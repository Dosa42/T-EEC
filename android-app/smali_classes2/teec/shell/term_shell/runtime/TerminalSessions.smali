.class public final Lteec/shell/term_shell/runtime/TerminalSessions;
.super Ljava/lang/Object;
.implements Lteec/shell/term_shell/runtime/TerminalServer$Provider;
.implements Ljava/io/Closeable;
.source "TerminalSessions.java"

.annotation system Ldalvik/annotation/MemberClasses;
  value = {
    Lteec/shell/term_shell/runtime/TerminalSessions$Factory;
  }
.end annotation

.field private final changed:Ljava/lang/Runnable;

.field private closed:Z

.field private error:Ljava/lang/String;

.field private final factory:Lteec/shell/term_shell/runtime/TerminalSessions$Factory;

.field private final preflight:Lteec/shell/term_shell/runtime/TerminalServer$Preflight;

.field private primary:Ljava/lang/String;

.field private final sessions:Ljava/util/Map;
  .annotation system Ldalvik/annotation/Signature;
    value = {
      "Ljava/util/Map<",
      "Ljava/lang/String;",
      "Lteec/shell/term_shell/runtime/PtySession;",
      ">;"
    }
  .end annotation
.end field

.field private ssh:Lteec/shell/term_shell/runtime/PtySession;

.field private sshError:Ljava/lang/String;

.method public constructor <init>(Lteec/shell/term_shell/runtime/TerminalSessions$Factory;Ljava/lang/Runnable;)V
  .registers 4
  .line 22
    new-instance v0, Lteec/shell/term_shell/runtime/TerminalSessions$0;
    invoke-direct { v0 }, Lteec/shell/term_shell/runtime/TerminalSessions$0;-><init>()V
    invoke-direct { p0, p1, p2, v0 }, Lteec/shell/term_shell/runtime/TerminalSessions;-><init>(Lteec/shell/term_shell/runtime/TerminalSessions$Factory;Ljava/lang/Runnable;Lteec/shell/term_shell/runtime/TerminalServer$Preflight;)V
  .line 23
    return-void
.end method

.method public constructor <init>(Lteec/shell/term_shell/runtime/TerminalSessions$Factory;Ljava/lang/Runnable;Lteec/shell/term_shell/runtime/TerminalServer$Preflight;)V
  .registers 5
  .line 25
    invoke-direct { p0 }, Ljava/lang/Object;-><init>()V
  .line 14
    new-instance v0, Ljava/util/LinkedHashMap;
    invoke-direct { v0 }, Ljava/util/LinkedHashMap;-><init>()V
    iput-object v0, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->sessions:Ljava/util/Map;
  .line 15
    const-string v0, ""
    iput-object v0, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->primary:Ljava/lang/String;
  .line 16
    iput-object v0, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->error:Ljava/lang/String;
  .line 18
    iput-object v0, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->sshError:Ljava/lang/String;
  .line 26
    iput-object p1, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->factory:Lteec/shell/term_shell/runtime/TerminalSessions$Factory;
  .line 27
    iput-object p2, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->changed:Ljava/lang/Runnable;
  .line 28
    iput-object p3, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->preflight:Lteec/shell/term_shell/runtime/TerminalServer$Preflight;
  .line 29
    return-void
.end method

.method static synthetic lambda$new$0()Lteec/shell/term_shell/runtime/TerminalServer$Admission;
  .registers 4
  .line 22
    new-instance v0, Lteec/shell/term_shell/runtime/TerminalServer$Admission;
    const/4 v1, 1
    const-string v2, "preflight_not_configured"
    const/4 v3, 0
    invoke-direct { v0, v3, v1, v2 }, Lteec/shell/term_shell/runtime/TerminalServer$Admission;-><init>(ZZLjava/lang/String;)V
    return-object v0
.end method

