const terminal = new Terminal({
    cursorBlink: true,
    fontSize: 13,
    fontFamily: 'ui-monospace, "DejaVu Sans Mono", Consolas, monospace',
    scrollback: 5000,
    screenReaderMode: true,
    theme: { background: '#0c0f12', foreground: '#c9d1d9', cursor: '#b8c8d2', selectionBackground: '#3b505a88' }
});
const fit = new FitAddon.FitAddon();
terminal.loadAddon(fit);
const terminalViewport = document.getElementById('terminal');
terminal.open(terminalViewport);
const status = document.getElementById('status');
const sessionLabel = document.getElementById('session');
const encoder = new TextEncoder();
const keyValues = { interrupt: '\x03', tab: '\t', escape: '\x1b', up: '\x1b[A', down: '\x1b[B' };
let socket;
let cursor = 0;
let session = new URL(location.href).searchParams.get('session') || '';
let creating = false;
const sessions = document.getElementById('sessions');
let ready = false;
let retry;
let closing = false;
let geometry = '';
let connectionStatus = { text: 'Connecting…', state: 'connecting' };
let sessionError;
let missingSession = false;
let recoveryAttempt = 0;
let listingRequest = 0;
let listingController;
const sessionRequests = new Set();
let terminalAllowed = false;
let preflightReason = 'Checking RAG readiness';

function applyPreflight(value) {
    const previous = terminalAllowed;
    terminalAllowed = value?.terminal_allowed === true;
    preflightReason = value?.reason || 'Waiting for RAG readiness';
    if (!terminalAllowed) {
        clearTimeout(retry);
        recoveryAttempt++;
    }
    renderStatus();
    if (terminalAllowed && !previous && !closing && socket?.readyState !== WebSocket.OPEN && socket?.readyState !== WebSocket.CONNECTING) {
        if (session) connect();
        else createSession(false);
    }
}

function setStatus(text, state) {
    connectionStatus = { text, state };
    renderStatus();
}

function renderStatus() {
    status.textContent = !terminalAllowed ? `Terminal input paused · ${preflightReason}` : sessionError ? sessionError.message : connectionStatus.text;
    status.dataset.state = !terminalAllowed || sessionError ? 'error' : connectionStatus.state;
    document.querySelectorAll('[data-key]').forEach(button => { button.disabled = !ready || !terminalAllowed; });
    terminal.options.disableStdin = !ready || !terminalAllowed;
    document.querySelector('.terminal-area').dataset.gated = String(!terminalAllowed);
    document.getElementById('keyboard').disabled = !ready || !terminalAllowed;
    document.getElementById('reconnect').disabled = !terminalAllowed;
    document.getElementById('new-terminal').disabled = !terminalAllowed || creating;
    sessions.disabled = !terminalAllowed;
    document.getElementById('close-terminal').disabled = !session || missingSession;
}

function clearSessionError(action) {
    if (sessionError?.action === action) sessionError = undefined;
    renderStatus();
}

function showSessionError(action, error) {
    sessionError = { action, message: error.message };
    renderStatus();
}

function resize() {
    const height = window.visualViewport ? window.visualViewport.height : window.innerHeight;
    document.documentElement.style.setProperty('--viewport-height', `${height}px`);
    const bounds = terminalViewport.getBoundingClientRect();
    if (bounds.width <= 0 || bounds.height <= 0) return;
    fit.fit();
    const size = `resize:${terminal.rows}:${terminal.cols}`;
    if (ready && socket?.readyState === WebSocket.OPEN && size !== geometry) {
        socket.send(size);
        geometry = size;
    }
}

function send(bytes) {
    if (!terminalAllowed || !ready || socket?.readyState !== WebSocket.OPEN) return;
    for (let offset = 0; offset < bytes.length; offset += 16384) socket.send(bytes.subarray(offset, offset + 16384));
}

function connect() {
    clearTimeout(retry);
    if (!terminalAllowed || closing) { renderStatus(); return; }
    recoveryAttempt++;
    ready = false;
    geometry = '';
    missingSession = false;
    sessionError = undefined;
    setStatus('Connecting…', 'connecting');
    const previous = socket;
    const protocol = location.protocol === 'https:' ? 'wss:' : 'ws:';
    const next = new WebSocket(`${protocol}//${location.host}/ws?session=${encodeURIComponent(session)}&cursor=${cursor}`);
    socket = next;
    previous?.close();
    next.binaryType = 'arraybuffer';
    next.onmessage = event => {
        if (socket !== next) return;
        if (typeof event.data === 'string') {
            const message = JSON.parse(event.data);
            if (message.type === 'reset') {
                session = message.session;
                cursor = 0;
                terminal.reset();
            } else if (message.type === 'state') {
                session = message.session;
                sessionLabel.textContent = session ? `Session ${session.slice(0, 8)} · PID ${message.pid}` : '';
                document.getElementById('open-terminal').href = `/terminal?session=${encodeURIComponent(session)}`;
                ready = message.running;
                if (message.preflight) applyPreflight(message.preflight);
                setStatus(message.error ? message.error : ready ? 'Connected · Ubuntu Bash' : session ? `Closed · exit ${message.exit}` : 'Starting Ubuntu…', message.error ? 'error' : ready ? 'connected' : 'closed');
                resize();
                refreshSessions();
            } else if (message.type === 'truncated') {
                terminal.write('\r\n[Older output is no longer in the session buffer]\r\n');
            }
            return;
        }
        const bytes = new Uint8Array(event.data);
        if (bytes.length < 8) return;
        const view = new DataView(event.data);
        const position = view.getUint32(0) * 4294967296 + view.getUint32(4);
        terminal.write(bytes.subarray(8), () => {
            if (socket !== next) return;
            cursor = position;
            if (next.readyState === WebSocket.OPEN) next.send(`ack:${cursor}`);
        });
    };
    next.onclose = () => {
        if (socket !== next || closing) return;
        ready = false;
        setStatus('Disconnected · reconnecting…', 'error');
        if (terminalAllowed) retry = setTimeout(recoverConnection, 1000);
    };
    next.onerror = () => {
        if (socket !== next || closing) return;
        ready = false;
        setStatus('Server unreachable · reconnecting…', 'error');
    };
}

