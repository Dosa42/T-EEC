import android.content.Context;
import teec.shell.term_shell.runtime.PtySession;
import teec.shell.term_shell.runtime.RagPreflight;
import teec.shell.term_shell.runtime.SemanticRag;
import teec.shell.term_shell.runtime.SemanticSettings;
import teec.shell.term_shell.runtime.TerminalServer;
import teec.shell.term_shell.runtime.TerminalSessions;
import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;
import org.json.JSONObject;

public final class RagPreflightTestMain {
    private static void require(boolean condition) {
        if (!condition) throw new AssertionError();
    }

    public static void main(String[] arguments) throws Exception {
        File directory = new File(arguments[0]);
        directory.mkdirs();
        Context context = new Context(directory, new File(arguments[1]), directory);
        Context other = new Context(directory, new File(arguments[1]), directory);
        if (arguments.length == 3) {
            try (SemanticRag live = new SemanticRag(arguments[2])) {
                RagPreflight liveGate = new RagPreflight(context, live);
                TerminalServer.Admission admission = liveGate.verify();
                require(admission.enabled && admission.terminalAllowed);
                System.out.println(admission.json());
            }
            return;
        }
        File payload = new File(directory, "deployment-assets/t-eec");
        payload.mkdirs();
        File guest = new File(directory, "Ubuntu22.04Bare/opt/t-eec");
        Files.createDirectories(new File(guest, "venv").toPath());
        Files.createDirectories(new File(guest, "models").toPath());
        Files.createDirectories(new File(guest, "data").toPath());
        for (String name : new String[]{"server.py", "model_runtime.py", "ingestion.py", "retrieval.py"}) Files.write(new File(payload, name).toPath(), "value = 1\n".getBytes(StandardCharsets.UTF_8));
        for (String name : new String[]{"venv/pyvenv.cfg", "models/weights", "data/collection"}) Files.write(new File(guest, name).toPath(), "preserve".getBytes(StandardCharsets.UTF_8));
        Context deployment = new Context(directory, payload.getParentFile(), directory);
        try (SemanticRag source = new SemanticRag(arguments[2])) {
            java.lang.reflect.Method deploy = SemanticRag.class.getDeclaredMethod("deploy", Context.class);
            deploy.setAccessible(true);
            deploy.invoke(source, deployment);
            for (String name : new String[]{"server.py", "model_runtime.py", "ingestion.py", "retrieval.py"}) require(new String(Files.readAllBytes(new File(guest, "app/" + name).toPath()), StandardCharsets.UTF_8).equals("value = 1\n"));
            for (String name : new String[]{"venv/pyvenv.cfg", "models/weights", "data/collection"}) require(new String(Files.readAllBytes(new File(guest, name).toPath()), StandardCharsets.UTF_8).equals("preserve"));
        }
        require(RagPreflight.isEnabled(context));
        require(SemanticSettings.request(context, "Settings started").contains("Preflight1: true"));
        require(SemanticSettings.request(context, "Unrelated") == null);
        require(SemanticSettings.request(context, "Preflight1: false").contains("Preflight1: false"));
        require(!RagPreflight.isEnabled(other));
        require(SemanticSettings.request(other, "Preflight1: true").contains("Preflight1: true"));
        Files.write(new File(directory, "rag-preflight-enabled").toPath(), "invalid".getBytes(StandardCharsets.UTF_8));
        require(RagPreflight.isEnabled(context));
        File invalid = new File(directory, "invalid-directory");
        Files.write(invalid.toPath(), new byte[0]);
        Context failure = new Context(invalid, directory, directory);
        String failed = SemanticSettings.request(failure, "Preflight1: false");
        require(failed.contains("could not be saved") && failed.contains("Preflight1: true"));
        require(!RagPreflight.evaluate(true, new JSONObject("{\"ready\":\"true\"}")).terminalAllowed);
        SemanticRag rag = new SemanticRag(arguments[2]);
        RagPreflight gate = new RagPreflight(context, rag);
        Map<String, String> environment = new HashMap<>(System.getenv());
        environment.remove("LD_PRELOAD");
        environment.put("PS1", "RAG_PROMPT> ");
        environment.put("TERM", "xterm-256color");
        String[] values = environment.entrySet().stream().map(entry -> entry.getKey() + "=" + entry.getValue()).toArray(String[]::new);
        TerminalSessions sessions = new TerminalSessions((id, listener) -> new PtySession(new String[]{arguments[3], "--noprofile", "--norc", "-i"}, values, "/", 24, 80, listener), null, gate);
        try { sessions.create(); throw new AssertionError("Initial creation bypassed gate"); }
        catch (java.io.IOException expected) { require(expected.getMessage().startsWith("Preflight1:")); }
        TerminalServer server = new TerminalServer(0, path -> Files.readAllBytes(Paths.get(arguments[1], path)), sessions, null, gate::request);
        Runtime.getRuntime().addShutdownHook(new Thread(() -> { server.close(); sessions.close(); rag.close(); }));
        System.out.println("PORT=" + server.port());
        System.out.flush();
        try (BufferedReader input = new BufferedReader(new InputStreamReader(System.in, StandardCharsets.UTF_8))) {
            String line;
            while ((line = input.readLine()) != null) {
                System.out.println("SETTING=" + SemanticSettings.request(context, line));
                System.out.flush();
            }
        }
    }
}
