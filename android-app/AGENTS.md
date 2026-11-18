# T-EEC owner instructions

Objective: Preserve Samet's terminal purpose and implement only the current authorized stage.

- Current stage: the owner authorized installing T-EEC and provisioning its fresh Ubuntu headlessly: update/upgrade, Rocq 9.3.0, Lean, standard libraries, Python/pip, Git, wget, Node.js, OCaml and rustup. Repair installation blockers and use the independent GitHub Actions workflow for APK rebuilds. Do not copy another app’s live data or change the future foundation architecture as part of provisioning.
- The naming contract is [identity.json](../identity.json). Use package `io.teec`, Java namespace `teec.shell.term_shell`, launcher class `io.teec.Launch` and the matching JNI/export names. Update both producer and consumer of every renamed identifier.
- Ubuntu uses the bundled base image. Do not copy another live environment, model store, database or provider login as an incidental step.
- Read [runtime-policy.yaml](server-java/runtime-policy.yaml) before changing access or process behavior. Keep HTTP/MCP `0.0.0.0:8866`, RAG `0.0.0.0:8867`, SSH `0.0.0.0:8122` and the matching launcher URL. Internal probes and the legacy asset listener remain distinct.
- Preserve existing command/filesystem reach, Host/Origin behavior, SSH authentication and request framing. Do not introduce new gates, allowlists, execution deadlines or session lifetimes without owner direction.
- Keep the persistent headless service, separate PTYs, session identity, output resume and machine jobs. Closing an activity/browser must not stop the backend.
- Preserve Preflight1's default and owner-controlled native debug toggle. Architecture changes to that dependency belong to the upcoming foundation discussion; do not bypass it during naming work.
- Keep private roots/settings/keys under this application's data directory. Retain deliberate shared phone mounts and existing provider/framework choices.
- Serve frontend files from `/opt/t-eec/frontend`, falling back to APK assets. Preserve owner edits across starts and upgrades; frontend-only updates need no APK change or backend restart.
- Third-party APIs and license notices retain their upstream identities. Old app histories belong in the sibling project history directory, with their original bytes and attribution preserved.
- Apply `agent-instructions` and the canonical comment-documentation policy. Keep rationale in concise Markdown or consumer-validated JSON. Do not add source comments/docstrings/shebangs during this task; update existing identifier-bearing directives only where required.
- Do not use the frontend/design-partner skill. Report source preparation, native-byte edits, packaging, installation and observed execution separately.

## Verification

Run `python -B ../tools/verify-branding.py --portable` from this directory for a standalone checkout. Full local audit additionally requires the external history recorded in identity.json. The runtime-policy checker is also static without `--self-test`. Compilation-backed checks may run for this authorized build. Keep phone work lightweight and perform the complete APK build in GitHub Actions.
