.class public final synthetic Lteec/shell/term_shell/runtime/UbuntuRuntimeService$6;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;
.source "D8$$SyntheticClass"

.annotation runtime Lcom/android/tools/r8/annotations/LambdaMethod;
  holder = "Lteec/shell/term_shell/runtime/UbuntuRuntimeService;"
  method = "pollPreflight"
  proto = "()V"
.end annotation

.field public final synthetic f$0:Lteec/shell/term_shell/runtime/UbuntuRuntimeService;

.method public synthetic constructor <init>(Lteec/shell/term_shell/runtime/UbuntuRuntimeService;)V
  .registers 2
  .line 0
    invoke-direct { p0 }, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$6;->f$0:Lteec/shell/term_shell/runtime/UbuntuRuntimeService;
    return-void
.end method

.method public final run()V
  .registers 2
  .line 0
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$6;->f$0:Lteec/shell/term_shell/runtime/UbuntuRuntimeService;
    invoke-static { v0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->$r8$lambda$KsaG_tLKFU6gsYWDU7OJW5omdjo(Lteec/shell/term_shell/runtime/UbuntuRuntimeService;)V
    return-void
.end method
