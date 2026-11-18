const ragCopy = value => JSON.parse(JSON.stringify(value));
const ragLines = value => value.split(/\r?\n/).map(line => line.trim()).filter(Boolean);
const ragCount = value => typeof value === 'number' && Number.isFinite(value) && value >= 0 ? new Intl.NumberFormat('tr-TR').format(value) : '—';
const ragTime = value => typeof value === 'number' && value > 0 ? new Date(value * 1000).toLocaleString('tr-TR') : 'Henüz yok';
const ragJoin = (path, name) => `${path.replace(/\/+$/, '')}/${name}`;
const ragParent = path => path.replace(/\/+$/, '').replace(/\/[^/]*$/, '') || '/';
const ragStates = { queued: 'Sırada', running: 'Çalışıyor', completed: 'Tamamlandı', failed: 'Başarısız', interrupted: 'Kesildi' };

async function ragRequest(url, options = {}, fetcher = fetch) {
    const response = await fetcher(url, { cache: 'no-store', ...options });
    const raw = await response.text();
    let value;
    try { value = JSON.parse(raw); } catch {
        throw new Error(response.ok ? 'Sunucu geçerli JSON döndürmedi.' : `HTTP ${response.status}: ${raw.slice(0, 400)}`);
    }
    const status = Number(value?.upstream_status) || response.status;
    if (!response.ok || status >= 400 || value?.error) {
        const error = new Error(value?.error || value?.message || `HTTP ${status}`);
        error.status = status;
        throw error;
    }
    return value;
}

