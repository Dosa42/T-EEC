package teec.shell.term_shell.runtime;

import android.content.Context;
import java.io.ByteArrayOutputStream;
import java.io.Closeable;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import org.json.JSONObject;

public final class SemanticRag implements Closeable {
    public static final int PORT = 8867;
    private final String base;
    private final ScheduledExecutorService worker = Executors.newSingleThreadScheduledExecutor(task -> {
        Thread thread = new Thread(task, "T-EEC-rag");
        thread.setDaemon(true);
        return thread;
    });
    private volatile boolean closed;
    private boolean started;
    private volatile Process process;
    private volatile String lifecycleError = "";
    private JSONObject cached;
    private long checked;
    private long nextStart;

    public SemanticRag() { this("http://127.0.0.1:" + PORT); }

    public SemanticRag(String base) { this.base = base; }

    public synchronized JSONObject refreshStatus() {
        checked = 0;
        return status();
    }

    public synchronized JSONObject status() {
        long now = System.nanoTime();
        if (cached == null || now - checked >= TimeUnit.MILLISECONDS.toNanos(500)) {
            try { cached = fetch("/health/status"); }
            catch (Exception failure) {
                cached = failure("rag_unreachable: " + failure.getMessage() + (lifecycleError.isEmpty() ? "" : "; " + lifecycleError));
            }
            checked = System.nanoTime();
        }
        try { return new JSONObject(cached.toString()); }
        catch (Exception failure) { return failure("rag_invalid_status"); }
    }

    public JSONObject events(String query) {
        try { return fetch("/events" + query); }
        catch (Exception failure) {
            JSONObject result = failure("rag_events_unreachable: " + failure.getMessage());
            try { result.put("events", new org.json.JSONArray()); result.put("cursor", 0); result.put("snapshot", status()); }
            catch (Exception ignored) {}
            return result;
        }
    }

    public JSONObject run(String path, String body) {
        try {
            JSONObject result = exchange(path, "POST", body);
            synchronized (this) { checked = 0; }
            return result;
        } catch (Exception failure) { return failure("rag_operation_failed: " + failure.getMessage()); }
    }

    public JSONObject ingest(String path, String method, String body) {
        return proxy(path, method, body, "ingest");
    }

    public JSONObject query(String path, String method, String body) {
        return proxy(path, method, body, "query");
    }

    private JSONObject proxy(String path, String method, String body, String operation) {
        try { return exchange(path, method, body, operation); }
        catch (Exception failure) {
            JSONObject result = failure("rag_" + operation + "_unreachable: " + failure.getMessage());
            try { result.put("upstream_status", 502); }
            catch (Exception ignored) {}
            return result;
        }
    }

    private JSONObject fetch(String path) throws Exception { return exchange(path, "GET", ""); }

    private JSONObject exchange(String path, String method, String body) throws Exception {
        return exchange(path, method, body, null);
    }

    private JSONObject exchange(String path, String method, String body, String operation) throws Exception {
        HttpURLConnection connection = (HttpURLConnection) new URL(base + path).openConnection();
        connection.setConnectTimeout(800);
        connection.setReadTimeout(operation != null ? 0 : 1200);
        connection.setUseCaches(false);
        connection.setRequestMethod(method);
        try {
            if (method.equals("POST")) {
                connection.setReadTimeout(0);
                connection.setDoOutput(true);
                connection.setRequestProperty("Content-Type", "application/json");
                byte[] bytes = body.getBytes(StandardCharsets.UTF_8);
                connection.setFixedLengthStreamingMode(bytes.length);
                try (java.io.OutputStream output = connection.getOutputStream()) { output.write(bytes); }
            }
            int code = connection.getResponseCode();
            if (operation == null && method.equals("GET") && code != 200) throw new IOException("HTTP " + code);
            try (InputStream input = code >= 400 ? connection.getErrorStream() : connection.getInputStream(); ByteArrayOutputStream output = new ByteArrayOutputStream()) {
                byte[] buffer = new byte[8192];
                int count;
                while (input != null && (count = input.read(buffer)) != -1) output.write(buffer, 0, count);
                JSONObject result;
                try { result = new JSONObject(new String(output.toByteArray(), StandardCharsets.UTF_8)); }
                catch (org.json.JSONException failure) {
                    if (operation == null) throw failure;
                    result = failure("rag_" + operation + "_invalid_response: HTTP " + code);
                    if (code < 400) code = 502;
                }
                if (operation != null || method.equals("POST")) result.put("upstream_status", code);
                return result;
            }
        } finally { connection.disconnect(); }
    }

