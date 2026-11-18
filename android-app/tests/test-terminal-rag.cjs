const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const { RagState } = require('../assets/terminal/rag.js');
const assets = path.join(__dirname, '../assets/terminal');
function snapshot(count = 0, cursor = 0, instance = 'one', allowed = true) {
    return { instance_id: instance, event_cursor: cursor, ready: true, models: ['e5', 'tinybert', 'nli', 'gliner'].map(id => ({ id, connected: true, ready: true, active_count: id === 'e5' ? count : 0, loaded: id === 'e5' })), preflight: { enabled: true, terminal_allowed: allowed, reason: allowed ? 'ready' : 'selftest failed' } };
}
function packet(count, cursor, events = [], instance = 'one', extra = {}) {
    return { cursor, events, snapshot: snapshot(count, cursor, instance), oldest_seq: 1, truncated: false, ...extra };
}
function lamp(state, now, id = 'e5') { return state.view(now).find(model => model.id === id).lamp; }
test('default state is disconnected and terminal denied', () => {
    const state = new RagState();
    assert.equal(state.preflight.terminal_allowed, false);
    assert.deepEqual(state.view(0).map(model => model.lamp), ['red', 'red', 'red', 'red']);
});
test('retained fast start/end gets 500ms from first visible frame', () => {
    const state = new RagState();
    state.status(snapshot());
    state.events(packet(0, 2, [{ seq: 1, model_id: 'e5', active_count: 1, time: 5 }, { seq: 2, model_id: 'e5', active_count: 0, time: 10 }]));
    assert.equal(lamp(state, 1000), 'green');
    assert.equal(state.models.get('e5').active_count, 0);
    assert.equal(lamp(state, 1499), 'green');
    assert.equal(lamp(state, 1500), 'yellow');
    assert.equal(lamp(state, 1500, 'tinybert'), 'yellow');
});
test('long work stays green and periodic snapshots do not renew the hold', () => {
    const state = new RagState();
    state.status(snapshot(1));
    assert.equal(lamp(state, 0), 'green');
    for (let now = 250; now < 2000; now += 250) {
        state.events(packet(1, 0));
        assert.equal(lamp(state, now), 'green');
    }
    state.events(packet(0, 1, [{ seq: 1, model_id: 'e5', active_count: 0 }]));
    assert.equal(lamp(state, 2000), 'yellow');
});
test('overlapping work remains green until the final operation ends', () => {
    const state = new RagState();
    state.status(snapshot());
    state.events(packet(2, 2, [{ seq: 1, model_id: 'e5', active_count: 1 }, { seq: 2, model_id: 'e5', active_count: 2 }]));
    assert.equal(lamp(state, 0), 'green');
    state.events(packet(1, 3, [{ seq: 3, model_id: 'e5', active_count: 1 }]));
    assert.equal(lamp(state, 600), 'green');
    state.events(packet(0, 4, [{ seq: 4, model_id: 'e5', active_count: 0 }]));
    assert.equal(lamp(state, 800), 'yellow');
});
test('disconnect immediately overrides the minimum green hold and denies input', () => {
    const state = new RagState();
    state.status(snapshot(1));
    assert.equal(lamp(state, 0), 'green');
    state.disconnect('offline');
    assert.equal(lamp(state, 20), 'red');
    assert.equal(state.preflight.terminal_allowed, false);
});
test('instance changes and truncated history do not replay old activity', () => {
    for (const reset of ['instance', 'truncated', 'gap']) {
        const state = new RagState();
        state.status(snapshot());
        const extra = reset === 'truncated' ? { truncated: true } : reset === 'gap' ? { oldest_seq: 9 } : {};
        state.events(packet(0, 10, [{ seq: 9, model_id: 'e5', active_count: 1 }, { seq: 10, model_id: 'e5', active_count: 0 }], reset === 'instance' ? 'two' : 'one', extra));
        assert.equal(lamp(state, 0), 'yellow');
        assert.equal(state.cursor, 10);
    }
});
test('reconnect shows current activity but does not retain a previous pulse', () => {
    const state = new RagState();
    state.status(snapshot(1));
    lamp(state, 0);
    state.disconnect();
    state.status(snapshot(0, 50));
    assert.equal(lamp(state, 100), 'yellow');
    state.disconnect();
    state.status(snapshot(1, 60));
    assert.equal(lamp(state, 200), 'green');
});
test('duplicate events cannot replay a completed pulse', () => {
    const state = new RagState();
    state.status(snapshot());
    const value = packet(0, 2, [{ seq: 1, model_id: 'e5', active_count: 1 }, { seq: 2, model_id: 'e5', active_count: 0 }]);
    state.events(value);
    lamp(state, 0);
    assert.equal(lamp(state, 500), 'yellow');
    state.events(value);
    assert.equal(lamp(state, 600), 'yellow');
});
test('native preflight is authoritative including native owner bypass', () => {
    const state = new RagState();
    state.status(snapshot(0, 0, 'one', false));
    assert.equal(state.preflight.terminal_allowed, false);
    state.status({ ready: false, error: 'rag_unreachable', preflight: { enabled: false, terminal_allowed: true, reason: 'owner bypass' } });
    assert.equal(state.preflight.terminal_allowed, true);
    assert.equal(lamp(state, 0), 'red');
});
function harness(search = '') {
    const nodes = new Map();
    const windowEvents = new Map();
    const requests = [];
    const sockets = [];
    class Element {
        constructor() { this.dataset = {}; this.style = { setProperty() {} }; this.listeners = new Map(); this.children = []; this.textContent = ''; this.value = ''; this.bounds = { width: 640, height: 400 }; }
        addEventListener(name, fn) { this.listeners.set(name, fn); }
        setAttribute(name, value) { this[name] = value; }
        append(...values) { this.children.push(...values); }
        replaceChildren(...values) { this.children = values; }
        getBoundingClientRect() { return this.bounds; }
    }
    function node(id) { if (!nodes.has(id)) nodes.set(id, new Element()); return nodes.get(id); }
    class MockTerminal {
        constructor() { this.options = {}; this.rows = 20; this.cols = 80; this.writes = []; }
        loadAddon() {}
        open() {}
        reset() {}
        focus() {}
        onData(fn) { this.input = fn; }
        onBinary(fn) { this.binary = fn; }
        write(value, callback) { this.writes.push(value); callback?.(); }
    }
    class MockSocket {
        static OPEN = 1;
        static CONNECTING = 0;
        constructor(url) { this.url = url; this.readyState = 0; this.sent = []; this.closed = 0; sockets.push(this); }
        send(value) { this.sent.push(value); }
        close() { this.closed++; this.readyState = 3; }
    }
    const context = {
        Terminal: MockTerminal, FitAddon: { FitAddon: class { fit() {} } }, WebSocket: MockSocket,
        document: { getElementById: node, querySelector: node, querySelectorAll: () => [], createElement: () => new Element(), documentElement: node('root') },
        window: { innerHeight: 800, addEventListener(name, fn) { if (!windowEvents.has(name)) windowEvents.set(name, []); windowEvents.get(name).push(fn); }, dispatchEvent(event) { for (const listener of windowEvents.get(event.type) || []) listener(event); } },
        location: { href: `http://localhost/terminal${search}`, protocol: 'http:', host: 'localhost', assign() {} },
        history: { replaceState() {} }, URL, TextEncoder, Uint8Array, DataView, AbortController,
        ResizeObserver: class { observe() {} }, setTimeout() { return 1; }, clearTimeout() {},
        fetch: async (url, options = {}) => {
            requests.push({ url, options });
            return { ok: true, json: async () => options.method === 'POST' ? { session: 'new-session' } : { sessions: [{ session: 'saved', running: true, pid: 42 }, { session: 'new-session', running: true, pid: 43 }] } };
        }
    };
    vm.createContext(context);
    vm.runInContext(fs.readFileSync(path.join(assets, 'app.js'), 'utf8'), context);
    return { context, nodes, requests, sockets, gate: allowed => context.window.dispatchEvent({ type: 'rag-preflight', detail: { enabled: true, terminal_allowed: allowed, reason: allowed ? 'ready' : 'health lost' } }), evaluate: source => vm.runInContext(source, context) };
}
async function settle() { for (let i = 0; i < 8; i++) await Promise.resolve(); }
test('fresh page creates no PTY and attaches no socket before preflight', async () => {
    const h = harness();
    await settle();
    assert.equal(h.requests.length, 0);
    assert.equal(h.sockets.length, 0);
    h.gate(false);
    assert.equal(h.nodes.get('new-terminal').disabled, true);
    h.gate(true);
    await settle();
    assert.equal(h.requests.filter(item => item.options.method === 'POST').length, 1);
    assert.equal(h.sockets.length, 1);
    assert.match(h.sockets[0].url, /session=new-session&cursor=0/);
});
test('saved PTY waits for preflight; lost health blocks input without closing output or jobs', async () => {
    const h = harness('?session=saved');
    assert.equal(h.sockets.length, 0);
    h.gate(true);
    const socket = h.sockets[0];
    socket.readyState = 1;
    socket.onmessage({ data: JSON.stringify({ type: 'state', session: 'saved', running: true, pid: 42 }) });
    await settle();
    h.evaluate("terminal.input('before')");
    assert.equal(new TextDecoder().decode(socket.sent.at(-1)), 'before');
    h.gate(false);
    const sent = socket.sent.length;
    h.evaluate("terminal.input('blocked'); terminal.binary('blocked'); connect(); createSession(false); recoverConnection()");
    await settle();
    assert.equal(socket.sent.length, sent);
    assert.equal(socket.closed, 0);
    assert.equal(h.sockets.length, 1);
    assert.equal(h.requests.filter(item => item.options.method === 'POST').length, 0);
    const bytes = new Uint8Array(11);
    new DataView(bytes.buffer).setUint32(4, 27);
    bytes.set([111, 117, 116], 8);
    socket.onmessage({ data: bytes.buffer });
    assert.equal(socket.sent.at(-1), 'ack:27');
    assert.equal(h.evaluate('cursor'), 27);
    h.gate(true);
    h.evaluate("terminal.input('after')");
    assert.equal(new TextDecoder().decode(socket.sent.at(-1)), 'after');
    assert.equal(h.sockets.length, 1);
});
test('reattach preserves session cursor and terminal resize remains functional', async () => {
    const h = harness('?session=saved');
    h.gate(true);
    const first = h.sockets[0];
    first.readyState = 1;
    first.onmessage({ data: JSON.stringify({ type: 'state', session: 'saved', running: true, pid: 42 }) });
    await settle();
    h.evaluate('cursor = 123; terminal.rows = 30; terminal.cols = 90; resize()');
    assert.equal(first.sent.at(-1), 'resize:30:90');
    first.readyState = 3;
    h.gate(false);
    h.gate(true);
    assert.equal(h.sockets.length, 2);
    assert.match(h.sockets[1].url, /session=saved&cursor=123/);
});
test('T-EEC keeps one terminal with an integrated pane and three module switches', () => {
    const html = fs.readFileSync(path.join(assets, 'index.html'), 'utf8');
    const css = fs.readFileSync(path.join(assets, 'style.css'), 'utf8');
    assert.match(html, /<html lang="en">/);
    assert.match(html, /<title>T-EEC<\/title>/);
    for (const id of ['terminal', 'status', 'session', 'sessions', 'keyboard', 'reconnect', 'new-terminal', 'close-terminal', 'open-terminal', 'toggle-pane', 'eec-pane']) assert.ok(html.includes(`id="${id}"`));
    assert.equal((html.match(/<main\b/g) || []).length, 1);
    assert.equal((html.match(/<aside\b/g) || []).length, 1);
    assert.match(html, /<div class="terminal-body">\s*<div id="terminal"[^>]*><\/div>\s*<aside id="eec-pane"/);
    assert.equal((html.match(/role="switch"/g) || []).length, 3);
    for (const id of ['epistemic', 'evidence', 'capsule']) {
        assert.match(html, new RegExp(`<input id="${id}" type="checkbox" role="switch"`));
        assert.match(html, new RegExp(`<output id="${id}-state" for="${id}">OFF<\\/output>`));
    }
    assert.doesNotMatch(html, /<nav\b|data-view=|id="(?:rag-|view-)|src="\/terminal\/rag\.js"/);
    for (const script of ['app.js', 'teec.js']) assert.ok(html.includes(`src="/terminal/${script}"`));
    assert.match(css, /\.terminal-area\{[^}]*block-size:var\(--viewport-height\)/);
    assert.match(css, /\.terminal-body\{[^}]*grid-template-columns:minmax\(0,1fr\) var\(--pane-width\)/);
    assert.match(css, /\[hidden\]\{display:none!important\}/);
});
test('panel controller renders four model rows, uses actual events and sends service test payloads', async () => {
    const h = harness('?session=saved');
    let now = 1000;
    let timerId = 0;
    const timers = new Map();
    const frames = new Map();
    const posts = [];
    const summaries = [];
    h.context.window.addEventListener('teec:rag-state', event => summaries.push(event.detail));
    const fallbackFetch = h.context.fetch;
    const healthy = snapshot();
    healthy.models.find(model => model.id === 'tinybert').ready = false;
    healthy.selftest = { running: false, passed: true, finished_at: 1, last_error: null };
    Object.assign(h.context, {
        performance: { now: () => now },
        CustomEvent: class { constructor(type, options) { this.type = type; this.detail = options.detail; } },
        requestAnimationFrame(fn) { frames.set(++timerId, fn); return timerId; },
        cancelAnimationFrame(id) { frames.delete(id); },
        setTimeout(fn, delay) { timers.set(++timerId, { fn, at: now + delay }); return timerId; },
        clearTimeout(id) { timers.delete(id); },
        fetch: async (url, options = {}) => {
            if (!url.startsWith('/control/rag/')) return fallbackFetch(url, options);
            if (options.method === 'POST') {
                posts.push({ url, body: JSON.parse(options.body) });
                return { ok: true, json: async () => ({ upstream_status: url.endsWith('selftest') ? 202 : 200 }) };
            }
            return { ok: true, json: async () => url.endsWith('/status') ? healthy : packet(0, 2, [{ seq: 1, model_id: 'e5', active_count: 1 }, { seq: 2, model_id: 'e5', active_count: 0 }]) };
        }
    });
    h.context.document.hidden = false;
    h.context.document.addEventListener = () => {};
    function renderFrames() {
        const pending = [...frames.values()];
        frames.clear();
        for (const frame of pending) frame(now);
    }
    function tick(time) {
        now = time;
        const due = [...timers].filter(([, timer]) => timer.at <= now);
        for (const [id, timer] of due) { timers.delete(id); timer.fn(); }
    }
    vm.runInContext(fs.readFileSync(path.join(assets, 'rag.js'), 'utf8'), h.context);
    await settle();
    renderFrames();
    const rows = h.nodes.get('rag-models').children;
    assert.equal(rows.length, 4);
    assert.deepEqual(rows.map(row => row.dataset.model), ['e5', 'tinybert', 'nli', 'gliner']);
    assert.deepEqual(rows.map(row => row.children[0].textContent), ['E5', 'TinyBERT', 'NLI', 'GLiNER']);
    assert.equal(rows[0].children[0].title, 'multilingual-e5-small');
    assert.match(rows[0].children[0]['aria-label'], /multilingual-e5-small/);
    assert.ok(rows.every(row => row.children[1].children.length === 3));
    assert.equal(rows[0].dataset.lamp, 'yellow');
    assert.equal(rows[1].dataset.lamp, '');
    assert.equal(rows[1].children[3].disabled, false);
    assert.match(h.nodes.get('rag-test-state').textContent, /passed/);
    assert.equal(summaries.at(-1).reachable, true);
    assert.equal(summaries.at(-1).readyCount, 3);
    assert.equal(summaries.at(-1).preflight.terminal_allowed, true);
    assert.deepEqual(Array.from(summaries.at(-1).models, model => model.lamp), rows.map(row => row.dataset.lamp));
    assert.equal(h.sockets.length, 1);
    rows[0].children[3].listeners.get('click')();
    await settle();
    renderFrames();
    assert.deepEqual(posts[0], { url: '/control/rag/models/e5/run', body: { texts: ['Paris is the capital of France.'], kind: 'passage' } });
    assert.equal(rows[0].dataset.lamp, 'yellow');
    assert.equal(summaries.at(-1).models[0].lamp, 'yellow');
    const beforeActivity = summaries.length;
    tick(1250);
    await settle();
    renderFrames();
    assert.equal(rows[0].dataset.lamp, 'green');
    assert.equal(rows[1].dataset.lamp, 'yellow');
    assert.ok(summaries.length > beforeActivity);
    assert.equal(summaries.at(-1).readyCount, 4);
    assert.equal(summaries.at(-1).models[0].lamp, 'green');
    assert.equal(summaries.at(-1).preflight.terminal_allowed, true);
    tick(1749);
    await settle();
    renderFrames();
    assert.equal(rows[0].dataset.lamp, 'green');
    tick(1750);
    renderFrames();
    assert.equal(rows[0].dataset.lamp, 'yellow');
    assert.equal(summaries.at(-1).models[0].lamp, 'yellow');
    h.nodes.get('rag-selftest').listeners.get('click')();
    await settle();
    renderFrames();
    assert.match(h.nodes.get('rag-feedback').textContent, /started/);
    assert.deepEqual(posts.at(-1), { url: '/control/rag/selftest', body: {} });
    h.context.fetch = async () => { throw new Error('offline'); };
    tick(2000);
    await settle();
    renderFrames();
    assert.ok(rows.every(row => row.dataset.lamp === 'red'));
    assert.equal(summaries.at(-1).reachable, false);
    assert.equal(summaries.at(-1).readyCount, 0);
    assert.equal(summaries.at(-1).preflight.terminal_allowed, false);
    assert.ok(summaries.at(-1).models.every(model => model.lamp === 'red'));
    assert.equal(h.nodes.get('new-terminal').disabled, true);
    assert.equal(h.sockets[0].closed, 0);
});
