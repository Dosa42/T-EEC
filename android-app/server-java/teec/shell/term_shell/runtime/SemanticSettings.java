package teec.shell.term_shell.runtime;

import android.content.Context;
import java.io.IOException;

public final class SemanticSettings {
    private SemanticSettings() {}

    public static String request(Context context, String message) {
        boolean update = "Preflight1: true".equals(message) || "Preflight1: false".equals(message);
        if (!update && !"Settings started".equals(message)) return null;
        String error = "";
        if (update) {
            try {
                RagPreflight.setEnabled(context, "Preflight1: true".equals(message));
            } catch (IOException failure) {
                error = "Preflight 1 could not be saved. The previous setting is still active.";
            }
        }
        return "updateSetting('Preflight1: " + RagPreflight.isEnabled(context)
            + "');document.getElementById('preflight1Status').textContent='" + error + "';";
    }
}