    private static JSONObject failure(String reason) {
        JSONObject result = new JSONObject();
        try { result.put("ready", false); result.put("error", reason); }
        catch (Exception ignored) {}
        return result;
    }

    public synchronized void start(Context context, ProotCommand proot) {
        if (started || closed) return;
        started = true;
        Context application = context.getApplicationContext();
        worker.execute(() -> {
            try { deploy(application); }
            catch (Exception failure) { lifecycleError = "rag_deploy_failed: " + failure.getMessage(); }
        });
        worker.scheduleWithFixedDelay(() -> maintain(application, proot), 0, 2, TimeUnit.SECONDS);
    }

    private void deploy(Context context) throws IOException {
        File directory = new File(context.getFilesDir(), UbuntuImage.NAME + "/opt/t-eec/app");
        if (!directory.isDirectory() && !directory.mkdirs()) throw new IOException("RAG-appmap ontbreekt");
        for (String name : new String[]{"server.py", "model_runtime.py", "ingestion.py", "retrieval.py"}) {
            File temporary = File.createTempFile(".deploy-", ".tmp", directory);
            try {
                try (InputStream input = context.getAssets().open("t-eec/" + name); FileOutputStream output = new FileOutputStream(temporary)) {
                    byte[] buffer = new byte[16384];
                    int count;
                    while ((count = input.read(buffer)) != -1) output.write(buffer, 0, count);
                    output.getFD().sync();
                }
                if (!temporary.renameTo(new File(directory, name))) throw new IOException("RAG-bron kon niet worden geplaatst: " + name);
            } finally { temporary.delete(); }
        }
    }

    private void maintain(Context context, ProotCommand proot) {
        if (closed) return;
        Process running = process;
        if (running != null) {
            try { running.exitValue(); process = null; }
            catch (IllegalThreadStateException active) { return; }
        }
        if (System.nanoTime() < nextStart) return;
        nextStart = System.nanoTime() + TimeUnit.SECONDS.toNanos(10);
        try { fetch("/health/status"); return; }
        catch (Exception unavailable) {}
        try {
            File python = new File(context.getFilesDir(), UbuntuImage.NAME + "/opt/t-eec/venv/pyvenv.cfg");
            if (!python.isFile()) throw new IOException("RAG Python-omgeving ontbreekt");
            Process launched = proot.process("/opt/t-eec/venv/bin/python", "/opt/t-eec/app/server.py", "--host", "0.0.0.0", "--port", Integer.toString(PORT));
            process = launched;
            drain(launched.getInputStream());
            drain(launched.getErrorStream());
            launched.getOutputStream().close();
            lifecycleError = "";
            if (closed) launched.destroy();
        } catch (Exception failure) { lifecycleError = "rag_start_failed: " + failure.getMessage(); }
    }

    private void drain(InputStream input) {
        Thread thread = new Thread(() -> {
            try (InputStream stream = input) {
                byte[] buffer = new byte[8192];
                while (stream.read(buffer) != -1) {}
            } catch (IOException ignored) {}
        }, "T-EEC-rag-output");
        thread.setDaemon(true);
        thread.start();
    }

    @Override
    public void close() {
        closed = true;
        worker.shutdownNow();
        Process running = process;
        if (running != null) running.destroy();
    }
}
