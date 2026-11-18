.class public final synthetic Lteec/shell/term_shell/runtime/TerminalSessions$1;
.super Ljava/lang/Object;
.implements Lteec/shell/term_shell/runtime/PtySession$Listener;
.source "D8$$SyntheticClass"

.annotation runtime Lcom/android/tools/r8/annotations/LambdaMethod;
  holder = "Lteec/shell/term_shell/runtime/TerminalSessions;"
  method = "lambda$create$1"
  proto = "(ILjava/lang/String;)V"
.end annotation

.field public final synthetic f$0:Lteec/shell/term_shell/runtime/TerminalSessions;

.method public synthetic constructor <init>(Lteec/shell/term_shell/runtime/TerminalSessions;)V
  .registers 2
  .line 0
    invoke-direct { p0 }, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lteec/shell/term_shell/runtime/TerminalSessions$1;->f$0:Lteec/shell/term_shell/runtime/TerminalSessions;
    return-void
.end method

.method public final exited(ILjava/lang/String;)V
  .registers 4
  .line 0
    iget-object v0, p0, Lteec/shell/term_shell/runtime/TerminalSessions$1;->f$0:Lteec/shell/term_shell/runtime/TerminalSessions;
    invoke-virtual { v0, p1, p2 }, Lteec/shell/term_shell/runtime/TerminalSessions;->lambda$create$1$teec-shell-term_shell-runtime-TerminalSessions(ILjava/lang/String;)V
    return-void
.end method
