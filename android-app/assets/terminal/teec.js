(() => {
    'use strict';
    const modules = ['epistemic', 'evidence', 'capsule'];
    const preferences = { epistemic: false, evidence: false, capsule: false };
    try {
        const stored = JSON.parse(localStorage.getItem('teec.module-preferences') || '{}');
        for (const name of modules) if (typeof stored?.[name] === 'boolean') preferences[name] = stored[name];
    } catch {}
    function renderModule(name) {
        const input = document.getElementById(name);
        input.checked = preferences[name];
        input.closest('.module-row').dataset.enabled = String(preferences[name]);
        document.getElementById(`${name}-state`).textContent = preferences[name] ? 'ON' : 'OFF';
        if (name === 'evidence') document.getElementById('evidence-mode').textContent = preferences.evidence ? 'Complete saving' : 'Temporary log';
    }
    for (const name of modules) {
        renderModule(name);
        document.getElementById(name).addEventListener('change', event => {
            preferences[name] = event.target.checked;
            renderModule(name);
            try { localStorage.setItem('teec.module-preferences', JSON.stringify(preferences)); }
            catch { document.getElementById('module-announcement').textContent = 'Module preferences could not be saved in this browser.'; return; }
            document.getElementById('module-announcement').textContent = `${name}: ${preferences[name] ? 'ON' : 'OFF'}. Backend unbound.`;
        });
    }
    const pane = document.getElementById('eec-pane');
    const toggle = document.getElementById('toggle-pane');
    toggle.addEventListener('click', () => {
        pane.hidden = !pane.hidden;
        document.body.classList.toggle('pane-hidden', pane.hidden);
        toggle.setAttribute('aria-expanded', String(!pane.hidden));
        window.dispatchEvent(new CustomEvent('teec:view-changed', { detail: { view: 'terminal' } }));
    });
    let timer;
    let request;
    let stopped = false;
    let generation = 0;
    let lastGate = '';
    function publish(preflight) {
        const next = { enabled: preflight?.enabled !== false, terminal_allowed: preflight?.terminal_allowed === true, reason: preflight?.reason || 'Waiting for terminal readiness' };
        const key = JSON.stringify(next);
        if (lastGate === key) return;
        lastGate = key;
        window.ragPreflight = next;
        window.dispatchEvent(new CustomEvent('rag-preflight', { detail: next }));
    }
    async function poll() {
        clearTimeout(timer);
        if (stopped || document.hidden || request) return;
        const current = generation;
        const controller = new AbortController();
        request = controller;
        const timeout = setTimeout(() => controller.abort(), 2500);
        try {
            const response = await fetch('/control/rag/status', { cache: 'no-store', signal: controller.signal });
            const value = await response.json();
            if (!response.ok || value.upstream_status >= 400) throw new Error(value.error || `HTTP ${value.upstream_status || response.status}`);
            if (current === generation && !stopped) publish(value.preflight);
        } catch (error) {
            if (current === generation && !stopped) publish({ enabled: true, terminal_allowed: false, reason: error.name === 'AbortError' ? 'Readiness check timed out' : error.message });
        } finally {
            clearTimeout(timeout);
            if (request === controller) request = undefined;
            if (!stopped) timer = setTimeout(poll, current === generation ? 2000 : 0);
        }
    }
    document.addEventListener('visibilitychange', () => {
        generation++;
        request?.abort();
        publish({ enabled: true, terminal_allowed: false, reason: 'Checking terminal readiness' });
        if (!document.hidden) poll();
    });
    window.addEventListener('beforeunload', () => { stopped = true; clearTimeout(timer); request?.abort(); });
    publish({ enabled: true, terminal_allowed: false, reason: 'Checking terminal readiness' });
    poll();
})();
