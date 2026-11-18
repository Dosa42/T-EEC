.class public final synthetic Lteec/shell/term_shell/runtime/TerminalSessions$0;
.super Ljava/lang/Object;
.implements Lteec/shell/term_shell/runtime/TerminalServer$Preflight;
.source "D8$$SyntheticClass"

.annotation runtime Lcom/android/tools/r8/annotations/LambdaMethod;
  holder = "Lteec/shell/term_shell/runtime/TerminalSessions;"
  method = "lambda$new$0"
  proto = "()Lteec/shell/term_shell/runtime/TerminalServer$Admission;"
.end annotation

.method public synthetic constructor <init>()V
  .registers 1
  .line 0
    invoke-direct { p0 }, Ljava/lang/Object;-><init>()V
    return-void
.end method

.method public final check()Lteec/shell/term_shell/runtime/TerminalServer$Admission;
  .registers 2
  .line 0
    invoke-static { }, Lteec/shell/term_shell/runtime/TerminalSessions;->lambda$new$0()Lteec/shell/term_shell/runtime/TerminalServer$Admission;
    move-result-object v0
    return-object v0
.end method
