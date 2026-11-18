.class final Lteec/shell/term_shell/runtime/McpEndpoint$ProtocolFailure;
.super Ljava/lang/Exception;
.source "McpEndpoint.java"

.annotation system Ldalvik/annotation/EnclosingClass;
  value = Lteec/shell/term_shell/runtime/McpEndpoint;
.end annotation
.annotation system Ldalvik/annotation/InnerClass;
  accessFlags = 26
  name = "ProtocolFailure"
.end annotation

.field final code:I

.method constructor <init>(ILjava/lang/String;)V
  .registers 3
  .line 35
    invoke-direct { p0, p2 }, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V
    iput p1, p0, Lteec/shell/term_shell/runtime/McpEndpoint$ProtocolFailure;->code:I
    return-void
.end method
