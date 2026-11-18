Source contract for T-EEC. Current state: [project handoff](../../README.md).

# T-EEC Java bootstrap

De Linux-knop gebruikt Ubuntu22.04Bare. Bij de eerste start pakt de Java-server de meegeleverde officiële Ubuntu Base 22.04.5 LTS ARM64-rootfs uit in `Context.getFilesDir()/Ubuntu22.04Bare`. Het archief staat in `assets/linux`; `ubuntu-base.json` legt bron, omvang en SHA-256 vast. De app hoeft de rootfs tijdens het starten niet te downloaden.

`LinuxApplication.getInstance()` roept `UbuntuRootfs.ensureInstalled()` aan. De eerste aanroep start één achtergrondtaak en retourneert zolang de installatie bezig is. Na volledige extractie wordt de stagingmap geactiveerd, de bestaande instelling `Linux image deployed` gezet en de bestaande Java-launcher automatisch opnieuw aangeroepen op de UI-thread. Een volgende start gebruikt de geïnstalleerde rootfs. Een reeds gedeployde Ubuntu-image met bestaande T-EEC-startbestanden blijft bruikbaar.

`UbuntuImage` voert de extractie uit met bundled BusyBox uit `common/bin`. De oorspronkelijke PRoot-, loader- en guest-clientbestanden worden hergebruikt. `t-eec/UbuntuBase22.04` selecteert in de bestaande bootloader het bare startpad. Dat start `startup.sh` en vervolgens `ProotClient`; diens bestaande FIFO-protocol meldt `Ready` aan de Java-server. Er wordt geen desktopomgeving geïnstalleerd. De eerste `startup.sh` bevat alleen een lege shellhook.

The application ID is `io.teec`, so the concrete rootfs path is `/data/data/io.teec/files/Ubuntu22.04Bare`. Bootstrap retains the existing `PRoot -r ... /t-eec/boot.sh` chain. The headless runtime service, independent terminal sessions and owner-controlled lifecycle are described in [RUNTIME.md](RUNTIME.md) and [AGENTS.md](../AGENTS.md).

## Broncode en DEX

`UbuntuRootfs.java` bevat de Android-koppeling; `UbuntuImage.java` de extractie. De app bevat hun gecompileerde Smali onder `smali_classes2/teec/shell/term_shell/runtime`. `build.json` legt de koppeling tussen broncode en gegenereerde classes vast.

```sh
python tools/build-server-java.py
python .github/scripts/vendor-ubuntu.py
python .github/scripts/verify-ubuntu.py
python .github/scripts/test-ubuntu.py
```

Voor regeneratie zijn JDK, Android SDK platform 35, D8 en `d2j-baksmali` nodig. `ANDROID_HOME` selecteert de SDK. De test gebruikt een lokale BusyBox; `TEEC_TEST_BUSYBOX` kan het pad vastleggen.

De twee Java-integratietests gebruiken het echte Ubuntu-archief. Ze controleren onder meer extractie, foutieve archiefdata, Ubuntu-identiteit, runtimebestanden, eerste aanroep, één automatische launcherhervatting en een volgende start. Android-frameworkklassen en de launcher zijn daarvoor testdoubles. De APK-build compileert ook de Java-broncode tegen de echte Android SDK en assembleert de Smali. APK-verificatie controleert de ingebedde rootfs, bootstrapclasses en het bare bootpad.

https://cdimage.ubuntu.com/ubuntu-base/releases/22.04.5/release/ubuntu-base-22.04.5-base-arm64.tar.gz


The browser includes the runtime monitor, read-only Ubuntu machine engine, CLIProxyAPI key profiles and RAG settings. Codex can submit explicit argv orders independently of interactive Bash. Persistent records, output, checklist states and HTTP interfaces are documented in [ENGINE.md](ENGINE.md). CLIProxyAPI authentication and four client profiles are configured; the AI adapter remains deferred.

Frontend files are read per request from `/opt/t-eec/frontend` inside Ubuntu, with packaged APK assets as fallback. Their existing `/terminal/` URLs remain on `0.0.0.0:8866`; edit and refresh the same browser session to apply frontend changes without an APK build or restart. Java-backend changes still require an APK update. The separate Rust/WASM workbench on port `8765` has its own build and assets.
