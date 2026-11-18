.class public final Lteec/shell/term_shell/runtime/TerminalServer;
.super Ljava/lang/Object;
.implements Ljava/io/Closeable;
.source "TerminalServer.java"

.annotation system Ldalvik/annotation/MemberClasses;
  value = {
    Lteec/shell/term_shell/runtime/TerminalServer$State;,
    Lteec/shell/term_shell/runtime/TerminalServer$Provider;,
    Lteec/shell/term_shell/runtime/TerminalServer$Assets;,
    Lteec/shell/term_shell/runtime/TerminalServer$Control;,
    Lteec/shell/term_shell/runtime/TerminalServer$Admission;,
    Lteec/shell/term_shell/runtime/TerminalServer$Connection;,
    Lteec/shell/term_shell/runtime/TerminalServer$AdmissionDenied;,
    Lteec/shell/term_shell/runtime/TerminalServer$Preflight;
  }
.end annotation

.field private final assets:Lteec/shell/term_shell/runtime/TerminalServer$Assets;

.field private final clients:Ljava/util/concurrent/ExecutorService;

.field private volatile closed:Z

.field private final control:Lteec/shell/term_shell/runtime/TerminalServer$Control;

.field private final files:Lteec/shell/term_shell/runtime/FileWorkspace;

.field private final listener:Ljava/net/ServerSocket;

.field private final mcp:Lteec/shell/term_shell/runtime/McpEndpoint;

.field private final provider:Lteec/shell/term_shell/runtime/TerminalServer$Provider;

.field private final sockets:Ljava/util/Set;
  .annotation system Ldalvik/annotation/Signature;
    value = {
      "Ljava/util/Set<",
      "Ljava/net/Socket;",
      ">;"
    }
  .end annotation
.end field

.method public static synthetic $r8$lambda$4fXOlwVlAtZTzi_DaqlM_CdGq8c(Lteec/shell/term_shell/runtime/TerminalServer;)V
  .registers 1
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/TerminalServer;->accept()V
    return-void
.end method

.method public constructor <init>(ILteec/shell/term_shell/runtime/TerminalServer$Assets;Lteec/shell/term_shell/runtime/TerminalServer$Provider;)V
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/io/IOException;
    }
  .end annotation
  .registers 5
  .line 109
    const/4 v0, 0
    invoke-direct { p0, p1, p2, p3, v0 }, Lteec/shell/term_shell/runtime/TerminalServer;-><init>(ILteec/shell/term_shell/runtime/TerminalServer$Assets;Lteec/shell/term_shell/runtime/TerminalServer$Provider;Lteec/shell/term_shell/runtime/FileWorkspace;)V
  .line 110
    return-void
.end method

.method public constructor <init>(ILteec/shell/term_shell/runtime/TerminalServer$Assets;Lteec/shell/term_shell/runtime/TerminalServer$Provider;Lteec/shell/term_shell/runtime/FileWorkspace;)V
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/io/IOException;
    }
  .end annotation
  .registers 11
  .line 113
    const/4 v5, 0
    move-object v0, p0
    move v1, p1
    move-object v2, p2
    move-object v3, p3
    move-object v4, p4
    invoke-direct/range { v0 .. v5 }, Lteec/shell/term_shell/runtime/TerminalServer;-><init>(ILteec/shell/term_shell/runtime/TerminalServer$Assets;Lteec/shell/term_shell/runtime/TerminalServer$Provider;Lteec/shell/term_shell/runtime/FileWorkspace;Lteec/shell/term_shell/runtime/TerminalServer$Control;)V
  .line 114
    return-void
.end method

.method public constructor <init>(ILteec/shell/term_shell/runtime/TerminalServer$Assets;Lteec/shell/term_shell/runtime/TerminalServer$Provider;Lteec/shell/term_shell/runtime/FileWorkspace;Lteec/shell/term_shell/runtime/TerminalServer$Control;)V
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/io/IOException;
    }
  .end annotation
  .catch Ljava/io/IOException; { :L0 .. :L1 } :L2
  .registers 7
  .line 116
    invoke-direct { p0 }, Ljava/lang/Object;-><init>()V
  .line 100
    invoke-static { }, Ljava/util/concurrent/ConcurrentHashMap;->newKeySet()Ljava/util/concurrent/ConcurrentHashMap$KeySetView;
    move-result-object v0
    iput-object v0, p0, Lteec/shell/term_shell/runtime/TerminalServer;->sockets:Ljava/util/Set;
  .line 101
    new-instance v0, Lteec/shell/term_shell/runtime/TerminalServer$0;
    invoke-direct { v0 }, Lteec/shell/term_shell/runtime/TerminalServer$0;-><init>()V
    invoke-static { v0 }, Ljava/util/concurrent/Executors;->newCachedThreadPool(Ljava/util/concurrent/ThreadFactory;)Ljava/util/concurrent/ExecutorService;
    move-result-object v0
    iput-object v0, p0, Lteec/shell/term_shell/runtime/TerminalServer;->clients:Ljava/util/concurrent/ExecutorService;
  .line 117
    iput-object p5, p0, Lteec/shell/term_shell/runtime/TerminalServer;->control:Lteec/shell/term_shell/runtime/TerminalServer$Control;
  .line 118
    new-instance v0, Lteec/shell/term_shell/runtime/McpEndpoint;
    invoke-direct { v0, p5 }, Lteec/shell/term_shell/runtime/McpEndpoint;-><init>(Lteec/shell/term_shell/runtime/TerminalServer$Control;)V
    iput-object v0, p0, Lteec/shell/term_shell/runtime/TerminalServer;->mcp:Lteec/shell/term_shell/runtime/McpEndpoint;
  .line 119
    iput-object p4, p0, Lteec/shell/term_shell/runtime/TerminalServer;->files:Lteec/shell/term_shell/runtime/FileWorkspace;
  .line 120
    iput-object p2, p0, Lteec/shell/term_shell/runtime/TerminalServer;->assets:Lteec/shell/term_shell/runtime/TerminalServer$Assets;
  .line 121
    iput-object p3, p0, Lteec/shell/term_shell/runtime/TerminalServer;->provider:Lteec/shell/term_shell/runtime/TerminalServer$Provider;
  .line 122
    new-instance p2, Ljava/net/ServerSocket;
    invoke-direct { p2 }, Ljava/net/ServerSocket;-><init>()V
    iput-object p2, p0, Lteec/shell/term_shell/runtime/TerminalServer;->listener:Ljava/net/ServerSocket;
  .line 123
    iget-object p2, p0, Lteec/shell/term_shell/runtime/TerminalServer;->listener:Ljava/net/ServerSocket;
    const/4 p3, 1
    invoke-virtual { p2, p3 }, Ljava/net/ServerSocket;->setReuseAddress(Z)V
  :L0
  .line 124
    iget-object p2, p0, Lteec/shell/term_shell/runtime/TerminalServer;->listener:Ljava/net/ServerSocket;
    new-instance p3, Ljava/net/InetSocketAddress;
    const-string p4, "0.0.0.0"
    invoke-direct { p3, p4, p1 }, Ljava/net/InetSocketAddress;-><init>(Ljava/lang/String;I)V
    invoke-virtual { p2, p3 }, Ljava/net/ServerSocket;->bind(Ljava/net/SocketAddress;)V
  :L1
  .line 125
    nop
  .line 126
    iget-object p1, p0, Lteec/shell/term_shell/runtime/TerminalServer;->clients:Ljava/util/concurrent/ExecutorService;
    new-instance p2, Lteec/shell/term_shell/runtime/TerminalServer$1;
    invoke-direct { p2, p0 }, Lteec/shell/term_shell/runtime/TerminalServer$1;-><init>(Lteec/shell/term_shell/runtime/TerminalServer;)V
    invoke-interface { p1, p2 }, Ljava/util/concurrent/ExecutorService;->execute(Ljava/lang/Runnable;)V
  .line 127
    return-void
  :L2
  .line 125
    move-exception p1
    iget-object p2, p0, Lteec/shell/term_shell/runtime/TerminalServer;->listener:Ljava/net/ServerSocket;
    invoke-virtual { p2 }, Ljava/net/ServerSocket;->close()V
    iget-object p2, p0, Lteec/shell/term_shell/runtime/TerminalServer;->clients:Ljava/util/concurrent/ExecutorService;
    invoke-interface { p2 }, Ljava/util/concurrent/ExecutorService;->shutdownNow()Ljava/util/List;
    throw p1
.end method

.method private accept()V
  .catch Ljava/io/IOException; { :L1 .. :L2 } :L3
  .registers 4
  .line 132
    nop
  :L0
    iget-boolean v0, p0, Lteec/shell/term_shell/runtime/TerminalServer;->closed:Z
    if-nez v0, :L5
  :L1
  .line 134
    iget-object v0, p0, Lteec/shell/term_shell/runtime/TerminalServer;->listener:Ljava/net/ServerSocket;
    invoke-virtual { v0 }, Ljava/net/ServerSocket;->accept()Ljava/net/Socket;
    move-result-object v0
  .line 135
    const/4 v1, 1
    invoke-virtual { v0, v1 }, Ljava/net/Socket;->setTcpNoDelay(Z)V
  .line 136
    const/16 v1, 10000
    invoke-virtual { v0, v1 }, Ljava/net/Socket;->setSoTimeout(I)V
  .line 137
    iget-object v1, p0, Lteec/shell/term_shell/runtime/TerminalServer;->sockets:Ljava/util/Set;
    invoke-interface { v1, v0 }, Ljava/util/Set;->add(Ljava/lang/Object;)Z
  .line 138
    iget-object v1, p0, Lteec/shell/term_shell/runtime/TerminalServer;->clients:Ljava/util/concurrent/ExecutorService;
    new-instance v2, Lteec/shell/term_shell/runtime/TerminalServer$2;
    invoke-direct { v2, p0, v0 }, Lteec/shell/term_shell/runtime/TerminalServer$2;-><init>(Lteec/shell/term_shell/runtime/TerminalServer;Ljava/net/Socket;)V
    invoke-interface { v1, v2 }, Ljava/util/concurrent/ExecutorService;->execute(Ljava/lang/Runnable;)V
  :L2
    goto :L4
  :L3
  .line 139
    move-exception v0
  .line 140
    iget-boolean v0, p0, Lteec/shell/term_shell/runtime/TerminalServer;->closed:Z
    if-nez v0, :L4
    invoke-virtual { p0 }, Lteec/shell/term_shell/runtime/TerminalServer;->close()V
  :L4
  .line 141
    goto :L0
  :L5
  .line 143
    return-void
.end method

.method static synthetic access$100(Lteec/shell/term_shell/runtime/TerminalServer;)Lteec/shell/term_shell/runtime/TerminalServer$Provider;
  .registers 1
  .line 27
    iget-object p0, p0, Lteec/shell/term_shell/runtime/TerminalServer;->provider:Lteec/shell/term_shell/runtime/TerminalServer$Provider;
    return-object p0
.end method

.method static synthetic access$200(Lteec/shell/term_shell/runtime/TerminalServer;)Z
  .registers 1
  .line 27
    iget-boolean p0, p0, Lteec/shell/term_shell/runtime/TerminalServer;->closed:Z
    return p0
.end method

.method static synthetic access$300(Lteec/shell/term_shell/runtime/TerminalServer;Lteec/shell/term_shell/runtime/TerminalServer$State;)Ljava/lang/String;
  .registers 2
  .line 27
    invoke-direct { p0, p1 }, Lteec/shell/term_shell/runtime/TerminalServer;->stateJson(Lteec/shell/term_shell/runtime/TerminalServer$State;)Ljava/lang/String;
    move-result-object p0
    return-object p0
.end method

.method static synthetic access$400(Lteec/shell/term_shell/runtime/TerminalServer;)Ljava/util/concurrent/ExecutorService;
  .registers 1
  .line 27
    iget-object p0, p0, Lteec/shell/term_shell/runtime/TerminalServer;->clients:Ljava/util/concurrent/ExecutorService;
    return-object p0
.end method

