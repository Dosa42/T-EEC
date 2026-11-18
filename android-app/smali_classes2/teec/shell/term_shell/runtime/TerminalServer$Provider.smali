.class public interface abstract Lteec/shell/term_shell/runtime/TerminalServer$Provider;
.super Ljava/lang/Object;
.source "TerminalServer.java"

.annotation system Ldalvik/annotation/EnclosingClass;
  value = Lteec/shell/term_shell/runtime/TerminalServer;
.end annotation
.annotation system Ldalvik/annotation/InnerClass;
  accessFlags = 1545
  name = "Provider"
.end annotation

.method public admission()Lteec/shell/term_shell/runtime/TerminalServer$Admission;
  .registers 5
  .line 59
    new-instance v0, Lteec/shell/term_shell/runtime/TerminalServer$Admission;
    const/4 v1, 1
    const-string v2, "preflight_not_configured"
    const/4 v3, 0
    invoke-direct { v0, v3, v1, v2 }, Lteec/shell/term_shell/runtime/TerminalServer$Admission;-><init>(ZZLjava/lang/String;)V
    return-object v0
.end method

.method public authorize()Lteec/shell/term_shell/runtime/TerminalServer$Admission;
  .registers 2
  .line 60
    invoke-interface { p0 }, Lteec/shell/term_shell/runtime/TerminalServer$Provider;->admission()Lteec/shell/term_shell/runtime/TerminalServer$Admission;
    move-result-object v0
    return-object v0
.end method

.method public create()Lteec/shell/term_shell/runtime/TerminalServer$State;
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/io/IOException;
    }
  .end annotation
  .registers 3
  .line 65
    new-instance v0, Ljava/io/IOException;
    const-string v1, "Nieuwe sessies zijn niet beschikbaar"
    invoke-direct { v0, v1 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw v0
.end method

.method public abstract current()Lteec/shell/term_shell/runtime/TerminalServer$State;
.end method

.method public find(Ljava/lang/String;)Lteec/shell/term_shell/runtime/TerminalServer$State;
  .registers 4
  .line 62
    invoke-interface { p0 }, Lteec/shell/term_shell/runtime/TerminalServer$Provider;->current()Lteec/shell/term_shell/runtime/TerminalServer$State;
    move-result-object v0
  .line 63
    if-eqz p1, :L1
    invoke-virtual { p1 }, Ljava/lang/String;->isEmpty()Z
    move-result v1
    if-nez v1, :L1
    iget-object v1, v0, Lteec/shell/term_shell/runtime/TerminalServer$State;->id:Ljava/lang/String;
    invoke-virtual { p1, v1 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p1
    if-eqz p1, :L0
    goto :L1
  :L0
    const/4 v0, 0
  :L1
    return-object v0
.end method

.method public list()[Lteec/shell/term_shell/runtime/TerminalServer$State;
  .registers 4
  .line 66
    const/4 v0, 1
    new-array v0, v0, [Lteec/shell/term_shell/runtime/TerminalServer$State;
    const/4 v1, 0
    invoke-interface { p0 }, Lteec/shell/term_shell/runtime/TerminalServer$Provider;->current()Lteec/shell/term_shell/runtime/TerminalServer$State;
    move-result-object v2
    aput-object v2, v0, v1
    return-object v0
.end method

.method public stop(Ljava/lang/String;)V
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/io/IOException;
    }
  .end annotation
  .registers 3
  .line 68
    invoke-interface { p0, p1 }, Lteec/shell/term_shell/runtime/TerminalServer$Provider;->find(Ljava/lang/String;)Lteec/shell/term_shell/runtime/TerminalServer$State;
    move-result-object p1
  .line 69
    if-eqz p1, :L0
    iget-object v0, p1, Lteec/shell/term_shell/runtime/TerminalServer$State;->session:Lteec/shell/term_shell/runtime/PtySession;
    if-eqz v0, :L0
  .line 70
    iget-object p1, p1, Lteec/shell/term_shell/runtime/TerminalServer$State;->session:Lteec/shell/term_shell/runtime/PtySession;
    invoke-virtual { p1 }, Lteec/shell/term_shell/runtime/PtySession;->stop()V
  .line 71
    return-void
  :L0
  .line 69
    new-instance p1, Ljava/io/IOException;
    const-string v0, "Onbekende terminalsessie"
    invoke-direct { p1, v0 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p1
.end method
