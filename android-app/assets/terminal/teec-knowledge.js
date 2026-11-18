(() => {
    const number = value => typeof value === 'number' && Number.isFinite(value) && value >= 0 ? value : null;
    const count = value => number(value) === null ? '—' : new Intl.NumberFormat('en').format(value);
    const time = value => typeof value === 'number' && value > 0 ? new Date(value * 1000).toLocaleString('en', { dateStyle: 'medium', timeStyle: 'short' }) : '—';
    const states = { queued: 'Queued', running: 'Running', completed: 'Completed', failed: 'Failed', interrupted: 'Interrupted' };
    const element = (tag, className, text) => {
        const node = document.createElement(tag);
        if (className) node.className = className;
        if (text !== undefined) node.textContent = text;
        return node;
    };

    async function request(url, options = {}) {
        const response = await fetch(url, { cache: 'no-store', ...options });
        const raw = await response.text();
        let value;
        try { value = JSON.parse(raw); }
        catch { throw new Error(response.ok ? 'The service returned an invalid response.' : `HTTP ${response.status}: ${raw.slice(0, 300)}`); }
        const status = Number(value?.upstream_status) || response.status;
        if (!response.ok || status >= 400 || value?.error) throw new Error(value?.error || value?.message || `HTTP ${status}`);
        return value;
    }

    function mount() {
        const ids = ['department-list', 'knowledge-status', 'knowledge-summary', 'department-detail', 'knowledge-refresh', 'knowledge-filter', 'add-source', 'source-dialog', 'source-form', 'source-side', 'source-path', 'source-recursive', 'source-departments', 'source-preview', 'source-ingest', 'source-result', 'source-close'];
        const nodes = Object.fromEntries(ids.map(id => [id, document.getElementById(id)]));
        if (ids.some(id => !nodes[id])) return;
        const state = { config: null, status: null, selected: 'microskills', targets: new Set(['microskills']), jobs: new Map(), job: null, reachable: false, configError: '', statusError: '', jobError: '', submittedError: '', refreshedAt: null, submitting: false };
        let pending = null;
        let timer;
        let stopped = false;
        let knowledgeVisible = document.getElementById('view-knowledge')?.hidden === false;
        let targetSignature = '';
        let dialogOpened = false;
        let returnFocus = null;

        function departments() {
            const metrics = new Map((state.status?.departments || []).map(row => [row.id, row]));
            return (state.config?.departments || state.status?.departments || []).map(row => ({ ...row, ...metrics.get(row.id), name: row.name })).sort((a, b) => Number(b.id === 'microskills') - Number(a.id === 'microskills'));
        }

        function totalRecords(rows) {
            return rows.length && rows.every(row => number(row.prepared_records) !== null) ? rows.reduce((total, row) => total + row.prepared_records, 0) : null;
        }

        function activeJobs() {
            return number(state.status?.active_jobs);
        }

        function statusText(row) {
            if (row.ready === true) return 'Ready';
            if (row.ready === false) return 'Not ready';
            return 'Status unavailable';
        }

        function jobText(job) {
            const lines = [`${job.action === 'preview' ? 'Preview' : 'Ingestion'} · ${states[job.state] || job.state || 'Unknown status'}`, `Job: ${job.id}`, `Started: ${time(job.created_at)}`];
            if (job.finished_at) lines.push(`Finished: ${time(job.finished_at)}`);
            lines.push(`Files: ${count(job.progress?.files)} · Records: ${count(job.progress?.records)} · Chunks: ${count(job.progress?.chunks)} · Tokens: ${count(job.progress?.tokens)}`);
            if (job.error) lines.push(`Error: ${job.error}`);
            if (job.state === 'interrupted') lines.push('This job was interrupted. You can submit the source again.');
            const names = new Map(departments().map(row => [row.id, row.name]));
            if (Array.isArray(job.department_ids)) lines.push(`Departments: ${job.department_ids.map(id => names.get(id) || id).join(', ')}`);
            if (Array.isArray(job.sources)) for (const source of job.sources) lines.push(`Source: ${source.side} · ${source.path}${source.recursive ? ' · including subfolders' : ''}`);
            if (job.result && Object.values(job.result).some(value => Array.isArray(value) ? value.length : value)) lines.push('', JSON.stringify(job.result, null, 2));
            return lines.join('\n');
        }

        function renderJob() {
            const job = state.jobs.get(state.job);
            const errors = [state.submittedError, state.jobError].filter(Boolean);
            nodes['source-result'].textContent = [...errors, job ? jobText(job) : 'Choose a source and at least one department, then preview or ingest it.'].join('\n\n');
            nodes['source-result'].dataset.error = String(Boolean(errors.length || job?.error || ['failed', 'interrupted'].includes(job?.state)));
        }

        function renderControls() {
            nodes['source-preview'].disabled = !state.config || state.submitting;
            nodes['source-ingest'].disabled = !state.config || state.submitting;
            nodes['source-form'].setAttribute('aria-busy', String(state.submitting));
            nodes['source-preview'].textContent = state.submitting ? 'Submitting…' : 'Preview source';
            nodes['source-ingest'].textContent = state.submitting ? 'Submitting…' : 'Ingest source';
            nodes['knowledge-refresh'].disabled = Boolean(pending);
        }

        function renderTargets() {
            const rows = state.config?.departments || [];
            const signature = JSON.stringify(rows.map(({ id, name }) => [id, name]));
            if (signature === targetSignature) return;
            targetSignature = signature;
            state.targets = new Set([...state.targets].filter(id => rows.some(row => row.id === id)));
            nodes['source-departments'].replaceChildren();
            if (!rows.length) {
                nodes['source-departments'].append(element('p', 'knowledge-empty', 'Department settings are unavailable. Refresh knowledge to try again.'));
                return;
            }
            if (!dialogOpened && !state.targets.size) state.targets.add(state.selected);
            for (const row of rows) {
                const label = element('label', 'source-department');
                const input = element('input');
                input.type = 'checkbox';
                input.name = 'department_ids';
                input.value = row.id;
                input.checked = state.targets.has(row.id);
                input.addEventListener('change', () => {
                    if (input.checked) state.targets.add(row.id);
                    else state.targets.delete(row.id);
                    state.submittedError = '';
                    renderJob();
                });
                label.append(input, element('span', '', row.name));
                nodes['source-departments'].append(label);
            }
        }

        function renderList(rows) {
            const focused = document.activeElement?.closest('[data-department-id]')?.dataset.departmentId;
            const filter = nodes['knowledge-filter'].value.trim().toLocaleLowerCase('en');
            const matching = rows.filter(row => `${row.name} ${row.id}`.toLocaleLowerCase('en').includes(filter));
            const list = nodes['department-list'];
            const itemTag = ['UL', 'OL'].includes(list.tagName) ? 'li' : 'div';
            list.replaceChildren();
            for (const row of matching) {
                const item = element(itemTag, 'department-item');
                const button = element('button', 'department-button');
                button.type = 'button';
                button.dataset.departmentId = row.id;
                button.dataset.ready = row.ready === true ? 'true' : row.ready === false ? 'false' : 'unknown';
                button.setAttribute('aria-pressed', String(row.id === state.selected));
                const ready = element('span', 'department-ready', statusText(row));
                ready.dataset.ready = button.dataset.ready;
                button.append(element('span', 'department-name', row.name), element('span', 'department-records', `${count(row.prepared_records)} records`), ready);
                button.addEventListener('click', () => { state.selected = row.id; render(); });
                item.append(button);
                list.append(item);
            }
            if (!matching.length) list.append(element(itemTag, 'knowledge-empty', rows.length ? 'No departments match this search.' : 'Department data is unavailable.'));
            if (focused) [...list.querySelectorAll('[data-department-id]')].find(button => button.dataset.departmentId === focused)?.focus({ preventScroll: true });
        }

        function renderDetail(rows) {
            const host = nodes['department-detail'];
            const row = rows.find(item => item.id === state.selected);
            const focusedJob = document.activeElement?.closest('[data-knowledge-job]')?.dataset.knowledgeJob;
            host.replaceChildren();
            if (!row) {
                host.append(element('p', 'knowledge-empty', 'Refresh knowledge to load the department stores.'));
                return;
            }
            const header = element('div', 'knowledge-detail-header');
            const identity = element('div');
            identity.append(element('p', 'eyebrow', 'DEPARTMENT STORE'), element('h2', '', row.name));
            const ready = element('span', 'department-ready', statusText(row));
            ready.dataset.ready = row.ready === true ? 'true' : row.ready === false ? 'false' : 'unknown';
            header.append(identity, ready);
            const metrics = element('dl', 'knowledge-metrics');
            for (const [key, label] of [['prepared_records', 'Prepared records'], ['chunks', 'Chunks'], ['tokens', 'Tokens'], ['vector_records', 'Vector records'], ['bytes', 'Bytes']]) {
                const metric = element('div', 'knowledge-metric');
                metric.append(element('dt', '', label), element('dd', '', count(row[key])));
                metrics.append(metric);
            }
            const meta = element('dl', 'knowledge-meta');
            for (const [label, value] of [['Database', row.chroma_path || '—'], ['Last ingestion', time(row.last_ingested_at)], ['Prepared sources', count(row.prepared_sources)], ['Indexed sources', count(row.indexed_sources)], ['Pending sources', count(row.pending_sources)]]) meta.append(element('dt', '', label), element('dd', '', value));
            host.append(header, element('p', 'knowledge-store-note', 'Each of the six departments has a separate Chroma database.'), metrics, meta);
            if (row.last_error) host.append(element('p', 'knowledge-error', `Last error: ${row.last_error}`));
            const jobs = [...state.jobs.values()].filter(job => job.department_ids?.includes(row.id)).sort((a, b) => (b.created_at || 0) - (a.created_at || 0)).slice(0, 5);
            if (jobs.length) {
                const section = element('section', 'knowledge-jobs');
                section.append(element('h3', '', 'Recent activity'));
                for (const job of jobs) {
                    const button = element('button', 'knowledge-job', `${job.action === 'preview' ? 'Preview' : 'Ingestion'} · ${states[job.state] || job.state} · ${time(job.created_at)}`);
                    button.type = 'button';
                    button.dataset.knowledgeJob = job.id;
                    button.addEventListener('click', () => {
                        state.job = job.id;
                        state.submittedError = '';
                        state.jobError = '';
                        openDialog();
                        refreshJob().then(renderJob);
                    });
                    section.append(button);
                }
                host.append(section);
            }
            if (focusedJob) [...host.querySelectorAll('[data-knowledge-job]')].find(button => button.dataset.knowledgeJob === focusedJob)?.focus({ preventScroll: true });
        }

        function render() {
            const rows = departments();
            if (!rows.some(row => row.id === state.selected)) state.selected = rows.find(row => row.id === 'microskills')?.id || rows[0]?.id || 'microskills';
            const errors = [state.configError, state.statusError].filter(Boolean);
            nodes['knowledge-status'].textContent = errors.length ? errors.join(' ') : state.refreshedAt ? `Connected · updated ${state.refreshedAt.toLocaleTimeString('en', { hour: '2-digit', minute: '2-digit', second: '2-digit' })}` : 'Loading knowledge…';
            nodes['knowledge-status'].dataset.error = String(Boolean(errors.length));
            nodes['knowledge-status'].dataset.reachable = String(state.reachable);
            nodes['knowledge-summary'].textContent = `${rows.length ? count(rows.length) : '—'} departments · ${count(totalRecords(rows))} prepared records · ${count(activeJobs())} active jobs${state.statusError && state.status ? ' · last received values' : ''}`;
            renderList(rows);
            renderDetail(rows);
            renderTargets();
            renderJob();
            renderControls();
            window.dispatchEvent(new CustomEvent('teec:knowledge-state', { detail: { departments: rows.length ? rows : null, activeJobs: activeJobs(), totalRecords: totalRecords(rows), reachable: state.reachable } }));
        }

        function acceptJob(job) {
            if (!job || typeof job.id !== 'string' || !job.id || typeof job.state !== 'string') throw new Error('The service returned an invalid job.');
            state.jobs.set(job.id, job);
        }

        async function refreshJob() {
            const id = state.job;
            if (!id) return;
            try {
                const value = await request(`/control/rag/ingest/jobs?id=${encodeURIComponent(id)}`);
                if (value.job?.id !== id) throw new Error('The service returned a different job.');
                acceptJob(value.job);
                if (state.job === id) state.jobError = '';
            } catch (error) { if (state.job === id) state.jobError = `Could not refresh job status. ${error.message}`; }
        }

        function schedule() {
            clearTimeout(timer);
            if (!stopped && knowledgeVisible && !document.hidden) timer = setTimeout(() => refresh(false), 3000);
        }

        function refresh(includeConfig = true) {
            if (pending) return pending;
            clearTimeout(timer);
            const tasks = [request('/control/rag/ingest/status').then(value => {
                if (!value || !Array.isArray(value.departments) || !Array.isArray(value.jobs)) throw new Error('The service returned invalid knowledge status.');
                for (const job of value.jobs) acceptJob(job);
                state.status = value;
                state.reachable = true;
                state.statusError = '';
                state.refreshedAt = new Date();
            }).catch(error => {
                state.reachable = false;
                state.statusError = `Knowledge status is unavailable. ${error.message}`;
            }).then(render)];
            if (includeConfig || !state.config) tasks.push(request('/control/rag/ingest/config').then(value => {
                if (!value || !Array.isArray(value.departments) || value.departments.length !== 6 || new Set(value.departments.map(row => row.id)).size !== 6 || !value.departments.some(row => row.id === 'microskills') || value.departments.some(row => typeof row.id !== 'string' || typeof row.name !== 'string' || !row.name.trim())) throw new Error('The service did not return six named departments.');
                state.config = value;
                state.configError = '';
            }).catch(error => { state.configError = `Department settings are unavailable. ${error.message}`; }).then(render));
            pending = Promise.all(tasks).then(refreshJob).then(render).finally(() => {
                pending = null;
                renderControls();
                schedule();
            });
            renderControls();
            return pending;
        }

        function openDialog() {
            if (!dialogOpened) {
                state.targets = new Set([state.selected]);
                targetSignature = '';
                renderTargets();
                dialogOpened = true;
            }
            renderJob();
            returnFocus = document.activeElement;
            if (!nodes['source-dialog'].open) nodes['source-dialog'].showModal();
            nodes['source-path'].focus();
        }

        async function startJob(action) {
            if (state.submitting || !state.config) return;
            state.submittedError = '';
            state.jobError = '';
            const path = nodes['source-path'].value.trim();
            nodes['source-path'].setCustomValidity(path ? '' : 'Enter a source file or folder path.');
            if (!nodes['source-form'].reportValidity()) return;
            const department_ids = state.config.departments.filter(row => state.targets.has(row.id)).map(row => row.id);
            if (!department_ids.length) {
                state.submittedError = 'Choose at least one destination department.';
                renderJob();
                nodes['source-departments'].querySelector('input')?.focus();
                return;
            }
            const sources = [{ side: nodes['source-side'].value, path, recursive: nodes['source-recursive'].checked }];
            state.submitting = true;
            renderControls();
            nodes['source-result'].textContent = `Submitting ${action === 'preview' ? 'preview' : 'ingestion'}…`;
            nodes['source-result'].dataset.error = 'false';
            try {
                const value = await request('/control/rag/ingest/jobs', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ action, sources, department_ids }) });
                acceptJob(value.job);
                state.job = value.job.id;
                renderJob();
                await refresh(false);
            } catch (error) { state.submittedError = `Could not start ${action === 'preview' ? 'preview' : 'ingestion'}. ${error.message}`; }
            finally { state.submitting = false; render(); }
        }

        nodes['source-preview'].type = 'button';
        nodes['source-ingest'].type = 'button';
        nodes['source-close'].type = 'button';
        nodes['source-result'].setAttribute('role', 'status');
        nodes['source-result'].setAttribute('aria-live', 'polite');
        nodes['source-result'].setAttribute('aria-atomic', 'true');
        nodes['knowledge-status'].setAttribute('role', 'status');
        nodes['source-form'].addEventListener('submit', event => event.preventDefault());
        nodes['source-preview'].addEventListener('click', () => startJob('preview'));
        nodes['source-ingest'].addEventListener('click', () => startJob('ingest'));
        nodes['source-path'].addEventListener('input', () => nodes['source-path'].setCustomValidity(''));
        nodes['add-source'].addEventListener('click', openDialog);
        nodes['source-close'].addEventListener('click', () => nodes['source-dialog'].close());
        nodes['source-dialog'].addEventListener('close', () => (returnFocus?.isConnected ? returnFocus : nodes['add-source']).focus({ preventScroll: true }));
        nodes['knowledge-filter'].addEventListener('input', () => renderList(departments()));
        nodes['knowledge-refresh'].addEventListener('click', () => refresh());
        window.addEventListener('teec:view-changed', event => {
            knowledgeVisible = event.detail?.view === 'knowledge';
            if (knowledgeVisible && !document.hidden) refresh(false);
            else clearTimeout(timer);
        });
        document.addEventListener('visibilitychange', () => {
            if (!document.hidden && knowledgeVisible) refresh(false);
            else clearTimeout(timer);
        });
        window.addEventListener('pagehide', () => { stopped = true; clearTimeout(timer); });
        window.addEventListener('pageshow', event => { if (event.persisted) { stopped = false; if (knowledgeVisible && !document.hidden) refresh(false); } });
        window.TeecKnowledge = { refresh };
        render();
        refresh();
    }

    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', mount, { once: true });
    else mount();
})();