class RagSettingsState {
    constructor(request = ragRequest) {
        this.request = request;
        this.config = null;
        this.saved = null;
        this.dirty = false;
        this.conflict = false;
        this.version = 0;
        this.status = null;
        this.selectedSources = new Set();
        this.selectedDepartments = new Set();
        this.jobs = new Map();
        this.selectedJob = null;
        this.directory = null;
        this.directoryVersion = 0;
    }
    checkConfig(value) {
        if (!value || !Number.isInteger(value.revision) || !Array.isArray(value.sources) || !Array.isArray(value.departments) || value.departments.length !== 6 || new Set(value.departments.map(row => row.id)).size !== 6 || !value.departments.some(row => row.id === 'microskills') || value.tokenizer?.id !== 'e5-tokenizer') throw new Error('Sunucu ayarları beklenen altı departman yapısında değil.');
        return value;
    }
    acceptConfig(value, force = false) {
        this.checkConfig(value);
        if (this.dirty && !force) return false;
        this.config = ragCopy(value);
        this.saved = ragCopy(value);
        this.config.departments.sort((a, b) => Number(b.id === 'microskills') - Number(a.id === 'microskills'));
        this.dirty = false;
        this.conflict = false;
        this.version++;
        this.selectedSources = new Set(value.sources.map(source => source.id));
        this.selectedDepartments = new Set([...this.selectedDepartments].filter(id => value.departments.some(row => row.id === id)));
        if (!this.selectedDepartments.size) this.selectedDepartments.add('microskills');
        return true;
    }
    async loadConfig(force = false) {
        return this.acceptConfig(await this.request('/control/rag/ingest/config'), force);
    }
    touch() { this.dirty = true; this.version++; }
    async rebaseDraft() {
        const value = this.checkConfig(await this.request('/control/rag/ingest/config'));
        this.saved = ragCopy(value);
        this.config.revision = value.revision;
        this.conflict = false;
        this.touch();
    }
    validate() {
        if (!this.config) throw new Error('Ayarlar henüz yüklenmedi.');
        const { chunk_tokens: chunk, overlap_tokens: overlap } = this.config.tokenizer;
        if (!Number.isInteger(chunk) || chunk < 1 || !Number.isInteger(overlap) || overlap < 0 || overlap >= chunk) throw new Error('Parça boyutu pozitif bir tam sayı; örtüşme ise sıfır ile parça boyutundan bir eksik arasında olmalıdır.');
        if (this.config.departments.some(row => !row.name.trim())) throw new Error('Departman adları boş bırakılamaz.');
    }
    async save() {
        this.validate();
        const submitted = ragCopy({ schema: this.config.schema, revision: this.config.revision, tokenizer: this.config.tokenizer, sources: this.config.sources, departments: this.config.departments });
        const version = this.version;
        try {
            const value = this.checkConfig(await this.request('/control/rag/ingest/config', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(submitted) }));
            this.saved = ragCopy(value);
            this.config.revision = value.revision;
            this.conflict = false;
            if (this.version === version) {
                this.config = ragCopy(value);
                this.config.departments.sort((a, b) => Number(b.id === 'microskills') - Number(a.id === 'microskills'));
                this.dirty = false;
            }
            return value;
        } catch (error) {
            if (error.status === 409) this.conflict = true;
            throw error;
        }
    }
    addSource(side, path, recursive) {
        if (!this.config) throw new Error('Kaynak eklemek için ayarların yüklenmesini bekleyin.');
        const existing = this.config.sources.find(source => source.side === side && source.path === path);
        if (existing) { this.selectedSources.add(existing.id); return false; }
        const used = new Set(this.config.sources.map(source => source.id));
        let id = `source-${Date.now()}`;
        while (used.has(id)) id += '-1';
        this.config.sources.push({ id, side, path, recursive: Boolean(recursive) });
        this.selectedSources.add(id);
        this.touch();
        return true;
    }
    removeSource(id) {
        this.config.sources = this.config.sources.filter(source => source.id !== id);
        this.selectedSources.delete(id);
        this.touch();
    }
    acceptJob(job) {
        if (!job || typeof job.id !== 'string' || !job.id) throw new Error('Sunucu geçerli iş kimliği döndürmedi.');
        this.jobs.set(job.id, ragCopy(job));
        if (!this.selectedJob) this.selectedJob = job.id;
        return job;
    }
    async refreshStatus() {
        const value = await this.request('/control/rag/ingest/status');
        if (!value || !Array.isArray(value.departments) || !Array.isArray(value.jobs)) throw new Error('Canlı durum yanıtı geçersiz.');
        this.status = value;
        for (const job of value.jobs) this.acceptJob(job);
        return value;
    }
    jobRequest(action) {
        if (this.dirty) throw new Error('İş başlatmadan önce taslak ayarları kaydedin.');
        this.validate();
        if (!['preview', 'ingest'].includes(action)) throw new Error('Geçersiz iş türü.');
        const sources = this.config.sources.filter(source => this.selectedSources.has(source.id)).map(({ side, path, recursive }) => ({ side, path, recursive }));
        const department_ids = this.config.departments.filter(row => this.selectedDepartments.has(row.id)).map(row => row.id);
        if (!sources.length || !department_ids.length) throw new Error('En az bir kaynak ve bir hedef departman seçin.');
        return { action, sources, department_ids };
    }
    async startJob(action) {
        const payload = this.jobRequest(action);
        const value = await this.request('/control/rag/ingest/jobs', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload) });
        this.acceptJob(value.job);
        this.selectedJob = value.job.id;
        return value.job;
    }
    async refreshJob(id = this.selectedJob) {
        if (!id) return null;
        const value = await this.request(`/control/rag/ingest/jobs?id=${encodeURIComponent(id)}`);
        return this.acceptJob(value.job);
    }
    async browse(side, path) {
        const version = ++this.directoryVersion;
        this.directory = null;
        const value = await this.request(`/files/list?side=${encodeURIComponent(side)}&path=${encodeURIComponent(path)}`);
        if (version !== this.directoryVersion) return null;
        if (!Array.isArray(value.entries) || typeof value.path !== 'string' || value.side !== side) throw new Error('Dosya listesi yanıtı geçersiz.');
        this.directory = value;
        return value;
    }
}

