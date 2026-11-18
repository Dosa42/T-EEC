package teec.shell.term_shell.runtime;

import java.net.URLEncoder;
import java.nio.ByteBuffer;
import java.nio.charset.CharacterCodingException;
import java.nio.charset.CodingErrorAction;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

public final class McpEndpoint {
    private static final String LATEST = "2025-11-25";
    private static final List<String> VERSIONS = Arrays.asList(LATEST, "2025-06-18");
    private final TerminalServer.Control control;

    public static final class Reply {
        public final int status;
        public final byte[] body;
        public final String headers;
        Reply(int status, String body, String headers) {
            this.status = status;
            this.body = body.getBytes(StandardCharsets.UTF_8);
            this.headers = headers;
        }
    }

    private static final class ProtocolFailure extends Exception {
        final int code;
        ProtocolFailure(int code, String message) { super(message); this.code = code; }
    }

    public McpEndpoint(TerminalServer.Control control) { this.control = control; }

    public Reply handle(String method, Map<String, String> headers, byte[] body) {
        String version = headers.getOrDefault("mcp-protocol-version", "2025-03-26");
        if (!method.equals("POST")) return new Reply(405, "", "Allow: POST\r\n");
        if (headers.containsKey("mcp-protocol-version") && !VERSIONS.contains(version)) return error(400, JSONObject.NULL, -32600, "Unsupported MCP-Protocol-Version", "");
        String responseHeaders = VERSIONS.contains(version) ? "MCP-Protocol-Version: " + version + "\r\n" : "";
        String contentType = headers.getOrDefault("content-type", "").split(";", 2)[0].trim();
        if (!contentType.equalsIgnoreCase("application/json")) return error(415, JSONObject.NULL, -32600, "Content-Type must be application/json", responseHeaders);
        if (!acceptsJson(headers.getOrDefault("accept", ""))) return error(406, JSONObject.NULL, -32600, "Accept must include application/json", responseHeaders);
        JSONObject request;
        try {
            String text = StandardCharsets.UTF_8.newDecoder().onMalformedInput(CodingErrorAction.REPORT).onUnmappableCharacter(CodingErrorAction.REPORT).decode(ByteBuffer.wrap(body)).toString();
            new JsonSyntax(text).check();
            Object decoded = new JSONTokener(text).nextValue();
            if (!(decoded instanceof JSONObject)) return error(400, JSONObject.NULL, -32600, "A single JSON-RPC object is required", responseHeaders);
            request = (JSONObject) decoded;
        } catch (JSONException | CharacterCodingException failure) {
            return error(400, JSONObject.NULL, -32700, "Invalid JSON: " + failure.getMessage(), responseHeaders);
        }
        Object id = request.opt("id");
        boolean hasId = request.has("id");
        if (!"2.0".equals(request.opt("jsonrpc")) || (hasId && !(id instanceof String || id instanceof Integer || id instanceof Long))) return error(400, JSONObject.NULL, -32600, "Invalid JSON-RPC envelope", responseHeaders);
        if (!VERSIONS.contains(version) && !"initialize".equals(request.opt("method"))) return error(400, hasId ? id : JSONObject.NULL, -32600, "MCP-Protocol-Version must be 2025-11-25 or 2025-06-18", responseHeaders);
        if (!request.has("method")) {
            if (hasId && request.has("result") != request.has("error")) return new Reply(202, "", responseHeaders);
            return error(400, hasId ? id : JSONObject.NULL, -32600, "JSON-RPC method is required", responseHeaders);
        }
        if (!(request.opt("method") instanceof String) || request.has("result") || request.has("error")) return error(400, hasId ? id : JSONObject.NULL, -32600, "Invalid JSON-RPC request", responseHeaders);
        if (request.has("params") && !(request.opt("params") instanceof JSONObject)) return error(hasId ? 200 : 400, hasId ? id : JSONObject.NULL, -32602, "params must be an object", responseHeaders);
        if (!hasId) return new Reply(202, "", responseHeaders);
        JSONObject params = request.optJSONObject("params");
        if (params == null) params = new JSONObject();
        String name = request.optString("method");
        try {
            JSONObject result;
            if (name.equals("initialize")) {
                String requested = string(params, "protocolVersion");
                object(params, "capabilities");
                JSONObject client = object(params, "clientInfo");
                string(client, "name"); string(client, "version");
                version = VERSIONS.contains(requested) ? requested : LATEST;
                responseHeaders = "MCP-Protocol-Version: " + version + "\r\n";
                result = new JSONObject().put("protocolVersion", version)
                        .put("capabilities", new JSONObject().put("tools", new JSONObject().put("listChanged", false)))
                        .put("serverInfo", new JSONObject().put("name", "teec-machine-engine").put("version", "1.0.0"))
                        .put("instructions", "Submit explicit argv with a unique order id, then fetch that id with engine_order. Reusing an id does not execute again. Interrupted orders are never replayed.");
            } else if (name.equals("ping")) result = new JSONObject();
            else if (name.equals("tools/list")) {
                if (params.has("cursor")) throw new ProtocolFailure(-32602, "This fixed tool list has no pagination cursor");
                result = new JSONObject().put("tools", tools());
            } else if (name.equals("tools/call")) result = call(params);
            else throw new ProtocolFailure(-32601, "Method not found: " + name);
            return new Reply(200, new JSONObject().put("jsonrpc", "2.0").put("id", id).put("result", result).toString(), responseHeaders);
        } catch (ProtocolFailure failure) {
            return error(200, id, failure.code, failure.getMessage(), responseHeaders);
        } catch (Exception failure) {
            return error(200, id, -32603, failure.toString(), responseHeaders);
        }
    }

