const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { RagSettingsState, ragRequest, ragLines, ragCount, ragJoin, ragParent } = require('../assets/terminal/rag-settings.js');

function config(revision = 1) {
    return {
        schema: 't-eec.ingest-config/1',
        revision,
        tokenizer: { id: 'e5-tokenizer', chunk_tokens: 256, overlap_tokens: 0 },
        sources: [{ id: 'microskills-file', side: 'android', path: '/storage/emulated/0/micro_skills_real.json', recursive: true }],
        departments: ['microskills', ...Array.from({ length: 5 }, (_, index) => `department-${index + 2}`)].map((id, index) => ({ id, name: index ? `Departman ${index + 1}` : 'MICROSKILLS', rules: [], phrases: [] }))
    };
}

function deferred() {
    let resolve;
    let reject;
    const promise = new Promise((done, fail) => { resolve = done; reject = fail; });
    return { promise, resolve, reject };
}

function response(value, status = 200) {
    return { ok: status >= 200 && status < 300, status, text: async () => JSON.stringify(value) };
}

function fileList(side, location, name = 'example.json') {
    return { side, path: location, entries: [{ name, directory: false, link: false, bytes: 0, modified: 1 }], error: '' };
}

function job(id, action = 'preview') {
    return { id, action, state: 'queued', created_at: 1, finished_at: null, sources: [], department_ids: ['microskills'], progress: { files: 0, records: 0, chunks: 0, tokens: 0 }, result: { sources: [], departments: [], samples: [], warnings: [] }, error: null };
}

test('loaded configuration is isolated and MICROSKILLS remains first', async () => {
    const incoming = config();
    incoming.departments.reverse();
    const state = new RagSettingsState(async url => { assert.equal(url, '/control/rag/ingest/config'); return incoming; });
    assert.equal(await state.loadConfig(), true);
    assert.equal(state.config.departments[0].id, 'microskills');
    assert.deepEqual([...state.selectedDepartments], ['microskills']);
    assert.deepEqual([...state.selectedSources], ['microskills-file']);
    state.config.departments[0].rules.push('Keep this local');
    assert.deepEqual(state.saved.departments.find(row => row.id === 'microskills').rules, []);
    assert.deepEqual(incoming.departments.find(row => row.id === 'microskills').rules, []);
});

test('optimistic save conflict preserves draft, revision, saved baseline, and selections', async () => {
    const requests = [];
    const conflict = Object.assign(new Error('revision conflict'), { status: 409 });
    const state = new RagSettingsState(async (url, options) => { requests.push({ url, options }); throw conflict; });
    state.acceptConfig(config(7));
    state.config.departments[0].name = 'My draft';
    state.config.departments[0].rules = ['Rule one'];
    state.touch();
    const draft = structuredClone(state.config);
    const saved = structuredClone(state.saved);
    await assert.rejects(state.save(), error => error === conflict);
    assert.equal(requests[0].url, '/control/rag/ingest/config');
    assert.equal(requests[0].options.method, 'POST');
    assert.equal(requests[0].options.headers['Content-Type'], 'application/json');
    assert.deepEqual(JSON.parse(requests[0].options.body), draft);
    assert.deepEqual(state.config, draft);
    assert.deepEqual(state.saved, saved);
    assert.equal(state.dirty, true);
    assert.equal(state.conflict, true);
    assert.deepEqual([...state.selectedDepartments], ['microskills']);
    assert.deepEqual([...state.selectedSources], ['microskills-file']);
});

test('rebasing a conflicted draft updates its revision without replacing local edits', async () => {
    const current = config(9);
    current.departments[0].name = 'Server update';
    const state = new RagSettingsState(async () => current);
    state.acceptConfig(config(7));
    state.config.departments[0].name = 'Local update';
    state.touch();
    state.conflict = true;
    await state.rebaseDraft();
    assert.equal(state.config.revision, 9);
    assert.equal(state.config.departments[0].name, 'Local update');
    assert.equal(state.saved.departments[0].name, 'Server update');
    assert.equal(state.dirty, true);
    assert.equal(state.conflict, false);
});