.method private state(Ljava/lang/String;Lteec/shell/term_shell/runtime/PtySession;)Lteec/shell/term_shell/runtime/TerminalServer$State;
  .registers 9
  .line 61
    new-instance v0, Lteec/shell/term_shell/runtime/TerminalServer$State;
    if-nez p2, :L0
    iget-object v1, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->error:Ljava/lang/String;
    goto :L1
  :L0
    invoke-virtual { p2 }, Lteec/shell/term_shell/runtime/PtySession;->failure()Ljava/lang/String;
    move-result-object v1
  :L1
    move-object v3, v1
    iget-object v4, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->ssh:Lteec/shell/term_shell/runtime/PtySession;
    iget-object v5, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->sshError:Ljava/lang/String;
    move-object v1, p1
    move-object v2, p2
    invoke-direct/range { v0 .. v5 }, Lteec/shell/term_shell/runtime/TerminalServer$State;-><init>(Ljava/lang/String;Lteec/shell/term_shell/runtime/PtySession;Ljava/lang/String;Lteec/shell/term_shell/runtime/PtySession;Ljava/lang/String;)V
    return-object v0
.end method

.method public admission()Lteec/shell/term_shell/runtime/TerminalServer$Admission;
  .registers 2
  .line 32
    iget-object v0, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->preflight:Lteec/shell/term_shell/runtime/TerminalServer$Preflight;
    invoke-interface { v0 }, Lteec/shell/term_shell/runtime/TerminalServer$Preflight;->check()Lteec/shell/term_shell/runtime/TerminalServer$Admission;
    move-result-object v0
    return-object v0
.end method

.method public authorize()Lteec/shell/term_shell/runtime/TerminalServer$Admission;
  .registers 2
  .line 35
    iget-object v0, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->preflight:Lteec/shell/term_shell/runtime/TerminalServer$Preflight;
    invoke-interface { v0 }, Lteec/shell/term_shell/runtime/TerminalServer$Preflight;->verify()Lteec/shell/term_shell/runtime/TerminalServer$Admission;
    move-result-object v0
    return-object v0
.end method

