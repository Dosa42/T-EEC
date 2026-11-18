.class public final synthetic Lteec/shell/term_shell/runtime/UbuntuRuntimeService$1;
.super Ljava/lang/Object;
.implements Lteec/shell/term_shell/runtime/TerminalSessions$Factory;
.source "D8$$SyntheticClass"

.annotation runtime Lcom/android/tools/r8/annotations/LambdaMethod;
  holder = "Lteec/shell/term_shell/runtime/UbuntuRuntimeService;"
  method = "lambda$onCreate$0"
  proto = "(Ljava/lang/String;Lteec/shell/term_shell/runtime/PtySession$Listener;)Lteec/shell/term_shell/runtime/PtySession;"
.end annotation

.field public final synthetic f$0:Lteec/shell/term_shell/runtime/UbuntuRuntimeService;

.method public synthetic constructor <init>(Lteec/shell/term_shell/runtime/UbuntuRuntimeService;)V
  .registers 2
  .line 0
    invoke-direct { p0 }, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$1;->f$0:Lteec/shell/term_shell/runtime/UbuntuRuntimeService;
    return-void
.end method

.method public final open(Ljava/lang/String;Lteec/shell/term_shell/runtime/PtySession$Listener;)Lteec/shell/term_shell/runtime/PtySession;
  .registers 4
  .line 0
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$1;->f$0:Lteec/shell/term_shell/runtime/UbuntuRuntimeService;
    invoke-virtual { v0, p1, p2 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->lambda$onCreate$0$teec-shell-term_shell-runtime-UbuntuRuntimeService(Ljava/lang/String;Lteec/shell/term_shell/runtime/PtySession$Listener;)Lteec/shell/term_shell/runtime/PtySession;
    move-result-object p1
    return-object p1
.end method
