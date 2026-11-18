package teec.shell.term_shell.runtime;

import android.content.Context;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import org.json.JSONObject;

public final class RagPreflight implements TerminalServer.Preflight {
    public static final boolean DEFAULT_ENABLED = true;
    private static final String SETTING = "rag-preflight-enabled";
    private final Context context;
    private final SemanticRag rag;

    public RagPreflight(Context context, SemanticRag rag) {
        this.context = context.getApplicationContext();
        this.rag = rag;
    }

    public static boolean isEnabled(Context context) {
        File setting = new File(context.getFilesDir(), SETTING);
        try (FileInputStream input = new FileInputStream(setting)) {
            byte[] bytes = new byte[6];
            int count = input.read(bytes);
            if (count == 5 && input.read() == -1 && "false".equals(new String(bytes, 0, count, StandardCharsets.US_ASCII))) return false;
            return DEFAULT_ENABLED;
        } catch (IOException failure) { return DEFAULT_ENABLED; }
    }

    public static void setEnabled(Context context, boolean enabled) throws IOException {
        File directory = context.getFilesDir();
        File temporary = File.createTempFile("rag-preflight-", ".tmp", directory);
        try {
            try (FileOutputStream output = new FileOutputStream(temporary)) {
                output.write(Boolean.toString(enabled).getBytes(StandardCharsets.US_ASCII));
                output.getFD().sync();
            }
            if (!temporary.renameTo(new File(directory, SETTING))) throw new IOException("Preflight1-instelling kon niet worden opgeslagen");
        } finally { temporary.delete(); }
    }

    @Override
    public TerminalServer.Admission check() {
        if (!isEnabled(context)) return new TerminalServer.Admission(false, true, "owner_debug_bypass");
        return evaluate(true, rag.status());
    }

    @Override
    public TerminalServer.Admission verify() {
        if (!isEnabled(context)) return new TerminalServer.Admission(false, true, "owner_debug_bypass");
        return evaluate(true, rag.refreshStatus());
    }

    public static TerminalServer.Admission evaluate(boolean enabled, JSONObject snapshot) {
        if (!enabled) return new TerminalServer.Admission(false, true, "owner_debug_bypass");
        boolean ready = Boolean.TRUE.equals(snapshot.opt("ready"));
        String reason = ready ? "rag_ready" : snapshot.optString("error", "");
        if (reason.isEmpty()) reason = snapshot.optString("reason", "");
        if (reason.isEmpty()) reason = "rag_not_ready";
        return new TerminalServer.Admission(true, ready, reason);
    }

    public String request(String method, String path, String body) throws Exception {
        java.net.URI uri = java.net.URI.create(path);
        String route = uri.getPath();
        JSONObject result;
        if ((method.equals("GET") || method.equals("HEAD")) && route.equals("/control/rag/status")) result = rag.status();
        else if ((method.equals("GET") || method.equals("HEAD")) && route.equals("/control/rag/events")) result = rag.events(uri.getRawQuery() == null ? "" : "?" + uri.getRawQuery());
        else if (route.equals("/control/rag/ingest/config") && (method.equals("GET") || method.equals("POST"))
                || route.equals("/control/rag/ingest/status") && method.equals("GET")
                || route.equals("/control/rag/ingest/jobs") && (method.equals("GET") || method.equals("POST"))) {
            result = rag.ingest(route.substring("/control/rag".length()) + (uri.getRawQuery() == null ? "" : "?" + uri.getRawQuery()), method, body);
        }
        else if (route.equals("/control/rag/rag/status") && method.equals("GET")
                || method.equals("POST") && (route.equals("/control/rag/rag/search") || route.equals("/control/rag/rag/route") || route.equals("/control/rag/rag/route-and-retrieve") || route.equals("/control/rag/rag/get"))) {
            result = rag.query(route.substring("/control/rag".length()) + (uri.getRawQuery() == null ? "" : "?" + uri.getRawQuery()), method, body);
        }
        else if (method.equals("POST") && (route.equals("/control/rag/selftest") || route.matches("/control/rag/models/[^/]+/run"))) result = rag.run(route.substring("/control/rag".length()), body);
        else throw new IOException("Onbekende RAG-opdracht");
        TerminalServer.Admission admission = route.equals("/control/rag/status") ? evaluate(isEnabled(context), result) : check();
        result.put("preflight", new JSONObject(admission.json()));
        return result.toString();
    }
}
