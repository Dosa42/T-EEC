const controlNodes = new Map();
let readingControl = false;
let selectedEngineId = '';
let observedEngineOrders = [];
let readingProxyProfiles = false;
const proxyProfileNodes = new Map();

function updateProxyKey(node) {
    const open = node.revealed || node.loading;
    node.value.textContent = node.revealed ? node.key : '••••••••••••••••';
    node.value.dataset.revealed = String(node.revealed);
    if (node.revealed) node.value.removeAttribute('aria-label');
    else node.value.setAttribute('aria-label', 'API-sleutel verborgen');
    node.toggle.textContent = open ? 'Verberg' : 'Toon';
    node.toggle.setAttribute('aria-label', `${open ? 'Verberg' : 'Toon'} API-sleutel voor ${node.name}`);
    node.toggle.setAttribute('aria-expanded', String(node.revealed));
    node.copy.disabled = !node.revealed || node.copying;
}

function hideProxyKey(node) {
    node.request++;
    node.loading = false;
    node.revealed = false;
    node.key = '';
    node.feedback.textContent = '';
    node.feedback.dataset.state = '';
    updateProxyKey(node);
}

async function toggleProxyKey(node) {
    if (node.revealed || node.loading) {
        hideProxyKey(node);
        return;
    }
    const request = ++node.request;
    node.loading = true;
    node.feedback.textContent = 'Sleutel laden…';
    node.feedback.dataset.state = '';
    updateProxyKey(node);
    try {
        const response = await fetch(`/control/cliproxy/profiles/${encodeURIComponent(node.name)}`, { cache: 'no-store' });
        if (!response.ok) throw new Error('key unavailable');
        const result = await response.json();
        if (typeof result.api_key !== 'string' || !result.api_key || result.name !== node.name) throw new Error('invalid key response');
        if (node.request !== request) return;
        node.key = result.api_key;
        node.revealed = true;
        node.feedback.textContent = 'Sleutel zichtbaar.';
    } catch {
        if (node.request !== request) return;
        node.feedback.textContent = 'Sleutel laden mislukt. Kies Toon om opnieuw te proberen.';
        node.feedback.dataset.state = 'error';
    } finally {
        if (node.request === request) {
            node.loading = false;
            updateProxyKey(node);
        }
    }
}

function copyProxySelection(node) {
    const selection = window.getSelection();
    if (!selection) return false;
    const previous = Array.from({ length: selection.rangeCount }, (_, index) => selection.getRangeAt(index).cloneRange());
    const focused = document.activeElement;
    try {
        const range = document.createRange();
        range.selectNodeContents(node.value);
        selection.removeAllRanges();
        selection.addRange(range);
        return document.execCommand('copy');
    } finally {
        selection.removeAllRanges();
        for (const range of previous) selection.addRange(range);
        if (focused && typeof focused.focus === 'function') focused.focus({ preventScroll: true });
    }
}

async function copyProxyKey(node) {
    if (!node.revealed || node.copying) return;
    const request = node.request;
    node.copying = true;
    updateProxyKey(node);
    try {
        let copied = false;
        if (navigator.clipboard?.writeText) {
            try {
                await navigator.clipboard.writeText(node.key);
                copied = true;
            } catch {}
        }
        if (node.request !== request || !node.revealed) return;
        if (!copied) copied = copyProxySelection(node);
        node.feedback.textContent = copied ? 'Gekopieerd.' : 'Kopiëren mislukt. Selecteer de zichtbare sleutel en kopieer handmatig.';
        node.feedback.dataset.state = copied ? 'ok' : 'error';
    } catch {
        if (node.request === request && node.revealed) {
            node.feedback.textContent = 'Kopiëren mislukt. Selecteer de zichtbare sleutel en kopieer handmatig.';
            node.feedback.dataset.state = 'error';
        }
    } finally {
        node.copying = false;
        updateProxyKey(node);
    }
}

