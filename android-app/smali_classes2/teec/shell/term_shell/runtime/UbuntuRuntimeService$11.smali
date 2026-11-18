.class public final synthetic Lteec/shell/term_shell/runtime/UbuntuRuntimeService$11;
.super Ljava/lang/Object;
.implements Lteec/shell/term_shell/runtime/MachineEngine$Runner;
.source "D8$$SyntheticClass"

.annotation runtime Lcom/android/tools/r8/annotations/LambdaMethod;
  holder = "Lteec/shell/term_shell/runtime/ProotCommand;"
  method = "process"
  proto = "([Ljava/lang/String;)Ljava/lang/Process;"
.end annotation

.field public final synthetic f$0:Lteec/shell/term_shell/runtime/ProotCommand;

.method public synthetic constructor <init>(Lteec/shell/term_shell/runtime/ProotCommand;)V
  .registers 2
  .line 0
    invoke-direct { p0 }, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$11;->f$0:Lteec/shell/term_shell/runtime/ProotCommand;
    return-void
.end method

.method public final start([Ljava/lang/String;)Ljava/lang/Process;
  .registers 3
  .line 0
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$11;->f$0:Lteec/shell/term_shell/runtime/ProotCommand;
    invoke-virtual { v0, p1 }, Lteec/shell/term_shell/runtime/ProotCommand;->process([Ljava/lang/String;)Ljava/lang/Process;
    move-result-object p1
    return-object p1
.end method
