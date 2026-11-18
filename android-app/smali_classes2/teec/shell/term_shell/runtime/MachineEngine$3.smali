.class public final synthetic Lteec/shell/term_shell/runtime/MachineEngine$3;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;
.source "D8$$SyntheticClass"

.annotation runtime Lcom/android/tools/r8/annotations/LambdaMethod;
  holder = "Lteec/shell/term_shell/runtime/MachineEngine;"
  method = "lambda$execute$2"
  proto = "(Lteec/shell/term_shell/runtime/MachineEngine$Order;)V"
.end annotation

.field public final synthetic f$0:Lteec/shell/term_shell/runtime/MachineEngine;

.field public final synthetic f$1:Lteec/shell/term_shell/runtime/MachineEngine$Order;

.method public synthetic constructor <init>(Lteec/shell/term_shell/runtime/MachineEngine;Lteec/shell/term_shell/runtime/MachineEngine$Order;)V
  .registers 3
  .line 0
    invoke-direct { p0 }, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lteec/shell/term_shell/runtime/MachineEngine$3;->f$0:Lteec/shell/term_shell/runtime/MachineEngine;
    iput-object p2, p0, Lteec/shell/term_shell/runtime/MachineEngine$3;->f$1:Lteec/shell/term_shell/runtime/MachineEngine$Order;
    return-void
.end method

.method public final run()V
  .registers 3
  .line 0
    iget-object v0, p0, Lteec/shell/term_shell/runtime/MachineEngine$3;->f$0:Lteec/shell/term_shell/runtime/MachineEngine;
    iget-object v1, p0, Lteec/shell/term_shell/runtime/MachineEngine$3;->f$1:Lteec/shell/term_shell/runtime/MachineEngine$Order;
    invoke-virtual { v0, v1 }, Lteec/shell/term_shell/runtime/MachineEngine;->lambda$execute$2$teec-shell-term_shell-runtime-MachineEngine(Lteec/shell/term_shell/runtime/MachineEngine$Order;)V
    return-void
.end method