function createProxyProfile(profile, index) {
    const row = document.createElement('li');
    row.className = 'proxy-profile';
    const name = document.createElement('h5');
    name.id = `proxy-profile-name-${index}`;
    name.textContent = profile.name;
    const endpoint = document.createElement('p');
    endpoint.className = 'proxy-profile-endpoint';
    endpoint.textContent = [profile.endpoint, profile.header].filter(value => typeof value === 'string' && value).join(' · ');
    const value = document.createElement('code');
    value.className = 'proxy-key-value';
    value.id = `proxy-key-value-${index}`;
    const actions = document.createElement('div');
    actions.className = 'proxy-key-actions';
    const toggle = document.createElement('button');
    toggle.type = 'button';
    toggle.disabled = !profile.has_key;
    toggle.setAttribute('aria-controls', value.id);
    const copy = document.createElement('button');
    copy.type = 'button';
    copy.textContent = 'Kopieer';
    copy.setAttribute('aria-label', `Kopieer API-sleutel voor ${profile.name}`);
    const feedback = document.createElement('p');
    feedback.className = 'proxy-key-feedback';
    feedback.setAttribute('role', 'status');
    feedback.setAttribute('aria-live', 'polite');
    const node = { name: profile.name, row, value, toggle, copy, feedback, key: '', revealed: false, loading: false, copying: false, request: 0 };
    toggle.addEventListener('click', () => toggleProxyKey(node));
    copy.addEventListener('click', () => copyProxyKey(node));
    actions.append(toggle, copy);
    row.setAttribute('aria-labelledby', name.id);
    row.append(name, endpoint, value, actions, feedback);
    updateProxyKey(node);
    if (!profile.has_key) feedback.textContent = 'Geen sleutel ingesteld.';
    return node;
}

async function loadProxyProfiles() {
    if (readingProxyProfiles) return;
    readingProxyProfiles = true;
    const list = document.getElementById('proxy-profiles');
    const retry = document.getElementById('proxy-profiles-retry');
    const status = document.getElementById('proxy-profiles-status');
    for (const node of proxyProfileNodes.values()) hideProxyKey(node);
    proxyProfileNodes.clear();
    list.replaceChildren();
    list.setAttribute('aria-busy', 'true');
    retry.disabled = true;
    status.dataset.state = '';
    controlText('proxy-profiles-status', 'Profielen laden…');
    controlText('proxy-profile-count', 'Profielen laden…');
    controlText('proxy-base-url', '—');
    controlText('proxy-provider', '—');
    try {
        const response = await fetch('/control/cliproxy/profiles', { cache: 'no-store' });
        if (!response.ok) throw new Error('profiles unavailable');
        const result = await response.json();
        if (!Array.isArray(result.profiles)) throw new Error('invalid profiles response');
        const names = new Set();
        for (const profile of result.profiles) {
            if (typeof profile.name !== 'string' || !profile.name || names.has(profile.name)) throw new Error('invalid profile');
            names.add(profile.name);
        }
        controlText('proxy-base-url', typeof result.base_url === 'string' && result.base_url ? result.base_url : 'Niet ingesteld');
        controlText('proxy-provider', typeof result.upstream_provider === 'string' && result.upstream_provider ? result.upstream_provider : 'Niet ingesteld');
        for (const [index, profile] of result.profiles.entries()) {
            const node = createProxyProfile(profile, index);
            proxyProfileNodes.set(profile.name, node);
            list.append(node.row);
        }
        controlText('proxy-profile-count', `${result.profiles.length} ${result.profiles.length === 1 ? 'profiel' : 'profielen'}`);
        status.textContent = result.profiles.length ? '' : 'Nog geen API-profielen ingesteld.';
        retry.textContent = 'Vernieuwen';
    } catch {
        controlText('proxy-profile-count', 'Profielen niet beschikbaar');
        status.textContent = 'Profielen laden mislukt. Probeer opnieuw.';
        status.dataset.state = 'error';
        retry.textContent = 'Opnieuw proberen';
    } finally {
        readingProxyProfiles = false;
        retry.disabled = false;
        list.setAttribute('aria-busy', 'false');
    }
}

