import argparse
import hashlib
from html.parser import HTMLParser
from http.client import HTTPConnection
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
from pathlib import Path
import subprocess
import tempfile
import threading
import time
from urllib.parse import urljoin, urlsplit
from host_java_dependencies import json_classpath

parser = argparse.ArgumentParser()
parser.add_argument('--evidence', type=Path)
parser.add_argument('--assets-only', action='store_true')
parser.add_argument('--proxy-only', action='store_true')
options = parser.parse_args()
root = Path(__file__).resolve().parents[2]
runtime = root / 'server-java/teec/shell/term_shell/runtime'
checks = []
requests = []
health = {'code': 200, 'ready': False}
behavior = {'code': 200, 'body': None, 'delay': 0}


def require(condition, label):
    if not condition:
        raise AssertionError(label)
    checks.append(label)


class LocalAssets(HTMLParser):
    def __init__(self):
        super().__init__()
        self.assets = []

    def handle_starttag(self, tag, attributes):
        values = dict(attributes)
        asset = values.get('src', '') if tag == 'script' else values.get('href', '') if tag == 'link' and 'stylesheet' in values.get('rel', '').split() else ''
        if asset and not urlsplit(asset).scheme and not urlsplit(asset).netloc:
            self.assets.append(asset)


class Upstream(BaseHTTPRequestHandler):
    def log_message(self, *arguments):
        pass

    def respond(self, method):
        body = self.rfile.read(int(self.headers.get('Content-Length', 0)))
        requests.append({'method': method, 'path': self.path, 'body': body})
        if self.path == '/health/status':
            code, payload = health['code'], {'ready': health['ready']}
        elif self.path.startswith(('/ingest/', '/rag/')):
            time.sleep(behavior['delay'])
            code = behavior['code']
            payload = behavior['body'] if behavior['body'] is not None else {'mode': 'e5_embedding', 'path': self.path}
        else:
            code, payload = 200, {'ready': True, 'path': self.path}
        data = payload if isinstance(payload, bytes) else json.dumps(payload, ensure_ascii=False).encode()
        self.send_response(code)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        self.respond('GET')

    def do_POST(self):
        self.respond('POST')