.method private static assetMime(Ljava/lang/String;)Ljava/lang/String;
  .registers 3
  .line 297
    const/16 v0, 46
    invoke-virtual { p0, v0 }, Ljava/lang/String;->lastIndexOf(I)I
    move-result v0
    const/4 v1, 1
    add-int/2addr v0, v1
    invoke-virtual { p0, v0 }, Ljava/lang/String;->substring(I)Ljava/lang/String;
    move-result-object p0
    sget-object v0, Ljava/util/Locale;->ROOT:Ljava/util/Locale;
    invoke-virtual { p0, v0 }, Ljava/lang/String;->toLowerCase(Ljava/util/Locale;)Ljava/lang/String;
    move-result-object p0
  .line 298
    invoke-virtual { p0 }, Ljava/lang/String;->hashCode()I
    move-result v0
    sparse-switch v0, :L57
  :L0
    goto/16 :L30
  :L1
    const-string v0, "webmanifest"
    invoke-virtual { p0, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p0
    if-eqz p0, :L0
    const/4 v1, 7
    goto/16 :L31
  :L2
    const-string v0, "woff2"
    invoke-virtual { p0, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p0
    if-eqz p0, :L0
    const/16 v1, 17
    goto/16 :L31
  :L3
    const-string v0, "woff"
    invoke-virtual { p0, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p0
    if-eqz p0, :L0
    const/16 v1, 16
    goto/16 :L31
  :L4
    const-string v0, "webp"
    invoke-virtual { p0, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p0
    if-eqz p0, :L0
    const/16 v1, 13
    goto/16 :L31
  :L5
    const-string v0, "webm"
    invoke-virtual { p0, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p0
    if-eqz p0, :L0
    const/16 v1, 28
    goto/16 :L31
  :L6
    const-string v0, "wasm"
    invoke-virtual { p0, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p0
    if-eqz p0, :L0
    const/16 v1, 20
    goto/16 :L31
  :L7
    const-string v0, "json"
    invoke-virtual { p0, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p0
    if-eqz p0, :L0
    const/4 v1, 5
    goto/16 :L31
  :L8
    const-string v0, "jpeg"
    invoke-virtual { p0, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p0
    if-eqz p0, :L0
    const/16 v1, 11
    goto/16 :L31
  :L9
    const-string v0, "html"
    invoke-virtual { p0, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p0
    if-eqz p0, :L0
    const/4 v1, 0
    goto/16 :L31
  :L10
    const-string v0, "avif"
    invoke-virtual { p0, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p0
    if-eqz p0, :L0
    const/16 v1, 14
    goto/16 :L31
  :L11
    const-string v0, "xml"
    invoke-virtual { p0, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p0
    if-eqz p0, :L0
    const/16 v1, 22
    goto/16 :L31
  :L12
    const-string v0, "wav"
    invoke-virtual { p0, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p0
    if-eqz p0, :L0
    const/16 v1, 26
    goto/16 :L31
  :L13
    const-string v0, "txt"
    invoke-virtual { p0, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p0
    if-eqz p0, :L0
    const/16 v1, 21
    goto/16 :L31
  :L14
    const-string v0, "ttf"
    invoke-virtual { p0, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p0
    if-eqz p0, :L0
    const/16 v1, 18
    goto/16 :L31
  :L15
    const-string v0, "svg"
    invoke-virtual { p0, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p0
    if-eqz p0, :L0
    const/16 v1, 8
    goto/16 :L31
  :L16
    const-string v0, "png"
    invoke-virtual { p0, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p0
    if-eqz p0, :L0
    const/16 v1, 9
    goto/16 :L31
  :L17
    const-string v0, "pdf"
    invoke-virtual { p0, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p0
    if-eqz p0, :L0
    const/16 v1, 23
    goto/16 :L31
  :L18
    const-string v0, "otf"
    invoke-virtual { p0, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p0
    if-eqz p0, :L0
    const/16 v1, 19
    goto/16 :L31
  :L19
    const-string v0, "ogg"
    invoke-virtual { p0, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p0
    if-eqz p0, :L0
    const/16 v1, 25
    goto/16 :L31
  :L20
    const-string v0, "mp4"
    invoke-virtual { p0, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p0
    if-eqz p0, :L0
    const/16 v1, 27
    goto :L31
  :L21
    const-string v0, "mp3"
    invoke-virtual { p0, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p0
    if-eqz p0, :L0
    const/16 v1, 24
    goto :L31
  :L22
    const-string v0, "mjs"
    invoke-virtual { p0, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p0
    if-eqz p0, :L0
    const/4 v1, 3
    goto :L31
  :L23
    const-string v0, "map"
    invoke-virtual { p0, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p0
    if-eqz p0, :L0
    const/4 v1, 6
    goto :L31
  :L24
    const-string v0, "jpg"
    invoke-virtual { p0, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p0
    if-eqz p0, :L0
    const/16 v1, 10
    goto :L31
  :L25
    const-string v0, "ico"
    invoke-virtual { p0, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p0
    if-eqz p0, :L0
    const/16 v1, 15
    goto :L31
  :L26
    const-string v0, "htm"
    invoke-virtual { p0, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p0
    if-eqz p0, :L0
    goto :L31
  :L27
    const-string v0, "gif"
    invoke-virtual { p0, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p0
    if-eqz p0, :L0
    const/16 v1, 12
    goto :L31
  :L28
    const-string v0, "css"
    invoke-virtual { p0, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p0
    if-eqz p0, :L0
    const/4 v1, 4
    goto :L31
  :L29
    const-string v0, "js"
    invoke-virtual { p0, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p0
    if-eqz p0, :L0
    const/4 v1, 2
    goto :L31
  :L30
    const/4 v1, -1
  :L31
    packed-switch v1, :L58
  .line 324
    const-string p0, "application/octet-stream"
    return-object p0
  :L32
  .line 323
    const-string p0, "video/webm"
    return-object p0
  :L33
  .line 322
    const-string p0, "video/mp4"
    return-object p0
  :L34
  .line 321
    const-string p0, "audio/wav"
    return-object p0
  :L35
  .line 320
    const-string p0, "audio/ogg"
    return-object p0
  :L36
  .line 319
    const-string p0, "audio/mpeg"
    return-object p0
  :L37
  .line 318
    const-string p0, "application/pdf"
    return-object p0
  :L38
  .line 317
    const-string p0, "application/xml"
    return-object p0
  :L39
  .line 316
    const-string p0, "text/plain"
    return-object p0
  :L40
  .line 315
    const-string p0, "application/wasm"
    return-object p0
  :L41
  .line 314
    const-string p0, "font/otf"
    return-object p0
  :L42
  .line 313
    const-string p0, "font/ttf"
    return-object p0
  :L43
  .line 312
    const-string p0, "font/woff2"
    return-object p0
  :L44
  .line 311
    const-string p0, "font/woff"
    return-object p0
  :L45
  .line 310
    const-string p0, "image/x-icon"
    return-object p0
  :L46
  .line 309
    const-string p0, "image/avif"
    return-object p0
  :L47
  .line 308
    const-string p0, "image/webp"
    return-object p0
  :L48
  .line 307
    const-string p0, "image/gif"
    return-object p0
  :L49
  .line 306
    const-string p0, "image/jpeg"
    return-object p0
  :L50
  .line 305
    const-string p0, "image/png"
    return-object p0
  :L51
  .line 304
    const-string p0, "image/svg+xml"
    return-object p0
  :L52
  .line 303
    const-string p0, "application/manifest+json"
    return-object p0
  :L53
  .line 302
    const-string p0, "application/json"
    return-object p0
  :L54
  .line 301
    const-string p0, "text/css"
    return-object p0
  :L55
  .line 300
    const-string p0, "text/javascript"
    return-object p0
  :L56
  .line 299
    const-string p0, "text/html"
    return-object p0
  :L57
  .sparse-switch
    3401 -> :L29
    98819 -> :L28
    102340 -> :L27
    103649 -> :L26
    104085 -> :L25
    105441 -> :L24
    107868 -> :L23
    108150 -> :L22
    108272 -> :L21
    108273 -> :L20
    109967 -> :L19
    110369 -> :L18
    110834 -> :L17
    111145 -> :L16
    114276 -> :L15
    115174 -> :L14
    115312 -> :L13
    117484 -> :L12
    118807 -> :L11
    3006482 -> :L10
    3213227 -> :L9
    3268712 -> :L8
    3271912 -> :L7
    3642020 -> :L6
    3645337 -> :L5
    3645340 -> :L4
    3655064 -> :L3
    113307034 -> :L2
    1631872387 -> :L1
  .end sparse-switch
  :L58
  .packed-switch 0
    :L56
    :L56
    :L55
    :L55
    :L54
    :L53
    :L53
    :L52
    :L51
    :L50
    :L49
    :L49
    :L48
    :L47
    :L46
    :L45
    :L44
    :L43
    :L42
    :L41
    :L40
    :L39
    :L38
    :L37
    :L36
    :L35
    :L34
    :L33
    :L32
  .end packed-switch
.end method

.method private static base64([B)Ljava/lang/String;
  .registers 9
  .line 422
    nop
  .line 423
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct { v0 }, Ljava/lang/StringBuilder;-><init>()V
  .line 424
    const/4 v1, 0
  :L0
    array-length v2, p0
    if-ge v1, v2, :L6
  .line 425
    aget-byte v2, p0, v1
    and-int/lit16 v2, v2, 255
    shl-int/lit8 v2, v2, 16
  .line 426
    add-int/lit8 v3, v1, 1
    array-length v4, p0
    if-ge v3, v4, :L1
    aget-byte v4, p0, v3
    and-int/lit16 v4, v4, 255
    shl-int/lit8 v4, v4, 8
    or-int/2addr v2, v4
  :L1
  .line 427
    add-int/lit8 v4, v1, 2
    array-length v5, p0
    if-ge v4, v5, :L2
    aget-byte v5, p0, v4
    and-int/lit16 v5, v5, 255
    or-int/2addr v2, v5
  :L2
  .line 428
    ushr-int/lit8 v5, v2, 18
    const-string v6, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    invoke-virtual { v6, v5 }, Ljava/lang/String;->charAt(I)C
    move-result v5
    invoke-virtual { v0, v5 }, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;
    move-result-object v5
    ushr-int/lit8 v7, v2, 12
    and-int/lit8 v7, v7, 63
    invoke-virtual { v6, v7 }, Ljava/lang/String;->charAt(I)C
    move-result v7
    invoke-virtual { v5, v7 }, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;
  .line 429
    array-length v5, p0
    const/16 v7, 61
    if-ge v3, v5, :L3
    ushr-int/lit8 v3, v2, 6
    and-int/lit8 v3, v3, 63
    invoke-virtual { v6, v3 }, Ljava/lang/String;->charAt(I)C
    move-result v3
    goto :L4
  :L3
    move v3, v7
  :L4
    invoke-virtual { v0, v3 }, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;
  .line 430
    array-length v3, p0
    if-ge v4, v3, :L5
    and-int/lit8 v2, v2, 63
    invoke-virtual { v6, v2 }, Ljava/lang/String;->charAt(I)C
    move-result v7
  :L5
    invoke-virtual { v0, v7 }, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;
  .line 424
    add-int/lit8 v1, v1, 3
    goto :L0
  :L6
  .line 432
    invoke-virtual { v0 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object p0
    return-object p0
.end method

.method private static header(Ljava/io/InputStream;)Ljava/lang/String;
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/io/IOException;
    }
  .end annotation
  .registers 8
  .line 387
    new-instance v0, Ljava/io/ByteArrayOutputStream;
    invoke-direct { v0 }, Ljava/io/ByteArrayOutputStream;-><init>()V
  .line 388
    nop
  .line 389
    const/4 v1, 4
    new-array v2, v1, [B
    fill-array-data v2, :L7
    const/4 v3, 0
    move v4, v3
  :L0
  .line 390
    invoke-virtual { v0 }, Ljava/io/ByteArrayOutputStream;->size()I
    move-result v5
    const/16 v6, 16384
    if-ge v5, v6, :L6
  .line 391
    invoke-virtual { p0 }, Ljava/io/InputStream;->read()I
    move-result v5
  .line 392
    if-ltz v5, :L5
  .line 393
    invoke-virtual { v0, v5 }, Ljava/io/ByteArrayOutputStream;->write(I)V
  .line 394
    aget-byte v6, v2, v4
    if-ne v5, v6, :L1
    add-int/lit8 v4, v4, 1
    goto :L3
  :L1
    const/16 v4, 13
    if-ne v5, v4, :L2
    const/4 v4, 1
    goto :L3
  :L2
    move v4, v3
  :L3
  .line 395
    if-ne v4, v1, :L4
    new-instance p0, Ljava/lang/String;
    invoke-virtual { v0 }, Ljava/io/ByteArrayOutputStream;->toByteArray()[B
    move-result-object v0
    sget-object v1, Ljava/nio/charset/StandardCharsets;->US_ASCII:Ljava/nio/charset/Charset;
    invoke-direct { p0, v0, v1 }, Ljava/lang/String;-><init>([BLjava/nio/charset/Charset;)V
    return-object p0
  :L4
  .line 396
    goto :L0
  :L5
  .line 392
    new-instance p0, Ljava/io/EOFException;
    invoke-direct { p0 }, Ljava/io/EOFException;-><init>()V
    throw p0
  :L6
  .line 397
    new-instance p0, Ljava/io/IOException;
    const-string v0, "HTTP header exceeds 16384 bytes"
    invoke-direct { p0, v0 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p0
  :L7
  .array-data 1
    13t
    10t
    13t
    10t
  .end array-data
.end method

.method static synthetic lambda$new$0(Ljava/lang/Runnable;)Ljava/lang/Thread;
  .registers 3
  .line 102
    new-instance v0, Ljava/lang/Thread;
    const-string v1, "Ubuntu-web-terminal"
    invoke-direct { v0, p0, v1 }, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;Ljava/lang/String;)V
  .line 103
    const/4 p0, 1
    invoke-virtual { v0, p0 }, Ljava/lang/Thread;->setDaemon(Z)V
  .line 104
    return-object v0
.end method

.method private static mcpBody(Ljava/io/InputStream;Ljava/util/Map;)[B
  .annotation system Ldalvik/annotation/Signature;
    value = {
      "(",
      "Ljava/io/InputStream;",
      "Ljava/util/Map<",
      "Ljava/lang/String;",
      "Ljava/lang/String;",
      ">;)[B"
    }
  .end annotation
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/io/IOException;
    }
  .end annotation
  .registers 15
  .line 337
    new-instance v0, Ljava/io/ByteArrayOutputStream;
    invoke-direct { v0 }, Ljava/io/ByteArrayOutputStream;-><init>()V
  .line 338
    const/16 v1, 16384
    new-array v1, v1, [B
  .line 339
    const-string v2, "transfer-encoding"
    invoke-interface { p1, v2 }, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v2
    check-cast v2, Ljava/lang/String;
  .line 340
    const-wide/16 v3, 16384
    const-string v5, "content-length"
    const-wide/16 v6, 0
    const/4 v8, 0
    if-eqz v2, :L10
  .line 341
    const-string v9, "chunked"
    invoke-virtual { v2, v9 }, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z
    move-result v2
    if-eqz v2, :L9
    invoke-interface { p1, v5 }, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z
    move-result p1
    if-nez p1, :L9
  :L0
  .line 343
    invoke-static { p0 }, Lteec/shell/term_shell/runtime/TerminalServer;->mcpLine(Ljava/io/InputStream;)Ljava/lang/String;
    move-result-object p1
  .line 344
    const/16 v2, 59
    invoke-virtual { p1, v2 }, Ljava/lang/String;->indexOf(I)I
    move-result v2
  .line 345
    if-gez v2, :L1
    goto :L2
  :L1
    invoke-virtual { p1, v8, v2 }, Ljava/lang/String;->substring(II)Ljava/lang/String;
    move-result-object p1
  :L2
  .line 346
    const-string v2, "[0-9a-fA-F]+"
    invoke-virtual { p1, v2 }, Ljava/lang/String;->matches(Ljava/lang/String;)Z
    move-result v2
    if-eqz v2, :L8
  .line 347
    const/16 v2, 16
    invoke-static { p1, v2 }, Ljava/lang/Long;->parseLong(Ljava/lang/String;I)J
    move-result-wide v9
  .line 348
    cmp-long p1, v9, v6
    if-nez p1, :L4
  :L3
  .line 349
    invoke-static { p0 }, Lteec/shell/term_shell/runtime/TerminalServer;->mcpLine(Ljava/io/InputStream;)Ljava/lang/String;
    move-result-object p1
    invoke-virtual { p1 }, Ljava/lang/String;->isEmpty()Z
    move-result p1
    if-nez p1, :L13
    goto :L3
  :L4
  .line 352
    cmp-long p1, v9, v6
    if-lez p1, :L6
  .line 353
    invoke-static { v3, v4, v9, v10 }, Ljava/lang/Math;->min(JJ)J
    move-result-wide v11
    long-to-int p1, v11
    invoke-virtual { p0, v1, v8, p1 }, Ljava/io/InputStream;->read([BII)I
    move-result p1
  .line 354
    if-ltz p1, :L5
  .line 355
    invoke-virtual { v0, v1, v8, p1 }, Ljava/io/ByteArrayOutputStream;->write([BII)V
    int-to-long v11, p1
    sub-long/2addr v9, v11
  .line 356
    goto :L4
  :L5
  .line 354
    new-instance p0, Ljava/io/EOFException;
    const-string p1, "Incomplete MCP chunk"
    invoke-direct { p0, p1 }, Ljava/io/EOFException;-><init>(Ljava/lang/String;)V
    throw p0
  :L6
  .line 357
    invoke-static { p0 }, Lteec/shell/term_shell/runtime/TerminalServer;->mcpLine(Ljava/io/InputStream;)Ljava/lang/String;
    move-result-object p1
    invoke-virtual { p1 }, Ljava/lang/String;->isEmpty()Z
    move-result p1
    if-eqz p1, :L7
  .line 358
    goto :L0
  :L7
  .line 357
    new-instance p0, Ljava/io/IOException;
    const-string p1, "Invalid MCP chunk ending"
    invoke-direct { p0, p1 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p0
  :L8
  .line 346
    new-instance p0, Ljava/io/IOException;
    const-string p1, "Invalid MCP chunk size"
    invoke-direct { p0, p1 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p0
  :L9
  .line 341
    new-instance p0, Ljava/io/IOException;
    const-string p1, "Invalid MCP transfer encoding"
    invoke-direct { p0, p1 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p0
  :L10
  .line 360
    const-string v2, "0"
    invoke-interface { p1, v5, v2 }, Ljava/util/Map;->getOrDefault(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object p1
    check-cast p1, Ljava/lang/String;
  .line 361
    const-string v2, "[0-9]+"
    invoke-virtual { p1, v2 }, Ljava/lang/String;->matches(Ljava/lang/String;)Z
    move-result v2
    if-eqz v2, :L14
  .line 362
    invoke-static { p1 }, Ljava/lang/Long;->parseLong(Ljava/lang/String;)J
    move-result-wide v9
  :L11
  .line 363
    cmp-long p1, v9, v6
    if-lez p1, :L13
  .line 364
    invoke-static { v3, v4, v9, v10 }, Ljava/lang/Math;->min(JJ)J
    move-result-wide v11
    long-to-int p1, v11
    invoke-virtual { p0, v1, v8, p1 }, Ljava/io/InputStream;->read([BII)I
    move-result p1
  .line 365
    if-ltz p1, :L12
  .line 366
    invoke-virtual { v0, v1, v8, p1 }, Ljava/io/ByteArrayOutputStream;->write([BII)V
    int-to-long v11, p1
    sub-long/2addr v9, v11
  .line 367
    goto :L11
  :L12
  .line 365
    new-instance p0, Ljava/io/EOFException;
    const-string p1, "Incomplete MCP request body"
    invoke-direct { p0, p1 }, Ljava/io/EOFException;-><init>(Ljava/lang/String;)V
    throw p0
  :L13
  .line 369
    invoke-virtual { v0 }, Ljava/io/ByteArrayOutputStream;->toByteArray()[B
    move-result-object p0
    return-object p0
  :L14
  .line 361
    new-instance p0, Ljava/io/IOException;
    const-string p1, "Invalid MCP Content-Length"
    invoke-direct { p0, p1 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p0
.end method

.method private static mcpLine(Ljava/io/InputStream;)Ljava/lang/String;
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/io/IOException;
    }
  .end annotation
  .registers 4
  .line 373
    new-instance v0, Ljava/io/ByteArrayOutputStream;
    invoke-direct { v0 }, Ljava/io/ByteArrayOutputStream;-><init>()V
  :L0
  .line 374
    invoke-virtual { v0 }, Ljava/io/ByteArrayOutputStream;->size()I
    move-result v1
    const/16 v2, 16384
    if-ge v1, v2, :L4
  .line 375
    invoke-virtual { p0 }, Ljava/io/InputStream;->read()I
    move-result v1
  .line 376
    if-ltz v1, :L3
  .line 377
    const/16 v2, 13
    if-ne v1, v2, :L2
  .line 378
    invoke-virtual { p0 }, Ljava/io/InputStream;->read()I
    move-result p0
    const/16 v1, 10
    if-ne p0, v1, :L1
  .line 379
    new-instance p0, Ljava/lang/String;
    invoke-virtual { v0 }, Ljava/io/ByteArrayOutputStream;->toByteArray()[B
    move-result-object v0
    sget-object v1, Ljava/nio/charset/StandardCharsets;->US_ASCII:Ljava/nio/charset/Charset;
    invoke-direct { p0, v0, v1 }, Ljava/lang/String;-><init>([BLjava/nio/charset/Charset;)V
    return-object p0
  :L1
  .line 378
    new-instance p0, Ljava/io/IOException;
    const-string v0, "Invalid MCP HTTP line ending"
    invoke-direct { p0, v0 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p0
  :L2
  .line 381
    invoke-virtual { v0, v1 }, Ljava/io/ByteArrayOutputStream;->write(I)V
  .line 382
    goto :L0
  :L3
  .line 376
    new-instance p0, Ljava/io/EOFException;
    const-string v0, "Incomplete MCP HTTP line"
    invoke-direct { p0, v0 }, Ljava/io/EOFException;-><init>(Ljava/lang/String;)V
    throw p0
  :L4
  .line 383
    new-instance p0, Ljava/io/IOException;
    const-string v0, "MCP HTTP line exceeds 16384 bytes"
    invoke-direct { p0, v0 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p0
.end method

.method private static query(Ljava/net/URI;Ljava/lang/String;)Ljava/lang/String;
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/io/IOException;
    }
  .end annotation
  .registers 8
  .line 329
    invoke-virtual { p0 }, Ljava/net/URI;->getRawQuery()Ljava/lang/String;
    move-result-object v0
    if-eqz v0, :L2
    invoke-virtual { p0 }, Ljava/net/URI;->getRawQuery()Ljava/lang/String;
    move-result-object p0
    const-string v0, "&"
    invoke-virtual { p0, v0 }, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;
    move-result-object p0
    array-length v0, p0
    const/4 v1, 0
    move v2, v1
  :L0
    if-ge v2, v0, :L2
    aget-object v3, p0, v2
  .line 330
    const-string v4, "="
    const/4 v5, 2
    invoke-virtual { v3, v4, v5 }, Ljava/lang/String;->split(Ljava/lang/String;I)[Ljava/lang/String;
    move-result-object v3
  .line 331
    array-length v4, v3
    if-ne v4, v5, :L1
    aget-object v4, v3, v1
    invoke-virtual { v4, p1 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v4
    if-eqz v4, :L1
    const/4 p0, 1
    aget-object p0, v3, p0
    const-string p1, "UTF-8"
    invoke-static { p0, p1 }, Ljava/net/URLDecoder;->decode(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object p0
    return-object p0
  :L1
  .line 329
    add-int/lit8 v2, v2, 1
    goto :L0
  :L2
  .line 333
    const-string p0, ""
    return-object p0
.end method

.method static quote(Ljava/lang/String;)Ljava/lang/String;
  .registers 7
  .line 412
    new-instance v0, Ljava/lang/StringBuilder;
    const-string v1, "\""
    invoke-direct { v0, v1 }, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V
  .line 413
    invoke-virtual { p0 }, Ljava/lang/String;->toCharArray()[C
    move-result-object p0
    array-length v1, p0
    const/4 v2, 0
  :L0
    const/16 v3, 34
    if-ge v2, v1, :L5
    aget-char v4, p0, v2
  .line 414
    const/16 v5, 92
    if-eq v4, v3, :L3
    if-ne v4, v5, :L1
    goto :L3
  :L1
  .line 415
    const/16 v3, 32
    if-ge v4, v3, :L2
    invoke-static { v4 }, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;
    move-result-object v3
    filled-new-array { v3 }, [Ljava/lang/Object;
    move-result-object v3
    const-string v4, "\\u%04x"
    invoke-static { v4, v3 }, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;
    move-result-object v3
    invoke-virtual { v0, v3 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    goto :L4
  :L2
  .line 416
    invoke-virtual { v0, v4 }, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;
    goto :L4
  :L3
  .line 414
    invoke-virtual { v0, v5 }, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;
    move-result-object v3
    invoke-virtual { v3, v4 }, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;
  :L4
  .line 413
    add-int/lit8 v2, v2, 1
    goto :L0
  :L5
  .line 418
    invoke-virtual { v0, v3 }, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;
    move-result-object p0
    invoke-virtual { p0 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object p0
    return-object p0
.end method

.method private static response(Ljava/io/OutputStream;ILjava/lang/String;[BZ)V
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/io/IOException;
    }
  .end annotation
  .registers 11
  .line 401
    const-string v5, ""
    move-object v0, p0
    move v1, p1
    move-object v2, p2
    move-object v3, p3
    move v4, p4
    invoke-static/range { v0 .. v5 }, Lteec/shell/term_shell/runtime/TerminalServer;->response(Ljava/io/OutputStream;ILjava/lang/String;[BZLjava/lang/String;)V
  .line 402
    return-void
.end method

.method private static response(Ljava/io/OutputStream;ILjava/lang/String;[BZLjava/lang/String;)V
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/io/IOException;
    }
  .end annotation
  .registers 9
  .line 405
    const-string v0, "text/"
    invoke-virtual { p2, v0 }, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v0
    if-nez v0, :L1
    const-string v0, "application/json"
    invoke-virtual { p2, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-nez v0, :L1
    const-string v0, "+json"
    invoke-virtual { p2, v0 }, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v0
    if-nez v0, :L1
    const-string v0, "xml"
    invoke-virtual { p2, v0 }, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v0
    if-eqz v0, :L0
    goto :L1
  :L0
    const-string v0, ""
    goto :L2
  :L1
    const-string v0, "; charset=utf-8"
  :L2
  .line 406
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct { v1 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "HTTP/1.1 "
    invoke-virtual { v1, v2 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v1
    invoke-virtual { v1, p1 }, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    move-result-object v1
    const-string v2, " "
    invoke-virtual { v1, v2 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v1
    const/16 v2, 200
    if-ne p1, v2, :L3
    const-string p1, "OK"
    goto :L6
  :L3
    const/16 v2, 201
    if-ne p1, v2, :L4
    const-string p1, "Created"
    goto :L6
  :L4
    const/16 v2, 202
    if-ne p1, v2, :L5
    const-string p1, "Accepted"
    goto :L6
  :L5
    const-string p1, "Error"
  :L6
    invoke-virtual { v1, p1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p1
    const-string v1, "\r\nContent-Type: "
    invoke-virtual { p1, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p1
    invoke-virtual { p1, p2 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p1
    invoke-virtual { p1, v0 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p1
    const-string p2, "\r\nContent-Length: "
    invoke-virtual { p1, p2 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p1
    array-length p2, p3
    invoke-virtual { p1, p2 }, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    move-result-object p1
    const-string p2, "\r\nCache-Control: no-store\r\nConnection: close\r\n"
    invoke-virtual { p1, p2 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p1
    invoke-virtual { p1, p5 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p1
    const-string p2, "\r\n"
    invoke-virtual { p1, p2 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p1
    invoke-virtual { p1 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object p1
    sget-object p2, Ljava/nio/charset/StandardCharsets;->US_ASCII:Ljava/nio/charset/Charset;
    invoke-virtual { p1, p2 }, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B
    move-result-object p1
    invoke-virtual { p0, p1 }, Ljava/io/OutputStream;->write([B)V
  .line 407
    if-nez p4, :L7
    invoke-virtual { p0, p3 }, Ljava/io/OutputStream;->write([B)V
  :L7
  .line 408
    invoke-virtual { p0 }, Ljava/io/OutputStream;->flush()V
  .line 409
    return-void
.end method

.method private serve(Ljava/net/Socket;)V
  .catch Ljava/lang/Exception; { :L0 .. :L1 } :L158
  .catchall { :L0 .. :L1 } :L157
  .catch Ljava/lang/Exception; { :L2 .. :L3 } :L8
  .catchall { :L2 .. :L3 } :L157
  .catch Ljava/io/IOException; { :L4 .. :L5 } :L6
  .catch Ljava/lang/Exception; { :L10 .. :L12 } :L158
  .catchall { :L10 .. :L12 } :L157
  .catch Ljava/lang/Exception; { :L13 .. :L14 } :L20
  .catchall { :L13 .. :L14 } :L157
  .catch Ljava/lang/Exception; { :L15 .. :L16 } :L17
  .catchall { :L15 .. :L16 } :L157
  .catch Ljava/lang/Exception; { :L23 .. :L24 } :L158
  .catchall { :L23 .. :L24 } :L157
  .catch Ljava/io/IOException; { :L25 .. :L26 } :L34
  .catch Ljava/lang/IllegalArgumentException; { :L25 .. :L26 } :L33
  .catch Ljava/lang/Exception; { :L25 .. :L26 } :L158
  .catchall { :L25 .. :L26 } :L157
  .catch Ljava/io/IOException; { :L27 .. :L28 } :L34
  .catch Ljava/lang/IllegalArgumentException; { :L27 .. :L28 } :L33
  .catch Ljava/lang/Exception; { :L27 .. :L28 } :L17
  .catchall { :L27 .. :L28 } :L157
  .catch Ljava/io/IOException; { :L30 .. :L32 } :L34
  .catch Ljava/lang/IllegalArgumentException; { :L30 .. :L32 } :L33
  .catch Ljava/lang/Exception; { :L30 .. :L32 } :L158
  .catchall { :L30 .. :L32 } :L157
  .catch Ljava/lang/Exception; { :L35 .. :L37 } :L158
  .catchall { :L35 .. :L37 } :L157
  .catch Ljava/io/IOException; { :L38 .. :L39 } :L40
  .catch Ljava/lang/Exception; { :L43 .. :L44 } :L158
  .catchall { :L43 .. :L44 } :L157
  .catch Ljava/io/IOException; { :L45 .. :L46 } :L47
  .catch Ljava/lang/Exception; { :L49 .. :L50 } :L158
  .catchall { :L49 .. :L50 } :L157
  .catch Ljava/lang/Exception; { :L51 .. :L57 } :L158
  .catchall { :L51 .. :L57 } :L157
  .catch Ljava/io/IOException; { :L58 .. :L59 } :L60
  .catch Ljava/lang/Exception; { :L63 .. :L64 } :L158
  .catchall { :L63 .. :L64 } :L157
  .catch Ljava/lang/Exception; { :L65 .. :L76 } :L158
  .catchall { :L65 .. :L76 } :L157
  .catch Ljava/io/IOException; { :L77 .. :L78 } :L79
  .catch Ljava/lang/Exception; { :L81 .. :L82 } :L158
  .catchall { :L81 .. :L82 } :L157
  .catch Ljava/io/IOException; { :L83 .. :L84 } :L85
  .catch Ljava/lang/Exception; { :L88 .. :L89 } :L158
  .catchall { :L88 .. :L89 } :L157
  .catch Ljava/lang/Exception; { :L90 .. :L91 } :L158
  .catchall { :L90 .. :L91 } :L157
  .catch Ljava/io/IOException; { :L92 .. :L93 } :L94
  .catch Ljava/lang/Exception; { :L96 .. :L98 } :L158
  .catchall { :L96 .. :L98 } :L157
  .catch Ljava/io/IOException; { :L99 .. :L100 } :L101
  .catch Ljava/lang/Exception; { :L103 .. :L105 } :L158
  .catchall { :L103 .. :L105 } :L157
  .catch Ljava/io/IOException; { :L107 .. :L108 } :L109
  .catch Ljava/lang/Exception; { :L111 .. :L115 } :L158
  .catchall { :L111 .. :L115 } :L157
  .catch Ljava/io/IOException; { :L116 .. :L117 } :L118
  .catch Ljava/lang/Exception; { :L120 .. :L121 } :L158
  .catchall { :L120 .. :L121 } :L157
  .catch Ljava/io/IOException; { :L122 .. :L123 } :L124
  .catch Ljava/lang/Exception; { :L126 .. :L127 } :L158
  .catchall { :L126 .. :L127 } :L157
  .catch Ljava/lang/Exception; { :L128 .. :L129 } :L134
  .catchall { :L128 .. :L129 } :L157
  .catch Ljava/io/IOException; { :L130 .. :L131 } :L132
  .catch Ljava/lang/Exception; { :L135 .. :L137 } :L158
  .catchall { :L135 .. :L137 } :L157
  .catch Ljava/io/IOException; { :L138 .. :L139 } :L140
  .catch Ljava/lang/Exception; { :L142 .. :L147 } :L158
  .catchall { :L142 .. :L147 } :L157
  .catch Ljava/io/IOException; { :L148 .. :L149 } :L150
  .catch Ljava/io/FileNotFoundException; { :L152 .. :L153 } :L154
  .catch Ljava/lang/Exception; { :L152 .. :L153 } :L158
  .catchall { :L152 .. :L153 } :L157
  .catch Ljava/lang/Exception; { :L155 .. :L156 } :L158
  .catchall { :L155 .. :L156 } :L157
  .catchall { :L160 .. :L161 } :L157
  .catch Ljava/io/IOException; { :L162 .. :L164 } :L165
  .catchall { :L162 .. :L164 } :L157
  .catch Ljava/io/IOException; { :L168 .. :L169 } :L170
  .catch Ljava/io/IOException; { :L173 .. :L174 } :L175
  .registers 25
  .line 146
    move-object/from16 v1, p0
    move-object/from16 v2, p1
    const-string v0, "/files/jobs"
    const-string v6, "text/plain"
    const-string v7, "application/json"
  .line 148
    const/4 v9, 0
  :L0
    new-instance v3, Ljava/io/BufferedInputStream;
    invoke-virtual { v2 }, Ljava/net/Socket;->getInputStream()Ljava/io/InputStream;
    move-result-object v4
    const/16 v5, 16384
    invoke-direct { v3, v4, v5 }, Ljava/io/BufferedInputStream;-><init>(Ljava/io/InputStream;I)V
  .line 149
    invoke-virtual { v2 }, Ljava/net/Socket;->getOutputStream()Ljava/io/OutputStream;
    move-result-object v4
  .line 150
    invoke-static { v3 }, Lteec/shell/term_shell/runtime/TerminalServer;->header(Ljava/io/InputStream;)Ljava/lang/String;
    move-result-object v10
  .line 151
    const-string v11, "\r\n"
    invoke-virtual { v10, v11 }, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;
    move-result-object v10
  .line 152
    aget-object v11, v10, v9
    const-string v12, " "
    invoke-virtual { v11, v12 }, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;
    move-result-object v11
  .line 153
    array-length v12, v11
  :L1
    const/4 v13, 3
    const-string v14, "GET required"
    const/16 v15, 405
    if-eq v12, v13, :L9
  :L2
  .line 154
    sget-object v0, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;
    invoke-virtual { v14, v0 }, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B
    move-result-object v0
    invoke-static { v4, v15, v6, v0, v9 }, Lteec/shell/term_shell/runtime/TerminalServer;->response(Ljava/io/OutputStream;ILjava/lang/String;[BZ)V
  :L3
  .line 285
    iget-object v0, v1, Lteec/shell/term_shell/runtime/TerminalServer;->sockets:Ljava/util/Set;
    invoke-interface { v0, v2 }, Ljava/util/Set;->remove(Ljava/lang/Object;)Z
  :L4
  .line 286
    invoke-virtual { v2 }, Ljava/net/Socket;->close()V
  :L5
    goto :L7
  :L6
    move-exception v0
  :L7
  .line 155
    return-void
  :L8
  .line 276
    move-exception v0
    move v12, v9
    goto/16 :L159
  :L9
  .line 157
    const/4 v12, 1
  :L10
    aget-object v13, v11, v12
    invoke-static { v13 }, Ljava/net/URI;->create(Ljava/lang/String;)Ljava/net/URI;
    move-result-object v13
  .line 158
    move/from16 v16, v12
    new-instance v12, Ljava/util/HashMap;
    invoke-direct { v12 }, Ljava/util/HashMap;-><init>()V
  .line 159
    move/from16 v8, v16
  :L11
    array-length v5, v10
  :L12
    if-ge v8, v5, :L22
  :L13
  .line 160
    aget-object v5, v10, v8
    const/16 v15, 58
    invoke-virtual { v5, v15 }, Ljava/lang/String;->indexOf(I)I
    move-result v5
  .line 161
    if-lez v5, :L18
    aget-object v15, v10, v8
    invoke-virtual { v15, v9, v5 }, Ljava/lang/String;->substring(II)Ljava/lang/String;
    move-result-object v15
    invoke-virtual { v15 }, Ljava/lang/String;->trim()Ljava/lang/String;
    move-result-object v15
  :L14
    move/from16 v18, v9
  :L15
    sget-object v9, Ljava/util/Locale;->ROOT:Ljava/util/Locale;
    invoke-virtual { v15, v9 }, Ljava/lang/String;->toLowerCase(Ljava/util/Locale;)Ljava/lang/String;
    move-result-object v9
    aget-object v15, v10, v8
    add-int/lit8 v5, v5, 1
    invoke-virtual { v15, v5 }, Ljava/lang/String;->substring(I)Ljava/lang/String;
    move-result-object v5
    invoke-virtual { v5 }, Ljava/lang/String;->trim()Ljava/lang/String;
    move-result-object v5
    invoke-interface { v12, v9, v5 }, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
  :L16
    goto :L19
  :L17
  .line 276
    move-exception v0
    goto :L21
  :L18
  .line 161
    move/from16 v18, v9
  :L19
  .line 159
    add-int/lit8 v8, v8, 1
    move/from16 v9, v18
    const/16 v5, 16384
    const/16 v15, 405
    goto :L11
  :L20
  .line 276
    move-exception v0
    move/from16 v18, v9
  :L21
    move/from16 v12, v18
    goto/16 :L159
  :L22
  .line 163
    move/from16 v18, v9
  :L23
    invoke-virtual { v13 }, Ljava/net/URI;->getPath()Ljava/lang/String;
    move-result-object v5
    const-string v8, "/mcp"
    invoke-virtual { v5, v8 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v5
  :L24
    const-string v8, "POST"
    const-string v9, "HEAD"
    if-eqz v5, :L42
  :L25
  .line 166
    aget-object v0, v11, v18
    invoke-virtual { v0, v8 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
  :L26
    if-eqz v0, :L29
  :L27
    invoke-static { v3, v12 }, Lteec/shell/term_shell/runtime/TerminalServer;->mcpBody(Ljava/io/InputStream;Ljava/util/Map;)[B
    move-result-object v0
  :L28
    move/from16 v3, v18
    goto :L31
  :L29
    move/from16 v3, v18
  :L30
    new-array v0, v3, [B
  :L31
  .line 167
    iget-object v5, v1, Lteec/shell/term_shell/runtime/TerminalServer;->mcp:Lteec/shell/term_shell/runtime/McpEndpoint;
    aget-object v8, v11, v3
    invoke-virtual { v5, v8, v12, v0 }, Lteec/shell/term_shell/runtime/McpEndpoint;->handle(Ljava/lang/String;Ljava/util/Map;[B)Lteec/shell/term_shell/runtime/McpEndpoint$Reply;
    move-result-object v0
  :L32
  .line 170
    goto :L36
  :L33
  .line 168
    move-exception v0
    goto :L35
  :L34
    move-exception v0
  :L35
  .line 169
    invoke-virtual { v0 }, Ljava/lang/Exception;->getMessage()Ljava/lang/String;
    move-result-object v0
    invoke-static { v0 }, Lteec/shell/term_shell/runtime/McpEndpoint;->badTransport(Ljava/lang/String;)Lteec/shell/term_shell/runtime/McpEndpoint$Reply;
    move-result-object v0
  :L36
  .line 171
    move-object v5, v11
    iget v11, v0, Lteec/shell/term_shell/runtime/McpEndpoint$Reply;->status:I
    const-string v12, "application/json"
    iget-object v13, v0, Lteec/shell/term_shell/runtime/McpEndpoint$Reply;->body:[B
    const/16 v18, 0
    aget-object v3, v5, v18
    invoke-virtual { v3, v9 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v14
    iget-object v15, v0, Lteec/shell/term_shell/runtime/McpEndpoint$Reply;->headers:Ljava/lang/String;
    move-object v10, v4
    invoke-static/range { v10 .. v15 }, Lteec/shell/term_shell/runtime/TerminalServer;->response(Ljava/io/OutputStream;ILjava/lang/String;[BZLjava/lang/String;)V
  :L37
  .line 285
    iget-object v0, v1, Lteec/shell/term_shell/runtime/TerminalServer;->sockets:Ljava/util/Set;
    invoke-interface { v0, v2 }, Ljava/util/Set;->remove(Ljava/lang/Object;)Z
  :L38
  .line 286
    invoke-virtual { v2 }, Ljava/net/Socket;->close()V
  :L39
    goto :L41
  :L40
    move-exception v0
  :L41
  .line 172
    return-void
  :L42
  .line 174
    move-object v5, v11
    const/16 v18, 0
  :L43
    aget-object v10, v5, v18
    const-string v11, "GET"
    invoke-virtual { v10, v11 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v10
    if-nez v10, :L49
    aget-object v10, v5, v18
    invoke-virtual { v10, v9 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v10
    if-nez v10, :L49
    aget-object v10, v5, v18
    invoke-virtual { v10, v8 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v10
    if-nez v10, :L49
  .line 175
    sget-object v0, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;
    invoke-virtual { v14, v0 }, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B
    move-result-object v0
    const/16 v3, 405
    const/4 v5, 0
    invoke-static { v4, v3, v6, v0, v5 }, Lteec/shell/term_shell/runtime/TerminalServer;->response(Ljava/io/OutputStream;ILjava/lang/String;[BZ)V
  :L44
  .line 285
    iget-object v0, v1, Lteec/shell/term_shell/runtime/TerminalServer;->sockets:Ljava/util/Set;
    invoke-interface { v0, v2 }, Ljava/util/Set;->remove(Ljava/lang/Object;)Z
  :L45
  .line 286
    invoke-virtual { v2 }, Ljava/net/Socket;->close()V
  :L46
    goto :L48
  :L47
    move-exception v0
  :L48
  .line 176
    return-void
  :L49
  .line 178
    iget-object v10, v1, Lteec/shell/term_shell/runtime/TerminalServer;->control:Lteec/shell/term_shell/runtime/TerminalServer$Control;
  :L50
    const-string v11, ""
    const-wide/16 v19, 0
    const-string v14, "0"
    const-string v15, "content-length"
    move-object/from16 v17, v5
    if-eqz v10, :L62
  :L51
    invoke-virtual { v13 }, Ljava/net/URI;->getPath()Ljava/lang/String;
    move-result-object v10
    const-string v5, "/control/"
    invoke-virtual { v10, v5 }, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v5
    if-eqz v5, :L62
  .line 179
    new-instance v0, Ljava/io/ByteArrayOutputStream;
    invoke-direct { v0 }, Ljava/io/ByteArrayOutputStream;-><init>()V
  .line 180
    invoke-interface { v12, v15, v14 }, Ljava/util/Map;->getOrDefault(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v5
    check-cast v5, Ljava/lang/String;
    invoke-static { v5 }, Ljava/lang/Long;->parseLong(Ljava/lang/String;)J
    move-result-wide v14
  .line 181
    const/16 v5, 16384
    new-array v5, v5, [B
  :L52
  .line 182
    cmp-long v8, v14, v19
    if-lez v8, :L54
  .line 183
    move-object/from16 v21, v11
    move-object/from16 v22, v13
    const-wide/16 v10, 16384
    invoke-static { v10, v11, v14, v15 }, Ljava/lang/Math;->min(JJ)J
    move-result-wide v12
    long-to-int v8, v12
    const/4 v10, 0
    invoke-virtual { v3, v5, v10, v8 }, Ljava/io/InputStream;->read([BII)I
    move-result v8
  .line 184
    if-ltz v8, :L53
  .line 185
    invoke-virtual { v0, v5, v10, v8 }, Ljava/io/ByteArrayOutputStream;->write([BII)V
    int-to-long v10, v8
    sub-long/2addr v14, v10
  .line 186
    move-object/from16 v11, v21
    move-object/from16 v13, v22
    goto :L52
  :L53
  .line 184
    new-instance v0, Ljava/io/EOFException;
    invoke-direct { v0 }, Ljava/io/EOFException;-><init>()V
    throw v0
  :L54
  .line 187
    move-object/from16 v21, v11
    move-object/from16 v22, v13
    iget-object v3, v1, Lteec/shell/term_shell/runtime/TerminalServer;->control:Lteec/shell/term_shell/runtime/TerminalServer$Control;
    const/16 v18, 0
    aget-object v5, v17, v18
    new-instance v8, Ljava/lang/StringBuilder;
    invoke-direct { v8 }, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual/range { v22 .. v22 }, Ljava/net/URI;->getRawPath()Ljava/lang/String;
    move-result-object v10
    invoke-virtual { v8, v10 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v8
    invoke-virtual/range { v22 .. v22 }, Ljava/net/URI;->getRawQuery()Ljava/lang/String;
    move-result-object v10
    if-nez v10, :L55
    move-object/from16 v11, v21
    goto :L56
  :L55
    new-instance v10, Ljava/lang/StringBuilder;
    invoke-direct { v10 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v11, "?"
    invoke-virtual { v10, v11 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v10
    invoke-virtual/range { v22 .. v22 }, Ljava/net/URI;->getRawQuery()Ljava/lang/String;
    move-result-object v11
    invoke-virtual { v10, v11 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v10
    invoke-virtual { v10 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v11
  :L56
    invoke-virtual { v8, v11 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v8
    invoke-virtual { v8 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v8
    new-instance v10, Ljava/lang/String;
    invoke-virtual { v0 }, Ljava/io/ByteArrayOutputStream;->toByteArray()[B
    move-result-object v0
    sget-object v11, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;
    invoke-direct { v10, v0, v11 }, Ljava/lang/String;-><init>([BLjava/nio/charset/Charset;)V
    invoke-interface { v3, v5, v8, v10 }, Lteec/shell/term_shell/runtime/TerminalServer$Control;->request(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
  .line 188
    sget-object v3, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;
    invoke-virtual { v0, v3 }, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B
    move-result-object v0
    const/16 v18, 0
    aget-object v3, v17, v18
    invoke-virtual { v3, v9 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    const/16 v5, 200
    invoke-static { v4, v5, v7, v0, v3 }, Lteec/shell/term_shell/runtime/TerminalServer;->response(Ljava/io/OutputStream;ILjava/lang/String;[BZ)V
  :L57
  .line 285
    iget-object v0, v1, Lteec/shell/term_shell/runtime/TerminalServer;->sockets:Ljava/util/Set;
    invoke-interface { v0, v2 }, Ljava/util/Set;->remove(Ljava/lang/Object;)Z
  :L58
  .line 286
    invoke-virtual { v2 }, Ljava/net/Socket;->close()V
  :L59
    goto :L61
  :L60
    move-exception v0
  :L61
  .line 189
    return-void
  :L62
  .line 178
    move-object/from16 v21, v11
    move-object/from16 v22, v13
  :L63
  .line 191
    iget-object v5, v1, Lteec/shell/term_shell/runtime/TerminalServer;->files:Lteec/shell/term_shell/runtime/FileWorkspace;
  :L64
    const-string v11, "Not found"
    const/16 v13, 404
    if-eqz v5, :L87
  :L65
    invoke-virtual/range { v22 .. v22 }, Ljava/net/URI;->getPath()Ljava/lang/String;
    move-result-object v5
    const-string v10, "/files/"
    invoke-virtual { v5, v10 }, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v5
    if-eqz v5, :L87
  .line 193
    nop
  .line 194
    invoke-virtual/range { v22 .. v22 }, Ljava/net/URI;->getPath()Ljava/lang/String;
    move-result-object v5
    const-string v10, "/files/list"
    invoke-virtual { v5, v10 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v5
    if-eqz v5, :L66
    const/16 v18, 0
    aget-object v5, v17, v18
    invoke-virtual { v5, v8 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v5
    if-nez v5, :L66
    iget-object v0, v1, Lteec/shell/term_shell/runtime/TerminalServer;->files:Lteec/shell/term_shell/runtime/FileWorkspace;
    const-string v3, "side"
    move-object/from16 v5, v22
    invoke-static { v5, v3 }, Lteec/shell/term_shell/runtime/TerminalServer;->query(Ljava/net/URI;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v3
    const-string v8, "path"
    invoke-static { v5, v8 }, Lteec/shell/term_shell/runtime/TerminalServer;->query(Ljava/net/URI;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v5
    invoke-virtual { v0, v3, v5 }, Lteec/shell/term_shell/runtime/FileWorkspace;->list(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    const/16 v5, 200
    goto/16 :L75
  :L66
    move-object/from16 v5, v22
  .line 195
    invoke-virtual { v5 }, Ljava/net/URI;->getPath()Ljava/lang/String;
    move-result-object v10
    invoke-virtual { v10, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v10
    if-eqz v10, :L74
    const/16 v18, 0
    aget-object v10, v17, v18
    invoke-virtual { v10, v8 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v8
    if-eqz v8, :L74
  .line 196
    invoke-interface { v12, v15, v14 }, Ljava/util/Map;->getOrDefault(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v0
    check-cast v0, Ljava/lang/String;
    invoke-static { v0 }, Ljava/lang/Long;->parseLong(Ljava/lang/String;)J
    move-result-wide v10
  .line 197
    new-instance v0, Ljava/io/ByteArrayOutputStream;
    invoke-direct { v0 }, Ljava/io/ByteArrayOutputStream;-><init>()V
  .line 198
    const/16 v5, 16384
    new-array v5, v5, [B
  :L67
  .line 199
    cmp-long v8, v10, v19
    if-lez v8, :L69
  .line 200
    const-wide/16 v12, 16384
    invoke-static { v12, v13, v10, v11 }, Ljava/lang/Math;->min(JJ)J
    move-result-wide v14
    long-to-int v8, v14
    const/4 v14, 0
    invoke-virtual { v3, v5, v14, v8 }, Ljava/io/InputStream;->read([BII)I
    move-result v8
  .line 201
    if-ltz v8, :L68
  .line 202
    invoke-virtual { v0, v5, v14, v8 }, Ljava/io/ByteArrayOutputStream;->write([BII)V
    int-to-long v14, v8
    sub-long/2addr v10, v14
  .line 203
    goto :L67
  :L68
  .line 201
    new-instance v0, Ljava/io/EOFException;
    invoke-direct { v0 }, Ljava/io/EOFException;-><init>()V
    throw v0
  :L69
  .line 204
    new-instance v3, Ljava/util/HashMap;
    invoke-direct { v3 }, Ljava/util/HashMap;-><init>()V
  .line 205
    new-instance v5, Ljava/lang/String;
    invoke-virtual { v0 }, Ljava/io/ByteArrayOutputStream;->toByteArray()[B
    move-result-object v0
    sget-object v8, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;
    invoke-direct { v5, v0, v8 }, Ljava/lang/String;-><init>([BLjava/nio/charset/Charset;)V
    const-string v0, "&"
    invoke-virtual { v5, v0 }, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;
    move-result-object v0
    array-length v5, v0
    const/4 v8, 0
  :L70
    if-ge v8, v5, :L73
    aget-object v10, v0, v8
  .line 206
    const-string v11, "="
    const/4 v12, 2
    invoke-virtual { v10, v11, v12 }, Ljava/lang/String;->split(Ljava/lang/String;I)[Ljava/lang/String;
    move-result-object v10
  .line 207
    array-length v11, v10
    const/4 v12, 2
    if-ne v11, v12, :L72
  .line 208
    const/16 v18, 0
    aget-object v11, v10, v18
    const-string v12, "UTF-8"
    invoke-static { v11, v12 }, Ljava/net/URLDecoder;->decode(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v11
  .line 209
    invoke-interface { v3, v11 }, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v12
    check-cast v12, Ljava/util/List;
  .line 210
    if-nez v12, :L71
    new-instance v12, Ljava/util/ArrayList;
    invoke-direct { v12 }, Ljava/util/ArrayList;-><init>()V
    invoke-interface { v3, v11, v12 }, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
  :L71
  .line 211
    aget-object v10, v10, v16
    const-string v11, "UTF-8"
    invoke-static { v10, v11 }, Ljava/net/URLDecoder;->decode(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v10
    invoke-interface { v12, v10 }, Ljava/util/List;->add(Ljava/lang/Object;)Z
  :L72
  .line 205
    add-int/lit8 v8, v8, 1
    goto :L70
  :L73
  .line 214
    iget-object v0, v1, Lteec/shell/term_shell/runtime/TerminalServer;->files:Lteec/shell/term_shell/runtime/FileWorkspace;
    invoke-virtual { v0, v3 }, Lteec/shell/term_shell/runtime/FileWorkspace;->submit(Ljava/util/Map;)Ljava/lang/String;
    move-result-object v0
  .line 215
    const/16 v5, 201
    goto :L75
  :L74
    invoke-virtual { v5 }, Ljava/net/URI;->getPath()Ljava/lang/String;
    move-result-object v3
    invoke-virtual { v3, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :L81
    iget-object v0, v1, Lteec/shell/term_shell/runtime/TerminalServer;->files:Lteec/shell/term_shell/runtime/FileWorkspace;
    invoke-virtual { v0 }, Lteec/shell/term_shell/runtime/FileWorkspace;->jobs()Ljava/lang/String;
    move-result-object v0
    const/16 v5, 200
  :L75
  .line 217
    sget-object v3, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;
    invoke-virtual { v0, v3 }, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B
    move-result-object v0
    const/16 v18, 0
    aget-object v3, v17, v18
    invoke-virtual { v3, v9 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    invoke-static { v4, v5, v7, v0, v3 }, Lteec/shell/term_shell/runtime/TerminalServer;->response(Ljava/io/OutputStream;ILjava/lang/String;[BZ)V
  :L76
  .line 285
    iget-object v0, v1, Lteec/shell/term_shell/runtime/TerminalServer;->sockets:Ljava/util/Set;
    invoke-interface { v0, v2 }, Ljava/util/Set;->remove(Ljava/lang/Object;)Z
  :L77
  .line 286
    invoke-virtual { v2 }, Ljava/net/Socket;->close()V
  :L78
    goto :L80
  :L79
    move-exception v0
  :L80
  .line 218
    return-void
  :L81
  .line 216
    sget-object v0, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;
    invoke-virtual { v11, v0 }, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B
    move-result-object v0
    const/4 v14, 0
    invoke-static { v4, v13, v6, v0, v14 }, Lteec/shell/term_shell/runtime/TerminalServer;->response(Ljava/io/OutputStream;ILjava/lang/String;[BZ)V
  :L82
  .line 285
    iget-object v0, v1, Lteec/shell/term_shell/runtime/TerminalServer;->sockets:Ljava/util/Set;
    invoke-interface { v0, v2 }, Ljava/util/Set;->remove(Ljava/lang/Object;)Z
  :L83
  .line 286
    invoke-virtual { v2 }, Ljava/net/Socket;->close()V
  :L84
    goto :L86
  :L85
    move-exception v0
  :L86
  .line 216
    return-void
  :L87
  .line 191
    move-object/from16 v5, v22
  .line 220
    const/16 v18, 0
  :L88
    aget-object v0, v17, v18
    invoke-virtual { v0, v8 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
  :L89
    const/16 v8, 10
    const-string v10, "/sessions"
    if-eqz v0, :L111
  :L90
  .line 221
    invoke-virtual { v5 }, Ljava/net/URI;->getPath()Ljava/lang/String;
    move-result-object v0
    invoke-virtual { v0, v10 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :L97
  .line 222
    iget-object v0, v1, Lteec/shell/term_shell/runtime/TerminalServer;->provider:Lteec/shell/term_shell/runtime/TerminalServer$Provider;
    invoke-interface { v0 }, Lteec/shell/term_shell/runtime/TerminalServer$Provider;->admission()Lteec/shell/term_shell/runtime/TerminalServer$Admission;
    move-result-object v0
    iget-boolean v0, v0, Lteec/shell/term_shell/runtime/TerminalServer$Admission;->terminalAllowed:Z
    if-nez v0, :L96
  .line 223
    iget-object v0, v1, Lteec/shell/term_shell/runtime/TerminalServer;->provider:Lteec/shell/term_shell/runtime/TerminalServer$Provider;
    invoke-interface { v0 }, Lteec/shell/term_shell/runtime/TerminalServer$Provider;->current()Lteec/shell/term_shell/runtime/TerminalServer$State;
    move-result-object v0
    invoke-direct { v1, v0 }, Lteec/shell/term_shell/runtime/TerminalServer;->stateJson(Lteec/shell/term_shell/runtime/TerminalServer$State;)Ljava/lang/String;
    move-result-object v0
    sget-object v3, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;
    invoke-virtual { v0, v3 }, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B
    move-result-object v0
    const/16 v3, 503
    const/4 v14, 0
    invoke-static { v4, v3, v7, v0, v14 }, Lteec/shell/term_shell/runtime/TerminalServer;->response(Ljava/io/OutputStream;ILjava/lang/String;[BZ)V
  :L91
  .line 285
    iget-object v0, v1, Lteec/shell/term_shell/runtime/TerminalServer;->sockets:Ljava/util/Set;
    invoke-interface { v0, v2 }, Ljava/util/Set;->remove(Ljava/lang/Object;)Z
  :L92
  .line 286
    invoke-virtual { v2 }, Ljava/net/Socket;->close()V
  :L93
    goto :L95
  :L94
    move-exception v0
  :L95
  .line 224
    return-void
  :L96
  .line 226
    iget-object v0, v1, Lteec/shell/term_shell/runtime/TerminalServer;->provider:Lteec/shell/term_shell/runtime/TerminalServer$Provider;
    invoke-interface { v0 }, Lteec/shell/term_shell/runtime/TerminalServer$Provider;->create()Lteec/shell/term_shell/runtime/TerminalServer$State;
    move-result-object v0
    invoke-direct { v1, v0 }, Lteec/shell/term_shell/runtime/TerminalServer;->stateJson(Lteec/shell/term_shell/runtime/TerminalServer$State;)Ljava/lang/String;
    move-result-object v0
    sget-object v3, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;
    invoke-virtual { v0, v3 }, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B
    move-result-object v0
    const/16 v3, 201
    const/4 v14, 0
    invoke-static { v4, v3, v7, v0, v14 }, Lteec/shell/term_shell/runtime/TerminalServer;->response(Ljava/io/OutputStream;ILjava/lang/String;[BZ)V
    goto :L106
  :L97
  .line 227
    invoke-virtual { v5 }, Ljava/net/URI;->getPath()Ljava/lang/String;
    move-result-object v0
    const-string v3, "/sessions/"
    invoke-virtual { v0, v3 }, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v0
    if-eqz v0, :L104
    invoke-virtual { v5 }, Ljava/net/URI;->getPath()Ljava/lang/String;
    move-result-object v0
    const-string v3, "/close"
    invoke-virtual { v0, v3 }, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v0
    if-eqz v0, :L104
  .line 228
    invoke-virtual { v5 }, Ljava/net/URI;->getPath()Ljava/lang/String;
    move-result-object v0
    invoke-virtual { v5 }, Ljava/net/URI;->getPath()Ljava/lang/String;
    move-result-object v3
    invoke-virtual { v3 }, Ljava/lang/String;->length()I
    move-result v3
    add-int/lit8 v3, v3, -6
    invoke-virtual { v0, v8, v3 }, Ljava/lang/String;->substring(II)Ljava/lang/String;
    move-result-object v0
  .line 229
    iget-object v3, v1, Lteec/shell/term_shell/runtime/TerminalServer;->provider:Lteec/shell/term_shell/runtime/TerminalServer$Provider;
    invoke-interface { v3, v0 }, Lteec/shell/term_shell/runtime/TerminalServer$Provider;->find(Ljava/lang/String;)Lteec/shell/term_shell/runtime/TerminalServer$State;
    move-result-object v3
  .line 230
    if-nez v3, :L103
    const-string v0, "{}"
    sget-object v3, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;
    invoke-virtual { v0, v3 }, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B
    move-result-object v0
    const/4 v14, 0
    invoke-static { v4, v13, v7, v0, v14 }, Lteec/shell/term_shell/runtime/TerminalServer;->response(Ljava/io/OutputStream;ILjava/lang/String;[BZ)V
  :L98
  .line 285
    iget-object v0, v1, Lteec/shell/term_shell/runtime/TerminalServer;->sockets:Ljava/util/Set;
    invoke-interface { v0, v2 }, Ljava/util/Set;->remove(Ljava/lang/Object;)Z
  :L99
  .line 286
    invoke-virtual { v2 }, Ljava/net/Socket;->close()V
  :L100
    goto :L102
  :L101
    move-exception v0
  :L102
  .line 230
    return-void
  :L103
  .line 231
    iget-object v5, v1, Lteec/shell/term_shell/runtime/TerminalServer;->provider:Lteec/shell/term_shell/runtime/TerminalServer$Provider;
    invoke-interface { v5, v0 }, Lteec/shell/term_shell/runtime/TerminalServer$Provider;->stop(Ljava/lang/String;)V
  .line 232
    invoke-direct { v1, v3 }, Lteec/shell/term_shell/runtime/TerminalServer;->stateJson(Lteec/shell/term_shell/runtime/TerminalServer$State;)Ljava/lang/String;
    move-result-object v0
    sget-object v3, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;
    invoke-virtual { v0, v3 }, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B
    move-result-object v0
    const/16 v5, 200
    const/4 v14, 0
    invoke-static { v4, v5, v7, v0, v14 }, Lteec/shell/term_shell/runtime/TerminalServer;->response(Ljava/io/OutputStream;ILjava/lang/String;[BZ)V
    goto :L105
  :L104
  .line 233
    sget-object v0, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;
    invoke-virtual { v11, v0 }, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B
    move-result-object v0
    const/4 v14, 0
    invoke-static { v4, v13, v6, v0, v14 }, Lteec/shell/term_shell/runtime/TerminalServer;->response(Ljava/io/OutputStream;ILjava/lang/String;[BZ)V
  :L105
    nop
  :L106
  .line 285
    iget-object v0, v1, Lteec/shell/term_shell/runtime/TerminalServer;->sockets:Ljava/util/Set;
    invoke-interface { v0, v2 }, Ljava/util/Set;->remove(Ljava/lang/Object;)Z
  :L107
  .line 286
    invoke-virtual { v2 }, Ljava/net/Socket;->close()V
  :L108
    goto :L110
  :L109
    move-exception v0
  :L110
  .line 234
    return-void
  :L111
  .line 236
    invoke-virtual { v5 }, Ljava/net/URI;->getPath()Ljava/lang/String;
    move-result-object v0
    invoke-virtual { v0, v10 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :L120
  .line 237
    new-instance v0, Ljava/lang/StringBuilder;
    const-string v3, "{\"sessions\":["
    invoke-direct { v0, v3 }, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V
  .line 238
    iget-object v3, v1, Lteec/shell/term_shell/runtime/TerminalServer;->provider:Lteec/shell/term_shell/runtime/TerminalServer$Provider;
    invoke-interface { v3 }, Lteec/shell/term_shell/runtime/TerminalServer$Provider;->list()[Lteec/shell/term_shell/runtime/TerminalServer$State;
    move-result-object v3
    array-length v5, v3
    const/4 v8, 0
  :L112
    if-ge v8, v5, :L114
    aget-object v10, v3, v8
  .line 239
    invoke-virtual { v0 }, Ljava/lang/StringBuilder;->length()I
    move-result v11
    const/16 v12, 13
    if-le v11, v12, :L113
    const/16 v11, 44
    invoke-virtual { v0, v11 }, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;
  :L113
  .line 240
    invoke-direct { v1, v10 }, Lteec/shell/term_shell/runtime/TerminalServer;->stateJson(Lteec/shell/term_shell/runtime/TerminalServer$State;)Ljava/lang/String;
    move-result-object v10
    invoke-virtual { v0, v10 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
  .line 238
    add-int/lit8 v8, v8, 1
    goto :L112
  :L114
  .line 242
    const-string v3, "]}"
    invoke-virtual { v0, v3 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual { v0 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    sget-object v3, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;
    invoke-virtual { v0, v3 }, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B
    move-result-object v0
    const/16 v18, 0
    aget-object v3, v17, v18
    invoke-virtual { v3, v9 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    const/16 v5, 200
    invoke-static { v4, v5, v7, v0, v3 }, Lteec/shell/term_shell/runtime/TerminalServer;->response(Ljava/io/OutputStream;ILjava/lang/String;[BZ)V
  :L115
  .line 285
    iget-object v0, v1, Lteec/shell/term_shell/runtime/TerminalServer;->sockets:Ljava/util/Set;
    invoke-interface { v0, v2 }, Ljava/util/Set;->remove(Ljava/lang/Object;)Z
  :L116
  .line 286
    invoke-virtual { v2 }, Ljava/net/Socket;->close()V
  :L117
    goto :L119
  :L118
    move-exception v0
  :L119
  .line 243
    return-void
  :L120
  .line 245
    invoke-virtual { v5 }, Ljava/net/URI;->getPath()Ljava/lang/String;
    move-result-object v0
    const-string v10, "/ws"
    invoke-virtual { v0, v10 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :L136
  .line 246
    iget-object v0, v1, Lteec/shell/term_shell/runtime/TerminalServer;->provider:Lteec/shell/term_shell/runtime/TerminalServer$Provider;
    const-string v8, "session"
    invoke-static { v5, v8 }, Lteec/shell/term_shell/runtime/TerminalServer;->query(Ljava/net/URI;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v8
    invoke-interface { v0, v8 }, Lteec/shell/term_shell/runtime/TerminalServer$Provider;->find(Ljava/lang/String;)Lteec/shell/term_shell/runtime/TerminalServer$State;
    move-result-object v0
    if-nez v0, :L126
  .line 247
    const-string v0, "Onbekende terminalsessie"
    sget-object v3, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;
    invoke-virtual { v0, v3 }, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B
    move-result-object v0
    const/4 v14, 0
    invoke-static { v4, v13, v6, v0, v14 }, Lteec/shell/term_shell/runtime/TerminalServer;->response(Ljava/io/OutputStream;ILjava/lang/String;[BZ)V
  :L121
  .line 285
    iget-object v0, v1, Lteec/shell/term_shell/runtime/TerminalServer;->sockets:Ljava/util/Set;
    invoke-interface { v0, v2 }, Ljava/util/Set;->remove(Ljava/lang/Object;)Z
  :L122
  .line 286
    invoke-virtual { v2 }, Ljava/net/Socket;->close()V
  :L123
    goto :L125
  :L124
    move-exception v0
  :L125
  .line 248
    return-void
  :L126
  .line 250
    const-string v0, "websocket"
    const-string v8, "upgrade"
    invoke-interface { v12, v8 }, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v8
    check-cast v8, Ljava/lang/String;
    invoke-virtual { v0, v8 }, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z
    move-result v0
    if-eqz v0, :L135
    const-string v0, "13"
    const-string v8, "sec-websocket-version"
    invoke-interface { v12, v8 }, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v8
    invoke-virtual { v0, v8 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :L135
    const-string v0, "sec-websocket-key"
    invoke-interface { v12, v0 }, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :L135
  .line 251
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct { v0 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v8, "sec-websocket-key"
    invoke-interface { v12, v8 }, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v8
    check-cast v8, Ljava/lang/String;
    invoke-virtual { v0, v8 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    const-string v8, "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
    invoke-virtual { v0, v8 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual { v0 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
  .line 252
    const-string v8, "SHA-1"
    invoke-static { v8 }, Ljava/security/MessageDigest;->getInstance(Ljava/lang/String;)Ljava/security/MessageDigest;
    move-result-object v8
    sget-object v9, Ljava/nio/charset/StandardCharsets;->US_ASCII:Ljava/nio/charset/Charset;
    invoke-virtual { v0, v9 }, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B
    move-result-object v0
    invoke-virtual { v8, v0 }, Ljava/security/MessageDigest;->digest([B)[B
    move-result-object v0
    invoke-static { v0 }, Lteec/shell/term_shell/runtime/TerminalServer;->base64([B)Ljava/lang/String;
    move-result-object v0
  .line 253
    new-instance v8, Ljava/lang/StringBuilder;
    invoke-direct { v8 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v9, "HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Accept: "
    invoke-virtual { v8, v9 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v8
    invoke-virtual { v8, v0 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    const-string v8, "\r\n\r\n"
    invoke-virtual { v0, v8 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual { v0 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    sget-object v8, Ljava/nio/charset/StandardCharsets;->US_ASCII:Ljava/nio/charset/Charset;
    invoke-virtual { v0, v8 }, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B
    move-result-object v0
    invoke-virtual { v4, v0 }, Ljava/io/OutputStream;->write([B)V
  .line 254
    invoke-virtual { v4 }, Ljava/io/OutputStream;->flush()V
  :L127
  .line 255
    nop
  .line 256
    const/4 v14, 0
  :L128
    invoke-virtual { v2, v14 }, Ljava/net/Socket;->setSoTimeout(I)V
  .line 257
    new-instance v0, Lteec/shell/term_shell/runtime/TerminalServer$Connection;
    invoke-direct/range { v0 .. v5 }, Lteec/shell/term_shell/runtime/TerminalServer$Connection;-><init>(Lteec/shell/term_shell/runtime/TerminalServer;Ljava/net/Socket;Ljava/io/InputStream;Ljava/io/OutputStream;Ljava/net/URI;)V
    invoke-static { v0 }, Lteec/shell/term_shell/runtime/TerminalServer$Connection;->access$000(Lteec/shell/term_shell/runtime/TerminalServer$Connection;)V
  :L129
  .line 285
    iget-object v0, v1, Lteec/shell/term_shell/runtime/TerminalServer;->sockets:Ljava/util/Set;
    invoke-interface { v0, v2 }, Ljava/util/Set;->remove(Ljava/lang/Object;)Z
  :L130
  .line 286
    invoke-virtual { v2 }, Ljava/net/Socket;->close()V
  :L131
    goto :L133
  :L132
    move-exception v0
  :L133
  .line 258
    return-void
  :L134
  .line 276
    move-exception v0
    move/from16 v12, v16
    goto/16 :L159
  :L135
  .line 250
    new-instance v0, Ljava/io/IOException;
    const-string v3, "Invalid WebSocket handshake"
    invoke-direct { v0, v3 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw v0
  :L136
  .line 260
    invoke-virtual { v5 }, Ljava/net/URI;->getPath()Ljava/lang/String;
    move-result-object v0
    const-string v3, "/health"
    invoke-virtual { v0, v3 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :L142
  .line 261
    iget-object v0, v1, Lteec/shell/term_shell/runtime/TerminalServer;->provider:Lteec/shell/term_shell/runtime/TerminalServer$Provider;
    invoke-interface { v0 }, Lteec/shell/term_shell/runtime/TerminalServer$Provider;->current()Lteec/shell/term_shell/runtime/TerminalServer$State;
    move-result-object v0
    invoke-direct { v1, v0 }, Lteec/shell/term_shell/runtime/TerminalServer;->stateJson(Lteec/shell/term_shell/runtime/TerminalServer$State;)Ljava/lang/String;
    move-result-object v0
    sget-object v3, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;
    invoke-virtual { v0, v3 }, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B
    move-result-object v0
    const/16 v18, 0
    aget-object v3, v17, v18
    invoke-virtual { v3, v9 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    const/16 v5, 200
    invoke-static { v4, v5, v7, v0, v3 }, Lteec/shell/term_shell/runtime/TerminalServer;->response(Ljava/io/OutputStream;ILjava/lang/String;[BZ)V
  :L137
  .line 285
    iget-object v0, v1, Lteec/shell/term_shell/runtime/TerminalServer;->sockets:Ljava/util/Set;
    invoke-interface { v0, v2 }, Ljava/util/Set;->remove(Ljava/lang/Object;)Z
  :L138
  .line 286
    invoke-virtual { v2 }, Ljava/net/Socket;->close()V
  :L139
    goto :L141
  :L140
    move-exception v0
  :L141
  .line 262
    return-void
  :L142
  .line 264
    invoke-virtual { v5 }, Ljava/net/URI;->getPath()Ljava/lang/String;
    move-result-object v0
  .line 265
    const-string v3, "/"
    invoke-virtual { v0, v3 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-nez v3, :L143
    const-string v3, "/terminal"
    invoke-virtual { v0, v3 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-nez v3, :L143
    const-string v3, "/terminal/"
    invoke-virtual { v0, v3 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-eqz v3, :L144
  :L143
    const-string v0, "/terminal/index.html"
  :L144
  .line 266
    const-string v3, "/terminal/"
    invoke-virtual { v0, v3 }, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v3
    if-eqz v3, :L145
    invoke-virtual { v0, v8 }, Ljava/lang/String;->substring(I)Ljava/lang/String;
    move-result-object v0
    goto :L146
  :L145
    move-object/from16 v0, v21
  :L146
  .line 267
    invoke-static { v0 }, Lteec/shell/term_shell/runtime/TerminalServer;->terminalAssetName(Ljava/lang/String;)Z
    move-result v3
    if-nez v3, :L152
  .line 268
    sget-object v0, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;
    invoke-virtual { v11, v0 }, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B
    move-result-object v0
    const/16 v18, 0
    aget-object v3, v17, v18
    invoke-virtual { v3, v9 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    invoke-static { v4, v13, v6, v0, v3 }, Lteec/shell/term_shell/runtime/TerminalServer;->response(Ljava/io/OutputStream;ILjava/lang/String;[BZ)V
  :L147
  .line 285
    iget-object v0, v1, Lteec/shell/term_shell/runtime/TerminalServer;->sockets:Ljava/util/Set;
    invoke-interface { v0, v2 }, Ljava/util/Set;->remove(Ljava/lang/Object;)Z
  :L148
  .line 286
    invoke-virtual { v2 }, Ljava/net/Socket;->close()V
  :L149
    goto :L151
  :L150
    move-exception v0
  :L151
  .line 269
    return-void
  :L152
  .line 272
    invoke-static { v0 }, Lteec/shell/term_shell/runtime/TerminalServer;->assetMime(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v3
    iget-object v5, v1, Lteec/shell/term_shell/runtime/TerminalServer;->assets:Lteec/shell/term_shell/runtime/TerminalServer$Assets;
    new-instance v8, Ljava/lang/StringBuilder;
    invoke-direct { v8 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v10, "terminal/"
    invoke-virtual { v8, v10 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v8
    invoke-virtual { v8, v0 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual { v0 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-interface { v5, v0 }, Lteec/shell/term_shell/runtime/TerminalServer$Assets;->read(Ljava/lang/String;)[B
    move-result-object v0
    const/16 v18, 0
    aget-object v5, v17, v18
    invoke-virtual { v5, v9 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v5
    const/16 v8, 200
    invoke-static { v4, v8, v3, v0, v5 }, Lteec/shell/term_shell/runtime/TerminalServer;->response(Ljava/io/OutputStream;ILjava/lang/String;[BZ)V
  :L153
  .line 275
    goto :L156
  :L154
  .line 273
    move-exception v0
  :L155
  .line 274
    sget-object v0, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;
    invoke-virtual { v11, v0 }, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B
    move-result-object v0
    const/16 v18, 0
    aget-object v3, v17, v18
    invoke-virtual { v3, v9 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    invoke-static { v4, v13, v6, v0, v3 }, Lteec/shell/term_shell/runtime/TerminalServer;->response(Ljava/io/OutputStream;ILjava/lang/String;[BZ)V
  :L156
  .line 285
    iget-object v0, v1, Lteec/shell/term_shell/runtime/TerminalServer;->sockets:Ljava/util/Set;
    invoke-interface { v0, v2 }, Ljava/util/Set;->remove(Ljava/lang/Object;)Z
    goto :L173
  :L157
    move-exception v0
    move-object v3, v0
    goto :L167
  :L158
  .line 276
    move-exception v0
    const/4 v12, 0
  :L159
  .line 277
    if-nez v12, :L172
  :L160
    iget-boolean v3, v1, Lteec/shell/term_shell/runtime/TerminalServer;->closed:Z
    if-nez v3, :L172
    instance-of v3, v0, Ljava/io/EOFException;
    if-nez v3, :L172
    instance-of v3, v0, Ljava/net/SocketException;
  :L161
    if-nez v3, :L172
  :L162
  .line 279
    instance-of v3, v0, Lteec/shell/term_shell/runtime/TerminalServer$AdmissionDenied;
    if-eqz v3, :L163
    invoke-virtual { v2 }, Ljava/net/Socket;->getOutputStream()Ljava/io/OutputStream;
    move-result-object v0
    iget-object v3, v1, Lteec/shell/term_shell/runtime/TerminalServer;->provider:Lteec/shell/term_shell/runtime/TerminalServer$Provider;
    invoke-interface { v3 }, Lteec/shell/term_shell/runtime/TerminalServer$Provider;->current()Lteec/shell/term_shell/runtime/TerminalServer$State;
    move-result-object v3
    invoke-direct { v1, v3 }, Lteec/shell/term_shell/runtime/TerminalServer;->stateJson(Lteec/shell/term_shell/runtime/TerminalServer$State;)Ljava/lang/String;
    move-result-object v3
    sget-object v4, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;
    invoke-virtual { v3, v4 }, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B
    move-result-object v3
    const/16 v4, 503
    const/4 v14, 0
    invoke-static { v0, v4, v7, v3, v14 }, Lteec/shell/term_shell/runtime/TerminalServer;->response(Ljava/io/OutputStream;ILjava/lang/String;[BZ)V
    goto :L166
  :L163
  .line 280
    invoke-virtual { v2 }, Ljava/net/Socket;->getOutputStream()Ljava/io/OutputStream;
    move-result-object v3
    invoke-virtual { v0 }, Ljava/lang/Exception;->toString()Ljava/lang/String;
    move-result-object v0
    sget-object v4, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;
    invoke-virtual { v0, v4 }, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B
    move-result-object v0
    const/16 v4, 500
    const/4 v14, 0
    invoke-static { v3, v4, v6, v0, v14 }, Lteec/shell/term_shell/runtime/TerminalServer;->response(Ljava/io/OutputStream;ILjava/lang/String;[BZ)V
  :L164
    goto :L166
  :L165
  .line 282
    move-exception v0
  :L166
    goto :L172
  :L167
  .line 285
    iget-object v0, v1, Lteec/shell/term_shell/runtime/TerminalServer;->sockets:Ljava/util/Set;
    invoke-interface { v0, v2 }, Ljava/util/Set;->remove(Ljava/lang/Object;)Z
  :L168
  .line 286
    invoke-virtual { v2 }, Ljava/net/Socket;->close()V
  :L169
    goto :L171
  :L170
    move-exception v0
  :L171
  .line 287
    throw v3
  :L172
  .line 285
    iget-object v0, v1, Lteec/shell/term_shell/runtime/TerminalServer;->sockets:Ljava/util/Set;
    invoke-interface { v0, v2 }, Ljava/util/Set;->remove(Ljava/lang/Object;)Z
  :L173
  .line 286
    invoke-virtual { v2 }, Ljava/net/Socket;->close()V
  :L174
    goto :L176
  :L175
    move-exception v0
  .line 287
    nop
  :L176
  .line 288
    return-void
.end method

.method private stateJson(Lteec/shell/term_shell/runtime/TerminalServer$State;)Ljava/lang/String;
  .registers 7
  .line 436
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct { v0 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "{\"type\":\"state\",\"session\":"
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    iget-object v1, p1, Lteec/shell/term_shell/runtime/TerminalServer$State;->id:Ljava/lang/String;
    invoke-static { v1 }, Lteec/shell/term_shell/runtime/TerminalServer;->quote(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    const-string v1, ",\"running\":"
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    iget-object v1, p1, Lteec/shell/term_shell/runtime/TerminalServer$State;->session:Lteec/shell/term_shell/runtime/PtySession;
    const/4 v2, 1
    const/4 v3, 0
    if-eqz v1, :L0
    iget-object v1, p1, Lteec/shell/term_shell/runtime/TerminalServer$State;->session:Lteec/shell/term_shell/runtime/PtySession;
    invoke-virtual { v1 }, Lteec/shell/term_shell/runtime/PtySession;->running()Z
    move-result v1
    if-eqz v1, :L0
    move v1, v2
    goto :L1
  :L0
    move v1, v3
  :L1
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;
    move-result-object v0
    const-string v1, ",\"pid\":"
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
  .line 437
    iget-object v1, p1, Lteec/shell/term_shell/runtime/TerminalServer$State;->session:Lteec/shell/term_shell/runtime/PtySession;
    const/4 v4, -1
    if-nez v1, :L2
    move v1, v4
    goto :L3
  :L2
    iget-object v1, p1, Lteec/shell/term_shell/runtime/TerminalServer$State;->session:Lteec/shell/term_shell/runtime/PtySession;
    invoke-virtual { v1 }, Lteec/shell/term_shell/runtime/PtySession;->pid()I
    move-result v1
  :L3
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    move-result-object v0
    const-string v1, ",\"exit\":"
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    iget-object v1, p1, Lteec/shell/term_shell/runtime/TerminalServer$State;->session:Lteec/shell/term_shell/runtime/PtySession;
    if-nez v1, :L4
    goto :L5
  :L4
    iget-object v1, p1, Lteec/shell/term_shell/runtime/TerminalServer$State;->session:Lteec/shell/term_shell/runtime/PtySession;
    invoke-virtual { v1 }, Lteec/shell/term_shell/runtime/PtySession;->exitStatus()I
    move-result v4
  :L5
    invoke-virtual { v0, v4 }, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    move-result-object v0
    const-string v1, ",\"error\":"
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    iget-object v4, p1, Lteec/shell/term_shell/runtime/TerminalServer$State;->error:Ljava/lang/String;
    invoke-static { v4 }, Lteec/shell/term_shell/runtime/TerminalServer;->quote(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v4
    invoke-virtual { v0, v4 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    const-string v4, ",\"ssh\":{\"port\":8122,\"running\":"
    invoke-virtual { v0, v4 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    iget-object v4, p1, Lteec/shell/term_shell/runtime/TerminalServer$State;->ssh:Lteec/shell/term_shell/runtime/PtySession;
    if-eqz v4, :L6
    iget-object v4, p1, Lteec/shell/term_shell/runtime/TerminalServer$State;->ssh:Lteec/shell/term_shell/runtime/PtySession;
  .line 438
    invoke-virtual { v4 }, Lteec/shell/term_shell/runtime/PtySession;->running()Z
    move-result v4
    if-eqz v4, :L6
    goto :L7
  :L6
    move v2, v3
  :L7
    invoke-virtual { v0, v2 }, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    iget-object p1, p1, Lteec/shell/term_shell/runtime/TerminalServer$State;->sshError:Ljava/lang/String;
    invoke-static { p1 }, Lteec/shell/term_shell/runtime/TerminalServer;->quote(Ljava/lang/String;)Ljava/lang/String;
    move-result-object p1
    invoke-virtual { v0, p1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p1
    const-string v0, "},\"preflight\":"
    invoke-virtual { p1, v0 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p1
    iget-object v0, p0, Lteec/shell/term_shell/runtime/TerminalServer;->provider:Lteec/shell/term_shell/runtime/TerminalServer$Provider;
    invoke-interface { v0 }, Lteec/shell/term_shell/runtime/TerminalServer$Provider;->admission()Lteec/shell/term_shell/runtime/TerminalServer$Admission;
    move-result-object v0
    invoke-virtual { v0 }, Lteec/shell/term_shell/runtime/TerminalServer$Admission;->json()Ljava/lang/String;
    move-result-object v0
    invoke-virtual { p1, v0 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p1
    const-string v0, "}"
    invoke-virtual { p1, v0 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p1
    invoke-virtual { p1 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object p1
  .line 436
    return-object p1
.end method

.method static terminalAssetName(Ljava/lang/String;)Z
  .registers 6
  .line 291
    invoke-virtual { p0 }, Ljava/lang/String;->isEmpty()Z
    move-result v0
    const/4 v1, 0
    if-nez v0, :L5
    const/16 v0, 92
    invoke-virtual { p0, v0 }, Ljava/lang/String;->indexOf(I)I
    move-result v0
    if-gez v0, :L5
    invoke-virtual { p0, v1 }, Ljava/lang/String;->indexOf(I)I
    move-result v0
    if-ltz v0, :L0
    goto :L5
  :L0
  .line 292
    const-string v0, "/"
    const/4 v2, -1
    invoke-virtual { p0, v0, v2 }, Ljava/lang/String;->split(Ljava/lang/String;I)[Ljava/lang/String;
    move-result-object p0
    array-length v0, p0
    move v2, v1
  :L1
    if-ge v2, v0, :L4
    aget-object v3, p0, v2
    invoke-virtual { v3 }, Ljava/lang/String;->isEmpty()Z
    move-result v4
    if-nez v4, :L3
    const-string v4, "."
    invoke-virtual { v3, v4 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v4
    if-nez v4, :L3
    const-string v4, ".."
    invoke-virtual { v3, v4 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-eqz v3, :L2
    goto :L3
  :L2
    add-int/lit8 v2, v2, 1
    goto :L1
  :L3
    return v1
  :L4
  .line 293
    const/4 p0, 1
    return p0
  :L5
  .line 291
    return v1
.end method

.method public close()V
  .catch Ljava/io/IOException; { :L0 .. :L1 } :L2
  .catch Ljava/io/IOException; { :L5 .. :L6 } :L7
  .registers 3
  .line 573
    const/4 v0, 1
    iput-boolean v0, p0, Lteec/shell/term_shell/runtime/TerminalServer;->closed:Z
  :L0
  .line 574
    iget-object v0, p0, Lteec/shell/term_shell/runtime/TerminalServer;->listener:Ljava/net/ServerSocket;
    invoke-virtual { v0 }, Ljava/net/ServerSocket;->close()V
  :L1
    goto :L3
  :L2
    move-exception v0
  :L3
  .line 575
    iget-object v0, p0, Lteec/shell/term_shell/runtime/TerminalServer;->sockets:Ljava/util/Set;
    invoke-interface { v0 }, Ljava/util/Set;->iterator()Ljava/util/Iterator;
    move-result-object v0
  :L4
    invoke-interface { v0 }, Ljava/util/Iterator;->hasNext()Z
    move-result v1
    if-eqz v1, :L8
    invoke-interface { v0 }, Ljava/util/Iterator;->next()Ljava/lang/Object;
    move-result-object v1
    check-cast v1, Ljava/net/Socket;
  :L5
    invoke-virtual { v1 }, Ljava/net/Socket;->close()V
  :L6
    goto :L4
  :L7
    move-exception v1
    goto :L4
  :L8
  .line 576
    iget-object v0, p0, Lteec/shell/term_shell/runtime/TerminalServer;->clients:Ljava/util/concurrent/ExecutorService;
    invoke-interface { v0 }, Ljava/util/concurrent/ExecutorService;->shutdownNow()Ljava/util/List;
  .line 577
    return-void
.end method

.method synthetic lambda$accept$1$teec-shell-term_shell-runtime-TerminalServer(Ljava/net/Socket;)V
  .registers 2
  .line 138
    invoke-direct { p0, p1 }, Lteec/shell/term_shell/runtime/TerminalServer;->serve(Ljava/net/Socket;)V
    return-void
.end method

.method public port()I
  .registers 2
  .line 129
    iget-object v0, p0, Lteec/shell/term_shell/runtime/TerminalServer;->listener:Ljava/net/ServerSocket;
    invoke-virtual { v0 }, Ljava/net/ServerSocket;->getLocalPort()I
    move-result v0
    return v0
.end method
