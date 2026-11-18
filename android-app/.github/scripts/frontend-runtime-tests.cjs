const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const sourcePath = process.argv[2] || path.resolve(__dirname, '../../assets/terminal/app.js');
const source = fs.readFileSync(sourcePath, 'utf8');
const checks = [];
const sessionState = (session, values = {}) => ({ type: 'state', session, pid: 42, running: true, exit: -1, error: '', ...values });
const reply = (value, status = 200) => ({ ok: status >= 200 && status < 300, status, json: async () => value, text: async () => typeof value === 'string' ? value : JSON.stringify(value) });
const settle = () => new Promise(resolve => setImmediate(resolve));

function fixture(selected = 'current', protocol = 'http:') {
    const nodes = new Map();
    const timers = new Map();
    const sockets = [];
    const requests = [];
    const navigations = [];
    const replacements = [];
    const pendingReplies = [];
    let timerId = 0;
    let fitCount = 0;
    let listing = [sessionState(selected || 'created')];
    function node() {
        return {
            textContent: '', dataset: {}, disabled: false, value: '', children: [], listeners: new Map(), bounds: { width: 640, height: 400 },
            addEventListener(name, callback) { this.listeners.set(name, callback); },
            replaceChildren(...children) { this.children = children; this.value = children.find(child => child.selected)?.value || ''; },
            getBoundingClientRect() { return this.bounds; },
            async emit(name, event) { if (!this.disabled) await this.listeners.get(name)?.(event); }
        };
    }
    const getNode = id => { if (!nodes.has(id)) nodes.set(id, node()); return nodes.get(id); };
    const keys = ['interrupt', 'tab', 'escape', 'up', 'down'].map(key => ({ ...node(), dataset: { key } }));
    class Terminal {
        constructor() { this.options = {}; this.rows = 24; this.cols = 80; this.writes = []; this.resets = 0; this.callbacks = []; }
        loadAddon() {}
        open() {}
        onData(callback) { this.input = callback; }
        onBinary(callback) { this.binaryInput = callback; }
        focus() {}
        reset() { this.resets++; }
        write(bytes, callback) {
            this.writes.push(bytes);
            if (this.deferWrites && callback) this.callbacks.push(callback);
            else callback?.();
        }
    }
    class WebSocket {
        static OPEN = 1;
        static CONNECTING = 0;
        static CLOSED = 3;
        constructor(url) { this.url = url; this.readyState = 0; this.sent = []; this.closeCount = 0; sockets.push(this); }
        close() { this.closeCount++; this.readyState = 3; this.onclose?.(); }
        send(value) { this.sent.push(value); }
        async state(value = sessionState(selected)) { this.readyState = 1; this.onmessage({ data: JSON.stringify(value) }); await settle(); }
        fail() { this.readyState = 3; this.onerror?.(); this.onclose?.(); }
    }
    const windowNode = node();
    const context = vm.createContext({
        Terminal, WebSocket, AbortController, TextEncoder, Uint8Array, DataView, URL, Map,
        FitAddon: { FitAddon: class { fit() { fitCount++; } } },
        location: {
            href: `${protocol}//example.invalid:8866/terminal${selected ? `?session=${selected}` : ''}`,
            protocol, host: 'example.invalid:8866', assign(url) { navigations.push(url); }
        },
        document: {
            getElementById: getNode,
            querySelector: getNode,
            querySelectorAll: () => keys,
            createElement: node,
            documentElement: { style: { setProperty() {} } }
        },
        window: { ...windowNode, innerHeight: 600, ragPreflight: { enabled: true, terminal_allowed: true, reason: 'ready' } },
        ResizeObserver: class { observe() {} },
        history: { replaceState(state, title, url) { replacements.push(url); } },
        setTimeout(callback, delay) { const id = ++timerId; timers.set(id, { callback, delay }); return id; },
        clearTimeout(id) { timers.delete(id); },
        async fetch(url, options) {
            requests.push({ url, method: options?.method || 'GET', cache: options?.cache });
            const next = pendingReplies.shift();
            if (next) return typeof next === 'function' ? next(url, options) : next;
            if (options?.method === 'POST' && url === '/sessions') return reply(sessionState('created'), 201);
            if (url.endsWith('/close')) return reply(sessionState(selected, { running: false, exit: 0 }));
            return reply({ sessions: listing });
        }
    });
    vm.runInContext(source, context, { filename: sourcePath });
    return {
        context, sockets, timers, requests, navigations, replacements, keys, pendingReplies,
        node: getNode,
        terminal: vm.runInContext('terminal', context),
        fitCount: () => fitCount,
        emit: (name, event) => windowNode.emit(name, event),
        setListing(value) { listing = value; },
        evaluate(code) { return vm.runInContext(code, context); },
        async timer(delay) {
            const entry = [...timers].find(([, timer]) => timer.delay === delay);
            assert.ok(entry, `Expected a ${delay} ms timer`);
            timers.delete(entry[0]);
            await entry[1].callback();
            await settle();
        },
        async focus() { await windowNode.listeners.get('focus')(); },
        unload() { windowNode.listeners.get('beforeunload')(); }
    };
}

