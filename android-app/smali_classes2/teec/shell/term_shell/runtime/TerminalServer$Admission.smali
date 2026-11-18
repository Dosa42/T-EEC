.class public final Lteec/shell/term_shell/runtime/TerminalServer$Admission;
.super Ljava/lang/Object;
.source "TerminalServer.java"

.annotation system Ldalvik/annotation/EnclosingClass;
  value = Lteec/shell/term_shell/runtime/TerminalServer;
.end annotation
.annotation system Ldalvik/annotation/InnerClass;
  accessFlags = 25
  name = "Admission"
.end annotation

.field public final enabled:Z

.field public final reason:Ljava/lang/String;

.field public final terminalAllowed:Z

.method public constructor <init>(ZZLjava/lang/String;)V
  .registers 4
  .line 38
    invoke-direct { p0 }, Ljava/lang/Object;-><init>()V
  .line 39
    iput-boolean p1, p0, Lteec/shell/term_shell/runtime/TerminalServer$Admission;->enabled:Z
  .line 40
    iput-boolean p2, p0, Lteec/shell/term_shell/runtime/TerminalServer$Admission;->terminalAllowed:Z
  .line 41
    iput-object p3, p0, Lteec/shell/term_shell/runtime/TerminalServer$Admission;->reason:Ljava/lang/String;
  .line 42
    return-void
.end method

.method public json()Ljava/lang/String;
  .registers 3
  .line 44
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct { v0 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "{\"enabled\":"
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    iget-boolean v1, p0, Lteec/shell/term_shell/runtime/TerminalServer$Admission;->enabled:Z
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;
    move-result-object v0
    const-string v1, ",\"terminal_allowed\":"
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    iget-boolean v1, p0, Lteec/shell/term_shell/runtime/TerminalServer$Admission;->terminalAllowed:Z
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;
    move-result-object v0
    const-string v1, ",\"reason\":"
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    iget-object v1, p0, Lteec/shell/term_shell/runtime/TerminalServer$Admission;->reason:Ljava/lang/String;
    invoke-static { v1 }, Lteec/shell/term_shell/runtime/TerminalServer;->quote(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    const-string v1, "}"
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual { v0 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method

.method public require()V
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/io/IOException;
    }
  .end annotation
  .registers 2
  .line 47
    iget-boolean v0, p0, Lteec/shell/term_shell/runtime/TerminalServer$Admission;->terminalAllowed:Z
    if-eqz v0, :L0
  .line 48
    return-void
  :L0
  .line 47
    new-instance v0, Lteec/shell/term_shell/runtime/TerminalServer$AdmissionDenied;
    invoke-direct { v0, p0 }, Lteec/shell/term_shell/runtime/TerminalServer$AdmissionDenied;-><init>(Lteec/shell/term_shell/runtime/TerminalServer$Admission;)V
    throw v0
.end method
