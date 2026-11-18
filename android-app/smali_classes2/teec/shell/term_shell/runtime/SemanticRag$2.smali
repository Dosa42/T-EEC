.class public final synthetic Lteec/shell/term_shell/runtime/SemanticRag$2;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;
.source "D8$$SyntheticClass"

.annotation runtime Lcom/android/tools/r8/annotations/LambdaMethod;
  holder = "Lteec/shell/term_shell/runtime/SemanticRag;"
  method = "lambda$drain$3"
  proto = "(Ljava/io/InputStream;)V"
.end annotation

.field public final synthetic f$0:Ljava/io/InputStream;

.method public synthetic constructor <init>(Ljava/io/InputStream;)V
  .registers 2
  .line 0
    invoke-direct { p0 }, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lteec/shell/term_shell/runtime/SemanticRag$2;->f$0:Ljava/io/InputStream;
    return-void
.end method

.method public final run()V
  .registers 2
  .line 0
    iget-object v0, p0, Lteec/shell/term_shell/runtime/SemanticRag$2;->f$0:Ljava/io/InputStream;
    invoke-static { v0 }, Lteec/shell/term_shell/runtime/SemanticRag;->lambda$drain$3(Ljava/io/InputStream;)V
    return-void
.end method