test('edits made while save is pending remain dirty after the submitted snapshot saves', async () => {
    const pending = deferred();
    let submitted;
    const state = new RagSettingsState(async (url, options) => { submitted = JSON.parse(options.body); return pending.promise; });
    state.acceptConfig(config(2));
    state.config.departments[0].name = 'Submitted name';
    state.touch();
    const saving = state.save();
    state.config.departments[0].name = 'Newer local name';
    state.config.tokenizer.overlap_tokens = 16;
    state.touch();
    pending.resolve({ ...submitted, revision: 3 });
    await saving;
    assert.equal(submitted.departments[0].name, 'Submitted name');
    assert.equal(submitted.tokenizer.overlap_tokens, 0);
    assert.equal(state.saved.departments[0].name, 'Submitted name');
    assert.equal(state.config.departments[0].name, 'Newer local name');
    assert.equal(state.config.tokenizer.overlap_tokens, 16);
    assert.equal(state.config.revision, 3);
    assert.equal(state.dirty, true);
});

test('successful save without later edits clears dirty state and adopts the server revision', async () => {
    const state = new RagSettingsState(async (url, options) => ({ ...JSON.parse(options.body), revision: 5 }));
    state.acceptConfig(config(4));
    state.config.departments[0].phrases = ['An exact phrase'];
    state.touch();
    await state.save();
    assert.equal(state.config.revision, 5);
    assert.equal(state.saved.revision, 5);
    assert.equal(state.dirty, false);
    assert.deepEqual(state.config.departments[0].phrases, ['An exact phrase']);
});

test('status polling and ordinary reload cannot replace a dirty configuration', async () => {
    const status = { mode: 'e5_embedding', departments: [{ id: 'microskills', name: 'Remote name', prepared_records: 0, vector_records: null }], jobs: [job('latest')], active_jobs: 1, paths: {} };
    const state = new RagSettingsState(async url => url.endsWith('/status') ? status : config(8));
    state.acceptConfig(config(3));
    state.config.departments[0].name = 'Unsaved name';
    state.config.departments[0].rules = ['Local rule'];
    state.touch();
    const draft = structuredClone(state.config);
    const saved = structuredClone(state.saved);
    await state.refreshStatus();
    assert.equal(await state.loadConfig(), false);
    assert.deepEqual(state.config, draft);
    assert.deepEqual(state.saved, saved);
    assert.equal(state.dirty, true);
    assert.equal(state.status.mode, 'e5_embedding');
    assert.equal(state.jobs.get('latest').state, 'queued');
    assert.equal(await state.loadConfig(true), true);
    assert.equal(state.config.revision, 8);
    assert.equal(state.dirty, false);
});

test('same-side duplicate sources are selected once without changing saved configuration', () => {
    const state = new RagSettingsState();
    state.acceptConfig(config());
    state.selectedSources.clear();
    const version = state.version;
    const source = state.config.sources[0];
    assert.equal(state.addSource(source.side, source.path, false), false);
    assert.equal(state.config.sources.length, 1);
    assert.equal(state.config.sources[0].recursive, true);
    assert.deepEqual([...state.selectedSources], [source.id]);
    assert.equal(state.dirty, false);
    assert.equal(state.version, version);
    assert.equal(state.addSource('ubuntu', source.path, false), true);
    assert.equal(state.addSource('ubuntu', '/root/second.json', true), true);
    assert.equal(new Set(state.config.sources.map(row => row.id)).size, 3);
    assert.equal(state.selectedSources.size, 3);
    assert.equal(state.dirty, true);
});

test('multiple selected sources and destinations are sent with distinct preview and ingest actions', async () => {
    const requests = [];
    const state = new RagSettingsState(async (url, options) => {
        const payload = JSON.parse(options.body);
        requests.push({ url, options, payload });
        return { job: { ...job(`job-${requests.length}`, payload.action), sources: payload.sources, department_ids: payload.department_ids } };
    });
    const incoming = config();
    incoming.sources.push({ id: 'ubuntu-folder', side: 'ubuntu', path: '/root/two words', recursive: true }, { id: 'unused-file', side: 'ubuntu', path: '/root/unused.json', recursive: false });
    state.acceptConfig(incoming);
    state.selectedSources.delete('unused-file');
    state.selectedDepartments.add('department-4');
    state.selectedDepartments.add('unknown-department');
    const preview = await state.startJob('preview');
    const ingest = await state.startJob('ingest');
    const expected = { sources: incoming.sources.slice(0, 2).map(({ side, path, recursive }) => ({ side, path, recursive })), department_ids: ['microskills', 'department-4'] };
    assert.deepEqual(requests.map(({ payload }) => payload), [{ action: 'preview', ...expected }, { action: 'ingest', ...expected }]);
    assert.ok(requests.every(({ url, options }) => url === '/control/rag/ingest/jobs' && options.method === 'POST' && options.headers['Content-Type'] === 'application/json'));
    assert.equal(preview.action, 'preview');
    assert.equal(ingest.action, 'ingest');
    assert.equal(state.selectedJob, 'job-2');
    assert.equal(state.jobs.size, 2);
    assert.equal(state.config.revision, 1);
    assert.equal(state.dirty, false);
});

