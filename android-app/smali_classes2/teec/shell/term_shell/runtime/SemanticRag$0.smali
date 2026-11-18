.class public final synthetic Lteec/shell/term_shell/runtime/SemanticRag$0;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;
.source "D8$$SyntheticClass"

.annotation runtime Lcom/android/tools/r8/annotations/LambdaMethod;
  holder = "Lteec/shell/term_shell/runtime/SemanticRag;"
  method = "lambda$start$1"
  proto = "(Landroid/content/Context;)V"
.end annotation

.field public final synthetic f$0:Lteec/shell/term_shell/runtime/SemanticRag;

.field public final synthetic f$1:Landroid/content/Context;

.method public synthetic constructor <init>(Lteec/shell/term_shell/runtime/SemanticRag;Landroid/content/Context;)V
  .registers 3
  .line 0
    invoke-direct { p0 }, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lteec/shell/term_shell/runtime/SemanticRag$0;->f$0:Lteec/shell/term_shell/runtime/SemanticRag;
    iput-object p2, p0, Lteec/shell/term_shell/runtime/SemanticRag$0;->f$1:Landroid/content/Context;
    return-void
.end method

.method public final run()V
  .registers 3
  .line 0
    iget-object v0, p0, Lteec/shell/term_shell/runtime/SemanticRag$0;->f$0:Lteec/shell/term_shell/runtime/SemanticRag;
    iget-object v1, p0, Lteec/shell/term_shell/runtime/SemanticRag$0;->f$1:Landroid/content/Context;
    invoke-virtual { v0, v1 }, Lteec/shell/term_shell/runtime/SemanticRag;->lambda$start$1$teec-shell-term_shell-runtime-SemanticRag(Landroid/content/Context;)V
    return-void
.end method
