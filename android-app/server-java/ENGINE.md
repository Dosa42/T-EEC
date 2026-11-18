Source contract for T-EEC. Current state: [project handoff](../../README.md).

# Machine-engine protocol

The browser keeps interactive Bash, machine output and file operations separate. The machine view has no composer or user input field. Codex submits explicit commands over the runtime HTTP API on port 8866. Each order runs in an independent Ubuntu PRoot process. This executor does not invoke Codex CLI, Claude CLI or an LLM.

## Orders

POST `/control/orders` with `application/x-www-form-urlencoded` fields:

| Field | Value |
| --- | --- |
| id | Caller-chosen unique order identifier |
| source | Caller attribution, for example `codex` |
| cwd | Absolute Ubuntu working directory |
| arg | Repeated field, one exact argument per occurrence |

Arguments are passed as an argv array, without shell interpretation. To execute shell syntax, explicitly supply `/bin/bash`, `-c` and the script as separate arguments. Standard input is closed. stdout and stderr are recorded separately. The response contains the accepted order. Reusing an ID reports an error and does not execute another command.

GET `/control/status` or `/control/orders` returns schema `teec.engine/1`, settings and order history. Order states are `queued`, `running`, `done`, `failed` or `interrupted`. Times are epoch milliseconds; exit is the process exit code when available. Output is actual captured text. Clicking an order in the browser selects its output without submitting commands.

GET `/control/summary` returns compact executor metadata, counts by state and the latest order's identity without reading captured output. GET `/control/orders/<percent-encoded-id>` reads one order, including its output, without loading other orders' output.

POST `/control/checklist` with `id` and `state=pending|true|false` records the caller's machine checklist result. Command success and caller verification remain separate fields; the engine does not invent verification results.

## Persistence

Records, stdout, stderr and settings live in the Android app's private `files/ubuntu-engine` directory, outside the Ubuntu image. Each record is saved through a synchronized temporary file and rename. Completed history survives service restarts and APK updates that preserve app data. Orders interrupted by service/process death are marked `interrupted` on recovery. No previous command is replayed on recovery.

GET `/control/settings` reads metadata. POST to the same path accepts `mode`, `model`, `reasoning`, `skills`, `hooks` and `instructions`. These are persistent descriptors for the later harness. Saving them does not load an AI adapter or execute hooks. The only current execution mechanism is explicit argv. API errors use an HTTP error response with a text reason.

## MCP endpoint

The same wildcard HTTP listener serves JSON-response Streamable HTTP at `/mcp`, for example `http://192.168.1.58:8866/mcp` from the phone's current LAN. The address is an example; the listener stays on `0.0.0.0` and shares the existing HTTP, WebSocket, file and command routes.

POST one UTF-8 JSON-RPC object with `Content-Type: application/json` and `Accept: application/json, text/event-stream`. Both Content-Length and chunked request bodies are supported. `initialize` negotiates `2025-11-25` or `2025-06-18`; unsupported requested versions receive the latest supported version. Initialization does not require a version header. Subsequent requests carry the negotiated `MCP-Protocol-Version`; unsupported versions receive HTTP 400. A missing follow-up header implies the older, unsupported `2025-03-26` version and also receives HTTP 400.

The server advertises only the fixed tools capability. It issues no MCP session token, requires no SSE connection, and returns HTTP 405 with `Allow: POST` for GET at `/mcp`. `notifications/initialized` and other accepted JSON-RPC notifications receive HTTP 202 with an empty body. Notifications do not submit jobs. `ping`, `tools/list` and `tools/call` use ordinary JSON responses. The existing unrestricted listener policy is preserved: this endpoint adds no authentication, Origin/hostname allowlist, command filter or execution timeout. That network policy is a deliberate local deployment choice; the transport tests do not claim compliance with the specification's Origin-validation policy.

| Tool | Arguments | Result |
| --- | --- | --- |
| `engine_status` | `{}` | Compact executor counts and metadata; no output history |
| `engine_submit` | `id`, `source`, absolute `cwd`, string array `argv` | The persisted, accepted order; execution continues independently |
| `engine_order` | `id` | Exactly one order with status, exit, stdout and stderr |

Each tool result includes matching text and `structuredContent` JSON. Malformed RPC parameters and unknown tool names produce protocol errors. Known-tool argument validation, duplicate order IDs, missing orders and executor errors produce tool results with `isError: true`. Reading a completed failed command is a successful lookup whose record contains `status: failed` and its real exit/error. An accepted submission is not a claim that the command has completed. The existing durable order rules apply equally to HTTP forms and MCP: exact argv, explicit shell invocation, no duplicate execution and no automatic replay of interrupted work.

Android uses its built-in `org.json`. The host tests use the pinned, hash-verified `org.json:json:20240303` under `tests/dependencies`; that JAR is test-only and is not included in the APK.

## Runtime telemetry

The UI polls the real HTTP health, SSH process state, Bash session registry and engine records. WebSocket status reflects the current browser socket. Controller attribution means the last received order's source and timestamp, not an agent heartbeat. Failed refreshes retain the last observations and visibly mark them stale.

CLIProxyAPI authentication and four client profiles are configured. The browser shows their stored base URL, provider and profile metadata; proxy-process liveness is a separate observation. AI-adapter connection, model catalog, reasoning routing, auto-debug and the enforced AI harness remain deferred. The existing phone proxy on port 8080 and independent native Codex backend are unchanged.

## CLIProxyAPI profiles

GET `/control/cliproxy/profiles` returns `configured`, `base_url`, `upstream_provider` and a `profiles` array. Each profile contains `name`, `endpoint`, `header` and `has_key`; this listing contains metadata only. GET `/control/cliproxy/profiles/<percent-encoded-name>` returns that profile's `name` and existing `api_key` when explicitly requested.

The four profiles are `openai-responses`, `openai-chat`, `anthropic-messages` and `gemini-generate`. The browser loads their metadata separately from telemetry polling. Keys start masked; `Toon` fetches one key, `Kopieer` becomes available after reveal, and `Verberg` clears the revealed value. Reloading starts masked again. These controls expose existing credentials and leave the machine executor's explicit-argv behavior intact.

The interface is served from `/opt/t-eec/frontend` inside Ubuntu, read for each request with APK assets as fallback. Frontend edits take effect after refreshing the same `/terminal?session=...` URL. Java-backend changes require an APK update. RAG readiness gates terminal creation and input through the owner's Preflight1 setting; the native owner debug toggle remains available.
