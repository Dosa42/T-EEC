# T-EEC

Objective: Build an independent terminal application with a bundled Ubuntu base and an owner-directed evidence-capsule foundation.

## Application

- Android package: `io.teec`; label: `T-EEC`; version: `0.1.0-teec`.
- Main Java namespace: `teec.shell.term_shell`; launcher receiver: `io.teec.Launch`.
- Native PTY: `libteec_pty.so`; display helper: `libEecX.so`.
- Service sources/assets: `android-app/t-eec` and `android-app/assets/t-eec`.
- Guest integration: `/t-eec`; services/frontend: `/opt/t-eec`.

[identity.json](identity.json) owns naming. [Runtime policy](android-app/server-java/runtime-policy.yaml) owns HTTP/WebSocket/MCP `0.0.0.0:8866`, RAG `0.0.0.0:8867`, SSH `0.0.0.0:8122` and lifecycle behavior. Internal asset HTTP uses `127.0.0.1:24112`; optional remote cursor defaults to `12124`.

## GitHub build

[Build T-EEC Android](.github/workflows/build-android.yml) runs on relevant `main` pushes or manual dispatch. It regenerates PTY/Java, runs host tests, checks bundled resources, builds and signs `teec.apk`, then uploads an Actions artifact containing the APK, SHA-256, package/signature metadata and source/build identities.

The repository uses one persistent signing identity through `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD` and `ANDROID_KEY_ALIAS`. Private signing material stays outside source control. A run never generates a replacement signing identity.

The workflow publishes build artifacts; it does not install or launch the application. See [Actions](https://github.com/Dosa42/T-EEC/actions) for the actual run result.

## Foundation state

Ubuntu starts from the bundled base image. No existing installed environment, models, databases or provider login was copied. The owner will define the Linux foundation and Witness architecture separately. Existing Preflight1 and its native owner debug toggle remain unchanged.

The implemented fresh Bare installer is `LinuxApplication.getInstance` → `UbuntuRootfs.ensureInstalled` → `UbuntuImage.install`. Inherited orphan callback branches still reference `DeployLinuxImage`; they are not the active installer. [Current-source checks](tools/current-source-checks.json) pin the reviewed references. Their Android runtime behavior is not claimed by source checks.

Third-party libraries, licenses and Mozilla developer-tools APIs retain their upstream identity.

## Verification

A standalone checkout runs:

```sh
python -B tools/verify-branding.py --portable
python -B -m unittest discover -s tools -p 'test_verify_branding.py' -v
```

Portable mode checks current identity, references, JNI exports, schema/payload agreement, source syntax and decoded archive integrity. It explicitly excludes original-source preservation and retired-name scanning, which require local external history. The default full mode additionally uses that history when present.

The source copy's previous full audit inspected 3,503 files and 7,773 archive members and preserved the original source baseline. Historical reports remain outside this repository. Full model-service tests need their Python dependencies; the first APK build does not provision models or a live RAG environment.
