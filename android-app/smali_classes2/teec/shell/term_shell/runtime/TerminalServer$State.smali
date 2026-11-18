.class public final Lteec/shell/term_shell/runtime/TerminalServer$State;
.super Ljava/lang/Object;
.source "TerminalServer.java"

.annotation system Ldalvik/annotation/EnclosingClass;
  value = Lteec/shell/term_shell/runtime/TerminalServer;
.end annotation
.annotation system Ldalvik/annotation/InnerClass;
  accessFlags = 25
  name = "State"
.end annotation

.field public final error:Ljava/lang/String;

.field public final id:Ljava/lang/String;

.field public final session:Lteec/shell/term_shell/runtime/PtySession;

.field public final ssh:Lteec/shell/term_shell/runtime/PtySession;

.field public final sshError:Ljava/lang/String;

.method public constructor <init>(Ljava/lang/String;Lteec/shell/term_shell/runtime/PtySession;Ljava/lang/String;)V
  .registers 10
  .line 82
    const/4 v4, 0
    const-string v5, ""
    move-object v0, p0
    move-object v1, p1
    move-object v2, p2
    move-object v3, p3
    invoke-direct/range { v0 .. v5 }, Lteec/shell/term_shell/runtime/TerminalServer$State;-><init>(Ljava/lang/String;Lteec/shell/term_shell/runtime/PtySession;Ljava/lang/String;Lteec/shell/term_shell/runtime/PtySession;Ljava/lang/String;)V
  .line 83
    return-void
.end method

.method public constructor <init>(Ljava/lang/String;Lteec/shell/term_shell/runtime/PtySession;Ljava/lang/String;Lteec/shell/term_shell/runtime/PtySession;Ljava/lang/String;)V
  .registers 6
  .line 85
    invoke-direct { p0 }, Ljava/lang/Object;-><init>()V
  .line 86
    iput-object p1, p0, Lteec/shell/term_shell/runtime/TerminalServer$State;->id:Ljava/lang/String;
  .line 87
    iput-object p2, p0, Lteec/shell/term_shell/runtime/TerminalServer$State;->session:Lteec/shell/term_shell/runtime/PtySession;
  .line 88
    iput-object p3, p0, Lteec/shell/term_shell/runtime/TerminalServer$State;->error:Ljava/lang/String;
  .line 89
    iput-object p4, p0, Lteec/shell/term_shell/runtime/TerminalServer$State;->ssh:Lteec/shell/term_shell/runtime/PtySession;
  .line 90
    iput-object p5, p0, Lteec/shell/term_shell/runtime/TerminalServer$State;->sshError:Ljava/lang/String;
  .line 91
    return-void
.end method
