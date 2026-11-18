class RagState {
    constructor() {
        this.definitions = [['e5', 'multilingual-e5-small'], ['tinybert', 'ms-marco-TinyBERT-L-2-v2'], ['nli', 'nli-deberta-v3-xsmall'], ['gliner', 'gliner_small-v2.1']];
        this.models = new Map(this.definitions.map(([id, name]) => [id, { id, name, connected: false, ready: false, active_count: 0, loaded: false, last_error: '', pendingBusy: false, greenUntil: 0, showingGreen: false }]));
        this.instance = null;
        this.cursor = 0;
        this.synced = false;
        this.reachable = false;
        this.preflight = { enabled: true, terminal_allowed: false, reason: 'Checking RAG readiness' };
        this.selftest = null;
        this.components = null;
    }
    resetModels() {
        for (const model of this.models.values()) Object.assign(model, { connected: false, ready: false, active_count: 0, loaded: false, pendingBusy: false, greenUntil: 0, showingGreen: false });
    }
    updateModel(value) {
        const model = this.models.get(value.id);
        if (!model) return;
        for (const key of ['name', 'connected', 'ready', 'loaded', 'last_error']) if (value[key] !== undefined) model[key] = value[key];
        if (Number.isInteger(value.active_count) && value.active_count >= 0) model.active_count = value.active_count;
        if (!model.connected) Object.assign(model, { active_count: 0, pendingBusy: false, greenUntil: 0, showingGreen: false });
        else if (model.active_count > 0) model.pendingBusy = true;
    }
    snapshot(value, reset = false, preflight = value?.preflight) {
        if (value?.error && !Array.isArray(value.models)) value = { ...value, models: [] };
        if (!value || !Array.isArray(value.models)) throw new Error('Invalid RAG status');
        if (reset) this.resetModels();
        const present = new Set(value.models.map(model => model.id));
        for (const id of this.models.keys()) if (!present.has(id)) this.updateModel({ id, connected: false, ready: false });
        for (const model of value.models) this.updateModel(model);
        this.instance = value.instance_id || null;
        this.reachable = true;
        this.synced = Boolean(this.instance);
        this.selftest = value.selftest || null;
        this.components = value.components || null;
        this.preflight = { enabled: preflight?.enabled !== false, terminal_allowed: preflight?.terminal_allowed === true, reason: preflight?.reason || (preflight?.terminal_allowed ? 'Terminal allowed' : 'Waiting for RAG readiness') };
    }
    status(value) {
        this.snapshot(value, true);
        this.cursor = Number.isSafeInteger(value.event_cursor) ? value.event_cursor : 0;
    }
    events(value) {
        const snapshot = value?.snapshot;
        const discontinuity = !this.synced || snapshot?.instance_id !== this.instance || value.truncated || (Number.isSafeInteger(value.oldest_seq) && value.oldest_seq > this.cursor + 1);
        if (!discontinuity) {
            const events = [...(value.events || [])].sort((a, b) => a.seq - b.seq);
            for (const event of events) {
                if (!Number.isSafeInteger(event.seq) || event.seq <= this.cursor) continue;
                const model = this.models.get(event.model_id);
                if (model && Number.isInteger(event.active_count) && event.active_count >= 0) {
                    model.active_count = event.active_count;
                    if (event.active_count > 0) model.pendingBusy = true;
                }
                this.cursor = event.seq;
            }
        }
        this.snapshot(snapshot, discontinuity, value.preflight || snapshot?.preflight);
        this.cursor = Number.isSafeInteger(value.cursor) ? value.cursor : Number.isSafeInteger(snapshot?.event_cursor) ? snapshot.event_cursor : this.cursor;
    }
    disconnect(reason) {
        this.resetModels();
        this.synced = false;
        this.reachable = false;
        this.preflight = { enabled: true, terminal_allowed: false, reason: reason || 'RAG service unreachable' };
    }
    view(now) {
        return [...this.models.values()].map(model => {
            if (model.connected && model.pendingBusy) {
                if (!model.showingGreen) model.greenUntil = now + 500;
                model.pendingBusy = false;
            }
            const lamp = !model.connected ? 'red' : model.active_count > 0 || now < model.greenUntil ? 'green' : model.ready ? 'yellow' : '';
            model.showingGreen = lamp === 'green';
            return { ...model, lamp };
        });
    }
}

