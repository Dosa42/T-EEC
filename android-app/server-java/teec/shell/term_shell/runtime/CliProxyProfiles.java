package teec.shell.term_shell.runtime;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.net.URI;
import java.nio.ByteBuffer;
import java.nio.charset.CharacterCodingException;
import java.nio.charset.CodingErrorAction;
import java.nio.charset.StandardCharsets;
import java.util.HashSet;
import java.util.Set;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

public final class CliProxyProfiles {
    private static final String ROUTE = "/control/cliproxy/profiles";
    private final File file;

    public CliProxyProfiles(File file) {
        this.file = file;
    }

    public String request(String method, String path, String body) throws IOException {
        String route;
        try { route = URI.create(path).getPath(); }
        catch (IllegalArgumentException failure) { throw new IOException("Ongeldige CLIProxy-profielroute"); }
        if (!"GET".equals(method) || route == null || !(route.equals(ROUTE) || route.startsWith(ROUTE + "/"))) {
            throw new IOException("Onbekende CLIProxy-profielopdracht");
        }
        try {
            JSONObject source = read();
            if (route.equals(ROUTE)) {
                JSONObject result = new JSONObject().put("configured", source != null).put("profiles", new JSONArray());
                if (source == null) return result.toString();
                result.put("base_url", source.getString("base_url")).put("upstream_provider", source.getString("upstream_provider"));
                JSONArray profiles = source.getJSONArray("profiles");
                JSONArray metadata = result.getJSONArray("profiles");
                for (int i = 0; i < profiles.length(); i++) {
                    JSONObject profile = profiles.getJSONObject(i);
                    metadata.put(new JSONObject().put("name", profile.getString("name")).put("endpoint", profile.getString("endpoint"))
                            .put("header", profile.getString("header")).put("has_key", !key(profile).isEmpty()));
                }
                return result.toString();
            }
            if (source == null) throw new IOException("CLIProxy-profielen zijn nog niet ingesteld");
            String name = route.substring(ROUTE.length() + 1);
            JSONArray profiles = source.getJSONArray("profiles");
            for (int i = 0; i < profiles.length(); i++) {
                JSONObject profile = profiles.getJSONObject(i);
                if (!name.equals(profile.getString("name"))) continue;
                String value = key(profile);
                if (value.isEmpty()) throw new IOException("Dit CLIProxy-profiel heeft geen API-sleutel");
                return new JSONObject().put("name", name).put("api_key", value).toString();
            }
            throw new IOException("CLIProxy-profiel niet gevonden");
        } catch (JSONException failure) {
            throw new IOException("CLIProxy-profielbestand heeft een ongeldige structuur");
        }
    }

    private JSONObject read() throws IOException, JSONException {
        if (!file.exists()) return null;
        byte[] bytes;
        try (FileInputStream input = new FileInputStream(file); ByteArrayOutputStream output = new ByteArrayOutputStream()) {
            byte[] buffer = new byte[8192];
            int count;
            while ((count = input.read(buffer)) != -1) output.write(buffer, 0, count);
            bytes = output.toByteArray();
        } catch (IOException failure) {
            throw new IOException("CLIProxy-profielbestand kon niet worden gelezen");
        }
        String text;
        try {
            text = StandardCharsets.UTF_8.newDecoder().onMalformedInput(CodingErrorAction.REPORT).onUnmappableCharacter(CodingErrorAction.REPORT)
                    .decode(ByteBuffer.wrap(bytes)).toString();
        } catch (CharacterCodingException failure) {
            throw new IOException("CLIProxy-profielbestand bevat ongeldige UTF-8");
        }
        JSONTokener tokens = new JSONTokener(text);
        Object value = tokens.nextValue();
        if (!(value instanceof JSONObject) || tokens.nextClean() != 0) throw new IOException("CLIProxy-profielbestand bevat ongeldige JSON");
        JSONObject source = (JSONObject) value;
        requiredString(source, "base_url");
        requiredString(source, "upstream_provider");
        if (!(source.opt("profiles") instanceof JSONArray)) throw new IOException("CLIProxy-profielbestand mist een geldige profielenlijst");
        JSONArray profiles = source.getJSONArray("profiles");
        Set<String> names = new HashSet<>();
        for (int i = 0; i < profiles.length(); i++) {
            if (!(profiles.opt(i) instanceof JSONObject)) throw new IOException("CLIProxy-profielbestand bevat een ongeldig profiel");
            JSONObject profile = profiles.getJSONObject(i);
            String name = requiredString(profile, "name");
            requiredString(profile, "endpoint");
            requiredString(profile, "header");
            if (name.isEmpty() || !names.add(name)) throw new IOException("CLIProxy-profielnamen moeten ingevuld en uniek zijn");
            Object secret = profile.opt("api_key");
            if (secret != null && secret != JSONObject.NULL && !(secret instanceof String)) throw new IOException("CLIProxy-profielbestand bevat een ongeldige API-sleutel");
        }
        return source;
    }

    private static String requiredString(JSONObject object, String name) throws IOException {
        Object value = object.opt(name);
        if (!(value instanceof String)) throw new IOException("CLIProxy-profielbestand bevat een ongeldig tekstveld");
        return (String) value;
    }

    private static String key(JSONObject profile) {
        Object value = profile.opt("api_key");
        return value instanceof String ? (String) value : "";
    }
}
