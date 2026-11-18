.class public final Lteec/shell/term_shell/runtime/SemanticRag;
.super Ljava/lang/Object;
.implements Ljava/io/Closeable;
.source "SemanticRag.java"

.field public final static PORT:I = 8867

.field private final base:Ljava/lang/String;

.field private cached:Lorg/json/JSONObject;

.field private checked:J

.field private volatile closed:Z

.field private volatile lifecycleError:Ljava/lang/String;

.field private nextStart:J

.field private volatile process:Ljava/lang/Process;

.field private started:Z

.field private final worker:Ljava/util/concurrent/ScheduledExecutorService;

.method public constructor <init>()V
  .registers 2
  .line 34
    const-string v0, "http://127.0.0.1:8867"
    invoke-direct { p0, v0 }, Lteec/shell/term_shell/runtime/SemanticRag;-><init>(Ljava/lang/String;)V
    return-void
.end method

.method public constructor <init>(Ljava/lang/String;)V
  .registers 3
  .line 36
    invoke-direct { p0 }, Ljava/lang/Object;-><init>()V
  .line 21
    new-instance v0, Lteec/shell/term_shell/runtime/SemanticRag$3;
    invoke-direct { v0 }, Lteec/shell/term_shell/runtime/SemanticRag$3;-><init>()V
    invoke-static { v0 }, Ljava/util/concurrent/Executors;->newSingleThreadScheduledExecutor(Ljava/util/concurrent/ThreadFactory;)Ljava/util/concurrent/ScheduledExecutorService;
    move-result-object v0
    iput-object v0, p0, Lteec/shell/term_shell/runtime/SemanticRag;->worker:Ljava/util/concurrent/ScheduledExecutorService;
  .line 29
    const-string v0, ""
    iput-object v0, p0, Lteec/shell/term_shell/runtime/SemanticRag;->lifecycleError:Ljava/lang/String;
  .line 36
    iput-object p1, p0, Lteec/shell/term_shell/runtime/SemanticRag;->base:Ljava/lang/String;
    return-void
.end method

