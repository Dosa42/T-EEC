.class public final synthetic Lteec/shell/term_shell/runtime/UbuntuRuntimeService$8;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;
.source "D8$$SyntheticClass"

.annotation runtime Lcom/android/tools/r8/annotations/LambdaMethod;
  holder = "Lteec/shell/term_shell/runtime/UbuntuRuntimeService;"
  method = "shutdown"
  proto = "()V"
.end annotation

.field public final synthetic f$0:Lteec/shell/term_shell/runtime/UbuntuRuntimeService;

.method public synthetic constructor <init>(Lteec/shell/term_shell/runtime/UbuntuRuntimeService;)V
  .registers 2
  .line 0
    invoke-direct { p0 }, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$8;->f$0:Lteec/shell/term_shell/runtime/UbuntuRuntimeService;
    return-void
.end method

.method public final run()V
  .registers 2
  .line 0
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$8;->f$0:Lteec/shell/term_shell/runtime/UbuntuRuntimeService;
    invoke-static { v0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->$r8$lambda$Tb5bTHL-f_KC1sRed_ferzMMb0g(Lteec/shell/term_shell/runtime/UbuntuRuntimeService;)V
    return-void
.end method
