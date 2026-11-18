const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const sourcePath = path.resolve(__dirname, '../../assets/terminal/control.js');
const source = fs.readFileSync(sourcePath, 'utf8');
const html = fs.readFileSync(path.resolve(__dirname, '../../assets/terminal/index.html'), 'utf8');
const checks = [];
const settle = () => new Promise(resolve => setImmediate(resolve));
const reply = (value, status = 200) => ({ ok: status >= 200 && status < 300, status, json: async () => value, text: async () => JSON.stringify(value) });
const profiles = ['terminal-openai', 'local-anthropic', 'local-gemini', 'external / test'].map(name => ({ name, endpoint: '/v1', header: 'Authorization: Bearer', has_key: true }));
const metadata = { configured: true, base_url: 'http://0.0.0.0:8317', upstream_provider: 'codex', profiles };
const fakeKey = 'synthetic-test-value-'.repeat(16);

function deferred() {
    let resolve;
    const promise = new Promise(accept => { resolve = accept; });
    return { promise, resolve };
}

function fixture(options = {}) {
    const nodes = new Map();
    const requests = [];
    const routes = new Map();
    const timers = [];
    const clipboardWrites = [];
    const selectionCopies = [];
    let focused;
    class Node {
        constructor(tag = 'div') {
            this.tagName = tag.toUpperCase();
            this.children = [];
            this.listeners = new Map();
            this.attributes = new Map();
            this.dataset = {};
            this.disabled = false;
            this.text = '';
            this.scrollHeight = 0;
            this.scrollTop = 0;
            this.clientHeight = 0;
        }
        set textContent(value) { this.text = String(value); this.children = []; }
        get textContent() { return this.text + this.children.map(child => child.textContent).join(''); }
        append(...children) { this.children.push(...children); }
        replaceChildren(...children) { this.text = ''; this.children = children; }
        setAttribute(name, value) { this.attributes.set(name, String(value)); }
        getAttribute(name) { return this.attributes.get(name); }
        removeAttribute(name) { this.attributes.delete(name); }
        addEventListener(name, callback) { this.listeners.set(name, callback); }
        querySelector() { return null; }
        focus() { focused = this; }
        async click() { if (!this.disabled) return this.listeners.get('click')?.(); }
    }
    const find = (node, id) => node.id === id ? node : node.children.map(child => find(child, id)).find(Boolean);
    const node = id => {
        for (const item of nodes.values()) {
            const found = find(item, id);
            if (found) return found;
        }
        if (!nodes.has(id)) { const item = new Node(); item.id = id; nodes.set(id, item); }
        return nodes.get(id);
    };
    const originalRange = { identity: 'previous-selection', cloneRange() { return this; } };
    const selection = {
        ranges: [originalRange],
        get rangeCount() { return this.ranges.length; },
        getRangeAt(index) { return this.ranges[index]; },
        removeAllRanges() { this.ranges = []; },
        addRange(range) { this.ranges.push(range); }
    };
    const document = {
        getElementById: node,
        createElement: tag => new Node(tag),
        get activeElement() { return focused; },
        createRange() { return { selectNodeContents(value) { this.value = value; } }; },
        execCommand(command) {
            assert.equal(command, 'copy');
            selectionCopies.push(selection.ranges[0]?.value.textContent);
            return options.copyResult !== false;
        }
    };
    focused = node('prior-focus');
    const navigator = options.clipboard === false ? {} : {
        clipboard: { async writeText(value) {
            clipboardWrites.push(value);
            if (options.clipboardError) throw new Error('clipboard denied');
            if (options.clipboardPending) await options.clipboardPending.promise;
        } }
    };
    if (options.metadata) routes.set('/control/cliproxy/profiles', [options.metadata]);
    const context = vm.createContext({
        document, navigator, window: { getSelection: () => selection },
        location: { origin: 'http://0.0.0.0:8866', port: '8866', protocol: 'http:' },
        WebSocket: { OPEN: 1 },
        setInterval(callback, delay) { timers.push({ callback, delay }); },
        async fetch(url, requestOptions) {
            requests.push({ url, options: requestOptions });
            const queued = routes.get(url);
            if (queued?.length) {
                const result = queued.shift();
                return typeof result === 'function' ? result() : result;
            }
            if (url === '/control/cliproxy/profiles') return reply(metadata);
            if (url.startsWith('/control/cliproxy/profiles/')) return reply({ name: decodeURIComponent(url.split('/').at(-1)), api_key: fakeKey });
            if (url === '/control/status') return reply({ settings: {}, orders: [] });
            if (url === '/health') return reply({ ssh: { port: 8122, running: true } });
            if (url === '/sessions') return reply({ sessions: [] });
            throw new Error('Unexpected request');
        }
    });
    vm.runInContext(source, context, { filename: sourcePath });
    return {
        node, requests, timers, clipboardWrites, selectionCopies, selection, originalRange,
        get focused() { return focused; },
        queue(url, result) { if (!routes.has(url)) routes.set(url, []); routes.get(url).push(result); },
        row(index = 0) {
            const row = node('proxy-profiles').children[index];
            return { element: row, name: row.children[0], value: row.children[2], toggle: row.children[3].children[0], copy: row.children[3].children[1], feedback: row.children[4] };
        },
        async poll() { await timers[0].callback(); await settle(); },
        async retry() { await node('proxy-profiles-retry').click(); await settle(); }
    };
}