with tempfile.TemporaryDirectory(prefix='teec-ingest-proxy-') as temporary:
    work = Path(temporary)
    classpath = json_classpath(root, work)
    names = ['PtyNative.java', 'PtySession.java', 'TerminalServer.java', 'McpEndpoint.java', 'FileWorkspace.java', 'SemanticRag.java', 'RagPreflight.java', 'ProotCommand.java', 'UbuntuImage.java']
    fixtures = ['android/content/Context.java', 'android/content/res/AssetManager.java', 'android/content/pm/ApplicationInfo.java', 'RagIngestionProxyTest.java']
    subprocess.run(['javac', '--release', '8', '-Xlint:-options', '-cp', classpath, '-d', work, *[runtime / name for name in names], *[root / 'tests/java' / name for name in fixtures]], check=True)
    upstream = ThreadingHTTPServer(('127.0.0.1', 0), Upstream)
    thread = threading.Thread(target=upstream.serve_forever, daemon=True)
    thread.start()
    process = subprocess.Popen(['java', '-cp', classpath, 'RagIngestionProxyTest', work / 'files', root / 'assets', 'http://127.0.0.1:' + str(upstream.server_port)], stdout=subprocess.PIPE, text=True)
    try:
        line = process.stdout.readline().strip()
        require(line.startswith('PORT='), 'four_modules_deploy_exactly_and_preserve_venv_models_settings_data')
        port = int(line.split('=')[1])

        def http(path, method='GET', body=b''):
            connection = HTTPConnection('127.0.0.1', port, timeout=8)
            try:
                connection.request(method, path, body=body, headers={'Content-Type': 'application/json'})
                response = connection.getresponse()
                data = response.read()
                return response.status, response.getheader('Content-Type'), data
            finally:
                connection.close()

        def api(path, method='GET', body=b''):
            code, mime, data = http(path, method, body)
            return code, json.loads(data) if mime.startswith('application/json') else data.decode()

        if not options.proxy_only:
            for page in ['/terminal/index.html', '/terminal/rag-settings.html']:
                code, mime, body = http(page)
                require(code == 200 and mime.startswith('text/html'), 'html_served_' + page)
                require(body == (root / 'assets' / page.lstrip('/')).read_bytes(), 'html_exact_' + page)
                document = LocalAssets()
                document.feed(body.decode())
                require(bool(document.assets), 'local_assets_present_' + page)
                if page.endswith('rag-settings.html'):
                    require(any(urlsplit(item).path.endswith('.js') for item in document.assets) and any(urlsplit(item).path.endswith('.css') for item in document.assets), 'settings_declares_script_and_stylesheet')
                for asset in document.assets:
                    target = urljoin(page, asset)
                    code, mime, body = http(target)
                    expected_mime = 'text/javascript' if urlsplit(target).path.endswith('.js') else 'text/css'
                    require(code == 200 and mime.startswith(expected_mime), 'asset_http_mime_' + target)
                    require(body == (root / 'assets' / urlsplit(target).path.lstrip('/')).read_bytes(), 'asset_exact_' + target)
        if not options.assets_only:
            for route in ['config', 'status', 'jobs']:
                before = len(requests)
                code, result = api('/control/rag/ingest/' + route)
                require(code == 200 and result['upstream_status'] == 200 and not result['preflight']['terminal_allowed'], 'get_' + route + '_available_with_closed_gate')
                require(any(item['method'] == 'GET' and item['path'] == '/ingest/' + route for item in requests[before:]), 'get_' + route + '_mapped_exactly')
            query = 'id=a%26b%3Dc%2Bd%252F&path=%E8%B3%87%E6%96%99%20%2B%25%23%3F&same=1&same=2'
            code, result = api('/control/rag/ingest/jobs?' + query)
            require(result['path'] == '/ingest/jobs?' + query, 'raw_query_encoding_and_repeated_fields_preserved')
            for target in ['/%63ontrol/rag/ingest/config', '/control/rag/ingest/%63onfig']:
                code, result = api(target)
                require(code == 200 and result['path'] == '/ingest/config', 'one_uri_decode_' + target)
            for target in ['/control/rag/ingest/%2563onfig', '/control/rag/ingest/jobs%3Fid=changed?id=original', '/control/rag/ingest/jobs%23fragment?id=original', '/control/rag/ingest/jobs%20suffix?id=original']:
                before = len(requests)
                code, result = api(target)
                require(code == 500 and not any(item['path'].startswith('/ingest/') for item in requests[before:]), 'encoded_path_does_not_change_dispatch_' + target)
            for target in ['/control/rag/ingest/status', '/control/rag/ingest/unknown']:
                before = len(requests)
                code, result = api(target, 'POST', b'{}')
                require(code == 500 and not any(item['path'].startswith('/ingest/') for item in requests[before:]), 'unsupported_post_not_forwarded_' + target)
            source = {'revision': 1, 'action': 'ingest', 'sources': [{'side': 'android', 'path': '/storage/emulated/0/資料 & #?% +/micro_skills_real.json', 'recursive': True}], 'department_ids': ['microskills', 'department-6']}
            payload = json.dumps(source, ensure_ascii=False, indent=1).encode()
            for route, status in [('config', 200), ('jobs', 202)]:
                behavior.update(code=status, body={'job': {'id': 'queued-1'}} if route == 'jobs' else {'revision': 2}, delay=0)
                before = len(requests)
                code, result = api('/control/rag/ingest/' + route + '?literal=%2B%25%3F', 'POST', payload)
                forwarded = [item for item in requests[before:] if item['path'].startswith('/ingest/')]
                require(code == 200 and result['upstream_status'] == status and len(forwarded) == 1, 'post_' + route + '_status_preserved')
                require(forwarded[0] == {'method': 'POST', 'path': '/ingest/' + route + '?literal=%2B%25%3F', 'body': payload}, 'post_' + route + '_utf8_body_and_query_byte_exact')
            for method, route, status in [('GET', 'jobs?id=missing', 404), ('GET', 'status', 500), ('POST', 'config', 409), ('POST', 'jobs', 400)]:
                behavior.update(code=status, body={'error': 'specific_error', 'detail': {'revision': 8}}, delay=0)
                code, result = api('/control/rag/ingest/' + route, method, b'{}' if method == 'POST' else b'')
                require(code == 200 and result['upstream_status'] == status and result['error'] == 'specific_error' and result['detail'] == {'revision': 8}, 'upstream_json_error_' + method + '_' + str(status))
            for status, body, expected in [(200, b'not-json', 502), (500, b'upstream-failed', 500), (404, b'', 404)]:
                behavior.update(code=status, body=body, delay=0)
                code, result = api('/control/rag/ingest/jobs?id=bad')
                require(code == 200 and result['upstream_status'] == expected and result['error'], 'invalid_or_empty_upstream_' + str(status))
            behavior.update(code=202, body={'job': {'id': 'delayed'}}, delay=1.4)
            code, result = api('/control/rag/ingest/jobs', 'POST', b'{}')
            require(code == 200 and result['upstream_status'] == 202, 'job_submission_exceeds_health_read_timeout')
            behavior.update(code=200, body={'job': {'id': 'delayed'}}, delay=1.4)
            code, result = api('/control/rag/ingest/jobs?id=delayed')
            require(code == 200 and result['upstream_status'] == 200, 'job_poll_exceeds_health_read_timeout')
            behavior.update(delay=0)
            behavior.update(code=200, body=None)
            before = len(requests)
            code, result = api('/control/rag/rag/status')
            require(code == 200 and result['upstream_status'] == 200 and not result['preflight']['terminal_allowed'], 'rag_status_available_with_closed_gate')
            require(any(item['method'] == 'GET' and item['path'] == '/rag/status' for item in requests[before:]), 'rag_status_mapped_exactly')
            query_payload = json.dumps({'query': 'Türkçe 資料 +%#?', 'department_ids': ['microskills'], 'record_id': 'record&?+1'}, ensure_ascii=False).encode()
            for route in ['search', 'route', 'route-and-retrieve', 'get']:
                before = len(requests)
                code, result = api('/control/rag/rag/' + route + '?literal=%2B%25%3F', 'POST', query_payload)
                forwarded = [item for item in requests[before:] if item['path'].startswith('/rag/')]
                require(code == 200 and result['upstream_status'] == 200 and not result['preflight']['terminal_allowed'], 'rag_' + route + '_available_with_closed_gate')
                require(forwarded == [{'method': 'POST', 'path': '/rag/' + route + '?literal=%2B%25%3F', 'body': query_payload}], 'rag_' + route + '_body_query_byte_exact')
            for route, method in [('get', 'GET'), ('search', 'GET'), ('route', 'GET'), ('route-and-retrieve', 'GET'), ('status', 'POST'), ('unknown', 'POST')]:
                before = len(requests)
                code, result = api('/control/rag/rag/' + route, method, b'{}' if method == 'POST' else b'')
                require(code == 500 and not any(item['path'].startswith('/rag/') for item in requests[before:]), 'rag_unsupported_method_' + route)
            for status in [400, 404, 409, 500, 503]:
                behavior.update(code=status, body={'error': 'query_error', 'detail': {'department_id': 'microskills'}})
                code, result = api('/control/rag/rag/search', 'POST', query_payload)
                require(code == 200 and result['upstream_status'] == status and result['error'] == 'query_error' and result['detail']['department_id'] == 'microskills', 'rag_error_status_' + str(status))
            behavior.update(code=200, body=b'not-json')
            code, result = api('/control/rag/rag/get', 'POST', query_payload)
            require(code == 200 and result['upstream_status'] == 502 and result['error'].startswith('rag_query_invalid_response:'), 'rag_invalid_json_explicit_failure')
            behavior.update(code=200, body={'results': []}, delay=1.4)
            code, result = api('/control/rag/rag/route-and-retrieve', 'POST', query_payload)
            require(code == 200 and result['upstream_status'] == 200 and result['results'] == [], 'rag_query_exceeds_health_read_timeout')
            behavior.update(delay=0)
            health.update(code=503, ready=True)
            time.sleep(.6)
            code, result = api('/control/rag/status')
            require(code == 200 and not result['ready'] and not result['preflight']['terminal_allowed'], 'health_503_ready_true_never_authorizes_terminal')
            code, result = api('/control/rag/events?after=27')
            require(result['path'] == '/events?after=27', 'existing_event_cursor_unchanged')
            for target in ['/control/rag/selftest', '/control/rag/models/e5/run']:
                code, result = api(target, 'POST', b'{}')
                require(code == 200 and result['upstream_status'] == 200, 'existing_post_route_' + target)
            upstream.shutdown()
            upstream.server_close()
            code, result = api('/control/rag/ingest/status')
            require(code == 200 and result['upstream_status'] == 502 and result['error'], 'upstream_unreachable_explicit_failure')
            code, result = api('/control/rag/rag/status')
            require(code == 200 and result['upstream_status'] == 502 and result['error'].startswith('rag_query_unreachable:'), 'rag_upstream_unreachable_explicit_failure')
    finally:
        process.terminate()
        try:
            process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait()
        if thread.is_alive():
            upstream.shutdown()
        upstream.server_close()

sources = [runtime / name for name in ['RagPreflight.java', 'SemanticRag.java', 'TerminalServer.java']]
sources += [root / 'tests/java/RagIngestionProxyTest.java', Path(__file__).resolve()]
report = {'schema': 'teec.ingestion-java-tests/1', 'status': 'passed', 'checks': checks, 'count': len(checks), 'sources': {str(path.relative_to(root)): hashlib.sha256(path.read_bytes()).hexdigest() for path in sources}, 'mode': 'assets_only' if options.assets_only else 'proxy_only' if options.proxy_only else 'complete', 'limitations': ['Uses controlled upstream HTTP responses; does not run ingestion or model inference.', 'No APK build, install, live service changes, or live owner setting mutation.']}
if options.evidence:
    options.evidence.parent.mkdir(parents=True, exist_ok=True)
    options.evidence.write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps({'status': 'passed', 'checks': len(checks), 'mode': report['mode']}))
