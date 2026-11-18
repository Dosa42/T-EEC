Source contract for T-EEC. Current state: [project handoff](../../README.md).

# Android host diagnostics from Ubuntu

`teec-host` runs a command on the Android host through the existing paired Termux ADB server. It gives Ubuntu a direct route to host diagnostics such as `/proc/stat`, interfaces and processes when the Ubuntu PRoot context cannot read those kernel interfaces. These are Android-host results, not fabricated Ubuntu `/proc` files or replacement `ps` output.

The client uses Python 3's standard library and opens the existing ADB smart socket at `127.0.0.1:5037`. This internal upstream address does not change the application's public HTTP `0.0.0.0:8866`, SSH `0.0.0.0:8122` or launcher addresses. The client never starts, kills, reconnects or reconfigures the ADB server and does not copy pairing keys. Pairing and wireless debugging remain owned by the existing ADB setup.

After deployment, the Python source is `/usr/local/lib/teec/host.py`; the small launcher is `/usr/local/bin/teec-host`. The launcher has no shebang. Run it from an existing shell, or invoke its interpreter explicitly from argv-based tools:

```sh
teec-host cat /proc/stat
teec-host ip link
teec-host ps -A
teec-host --json ss -ltn
/bin/sh /usr/local/bin/teec-host --json cat /proc/stat
python3 /usr/local/lib/teec/host.py --json ip link
```

The client discovers devices with `host:devices-l`. One connected device is selected automatically. If several devices are connected, use `--serial ID` or set `ANDROID_SERIAL`; the flag overrides the environment. Offline or unauthorized devices are reported explicitly. Optional `--host` and `--port` override `TEEC_ADB_HOST` and `TEEC_ADB_PORT` for a different existing server.

Commands are noninteractive. The client requests `shell,v2,raw`, closes remote stdin explicitly, and quotes every argument separately. Empty arguments, spaces, quotes and shell metacharacters retain their argument values. Use an explicit `sh -c` argument when shell syntax is wanted:

```sh
teec-host sh -c 'ip link; cat /proc/stat'
```

Plain mode streams the actual stdout and stderr bytes separately and returns the remote exit code. JSON mode captures `stdout`, `stderr`, byte counts, `exit`, `device`, `provider` and the submitted `argv`. Invalid UTF-8 bytes are represented with escaped surrogate values and can be recovered using Python's `text.encode('utf-8', 'surrogateescape')`.

An exit code of zero does not erase stderr: for example, a host `ss` command may exit zero while reporting denied kernel information. JSON includes both observations. Transport or protocol failures return a local exit code of one, put the reason in `error`, retain any partial output and leave the remote `exit` null. A missing remote exit packet is an incomplete command observation, not an invented success.

No additional execution deadline, authentication gate, command allowlist or new service is introduced. Host Android permissions still determine which diagnostics return data. The tool reports those actual results and errors.

Protocol implementation follows Android's [ADB service framing](https://android.googlesource.com/platform/packages/modules/adb/+/refs/heads/main/docs/dev/services.md), [shell channel definitions](https://android.googlesource.com/platform/packages/modules/adb/+/refs/heads/main/shell_protocol.h) and [official client behavior](https://android.googlesource.com/platform/packages/modules/adb/+/refs/heads/main/client/commandline.cpp). The isolated host tests use synthetic, fragmented ADB responses and never access the running ADB server.
