# T-EEC Android

Objective: Provide T-EEC's independent Android host and bundled Ubuntu base.

The [project handoff](../README.md) records current scope, and [owner decisions](AGENTS.md) govern changes. Package `io.teec`, label `T-EEC`, version `0.1.0-teec`, version code `1`.

The source contains the base Ubuntu archive, PRoot, native helpers, SSH payload, Java runtime, terminal assets and Python service code. Ubuntu has no copied installed packages, models, databases or provider credentials.

Frontend files are read from `/opt/t-eec/frontend` per request, with APK assets as fallback. Existing external edits survive future starts and updates. Changing frontend files does not require an APK rebuild.

Java, Smali and JNI names must agree. Native export-table edits are binary preparation, not recompilation or execution. Build metadata is created only by the authorized build; historical receipts live outside the project.

The GitHub workflow regenerates Java/Smali through `tools/build-server-java.py`, builds the PTY and packages/signs `teec.apk`. Build results are recorded in GitHub Actions. The workflow does not deploy an application.
