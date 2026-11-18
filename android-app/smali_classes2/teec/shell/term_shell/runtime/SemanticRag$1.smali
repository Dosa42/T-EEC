.class public final synthetic Lteec/shell/term_shell/runtime/SemanticRag$1;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;
.source "D8$$SyntheticClass"

.annotation runtime Lcom/android/tools/r8/annotations/LambdaMethod;
  holder = "Lteec/shell/term_shell/runtime/SemanticRag;"
  method = "lambda$start$2"
  proto = "(Landroid/content/Context;Lteec/shell/term_shell/runtime/ProotCommand;)V"
.end annotation

.field public final synthetic f$0:Lteec/shell/term_shell/runtime/SemanticRag;

.field public final synthetic f$1:Landroid/content/Context;

.field public final synthetic f$2:Lteec/shell/term_shell/runtime/ProotCommand;

.method public synthetic constructor <init>(Lteec/shell/term_shell/runtime/SemanticRag;Landroid/content/Context;Lteec/shell/term_shell/runtime/ProotCommand;)V
  .registers 4
  .line 0
    invoke-direct { p0 }, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lteec/shell/term_shell/runtime/SemanticRag$1;->f$0:Lteec/shell/term_shell/runtime/SemanticRag;
    iput-object p2, p0, Lteec/shell/term_shell/runtime/SemanticRag$1;->f$1:Landroid/content/Context;
    iput-object p3, p0, Lteec/shell/term_shell/runtime/SemanticRag$1;->f$2:Lteec/shell/term_shell/runtime/ProotCommand;
    return-void
.end method

.method public final run()V
  .registers 4
  .line 0
    iget-object v0, p0, Lteec/shell/term_shell/runtime/SemanticRag$1;->f$0:Lteec/shell/term_shell/runtime/SemanticRag;
    iget-object v1, p0, Lteec/shell/term_shell/runtime/SemanticRag$1;->f$1:Landroid/content/Context;
    iget-object v2, p0, Lteec/shell/term_shell/runtime/SemanticRag$1;->f$2:Lteec/shell/term_shell/runtime/ProotCommand;
    invoke-virtual { v0, v1, v2 }, Lteec/shell/term_shell/runtime/SemanticRag;->lambda$start$2$teec-shell-term_shell-runtime-SemanticRag(Landroid/content/Context;Lteec/shell/term_shell/runtime/ProotCommand;)V
    return-void
.end method
