package teec.shell.term_shell.runtime;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;

public final class FrontendAssets implements TerminalServer.Assets {
    private final File directory;
    private final TerminalServer.Assets packaged;

    public FrontendAssets(File directory, TerminalServer.Assets packaged) {
        this.directory = directory;
        this.packaged = packaged;
    }

    @Override
    public byte[] read(String path) throws IOException {
        if (!path.startsWith("terminal/") || !TerminalServer.terminalAssetName(path.substring(9))) throw new FileNotFoundException("Not found");
        File file = new File(directory, path.substring(9));
        if (!file.exists()) return packaged.read(path);
        if (!file.isFile()) throw new FileNotFoundException("Not found");
        try (FileInputStream input = new FileInputStream(file); ByteArrayOutputStream output = new ByteArrayOutputStream()) {
            byte[] buffer = new byte[16384];
            int count;
            while ((count = input.read(buffer)) != -1) output.write(buffer, 0, count);
            return output.toByteArray();
        }
    }
}