function mountRagSettings() {
    const state = new RagSettingsState();
    const byId = id => document.getElementById(id);
    const create = (tag, className, text) => {
        const node = document.createElement(tag);
        if (className) node.className = className;
        if (text !== undefined) node.textContent = text;
        return node;
    };
    const feedback = (id, text, error = false) => { byId(id).textContent = text; byId(id).dataset.error = String(error); };
    const metricRows = new Map();
    const destinationNames = new Map();
    const jobButtons = new Map();
    let configBusy = false;
    let jobBusy = false;
    let statusBusy = false;
    let stopped = false;
    let timer;
    let browseVersion = 0;
    const metrics = [['prepared_records', 'Hazır kayıt'], ['chunks', 'Parça'], ['tokens', 'Token'], ['vector_records', 'Vektör kaydı'], ['bytes', 'Bayt']];
    function renderControls() {
        const ready = Boolean(state.config);
        byId('config-fields').disabled = !ready || configBusy;
        byId('save-config').disabled = !ready || !state.dirty || configBusy;
        byId('reload-config').disabled = configBusy || state.dirty;
        byId('rebase-draft').disabled = configBusy;
        byId('discard-draft').disabled = configBusy;
        byId('conflict-actions').hidden = !state.conflict;
        byId('draft-status').textContent = ready ? `${state.dirty ? 'Kaydedilmemiş değişiklikler' : 'Tüm ayarlar kayıtlı'} · sürüm ${state.config.revision}` : 'Kayıtlı ayarlar bekleniyor.';
        const sourceCount = state.config?.sources.filter(source => state.selectedSources.has(source.id)).length || 0;
        const targetCount = state.selectedDepartments.size;
        const runnable = ready && !state.dirty && sourceCount > 0 && targetCount > 0 && !configBusy && !jobBusy;
        byId('preview-job').disabled = !runnable;
        byId('ingest-job').disabled = !runnable;
        byId('run-summary').textContent = !ready ? 'Önce kayıtlı ayarları yükleyin.' : state.dirty ? 'İş başlatmak için değişiklikleri kaydedin.' : `${sourceCount} kaynak → ${targetCount} hedef departman. Her hedefe aynı seçili kaynaklar işlenir.`;
        byId('add-directory').disabled = !ready || configBusy || !state.directory;
    }
    function makeMetricList(definitions) {
        const list = create('dl', 'metrics');
        const values = new Map();
        for (const [key, label] of definitions) {
            const item = create('div', key === 'vector_records' ? 'metric vector-count' : 'metric');
            const value = create('dd', '', '—');
            item.append(create('dt', '', label), value);
            list.append(item);
            values.set(key, value);
        }
        return { list, values };
    }
    function renderDepartments() {
        metricRows.clear();
        destinationNames.clear();
        byId('department-list').replaceChildren();
        byId('destination-list').replaceChildren();
        for (const [index, department] of state.config.departments.entries()) {
            const row = create('li', 'department-row');
            const nameArea = create('div', 'department-name');
            const nameLabel = create('label', '', `Departman ${index + 1}`);
            const name = create('input');
            name.id = `department-name-${index}`;
            nameLabel.htmlFor = name.id;
            name.value = department.name;
            name.required = true;
            name.readOnly = department.id === 'microskills';
            name.addEventListener('input', () => {
                department.name = name.value;
                destinationNames.get(department.id).textContent = name.value || 'Adsız departman';
                state.touch();
                renderControls();
            });
            nameLabel.append(name);
            const ready = create('p', 'department-state', 'Durum bekleniyor');
            nameArea.append(nameLabel, ready);
            const stats = create('div', 'department-stats');
            const measured = makeMetricList(metrics);
            const path = create('p', 'path department-path', 'Chroma yolu · —');
            stats.append(measured.list, path);
            const meta = create('p', 'department-meta', 'Son hazırlama · —');
            const error = create('p', 'department-error');
            const notes = create('details', 'department-notes');
            notes.append(create('summary', '', 'Kurallar ve anahtar ifadeler'));
            const fields = create('div', 'notes-fields');
            for (const [key, label] of [['rules', 'Kurallar · her satıra bir talimat'], ['phrases', 'Anahtar ifadeler · her satıra bir ifade']]) {
                const wrapper = create('label', '', label);
                const input = create('textarea');
                input.id = `department-${key}-${index}`;
                wrapper.htmlFor = input.id;
                input.value = (department[key] || []).join('\n');
                input.rows = 3;
                input.addEventListener('input', () => { department[key] = ragLines(input.value); state.touch(); renderControls(); });
                wrapper.append(input);
                fields.append(wrapper);
            }
            notes.append(fields);
            row.append(nameArea, stats, meta, error, notes);
            byId('department-list').append(row);
            metricRows.set(department.id, { values: measured.values, path, ready, meta, error });
            const target = create('label', 'check-label');
            const checkbox = create('input');
            checkbox.type = 'checkbox';
            checkbox.checked = state.selectedDepartments.has(department.id);
            const caption = create('span', '', department.name);
            checkbox.addEventListener('change', () => { checkbox.checked ? state.selectedDepartments.add(department.id) : state.selectedDepartments.delete(department.id); renderControls(); });
            target.append(checkbox, caption);
            byId('destination-list').append(target);
            destinationNames.set(department.id, caption);
        }
        byId('department-count').textContent = `${state.config.departments.length} departman`;
        renderMetrics();
    }
    function renderMetrics() {
        const rows = new Map((state.status?.departments || []).map(row => [row.id, row]));
        for (const [id, view] of metricRows) {
            const value = rows.get(id);
            for (const [key, node] of view.values) node.textContent = ragCount(value?.[key]);
            view.path.textContent = `Chroma yolu · ${value?.chroma_path || '—'}`;
            view.ready.textContent = !value ? 'Durum bekleniyor' : value.ready ? 'Depo hazır' : 'Depo hazır değil';
            view.ready.dataset.ready = String(value?.ready === true);
            view.meta.textContent = `Son içe alma · ${value ? ragTime(value.last_ingested_at) : '—'}`;
            view.error.textContent = value?.last_error || '';
        }
    }
    function renderSources() {
        byId('source-list').replaceChildren();
        if (!state.config.sources.length) byId('source-list').append(create('li', 'empty', 'Kayıtlı kaynak yok. Aşağıdaki dosya tarayıcısından bir dosya veya klasör ekleyin.'));
        for (const source of state.config.sources) {
            const row = create('li', 'source-row');
            const label = create('label', 'check-label');
            const selected = create('input');
            selected.type = 'checkbox';
            selected.checked = state.selectedSources.has(source.id);
            selected.setAttribute('aria-label', `Bu işte kullan: ${source.side} ${source.path}`);
            selected.addEventListener('change', () => { selected.checked ? state.selectedSources.add(source.id) : state.selectedSources.delete(source.id); renderControls(); });
            const side = create('span', 'source-side', source.side === 'android' ? 'Android' : 'Ubuntu');
            side.dataset.side = source.side;
            label.append(selected, side);
            const remove = create('button', 'source-remove', 'Kaldır');
            remove.type = 'button';
            remove.setAttribute('aria-label', `Kaynağı kaldır: ${source.path}`);
            remove.addEventListener('click', () => { state.removeSource(source.id); renderSources(); renderControls(); byId('source-list').querySelector('input')?.focus(); });
            const recursiveLabel = create('label', 'check-label recursive');
            const recursive = create('input');
            recursive.type = 'checkbox';
            recursive.checked = source.recursive;
            recursive.addEventListener('change', () => { source.recursive = recursive.checked; state.touch(); renderControls(); });
            recursiveLabel.append(recursive, create('span', '', 'Klasörse alt klasörleri dahil et'));
            row.append(label, remove, create('p', 'path source-path', source.path), recursiveLabel);
            byId('source-list').append(row);
        }
        byId('source-count').textContent = `${state.config.sources.length} kaynak`;
    }
    function renderConfig() {
        byId('tokenizer-id').value = state.config.tokenizer.id;
        byId('chunk-tokens').value = state.config.tokenizer.chunk_tokens;
        byId('overlap-tokens').value = state.config.tokenizer.overlap_tokens;
        renderDepartments();
        renderSources();
        renderControls();
    }
    function renderJobs() {
        const jobs = [...state.jobs.values()].sort((a, b) => (b.created_at || 0) - (a.created_at || 0));
        if (!jobs.length) {
            byId('job-list').replaceChildren(create('li', 'empty', 'Henüz iş yok. Bir önizleme ile başlayabilirsiniz.'));
        } else {
            if (!jobButtons.size) byId('job-list').replaceChildren();
            for (const [index, job] of jobs.entries()) {
                if (!jobButtons.has(job.id)) {
                    const item = create('li');
                    const button = create('button');
                    button.type = 'button';
                    button.addEventListener('click', async () => {
                        state.selectedJob = job.id;
                        renderJobs();
                        try { await state.refreshJob(job.id); renderJobs(); } catch (error) { feedback('run-feedback', `İş ayrıntıları alınamadı: ${error.message}`, true); }
                    });
                    item.append(button);
                    byId('job-list').insertBefore(item, byId('job-list').children[index] || null);
                    jobButtons.set(job.id, button);
                }
                const button = jobButtons.get(job.id);
                button.textContent = `${job.action === 'preview' ? 'Önizleme' : 'İçe alma'} · ${ragStates[job.state] || job.state} · ${ragTime(job.created_at)}`;
                button.setAttribute('aria-pressed', String(state.selectedJob === job.id));
            }
        }
        const job = state.jobs.get(state.selectedJob);
        byId('job-detail').hidden = !job;
        if (!job) return;
        byId('job-title').textContent = job.action === 'preview' ? 'Önizleme sonucu' : 'İçe alma sonucu';
        byId('job-identity').textContent = `İş · ${job.id}`;
        byId('job-state').textContent = `${ragStates[job.state] || job.state} · Başlangıç ${ragTime(job.created_at)}${job.finished_at ? ` · Bitiş ${ragTime(job.finished_at)}` : ''}`;
        byId('job-progress').hidden = !['queued', 'running'].includes(job.state);
        const counts = makeMetricList([['files', 'Dosya'], ['records', 'Kayıt'], ['chunks', 'Parça'], ['tokens', 'Token']]);
        for (const [key, node] of counts.values) node.textContent = ragCount(job.progress?.[key]);
        byId('job-counts').replaceChildren(...counts.list.children);
        feedback('job-error', job.error || (job.state === 'interrupted' ? 'İş kesildi; otomatik olarak yeniden başlatılmadı.' : ''), Boolean(job.error));
        byId('job-warnings').replaceChildren();
        if (job.result?.warnings?.length) {
            byId('job-warnings').append(create('p', '', 'Uyarılar'));
            const list = create('ul');
            for (const warning of job.result.warnings) list.append(create('li', '', typeof warning === 'string' ? warning : JSON.stringify(warning)));
            byId('job-warnings').append(list);
        }
        byId('job-result-data').textContent = JSON.stringify({ sources: job.sources, department_ids: job.department_ids, result: job.result || null }, null, 2);
    }
    async function loadConfig(force = false) {
        configBusy = true;
        renderControls();
        try {
            if (await state.loadConfig(force)) renderConfig();
            feedback('config-feedback', state.dirty ? 'Taslak korundu; kayıtlı ayarlar forma uygulanmadı.' : 'Kayıtlı ayarlar yüklendi.');
        } catch (error) { feedback('config-feedback', `Ayarlar yüklenemedi: ${error.message}`, true); }
        finally { configBusy = false; renderControls(); }
    }
    async function refreshStatus() {
        if (statusBusy) return;
        statusBusy = true;
        byId('refresh-status').disabled = true;
        try {
            const value = await state.refreshStatus();
            feedback('service-status', `Canlı durum · ${new Date().toLocaleTimeString('tr-TR')} · ${value.mode || 'Mod bilinmiyor'}`);
            byId('active-jobs').textContent = `${ragCount(value.active_jobs)} etkin iş`;
            renderMetrics();
            renderJobs();
            byId('service-paths').replaceChildren();
            for (const [key, label] of [['service', 'Servis'], ['settings', 'Ayarlar'], ['data', 'Veri']]) byId('service-paths').append(create('dt', '', label), create('dd', '', value.paths?.[key] || '—'));
            if (state.selectedJob) {
                try { await state.refreshJob(); renderJobs(); }
                catch (error) { feedback('run-feedback', `İş durumu alınamadı: ${error.message}`, true); }
            }
        } catch (error) {
            feedback('service-status', `Canlı duruma ulaşılamadı. Son alınan değerler gösteriliyor. ${error.message}`, true);
            if (!state.status) byId('job-list').replaceChildren(create('li', 'empty', 'İş durumu alınamadı. Durumu yenileyerek tekrar deneyin.'));
        } finally { statusBusy = false; byId('refresh-status').disabled = false; }
    }
    function addSource(side, path, recursive) {
        try {
            const added = state.addSource(side, path, recursive);
            renderSources();
            renderControls();
            feedback('browser-status', added ? `Kaynak taslağa eklendi: ${path}. Ayarları kaydedin.` : `Kaynak zaten listede ve bu iş için seçildi: ${path}`);
        } catch (error) { feedback('browser-status', error.message, true); }
    }
    async function browse(side, path) {
        const version = ++browseVersion;
        byId('browser-up').disabled = true;
        byId('add-directory').disabled = true;
        byId('browser-list').replaceChildren(create('li', 'empty', 'Klasör yükleniyor…'));
        byId('browser-list').setAttribute('aria-busy', 'true');
        feedback('browser-status', 'Dosya listesi yükleniyor…');
        try {
            const directory = await state.browse(side, path);
            if (!directory || version !== browseVersion) return;
            byId('browser-path').value = directory.path;
            byId('browser-location').textContent = `${side === 'android' ? 'Android' : 'Ubuntu'} · ${directory.path}`;
            byId('browser-list').replaceChildren();
            if (!directory.entries.length) byId('browser-list').append(create('li', 'empty', 'Bu konumda listelenen öğe yok.'));
            for (const entry of directory.entries) {
                const row = create('li', 'browser-row');
                const identity = create('div', 'browser-entry');
                identity.append(create('p', 'browser-entry-name', entry.name), create('p', 'browser-entry-kind', `${entry.directory ? 'Klasör' : 'Dosya'}${entry.link ? ' · bağlantı' : ''}${!entry.directory ? ` · ${ragCount(entry.bytes)} bayt` : ''}`));
                const action = create('button', '', entry.directory ? 'Aç' : 'Kaynak ekle');
                action.type = 'button';
                action.setAttribute('aria-label', `${entry.directory ? 'Klasörü aç' : 'Kaynak ekle'}: ${entry.name}`);
                action.addEventListener('click', () => entry.directory ? browse(side, ragJoin(directory.path, entry.name)) : addSource(side, ragJoin(directory.path, entry.name), false));
                row.append(identity, action);
                byId('browser-list').append(row);
            }
            byId('browser-up').disabled = directory.path === '/';
            renderControls();
            feedback('browser-status', `${directory.entries.length} öğe listelendi.`);
        } catch (error) {
            if (version !== browseVersion) return;
            byId('browser-list').replaceChildren(create('li', 'empty', 'Dosya listesi alınamadı. Yolu denetleyip tekrar açın.'));
            byId('browser-location').textContent = `${side === 'android' ? 'Android' : 'Ubuntu'} · ${path}`;
            feedback('browser-status', error.message, true);
        } finally { if (version === browseVersion) byId('browser-list').setAttribute('aria-busy', 'false'); }
    }
    byId('config-form').addEventListener('submit', async event => {
        event.preventDefault();
        if (configBusy) return;
        configBusy = true;
        renderControls();
        feedback('config-feedback', 'Ayarlar kaydediliyor…');
        try {
            await state.save();
            if (!state.dirty) renderConfig();
            feedback('config-feedback', state.dirty ? 'Gönderilen ayarlar kaydedildi; sonraki değişiklikler taslakta duruyor.' : 'Ayarlar kaydedildi.');
            await refreshStatus();
        } catch (error) { feedback('config-feedback', state.conflict ? `Sürüm çakışması. Taslağınız korunuyor. ${error.message}` : `Kaydedilemedi: ${error.message}`, true); }
        finally { configBusy = false; renderControls(); }
    });
    for (const [id, key] of [['chunk-tokens', 'chunk_tokens'], ['overlap-tokens', 'overlap_tokens']]) byId(id).addEventListener('input', () => { state.config.tokenizer[key] = byId(id).value === '' ? null : Number(byId(id).value); state.touch(); renderControls(); });
    byId('reload-config').addEventListener('click', () => loadConfig());
    byId('discard-draft').addEventListener('click', () => loadConfig(true));
    byId('rebase-draft').addEventListener('click', async () => {
        configBusy = true;
        renderControls();
        try { await state.rebaseDraft(); feedback('config-feedback', 'Taslak güncel sürüme taşındı. Kaydettiğinizde sunucudaki ayarlar bu taslakla değiştirilecek.'); }
        catch (error) { feedback('config-feedback', error.message, true); }
        finally { configBusy = false; renderControls(); }
    });
    byId('refresh-status').addEventListener('click', refreshStatus);
    byId('browser-form').addEventListener('submit', event => { event.preventDefault(); browse(byId('browser-side').value, byId('browser-path').value); });
    byId('browser-side').addEventListener('change', () => {
        const side = byId('browser-side').value;
        const path = side === 'android' ? '/storage/emulated/0/Download' : '/root';
        byId('browser-path').value = path;
        browse(side, path);
    });
    byId('browser-up').addEventListener('click', () => { if (state.directory) browse(state.directory.side, ragParent(state.directory.path)); });
    byId('add-directory').addEventListener('click', () => { if (state.directory) addSource(state.directory.side, state.directory.path, byId('browser-recursive').checked); });
    for (const [id, action] of [['preview-job', 'preview'], ['ingest-job', 'ingest']]) byId(id).addEventListener('click', async () => {
        if (jobBusy) return;
        jobBusy = true;
        renderControls();
        feedback('run-feedback', 'İş gönderiliyor…');
        try {
            await state.startJob(action);
            renderJobs();
            feedback('run-feedback', `${action === 'preview' ? 'Önizleme' : 'İçe alma'} işi kabul edildi. İlerleme aşağıda gösterilir.`);
            await refreshStatus();
        } catch (error) { feedback('run-feedback', `İş başlatılamadı: ${error.message}`, true); }
        finally { jobBusy = false; renderControls(); }
    });
    window.addEventListener('beforeunload', event => { if (state.dirty) { event.preventDefault(); event.returnValue = ''; } });
    window.addEventListener('pagehide', () => { stopped = true; clearTimeout(timer); });
    window.addEventListener('pageshow', event => { if (event.persisted) { stopped = false; poll(); } });
    async function poll() { await refreshStatus(); if (!stopped) timer = setTimeout(poll, 3000); }
    loadConfig();
    poll();
    return { state, refreshStatus, loadConfig, browse };
}

if (typeof module !== 'undefined' && module.exports) module.exports = { RagSettingsState, ragRequest, ragLines, ragCount, ragJoin, ragParent, mountRagSettings };
if (typeof document !== 'undefined') mountRagSettings();