test('job submission requires saved settings, valid token boundaries, and both selections', () => {
    const state = new RagSettingsState();
    assert.throws(() => state.jobRequest('preview'), /yüklenmedi/);
    state.acceptConfig(config());
    state.touch();
    assert.throws(() => state.jobRequest('ingest'), /kaydedin/);
    state.acceptConfig(config(), true);
    state.selectedSources.clear();
    assert.throws(() => state.jobRequest('preview'), /En az bir kaynak/);
    state.selectedSources.add('microskills-file');
    state.selectedDepartments.clear();
    assert.throws(() => state.jobRequest('ingest'), /En az bir kaynak/);
    state.selectedDepartments.add('microskills');
    assert.throws(() => state.jobRequest('unknown'), /Geçersiz iş türü/);
    for (const [chunk_tokens, overlap_tokens] of [[0, 0], [2.5, 0], [8, -1], [8, 8], [8, 0.5], [null, 0]]) {
        Object.assign(state.config.tokenizer, { chunk_tokens, overlap_tokens });
        assert.throws(() => state.jobRequest('ingest'), /Parça boyutu/);
    }
    Object.assign(state.config.tokenizer, { chunk_tokens: 8, overlap_tokens: 7 });
    assert.equal(state.jobRequest('preview').action, 'preview');
    state.config.departments[0].name = '  ';
    assert.throws(() => state.jobRequest('preview'), /Departman adları/);
});

test('request helper accepts upstream success and preserves JSON request options', async () => {
    const options = { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: '{"action":"preview"}' };
    const expected = { upstream_status: 202, job: job('accepted') };
    const value = await ragRequest('/control/rag/ingest/jobs', options, async (url, actual) => {
        assert.equal(url, '/control/rag/ingest/jobs');
        assert.deepEqual(actual, { cache: 'no-store', ...options });
        return response(expected);
    });
    assert.deepEqual(value, expected);
});

test('request helper rejects HTTP, upstream, and HTTP-200 payload failures', async () => {
    for (const [payload, httpStatus, expectedStatus, expectedMessage] of [
        [{ error: 'revision conflict' }, 409, 409, 'revision conflict'],
        [{ upstream_status: 409, error: 'upstream conflict' }, 200, 409, 'upstream conflict'],
        [{ upstream_status: '503', message: 'model unavailable' }, 200, 503, 'model unavailable'],
        [{ ready: false, error: 'rag_operation_failed: connection lost' }, 200, 200, 'rag_operation_failed: connection lost'],
        [{}, 502, 502, 'HTTP 502']
    ]) {
        await assert.rejects(ragRequest('/endpoint', {}, async () => response(payload, httpStatus)), error => error.status === expectedStatus && error.message === expectedMessage);
    }
    const offline = new Error('offline');
    await assert.rejects(ragRequest('/endpoint', {}, async () => { throw offline; }), error => error === offline);
});

test('request helper reports malformed JSON and preserves non-JSON HTTP diagnostics', async () => {
    await assert.rejects(ragRequest('/endpoint', {}, async () => ({ ok: true, status: 200, text: async () => '<html>not JSON</html>' })), /geçerli JSON/);
    await assert.rejects(ragRequest('/endpoint', {}, async () => ({ ok: false, status: 500, text: async () => 'upstream exploded' })), /HTTP 500: upstream exploded/);
});

test('malformed configurations, status, jobs, and listings are rejected without acceptance', async () => {
    const state = new RagSettingsState();
    for (const value of [null, {}, { ...config(), revision: 1.5 }, { ...config(), departments: config().departments.slice(1) }, { ...config(), tokenizer: { id: 'other' } }]) assert.throws(() => state.acceptConfig(value));
    const duplicate = config();
    duplicate.departments[5].id = 'microskills';
    assert.throws(() => state.acceptConfig(duplicate));
    assert.equal(state.config, null);
    state.request = async () => ({ departments: [], jobs: null });
    await assert.rejects(state.refreshStatus(), /Canlı durum yanıtı geçersiz/);
    assert.equal(state.status, null);
    for (const value of [null, {}, { id: '' }, { id: 1 }]) assert.throws(() => state.acceptJob(value), /geçerli iş kimliği/);
    assert.equal(state.jobs.size, 0);
    for (const value of [{ side: 'ubuntu', path: '/root' }, { side: 'android', path: '/root', entries: [] }, { side: 'ubuntu', path: null, entries: [] }]) {
        state.request = async () => value;
        await assert.rejects(state.browse('ubuntu', '/root'), /Dosya listesi yanıtı geçersiz/);
        assert.equal(state.directory, null);
    }
});

