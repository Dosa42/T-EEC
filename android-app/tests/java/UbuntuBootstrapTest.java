import teec.shell.term_shell.runtime.UbuntuImage;
import teec.shell.term_shell.runtime.UbuntuRootfs;
import teec.shell.term_shell.runtime.UbuntuRuntime;
import android.app.Activity;
import java.io.File;
import java.util.concurrent.TimeUnit;
public class UbuntuBootstrapTest {
    public static void main(String[] arguments) throws Exception {
        Activity activity = new Activity(new File(arguments[0]), new File(arguments[1]), new File(arguments[2]));
        q1.f scene = new q1.f();
        if (UbuntuRootfs.ensureInstalled(activity, scene)) { throw new AssertionError("First click did not schedule installation"); }
        for (int i = 0; i < 20; i++) { UbuntuRootfs.ensureInstalled(activity, scene); }
        activity.destroyed = true;
        Runnable resume = activity.uiTasks.poll(60, TimeUnit.SECONDS);
        if (resume == null) { throw new AssertionError("Installation never queued its completion callback"); }
        if (UbuntuRuntime.starts != 0 || !UbuntuImage.ready(activity.files)) {
            throw new AssertionError("Installation was not ready before its queued completion callback");
        }
        resume.run();
        if (UbuntuRuntime.starts != 1) { throw new AssertionError("Destroyed Activity prevented installed Ubuntu from starting"); }
        if (UbuntuRuntime.lastContext != activity.getApplicationContext() || UbuntuRuntime.lastContext == activity) {
            throw new AssertionError("Runtime did not start with the application context");
        }
        if (UbuntuRuntime.starts != 1 || activity.posted != 1 || !UbuntuImage.ready(activity.files)) {
            throw new AssertionError("Installation did not resume exactly once");
        }
        if (!UbuntuRootfs.ensureInstalled(activity, scene) || UbuntuRuntime.starts != 1) {
            throw new AssertionError("Second click scheduled another installation");
        }
        System.out.println("Ubuntu bootstrap integration passed: first-click async installation, destroyed Activity, one application-context runtime start, retained readiness, warm start");
    }
}