.method private deploy(Landroid/content/Context;)V
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/io/IOException;
    }
  .end annotation
  .catchall { :L3 .. :L4 } :L27
  .catchall { :L4 .. :L5 } :L21
  .catchall { :L6 .. :L9 } :L15
  .catchall { :L9 .. :L10 } :L21
  .catchall { :L11 .. :L13 } :L27
  .catchall { :L14 .. :L15 } :L27
  .catchall { :L16 .. :L17 } :L18
  .catchall { :L19 .. :L21 } :L21
  .catchall { :L22 .. :L23 } :L24
  .catchall { :L25 .. :L27 } :L27
  .registers 13
  .line 151
    new-instance v0, Ljava/io/File;
    invoke-virtual { p1 }, Landroid/content/Context;->getFilesDir()Ljava/io/File;
    move-result-object v1
    const-string v2, "Ubuntu22.04Bare/opt/t-eec/app"
    invoke-direct { v0, v1, v2 }, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
  .line 152
    invoke-virtual { v0 }, Ljava/io/File;->isDirectory()Z
    move-result v1
    if-nez v1, :L1
    invoke-virtual { v0 }, Ljava/io/File;->mkdirs()Z
    move-result v1
    if-eqz v1, :L0
    goto :L1
  :L0
    new-instance p1, Ljava/io/IOException;
    const-string v0, "RAG-appmap ontbreekt"
    invoke-direct { p1, v0 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p1
  :L1
  .line 153
    const-string v1, "ingestion.py"
    const-string v2, "retrieval.py"
    const-string v3, "server.py"
    const-string v4, "model_runtime.py"
    filled-new-array { v3, v4, v1, v2 }, [Ljava/lang/String;
    move-result-object v1
    const/4 v2, 0
    move v3, v2
  :L2
    const/4 v4, 4
    if-ge v3, v4, :L28
    aget-object v4, v1, v3
  .line 154
    const-string v5, ".deploy-"
    const-string v6, ".tmp"
    invoke-static { v5, v6, v0 }, Ljava/io/File;->createTempFile(Ljava/lang/String;Ljava/lang/String;Ljava/io/File;)Ljava/io/File;
    move-result-object v5
  :L3
  .line 156
    invoke-virtual { p1 }, Landroid/content/Context;->getAssets()Landroid/content/res/AssetManager;
    move-result-object v6
    new-instance v7, Ljava/lang/StringBuilder;
    invoke-direct { v7 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v8, "t-eec/"
    invoke-virtual { v7, v8 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v7
    invoke-virtual { v7, v4 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v7
    invoke-virtual { v7 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v7
    invoke-virtual { v6, v7 }, Landroid/content/res/AssetManager;->open(Ljava/lang/String;)Ljava/io/InputStream;
    move-result-object v6
  :L4
    new-instance v7, Ljava/io/FileOutputStream;
    invoke-direct { v7, v5 }, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V
  :L5
  .line 157
    const/16 v8, 16384
  :L6
    new-array v8, v8, [B
  :L7
  .line 159
    invoke-virtual { v6, v8 }, Ljava/io/InputStream;->read([B)I
    move-result v9
    const/4 v10, -1
    if-eq v9, v10, :L8
    invoke-virtual { v7, v8, v2, v9 }, Ljava/io/FileOutputStream;->write([BII)V
    goto :L7
  :L8
  .line 160
    invoke-virtual { v7 }, Ljava/io/FileOutputStream;->getFD()Ljava/io/FileDescriptor;
    move-result-object v8
    invoke-virtual { v8 }, Ljava/io/FileDescriptor;->sync()V
  :L9
  .line 161
    invoke-virtual { v7 }, Ljava/io/FileOutputStream;->close()V
  :L10
    if-eqz v6, :L12
  :L11
    invoke-virtual { v6 }, Ljava/io/InputStream;->close()V
  :L12
  .line 162
    new-instance v6, Ljava/io/File;
    invoke-direct { v6, v0, v4 }, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    invoke-virtual { v5, v6 }, Ljava/io/File;->renameTo(Ljava/io/File;)Z
    move-result v6
  :L13
    if-eqz v6, :L14
  .line 163
    invoke-virtual { v5 }, Ljava/io/File;->delete()Z
  .line 153
    add-int/lit8 v3, v3, 1
    goto :L2
  :L14
  .line 162
    new-instance p1, Ljava/io/IOException;
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct { v0 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "RAG-bron kon niet worden geplaatst: "
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual { v0, v4 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual { v0 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-direct { p1, v0 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p1
  :L15
  .line 156
    move-exception p1
  :L16
    invoke-virtual { v7 }, Ljava/io/FileOutputStream;->close()V
  :L17
    goto :L20
  :L18
    move-exception v0
  :L19
    invoke-virtual { p1, v0 }, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V
  :L20
    throw p1
  :L21
    move-exception p1
    if-eqz v6, :L26
  :L22
    invoke-virtual { v6 }, Ljava/io/InputStream;->close()V
  :L23
    goto :L26
  :L24
    move-exception v0
  :L25
    invoke-virtual { p1, v0 }, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V
  :L26
    throw p1
  :L27
  .line 163
    move-exception p1
    invoke-virtual { v5 }, Ljava/io/File;->delete()Z
    throw p1
  :L28
  .line 165
    return-void
.end method

.method private drain(Ljava/io/InputStream;)V
  .registers 4
  .line 192
    new-instance v0, Ljava/lang/Thread;
    new-instance v1, Lteec/shell/term_shell/runtime/SemanticRag$2;
    invoke-direct { v1, p1 }, Lteec/shell/term_shell/runtime/SemanticRag$2;-><init>(Ljava/io/InputStream;)V
    const-string p1, "T-EEC-rag-output"
    invoke-direct { v0, v1, p1 }, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;Ljava/lang/String;)V
  .line 198
    const/4 p1, 1
    invoke-virtual { v0, p1 }, Ljava/lang/Thread;->setDaemon(Z)V
  .line 199
    invoke-virtual { v0 }, Ljava/lang/Thread;->start()V
  .line 200
    return-void
.end method

.method private exchange(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Lorg/json/JSONObject;
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/lang/Exception;
    }
  .end annotation
  .registers 5
  .line 95
    const/4 v0, 0
    invoke-direct { p0, p1, p2, p3, v0 }, Lteec/shell/term_shell/runtime/SemanticRag;->exchange(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Lorg/json/JSONObject;
    move-result-object p1
    return-object p1
.end method

.method private exchange(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Lorg/json/JSONObject;
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/lang/Exception;
    }
  .end annotation
  .catchall { :L2 .. :L3 } :L46
  .catchall { :L3 .. :L4 } :L7
  .catchall { :L5 .. :L6 } :L46
  .catchall { :L8 .. :L9 } :L10
  .catchall { :L11 .. :L17 } :L46
  .catchall { :L17 .. :L18 } :L40
  .catchall { :L19 .. :L21 } :L34
  .catch Lorg/json/JSONException; { :L22 .. :L23 } :L24
  .catchall { :L22 .. :L23 } :L34
  .catchall { :L25 .. :L28 } :L34
  .catchall { :L29 .. :L30 } :L40
  .catchall { :L31 .. :L32 } :L46
  .catchall { :L33 .. :L34 } :L34
  .catchall { :L35 .. :L36 } :L37
  .catchall { :L38 .. :L40 } :L40
  .catchall { :L41 .. :L42 } :L43
  .catchall { :L44 .. :L46 } :L46
  .registers 13
  .line 99
    const-string v0, "POST"
    new-instance v1, Ljava/net/URL;
    new-instance v2, Ljava/lang/StringBuilder;
    invoke-direct { v2 }, Ljava/lang/StringBuilder;-><init>()V
    iget-object v3, p0, Lteec/shell/term_shell/runtime/SemanticRag;->base:Ljava/lang/String;
    invoke-virtual { v2, v3 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v2
    invoke-virtual { v2, p1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p1
    invoke-virtual { p1 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object p1
    invoke-direct { v1, p1 }, Ljava/net/URL;-><init>(Ljava/lang/String;)V
    invoke-virtual { v1 }, Ljava/net/URL;->openConnection()Ljava/net/URLConnection;
    move-result-object p1
    check-cast p1, Ljava/net/HttpURLConnection;
  .line 100
    const/16 v1, 800
    invoke-virtual { p1, v1 }, Ljava/net/HttpURLConnection;->setConnectTimeout(I)V
  .line 101
    const/4 v1, 0
    if-eqz p4, :L0
    move v2, v1
    goto :L1
  :L0
    const/16 v2, 1200
  :L1
    invoke-virtual { p1, v2 }, Ljava/net/HttpURLConnection;->setReadTimeout(I)V
  .line 102
    invoke-virtual { p1, v1 }, Ljava/net/HttpURLConnection;->setUseCaches(Z)V
  .line 103
    invoke-virtual { p1, p2 }, Ljava/net/HttpURLConnection;->setRequestMethod(Ljava/lang/String;)V
  :L2
  .line 105
    invoke-virtual { p2, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-eqz v2, :L13
  .line 106
    invoke-virtual { p1, v1 }, Ljava/net/HttpURLConnection;->setReadTimeout(I)V
  .line 107
    const/4 v2, 1
    invoke-virtual { p1, v2 }, Ljava/net/HttpURLConnection;->setDoOutput(Z)V
  .line 108
    const-string v2, "Content-Type"
    const-string v3, "application/json"
    invoke-virtual { p1, v2, v3 }, Ljava/net/HttpURLConnection;->setRequestProperty(Ljava/lang/String;Ljava/lang/String;)V
  .line 109
    sget-object v2, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;
    invoke-virtual { p3, v2 }, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B
    move-result-object p3
  .line 110
    array-length v2, p3
    invoke-virtual { p1, v2 }, Ljava/net/HttpURLConnection;->setFixedLengthStreamingMode(I)V
  .line 111
    invoke-virtual { p1 }, Ljava/net/HttpURLConnection;->getOutputStream()Ljava/io/OutputStream;
    move-result-object v2
  :L3
    invoke-virtual { v2, p3 }, Ljava/io/OutputStream;->write([B)V
  :L4
    if-eqz v2, :L13
  :L5
    invoke-virtual { v2 }, Ljava/io/OutputStream;->close()V
  :L6
    goto :L13
  :L7
    move-exception p2
    if-eqz v2, :L12
  :L8
    invoke-virtual { v2 }, Ljava/io/OutputStream;->close()V
  :L9
    goto :L12
  :L10
    move-exception p3
  :L11
    invoke-virtual { p2, p3 }, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V
  :L12
    throw p2
  :L13
  .line 113
    invoke-virtual { p1 }, Ljava/net/HttpURLConnection;->getResponseCode()I
    move-result p3
  .line 114
    if-nez p4, :L15
    const-string v2, "GET"
    invoke-virtual { p2, v2 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-eqz v2, :L15
    const/16 v2, 200
    if-ne p3, v2, :L14
    goto :L15
  :L14
    new-instance p2, Ljava/io/IOException;
    new-instance p4, Ljava/lang/StringBuilder;
    invoke-direct { p4 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v0, "HTTP "
    invoke-virtual { p4, v0 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p4
    invoke-virtual { p4, p3 }, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    move-result-object p3
    invoke-virtual { p3 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object p3
    invoke-direct { p2, p3 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p2
  :L15
  .line 115
    const/16 v2, 400
    if-lt p3, v2, :L16
    invoke-virtual { p1 }, Ljava/net/HttpURLConnection;->getErrorStream()Ljava/io/InputStream;
    move-result-object v3
    goto :L17
  :L16
    invoke-virtual { p1 }, Ljava/net/HttpURLConnection;->getInputStream()Ljava/io/InputStream;
    move-result-object v3
  :L17
    new-instance v4, Ljava/io/ByteArrayOutputStream;
    invoke-direct { v4 }, Ljava/io/ByteArrayOutputStream;-><init>()V
  :L18
  .line 116
    const/16 v5, 8192
  :L19
    new-array v5, v5, [B
  :L20
  .line 118
    if-eqz v3, :L22
    invoke-virtual { v3, v5 }, Ljava/io/InputStream;->read([B)I
    move-result v6
    const/4 v7, -1
    if-eq v6, v7, :L22
    invoke-virtual { v4, v5, v1, v6 }, Ljava/io/ByteArrayOutputStream;->write([BII)V
  :L21
    goto :L20
  :L22
  .line 120
    new-instance v1, Lorg/json/JSONObject;
    new-instance v5, Ljava/lang/String;
    invoke-virtual { v4 }, Ljava/io/ByteArrayOutputStream;->toByteArray()[B
    move-result-object v6
    sget-object v7, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;
    invoke-direct { v5, v6, v7 }, Ljava/lang/String;-><init>([BLjava/nio/charset/Charset;)V
    invoke-direct { v1, v5 }, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V
  :L23
  .line 125
    goto :L26
  :L24
  .line 121
    move-exception v1
  .line 122
    if-eqz p4, :L33
  :L25
  .line 123
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct { v1 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v5, "rag_"
    invoke-virtual { v1, v5 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v1
    invoke-virtual { v1, p4 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v1
    const-string v5, "_invalid_response: HTTP "
    invoke-virtual { v1, v5 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v1
    invoke-virtual { v1, p3 }, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    move-result-object v1
    invoke-virtual { v1 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1
    invoke-static { v1 }, Lteec/shell/term_shell/runtime/SemanticRag;->failure(Ljava/lang/String;)Lorg/json/JSONObject;
    move-result-object v1
  .line 124
    if-ge p3, v2, :L26
    const/16 p3, 502
  :L26
  .line 126
    if-nez p4, :L27
    invoke-virtual { p2, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p2
    if-eqz p2, :L28
  :L27
    const-string p2, "upstream_status"
    invoke-virtual { v1, p2, p3 }, Lorg/json/JSONObject;->put(Ljava/lang/String;I)Lorg/json/JSONObject;
  :L28
  .line 127
    nop
  :L29
  .line 128
    invoke-virtual { v4 }, Ljava/io/ByteArrayOutputStream;->close()V
  :L30
    if-eqz v3, :L32
  :L31
    invoke-virtual { v3 }, Ljava/io/InputStream;->close()V
  :L32
  .line 129
    invoke-virtual { p1 }, Ljava/net/HttpURLConnection;->disconnect()V
  .line 127
    return-object v1
  :L33
  .line 122
    throw v1
  :L34
  .line 115
    move-exception p2
  :L35
    invoke-virtual { v4 }, Ljava/io/ByteArrayOutputStream;->close()V
  :L36
    goto :L39
  :L37
    move-exception p3
  :L38
    invoke-virtual { p2, p3 }, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V
  :L39
    throw p2
  :L40
    move-exception p2
    if-eqz v3, :L45
  :L41
    invoke-virtual { v3 }, Ljava/io/InputStream;->close()V
  :L42
    goto :L45
  :L43
    move-exception p3
  :L44
    invoke-virtual { p2, p3 }, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V
  :L45
    throw p2
  :L46
  .line 129
    move-exception p2
    invoke-virtual { p1 }, Ljava/net/HttpURLConnection;->disconnect()V
    throw p2
.end method

.method private static failure(Ljava/lang/String;)Lorg/json/JSONObject;
  .catch Ljava/lang/Exception; { :L0 .. :L1 } :L2
  .registers 4
  .line 133
    new-instance v0, Lorg/json/JSONObject;
    invoke-direct { v0 }, Lorg/json/JSONObject;-><init>()V
  :L0
  .line 134
    const-string v1, "ready"
    const/4 v2, 0
    invoke-virtual { v0, v1, v2 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Z)Lorg/json/JSONObject;
    const-string v1, "error"
    invoke-virtual { v0, v1, p0 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
  :L1
    goto :L3
  :L2
  .line 135
    move-exception p0
  :L3
    nop
  .line 136
    return-object v0
.end method

.method private fetch(Ljava/lang/String;)Lorg/json/JSONObject;
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/lang/Exception;
    }
  .end annotation
  .registers 4
  .line 92
    const-string v0, "GET"
    const-string v1, ""
    invoke-direct { p0, p1, v0, v1 }, Lteec/shell/term_shell/runtime/SemanticRag;->exchange(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Lorg/json/JSONObject;
    move-result-object p1
    return-object p1
.end method

.method static synthetic lambda$drain$3(Ljava/io/InputStream;)V
  .catchall { :L0 .. :L2 } :L6
  .catch Ljava/io/IOException; { :L4 .. :L5 } :L12
  .catchall { :L7 .. :L8 } :L9
  .catch Ljava/io/IOException; { :L10 .. :L12 } :L12
  .registers 4
  .line 193
    nop
  .line 194
    const/16 v0, 8192
  :L0
    new-array v0, v0, [B
  :L1
  .line 195
    invoke-virtual { p0, v0 }, Ljava/io/InputStream;->read([B)I
    move-result v1
  :L2
    const/4 v2, -1
    if-eq v1, v2, :L3
    goto :L1
  :L3
  .line 196
    if-eqz p0, :L13
  :L4
    invoke-virtual { p0 }, Ljava/io/InputStream;->close()V
  :L5
    goto :L13
  :L6
  .line 193
    move-exception v0
    if-eqz p0, :L11
  :L7
    invoke-virtual { p0 }, Ljava/io/InputStream;->close()V
  :L8
    goto :L11
  :L9
    move-exception p0
  :L10
    invoke-virtual { v0, p0 }, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V
  :L11
    throw v0
  :L12
  .line 196
    move-exception p0
  :L13
  .line 197
    return-void
.end method

.method static synthetic lambda$new$0(Ljava/lang/Runnable;)Ljava/lang/Thread;
  .registers 3
  .line 22
    new-instance v0, Ljava/lang/Thread;
    const-string v1, "T-EEC-rag"
    invoke-direct { v0, p0, v1 }, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;Ljava/lang/String;)V
  .line 23
    const/4 p0, 1
    invoke-virtual { v0, p0 }, Ljava/lang/Thread;->setDaemon(Z)V
  .line 24
    return-object v0
.end method

.method private maintain(Landroid/content/Context;Lteec/shell/term_shell/runtime/ProotCommand;)V
  .catch Ljava/lang/IllegalThreadStateException; { :L1 .. :L2 } :L3
  .catch Ljava/lang/Exception; { :L6 .. :L7 } :L8
  .catch Ljava/lang/Exception; { :L9 .. :L12 } :L12
  .registers 9
  .line 168
    iget-boolean v0, p0, Lteec/shell/term_shell/runtime/SemanticRag;->closed:Z
    if-eqz v0, :L0
    return-void
  :L0
  .line 169
    iget-object v0, p0, Lteec/shell/term_shell/runtime/SemanticRag;->process:Ljava/lang/Process;
  .line 170
    if-eqz v0, :L4
  :L1
  .line 171
    invoke-virtual { v0 }, Ljava/lang/Process;->exitValue()I
    const/4 v0, 0
    iput-object v0, p0, Lteec/shell/term_shell/runtime/SemanticRag;->process:Ljava/lang/Process;
  :L2
  .line 172
    goto :L4
  :L3
    move-exception v0
    return-void
  :L4
  .line 174
    invoke-static { }, Ljava/lang/System;->nanoTime()J
    move-result-wide v0
    iget-wide v2, p0, Lteec/shell/term_shell/runtime/SemanticRag;->nextStart:J
    cmp-long v0, v0, v2
    if-gez v0, :L5
    return-void
  :L5
  .line 175
    invoke-static { }, Ljava/lang/System;->nanoTime()J
    move-result-wide v0
    sget-object v2, Ljava/util/concurrent/TimeUnit;->SECONDS:Ljava/util/concurrent/TimeUnit;
    const-wide/16 v3, 10
    invoke-virtual { v2, v3, v4 }, Ljava/util/concurrent/TimeUnit;->toNanos(J)J
    move-result-wide v2
    add-long/2addr v0, v2
    iput-wide v0, p0, Lteec/shell/term_shell/runtime/SemanticRag;->nextStart:J
  :L6
  .line 176
    const-string v0, "/health/status"
    invoke-direct { p0, v0 }, Lteec/shell/term_shell/runtime/SemanticRag;->fetch(Ljava/lang/String;)Lorg/json/JSONObject;
  :L7
    return-void
  :L8
  .line 177
    move-exception v0
  :L9
  .line 179
    new-instance v0, Ljava/io/File;
    invoke-virtual { p1 }, Landroid/content/Context;->getFilesDir()Ljava/io/File;
    move-result-object p1
    const-string v1, "Ubuntu22.04Bare/opt/t-eec/venv/pyvenv.cfg"
    invoke-direct { v0, p1, v1 }, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
  .line 180
    invoke-virtual { v0 }, Ljava/io/File;->isFile()Z
    move-result p1
    if-eqz p1, :L11
  .line 181
    const-string v0, "/opt/t-eec/venv/bin/python"
    const-string v1, "/opt/t-eec/app/server.py"
    const-string v2, "--host"
    const-string v3, "0.0.0.0"
    const-string v4, "--port"
    const/16 p1, 8867
    invoke-static { p1 }, Ljava/lang/Integer;->toString(I)Ljava/lang/String;
    move-result-object v5
    filled-new-array/range { v0 .. v5 }, [Ljava/lang/String;
    move-result-object p1
    invoke-virtual { p2, p1 }, Lteec/shell/term_shell/runtime/ProotCommand;->process([Ljava/lang/String;)Ljava/lang/Process;
    move-result-object p1
  .line 182
    iput-object p1, p0, Lteec/shell/term_shell/runtime/SemanticRag;->process:Ljava/lang/Process;
  .line 183
    invoke-virtual { p1 }, Ljava/lang/Process;->getInputStream()Ljava/io/InputStream;
    move-result-object p2
    invoke-direct { p0, p2 }, Lteec/shell/term_shell/runtime/SemanticRag;->drain(Ljava/io/InputStream;)V
  .line 184
    invoke-virtual { p1 }, Ljava/lang/Process;->getErrorStream()Ljava/io/InputStream;
    move-result-object p2
    invoke-direct { p0, p2 }, Lteec/shell/term_shell/runtime/SemanticRag;->drain(Ljava/io/InputStream;)V
  .line 185
    invoke-virtual { p1 }, Ljava/lang/Process;->getOutputStream()Ljava/io/OutputStream;
    move-result-object p2
    invoke-virtual { p2 }, Ljava/io/OutputStream;->close()V
  .line 186
    const-string p2, ""
    iput-object p2, p0, Lteec/shell/term_shell/runtime/SemanticRag;->lifecycleError:Ljava/lang/String;
  .line 187
    iget-boolean p2, p0, Lteec/shell/term_shell/runtime/SemanticRag;->closed:Z
    if-eqz p2, :L10
    invoke-virtual { p1 }, Ljava/lang/Process;->destroy()V
  :L10
  .line 188
    goto :L13
  :L11
  .line 180
    new-instance p1, Ljava/io/IOException;
    const-string p2, "RAG Python-omgeving ontbreekt"
    invoke-direct { p1, p2 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p1
  :L12
  .line 188
    move-exception v0
    move-object p1, v0
    new-instance p2, Ljava/lang/StringBuilder;
    invoke-direct { p2 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v0, "rag_start_failed: "
    invoke-virtual { p2, v0 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p2
    invoke-virtual { p1 }, Ljava/lang/Exception;->getMessage()Ljava/lang/String;
    move-result-object p1
    invoke-virtual { p2, p1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p1
    invoke-virtual { p1 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object p1
    iput-object p1, p0, Lteec/shell/term_shell/runtime/SemanticRag;->lifecycleError:Ljava/lang/String;
  :L13
  .line 189
    return-void
.end method

.method private proxy(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Lorg/json/JSONObject;
  .catch Ljava/lang/Exception; { :L0 .. :L1 } :L2
  .catch Ljava/lang/Exception; { :L3 .. :L4 } :L5
  .registers 5
  :L0
  .line 83
    invoke-direct { p0, p1, p2, p3, p4 }, Lteec/shell/term_shell/runtime/SemanticRag;->exchange(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Lorg/json/JSONObject;
    move-result-object p1
  :L1
    return-object p1
  :L2
  .line 84
    move-exception p1
  .line 85
    new-instance p2, Ljava/lang/StringBuilder;
    invoke-direct { p2 }, Ljava/lang/StringBuilder;-><init>()V
    const-string p3, "rag_"
    invoke-virtual { p2, p3 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p2
    invoke-virtual { p2, p4 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p2
    const-string p3, "_unreachable: "
    invoke-virtual { p2, p3 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p2
    invoke-virtual { p1 }, Ljava/lang/Exception;->getMessage()Ljava/lang/String;
    move-result-object p1
    invoke-virtual { p2, p1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p1
    invoke-virtual { p1 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object p1
    invoke-static { p1 }, Lteec/shell/term_shell/runtime/SemanticRag;->failure(Ljava/lang/String;)Lorg/json/JSONObject;
    move-result-object p1
  :L3
  .line 86
    const-string p2, "upstream_status"
    const/16 p3, 502
    invoke-virtual { p1, p2, p3 }, Lorg/json/JSONObject;->put(Ljava/lang/String;I)Lorg/json/JSONObject;
  :L4
    goto :L6
  :L5
  .line 87
    move-exception p2
  :L6
    nop
  .line 88
    return-object p1
.end method

.method public close()V
  .registers 2
  .line 204
    const/4 v0, 1
    iput-boolean v0, p0, Lteec/shell/term_shell/runtime/SemanticRag;->closed:Z
  .line 205
    iget-object v0, p0, Lteec/shell/term_shell/runtime/SemanticRag;->worker:Ljava/util/concurrent/ScheduledExecutorService;
    invoke-interface { v0 }, Ljava/util/concurrent/ScheduledExecutorService;->shutdownNow()Ljava/util/List;
  .line 206
    iget-object v0, p0, Lteec/shell/term_shell/runtime/SemanticRag;->process:Ljava/lang/Process;
  .line 207
    if-eqz v0, :L0
    invoke-virtual { v0 }, Ljava/lang/Process;->destroy()V
  :L0
  .line 208
    return-void
.end method

.method public events(Ljava/lang/String;)Lorg/json/JSONObject;
  .catch Ljava/lang/Exception; { :L0 .. :L1 } :L2
  .catch Ljava/lang/Exception; { :L3 .. :L4 } :L5
  .registers 4
  :L0
  .line 57
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct { v0 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "/events"
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual { v0, p1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p1
    invoke-virtual { p1 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object p1
    invoke-direct { p0, p1 }, Lteec/shell/term_shell/runtime/SemanticRag;->fetch(Ljava/lang/String;)Lorg/json/JSONObject;
    move-result-object p1
  :L1
    return-object p1
  :L2
  .line 58
    move-exception p1
  .line 59
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct { v0 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "rag_events_unreachable: "
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual { p1 }, Ljava/lang/Exception;->getMessage()Ljava/lang/String;
    move-result-object p1
    invoke-virtual { v0, p1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p1
    invoke-virtual { p1 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object p1
    invoke-static { p1 }, Lteec/shell/term_shell/runtime/SemanticRag;->failure(Ljava/lang/String;)Lorg/json/JSONObject;
    move-result-object p1
  :L3
  .line 60
    const-string v0, "events"
    new-instance v1, Lorg/json/JSONArray;
    invoke-direct { v1 }, Lorg/json/JSONArray;-><init>()V
    invoke-virtual { p1, v0, v1 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    const-string v0, "cursor"
    const/4 v1, 0
    invoke-virtual { p1, v0, v1 }, Lorg/json/JSONObject;->put(Ljava/lang/String;I)Lorg/json/JSONObject;
    const-string v0, "snapshot"
    invoke-virtual { p0 }, Lteec/shell/term_shell/runtime/SemanticRag;->status()Lorg/json/JSONObject;
    move-result-object v1
    invoke-virtual { p1, v0, v1 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
  :L4
    goto :L6
  :L5
  .line 61
    move-exception v0
  :L6
    nop
  .line 62
    return-object p1
.end method

.method public ingest(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Lorg/json/JSONObject;
  .registers 5
  .line 75
    const-string v0, "ingest"
    invoke-direct { p0, p1, p2, p3, v0 }, Lteec/shell/term_shell/runtime/SemanticRag;->proxy(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Lorg/json/JSONObject;
    move-result-object p1
    return-object p1
.end method

.method synthetic lambda$start$1$teec-shell-term_shell-runtime-SemanticRag(Landroid/content/Context;)V
  .catch Ljava/lang/Exception; { :L0 .. :L1 } :L2
  .registers 4
  :L0
  .line 144
    invoke-direct { p0, p1 }, Lteec/shell/term_shell/runtime/SemanticRag;->deploy(Landroid/content/Context;)V
  :L1
  .line 145
    goto :L3
  :L2
    move-exception p1
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct { v0 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "rag_deploy_failed: "
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual { p1 }, Ljava/lang/Exception;->getMessage()Ljava/lang/String;
    move-result-object p1
    invoke-virtual { v0, p1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p1
    invoke-virtual { p1 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object p1
    iput-object p1, p0, Lteec/shell/term_shell/runtime/SemanticRag;->lifecycleError:Ljava/lang/String;
  :L3
  .line 146
    return-void
.end method

.method synthetic lambda$start$2$teec-shell-term_shell-runtime-SemanticRag(Landroid/content/Context;Lteec/shell/term_shell/runtime/ProotCommand;)V
  .registers 3
  .line 147
    invoke-direct { p0, p1, p2 }, Lteec/shell/term_shell/runtime/SemanticRag;->maintain(Landroid/content/Context;Lteec/shell/term_shell/runtime/ProotCommand;)V
    return-void
.end method

.method public query(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Lorg/json/JSONObject;
  .registers 5
  .line 79
    const-string v0, "query"
    invoke-direct { p0, p1, p2, p3, v0 }, Lteec/shell/term_shell/runtime/SemanticRag;->proxy(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Lorg/json/JSONObject;
    move-result-object p1
    return-object p1
.end method

.method public declared-synchronized refreshStatus()Lorg/json/JSONObject;
  .catchall { :L0 .. :L1 } :L2
  .catchall { :L3 .. :L4 } :L2
  .registers 3
    monitor-enter p0
  .line 39
    const-wide/16 v0, 0
  :L0
    iput-wide v0, p0, Lteec/shell/term_shell/runtime/SemanticRag;->checked:J
  .line 40
    invoke-virtual { p0 }, Lteec/shell/term_shell/runtime/SemanticRag;->status()Lorg/json/JSONObject;
    move-result-object v0
  :L1
    monitor-exit p0
    return-object v0
  :L2
  .line 38
    move-exception v0
  :L3
    monitor-exit p0
  :L4
    throw v0
.end method

.method public run(Ljava/lang/String;Ljava/lang/String;)Lorg/json/JSONObject;
  .catch Ljava/lang/Exception; { :L0 .. :L1 } :L5
  .catchall { :L2 .. :L4 } :L3
  .catch Ljava/lang/Exception; { :L4 .. :L5 } :L5
  .registers 5
  :L0
  .line 68
    const-string v0, "POST"
    invoke-direct { p0, p1, v0, p2 }, Lteec/shell/term_shell/runtime/SemanticRag;->exchange(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Lorg/json/JSONObject;
    move-result-object p1
  .line 69
    monitor-enter p0
  :L1
    const-wide/16 v0, 0
  :L2
    iput-wide v0, p0, Lteec/shell/term_shell/runtime/SemanticRag;->checked:J
    monitor-exit p0
  .line 70
    return-object p1
  :L3
  .line 69
    move-exception p1
    monitor-exit p0
  :L4
    throw p1
  :L5
  .line 71
    move-exception p1
    new-instance p2, Ljava/lang/StringBuilder;
    invoke-direct { p2 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v0, "rag_operation_failed: "
    invoke-virtual { p2, v0 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p2
    invoke-virtual { p1 }, Ljava/lang/Exception;->getMessage()Ljava/lang/String;
    move-result-object p1
    invoke-virtual { p2, p1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p1
    invoke-virtual { p1 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object p1
    invoke-static { p1 }, Lteec/shell/term_shell/runtime/SemanticRag;->failure(Ljava/lang/String;)Lorg/json/JSONObject;
    move-result-object p1
    return-object p1
.end method

.method public declared-synchronized start(Landroid/content/Context;Lteec/shell/term_shell/runtime/ProotCommand;)V
  .catchall { :L0 .. :L2 } :L4
  .catchall { :L5 .. :L6 } :L4
  .registers 12
    monitor-enter p0
  :L0
  .line 140
    iget-boolean v0, p0, Lteec/shell/term_shell/runtime/SemanticRag;->started:Z
    if-nez v0, :L3
    iget-boolean v0, p0, Lteec/shell/term_shell/runtime/SemanticRag;->closed:Z
    if-eqz v0, :L1
    goto :L3
  :L1
  .line 141
    const/4 v0, 1
    iput-boolean v0, p0, Lteec/shell/term_shell/runtime/SemanticRag;->started:Z
  .line 142
    invoke-virtual { p1 }, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;
    move-result-object p1
  .line 143
    iget-object v0, p0, Lteec/shell/term_shell/runtime/SemanticRag;->worker:Ljava/util/concurrent/ScheduledExecutorService;
    new-instance v1, Lteec/shell/term_shell/runtime/SemanticRag$0;
    invoke-direct { v1, p0, p1 }, Lteec/shell/term_shell/runtime/SemanticRag$0;-><init>(Lteec/shell/term_shell/runtime/SemanticRag;Landroid/content/Context;)V
    invoke-interface { v0, v1 }, Ljava/util/concurrent/ScheduledExecutorService;->execute(Ljava/lang/Runnable;)V
  .line 147
    iget-object v2, p0, Lteec/shell/term_shell/runtime/SemanticRag;->worker:Ljava/util/concurrent/ScheduledExecutorService;
    new-instance v3, Lteec/shell/term_shell/runtime/SemanticRag$1;
    invoke-direct { v3, p0, p1, p2 }, Lteec/shell/term_shell/runtime/SemanticRag$1;-><init>(Lteec/shell/term_shell/runtime/SemanticRag;Landroid/content/Context;Lteec/shell/term_shell/runtime/ProotCommand;)V
    sget-object v8, Ljava/util/concurrent/TimeUnit;->SECONDS:Ljava/util/concurrent/TimeUnit;
    const-wide/16 v4, 0
    const-wide/16 v6, 2
    invoke-interface/range { v2 .. v8 }, Ljava/util/concurrent/ScheduledExecutorService;->scheduleWithFixedDelay(Ljava/lang/Runnable;JJLjava/util/concurrent/TimeUnit;)Ljava/util/concurrent/ScheduledFuture;
  :L2
  .line 148
    monitor-exit p0
    return-void
  :L3
  .line 140
    monitor-exit p0
    return-void
  :L4
  .line 139
    move-exception v0
    move-object p1, v0
  :L5
    monitor-exit p0
  :L6
    throw p1
.end method

.method public declared-synchronized status()Lorg/json/JSONObject;
  .catchall { :L0 .. :L1 } :L14
  .catch Ljava/lang/Exception; { :L2 .. :L3 } :L4
  .catchall { :L2 .. :L3 } :L14
  .catchall { :L5 .. :L9 } :L14
  .catch Ljava/lang/Exception; { :L9 .. :L10 } :L11
  .catchall { :L9 .. :L10 } :L14
  .catchall { :L12 .. :L13 } :L14
  .catchall { :L15 .. :L16 } :L14
  .registers 6
    monitor-enter p0
  :L0
  .line 44
    invoke-static { }, Ljava/lang/System;->nanoTime()J
    move-result-wide v0
  .line 45
    iget-object v2, p0, Lteec/shell/term_shell/runtime/SemanticRag;->cached:Lorg/json/JSONObject;
    if-eqz v2, :L2
    iget-wide v2, p0, Lteec/shell/term_shell/runtime/SemanticRag;->checked:J
    sub-long/2addr v0, v2
    sget-object v2, Ljava/util/concurrent/TimeUnit;->MILLISECONDS:Ljava/util/concurrent/TimeUnit;
    const-wide/16 v3, 500
    invoke-virtual { v2, v3, v4 }, Ljava/util/concurrent/TimeUnit;->toNanos(J)J
    move-result-wide v2
  :L1
    cmp-long v0, v0, v2
    if-ltz v0, :L9
  :L2
  .line 46
    const-string v0, "/health/status"
    invoke-direct { p0, v0 }, Lteec/shell/term_shell/runtime/SemanticRag;->fetch(Ljava/lang/String;)Lorg/json/JSONObject;
    move-result-object v0
    iput-object v0, p0, Lteec/shell/term_shell/runtime/SemanticRag;->cached:Lorg/json/JSONObject;
  :L3
  .line 49
    goto :L8
  :L4
  .line 47
    move-exception v0
  :L5
  .line 48
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct { v1 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "rag_unreachable: "
    invoke-virtual { v1, v2 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v1
    invoke-virtual { v0 }, Ljava/lang/Exception;->getMessage()Ljava/lang/String;
    move-result-object v0
    invoke-virtual { v1, v0 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    iget-object v1, p0, Lteec/shell/term_shell/runtime/SemanticRag;->lifecycleError:Ljava/lang/String;
    invoke-virtual { v1 }, Ljava/lang/String;->isEmpty()Z
    move-result v1
    if-eqz v1, :L6
    const-string v1, ""
    goto :L7
  :L6
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct { v1 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "; "
    invoke-virtual { v1, v2 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v1
    iget-object v2, p0, Lteec/shell/term_shell/runtime/SemanticRag;->lifecycleError:Ljava/lang/String;
    invoke-virtual { v1, v2 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v1
    invoke-virtual { v1 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1
  :L7
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual { v0 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-static { v0 }, Lteec/shell/term_shell/runtime/SemanticRag;->failure(Ljava/lang/String;)Lorg/json/JSONObject;
    move-result-object v0
    iput-object v0, p0, Lteec/shell/term_shell/runtime/SemanticRag;->cached:Lorg/json/JSONObject;
  :L8
  .line 50
    invoke-static { }, Ljava/lang/System;->nanoTime()J
    move-result-wide v0
    iput-wide v0, p0, Lteec/shell/term_shell/runtime/SemanticRag;->checked:J
  :L9
  .line 52
    new-instance v0, Lorg/json/JSONObject;
    iget-object v1, p0, Lteec/shell/term_shell/runtime/SemanticRag;->cached:Lorg/json/JSONObject;
    invoke-virtual { v1 }, Lorg/json/JSONObject;->toString()Ljava/lang/String;
    move-result-object v1
    invoke-direct { v0, v1 }, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V
  :L10
    monitor-exit p0
    return-object v0
  :L11
  .line 53
    move-exception v0
  :L12
    const-string v0, "rag_invalid_status"
    invoke-static { v0 }, Lteec/shell/term_shell/runtime/SemanticRag;->failure(Ljava/lang/String;)Lorg/json/JSONObject;
    move-result-object v0
  :L13
    monitor-exit p0
    return-object v0
  :L14
  .line 43
    move-exception v0
  :L15
    monitor-exit p0
  :L16
    throw v0
.end method
