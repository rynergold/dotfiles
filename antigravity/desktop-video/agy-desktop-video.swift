// Plays the agy-wallpaper video in two places:
//   1. as a live desktop wallpaper (under every other window), and
//   2. as a backdrop that follows each Ghostty window, sitting directly beneath it in the
//      stacking order, so a transparent Ghostty (background-opacity < 1) shows the video
//      no matter which other apps are open behind it.
//
// - Hides all video windows while an app from `hideFor` has a panel on screen (EasyTab's blurred
//   panel would otherwise sample and show the video). Override with AGY_HIDE_FOR=bundle.id,bundle.id.
// - The Ghostty backdrop gets a black veil; strength comes from ~/.gemini/antigravity/ghostty-video-dim
//   (0...1, set with `agy-wallpaper dim 0.7`).
// - Follows ~/.gemini/antigravity/wallpaper.mp4 (a symlink managed by agy-wallpaper); re-points live.
// - Pauses when the desktop is fully covered by windows, or when the display sleeps.
// - One player drives one window per screen, on every Space, ignoring the mouse.
import Cocoa
import AVFoundation

final class DesktopVideo: NSObject {
    let link = (NSHomeDirectory() as NSString).appendingPathComponent(".gemini/antigravity/wallpaper.mp4")
    let player = AVQueuePlayer()
    var looper: AVPlayerLooper?
    var windows: [NSWindow] = []
    var lastTarget = ""
    var displayAsleep = false
    var backdrops: [CGWindowID: NSWindow] = [:]
    let ghosttyBundleID = "com.mitchellh.ghostty"
    let dimFile = (NSHomeDirectory() as NSString).appendingPathComponent(".gemini/antigravity/ghostty-video-dim")
    var ghosttyDim: Float = 0.7
    var lastDimRaw = ""
    let hideFor: [String] = {
        if let env = ProcessInfo.processInfo.environment["AGY_HIDE_FOR"] { return env.split(separator: ",").map(String.init) }
        return ["com.open.easytab"]
    }()
    var hiddenForOverlay = false