    private JSONObject call(JSONObject params) throws Exception {
        String name = string(params, "name");
        if (!Arrays.asList("engine_status", "engine_submit", "engine_order").contains(name)) throw new ProtocolFailure(-32602, "Unknown tool: " + name);
        JSONObject args = params.has("arguments") ? object(params, "arguments") : new JSONObject();
        try {
            String method = "GET";
            String path;
            String body = "";
            if (name.equals("engine_status")) {
                keys(args);
                path = "/control/summary";
            } else if (name.equals("engine_order")) {
                keys(args, "id");
                path = "/control/orders/" + encode(string(args, "id")).replace("+", "%20");
            } else {
                keys(args, "id", "source", "cwd", "argv");
                String id = string(args, "id");
                String source = string(args, "source");
                String cwd = string(args, "cwd");
                if (!cwd.startsWith("/")) throw new ProtocolFailure(-32602, "cwd must be absolute");
                if (!(args.opt("argv") instanceof JSONArray)) throw new ProtocolFailure(-32602, "argv must be an array of strings");
                JSONArray argv = args.getJSONArray("argv");
                if (argv.length() == 0) throw new ProtocolFailure(-32602, "argv must not be empty");
                StringBuilder form = new StringBuilder("id=").append(encode(id)).append("&source=").append(encode(source)).append("&cwd=").append(encode(cwd));
                for (int i = 0; i < argv.length(); i++) {
                    if (!(argv.get(i) instanceof String) || (i == 0 && argv.getString(i).isEmpty())) throw new ProtocolFailure(-32602, "argv must contain strings and a nonempty executable");
                    form.append("&arg=").append(encode(argv.getString(i)));
                }
                method = "POST"; path = "/control/orders"; body = form.toString();
            }
            if (control == null) throw new IllegalStateException("Machine engine is unavailable");
            return toolResult(new JSONObject(control.request(method, path, body)), false);
        } catch (Exception failure) {
            return toolResult(new JSONObject().put("error", failure.getMessage() == null ? failure.toString() : failure.getMessage()), true);
        }
    }

    private static JSONObject toolResult(JSONObject data, boolean failed) throws JSONException {
        return new JSONObject().put("content", new JSONArray().put(new JSONObject().put("type", "text").put("text", data.toString())))
                .put("structuredContent", data).put("isError", failed);
    }

    private static JSONArray tools() throws JSONException {
        JSONObject empty = new JSONObject().put("type", "object").put("properties", new JSONObject()).put("additionalProperties", false);
        JSONObject id = new JSONObject().put("type", "string").put("minLength", 1);
        JSONObject lookup = new JSONObject().put("type", "object").put("properties", new JSONObject().put("id", id)).put("required", new JSONArray().put("id")).put("additionalProperties", false);
        JSONObject submit = new JSONObject().put("type", "object").put("properties", new JSONObject().put("id", id).put("source", id)
                .put("cwd", new JSONObject().put("type", "string").put("pattern", "^/"))
                .put("argv", new JSONObject().put("type", "array").put("items", new JSONObject().put("type", "string")).put("minItems", 1)))
                .put("required", new JSONArray().put("id").put("source").put("cwd").put("argv")).put("additionalProperties", false);
        return new JSONArray()
                .put(tool("engine_status", "Read compact executor metadata and order counts without loading output history.", empty, true))
                .put(tool("engine_submit", "Persist and start one Ubuntu order using exact argv and absolute cwd. Use a unique id; duplicate ids fail without another execution. Shell syntax requires explicit /bin/bash -c arguments.", submit, false))
                .put(tool("engine_order", "Read one persisted order by id, including status, exit, stdout and stderr. Other orders' output is not read.", lookup, true));
    }

