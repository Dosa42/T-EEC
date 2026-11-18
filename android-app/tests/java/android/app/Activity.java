package android.app;
import android.content.Context;
import java.io.File;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;
public class Activity extends Context {
    public int posted;
    public boolean destroyed;
    public final BlockingQueue<Runnable> uiTasks = new LinkedBlockingQueue<>();
    private final Context application;
    public Activity(File files, File assets, File libraries) {
        super(files, assets, libraries);
        application = new Context(files, assets, libraries);
    }
    @Override
    public Context getApplicationContext() { return application; }
    public void runOnUiThread(Runnable task) { posted++; uiTasks.add(task); }
    public boolean isFinishing() { return false; }
    public boolean isDestroyed() { return destroyed; }
}
