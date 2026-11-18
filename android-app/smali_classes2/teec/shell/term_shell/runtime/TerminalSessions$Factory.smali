.class public interface abstract Lteec/shell/term_shell/runtime/TerminalSessions$Factory;
.super Ljava/lang/Object;
.source "TerminalSessions.java"

.annotation system Ldalvik/annotation/EnclosingClass;
  value = Lteec/shell/term_shell/runtime/TerminalSessions;
.end annotation
.annotation system Ldalvik/annotation/InnerClass;
  accessFlags = 1545
  name = "Factory"
.end annotation

.method public abstract open(Ljava/lang/String;Lteec/shell/term_shell/runtime/PtySession$Listener;)Lteec/shell/term_shell/runtime/PtySession;
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/io/IOException;
    }
  .end annotation
.end method