test('newer browser response wins when directory requests complete out of order', async () => {
    const pending = [];
    const urls = [];
    const state = new RagSettingsState(url => { urls.push(url); const entry = deferred(); pending.push(entry); return entry.promise; });
    state.directory = fileList('android', '/old');
    const first = state.browse('android', '/storage/emulated/0/first');
    assert.equal(state.directory, null);
    const second = state.browse('ubuntu', '/root/a & b');
    assert.equal(new URL(urls[1], 'http://localhost').searchParams.get('path'), '/root/a & b');
    const fresh = fileList('ubuntu', '/root/a & b', 'new.json');
    pending[1].resolve(fresh);
    assert.deepEqual(await second, fresh);
    pending[0].resolve(fileList('android', '/storage/emulated/0/first', 'stale.json'));
    assert.equal(await first, null);
    assert.deepEqual(state.directory, fresh);
});

test('failed directory loads clear prior entries and surface HTTP-200 filesystem errors', async () => {
    const state = new RagSettingsState((url, options) => ragRequest(url, options, async () => response({ side: 'ubuntu', path: '/missing', entries: [], error: 'Permission denied' })));
    state.directory = fileList('ubuntu', '/root');
    await assert.rejects(state.browse('ubuntu', '/missing'), /Permission denied/);
    assert.equal(state.directory, null);
});

test('individual job refresh encodes its identity and retains an independent snapshot', async () => {
    const value = job('task a&b?');
    const state = new RagSettingsState(async url => {
        assert.equal(new URL(url, 'http://localhost').searchParams.get('id'), value.id);
        return { job: value };
    });
    assert.equal(await state.refreshJob(), null);
    state.selectedJob = value.id;
    await state.refreshJob();
    value.progress.tokens = 100;
    assert.equal(state.jobs.get(value.id).progress.tokens, 0);
});

test('unknown counters remain distinct from known zero and finite counts', () => {
    for (const value of [undefined, null, NaN, Infinity, -Infinity, -1, '0', {}, false]) assert.equal(ragCount(value), '—');
    assert.equal(ragCount(0), '0');
    assert.equal(ragCount(1234), '1.234');
    assert.deepEqual(ragLines(' one\r\n\n two \n  \n'), ['one', 'two']);
    assert.equal(ragJoin('/', 'file.json'), '/file.json');
    assert.equal(ragJoin('/root///', 'a & b.json'), '/root/a & b.json');
    assert.equal(ragParent('/root/child/'), '/root');
    assert.equal(ragParent('/root'), '/');
    assert.equal(ragParent('/'), '/');
});

test('settings markup exposes required controls and current E5 preview/ingest messaging', () => {
    const html = fs.readFileSync(path.join(__dirname, '../assets/terminal/rag-settings.html'), 'utf8');
    const ids = [...html.matchAll(/\bid="([^"]+)"/g)].map(match => match[1]);
    assert.equal(new Set(ids).size, ids.length);
    for (const id of ['config-form', 'config-fields', 'config-feedback', 'save-config', 'rebase-draft', 'discard-draft', 'department-list', 'tokenizer-id', 'chunk-tokens', 'overlap-tokens', 'source-list', 'browser-form', 'browser-side', 'browser-path', 'browser-list', 'destination-list', 'preview-job', 'ingest-job', 'job-list', 'job-detail', 'job-counts', 'job-error', 'service-status']) assert.ok(ids.includes(id), `Missing ${id}`);
    assert.match(html, /<html lang="tr">/);
    assert.match(html, /e5_embedding/);
    assert.match(html, /Önizleme yalnızca tokenları hazırlar/);
    assert.match(html, /İçe alma, E5 embedding üretir/);
    assert.match(html, /Önizleme departman kayıtlarını değiştirmez ve embedding üretmez/);
    assert.doesNotMatch(html, /encoder-less|encoderless|tokenizer_only|tokenizer-only/i);
});