async function check(name, action) {
    await action();
    checks.push({ name, status: 'passed' });
}

async function main() {
    await check('four-masked-profiles-with-no-key-fetch-on-load-or-status-poll', async () => {
        const f = fixture();
        await settle();
        assert.equal(f.node('proxy-profiles').children.length, 4);
        assert.equal(f.node('proxy-base-url').textContent, metadata.base_url);
        assert.equal(f.node('proxy-provider').textContent, metadata.upstream_provider);
        for (let index = 0; index < 4; index++) {
            const row = f.row(index);
            assert.equal(row.toggle.textContent, 'Toon');
            assert.equal(row.copy.disabled, true);
            assert.equal(row.value.dataset.revealed, 'false');
            assert.ok(!row.value.textContent.includes(fakeKey));
            assert.match(row.toggle.getAttribute('aria-label'), new RegExp(profiles[index].name));
        }
        await f.poll();
        await f.poll();
        assert.equal(f.requests.filter(item => item.url.startsWith('/control/cliproxy/')).length, 1);
        assert.ok(f.requests.every(item => item.options.cache === 'no-store'));
    });
    await check('reveal-copy-hide-and-reload-mask-without-timers', async () => {
        const f = fixture();
        await settle();
        const row = f.row();
        await row.toggle.click();
        assert.equal(row.value.textContent, fakeKey);
        assert.equal(row.toggle.textContent, 'Verberg');
        assert.equal(row.toggle.getAttribute('aria-expanded'), 'true');
        assert.equal(row.copy.disabled, false);
        await row.copy.click();
        assert.deepEqual(f.clipboardWrites, [fakeKey]);
        assert.equal(row.feedback.textContent, 'Gekopieerd.');
        assert.equal(row.value.textContent, fakeKey);
        await row.toggle.click();
        assert.ok(!f.node('proxy-profiles').textContent.includes(fakeKey));
        assert.equal(row.copy.disabled, true);
        assert.equal(row.toggle.getAttribute('aria-expanded'), 'false');
        await row.toggle.click();
        assert.equal(f.requests.filter(item => item.url === '/control/cliproxy/profiles/terminal-openai').length, 2);
        await f.retry();
        assert.ok(!f.node('proxy-profiles').textContent.includes(fakeKey));
        assert.equal(f.row().toggle.textContent, 'Toon');
        assert.equal(f.timers.length, 1);
        assert.equal(f.timers[0].delay, 2000);
        const reloaded = fixture();
        await settle();
        assert.equal(reloaded.row().value.dataset.revealed, 'false');
    });
    await check('insecure-http-selection-copy-restores-focus-and-selection', async () => {
        const f = fixture({ clipboard: false });
        await settle();
        const row = f.row();
        const focused = f.focused;
        await row.toggle.click();
        await row.copy.click();
        assert.deepEqual(f.selectionCopies, [fakeKey]);
        assert.equal(f.focused, focused);
        assert.deepEqual(f.selection.ranges, [f.originalRange]);
        assert.equal(row.feedback.textContent, 'Gekopieerd.');
    });
    await check('denied-clipboard-falls-back-and-failed-copy-explains-manual-selection', async () => {
        const f = fixture({ clipboardError: true, copyResult: false });
        await settle();
        const row = f.row();
        await row.toggle.click();
        await row.copy.click();
        assert.equal(f.clipboardWrites.length, 1);
        assert.equal(f.selectionCopies.length, 1);
        assert.equal(row.feedback.dataset.state, 'error');
        assert.match(row.feedback.textContent, /kopieer handmatig/);
        assert.equal(row.copy.disabled, false);
        assert.equal(row.value.textContent, fakeKey);
    });
    await check('hide-during-pending-reveal-prevents-late-key-display', async () => {
        const f = fixture();
        await settle();
        const delayed = deferred();
        f.queue('/control/cliproxy/profiles/terminal-openai', delayed.promise);
        const row = f.row();
        const reveal = row.toggle.click();
        assert.equal(row.toggle.textContent, 'Verberg');
        assert.equal(row.copy.disabled, true);
        await row.toggle.click();
        delayed.resolve(reply({ name: profiles[0].name, api_key: fakeKey }));
        await reveal;
        assert.equal(row.toggle.textContent, 'Toon');
        assert.equal(row.copy.disabled, true);
        assert.ok(!row.element.textContent.includes(fakeKey));
    });
    await check('failed-reveal-and-mismatched-profile-stay-masked-and-can-retry', async () => {
        const f = fixture();
        await settle();
        const row = f.row();
        const url = '/control/cliproxy/profiles/terminal-openai';
        f.queue(url, reply({ api_key: fakeKey }, 503));
        await row.toggle.click();
        assert.equal(row.feedback.dataset.state, 'error');
        assert.ok(!row.element.textContent.includes(fakeKey));
        assert.equal(row.copy.disabled, true);
        f.queue(url, reply({ name: 'other-profile', api_key: fakeKey }));
        await row.toggle.click();
        assert.equal(row.feedback.dataset.state, 'error');
        assert.ok(!row.element.textContent.includes(fakeKey));
        await row.toggle.click();
        assert.equal(row.value.textContent, fakeKey);
    });
    await check('profile-errors-empty-and-missing-keys-remain-actionable', async () => {
        const f = fixture({ metadata: reply({ failure: fakeKey }, 500) });
        await settle();
        assert.equal(f.node('proxy-profiles-status').dataset.state, 'error');
        assert.equal(f.node('proxy-profiles-retry').disabled, false);
        assert.ok(!f.node('proxy-profiles-status').textContent.includes(fakeKey));
        await f.retry();
        assert.equal(f.node('proxy-profiles').children.length, 4);
        f.queue('/control/cliproxy/profiles', reply({ configured: false, profiles: [] }));
        await f.retry();
        assert.match(f.node('proxy-profiles-status').textContent, /Nog geen/);
        f.queue('/control/cliproxy/profiles', reply({ ...metadata, profiles: [{ ...profiles[0], has_key: false }] }));
        await f.retry();
        assert.equal(f.row().toggle.disabled, true);
        assert.equal(f.row().copy.disabled, true);
        assert.equal(f.row().feedback.textContent, 'Geen sleutel ingesteld.');
    });
    await check('encoded-profile-name-and-long-key-remain-literal-text', async () => {
        const f = fixture();
        await settle();
        const row = f.row(3);
        await row.toggle.click();
        assert.ok(f.requests.some(item => item.url === '/control/cliproxy/profiles/external%20%2F%20test'));
        assert.equal(row.value.textContent, fakeKey);
        assert.equal(row.value.children.length, 0);
    });
    await check('hide-during-pending-copy-does-not-restore-secret-or-feedback', async () => {
        const pending = deferred();
        const f = fixture({ clipboardPending: pending });
        await settle();
        const row = f.row();
        await row.toggle.click();
        const copying = row.copy.click();
        await row.toggle.click();
        pending.resolve();
        await copying;
        assert.equal(row.value.dataset.revealed, 'false');
        assert.equal(row.feedback.textContent, '');
        assert.equal(row.copy.disabled, true);
    });
    await check('operations-surface-remains-read-only-with-semantic-controls', async () => {
        const operations = html.split('<aside id="operations"')[1].split('</aside>')[0];
        assert.doesNotMatch(operations, /<(?:input|textarea|form)\b|contenteditable\s*=\s*["']?true/i);
        assert.match(operations, /id="proxy-profiles-retry" type="button"/);
        assert.match(operations, /id="proxy-profiles-status" role="status" aria-live="polite"/);
        const f = fixture();
        await settle();
        for (let index = 0; index < 4; index++) {
            const row = f.row(index);
            assert.equal(row.value.tagName, 'CODE');
            assert.equal(row.toggle.tagName, 'BUTTON');
            assert.equal(row.copy.tagName, 'BUTTON');
            assert.equal(row.toggle.getAttribute('aria-controls'), row.value.id);
        }
    });
    const result = { passed: checks.length, checks };
    const evidenceIndex = process.argv.indexOf('--evidence');
    if (evidenceIndex !== -1) {
        const destination = process.argv[evidenceIndex + 1];
        if (!destination || !path.isAbsolute(destination)) throw new Error('--evidence requires an absolute path');
        fs.writeFileSync(destination, JSON.stringify(result, null, 2) + '\n');
    }
    process.stdout.write(JSON.stringify(result) + '\n');
}

main().catch(error => { process.stderr.write(`${error.stack}\n`); process.exitCode = 1; });
