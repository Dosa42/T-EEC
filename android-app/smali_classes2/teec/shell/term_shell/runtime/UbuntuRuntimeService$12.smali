.class public final synthetic Lteec/shell/term_shell/runtime/UbuntuRuntimeService$12;
.super Ljava/lang/Object;
.implements Lteec/shell/term_shell/runtime/TerminalServer$Assets;
.source "D8$$SyntheticClass"

.annotation runtime Lcom/android/tools/r8/annotations/LambdaMethod;
  holder = "Lteec/shell/term_shell/runtime/UbuntuRuntimeService;"
  method = "readAsset"
  proto = "(Ljava/lang/String;)[B"
.end annotation

.field public final synthetic f$0:Lteec/shell/term_shell/runtime/UbuntuRuntimeService;

.method public synthetic constructor <init>(Lteec/shell/term_shell/runtime/UbuntuRuntimeService;)V
  .registers 2
  .line 0
    invoke-direct { p0 }, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$12;->f$0:Lteec/shell/term_shell/runtime/UbuntuRuntimeService;
    return-void
.end method

.method public final read(Ljava/lang/String;)[B
  .registers 3
  .line 0
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$12;->f$0:Lteec/shell/term_shell/runtime/UbuntuRuntimeService;
    invoke-static { v0, p1 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->$r8$lambda$Y71EEhwxVMpfZFUw05zFsT4xEeA(Lteec/shell/term_shell/runtime/UbuntuRuntimeService;Ljava/lang/String;)[B
    move-result-object p1
    return-object p1
.end method
