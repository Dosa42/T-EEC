.class public final synthetic Lteec/shell/term_shell/runtime/UbuntuRuntimeService$13;
.super Ljava/lang/Object;
.implements Lteec/shell/term_shell/runtime/TerminalServer$Control;
.source "D8$$SyntheticClass"

.annotation runtime Lcom/android/tools/r8/annotations/LambdaMethod;
  holder = "Lteec/shell/term_shell/runtime/UbuntuRuntimeService;"
  method = "control"
  proto = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;"
.end annotation

.field public final synthetic f$0:Lteec/shell/term_shell/runtime/UbuntuRuntimeService;

.method public synthetic constructor <init>(Lteec/shell/term_shell/runtime/UbuntuRuntimeService;)V
  .registers 2
  .line 0
    invoke-direct { p0 }, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$13;->f$0:Lteec/shell/term_shell/runtime/UbuntuRuntimeService;
    return-void
.end method

.method public final request(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
  .registers 5
  .line 0
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$13;->f$0:Lteec/shell/term_shell/runtime/UbuntuRuntimeService;
    invoke-static { v0, p1, p2, p3 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->$r8$lambda$CkshUilJPGpXCaazzEGzoGiGrGs(Lteec/shell/term_shell/runtime/UbuntuRuntimeService;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object p1
    return-object p1
.end method