    override init() {
        super.init()
        player.isMuted = true
        player.volume = 0
        // Default is true: a playing video would keep the display awake forever.
        player.preventsDisplaySleepDuringVideoPlayback = false
        player.automaticallyWaitsToMinimizeStalling = false

        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(rebuildWindows), name: NSApplication.didChangeScreenParametersNotification, object: nil)
        let wnc = NSWorkspace.shared.notificationCenter
        wnc.addObserver(self, selector: #selector(sleepChanged(_:)), name: NSWorkspace.screensDidSleepNotification, object: nil)
        wnc.addObserver(self, selector: #selector(sleepChanged(_:)), name: NSWorkspace.screensDidWakeNotification, object: nil)

        wnc.addObserver(self, selector: #selector(syncBackdrops), name: NSWorkspace.didActivateApplicationNotification, object: nil)
        wnc.addObserver(self, selector: #selector(syncBackdrops), name: NSWorkspace.activeSpaceDidChangeNotification, object: nil)

        rebuildWindows()
        reloadIfLinkChanged()
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            self?.reloadIfLinkChanged()
            self?.reloadDimIfChanged()
        }
        reloadDimIfChanged()
        scheduleTracking()
    }

    // MARK: Ghostty backdrops

    func scheduleTracking() {
        // 20 Hz keeps the backdrop glued to a moving window; 1 Hz while Ghostty isn't running.
        let ghosttyRunning = !NSRunningApplication.runningApplications(withBundleIdentifier: ghosttyBundleID).isEmpty
        Timer.scheduledTimer(withTimeInterval: ghosttyRunning ? 0.05 : 1.0, repeats: false) { [weak self] _ in
            self?.syncBackdrops()
            self?.scheduleTracking()
        }
    }

    func reloadDimIfChanged() {
        let raw = (try? String(contentsOfFile: dimFile, encoding: .utf8))?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard raw != lastDimRaw else { return }
        lastDimRaw = raw
        if let v = Float(raw) { ghosttyDim = max(0, min(1, v)) }
        for win in backdrops.values { applyDim(to: win) }
    }

    func applyDim(to win: NSWindow) {
        win.contentView?.layer?.sublayers?.first(where: { $0.name == "dim" })?.opacity = ghosttyDim
    }

    func overlayVisible(_ info: [[String: Any]]) -> Bool {
        let pids = Set(hideFor.flatMap { NSRunningApplication.runningApplications(withBundleIdentifier: $0) }.map { $0.processIdentifier })
        if pids.isEmpty { return false }
        return info.contains { w in
            guard let pid = w[kCGWindowOwnerPID as String] as? pid_t, pids.contains(pid),
                  (w[kCGWindowAlpha as String] as? Double ?? 1) > 0,
                  let b = w[kCGWindowBounds as String] as? [String: CGFloat],
                  (b["Width"] ?? 0) >= 150, (b["Height"] ?? 0) >= 80
            else { return false }
            return true
        }
    }

    func makeBackdrop() -> NSWindow {
        let win = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 400, height: 300), styleMask: .borderless, backing: .buffered, defer: false)
        win.level = .normal
        // moveToActiveSpace: follows Ghostty to whichever Space it is shown on.
        win.collectionBehavior = [.moveToActiveSpace, .stationary, .ignoresCycle, .fullScreenAuxiliary]
        win.ignoresMouseEvents = true
        win.isOpaque = true
        win.backgroundColor = .black
        win.hasShadow = false
        win.isReleasedWhenClosed = false
        let view = NSView(frame: win.contentRect(forFrameRect: win.frame))
        view.wantsLayer = true
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.bounds
        layer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        view.layer?.addSublayer(layer)
        let dim = CALayer()
        dim.name = "dim"
        dim.backgroundColor = NSColor.black.cgColor
        dim.opacity = ghosttyDim
        dim.frame = view.bounds
        dim.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        view.layer?.addSublayer(dim)
        win.contentView = view
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlayback), name: NSWindow.didChangeOcclusionStateNotification, object: win)
        return win
    }

    @objc func syncBackdrops() {
        let pids = Set(NSRunningApplication.runningApplications(withBundleIdentifier: ghosttyBundleID).map { $0.processIdentifier })
        let info = (CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]]) ?? []

        // An overlay app (EasyTab) is showing a blurred panel: take every video window away so it
        // samples the normal desktop instead, and bring them back when the panel closes.
        if overlayVisible(info) {
            if !hiddenForOverlay {
                hiddenForOverlay = true
                windows.forEach { $0.orderOut(nil) }
                removeBackdrops(keeping: [])
                updatePlayback()
            }
            return
        }
        if hiddenForOverlay {
            hiddenForOverlay = false
            windows.forEach { $0.orderFrontRegardless() }
        }

        guard !pids.isEmpty else { removeBackdrops(keeping: []); updatePlayback(); return }

        let mine = Set(backdrops.values.map { CGWindowID($0.windowNumber) })
        var seen = Set<CGWindowID>()
        let primaryHeight = NSScreen.screens.first?.frame.height ?? 0

        // `info` is ordered front to back.
        for (i, w) in info.enumerated() {
            guard let pid = w[kCGWindowOwnerPID as String] as? pid_t, pids.contains(pid),
                  (w[kCGWindowLayer as String] as? Int) == 0,
                  (w[kCGWindowAlpha as String] as? Double ?? 1) > 0,
                  let id = w[kCGWindowNumber as String] as? CGWindowID,
                  let bounds = w[kCGWindowBounds as String] as? [String: CGFloat],
                  let x = bounds["X"], let y = bounds["Y"], let width = bounds["Width"], let height = bounds["Height"],
                  width >= 200, height >= 150
            else { continue }

            seen.insert(id)
            let frame = NSRect(x: x, y: primaryHeight - y - height, width: width, height: height)
            let win = backdrops[id] ?? { let b = makeBackdrop(); backdrops[id] = b; return b }()
            if win.frame != frame { win.setFrame(frame, display: false) }

            // Already directly beneath this Ghostty window? Then leave the stacking alone.
            let below = i + 1 < info.count ? info[i + 1][kCGWindowNumber as String] as? CGWindowID : nil
            let myNumber = CGWindowID(win.windowNumber)
            if below != myNumber || !win.isVisible {
                win.order(.below, relativeTo: Int(id))
            }
            _ = mine
        }
        removeBackdrops(keeping: seen)
        updatePlayback()
    }

    func removeBackdrops(keeping: Set<CGWindowID>) {
        for (id, win) in backdrops where !keeping.contains(id) {
            win.orderOut(nil)
            backdrops[id] = nil
        }
    }

    @objc func rebuildWindows() {
        windows.forEach { $0.orderOut(nil) }
        windows = NSScreen.screens.map { screen in
            let win = NSWindow(contentRect: screen.frame, styleMask: .borderless, backing: .buffered, defer: false, screen: screen)
            win.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)) + 1)
            win.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
            win.ignoresMouseEvents = true
            win.isOpaque = true
            win.backgroundColor = .black
            win.hasShadow = false
            win.isReleasedWhenClosed = false
            let view = NSView(frame: NSRect(origin: .zero, size: screen.frame.size))
            view.wantsLayer = true
            let layer = AVPlayerLayer(player: player)
            layer.videoGravity = .resizeAspectFill
            layer.frame = view.bounds
            layer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
            view.layer?.addSublayer(layer)
            win.contentView = view
            win.orderFrontRegardless()
            NotificationCenter.default.addObserver(self, selector: #selector(updatePlayback), name: NSWindow.didChangeOcclusionStateNotification, object: win)
            return win
        }
        updatePlayback()
    }

    func reloadIfLinkChanged() {
        guard let target = try? FileManager.default.destinationOfSymbolicLink(atPath: link), target != lastTarget else { return }
        guard FileManager.default.fileExists(atPath: target) else { return }
        lastTarget = target
        player.pause()
        looper = nil
        player.removeAllItems()
        looper = AVPlayerLooper(player: player, templateItem: AVPlayerItem(url: URL(fileURLWithPath: target)))
        updatePlayback()
    }

    @objc func sleepChanged(_ n: Notification) {
        displayAsleep = (n.name == NSWorkspace.screensDidSleepNotification)
        updatePlayback()
    }

    @objc func updatePlayback() {
        let anyVisible = (windows + Array(backdrops.values)).contains { $0.occlusionState.contains(.visible) }
        if anyVisible && !displayAsleep { player.play() } else { player.pause() }
    }
}

let app = NSApplication.shared
// .prohibited (not .accessory): window switchers such as EasyTab list every normal-level window of a
// regular or "substantial accessory" app, which put this player's backdrop in their lists. Windows
// are still drawn normally for a prohibited app, and switchers skip it.
app.setActivationPolicy(.prohibited)
let wallpaper = DesktopVideo()
_ = wallpaper
app.run()
