.class public final Lteec/shell/term_shell/runtime/TerminalServer$AdmissionDenied;
.super Ljava/io/IOException;
.source "TerminalServer.java"

.annotation system Ldalvik/annotation/EnclosingClass;
  value = Lteec/shell/term_shell/runtime/TerminalServer;
.end annotation
.annotation system Ldalvik/annotation/InnerClass;
  accessFlags = 25
  name = "AdmissionDenied"
.end annotation

.field public final admission:Lteec/shell/term_shell/runtime/TerminalServer$Admission;

.method public constructor <init>(Lteec/shell/term_shell/runtime/TerminalServer$Admission;)V
  .registers 4
  .line 53
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct { v0 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "Preflight1: "
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    iget-object v1, p1, Lteec/shell/term_shell/runtime/TerminalServer$Admission;->reason:Ljava/lang/String;
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual { v0 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-direct { p0, v0 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
  .line 54
    iput-object p1, p0, Lteec/shell/term_shell/runtime/TerminalServer$AdmissionDenied;->admission:Lteec/shell/term_shell/runtime/TerminalServer$Admission;
  .line 55
    return-void
.end method
