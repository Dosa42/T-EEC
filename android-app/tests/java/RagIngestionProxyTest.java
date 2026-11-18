import android.content.Context;
import teec.shell.term_shell.runtime.RagPreflight;
import teec.shell.term_shell.runtime.SemanticRag;
import teec.shell.term_shell.runtime.TerminalServer;
import java.io.File;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.concurrent.CountDownLatch;

public final class RagIngestionProxyTest {
    private static void require(boolean condition) {
        if (!condition) throw new AssertionError();
    }

    public static void main(String[] arguments) throws Exception {
        File directory = new File(arguments[0]);
        directory.mkdirs();
        File payload = new File(directory, "deployment-assets/t-eec");
        payload.mkdirs();
        File guest = new File(directory, "Ubuntu22.04Bare/opt/t-eec");
        for (String name : new String[]{"venv", "models", "data"}) Files.createDirectories(new File(guest, name).toPath());
        String[] modules = {"server.py", "model_runtime.py", "ingestion.py", "retrieval.py"};
        for (String name : modules) Files.write(new File(payload, name).toPath(), ("module = '" + name + "'\n").getBytes(StandardCharsets.UTF_8));
        String[] preserved = {"venv/pyvenv.cfg", "models/weights", "data/ingestion-settings.json", "data/collection"};
        for (String name : preserved) Files.write(new File(guest, name).toPath(), "preserve".getBytes(StandardCharsets.UTF_8));
        Context deployment = new Context(directory, payload.getParentFile(), directory);
        try (SemanticRag source = new SemanticRag(arguments[2])) {
            java.lang.reflect.Method deploy = SemanticRag.class.getDeclaredMethod("deploy", Context.class);
            deploy.setAccessible(true);
            deploy.invoke(source, deployment);
            for (String name : modules) require(java.util.Arrays.equals(Files.readAllBytes(new File(payload, name).toPath()), Files.readAllBytes(new File(guest, "app/" + name).toPath())));
            for (String name : preserved) require(new String(Files.readAllBytes(new File(guest, name).toPath()), StandardCharsets.UTF_8).equals("preserve"));
            require(new File(guest, "app").list().length == modules.length);
        }
        Context context = new Context(directory, new File(arguments[1]), directory);
        SemanticRag rag = new SemanticRag(arguments[2]);
        RagPreflight gate = new RagPreflight(context, rag);
        TerminalServer.Provider provider = new TerminalServer.Provider() {
            public TerminalServer.State current() { return new TerminalServer.State("", null, ""); }
            public TerminalServer.Admission admission() { return gate.check(); }
        };
        TerminalServer server = new TerminalServer(0, path -> Files.readAllBytes(Paths.get(arguments[1], path)), provider, null, gate::request);
        Runtime.getRuntime().addShutdownHook(new Thread(() -> { server.close(); rag.close(); }));
        System.out.println("PORT=" + server.port());
        System.out.flush();
        new CountDownLatch(1).await();
    }
}