function showEngineOutput() {
    const order = observedEngineOrders.find(item => item.id === selectedEngineId) || observedEngineOrders.at(-1);
    const output = order ? `$ ${order.argv.map(arg => JSON.stringify(arg)).join(' ')}\ncwd=${order.cwd}\n\n${order.stdout}${order.stderr ? `\n[stderr]\n${order.stderr}` : ''}${order.error ? `\n[error]\n${order.error}` : ''}` : 'Nog geen machine-opdrachten ontvangen.';
    const log = document.getElementById('engine-output');
    const atBottom = log.scrollHeight - log.scrollTop - log.clientHeight < 24;
    controlText('engine-output-label', order ? `stdout / stderr · ${order.id}` : 'stdout / stderr');
    controlText('engine-output', output);
    if (atBottom) log.scrollTop = log.scrollHeight;
    for (const [id, node] of controlNodes) node.title.setAttribute('aria-pressed', String(order?.id === id));
}
function controlText(id, value) {
    const element = document.getElementById(id);
    if (element.textContent !== value) element.textContent = value;
}
async function readControlJson(path) {
    const response = await fetch(path, { cache: 'no-store' });
    if (!response.ok) throw new Error(`${path}: ${await response.text()}`);
    return response.json();
}
async function refreshControl() {
    if (readingControl) return;
    readingControl = true;
    try {
        const [engine, health, listing] = await Promise.all([readControlJson('/control/status'), readControlJson('/health'), readControlJson('/sessions')]);
        controlText('server-url', location.origin);
        controlText('server-ssh', `0.0.0.0:${health.ssh.port} · ${health.ssh.running ? 'actief' : 'gestopt'}${health.ssh.error ? ` · ${health.ssh.error}` : ''}`);
        const connected = typeof socket !== 'undefined' && socket?.readyState === WebSocket.OPEN;
        controlText('server-ws', `${location.port || (location.protocol === 'https:' ? '443' : '80')} /ws · ${connected ? 'verbonden' : 'niet verbonden'}`);
        controlText('server-sessions', `${listing.sessions.filter(item => item.running).length} actief / ${listing.sessions.length} totaal`);
        controlText('server-health', 'HTTP bereikbaar');
        document.getElementById('server-health').dataset.state = 'ok';
        controlText('control-freshness', new Date().toLocaleTimeString('nl-NL'));
        for (const key of ['mode', 'model', 'reasoning', 'skills', 'hooks', 'instructions']) controlText(`engine-${key}`, engine.settings[key] || 'Niet ingesteld');
        const active = engine.orders.filter(order => ['queued', 'running'].includes(order.status));
        controlText('engine-state', active.length ? `${active.length} actief` : 'wacht');
        const latest = engine.orders.at(-1);
        controlText('controller-receipt', latest ? `${latest.source}\n${latest.id}\n${new Date(Number(latest.created)).toLocaleString('nl-NL')}` : 'Nog geen opdracht ontvangen.');
        observedEngineOrders = engine.orders;
        const list = document.getElementById('engine-orders');
        if (engine.orders.length) list.querySelector('.empty-orders')?.remove();
        for (const order of engine.orders) {
            let node = controlNodes.get(order.id);
            if (!node) {
                const row = document.createElement('li');
                row.className = 'engine-order';
                const title = document.createElement('button');
                title.type = 'button';
                title.addEventListener('click', () => { selectedEngineId = order.id; showEngineOutput(); });
                const state = document.createElement('span');
                state.className = 'order-status';
                const check = document.createElement('span');
                row.append(title, state, check);
                list.append(row);
                node = { row, title, state, check };
                controlNodes.set(order.id, node);
            }
            node.row.dataset.status = order.status;
            node.title.textContent = order.id;
            node.row.title = `${order.source}\n${order.cwd}\n${order.argv.join(' ')}`;
            node.state.textContent = `${order.status}${order.exit !== '' ? ` · exit ${order.exit}` : ''}`;
            node.check.textContent = `check=${order.checklist}`;
        }
        showEngineOutput();
        controlText('control-error', '');
    } catch (error) {
        controlText('control-error', error.message);
        controlText('server-health', 'Status verversen mislukt');
        document.getElementById('server-health').dataset.state = 'error';
        controlText('control-freshness', 'Laatste gegevens');
    } finally { readingControl = false; }
}
document.getElementById('proxy-profiles-retry').addEventListener('click', loadProxyProfiles);
loadProxyProfiles();
refreshControl();
setInterval(refreshControl, 2000);
