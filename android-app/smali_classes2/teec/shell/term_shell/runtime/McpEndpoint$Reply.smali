.class public final Lteec/shell/term_shell/runtime/McpEndpoint$Reply;
.super Ljava/lang/Object;
.source "McpEndpoint.java"

.annotation system Ldalvik/annotation/EnclosingClass;
  value = Lteec/shell/term_shell/runtime/McpEndpoint;
.end annotation
.annotation system Ldalvik/annotation/InnerClass;
  accessFlags = 25
  name = "Reply"
.end annotation

.field public final body:[B

.field public final headers:Ljava/lang/String;

.field public final status:I

.method constructor <init>(ILjava/lang/String;Ljava/lang/String;)V
  .registers 4
  .line 26
    invoke-direct { p0 }, Ljava/lang/Object;-><init>()V
  .line 27
    iput p1, p0, Lteec/shell/term_shell/runtime/McpEndpoint$Reply;->status:I
  .line 28
    sget-object p1, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;
    invoke-virtual { p2, p1 }, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B
    move-result-object p1
    iput-object p1, p0, Lteec/shell/term_shell/runtime/McpEndpoint$Reply;->body:[B
  .line 29
    iput-object p3, p0, Lteec/shell/term_shell/runtime/McpEndpoint$Reply;->headers:Ljava/lang/String;
  .line 30
    return-void
.end method