function mountRagPanel() {
    const state = new RagState();
    const rows = new Map();
    const list = document.getElementById('rag-models');
    const selftest = document.getElementById('rag-selftest');
    const feedback = document.getElementById('rag-feedback');
    const labels = { e5: 'E5', tinybert: 'TinyBERT', nli: 'NLI', gliner: 'GLiNER' };
    let pollTimer;
    let expiryTimer;
    let frame;
    let request;
    let stopped = false;
    let generation = 0;
    let lastGate = '';
    const pending = new Set();
    const samples = {
        e5: { texts: ['Paris is the capital of France.'], kind: 'passage' },
        tinybert: { query: 'What is the capital of France?', docs: ['Paris is the capital of France.', 'Bananas are fruit.'] },
        nli: { pairs: [{ premise: 'A dog is running.', hypothesis: 'An animal is running.' }] },
        gliner: { text: 'Alice works at Microsoft in Paris.', labels: ['person', 'organization', 'location'], threshold: 0.5 }
    };
    for (const [id, name] of state.definitions) {
        const row = document.createElement('li');
        row.className = 'rag-model';
        row.dataset.model = id;
        const title = document.createElement('strong');
        title.textContent = labels[id];
        title.title = name;
        title.setAttribute('aria-label', `${labels[id]} · ${name}`);
        const lamps = document.createElement('span');
        lamps.className = 'rag-lamps';
        lamps.setAttribute('aria-hidden', 'true');
        for (const color of ['red', 'yellow', 'green']) {
            const lamp = document.createElement('span');
            lamp.className = `rag-lamp ${color}`;
            lamp.dataset.color = color;
            lamps.append(lamp);
        }
        const detail = document.createElement('span');
        detail.className = 'rag-model-state';
        const button = document.createElement('button');
        button.type = 'button';
        button.textContent = 'Test';
        button.setAttribute('aria-label', `Test ${name}`);
        button.addEventListener('click', () => run(`/control/rag/models/${id}/run`, id));
        row.append(title, lamps, detail, button);
        list.append(row);
        rows.set(id, { row, title, lamps, detail, button });
    }
    function gate() {
        const value = JSON.stringify(state.preflight);
        if (value !== lastGate) {
            lastGate = value;
            window.ragPreflight = { ...state.preflight };
            window.dispatchEvent(new CustomEvent('rag-preflight', { detail: window.ragPreflight }));
        }
    }
    function scheduleRender() {
        if (frame === undefined && !stopped) frame = requestAnimationFrame(render);
    }
    function render() {
        frame = undefined;
        clearTimeout(expiryTimer);
        const now = performance.now();
        let expiry = Infinity;
        const models = state.view(now);
        for (const model of models) {
            const node = rows.get(model.id);
            node.title.title = model.name;
            node.title.setAttribute('aria-label', `${labels[model.id]} · ${model.name}`);
            node.button.setAttribute('aria-label', `Test ${model.name}`);
            node.row.dataset.lamp = model.lamp;
            const label = model.lamp === 'red' ? 'Disconnected' : model.active_count > 0 ? `Working · ${model.active_count} active` : model.lamp === 'green' ? 'Work completed' : model.ready ? 'Ready' : 'Preparing';
            node.detail.textContent = `${label} · ${model.loaded ? 'loaded' : 'not loaded'}${model.last_error ? ` · ${model.last_error}` : ''}`;
            node.button.disabled = !model.connected || pending.has(model.id);
            if (model.greenUntil > now && model.active_count === 0) expiry = Math.min(expiry, model.greenUntil);
        }
        const preflight = document.getElementById('rag-preflight');
        preflight.textContent = `${state.preflight.enabled ? 'Preflight' : 'Preflight disabled by owner'} · ${state.preflight.terminal_allowed ? 'terminal allowed' : 'terminal input paused'} · ${state.preflight.reason}`;
        preflight.dataset.allowed = String(state.preflight.terminal_allowed);
        const test = state.selftest;
        document.getElementById('rag-test-state').textContent = test ? `Self-test: ${test.running ? 'running' : test.passed === true ? 'passed' : test.finished_at ? 'failed' : 'not completed'}${test.last_error ? ` · ${test.last_error}` : ''}` : 'Self-test not yet confirmed';
        selftest.disabled = !state.reachable || pending.has('selftest');
        window.dispatchEvent(new CustomEvent('teec:rag-state', { detail: { reachable: state.reachable, readyCount: models.filter(model => model.connected && model.ready).length, models, preflight: { ...state.preflight } } }));
        if (expiry < Infinity) expiryTimer = setTimeout(scheduleRender, Math.max(1, expiry - now));
    }
    async function json(path, options = {}) {
        const response = await fetch(path, { cache: 'no-store', ...options });
        const value = await response.json();
        if (!response.ok || value.upstream_status >= 400) throw new Error(typeof value.error === 'string' ? value.error : value.message || `HTTP ${value.upstream_status || response.status}`);
        return value;
    }
    async function run(path, id) {
        if (pending.has(id)) return;
        pending.add(id);
        feedback.textContent = `${id === 'selftest' ? 'Self-test' : labels[id]} requested`;
        scheduleRender();
        try {
            const result = await json(path, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(samples[id] || {}) });
            feedback.textContent = result.error || result.message || (id === 'selftest' ? 'Self-test started; waiting for results' : `${labels[id]} completed`);
        } catch (error) { feedback.textContent = error.message; }
        finally { pending.delete(id); scheduleRender(); }
    }
    async function poll() {
        clearTimeout(pollTimer);
        if (stopped || document.hidden || request) return;
        const current = generation;
        const controller = new AbortController();
        request = controller;
        const timeout = setTimeout(() => controller.abort(), 2500);
        try {
            const synced = state.synced;
            const result = await json(synced ? `/control/rag/events?after=${state.cursor}` : '/control/rag/status', { signal: controller.signal });
            if (current !== generation || stopped) return;
            if (synced) state.events(result);
            else state.status(result);
        } catch (error) {
            if (current === generation && !stopped) state.disconnect(error.name === 'AbortError' ? 'RAG status timed out' : error.message);
        } finally {
            clearTimeout(timeout);
            if (request === controller) request = undefined;
            if (!stopped) {
                gate();
                scheduleRender();
                pollTimer = setTimeout(poll, current === generation ? 250 : 0);
            }
        }
    }
    selftest.addEventListener('click', () => run('/control/rag/selftest', 'selftest'));
    document.addEventListener('visibilitychange', () => {
        generation++;
        state.disconnect('Checking current RAG status');
        request?.abort();
        gate();
        scheduleRender();
        if (!document.hidden) poll();
    });
    window.addEventListener('beforeunload', () => {
        stopped = true;
        clearTimeout(pollTimer);
        clearTimeout(expiryTimer);
        if (frame !== undefined) cancelAnimationFrame(frame);
        request?.abort();
    });
    gate();
    scheduleRender();
    poll();
}

if (typeof module !== 'undefined' && module.exports) module.exports = { RagState };
if (typeof document !== 'undefined') mountRagPanel();