async function check(id, action) {
    await action();
    checks.push({ id, status: 'passed' });
}

async function main() {
    await check('stale-link-requires-explicit-existing-session-selection', async () => {
        const f = fixture('expired');
        f.setListing([sessionState('other-one'), sessionState('other-two')]);
        f.sockets[0].fail();
        await f.timer(1000);
        assert.equal(f.sockets.length, 1);
        assert.equal(f.sockets[0].readyState, 3);
        assert.equal(f.node('status').dataset.state, 'closed');
        assert.match(f.node('status').textContent, /Session no longer exists/);
        assert.equal(f.node('sessions').value, '');
        assert.deepEqual(f.node('sessions').children.map(item => item.value), ['', 'other-one', 'other-two']);
        assert.equal(f.node('sessions').disabled, false);
        assert.equal(f.node('close-terminal').disabled, true);
        assert.equal(f.timers.size, 0);
        await f.node('reconnect').emit('click');
        assert.equal(f.sockets.length, 1);
        assert.equal(f.timers.size, 0);
        assert.ok(f.requests.every(request => request.method === 'GET'));
        assert.deepEqual(f.navigations, []);
        assert.deepEqual(f.replacements, []);
        assert.equal(f.terminal.resets, 0);
        f.node('sessions').value = 'other-two';
        await f.node('sessions').emit('change');
        assert.deepEqual(f.navigations, ['/terminal?session=other-two']);
        assert.equal(f.sockets.length, 1);
    });

    await check('empty-session-list-does-not-create-or-loop', async () => {
        const f = fixture('expired');
        f.setListing([]);
        f.sockets[0].fail();
        await f.timer(1000);
        assert.equal(f.timers.size, 0);
        assert.equal(f.sockets.length, 1);
        assert.match(f.node('status').textContent, /create a terminal/);
        await f.node('close-terminal').emit('click');
        await f.focus();
        assert.ok(f.requests.every(request => request.method === 'GET'));
        assert.equal(f.node('new-terminal').disabled, false);
        await f.node('new-terminal').emit('click');
        assert.equal(f.requests.filter(request => request.method === 'POST').length, 1);
        assert.deepEqual(f.navigations, ['/terminal?session=created']);
    });

    await check('same-session-resumes-cursor-input-and-geometry', async () => {
        const f = fixture('current', 'https:');
        const original = f.sockets[0];
        await original.state();
        assert.equal(f.node('status').dataset.state, 'connected');
        assert.equal(original.sent[0], 'resize:24:80');
        const bytes = new Uint8Array(11);
        new DataView(bytes.buffer).setUint32(4, 384);
        bytes.set([65, 66, 67], 8);
        original.onmessage({ data: bytes.buffer });
        assert.equal(original.sent.at(-1), 'ack:384');
        f.terminal.input('a'.repeat(16385));
        assert.deepEqual(original.sent.slice(-2).map(value => value.length), [16384, 1]);
        f.terminal.binaryInput('\xff\x00');
        assert.deepEqual([...original.sent.at(-1)], [255, 0]);
        original.fail();
        const beforeDisconnectedInput = original.sent.length;
        f.terminal.input('must-not-send');
        assert.equal(original.sent.length, beforeDisconnectedInput);
        await f.timer(1000);
        const resumed = f.sockets.at(-1);
        assert.equal(new URL(resumed.url).protocol, 'wss:');
        assert.equal(new URL(resumed.url).searchParams.get('session'), 'current');
        assert.equal(new URL(resumed.url).searchParams.get('cursor'), '384');
        await resumed.state();
        assert.equal(resumed.sent[0], 'resize:24:80');
        assert.equal(f.terminal.resets, 0);
        assert.equal(f.node('status').dataset.state, 'connected');
        assert.ok(f.requests.every(request => request.method === 'GET'));
        assert.ok(f.keys.every(key => !key.disabled));
        await f.keys[0].emit('click');
        assert.deepEqual([...resumed.sent.at(-1)], [3]);
        original.onclose();
        assert.equal(f.node('status').dataset.state, 'connected');
    });

    await check('hidden-terminal-refits-on-view-change-without-session-changes', async () => {
        const f = fixture();
        const socket = f.sockets[0];
        const viewport = f.node('terminal');
        const initialFits = f.fitCount();
        viewport.bounds = { width: 0, height: 0 };
        await socket.state();
        f.evaluate('cursor = 384');
        await f.emit('resize');
        await f.emit('teec:view-changed');
        assert.equal(f.fitCount(), initialFits);
        assert.deepEqual(socket.sent, []);
        assert.equal(f.terminal.rows, 24);
        assert.equal(f.terminal.cols, 80);
        viewport.bounds = { width: 720, height: 480 };
        f.terminal.rows = 30;
        f.terminal.cols = 90;
        await f.emit('teec:view-changed');
        assert.equal(f.fitCount(), initialFits + 1);
        assert.deepEqual(socket.sent, ['resize:30:90']);
        await f.emit('teec:view-changed');
        assert.deepEqual(socket.sent, ['resize:30:90']);
        f.terminal.rows = 28;
        await f.emit('resize');
        assert.equal(socket.sent.at(-1), 'resize:28:90');
        assert.equal(f.evaluate('cursor'), 384);
        assert.equal(f.sockets.length, 1);
        assert.equal(socket.closeCount, 0);
        assert.equal(f.terminal.resets, 0);
        assert.ok(f.requests.every(request => request.method === 'GET'));
    });

    await check('list-error-clears-after-recovery-without-blocking-live-input', async () => {
        const f = fixture();
        await f.sockets[0].state();
        f.pendingReplies.push(reply('Permission denied: session store', 503));
        await f.focus();
        assert.match(f.node('status').textContent, /HTTP 503: Permission denied: session store/);
        assert.equal(f.node('status').dataset.state, 'error');
        assert.ok(f.keys.every(key => !key.disabled));
        f.terminal.input('echo still-connected\n');
        assert.equal(new TextDecoder().decode(f.sockets[0].sent.at(-1)), 'echo still-connected\n');
        await f.focus();
        assert.equal(f.node('status').textContent, 'Connected · Ubuntu Bash');
        assert.equal(f.node('status').dataset.state, 'connected');
        assert.equal(f.sockets.length, 1);
    });

    await check('create-and-close-errors-preserve-status-and-server-body', async () => {
        const f = fixture();
        await f.sockets[0].state();
        f.pendingReplies.push(reply({ error: 'PTY allocation failed' }, 500));
        await f.node('new-terminal').emit('click');
        assert.match(f.node('status').textContent, /Could not create terminal · HTTP 500: PTY allocation failed/);
        assert.equal(f.node('new-terminal').disabled, false);
        await f.focus();
        assert.match(f.node('status').textContent, /PTY allocation failed/);
        f.pendingReplies.push(reply({ message: 'Cannot close process 42' }, 409));
        await f.node('close-terminal').emit('click');
        assert.match(f.node('status').textContent, /Could not close terminal · HTTP 409: Cannot close process 42/);
        assert.deepEqual(f.navigations, []);
        assert.equal(f.sockets.length, 1);
        f.pendingReplies.push(reply('', 404));
        await f.node('close-terminal').emit('click');
        assert.match(f.node('status').textContent, /HTTP 404$/);
        await f.node('close-terminal').emit('click');
        assert.equal(f.node('status').dataset.state, 'connected');
    });

    await check('transport-recovery-retries-list-before-reopening-socket', async () => {
        const f = fixture();
        await f.sockets[0].state();
        f.sockets[0].fail();
        f.pendingReplies.push(reply('server restarting', 503));
        await f.timer(1000);
        assert.equal(f.sockets.length, 1);
        assert.match(f.node('status').textContent, /server restarting/);
        await f.timer(1000);
        assert.equal(f.sockets.length, 2);
        await f.sockets.at(-1).state();
        assert.equal(f.node('status').textContent, 'Connected · Ubuntu Bash');
        assert.equal(f.timers.size, 0);
        assert.ok(f.requests.every(request => request.method === 'GET'));
    });

    await check('closed-session-stays-closed-after-list-recovery', async () => {
        const f = fixture();
        await f.sockets[0].state(sessionState('current', { running: false, exit: 7 }));
        f.pendingReplies.push(reply('listing unavailable', 500));
        await f.focus();
        await f.focus();
        assert.equal(f.node('status').textContent, 'Closed · exit 7');
        assert.equal(f.node('status').dataset.state, 'closed');
        assert.ok(f.keys.every(key => key.disabled));
    });

    await check('late-list-response-cannot-overwrite-newer-session-list', async () => {
        const f = fixture();
        await f.sockets[0].state();
        let complete;
        let signal;
        f.pendingReplies.push((url, options) => new Promise(resolve => { signal = options.signal; complete = resolve; }));
        const delayed = f.focus();
        f.setListing([sessionState('current'), sessionState('newer')]);
        await f.focus();
        assert.equal(signal.aborted, true);
        complete(reply({ sessions: [sessionState('older')] }));
        await delayed;
        assert.deepEqual(f.node('sessions').children.map(item => item.value), ['current', 'newer']);
        assert.equal(f.node('status').dataset.state, 'connected');
    });

    await check('focus-superseding-recovery-does-not-create-extra-connections', async () => {
        const f = fixture();
        await f.sockets[0].state();
        f.sockets[0].fail();
        let signal;
        f.pendingReplies.push((url, options) => new Promise((resolve, reject) => {
            signal = options.signal;
            signal.addEventListener('abort', () => reject(new Error('superseded')));
        }));
        const recovering = f.timer(1000);
        await f.focus();
        await recovering;
        assert.equal(signal.aborted, true);
        assert.equal(f.sockets.length, 1);
        assert.equal([...f.timers.values()].filter(timer => timer.delay === 1000).length, 1);
        await f.timer(1000);
        assert.equal(f.sockets.length, 2);
        await f.sockets.at(-1).state();
        assert.equal(f.node('status').textContent, 'Connected · Ubuntu Bash');
        assert.equal(f.timers.size, 0);
        assert.ok(f.requests.every(request => request.method === 'GET'));
    });

    await check('pending-recovery-does-not-reconnect-after-unload', async () => {
        const f = fixture();
        f.sockets[0].fail();
        let complete;
        let signal;
        f.pendingReplies.push((url, options) => new Promise(resolve => { signal = options.signal; complete = resolve; }));
        const recovering = f.timer(1000);
        f.unload();
        assert.equal(signal.aborted, true);
        complete(reply({ sessions: [sessionState('current')] }));
        await recovering;
        assert.equal(f.sockets.length, 1);
        assert.equal(f.timers.size, 0);
    });

    await check('slow-create-has-no-deadline-or-automatic-retry', async () => {
        const f = fixture();
        let complete;
        let signal;
        f.pendingReplies.push((url, options) => new Promise(resolve => { signal = options.signal; complete = resolve; }));
        const creating = f.node('new-terminal').emit('click');
        await settle();
        assert.equal(f.node('new-terminal').disabled, true);
        assert.equal(f.timers.size, 0);
        assert.equal(signal.aborted, false);
        assert.equal(f.requests.length, 1);
        assert.deepEqual(f.navigations, []);
        complete(reply(sessionState('created'), 201));
        await creating;
        assert.equal(f.node('new-terminal').disabled, false);
        assert.deepEqual(f.navigations, ['/terminal?session=created']);
        assert.equal(f.sockets.length, 1);
        assert.equal(f.timers.size, 0);
    });

    await check('bare-terminal-keeps-existing-create-and-url-flow', async () => {
        const f = fixture('');
        await settle();
        assert.deepEqual(f.requests.map(request => [request.url, request.method]), [['/sessions', 'POST']]);
        assert.deepEqual(f.replacements, ['/terminal?session=created']);
        assert.equal(new URL(f.sockets[0].url).searchParams.get('session'), 'created');
        await f.sockets[0].state(sessionState('created'));
        assert.equal(f.node('status').dataset.state, 'connected');
        assert.equal(f.node('open-terminal').href, '/terminal?session=created');
    });

    await check('old-socket-write-callback-cannot-change-resumed-cursor', async () => {
        const f = fixture();
        const old = f.sockets[0];
        await old.state();
        f.terminal.deferWrites = true;
        const bytes = new Uint8Array(9);
        new DataView(bytes.buffer).setUint32(4, 90);
        old.onmessage({ data: bytes.buffer });
        old.fail();
        await f.timer(1000);
        const current = f.sockets.at(-1);
        f.terminal.callbacks.shift()();
        assert.equal(f.evaluate('cursor'), 0);
        assert.equal(current.sent.length, 0);
        assert.equal(old.sent.some(value => value === 'ack:90'), false);
    });

    console.log(JSON.stringify({
        schema: 'teec.frontend-runtime-regression/1',
        status: 'passed',
        source: { path: sourcePath, sha256: crypto.createHash('sha256').update(source).digest('hex') },
        scope: { network: 'isolated mocked HTTP and WebSocket', appRuntimeMutations: false, testClock: 'manually advanced', browserRendering: false },
        checkCount: checks.length,
        checks
    }, null, 2));
}

main().catch(error => { console.error(error); process.exitCode = 1; });
