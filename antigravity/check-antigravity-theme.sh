#!/bin/bash
# Smoke test for the Antigravity theme. Run after an update (and after re-applying the theme)
# to find out what, if anything, Google changed. Reads the running app over its debug port.
#
#   FAIL = the theme is broken (exit 1)
#   WARN = a selector matched nothing; fine if that view isn't open right now, otherwise it drifted
set -e

if ! command -v node >/dev/null; then echo "node is required"; exit 2; fi
if ! pgrep -x Antigravity >/dev/null; then echo "Antigravity is not running"; exit 2; fi

PORT=""
for p in $(lsof -nP -iTCP -sTCP:LISTEN 2>/dev/null | awk '/Antigravi/ {print $9}' | sed 's/.*://'); do
    if curl -s -m 2 "http://localhost:$p/json" 2>/dev/null | grep -q webSocketDebuggerUrl; then PORT=$p; break; fi
done
if [ -z "$PORT" ]; then
    echo "No debug port found. Relaunch with:  open -a Antigravity --args --remote-debugging-port=9222"
    exit 2
fi

DBG_PORT="$PORT" node --input-type=module - <<'EOF'
const targets = await (await fetch(`http://localhost:${process.env.DBG_PORT}/json`)).json();
const t = targets.find(x => x.type === 'page' && x.url.startsWith('https://127.0.0.1'));
if (!t) { console.log('FAIL  no Antigravity page target found'); process.exit(1); }

const ws = new WebSocket(t.webSocketDebuggerUrl);
await new Promise(r => ws.onopen = r);
let id = 0, ctx;
const pend = new Map();
ws.onmessage = e => {
  const m = JSON.parse(e.data);
  if (m.id && pend.has(m.id)) { pend.get(m.id)(m); pend.delete(m.id); }
  if (m.method === 'Runtime.executionContextCreated' && ctx === undefined && m.params.context.name === '') ctx = m.params.context.id;
};
const send = (method, params = {}) => new Promise(r => { const i = ++id; pend.set(i, r); ws.send(JSON.stringify({ id: i, method, params })); });
await send('Runtime.enable');
await new Promise(r => setTimeout(r, 800));

const page = () => {
  const out = { fail: [], warn: [], ok: [] };
  const alpha = c => {
    if (!c || c === 'transparent') return 0;
    const m = /rgba?\(([^)]+)\)/.exec(c);
    if (!m) return 1;
    const p = m[1].split(/[ ,/]+/);
    return p.length > 3 ? parseFloat(p[3]) : 1;
  };
  const root = getComputedStyle(document.documentElement);

  // 1. Injection
  document.getElementById('antigravity-custom-css') ? out.ok.push('theme stylesheet injected') : out.fail.push('theme stylesheet (#antigravity-custom-css) not injected');
  document.getElementById('antigravity-video-bg') ? out.ok.push('video background injected') : out.fail.push('video background element missing');

  // 2. The app still themes itself through the variables we override
  const cssText = [...document.styleSheets].map(s => { try { return [...s.cssRules].map(r => r.cssText).join('') } catch { return '' } }).join('');
  for (const v of ['background', 'sidebar', 'sidebar-muted', 'card', 'card-border', 'muted']) {
    cssText.includes(`--color-${v}`) ? out.ok.push(`app still defines --color-${v}`) : out.fail.push(`app no longer defines --color-${v} (variable renamed? theme will not apply)`);
  }
  root.getPropertyValue('--background').trim() === 'transparent' ? out.ok.push('--background override active') : out.fail.push('--background override not active');

  // 3. Tinted regions render as tinted
  const sb = document.querySelector('div.bg-sidebar');
  if (!sb) out.fail.push('no div.bg-sidebar found (sidebar class renamed?)');
  else alpha(getComputedStyle(sb).backgroundColor) > 0.5 ? out.ok.push('sidebar is tinted') : out.fail.push('sidebar is not tinted');

  // 4. Structural selectors (view-dependent, so WARN only)
  const sel = {
    'Install IDE button': '[data-testid="install-editor"]',
    'right pane (header + body)': 'div:has(> div[class*="border-b"][class*="pr-[72px]"]) > div:not([class*="border-b"])',
    'chat column (conversation-view)': '[data-testid="conversation-view"]',
    'sidebar conversation rows': '[data-testid="conversation-row-sidebar"]',
    'row hover actions': '[data-testid="conversation-row-sidebar"] div[class*="group-hover:opacity-100"]',
    'terminal (xterm)': '.xterm-scrollable-element',
  };
  for (const [name, s] of Object.entries(sel)) {
    document.querySelector(s) ? out.ok.push(`selector matches: ${name}`) : out.warn.push(`selector matches nothing: ${name} (open that view, or the DOM changed)`);
  }

  // 5. Large opaque surfaces we did not intend
  const area = innerWidth * innerHeight * 0.03;
  const known = c => /^rgba\((18, 18, 18|24, 24, 24|34, 34, 34|21, 21, 21)/.test(c);
  const stray = [...document.querySelectorAll('body *')]
    .filter(e => { const r = e.getBoundingClientRect(); return r.width * r.height > area && !e.closest('.xterm,.monaco-editor,video'); })
    .map(e => ({ e, bg: getComputedStyle(e).backgroundColor }))
    .filter(x => alpha(x.bg) > 0.5 && !known(x.bg));
  stray.length === 0
    ? out.ok.push('no unexpected opaque panels')
    : stray.slice(0, 6).forEach(x => out.warn.push(`unexpected opaque panel: <${x.e.tagName.toLowerCase()} class="${(x.e.getAttribute('class') || '').slice(0, 60)}"> ${x.bg}`));

  return JSON.stringify(out);
};

const r = await send('Runtime.evaluate', { expression: `(${page})()`, contextId: ctx, returnByValue: true });
const res = JSON.parse(r.result.result.value);
res.ok.forEach(m => console.log('ok    ' + m));
res.warn.forEach(m => console.log('WARN  ' + m));
res.fail.forEach(m => console.log('FAIL  ' + m));
console.log(`\n${res.ok.length} ok, ${res.warn.length} warn, ${res.fail.length} fail`);
ws.close();
process.exit(res.fail.length ? 1 : 0);
EOF