    private static JSONObject tool(String name, String description, JSONObject schema, boolean readOnly) throws JSONException {
        return new JSONObject().put("name", name).put("description", description).put("inputSchema", schema)
                .put("annotations", new JSONObject().put("readOnlyHint", readOnly).put("destructiveHint", !readOnly).put("idempotentHint", true).put("openWorldHint", !readOnly));
    }

    private static void keys(JSONObject value, String... allowed) throws ProtocolFailure {
        Iterator<String> iterator = value.keys();
        while (iterator.hasNext()) {
            String key = iterator.next();
            if (!Arrays.asList(allowed).contains(key)) throw new ProtocolFailure(-32602, "Unexpected argument: " + key);
        }
    }

    private static JSONObject object(JSONObject value, String key) throws ProtocolFailure {
        Object object = value.opt(key);
        if (!(object instanceof JSONObject)) throw new ProtocolFailure(-32602, key + " must be an object");
        return (JSONObject) object;
    }

    private static String string(JSONObject value, String key) throws ProtocolFailure {
        Object text = value.opt(key);
        if (!(text instanceof String) || ((String) text).isEmpty()) throw new ProtocolFailure(-32602, key + " must be a nonempty string");
        return (String) text;
    }

    private static String encode(String value) throws java.io.UnsupportedEncodingException { return URLEncoder.encode(value, "UTF-8"); }

    private static boolean acceptsJson(String accept) {
        for (String item : accept.split(",")) {
            String[] parts = item.trim().split(";");
            if (parts[0].trim().equalsIgnoreCase("application/json")) {
                boolean enabled = true;
                for (int i = 1; i < parts.length; i++) if (parts[i].trim().matches("(?i)q\\s*=\\s*0(?:\\.0*)?")) enabled = false;
                if (enabled) return true;
            }
        }
        return false;
    }

    public static Reply badTransport(String message) { return error(400, JSONObject.NULL, -32600, message, ""); }

    private static Reply error(int status, Object id, int code, String message, String headers) {
        try {
            JSONObject result = new JSONObject().put("jsonrpc", "2.0")
                    .put("error", new JSONObject().put("code", code).put("message", message == null ? "Invalid request" : message));
            if (id != null && id != JSONObject.NULL) result.put("id", id);
            return new Reply(status, result.toString(), headers);
        } catch (JSONException failure) { throw new IllegalStateException(failure); }
    }

    private static final class JsonSyntax {
        private final String text;
        private int offset;
        JsonSyntax(String text) { this.text = text; }
        void check() throws JSONException {
            value(); whitespace();
            if (offset != text.length()) invalid();
        }
        private void value() throws JSONException {
            whitespace();
            char next = peek();
            if (next == '{' || next == '[') {
                offset++;
                char end = next == '{' ? '}' : ']';
                whitespace();
                if (peek() == end) { offset++; return; }
                while (true) {
                    if (next == '{') { string(); whitespace(); if (peek() != ':') invalid(); offset++; }
                    value(); whitespace();
                    if (peek() == end) { offset++; return; }
                    if (peek() != ',') invalid();
                    offset++; whitespace();
                }
            } else if (next == '"') string();
            else if (next == 't') literal("true");
            else if (next == 'f') literal("false");
            else if (next == 'n') literal("null");
            else {
                if (next == '-') offset++;
                if (peek() == '0') offset++;
                else { if (peek() < '1' || peek() > '9') invalid(); digits(); }
                if (peek() == '.') { offset++; if (!digit()) invalid(); digits(); }
                if (peek() == 'e' || peek() == 'E') { offset++; if (peek() == '+' || peek() == '-') offset++; if (!digit()) invalid(); digits(); }
            }
        }
        private void string() throws JSONException {
            if (peek() != '"') invalid();
            offset++;
            while (offset < text.length()) {
                char next = text.charAt(offset++);
                if (next == '"') return;
                if (next < 32) invalid();
                if (next == '\\') {
                    if (offset == text.length()) invalid();
                    char escape = text.charAt(offset++);
                    if (escape == 'u') {
                        for (int i = 0; i < 4; i++) {
                            if (offset == text.length() || "0123456789abcdefABCDEF".indexOf(text.charAt(offset++)) < 0) invalid();
                        }
                    } else if ("\"\\/bfnrt".indexOf(escape) < 0) invalid();
                }
            }
            invalid();
        }
        private void literal(String value) throws JSONException {
            if (!text.startsWith(value, offset)) invalid();
            offset += value.length();
        }
        private void whitespace() { while (offset < text.length() && " \t\r\n".indexOf(text.charAt(offset)) >= 0) offset++; }
        private char peek() { return offset < text.length() ? text.charAt(offset) : '\0'; }
        private boolean digit() { return peek() >= '0' && peek() <= '9'; }
        private void digits() { while (digit()) offset++; }
        private void invalid() throws JSONException { throw new JSONException("Invalid JSON syntax at " + offset); }
    }
}
