.class public final synthetic Lteec/shell/term_shell/runtime/UbuntuRuntimeService$4;
.super Ljava/lang/Object;
.implements Lteec/shell/term_shell/runtime/PtySession$Listener;
.source "D8$$SyntheticClass"

.annotation runtime Lcom/android/tools/r8/annotations/LambdaMethod;
  holder = "Lteec/shell/term_shell/runtime/UbuntuRuntimeService;"
  method = "lambda$startSsh$4"
  proto = "(Ljava/lang/String;ILjava/lang/String;)V"
.end annotation

.field public final synthetic f$0:Lteec/shell/term_shell/runtime/UbuntuRuntimeService;

.field public final synthetic f$1:Ljava/lang/String;

.method public synthetic constructor <init>(Lteec/shell/term_shell/runtime/UbuntuRuntimeService;Ljava/lang/String;)V
  .registers 3
  .line 0
    invoke-direct { p0 }, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$4;->f$0:Lteec/shell/term_shell/runtime/UbuntuRuntimeService;
    iput-object p2, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$4;->f$1:Ljava/lang/String;
    return-void
.end method

.method public final exited(ILjava/lang/String;)V
  .registers 5
  .line 0
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$4;->f$0:Lteec/shell/term_shell/runtime/UbuntuRuntimeService;
    iget-object v1, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$4;->f$1:Ljava/lang/String;
    invoke-virtual { v0, v1, p1, p2 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->lambda$startSsh$4$teec-shell-term_shell-runtime-UbuntuRuntimeService(Ljava/lang/String;ILjava/lang/String;)V
    return-void
.end method
