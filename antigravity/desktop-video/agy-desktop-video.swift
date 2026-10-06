// Plays the agy-wallpaper video as a live desktop wallpaper (under every other window).
// Pair it with a transparent Ghostty (background-opacity < 1) and the video shows through.
//
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

        rebuildWindows()
        reloadIfLinkChanged()
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in self?.reloadIfLinkChanged() }
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
        let anyVisible = windows.contains { $0.occlusionState.contains(.visible) }
        if anyVisible && !displayAsleep { player.play() } else { player.pause() }
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let wallpaper = DesktopVideo()
_ = wallpaper
app.run()
