.class public final Lteec/shell/term_shell/runtime/MachineEngine;
.super Ljava/lang/Object;
.implements Ljava/io/Closeable;
.source "MachineEngine.java"

.annotation system Ldalvik/annotation/MemberClasses;
  value = {
    Lteec/shell/term_shell/runtime/MachineEngine$Runner;,
    Lteec/shell/term_shell/runtime/MachineEngine$Order;
  }
.end annotation

.field private closed:Z

.field private final directory:Ljava/io/File;

.field private final orders:Ljava/util/Map;
  .annotation system Ldalvik/annotation/Signature;
    value = {
      "Ljava/util/Map<",
      "Ljava/lang/String;",
      "Lteec/shell/term_shell/runtime/MachineEngine$Order;",
      ">;"
    }
  .end annotation
.end field

.field private final runner:Lteec/shell/term_shell/runtime/MachineEngine$Runner;

.field private final settings:Ljava/util/Properties;

.field private final workers:Ljava/util/concurrent/ExecutorService;

.method public constructor <init>(Ljava/io/File;Lteec/shell/term_shell/runtime/MachineEngine$Runner;)V
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/io/IOException;
    }
  .end annotation
  .catchall { :L2 .. :L3 } :L4
  .catchall { :L5 .. :L6 } :L7
  .catchall { :L11 .. :L12 } :L14
  .catchall { :L15 .. :L16 } :L17
  .registers 9
  .line 56
    invoke-direct { p0 }, Ljava/lang/Object;-><init>()V
  .line 27
    new-instance v0, Ljava/util/LinkedHashMap;
    invoke-direct { v0 }, Ljava/util/LinkedHashMap;-><init>()V
    iput-object v0, p0, Lteec/shell/term_shell/runtime/MachineEngine;->orders:Ljava/util/Map;
  .line 28
    new-instance v0, Ljava/util/Properties;
    invoke-direct { v0 }, Ljava/util/Properties;-><init>()V
    iput-object v0, p0, Lteec/shell/term_shell/runtime/MachineEngine;->settings:Ljava/util/Properties;
  .line 29
    invoke-static { }, Ljava/util/concurrent/Executors;->newCachedThreadPool()Ljava/util/concurrent/ExecutorService;
    move-result-object v0
    iput-object v0, p0, Lteec/shell/term_shell/runtime/MachineEngine;->workers:Ljava/util/concurrent/ExecutorService;
  .line 57
    iput-object p1, p0, Lteec/shell/term_shell/runtime/MachineEngine;->directory:Ljava/io/File;
  .line 58
    iput-object p2, p0, Lteec/shell/term_shell/runtime/MachineEngine;->runner:Lteec/shell/term_shell/runtime/MachineEngine$Runner;
  .line 59
    invoke-virtual { p1 }, Ljava/io/File;->isDirectory()Z
    move-result p2
    if-nez p2, :L1
    invoke-virtual { p1 }, Ljava/io/File;->mkdirs()Z
    move-result p2
    if-eqz p2, :L0
    goto :L1
  :L0
    new-instance p1, Ljava/io/IOException;
    const-string p2, "Engine-map aanmaken mislukt"
    invoke-direct { p1, p2 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p1
  :L1
  .line 60
    new-instance p2, Ljava/io/File;
    const-string v0, "settings.properties"
    invoke-direct { p2, p1, v0 }, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
  .line 61
    invoke-virtual { p2 }, Ljava/io/File;->isFile()Z
    move-result v0
    if-eqz v0, :L9
    new-instance v0, Ljava/io/FileInputStream;
    invoke-direct { v0, p2 }, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V
  :L2
    iget-object p2, p0, Lteec/shell/term_shell/runtime/MachineEngine;->settings:Ljava/util/Properties;
    invoke-virtual { p2, v0 }, Ljava/util/Properties;->load(Ljava/io/InputStream;)V
  :L3
    invoke-virtual { v0 }, Ljava/io/InputStream;->close()V
    goto :L9
  :L4
    move-exception p1
  :L5
    invoke-virtual { v0 }, Ljava/io/InputStream;->close()V
  :L6
    goto :L8
  :L7
    move-exception p2
    invoke-virtual { p1, p2 }, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V
  :L8
    throw p1
  :L9
  .line 62
    new-instance p2, Lteec/shell/term_shell/runtime/MachineEngine$0;
    invoke-direct { p2 }, Lteec/shell/term_shell/runtime/MachineEngine$0;-><init>()V
    invoke-virtual { p1, p2 }, Ljava/io/File;->listFiles(Ljava/io/FilenameFilter;)[Ljava/io/File;
    move-result-object p1
  .line 63
    if-eqz p1, :L20
  .line 64
    new-instance p2, Lteec/shell/term_shell/runtime/MachineEngine$1;
    invoke-direct { p2 }, Lteec/shell/term_shell/runtime/MachineEngine$1;-><init>()V
    invoke-static { p2 }, Ljava/util/Comparator;->comparing(Ljava/util/function/Function;)Ljava/util/Comparator;
    move-result-object p2
    invoke-static { p1, p2 }, Ljava/util/Arrays;->sort([Ljava/lang/Object;Ljava/util/Comparator;)V
  .line 65
    array-length p2, p1
    const/4 v0, 0
  :L10
    if-ge v0, p2, :L19
    aget-object v1, p1, v0
  .line 66
    new-instance v2, Ljava/util/Properties;
    invoke-direct { v2 }, Ljava/util/Properties;-><init>()V
  .line 67
    new-instance v3, Ljava/io/FileInputStream;
    invoke-direct { v3, v1 }, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V
  :L11
    invoke-virtual { v2, v3 }, Ljava/util/Properties;->load(Ljava/io/InputStream;)V
  :L12
    invoke-virtual { v3 }, Ljava/io/InputStream;->close()V
  .line 68
    new-instance v3, Lteec/shell/term_shell/runtime/MachineEngine$Order;
    invoke-direct { v3, p0, v1, v2 }, Lteec/shell/term_shell/runtime/MachineEngine$Order;-><init>(Lteec/shell/term_shell/runtime/MachineEngine;Ljava/io/File;Ljava/util/Properties;)V
  .line 69
    const-string v1, "queued"
    const-string v4, "running"
    filled-new-array { v1, v4 }, [Ljava/lang/String;
    move-result-object v1
    invoke-static { v1 }, Ljava/util/Arrays;->asList([Ljava/lang/Object;)Ljava/util/List;
    move-result-object v1
    const-string v4, "status"
    invoke-virtual { v2, v4 }, Ljava/util/Properties;->getProperty(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v5
    invoke-interface { v1, v5 }, Ljava/util/List;->contains(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :L13
  .line 70
    const-string v1, "interrupted"
    invoke-virtual { v2, v4, v1 }, Ljava/util/Properties;->setProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Object;
  .line 71
    invoke-static { }, Ljava/lang/System;->currentTimeMillis()J
    move-result-wide v4
    invoke-static { v4, v5 }, Ljava/lang/Long;->toString(J)Ljava/lang/String;
    move-result-object v1
    const-string v4, "finished"
    invoke-virtual { v2, v4, v1 }, Ljava/util/Properties;->setProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Object;
  .line 72
    const-string v1, "error"
    const-string v4, "runtime_stopped"
    invoke-virtual { v2, v1, v4 }, Ljava/util/Properties;->setProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Object;
  .line 73
    invoke-virtual { v3 }, Lteec/shell/term_shell/runtime/MachineEngine$Order;->save()V
  :L13
  .line 75
    iget-object v1, p0, Lteec/shell/term_shell/runtime/MachineEngine;->orders:Ljava/util/Map;
    const-string v4, "id"
    invoke-virtual { v2, v4 }, Ljava/util/Properties;->getProperty(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2
    invoke-interface { v1, v2, v3 }, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
  .line 65
    add-int/lit8 v0, v0, 1
    goto :L10
  :L14
  .line 67
    move-exception p1
  :L15
    invoke-virtual { v3 }, Ljava/io/InputStream;->close()V
  :L16
    goto :L18
  :L17
    move-exception p2
    invoke-virtual { p1, p2 }, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V
  :L18
    throw p1
  :L19
  .line 77
    return-void
  :L20
  .line 63
    new-instance p1, Ljava/io/IOException;
    const-string p2, "Engine-map lezen mislukt"
    invoke-direct { p1, p2 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p1
.end method

.method static synthetic access$000(Lteec/shell/term_shell/runtime/MachineEngine;)Ljava/io/File;
  .registers 1
  .line 23
    iget-object p0, p0, Lteec/shell/term_shell/runtime/MachineEngine;->directory:Ljava/io/File;
    return-object p0
.end method

.method static synthetic access$100(Ljava/io/File;Ljava/util/Properties;)V
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/io/IOException;
    }
  .end annotation
  .registers 2
  .line 23
    invoke-static { p0, p1 }, Lteec/shell/term_shell/runtime/MachineEngine;->store(Ljava/io/File;Ljava/util/Properties;)V
    return-void
.end method

.method static synthetic access$200(Ljava/io/File;)Ljava/lang/String;
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/io/IOException;
    }
  .end annotation
  .registers 1
  .line 23
    invoke-static { p0 }, Lteec/shell/term_shell/runtime/MachineEngine;->read(Ljava/io/File;)Ljava/lang/String;
    move-result-object p0
    return-object p0
.end method

.method private copyStream(Lteec/shell/term_shell/runtime/MachineEngine$Order;Ljava/io/InputStream;Ljava/lang/String;)V
  .catchall { :L0 .. :L1 } :L15
  .catchall { :L2 .. :L4 } :L9
  .catchall { :L5 .. :L6 } :L15
  .catch Ljava/io/IOException; { :L7 .. :L8 } :L21
  .catchall { :L10 .. :L11 } :L12
  .catchall { :L13 .. :L15 } :L15
  .catchall { :L16 .. :L17 } :L18
  .catch Ljava/io/IOException; { :L19 .. :L21 } :L21
  .catchall { :L22 .. :L25 } :L24
  .registers 7
  :L0
  .line 164
    new-instance v0, Ljava/io/FileOutputStream;
    invoke-virtual { p1, p3 }, Lteec/shell/term_shell/runtime/MachineEngine$Order;->stream(Ljava/lang/String;)Ljava/io/File;
    move-result-object p3
    invoke-direct { v0, p3 }, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V
  :L1
  .line 165
    const/16 p3, 16384
  :L2
    new-array p3, p3, [B
  :L3
  .line 167
    invoke-virtual { p2, p3 }, Ljava/io/InputStream;->read([B)I
    move-result v1
    const/4 v2, -1
    if-eq v1, v2, :L5
    const/4 v2, 0
    invoke-virtual { v0, p3, v2, v1 }, Ljava/io/OutputStream;->write([BII)V
    invoke-virtual { v0 }, Ljava/io/OutputStream;->flush()V
  :L4
    goto :L3
  :L5
  .line 168
    invoke-virtual { v0 }, Ljava/io/OutputStream;->close()V
  :L6
    if-eqz p2, :L23
  :L7
    invoke-virtual { p2 }, Ljava/io/InputStream;->close()V
  :L8
    goto :L23
  :L9
  .line 164
    move-exception p3
  :L10
    invoke-virtual { v0 }, Ljava/io/OutputStream;->close()V
  :L11
    goto :L14
  :L12
    move-exception v0
  :L13
    invoke-virtual { p3, v0 }, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V
  :L14
    throw p3
  :L15
    move-exception p3
    if-eqz p2, :L20
  :L16
    invoke-virtual { p2 }, Ljava/io/InputStream;->close()V
  :L17
    goto :L20
  :L18
    move-exception p2
  :L19
    invoke-virtual { p3, p2 }, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V
  :L20
    throw p3
  :L21
  .line 168
    move-exception p2
    monitor-enter p0
  :L22
    iget-object p1, p1, Lteec/shell/term_shell/runtime/MachineEngine$Order;->data:Ljava/util/Properties;
    const-string p3, "error"
    invoke-virtual { p2 }, Ljava/io/IOException;->toString()Ljava/lang/String;
    move-result-object p2
    invoke-virtual { p1, p3, p2 }, Ljava/util/Properties;->setProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Object;
    monitor-exit p0
  :L23
  .line 169
    return-void
  :L24
  .line 168
    move-exception p1
    monitor-exit p0
  :L25
    throw p1
.end method

.method private execute(Lteec/shell/term_shell/runtime/MachineEngine$Order;)V
  .catch Ljava/lang/Exception; { :L0 .. :L1 } :L15
  .catchall { :L1 .. :L5 } :L12
  .catch Ljava/lang/Exception; { :L5 .. :L6 } :L15
  .catchall { :L6 .. :L11 } :L10
  .catch Ljava/lang/Exception; { :L11 .. :L12 } :L15
  .catchall { :L13 .. :L14 } :L12
  .catch Ljava/lang/Exception; { :L14 .. :L15 } :L15
  .catchall { :L16 .. :L18 } :L24
  .catch Ljava/io/IOException; { :L18 .. :L19 } :L20
  .catchall { :L18 .. :L19 } :L24
  .catchall { :L21 .. :L25 } :L24
  .registers 9
  :L0
  .line 131
    monitor-enter p0
  :L1
  .line 132
    iget-boolean v0, p0, Lteec/shell/term_shell/runtime/MachineEngine;->closed:Z
    if-eqz v0, :L2
    monitor-exit p0
    return-void
  :L2
  .line 133
    new-instance v0, Ljava/util/ArrayList;
    const-string v1, "/usr/bin/env"
    const-string v2, "-C"
    iget-object v3, p1, Lteec/shell/term_shell/runtime/MachineEngine$Order;->data:Ljava/util/Properties;
    const-string v4, "cwd"
    invoke-virtual { v3, v4 }, Ljava/util/Properties;->getProperty(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v3
    const-string v4, "--"
    filled-new-array { v1, v2, v3, v4 }, [Ljava/lang/String;
    move-result-object v1
    invoke-static { v1 }, Ljava/util/Arrays;->asList([Ljava/lang/Object;)Ljava/util/List;
    move-result-object v1
    invoke-direct { v0, v1 }, Ljava/util/ArrayList;-><init>(Ljava/util/Collection;)V
  .line 134
    iget-object v1, p1, Lteec/shell/term_shell/runtime/MachineEngine$Order;->data:Ljava/util/Properties;
    const-string v2, "argc"
    invoke-virtual { v1, v2 }, Ljava/util/Properties;->getProperty(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    invoke-static { v1 }, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I
    move-result v1
  .line 135
    const/4 v2, 0
    move v3, v2
  :L3
    if-ge v3, v1, :L4
    iget-object v4, p1, Lteec/shell/term_shell/runtime/MachineEngine$Order;->data:Ljava/util/Properties;
    new-instance v5, Ljava/lang/StringBuilder;
    invoke-direct { v5 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v6, "arg."
    invoke-virtual { v5, v6 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v5
    invoke-virtual { v5, v3 }, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    move-result-object v5
    invoke-virtual { v5 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v5
    invoke-virtual { v4, v5 }, Ljava/util/Properties;->getProperty(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v4
    invoke-interface { v0, v4 }, Ljava/util/List;->add(Ljava/lang/Object;)Z
    add-int/lit8 v3, v3, 1
    goto :L3
  :L4
  .line 136
    iget-object v1, p0, Lteec/shell/term_shell/runtime/MachineEngine;->runner:Lteec/shell/term_shell/runtime/MachineEngine$Runner;
    new-array v2, v2, [Ljava/lang/String;
    invoke-interface { v0, v2 }, Ljava/util/List;->toArray([Ljava/lang/Object;)[Ljava/lang/Object;
    move-result-object v0
    check-cast v0, [Ljava/lang/String;
    invoke-interface { v1, v0 }, Lteec/shell/term_shell/runtime/MachineEngine$Runner;->start([Ljava/lang/String;)Ljava/lang/Process;
    move-result-object v0
    iput-object v0, p1, Lteec/shell/term_shell/runtime/MachineEngine$Order;->process:Ljava/lang/Process;
  .line 137
    iget-object v0, p1, Lteec/shell/term_shell/runtime/MachineEngine$Order;->process:Ljava/lang/Process;
    invoke-virtual { v0 }, Ljava/lang/Process;->getOutputStream()Ljava/io/OutputStream;
    move-result-object v0
    invoke-virtual { v0 }, Ljava/io/OutputStream;->close()V
  .line 138
    iget-object v0, p1, Lteec/shell/term_shell/runtime/MachineEngine$Order;->data:Ljava/util/Properties;
    const-string v1, "status"
    const-string v2, "running"
    invoke-virtual { v0, v1, v2 }, Ljava/util/Properties;->setProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Object;
  .line 139
    iget-object v0, p1, Lteec/shell/term_shell/runtime/MachineEngine$Order;->data:Ljava/util/Properties;
    const-string v1, "started"
    invoke-static { }, Ljava/lang/System;->currentTimeMillis()J
    move-result-wide v2
    invoke-static { v2, v3 }, Ljava/lang/Long;->toString(J)Ljava/lang/String;
    move-result-object v2
    invoke-virtual { v0, v1, v2 }, Ljava/util/Properties;->setProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Object;
  .line 140
    invoke-virtual { p1 }, Lteec/shell/term_shell/runtime/MachineEngine$Order;->save()V
  .line 141
    monitor-exit p0
  :L5
  .line 142
    new-instance v0, Ljava/lang/Thread;
    new-instance v1, Lteec/shell/term_shell/runtime/MachineEngine$3;
    invoke-direct { v1, p0, p1 }, Lteec/shell/term_shell/runtime/MachineEngine$3;-><init>(Lteec/shell/term_shell/runtime/MachineEngine;Lteec/shell/term_shell/runtime/MachineEngine$Order;)V
    const-string v2, "Ubuntu-engine-stderr"
    invoke-direct { v0, v1, v2 }, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;Ljava/lang/String;)V
  .line 143
    invoke-virtual { v0 }, Ljava/lang/Thread;->start()V
  .line 144
    iget-object v1, p1, Lteec/shell/term_shell/runtime/MachineEngine$Order;->process:Ljava/lang/Process;
    invoke-virtual { v1 }, Ljava/lang/Process;->getInputStream()Ljava/io/InputStream;
    move-result-object v1
    const-string v2, "stdout"
    invoke-direct { p0, p1, v1, v2 }, Lteec/shell/term_shell/runtime/MachineEngine;->copyStream(Lteec/shell/term_shell/runtime/MachineEngine$Order;Ljava/io/InputStream;Ljava/lang/String;)V
  .line 145
    iget-object v1, p1, Lteec/shell/term_shell/runtime/MachineEngine$Order;->process:Ljava/lang/Process;
    invoke-virtual { v1 }, Ljava/lang/Process;->waitFor()I
    move-result v1
  .line 146
    invoke-virtual { v0 }, Ljava/lang/Thread;->join()V
  .line 147
    monitor-enter p0
  :L6
  .line 148
    iget-object v0, p1, Lteec/shell/term_shell/runtime/MachineEngine$Order;->data:Ljava/util/Properties;
    const-string v2, "status"
    invoke-virtual { v0, v2 }, Ljava/util/Properties;->getProperty(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    const-string v2, "interrupted"
    invoke-virtual { v0, v2 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-nez v0, :L9
    iget-object v0, p1, Lteec/shell/term_shell/runtime/MachineEngine$Order;->data:Ljava/util/Properties;
    const-string v2, "status"
    if-nez v1, :L7
    iget-object v3, p1, Lteec/shell/term_shell/runtime/MachineEngine$Order;->data:Ljava/util/Properties;
    const-string v4, "error"
    const-string v5, ""
    invoke-virtual { v3, v4, v5 }, Ljava/util/Properties;->getProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v3
    invoke-virtual { v3 }, Ljava/lang/String;->isEmpty()Z
    move-result v3
    if-eqz v3, :L7
    const-string v3, "done"
    goto :L8
  :L7
    const-string v3, "failed"
  :L8
    invoke-virtual { v0, v2, v3 }, Ljava/util/Properties;->setProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Object;
  :L9
  .line 149
    iget-object v0, p1, Lteec/shell/term_shell/runtime/MachineEngine$Order;->data:Ljava/util/Properties;
    const-string v2, "exit"
    invoke-static { v1 }, Ljava/lang/Integer;->toString(I)Ljava/lang/String;
    move-result-object v1
    invoke-virtual { v0, v2, v1 }, Ljava/util/Properties;->setProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Object;
  .line 150
    iget-object v0, p1, Lteec/shell/term_shell/runtime/MachineEngine$Order;->data:Ljava/util/Properties;
    const-string v1, "finished"
    invoke-static { }, Ljava/lang/System;->currentTimeMillis()J
    move-result-wide v2
    invoke-static { v2, v3 }, Ljava/lang/Long;->toString(J)Ljava/lang/String;
    move-result-object v2
    invoke-virtual { v0, v1, v2 }, Ljava/util/Properties;->setProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Object;
  .line 151
    invoke-virtual { p1 }, Lteec/shell/term_shell/runtime/MachineEngine$Order;->save()V
  .line 152
    monitor-exit p0
  .line 160
    goto :L23
  :L10
  .line 152
    move-exception v0
    monitor-exit p0
  :L11
    throw v0
  :L12
  .line 141
    move-exception v0
  :L13
    monitor-exit p0
  :L14
    throw v0
  :L15
  .line 153
    move-exception v0
  .line 154
    monitor-enter p0
  :L16
  .line 155
    iget-object v1, p1, Lteec/shell/term_shell/runtime/MachineEngine$Order;->data:Ljava/util/Properties;
    const-string v2, "status"
    invoke-virtual { v1, v2 }, Ljava/util/Properties;->getProperty(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    const-string v2, "interrupted"
    invoke-virtual { v1, v2 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :L17
    iget-object v1, p1, Lteec/shell/term_shell/runtime/MachineEngine$Order;->data:Ljava/util/Properties;
    const-string v2, "status"
    const-string v3, "failed"
    invoke-virtual { v1, v2, v3 }, Ljava/util/Properties;->setProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Object;
  :L17
  .line 156
    iget-object v1, p1, Lteec/shell/term_shell/runtime/MachineEngine$Order;->data:Ljava/util/Properties;
    const-string v2, "error"
    invoke-virtual { v0 }, Ljava/lang/Exception;->toString()Ljava/lang/String;
    move-result-object v3
    invoke-virtual { v1, v2, v3 }, Ljava/util/Properties;->setProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Object;
  .line 157
    iget-object v1, p1, Lteec/shell/term_shell/runtime/MachineEngine$Order;->data:Ljava/util/Properties;
    const-string v2, "finished"
    invoke-static { }, Ljava/lang/System;->currentTimeMillis()J
    move-result-wide v3
    invoke-static { v3, v4 }, Ljava/lang/Long;->toString(J)Ljava/lang/String;
    move-result-object v3
    invoke-virtual { v1, v2, v3 }, Ljava/util/Properties;->setProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Object;
  :L18
  .line 158
    invoke-virtual { p1 }, Lteec/shell/term_shell/runtime/MachineEngine$Order;->save()V
  :L19
    goto :L22
  :L20
    move-exception v1
  :L21
    iget-object p1, p1, Lteec/shell/term_shell/runtime/MachineEngine$Order;->data:Ljava/util/Properties;
    const-string v2, "error"
    new-instance v3, Ljava/lang/StringBuilder;
    invoke-direct { v3 }, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual { v3, v0 }, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;
    move-result-object v0
    const-string v3, "; "
    invoke-virtual { v0, v3 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual { v0 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-virtual { p1, v2, v0 }, Ljava/util/Properties;->setProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Object;
  :L22
  .line 159
    monitor-exit p0
  :L23
  .line 161
    return-void
  :L24
  .line 159
    move-exception p1
    monitor-exit p0
  :L25
    throw p1
.end method

.method private static form(Ljava/lang/String;)Ljava/util/Map;
  .annotation system Ldalvik/annotation/Signature;
    value = {
      "(",
      "Ljava/lang/String;",
      ")",
      "Ljava/util/Map<",
      "Ljava/lang/String;",
      "Ljava/util/List<",
      "Ljava/lang/String;",
      ">;>;"
    }
  .end annotation
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/io/IOException;
    }
  .end annotation
  .registers 9
  .line 229
    new-instance v0, Ljava/util/LinkedHashMap;
    invoke-direct { v0 }, Ljava/util/LinkedHashMap;-><init>()V
  .line 230
    const-string v1, "&"
    invoke-virtual { p0, v1 }, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;
    move-result-object p0
    array-length v1, p0
    const/4 v2, 0
    move v3, v2
  :L0
    if-ge v3, v1, :L3
    aget-object v4, p0, v3
  .line 231
    const-string v5, "="
    const/4 v6, 2
    invoke-virtual { v4, v5, v6 }, Ljava/lang/String;->split(Ljava/lang/String;I)[Ljava/lang/String;
    move-result-object v4
  .line 232
    array-length v5, v4
    if-ne v5, v6, :L2
  .line 233
    aget-object v5, v4, v2
    const-string v6, "UTF-8"
    invoke-static { v5, v6 }, Ljava/net/URLDecoder;->decode(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v5
  .line 234
    invoke-interface { v0, v5 }, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v7
    check-cast v7, Ljava/util/List;
  .line 235
    if-nez v7, :L1
    new-instance v7, Ljava/util/ArrayList;
    invoke-direct { v7 }, Ljava/util/ArrayList;-><init>()V
    invoke-interface { v0, v5, v7 }, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
  :L1
  .line 236
    const/4 v5, 1
    aget-object v4, v4, v5
    invoke-static { v4, v6 }, Ljava/net/URLDecoder;->decode(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v4
    invoke-interface { v7, v4 }, Ljava/util/List;->add(Ljava/lang/Object;)Z
  :L2
  .line 230
    add-int/lit8 v3, v3, 1
    goto :L0
  :L3
  .line 239
    return-object v0
.end method

.method static synthetic lambda$new$0(Ljava/io/File;Ljava/lang/String;)Z
  .registers 2
  .line 62
    const-string p0, ".order"
    invoke-virtual { p1, p0 }, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result p0
    return p0
.end method

.method private static read(Ljava/io/File;)Ljava/lang/String;
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/io/IOException;
    }
  .end annotation
  .catchall { :L1 .. :L2 } :L14
  .catchall { :L3 .. :L6 } :L8
  .catchall { :L6 .. :L7 } :L14
  .catchall { :L9 .. :L10 } :L11
  .catchall { :L12 .. :L14 } :L14
  .catchall { :L15 .. :L16 } :L17
  .registers 5
  .line 220
    invoke-virtual { p0 }, Ljava/io/File;->isFile()Z
    move-result v0
    if-nez v0, :L0
    const-string p0, ""
    return-object p0
  :L0
  .line 221
    new-instance v0, Ljava/io/FileInputStream;
    invoke-direct { v0, p0 }, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V
  :L1
    new-instance p0, Ljava/io/ByteArrayOutputStream;
    invoke-direct { p0 }, Ljava/io/ByteArrayOutputStream;-><init>()V
  :L2
  .line 222
    const/16 v1, 16384
  :L3
    new-array v1, v1, [B
  :L4
  .line 223
    invoke-virtual { v0, v1 }, Ljava/io/InputStream;->read([B)I
    move-result v2
    const/4 v3, -1
    if-eq v2, v3, :L5
    const/4 v3, 0
    invoke-virtual { p0, v1, v3, v2 }, Ljava/io/ByteArrayOutputStream;->write([BII)V
    goto :L4
  :L5
  .line 224
    new-instance v1, Ljava/lang/String;
    invoke-virtual { p0 }, Ljava/io/ByteArrayOutputStream;->toByteArray()[B
    move-result-object v2
    sget-object v3, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;
    invoke-direct { v1, v2, v3 }, Ljava/lang/String;-><init>([BLjava/nio/charset/Charset;)V
  :L6
  .line 225
    invoke-virtual { p0 }, Ljava/io/ByteArrayOutputStream;->close()V
  :L7
    invoke-virtual { v0 }, Ljava/io/InputStream;->close()V
  .line 224
    return-object v1
  :L8
  .line 221
    move-exception v1
  :L9
    invoke-virtual { p0 }, Ljava/io/ByteArrayOutputStream;->close()V
  :L10
    goto :L13
  :L11
    move-exception p0
  :L12
    invoke-virtual { v1, p0 }, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V
  :L13
    throw v1
  :L14
    move-exception p0
  :L15
    invoke-virtual { v0 }, Ljava/io/InputStream;->close()V
  :L16
    goto :L18
  :L17
    move-exception v0
    invoke-virtual { p0, v0 }, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V
  :L18
    throw p0
.end method

.method private snapshot()Ljava/lang/String;
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/io/IOException;
    }
  .end annotation
  .registers 9
  .line 172
    new-instance v0, Ljava/lang/StringBuilder;
    const-string v1, "{\"schema\":\"teec.engine/1\",\"adapter\":\"not_configured\",\"settings\":{"
    invoke-direct { v0, v1 }, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V
  .line 173
    const-string v6, "hooks"
    const-string v7, "instructions"
    const-string v2, "mode"
    const-string v3, "model"
    const-string v4, "reasoning"
    const-string v5, "skills"
    filled-new-array/range { v2 .. v7 }, [Ljava/lang/String;
    move-result-object v1
    invoke-static { v1 }, Ljava/util/Arrays;->asList([Ljava/lang/Object;)Ljava/util/List;
    move-result-object v1
    invoke-interface { v1 }, Ljava/util/List;->iterator()Ljava/util/Iterator;
    move-result-object v1
  :L0
    invoke-interface { v1 }, Ljava/util/Iterator;->hasNext()Z
    move-result v2
    const/16 v3, 44
    const/4 v4, 1
    if-eqz v2, :L4
    invoke-interface { v1 }, Ljava/util/Iterator;->next()Ljava/lang/Object;
    move-result-object v2
    check-cast v2, Ljava/lang/String;
  .line 174
    invoke-virtual { v0 }, Ljava/lang/StringBuilder;->length()I
    move-result v5
    sub-int/2addr v5, v4
    invoke-virtual { v0, v5 }, Ljava/lang/StringBuilder;->charAt(I)C
    move-result v4
    const/16 v5, 123
    if-eq v4, v5, :L1
    invoke-virtual { v0, v3 }, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;
  :L1
  .line 175
    invoke-static { v2 }, Lteec/shell/term_shell/runtime/TerminalServer;->quote(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v3
    invoke-virtual { v0, v3 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v3
    const/16 v4, 58
    invoke-virtual { v3, v4 }, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;
    move-result-object v3
    iget-object v4, p0, Lteec/shell/term_shell/runtime/MachineEngine;->settings:Ljava/util/Properties;
    const-string v5, "mode"
    invoke-virtual { v2, v5 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v5
    if-eqz v5, :L2
    const-string v5, "mechanical"
    goto :L3
  :L2
    const-string v5, ""
  :L3
    invoke-virtual { v4, v2, v5 }, Ljava/util/Properties;->getProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2
    invoke-static { v2 }, Lteec/shell/term_shell/runtime/TerminalServer;->quote(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2
    invoke-virtual { v3, v2 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
  .line 176
    goto :L0
  :L4
  .line 177
    const-string v1, "},\"orders\":["
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
  .line 178
    nop
  .line 179
    iget-object v1, p0, Lteec/shell/term_shell/runtime/MachineEngine;->orders:Ljava/util/Map;
    invoke-interface { v1 }, Ljava/util/Map;->values()Ljava/util/Collection;
    move-result-object v1
    invoke-interface { v1 }, Ljava/util/Collection;->iterator()Ljava/util/Iterator;
    move-result-object v1
  :L5
    invoke-interface { v1 }, Ljava/util/Iterator;->hasNext()Z
    move-result v2
    if-eqz v2, :L7
    invoke-interface { v1 }, Ljava/util/Iterator;->next()Ljava/lang/Object;
    move-result-object v2
    check-cast v2, Lteec/shell/term_shell/runtime/MachineEngine$Order;
  .line 180
    if-nez v4, :L6
    invoke-virtual { v0, v3 }, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;
  :L6
  .line 181
    invoke-virtual { v2 }, Lteec/shell/term_shell/runtime/MachineEngine$Order;->json()Ljava/lang/String;
    move-result-object v2
    invoke-virtual { v0, v2 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
  .line 182
    const/4 v4, 0
    goto :L5
  :L7
  .line 183
    const-string v1, "]}"
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual { v0 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method

.method private static store(Ljava/io/File;Ljava/util/Properties;)V
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/io/IOException;
    }
  .end annotation
  .catchall { :L0 .. :L1 } :L3
  .catchall { :L4 .. :L5 } :L6
  .registers 5
  .line 214
    new-instance v0, Ljava/io/File;
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct { v1 }, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual { p0 }, Ljava/io/File;->getPath()Ljava/lang/String;
    move-result-object v2
    invoke-virtual { v1, v2 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v1
    const-string v2, ".tmp"
    invoke-virtual { v1, v2 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v1
    invoke-virtual { v1 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1
    invoke-direct { v0, v1 }, Ljava/io/File;-><init>(Ljava/lang/String;)V
  .line 215
    new-instance v1, Ljava/io/FileOutputStream;
    invoke-direct { v1, v0 }, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V
    const/4 v2, 0
  :L0
    invoke-virtual { p1, v1, v2 }, Ljava/util/Properties;->store(Ljava/io/OutputStream;Ljava/lang/String;)V
    invoke-virtual { v1 }, Ljava/io/FileOutputStream;->getFD()Ljava/io/FileDescriptor;
    move-result-object p1
    invoke-virtual { p1 }, Ljava/io/FileDescriptor;->sync()V
  :L1
    invoke-virtual { v1 }, Ljava/io/FileOutputStream;->close()V
  .line 216
    invoke-virtual { v0, p0 }, Ljava/io/File;->renameTo(Ljava/io/File;)Z
    move-result p1
    if-eqz p1, :L2
  .line 217
    return-void
  :L2
  .line 216
    new-instance p1, Ljava/io/IOException;
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct { v0 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "Engine-record opslaan mislukt: "
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual { p0 }, Ljava/io/File;->getName()Ljava/lang/String;
    move-result-object p0
    invoke-virtual { v0, p0 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p0
    invoke-virtual { p0 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object p0
    invoke-direct { p1, p0 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p1
  :L3
  .line 215
    move-exception p0
  :L4
    invoke-virtual { v1 }, Ljava/io/FileOutputStream;->close()V
  :L5
    goto :L7
  :L6
    move-exception p1
    invoke-virtual { p0, p1 }, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V
  :L7
    throw p0
.end method

.method private submit(Ljava/util/Map;)Ljava/lang/String;
  .annotation system Ldalvik/annotation/Signature;
    value = {
      "(",
      "Ljava/util/Map<",
      "Ljava/lang/String;",
      "Ljava/util/List<",
      "Ljava/lang/String;",
      ">;>;)",
      "Ljava/lang/String;"
    }
  .end annotation
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/io/IOException;
    }
  .end annotation
  .registers 10
  .line 110
    const-string v0, "id"
    invoke-static { p1, v0 }, Lteec/shell/term_shell/runtime/MachineEngine;->value(Ljava/util/Map;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
  .line 111
    const-string v2, "source"
    invoke-static { p1, v2 }, Lteec/shell/term_shell/runtime/MachineEngine;->value(Ljava/util/Map;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v3
  .line 112
    const-string v4, "cwd"
    invoke-static { p1, v4 }, Lteec/shell/term_shell/runtime/MachineEngine;->value(Ljava/util/Map;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v5
  .line 113
    const-string v6, "arg"
    invoke-interface { p1, v6 }, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object p1
    check-cast p1, Ljava/util/List;
  .line 114
    invoke-virtual { v1 }, Ljava/lang/String;->isEmpty()Z
    move-result v6
    if-nez v6, :L3
    invoke-virtual { v3 }, Ljava/lang/String;->isEmpty()Z
    move-result v6
    if-nez v6, :L3
    const-string v6, "/"
    invoke-virtual { v5, v6 }, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v6
    if-eqz v6, :L3
    if-eqz p1, :L3
    invoke-interface { p1 }, Ljava/util/List;->isEmpty()Z
    move-result v6
    if-nez v6, :L3
    const/4 v6, 0
    invoke-interface { p1, v6 }, Ljava/util/List;->get(I)Ljava/lang/Object;
    move-result-object v7
    check-cast v7, Ljava/lang/String;
    invoke-virtual { v7 }, Ljava/lang/String;->isEmpty()Z
    move-result v7
    if-nez v7, :L3
  .line 115
    iget-object v7, p0, Lteec/shell/term_shell/runtime/MachineEngine;->orders:Ljava/util/Map;
    invoke-interface { v7, v1 }, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z
    move-result v7
    if-nez v7, :L2
  .line 116
    new-instance v7, Ljava/util/Properties;
    invoke-direct { v7 }, Ljava/util/Properties;-><init>()V
  .line 117
    invoke-virtual { v7, v0, v1 }, Ljava/util/Properties;->setProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Object;
    invoke-virtual { v7, v2, v3 }, Ljava/util/Properties;->setProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Object;
    invoke-virtual { v7, v4, v5 }, Ljava/util/Properties;->setProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Object;
  .line 118
    invoke-static { }, Ljava/lang/System;->currentTimeMillis()J
    move-result-wide v2
    invoke-static { v2, v3 }, Ljava/lang/Long;->toString(J)Ljava/lang/String;
    move-result-object v0
    const-string v2, "created"
    invoke-virtual { v7, v2, v0 }, Ljava/util/Properties;->setProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Object;
  .line 119
    const-string v0, "status"
    const-string v2, "queued"
    invoke-virtual { v7, v0, v2 }, Ljava/util/Properties;->setProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Object;
    const-string v0, "checklist"
    const-string v2, "pending"
    invoke-virtual { v7, v0, v2 }, Ljava/util/Properties;->setProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Object;
  .line 120
    invoke-interface { p1 }, Ljava/util/List;->size()I
    move-result v0
    invoke-static { v0 }, Ljava/lang/Integer;->toString(I)Ljava/lang/String;
    move-result-object v0
    const-string v2, "argc"
    invoke-virtual { v7, v2, v0 }, Ljava/util/Properties;->setProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Object;
  .line 121
    nop
  :L0
    invoke-interface { p1 }, Ljava/util/List;->size()I
    move-result v0
    if-ge v6, v0, :L1
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct { v0 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "arg."
    invoke-virtual { v0, v2 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual { v0, v6 }, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual { v0 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-interface { p1, v6 }, Ljava/util/List;->get(I)Ljava/lang/Object;
    move-result-object v2
    check-cast v2, Ljava/lang/String;
    invoke-virtual { v7, v0, v2 }, Ljava/util/Properties;->setProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Object;
    add-int/lit8 v6, v6, 1
    goto :L0
  :L1
  .line 122
    new-instance p1, Lteec/shell/term_shell/runtime/MachineEngine$Order;
    new-instance v0, Ljava/io/File;
    iget-object v2, p0, Lteec/shell/term_shell/runtime/MachineEngine;->directory:Ljava/io/File;
    sget-object v3, Ljava/util/Locale;->ROOT:Ljava/util/Locale;
    invoke-static { }, Ljava/lang/System;->currentTimeMillis()J
    move-result-wide v4
    invoke-static { v4, v5 }, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;
    move-result-object v4
    invoke-static { }, Ljava/util/UUID;->randomUUID()Ljava/util/UUID;
    move-result-object v5
    filled-new-array { v4, v5 }, [Ljava/lang/Object;
    move-result-object v4
    const-string v5, "%019d-%s.order"
    invoke-static { v3, v5, v4 }, Ljava/lang/String;->format(Ljava/util/Locale;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;
    move-result-object v3
    invoke-direct { v0, v2, v3 }, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    invoke-direct { p1, p0, v0, v7 }, Lteec/shell/term_shell/runtime/MachineEngine$Order;-><init>(Lteec/shell/term_shell/runtime/MachineEngine;Ljava/io/File;Ljava/util/Properties;)V
  .line 123
    invoke-virtual { p1 }, Lteec/shell/term_shell/runtime/MachineEngine$Order;->save()V
  .line 124
    iget-object v0, p0, Lteec/shell/term_shell/runtime/MachineEngine;->orders:Ljava/util/Map;
    invoke-interface { v0, v1, p1 }, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
  .line 125
    iget-object v0, p0, Lteec/shell/term_shell/runtime/MachineEngine;->workers:Ljava/util/concurrent/ExecutorService;
    new-instance v1, Lteec/shell/term_shell/runtime/MachineEngine$2;
    invoke-direct { v1, p0, p1 }, Lteec/shell/term_shell/runtime/MachineEngine$2;-><init>(Lteec/shell/term_shell/runtime/MachineEngine;Lteec/shell/term_shell/runtime/MachineEngine$Order;)V
    invoke-interface { v0, v1 }, Ljava/util/concurrent/ExecutorService;->execute(Ljava/lang/Runnable;)V
  .line 126
    invoke-virtual { p1 }, Lteec/shell/term_shell/runtime/MachineEngine$Order;->json()Ljava/lang/String;
    move-result-object p1
    return-object p1
  :L2
  .line 115
    new-instance p1, Ljava/io/IOException;
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct { v0 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "Opdracht-ID bestaat al: "
    invoke-virtual { v0, v2 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual { v0 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-direct { p1, v0 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p1
  :L3
  .line 114
    new-instance p1, Ljava/io/IOException;
    const-string v0, "id, source, absoluut cwd en herhaalde arg vereist"
    invoke-direct { p1, v0 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p1
.end method

.method private summary()Ljava/lang/String;
  .registers 13
  .line 187
    new-instance v0, Ljava/util/LinkedHashMap;
    invoke-direct { v0 }, Ljava/util/LinkedHashMap;-><init>()V
  .line 188
    const-string v1, "failed"
    const-string v2, "interrupted"
    const-string v3, "queued"
    const-string v4, "running"
    const-string v5, "done"
    filled-new-array { v3, v4, v5, v1, v2 }, [Ljava/lang/String;
    move-result-object v1
    invoke-static { v1 }, Ljava/util/Arrays;->asList([Ljava/lang/Object;)Ljava/util/List;
    move-result-object v1
    invoke-interface { v1 }, Ljava/util/List;->iterator()Ljava/util/Iterator;
    move-result-object v1
  :L0
    invoke-interface { v1 }, Ljava/util/Iterator;->hasNext()Z
    move-result v2
    if-eqz v2, :L1
    invoke-interface { v1 }, Ljava/util/Iterator;->next()Ljava/lang/Object;
    move-result-object v2
    check-cast v2, Ljava/lang/String;
    const/4 v3, 0
    invoke-static { v3 }, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;
    move-result-object v3
    invoke-interface { v0, v2, v3 }, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
    goto :L0
  :L1
  .line 189
    nop
  .line 190
    iget-object v1, p0, Lteec/shell/term_shell/runtime/MachineEngine;->orders:Ljava/util/Map;
    invoke-interface { v1 }, Ljava/util/Map;->values()Ljava/util/Collection;
    move-result-object v1
    invoke-interface { v1 }, Ljava/util/Collection;->iterator()Ljava/util/Iterator;
    move-result-object v1
    const/4 v2, 0
  :L2
    invoke-interface { v1 }, Ljava/util/Iterator;->hasNext()Z
    move-result v3
    const-string v4, "status"
    const/4 v5, 1
    if-eqz v3, :L4
    invoke-interface { v1 }, Ljava/util/Iterator;->next()Ljava/lang/Object;
    move-result-object v2
    check-cast v2, Lteec/shell/term_shell/runtime/MachineEngine$Order;
  .line 191
    iget-object v3, v2, Lteec/shell/term_shell/runtime/MachineEngine$Order;->data:Ljava/util/Properties;
    const-string v6, "unknown"
    invoke-virtual { v3, v4, v6 }, Ljava/util/Properties;->getProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v3
  .line 192
    invoke-interface { v0, v3 }, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z
    move-result v4
    if-eqz v4, :L3
    invoke-interface { v0, v3 }, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v4
    check-cast v4, Ljava/lang/Integer;
    invoke-virtual { v4 }, Ljava/lang/Integer;->intValue()I
    move-result v4
    add-int/2addr v5, v4
  :L3
    invoke-static { v5 }, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;
    move-result-object v4
    invoke-interface { v0, v3, v4 }, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
  .line 193
    nop
  .line 194
    goto :L2
  :L4
  .line 195
    new-instance v1, Ljava/lang/StringBuilder;
    const-string v3, "{\"schema\":\"teec.engine.status/1\",\"adapter\":\"not_configured\",\"orderCount\":"
    invoke-direct { v1, v3 }, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V
    iget-object v3, p0, Lteec/shell/term_shell/runtime/MachineEngine;->orders:Ljava/util/Map;
    invoke-interface { v3 }, Ljava/util/Map;->size()I
    move-result v3
    invoke-virtual { v1, v3 }, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    move-result-object v1
    const-string v3, ",\"states\":{"
    invoke-virtual { v1, v3 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v1
  .line 196
    invoke-interface { v0 }, Ljava/util/Map;->entrySet()Ljava/util/Set;
    move-result-object v0
    invoke-interface { v0 }, Ljava/util/Set;->iterator()Ljava/util/Iterator;
    move-result-object v0
  :L5
    invoke-interface { v0 }, Ljava/util/Iterator;->hasNext()Z
    move-result v3
    const/16 v6, 44
    const/16 v7, 58
    const/16 v8, 123
    if-eqz v3, :L7
    invoke-interface { v0 }, Ljava/util/Iterator;->next()Ljava/lang/Object;
    move-result-object v3
    check-cast v3, Ljava/util/Map$Entry;
  .line 197
    invoke-virtual { v1 }, Ljava/lang/StringBuilder;->length()I
    move-result v9
    sub-int/2addr v9, v5
    invoke-virtual { v1, v9 }, Ljava/lang/StringBuilder;->charAt(I)C
    move-result v9
    if-eq v9, v8, :L6
    invoke-virtual { v1, v6 }, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;
  :L6
  .line 198
    invoke-interface { v3 }, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;
    move-result-object v6
    check-cast v6, Ljava/lang/String;
    invoke-static { v6 }, Lteec/shell/term_shell/runtime/TerminalServer;->quote(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v6
    invoke-virtual { v1, v6 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v6
    invoke-virtual { v6, v7 }, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;
    move-result-object v6
    invoke-interface { v3 }, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;
    move-result-object v3
    invoke-virtual { v6, v3 }, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;
  .line 199
    goto :L5
  :L7
  .line 200
    const-string v0, "},\"latest\":"
    invoke-virtual { v1, v0 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
  .line 201
    const/16 v0, 125
    if-nez v2, :L8
    const-string v2, "null"
    invoke-virtual { v1, v2 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    goto :L12
  :L8
  .line 203
    invoke-virtual { v1, v8 }, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;
  .line 204
    const-string v3, "source"
    const-string v9, "created"
    const-string v10, "id"
    filled-new-array { v10, v3, v4, v9 }, [Ljava/lang/String;
    move-result-object v3
    invoke-static { v3 }, Ljava/util/Arrays;->asList([Ljava/lang/Object;)Ljava/util/List;
    move-result-object v3
    invoke-interface { v3 }, Ljava/util/List;->iterator()Ljava/util/Iterator;
    move-result-object v3
  :L9
    invoke-interface { v3 }, Ljava/util/Iterator;->hasNext()Z
    move-result v4
    if-eqz v4, :L11
    invoke-interface { v3 }, Ljava/util/Iterator;->next()Ljava/lang/Object;
    move-result-object v4
    check-cast v4, Ljava/lang/String;
  .line 205
    invoke-virtual { v1 }, Ljava/lang/StringBuilder;->length()I
    move-result v9
    sub-int/2addr v9, v5
    invoke-virtual { v1, v9 }, Ljava/lang/StringBuilder;->charAt(I)C
    move-result v9
    if-eq v9, v8, :L10
    invoke-virtual { v1, v6 }, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;
  :L10
  .line 206
    invoke-static { v4 }, Lteec/shell/term_shell/runtime/TerminalServer;->quote(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v9
    invoke-virtual { v1, v9 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v9
    invoke-virtual { v9, v7 }, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;
    move-result-object v9
    iget-object v10, v2, Lteec/shell/term_shell/runtime/MachineEngine$Order;->data:Ljava/util/Properties;
    const-string v11, ""
    invoke-virtual { v10, v4, v11 }, Ljava/util/Properties;->getProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v4
    invoke-static { v4 }, Lteec/shell/term_shell/runtime/TerminalServer;->quote(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v4
    invoke-virtual { v9, v4 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
  .line 207
    goto :L9
  :L11
  .line 208
    invoke-virtual { v1, v0 }, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;
  :L12
  .line 210
    invoke-virtual { v1, v0 }, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual { v0 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method

.method private static value(Ljava/util/Map;Ljava/lang/String;)Ljava/lang/String;
  .annotation system Ldalvik/annotation/Signature;
    value = {
      "(",
      "Ljava/util/Map<",
      "Ljava/lang/String;",
      "Ljava/util/List<",
      "Ljava/lang/String;",
      ">;>;",
      "Ljava/lang/String;",
      ")",
      "Ljava/lang/String;"
    }
  .end annotation
  .registers 2
  .line 243
    invoke-interface { p0, p1 }, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object p0
    check-cast p0, Ljava/util/List;
  .line 244
    if-eqz p0, :L1
    invoke-interface { p0 }, Ljava/util/List;->isEmpty()Z
    move-result p1
    if-eqz p1, :L0
    goto :L1
  :L0
    const/4 p1, 0
    invoke-interface { p0, p1 }, Ljava/util/List;->get(I)Ljava/lang/Object;
    move-result-object p0
    check-cast p0, Ljava/lang/String;
    goto :L2
  :L1
    const-string p0, ""
  :L2
    return-object p0
.end method

.method public declared-synchronized close()V
  .catchall { :L0 .. :L2 } :L10
  .catch Ljava/io/IOException; { :L2 .. :L3 } :L4
  .catchall { :L2 .. :L3 } :L10
  .catchall { :L5 .. :L9 } :L10
  .catchall { :L11 .. :L12 } :L10
  .registers 7
    monitor-enter p0
  .line 249
    const/4 v0, 1
  :L0
    iput-boolean v0, p0, Lteec/shell/term_shell/runtime/MachineEngine;->closed:Z
  .line 250
    iget-object v0, p0, Lteec/shell/term_shell/runtime/MachineEngine;->orders:Ljava/util/Map;
    invoke-interface { v0 }, Ljava/util/Map;->values()Ljava/util/Collection;
    move-result-object v0
    invoke-interface { v0 }, Ljava/util/Collection;->iterator()Ljava/util/Iterator;
    move-result-object v0
  :L1
    invoke-interface { v0 }, Ljava/util/Iterator;->hasNext()Z
    move-result v1
    if-eqz v1, :L8
    invoke-interface { v0 }, Ljava/util/Iterator;->next()Ljava/lang/Object;
    move-result-object v1
    check-cast v1, Lteec/shell/term_shell/runtime/MachineEngine$Order;
  .line 251
    const-string v2, "queued"
    const-string v3, "running"
    filled-new-array { v2, v3 }, [Ljava/lang/String;
    move-result-object v2
    invoke-static { v2 }, Ljava/util/Arrays;->asList([Ljava/lang/Object;)Ljava/util/List;
    move-result-object v2
    iget-object v3, v1, Lteec/shell/term_shell/runtime/MachineEngine$Order;->data:Ljava/util/Properties;
    const-string v4, "status"
    invoke-virtual { v3, v4 }, Ljava/util/Properties;->getProperty(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v3
    invoke-interface { v2, v3 }, Ljava/util/List;->contains(Ljava/lang/Object;)Z
    move-result v2
    if-eqz v2, :L6
  .line 252
    iget-object v2, v1, Lteec/shell/term_shell/runtime/MachineEngine$Order;->data:Ljava/util/Properties;
    const-string v3, "status"
    const-string v4, "interrupted"
    invoke-virtual { v2, v3, v4 }, Ljava/util/Properties;->setProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Object;
  .line 253
    iget-object v2, v1, Lteec/shell/term_shell/runtime/MachineEngine$Order;->data:Ljava/util/Properties;
    const-string v3, "finished"
    invoke-static { }, Ljava/lang/System;->currentTimeMillis()J
    move-result-wide v4
    invoke-static { v4, v5 }, Ljava/lang/Long;->toString(J)Ljava/lang/String;
    move-result-object v4
    invoke-virtual { v2, v3, v4 }, Ljava/util/Properties;->setProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Object;
  :L2
  .line 254
    invoke-virtual { v1 }, Lteec/shell/term_shell/runtime/MachineEngine$Order;->save()V
  :L3
    goto :L6
  :L4
    move-exception v2
  :L5
    iget-object v3, v1, Lteec/shell/term_shell/runtime/MachineEngine$Order;->data:Ljava/util/Properties;
    const-string v4, "error"
    invoke-virtual { v2 }, Ljava/io/IOException;->toString()Ljava/lang/String;
    move-result-object v2
    invoke-virtual { v3, v4, v2 }, Ljava/util/Properties;->setProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Object;
  :L6
  .line 256
    iget-object v2, v1, Lteec/shell/term_shell/runtime/MachineEngine$Order;->process:Ljava/lang/Process;
    if-eqz v2, :L7
    iget-object v2, v1, Lteec/shell/term_shell/runtime/MachineEngine$Order;->process:Ljava/lang/Process;
    invoke-virtual { v2 }, Ljava/lang/Process;->isAlive()Z
    move-result v2
    if-eqz v2, :L7
    iget-object v1, v1, Lteec/shell/term_shell/runtime/MachineEngine$Order;->process:Ljava/lang/Process;
    invoke-virtual { v1 }, Ljava/lang/Process;->destroy()V
  :L7
  .line 257
    goto :L1
  :L8
  .line 258
    iget-object v0, p0, Lteec/shell/term_shell/runtime/MachineEngine;->workers:Ljava/util/concurrent/ExecutorService;
    invoke-interface { v0 }, Ljava/util/concurrent/ExecutorService;->shutdown()V
  :L9
  .line 259
    monitor-exit p0
    return-void
  :L10
  .line 248
    move-exception v0
  :L11
    monitor-exit p0
  :L12
    throw v0
.end method

.method synthetic lambda$execute$2$teec-shell-term_shell-runtime-MachineEngine(Lteec/shell/term_shell/runtime/MachineEngine$Order;)V
  .registers 4
  .line 142
    iget-object v0, p1, Lteec/shell/term_shell/runtime/MachineEngine$Order;->process:Ljava/lang/Process;
    invoke-virtual { v0 }, Ljava/lang/Process;->getErrorStream()Ljava/io/InputStream;
    move-result-object v0
    const-string v1, "stderr"
    invoke-direct { p0, p1, v0, v1 }, Lteec/shell/term_shell/runtime/MachineEngine;->copyStream(Lteec/shell/term_shell/runtime/MachineEngine$Order;Ljava/io/InputStream;Ljava/lang/String;)V
    return-void
.end method

.method synthetic lambda$submit$1$teec-shell-term_shell-runtime-MachineEngine(Lteec/shell/term_shell/runtime/MachineEngine$Order;)V
  .registers 2
  .line 125
    invoke-direct { p0, p1 }, Lteec/shell/term_shell/runtime/MachineEngine;->execute(Lteec/shell/term_shell/runtime/MachineEngine$Order;)V
    return-void
.end method

.method public declared-synchronized request(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/io/IOException;
    }
  .end annotation
  .catch Ljava/lang/IllegalArgumentException; { :L0 .. :L2 } :L26
  .catchall { :L0 .. :L2 } :L25
  .catch Ljava/lang/IllegalArgumentException; { :L3 .. :L5 } :L26
  .catchall { :L3 .. :L5 } :L25
  .catch Ljava/lang/IllegalArgumentException; { :L6 .. :L8 } :L26
  .catchall { :L6 .. :L8 } :L25
  .catch Ljava/lang/IllegalArgumentException; { :L9 .. :L22 } :L26
  .catchall { :L9 .. :L22 } :L25
  .catch Ljava/lang/IllegalArgumentException; { :L23 .. :L25 } :L26
  .catchall { :L23 .. :L25 } :L25
  .catchall { :L27 .. :L29 } :L25
  .registers 11
    monitor-enter p0
  :L0
  .line 81
    iget-boolean v0, p0, Lteec/shell/term_shell/runtime/MachineEngine;->closed:Z
    if-nez v0, :L24
  .line 82
    const-string v0, "GET"
    invoke-virtual { p1, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-nez v0, :L1
    const-string v0, "HEAD"
    invoke-virtual { p1, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :L3
  :L1
    const-string v0, "/control/summary"
    invoke-virtual { p2, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :L3
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/MachineEngine;->summary()Ljava/lang/String;
    move-result-object p1
  :L2
    monitor-exit p0
    return-object p1
  :L3
  .line 83
    const-string v0, "GET"
    invoke-virtual { p1, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-nez v0, :L4
    const-string v0, "HEAD"
    invoke-virtual { p1, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :L7
  :L4
    const-string v0, "/control/orders/"
    invoke-virtual { p2, v0 }, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v0
    if-eqz v0, :L7
  .line 84
    iget-object p1, p0, Lteec/shell/term_shell/runtime/MachineEngine;->orders:Ljava/util/Map;
    const-string p3, "/control/orders/"
    invoke-virtual { p3 }, Ljava/lang/String;->length()I
    move-result p3
    invoke-virtual { p2, p3 }, Ljava/lang/String;->substring(I)Ljava/lang/String;
    move-result-object p2
    invoke-interface { p1, p2 }, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object p1
    check-cast p1, Lteec/shell/term_shell/runtime/MachineEngine$Order;
  .line 85
    if-eqz p1, :L6
  .line 86
    invoke-virtual { p1 }, Lteec/shell/term_shell/runtime/MachineEngine$Order;->json()Ljava/lang/String;
    move-result-object p1
  :L5
    monitor-exit p0
    return-object p1
  :L6
  .line 85
    new-instance p1, Ljava/io/IOException;
    const-string p2, "Onbekend opdracht-ID"
    invoke-direct { p1, p2 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p1
  :L7
  .line 88
    invoke-static { p3 }, Lteec/shell/term_shell/runtime/MachineEngine;->form(Ljava/lang/String;)Ljava/util/Map;
    move-result-object p3
  .line 89
    const-string v0, "POST"
    invoke-virtual { p1, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :L9
    const-string v0, "/control/orders"
    invoke-virtual { p2, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :L9
    invoke-direct { p0, p3 }, Lteec/shell/term_shell/runtime/MachineEngine;->submit(Ljava/util/Map;)Ljava/lang/String;
    move-result-object p1
  :L8
    monitor-exit p0
    return-object p1
  :L9
  .line 90
    const-string v0, "POST"
    invoke-virtual { p1, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :L15
    const-string v0, "/control/settings"
    invoke-virtual { p2, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :L15
  .line 91
    invoke-interface { p3 }, Ljava/util/Map;->keySet()Ljava/util/Set;
    move-result-object p1
    invoke-interface { p1 }, Ljava/util/Set;->iterator()Ljava/util/Iterator;
    move-result-object p1
  :L10
    invoke-interface { p1 }, Ljava/util/Iterator;->hasNext()Z
    move-result v0
    if-eqz v0, :L12
    invoke-interface { p1 }, Ljava/util/Iterator;->next()Ljava/lang/Object;
    move-result-object v0
    check-cast v0, Ljava/lang/String;
  .line 92
    const-string v1, "mode"
    const-string v2, "model"
    const-string v3, "reasoning"
    const-string v4, "skills"
    const-string v5, "hooks"
    const-string v6, "instructions"
    filled-new-array/range { v1 .. v6 }, [Ljava/lang/String;
    move-result-object v1
    invoke-static { v1 }, Ljava/util/Arrays;->asList([Ljava/lang/Object;)Ljava/util/List;
    move-result-object v1
    invoke-interface { v1, v0 }, Ljava/util/List;->contains(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :L11
  .line 93
    goto :L10
  :L11
  .line 92
    new-instance p1, Ljava/io/IOException;
    new-instance p2, Ljava/lang/StringBuilder;
    invoke-direct { p2 }, Ljava/lang/StringBuilder;-><init>()V
    const-string p3, "Onbekende setting: "
    invoke-virtual { p2, p3 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p2
    invoke-virtual { p2, v0 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p2
    invoke-virtual { p2 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object p2
    invoke-direct { p1, p2 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p1
  :L12
  .line 94
    invoke-interface { p3 }, Ljava/util/Map;->keySet()Ljava/util/Set;
    move-result-object p1
    invoke-interface { p1 }, Ljava/util/Set;->iterator()Ljava/util/Iterator;
    move-result-object p1
  :L13
    invoke-interface { p1 }, Ljava/util/Iterator;->hasNext()Z
    move-result v0
    if-eqz v0, :L14
    invoke-interface { p1 }, Ljava/util/Iterator;->next()Ljava/lang/Object;
    move-result-object v0
    check-cast v0, Ljava/lang/String;
    iget-object v1, p0, Lteec/shell/term_shell/runtime/MachineEngine;->settings:Ljava/util/Properties;
    invoke-static { p3, v0 }, Lteec/shell/term_shell/runtime/MachineEngine;->value(Ljava/util/Map;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2
    invoke-virtual { v1, v0, v2 }, Ljava/util/Properties;->setProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Object;
    goto :L13
  :L14
  .line 95
    new-instance p1, Ljava/io/File;
    iget-object p3, p0, Lteec/shell/term_shell/runtime/MachineEngine;->directory:Ljava/io/File;
    const-string v0, "settings.properties"
    invoke-direct { p1, p3, v0 }, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    iget-object p3, p0, Lteec/shell/term_shell/runtime/MachineEngine;->settings:Ljava/util/Properties;
    invoke-static { p1, p3 }, Lteec/shell/term_shell/runtime/MachineEngine;->store(Ljava/io/File;Ljava/util/Properties;)V
    goto :L21
  :L15
  .line 96
    const-string v0, "POST"
    invoke-virtual { p1, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :L18
    const-string v0, "/control/checklist"
    invoke-virtual { p2, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :L18
  .line 97
    iget-object p1, p0, Lteec/shell/term_shell/runtime/MachineEngine;->orders:Ljava/util/Map;
    const-string v0, "id"
    invoke-static { p3, v0 }, Lteec/shell/term_shell/runtime/MachineEngine;->value(Ljava/util/Map;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    invoke-interface { p1, v0 }, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object p1
    check-cast p1, Lteec/shell/term_shell/runtime/MachineEngine$Order;
  .line 98
    if-eqz p1, :L17
  .line 99
    const-string v0, "state"
    invoke-static { p3, v0 }, Lteec/shell/term_shell/runtime/MachineEngine;->value(Ljava/util/Map;Ljava/lang/String;)Ljava/lang/String;
    move-result-object p3
  .line 100
    const-string v0, "pending"
    const-string v1, "true"
    const-string v2, "false"
    filled-new-array { v0, v1, v2 }, [Ljava/lang/String;
    move-result-object v0
    invoke-static { v0 }, Ljava/util/Arrays;->asList([Ljava/lang/Object;)Ljava/util/List;
    move-result-object v0
    invoke-interface { v0, p3 }, Ljava/util/List;->contains(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :L16
  .line 101
    iget-object v0, p1, Lteec/shell/term_shell/runtime/MachineEngine$Order;->data:Ljava/util/Properties;
    const-string v1, "checklist"
    invoke-virtual { v0, v1, p3 }, Ljava/util/Properties;->setProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Object;
  .line 102
    invoke-virtual { p1 }, Lteec/shell/term_shell/runtime/MachineEngine$Order;->save()V
    goto :L20
  :L16
  .line 100
    new-instance p1, Ljava/io/IOException;
    const-string p2, "Checklist: pending, true of false vereist"
    invoke-direct { p1, p2 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p1
  :L17
  .line 98
    new-instance p1, Ljava/io/IOException;
    const-string p2, "Onbekend opdracht-ID"
    invoke-direct { p1, p2 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p1
  :L18
  .line 103
    const-string p3, "GET"
    invoke-virtual { p1, p3 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p3
    if-nez p3, :L20
    const-string p3, "HEAD"
    invoke-virtual { p1, p3 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p1
    if-eqz p1, :L19
    goto :L20
  :L19
    new-instance p1, Ljava/io/IOException;
    const-string p2, "Onbekende engine-opdracht"
    invoke-direct { p1, p2 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p1
  :L20
    nop
  :L21
  .line 104
    const-string p1, "/control/status"
    const-string p3, "/control/settings"
    const-string v0, "/control/checklist"
    const-string v1, "/control/orders"
    filled-new-array { p1, p3, v0, v1 }, [Ljava/lang/String;
    move-result-object p1
    invoke-static { p1 }, Ljava/util/Arrays;->asList([Ljava/lang/Object;)Ljava/util/List;
    move-result-object p1
    invoke-interface { p1, p2 }, Ljava/util/List;->contains(Ljava/lang/Object;)Z
    move-result p1
    if-eqz p1, :L23
  .line 105
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/MachineEngine;->snapshot()Ljava/lang/String;
    move-result-object p1
  :L22
    monitor-exit p0
    return-object p1
  :L23
  .line 104
    new-instance p1, Ljava/io/IOException;
    const-string p2, "Onbekend engine-pad"
    invoke-direct { p1, p2 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p1
  :L24
  .line 81
    new-instance p1, Ljava/io/IOException;
    const-string p2, "Engine afgesloten"
    invoke-direct { p1, p2 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p1
  :L25
  .line 80
    move-exception v0
    move-object p1, v0
    goto :L28
  :L26
  .line 106
    move-exception v0
    move-object p1, v0
  :L27
    new-instance p2, Ljava/io/IOException;
    invoke-virtual { p1 }, Ljava/lang/IllegalArgumentException;->getMessage()Ljava/lang/String;
    move-result-object p3
    invoke-direct { p2, p3, p1 }, Ljava/io/IOException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V
    throw p2
  :L28
  .line 80
    monitor-exit p0
  :L29
    throw p1
.end method
