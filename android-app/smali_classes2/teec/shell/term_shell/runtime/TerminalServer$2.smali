.class public final synthetic Lteec/shell/term_shell/runtime/TerminalServer$2;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;
.source "D8$$SyntheticClass"

.annotation runtime Lcom/android/tools/r8/annotations/LambdaMethod;
  holder = "Lteec/shell/term_shell/runtime/TerminalServer;"
  method = "lambda$accept$1"
  proto = "(Ljava/net/Socket;)V"
.end annotation

.field public final synthetic f$0:Lteec/shell/term_shell/runtime/TerminalServer;

.field public final synthetic f$1:Ljava/net/Socket;

.method public synthetic constructor <init>(Lteec/shell/term_shell/runtime/TerminalServer;Ljava/net/Socket;)V
  .registers 3
  .line 0
    invoke-direct { p0 }, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lteec/shell/term_shell/runtime/TerminalServer$2;->f$0:Lteec/shell/term_shell/runtime/TerminalServer;
    iput-object p2, p0, Lteec/shell/term_shell/runtime/TerminalServer$2;->f$1:Ljava/net/Socket;
    return-void
.end method

.method public final run()V
  .registers 3
  .line 0
    iget-object v0, p0, Lteec/shell/term_shell/runtime/TerminalServer$2;->f$0:Lteec/shell/term_shell/runtime/TerminalServer;
    iget-object v1, p0, Lteec/shell/term_shell/runtime/TerminalServer$2;->f$1:Ljava/net/Socket;
    invoke-virtual { v0, v1 }, Lteec/shell/term_shell/runtime/TerminalServer;->lambda$accept$1$teec-shell-term_shell-runtime-TerminalServer(Ljava/net/Socket;)V
    return-void
.end method
