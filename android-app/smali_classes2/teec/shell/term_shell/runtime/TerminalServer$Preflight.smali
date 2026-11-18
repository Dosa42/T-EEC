.class public interface abstract Lteec/shell/term_shell/runtime/TerminalServer$Preflight;
.super Ljava/lang/Object;
.source "TerminalServer.java"

.annotation system Ldalvik/annotation/EnclosingClass;
  value = Lteec/shell/term_shell/runtime/TerminalServer;
.end annotation
.annotation system Ldalvik/annotation/InnerClass;
  accessFlags = 1545
  name = "Preflight"
.end annotation

.method public abstract check()Lteec/shell/term_shell/runtime/TerminalServer$Admission;
.end method

.method public verify()Lteec/shell/term_shell/runtime/TerminalServer$Admission;
  .registers 2
  .line 32
    invoke-interface { p0 }, Lteec/shell/term_shell/runtime/TerminalServer$Preflight;->check()Lteec/shell/term_shell/runtime/TerminalServer$Admission;
    move-result-object v0
    return-object v0
.end method