async function recoverConnection() {
    clearTimeout(retry);
    if (closing || !terminalAllowed) return;
    const attempt = ++recoveryAttempt;
    const previous = socket;
    const requested = session;
    const listing = await refreshSessions();
    if (closing || !terminalAllowed || attempt !== recoveryAttempt || socket !== previous || session !== requested) return;
    if (!listing) {
        if (socket?.readyState !== WebSocket.OPEN) retry = setTimeout(recoverConnection, 1000);
        return;
    }
    if (!listing.some(item => item.session === requested)) {
        ready = false;
        missingSession = true;
        socket = undefined;
        previous?.close();
        setStatus(listing.length ? 'Session no longer exists · select a terminal or create one' : 'Session no longer exists · create a terminal', 'closed');
        return;
    }
    connect();
}

async function requestSessionJson(path, options, message, controller = new AbortController()) {
    sessionRequests.add(controller);
    try {
        const response = await fetch(path, { cache: 'no-store', ...options, signal: controller.signal });
        if (!response.ok) {
            let detail = '';
            try {
                detail = (await response.text()).trim();
                try {
                    const result = JSON.parse(detail);
                    detail = typeof result.error === 'string' ? result.error : typeof result.message === 'string' ? result.message : detail;
                } catch {}
            } catch {}
            throw new Error(`HTTP ${response.status}${detail ? `: ${detail}` : ''}`);
        }
        return await response.json();
    } catch (error) {
        throw new Error(`${message} · ${error.message}`);
    } finally { sessionRequests.delete(controller); }
}

terminal.onData(data => send(encoder.encode(data)));
terminal.onBinary(data => send(Uint8Array.from(data, character => character.charCodeAt(0) & 255)));
document.querySelectorAll('[data-key]').forEach(button => {
    button.addEventListener('click', () => { send(encoder.encode(keyValues[button.dataset.key])); terminal.focus(); });
});
document.getElementById('keyboard').addEventListener('click', () => terminal.focus());
document.getElementById('reconnect').addEventListener('click', recoverConnection);
async function refreshSessions() {
    const request = ++listingRequest;
    listingController?.abort();
    const controller = new AbortController();
    listingController = controller;
    try {
        const result = await requestSessionJson('/sessions', {}, 'Could not load sessions', controller);
        if (closing || request !== listingRequest) return null;
        const options = result.sessions.map((item, index) => {
            const option = document.createElement('option');
            option.value = item.session;
            option.textContent = `${index + 1} · ${item.session.slice(0, 8)} · ${item.running ? `PID ${item.pid}` : `exit ${item.exit}`}`;
            option.selected = item.session === session;
            return option;
        });
        if (!result.sessions.some(item => item.session === session)) {
            const placeholder = document.createElement('option');
            placeholder.value = '';
            placeholder.textContent = result.sessions.length ? 'Select a terminal' : 'No terminals available';
            placeholder.selected = true;
            placeholder.disabled = true;
            options.unshift(placeholder);
        }
        sessions.replaceChildren(...options);
        clearSessionError('list');
        return result.sessions;
    } catch (error) {
        if (!closing && request === listingRequest) showSessionError('list', error);
        return null;
    } finally { if (listingController === controller) listingController = undefined; }
}
async function createSession(navigate) {
    if (creating || closing || !terminalAllowed) return;
    creating = true;
    const button = document.getElementById('new-terminal');
    button.disabled = true;
    try {
        const result = await requestSessionJson('/sessions', { method: 'POST' }, 'Could not create terminal');
        if (closing) return;
        clearSessionError('create');
        const url = `/terminal?session=${encodeURIComponent(result.session)}`;
        if (navigate) { location.assign(url); return; }
        if (session !== result.session) { cursor = 0; terminal.reset(); }
        session = result.session;
        history.replaceState(null, '', url);
        connect();
    } catch (error) { if (!closing) showSessionError('create', error); }
    finally { creating = false; renderStatus(); }
}
sessions.addEventListener('change', () => { if (terminalAllowed && sessions.value) location.assign(`/terminal?session=${encodeURIComponent(sessions.value)}`); });
document.getElementById('new-terminal').addEventListener('click', () => createSession(true));
document.getElementById('close-terminal').addEventListener('click', async () => {
    if (!session || missingSession) return;
    try {
        await requestSessionJson(`/sessions/${encodeURIComponent(session)}/close`, { method: 'POST' }, 'Could not close terminal');
        if (closing) return;
        clearSessionError('close');
        await refreshSessions();
    } catch (error) { if (!closing) showSessionError('close', error); }
});
window.addEventListener('focus', refreshSessions);
window.addEventListener('rag-preflight', event => applyPreflight(event.detail));
new ResizeObserver(resize).observe(terminalViewport);
window.addEventListener('resize', resize);
window.addEventListener('teec:view-changed', resize);
window.visualViewport?.addEventListener('resize', resize);
window.addEventListener('beforeunload', () => {
    closing = true;
    clearTimeout(retry);
    for (const controller of sessionRequests) controller.abort();
    socket?.close();
});
resize();
applyPreflight(window.ragPreflight);
terminal.focus();