.method public close()V
  .catchall { :L0 .. :L1 } :L10
  .catch Ljava/lang/InterruptedException; { :L5 .. :L6 } :L7
  .catchall { :L11 .. :L12 } :L10
  .registers 7
  .line 101
    monitor-enter p0
    const/4 v0, 1
  :L0
    iput-boolean v0, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->closed:Z
    invoke-virtual { p0 }, Lteec/shell/term_shell/runtime/TerminalSessions;->list()[Lteec/shell/term_shell/runtime/TerminalServer$State;
    move-result-object v0
    monitor-exit p0
  :L1
  .line 102
    array-length v1, v0
    const/4 v2, 0
    move v3, v2
  :L2
    if-ge v3, v1, :L3
    aget-object v4, v0, v3
    iget-object v4, v4, Lteec/shell/term_shell/runtime/TerminalServer$State;->session:Lteec/shell/term_shell/runtime/PtySession;
    invoke-virtual { v4 }, Lteec/shell/term_shell/runtime/PtySession;->stop()V
    add-int/lit8 v3, v3, 1
    goto :L2
  :L3
  .line 103
    array-length v1, v0
  :L4
    if-ge v2, v1, :L9
    aget-object v3, v0, v2
  :L5
    iget-object v3, v3, Lteec/shell/term_shell/runtime/TerminalServer$State;->session:Lteec/shell/term_shell/runtime/PtySession;
    const-wide/16 v4, 3000
    invoke-virtual { v3, v4, v5 }, Lteec/shell/term_shell/runtime/PtySession;->join(J)V
  :L6
  .line 104
    goto :L8
  :L7
    move-exception v3
    invoke-static { }, Ljava/lang/Thread;->currentThread()Ljava/lang/Thread;
    move-result-object v3
    invoke-virtual { v3 }, Ljava/lang/Thread;->interrupt()V
  :L8
  .line 103
    add-int/lit8 v2, v2, 1
    goto :L4
  :L9
  .line 105
    return-void
  :L10
  .line 101
    move-exception v0
  :L11
    monitor-exit p0
  :L12
    throw v0
.end method

.method public declared-synchronized create()Lteec/shell/term_shell/runtime/TerminalServer$State;
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/io/IOException;
    }
  .end annotation
  .catchall { :L0 .. :L4 } :L6
  .catchall { :L5 .. :L7 } :L6
  .registers 5
    monitor-enter p0
  :L0
  .line 66
    invoke-virtual { p0 }, Lteec/shell/term_shell/runtime/TerminalSessions;->authorize()Lteec/shell/term_shell/runtime/TerminalServer$Admission;
    move-result-object v0
    invoke-virtual { v0 }, Lteec/shell/term_shell/runtime/TerminalServer$Admission;->require()V
  .line 67
    iget-boolean v0, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->closed:Z
    if-nez v0, :L5
  .line 68
    invoke-static { }, Ljava/util/UUID;->randomUUID()Ljava/util/UUID;
    move-result-object v0
    invoke-virtual { v0 }, Ljava/util/UUID;->toString()Ljava/lang/String;
    move-result-object v0
  .line 69
    iget-object v1, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->factory:Lteec/shell/term_shell/runtime/TerminalSessions$Factory;
    new-instance v2, Lteec/shell/term_shell/runtime/TerminalSessions$1;
    invoke-direct { v2, p0 }, Lteec/shell/term_shell/runtime/TerminalSessions$1;-><init>(Lteec/shell/term_shell/runtime/TerminalSessions;)V
    invoke-interface { v1, v0, v2 }, Lteec/shell/term_shell/runtime/TerminalSessions$Factory;->open(Ljava/lang/String;Lteec/shell/term_shell/runtime/PtySession$Listener;)Lteec/shell/term_shell/runtime/PtySession;
    move-result-object v1
  .line 70
    iget-object v2, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->sessions:Ljava/util/Map;
    iget-object v3, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->primary:Ljava/lang/String;
    invoke-interface { v2, v3 }, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v2
    check-cast v2, Lteec/shell/term_shell/runtime/PtySession;
  .line 71
    iget-object v3, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->sessions:Ljava/util/Map;
    invoke-interface { v3, v0, v1 }, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
  .line 72
    if-eqz v2, :L1
    invoke-virtual { v2 }, Lteec/shell/term_shell/runtime/PtySession;->running()Z
    move-result v2
    if-nez v2, :L2
  :L1
    iput-object v0, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->primary:Ljava/lang/String;
  :L2
  .line 73
    const-string v2, ""
    iput-object v2, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->error:Ljava/lang/String;
  .line 74
    iget-object v2, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->changed:Ljava/lang/Runnable;
    if-eqz v2, :L3
    iget-object v2, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->changed:Ljava/lang/Runnable;
    invoke-interface { v2 }, Ljava/lang/Runnable;->run()V
  :L3
  .line 75
    invoke-direct { p0, v0, v1 }, Lteec/shell/term_shell/runtime/TerminalSessions;->state(Ljava/lang/String;Lteec/shell/term_shell/runtime/PtySession;)Lteec/shell/term_shell/runtime/TerminalServer$State;
    move-result-object v0
  :L4
    monitor-exit p0
    return-object v0
  :L5
  .line 67
    new-instance v0, Ljava/io/IOException;
    const-string v1, "Terminalserver is gestopt"
    invoke-direct { v0, v1 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw v0
  :L6
  .line 65
    move-exception v0
    monitor-exit p0
  :L7
    throw v0
.end method

.method public declared-synchronized current()Lteec/shell/term_shell/runtime/TerminalServer$State;
  .catchall { :L0 .. :L5 } :L6
  .catchall { :L7 .. :L8 } :L6
  .registers 5
    monitor-enter p0
  :L0
  .line 46
    iget-object v0, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->sessions:Ljava/util/Map;
    iget-object v1, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->primary:Ljava/lang/String;
    invoke-interface { v0, v1 }, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v0
    check-cast v0, Lteec/shell/term_shell/runtime/PtySession;
  .line 47
    if-eqz v0, :L1
    invoke-virtual { v0 }, Lteec/shell/term_shell/runtime/PtySession;->running()Z
    move-result v1
    if-nez v1, :L4
  :L1
    iget-object v1, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->sessions:Ljava/util/Map;
    invoke-interface { v1 }, Ljava/util/Map;->entrySet()Ljava/util/Set;
    move-result-object v1
    invoke-interface { v1 }, Ljava/util/Set;->iterator()Ljava/util/Iterator;
    move-result-object v1
  :L2
    invoke-interface { v1 }, Ljava/util/Iterator;->hasNext()Z
    move-result v2
    if-eqz v2, :L4
    invoke-interface { v1 }, Ljava/util/Iterator;->next()Ljava/lang/Object;
    move-result-object v2
    check-cast v2, Ljava/util/Map$Entry;
  .line 48
    invoke-interface { v2 }, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;
    move-result-object v3
    check-cast v3, Lteec/shell/term_shell/runtime/PtySession;
    invoke-virtual { v3 }, Lteec/shell/term_shell/runtime/PtySession;->running()Z
    move-result v3
    if-eqz v3, :L3
    invoke-interface { v2 }, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;
    move-result-object v0
    check-cast v0, Ljava/lang/String;
    iput-object v0, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->primary:Ljava/lang/String;
    invoke-interface { v2 }, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;
    move-result-object v0
    check-cast v0, Lteec/shell/term_shell/runtime/PtySession;
    goto :L4
  :L3
  .line 49
    goto :L2
  :L4
  .line 50
    iget-object v1, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->primary:Ljava/lang/String;
    invoke-direct { p0, v1, v0 }, Lteec/shell/term_shell/runtime/TerminalSessions;->state(Ljava/lang/String;Lteec/shell/term_shell/runtime/PtySession;)Lteec/shell/term_shell/runtime/TerminalServer$State;
    move-result-object v0
  :L5
    monitor-exit p0
    return-object v0
  :L6
  .line 45
    move-exception v0
  :L7
    monitor-exit p0
  :L8
    throw v0
.end method

.method public declared-synchronized error(Ljava/lang/String;)V
  .catchall { :L0 .. :L1 } :L2
  .catchall { :L3 .. :L4 } :L2
  .registers 2
    monitor-enter p0
  :L0
  .line 42
    iput-object p1, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->error:Ljava/lang/String;
  :L1
    monitor-exit p0
    return-void
  :L2
  .line 42
    move-exception p1
  :L3
    monitor-exit p0
  :L4
    throw p1
.end method

.method public declared-synchronized find(Ljava/lang/String;)Lteec/shell/term_shell/runtime/TerminalServer$State;
  .catchall { :L0 .. :L3 } :L6
  .catchall { :L4 .. :L5 } :L6
  .catchall { :L7 .. :L8 } :L6
  .registers 3
    monitor-enter p0
  .line 55
    if-eqz p1, :L4
  :L0
    invoke-virtual { p1 }, Ljava/lang/String;->isEmpty()Z
    move-result v0
    if-eqz v0, :L1
    goto :L4
  :L1
  .line 56
    iget-object v0, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->sessions:Ljava/util/Map;
    invoke-interface { v0, p1 }, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v0
    check-cast v0, Lteec/shell/term_shell/runtime/PtySession;
  .line 57
    if-nez v0, :L2
    const/4 p1, 0
    goto :L3
  :L2
    invoke-direct { p0, p1, v0 }, Lteec/shell/term_shell/runtime/TerminalSessions;->state(Ljava/lang/String;Lteec/shell/term_shell/runtime/PtySession;)Lteec/shell/term_shell/runtime/TerminalServer$State;
    move-result-object p1
  :L3
    monitor-exit p0
    return-object p1
  :L4
  .line 55
    invoke-virtual { p0 }, Lteec/shell/term_shell/runtime/TerminalSessions;->current()Lteec/shell/term_shell/runtime/TerminalServer$State;
    move-result-object p1
  :L5
    monitor-exit p0
    return-object p1
  :L6
  .line 54
    move-exception p1
  :L7
    monitor-exit p0
  :L8
    throw p1
.end method

.method synthetic lambda$create$1$teec-shell-term_shell-runtime-TerminalSessions(ILjava/lang/String;)V
  .registers 3
  .line 69
    iget-object p1, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->changed:Ljava/lang/Runnable;
    if-eqz p1, :L0
    iget-object p1, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->changed:Ljava/lang/Runnable;
    invoke-interface { p1 }, Ljava/lang/Runnable;->run()V
  :L0
    return-void
.end method

.method public declared-synchronized list()[Lteec/shell/term_shell/runtime/TerminalServer$State;
  .catchall { :L0 .. :L2 } :L4
  .catchall { :L5 .. :L6 } :L4
  .registers 7
    monitor-enter p0
  :L0
  .line 80
    iget-object v0, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->sessions:Ljava/util/Map;
    invoke-interface { v0 }, Ljava/util/Map;->size()I
    move-result v0
    new-array v0, v0, [Lteec/shell/term_shell/runtime/TerminalServer$State;
  .line 81
    nop
  .line 82
    iget-object v1, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->sessions:Ljava/util/Map;
    invoke-interface { v1 }, Ljava/util/Map;->entrySet()Ljava/util/Set;
    move-result-object v1
    invoke-interface { v1 }, Ljava/util/Set;->iterator()Ljava/util/Iterator;
    move-result-object v1
    const/4 v2, 0
  :L1
    invoke-interface { v1 }, Ljava/util/Iterator;->hasNext()Z
    move-result v3
    if-eqz v3, :L3
    invoke-interface { v1 }, Ljava/util/Iterator;->next()Ljava/lang/Object;
    move-result-object v3
    check-cast v3, Ljava/util/Map$Entry;
    add-int/lit8 v4, v2, 1
    invoke-interface { v3 }, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;
    move-result-object v5
    check-cast v5, Ljava/lang/String;
    invoke-interface { v3 }, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;
    move-result-object v3
    check-cast v3, Lteec/shell/term_shell/runtime/PtySession;
    invoke-direct { p0, v5, v3 }, Lteec/shell/term_shell/runtime/TerminalSessions;->state(Ljava/lang/String;Lteec/shell/term_shell/runtime/PtySession;)Lteec/shell/term_shell/runtime/TerminalServer$State;
    move-result-object v3
    aput-object v3, v0, v2
  :L2
    move v2, v4
    goto :L1
  :L3
  .line 83
    monitor-exit p0
    return-object v0
  :L4
  .line 79
    move-exception v0
  :L5
    monitor-exit p0
  :L6
    throw v0
.end method

.method public declared-synchronized running()Z
  .catchall { :L0 .. :L2 } :L4
  .catchall { :L5 .. :L6 } :L4
  .registers 3
    monitor-enter p0
  :L0
  .line 94
    iget-object v0, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->sessions:Ljava/util/Map;
    invoke-interface { v0 }, Ljava/util/Map;->values()Ljava/util/Collection;
    move-result-object v0
    invoke-interface { v0 }, Ljava/util/Collection;->iterator()Ljava/util/Iterator;
    move-result-object v0
  :L1
    invoke-interface { v0 }, Ljava/util/Iterator;->hasNext()Z
    move-result v1
    if-eqz v1, :L3
    invoke-interface { v0 }, Ljava/util/Iterator;->next()Ljava/lang/Object;
    move-result-object v1
    check-cast v1, Lteec/shell/term_shell/runtime/PtySession;
    invoke-virtual { v1 }, Lteec/shell/term_shell/runtime/PtySession;->running()Z
    move-result v1
  :L2
    if-eqz v1, :L1
    monitor-exit p0
    const/4 v0, 1
    return v0
  :L3
  .line 95
    monitor-exit p0
    const/4 v0, 0
    return v0
  :L4
  .line 93
    move-exception v0
  :L5
    monitor-exit p0
  :L6
    throw v0
.end method

.method public declared-synchronized ssh(Lteec/shell/term_shell/runtime/PtySession;Ljava/lang/String;)V
  .catchall { :L0 .. :L1 } :L2
  .catchall { :L3 .. :L4 } :L2
  .registers 3
    monitor-enter p0
  :L0
  .line 38
    iput-object p1, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->ssh:Lteec/shell/term_shell/runtime/PtySession;
  .line 39
    iput-object p2, p0, Lteec/shell/term_shell/runtime/TerminalSessions;->sshError:Ljava/lang/String;
  :L1
  .line 40
    monitor-exit p0
    return-void
  :L2
  .line 37
    move-exception p1
  :L3
    monitor-exit p0
  :L4
    throw p1
.end method

.method public stop(Ljava/lang/String;)V
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/io/IOException;
    }
  .end annotation
  .registers 3
  .line 88
    invoke-virtual { p0, p1 }, Lteec/shell/term_shell/runtime/TerminalSessions;->find(Ljava/lang/String;)Lteec/shell/term_shell/runtime/TerminalServer$State;
    move-result-object p1
  .line 89
    if-eqz p1, :L0
    iget-object v0, p1, Lteec/shell/term_shell/runtime/TerminalServer$State;->session:Lteec/shell/term_shell/runtime/PtySession;
    if-eqz v0, :L0
  .line 90
    iget-object p1, p1, Lteec/shell/term_shell/runtime/TerminalServer$State;->session:Lteec/shell/term_shell/runtime/PtySession;
    invoke-virtual { p1 }, Lteec/shell/term_shell/runtime/PtySession;->stop()V
  .line 91
    return-void
  :L0
  .line 89
    new-instance p1, Ljava/io/IOException;
    const-string v0, "Onbekende terminalsessie"
    invoke-direct { p1, v0 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p1
.end method
