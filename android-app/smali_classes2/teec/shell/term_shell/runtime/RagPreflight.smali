.class public final Lteec/shell/term_shell/runtime/RagPreflight;
.super Ljava/lang/Object;
.implements Lteec/shell/term_shell/runtime/TerminalServer$Preflight;
.source "RagPreflight.java"

.field public final static DEFAULT_ENABLED:Z = true

.field private final static SETTING:Ljava/lang/String; = "rag-preflight-enabled"

.field private final context:Landroid/content/Context;

.field private final rag:Lteec/shell/term_shell/runtime/SemanticRag;

.method public constructor <init>(Landroid/content/Context;Lteec/shell/term_shell/runtime/SemanticRag;)V
  .registers 3
  .line 17
    invoke-direct { p0 }, Ljava/lang/Object;-><init>()V
  .line 18
    invoke-virtual { p1 }, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;
    move-result-object p1
    iput-object p1, p0, Lteec/shell/term_shell/runtime/RagPreflight;->context:Landroid/content/Context;
  .line 19
    iput-object p2, p0, Lteec/shell/term_shell/runtime/RagPreflight;->rag:Lteec/shell/term_shell/runtime/SemanticRag;
  .line 20
    return-void
.end method

.method public static evaluate(ZLorg/json/JSONObject;)Lteec/shell/term_shell/runtime/TerminalServer$Admission;
  .registers 6
  .line 57
    const/4 v0, 1
    if-nez p0, :L0
    new-instance p0, Lteec/shell/term_shell/runtime/TerminalServer$Admission;
    const/4 p1, 0
    const-string v1, "owner_debug_bypass"
    invoke-direct { p0, p1, v0, v1 }, Lteec/shell/term_shell/runtime/TerminalServer$Admission;-><init>(ZZLjava/lang/String;)V
    return-object p0
  :L0
  .line 58
    sget-object p0, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;
    const-string v1, "ready"
    invoke-virtual { p1, v1 }, Lorg/json/JSONObject;->opt(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v1
    invoke-virtual { p0, v1 }, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z
    move-result p0
  .line 59
    const-string v1, ""
    if-eqz p0, :L1
    const-string v2, "rag_ready"
    goto :L2
  :L1
    const-string v2, "error"
    invoke-virtual { p1, v2, v1 }, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2
  :L2
  .line 60
    invoke-virtual { v2 }, Ljava/lang/String;->isEmpty()Z
    move-result v3
    if-eqz v3, :L3
    const-string v2, "reason"
    invoke-virtual { p1, v2, v1 }, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2
  :L3
  .line 61
    invoke-virtual { v2 }, Ljava/lang/String;->isEmpty()Z
    move-result p1
    if-eqz p1, :L4
    const-string v2, "rag_not_ready"
  :L4
  .line 62
    new-instance p1, Lteec/shell/term_shell/runtime/TerminalServer$Admission;
    invoke-direct { p1, v0, p0, v2 }, Lteec/shell/term_shell/runtime/TerminalServer$Admission;-><init>(ZZLjava/lang/String;)V
    return-object p1
.end method

.method public static isEnabled(Landroid/content/Context;)Z
  .catch Ljava/io/IOException; { :L0 .. :L1 } :L13
  .catchall { :L2 .. :L3 } :L7
  .catch Ljava/io/IOException; { :L4 .. :L6 } :L13
  .catchall { :L8 .. :L9 } :L10
  .catch Ljava/io/IOException; { :L11 .. :L13 } :L13
  .registers 8
  .line 23
    new-instance v0, Ljava/io/File;
    invoke-virtual { p0 }, Landroid/content/Context;->getFilesDir()Ljava/io/File;
    move-result-object p0
    const-string v1, "rag-preflight-enabled"
    invoke-direct { v0, p0, v1 }, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
  .line 24
    const/4 p0, 1
  :L0
    new-instance v1, Ljava/io/FileInputStream;
    invoke-direct { v1, v0 }, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V
  :L1
  .line 25
    const/4 v0, 6
  :L2
    new-array v0, v0, [B
  .line 26
    invoke-virtual { v1, v0 }, Ljava/io/FileInputStream;->read([B)I
    move-result v2
  .line 27
    const/4 v3, 5
    if-ne v2, v3, :L5
    invoke-virtual { v1 }, Ljava/io/FileInputStream;->read()I
    move-result v3
    const/4 v4, -1
    if-ne v3, v4, :L5
    const-string v3, "false"
    new-instance v4, Ljava/lang/String;
    sget-object v5, Ljava/nio/charset/StandardCharsets;->US_ASCII:Ljava/nio/charset/Charset;
    const/4 v6, 0
    invoke-direct { v4, v0, v6, v2, v5 }, Ljava/lang/String;-><init>([BIILjava/nio/charset/Charset;)V
    invoke-virtual { v3, v4 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
  :L3
    if-eqz v0, :L5
  :L4
  .line 29
    invoke-virtual { v1 }, Ljava/io/FileInputStream;->close()V
  .line 27
    return v6
  :L5
  .line 28
    nop
  .line 29
    invoke-virtual { v1 }, Ljava/io/FileInputStream;->close()V
  :L6
  .line 28
    return p0
  :L7
  .line 24
    move-exception v0
  :L8
    invoke-virtual { v1 }, Ljava/io/FileInputStream;->close()V
  :L9
    goto :L12
  :L10
    move-exception v1
  :L11
    invoke-virtual { v0, v1 }, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V
  :L12
    throw v0
  :L13
  .line 29
    move-exception v0
    return p0
.end method

.method public static setEnabled(Landroid/content/Context;Z)V
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/io/IOException;
    }
  .end annotation
  .catchall { :L0 .. :L1 } :L11
  .catchall { :L1 .. :L2 } :L5
  .catchall { :L2 .. :L3 } :L11
  .catchall { :L4 .. :L5 } :L11
  .catchall { :L6 .. :L7 } :L8
  .catchall { :L9 .. :L11 } :L11
  .registers 5
  .line 33
    invoke-virtual { p0 }, Landroid/content/Context;->getFilesDir()Ljava/io/File;
    move-result-object p0
  .line 34
    const-string v0, "rag-preflight-"
    const-string v1, ".tmp"
    invoke-static { v0, v1, p0 }, Ljava/io/File;->createTempFile(Ljava/lang/String;Ljava/lang/String;Ljava/io/File;)Ljava/io/File;
    move-result-object v0
  :L0
  .line 36
    new-instance v1, Ljava/io/FileOutputStream;
    invoke-direct { v1, v0 }, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V
  :L1
  .line 37
    invoke-static { p1 }, Ljava/lang/Boolean;->toString(Z)Ljava/lang/String;
    move-result-object p1
    sget-object v2, Ljava/nio/charset/StandardCharsets;->US_ASCII:Ljava/nio/charset/Charset;
    invoke-virtual { p1, v2 }, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B
    move-result-object p1
    invoke-virtual { v1, p1 }, Ljava/io/FileOutputStream;->write([B)V
  .line 38
    invoke-virtual { v1 }, Ljava/io/FileOutputStream;->getFD()Ljava/io/FileDescriptor;
    move-result-object p1
    invoke-virtual { p1 }, Ljava/io/FileDescriptor;->sync()V
  :L2
  .line 39
    invoke-virtual { v1 }, Ljava/io/FileOutputStream;->close()V
  .line 40
    new-instance p1, Ljava/io/File;
    const-string v1, "rag-preflight-enabled"
    invoke-direct { p1, p0, v1 }, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    invoke-virtual { v0, p1 }, Ljava/io/File;->renameTo(Ljava/io/File;)Z
    move-result p0
  :L3
    if-eqz p0, :L4
  .line 41
    invoke-virtual { v0 }, Ljava/io/File;->delete()Z
  .line 42
    return-void
  :L4
  .line 40
    new-instance p0, Ljava/io/IOException;
    const-string p1, "Preflight1-instelling kon niet worden opgeslagen"
    invoke-direct { p0, p1 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p0
  :L5
  .line 36
    move-exception p0
  :L6
    invoke-virtual { v1 }, Ljava/io/FileOutputStream;->close()V
  :L7
    goto :L10
  :L8
    move-exception p1
  :L9
    invoke-virtual { p0, p1 }, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V
  :L10
    throw p0
  :L11
  .line 41
    move-exception p0
    invoke-virtual { v0 }, Ljava/io/File;->delete()Z
    throw p0
.end method

.method public check()Lteec/shell/term_shell/runtime/TerminalServer$Admission;
  .registers 5
  .line 46
    iget-object v0, p0, Lteec/shell/term_shell/runtime/RagPreflight;->context:Landroid/content/Context;
    invoke-static { v0 }, Lteec/shell/term_shell/runtime/RagPreflight;->isEnabled(Landroid/content/Context;)Z
    move-result v0
    const/4 v1, 1
    if-nez v0, :L0
    new-instance v0, Lteec/shell/term_shell/runtime/TerminalServer$Admission;
    const/4 v2, 0
    const-string v3, "owner_debug_bypass"
    invoke-direct { v0, v2, v1, v3 }, Lteec/shell/term_shell/runtime/TerminalServer$Admission;-><init>(ZZLjava/lang/String;)V
    return-object v0
  :L0
  .line 47
    iget-object v0, p0, Lteec/shell/term_shell/runtime/RagPreflight;->rag:Lteec/shell/term_shell/runtime/SemanticRag;
    invoke-virtual { v0 }, Lteec/shell/term_shell/runtime/SemanticRag;->status()Lorg/json/JSONObject;
    move-result-object v0
    invoke-static { v1, v0 }, Lteec/shell/term_shell/runtime/RagPreflight;->evaluate(ZLorg/json/JSONObject;)Lteec/shell/term_shell/runtime/TerminalServer$Admission;
    move-result-object v0
    return-object v0
.end method

.method public request(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/lang/Exception;
    }
  .end annotation
  .registers 12
  .line 66
    invoke-static { p2 }, Ljava/net/URI;->create(Ljava/lang/String;)Ljava/net/URI;
    move-result-object p2
  .line 67
    invoke-virtual { p2 }, Ljava/net/URI;->getPath()Ljava/lang/String;
    move-result-object v0
  .line 69
    const-string v1, "GET"
    invoke-virtual { p1, v1 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    const-string v3, "HEAD"
    const-string v4, "/control/rag/status"
    if-nez v2, :L0
    invoke-virtual { p1, v3 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-eqz v2, :L1
  :L0
    invoke-virtual { v0, v4 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-eqz v2, :L1
    iget-object p1, p0, Lteec/shell/term_shell/runtime/RagPreflight;->rag:Lteec/shell/term_shell/runtime/SemanticRag;
    invoke-virtual { p1 }, Lteec/shell/term_shell/runtime/SemanticRag;->status()Lorg/json/JSONObject;
    move-result-object p1
    goto/16 :L18
  :L1
  .line 70
    invoke-virtual { p1, v1 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    const-string v5, ""
    const-string v6, "?"
    if-nez v2, :L2
    invoke-virtual { p1, v3 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-eqz v2, :L5
  :L2
    const-string v2, "/control/rag/events"
    invoke-virtual { v0, v2 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-eqz v2, :L5
    iget-object p1, p0, Lteec/shell/term_shell/runtime/RagPreflight;->rag:Lteec/shell/term_shell/runtime/SemanticRag;
    invoke-virtual { p2 }, Ljava/net/URI;->getRawQuery()Ljava/lang/String;
    move-result-object p3
    if-nez p3, :L3
    goto :L4
  :L3
    new-instance p3, Ljava/lang/StringBuilder;
    invoke-direct { p3 }, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual { p3, v6 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p3
    invoke-virtual { p2 }, Ljava/net/URI;->getRawQuery()Ljava/lang/String;
    move-result-object p2
    invoke-virtual { p3, p2 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p2
    invoke-virtual { p2 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v5
  :L4
    invoke-virtual { p1, v5 }, Lteec/shell/term_shell/runtime/SemanticRag;->events(Ljava/lang/String;)Lorg/json/JSONObject;
    move-result-object p1
    goto/16 :L18
  :L5
  .line 71
    const-string v2, "/control/rag/ingest/config"
    invoke-virtual { v0, v2 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    const-string v3, "/control/rag"
    const-string v7, "POST"
    if-eqz v2, :L6
    invoke-virtual { p1, v1 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-nez v2, :L8
    invoke-virtual { p1, v7 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-nez v2, :L8
  :L6
  .line 72
    const-string v2, "/control/rag/ingest/status"
    invoke-virtual { v0, v2 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-eqz v2, :L7
    invoke-virtual { p1, v1 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-nez v2, :L8
  :L7
  .line 73
    const-string v2, "/control/rag/ingest/jobs"
    invoke-virtual { v0, v2 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-eqz v2, :L11
    invoke-virtual { p1, v1 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-nez v2, :L8
    invoke-virtual { p1, v7 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-eqz v2, :L11
  :L8
  .line 74
    iget-object v1, p0, Lteec/shell/term_shell/runtime/RagPreflight;->rag:Lteec/shell/term_shell/runtime/SemanticRag;
    new-instance v2, Ljava/lang/StringBuilder;
    invoke-direct { v2 }, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual { v3 }, Ljava/lang/String;->length()I
    move-result v3
    invoke-virtual { v0, v3 }, Ljava/lang/String;->substring(I)Ljava/lang/String;
    move-result-object v3
    invoke-virtual { v2, v3 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v2
    invoke-virtual { p2 }, Ljava/net/URI;->getRawQuery()Ljava/lang/String;
    move-result-object v3
    if-nez v3, :L9
    goto :L10
  :L9
    new-instance v3, Ljava/lang/StringBuilder;
    invoke-direct { v3 }, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual { v3, v6 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v3
    invoke-virtual { p2 }, Ljava/net/URI;->getRawQuery()Ljava/lang/String;
    move-result-object p2
    invoke-virtual { v3, p2 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p2
    invoke-virtual { p2 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v5
  :L10
    invoke-virtual { v2, v5 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p2
    invoke-virtual { p2 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object p2
    invoke-virtual { v1, p2, p1, p3 }, Lteec/shell/term_shell/runtime/SemanticRag;->ingest(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Lorg/json/JSONObject;
    move-result-object p1
    goto/16 :L18
  :L11
  .line 76
    const-string v2, "/control/rag/rag/status"
    invoke-virtual { v0, v2 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-eqz v2, :L12
    invoke-virtual { p1, v1 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :L13
  :L12
  .line 77
    invoke-virtual { p1, v7 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :L16
    const-string v1, "/control/rag/rag/search"
    invoke-virtual { v0, v1 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :L13
    const-string v1, "/control/rag/rag/route"
    invoke-virtual { v0, v1 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :L13
    const-string v1, "/control/rag/rag/route-and-retrieve"
    invoke-virtual { v0, v1 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :L13
    const-string v1, "/control/rag/rag/get"
    invoke-virtual { v0, v1 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :L16
  :L13
  .line 78
    iget-object v1, p0, Lteec/shell/term_shell/runtime/RagPreflight;->rag:Lteec/shell/term_shell/runtime/SemanticRag;
    new-instance v2, Ljava/lang/StringBuilder;
    invoke-direct { v2 }, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual { v3 }, Ljava/lang/String;->length()I
    move-result v3
    invoke-virtual { v0, v3 }, Ljava/lang/String;->substring(I)Ljava/lang/String;
    move-result-object v3
    invoke-virtual { v2, v3 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v2
    invoke-virtual { p2 }, Ljava/net/URI;->getRawQuery()Ljava/lang/String;
    move-result-object v3
    if-nez v3, :L14
    goto :L15
  :L14
    new-instance v3, Ljava/lang/StringBuilder;
    invoke-direct { v3 }, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual { v3, v6 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v3
    invoke-virtual { p2 }, Ljava/net/URI;->getRawQuery()Ljava/lang/String;
    move-result-object p2
    invoke-virtual { v3, p2 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p2
    invoke-virtual { p2 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v5
  :L15
    invoke-virtual { v2, v5 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p2
    invoke-virtual { p2 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object p2
    invoke-virtual { v1, p2, p1, p3 }, Lteec/shell/term_shell/runtime/SemanticRag;->query(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Lorg/json/JSONObject;
    move-result-object p1
    goto :L18
  :L16
  .line 80
    invoke-virtual { p1, v7 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p1
    if-eqz p1, :L21
    const-string p1, "/control/rag/selftest"
    invoke-virtual { v0, p1 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p1
    if-nez p1, :L17
    const-string p1, "/control/rag/models/[^/]+/run"
    invoke-virtual { v0, p1 }, Ljava/lang/String;->matches(Ljava/lang/String;)Z
    move-result p1
    if-eqz p1, :L21
  :L17
    iget-object p1, p0, Lteec/shell/term_shell/runtime/RagPreflight;->rag:Lteec/shell/term_shell/runtime/SemanticRag;
    invoke-virtual { v3 }, Ljava/lang/String;->length()I
    move-result p2
    invoke-virtual { v0, p2 }, Ljava/lang/String;->substring(I)Ljava/lang/String;
    move-result-object p2
    invoke-virtual { p1, p2, p3 }, Lteec/shell/term_shell/runtime/SemanticRag;->run(Ljava/lang/String;Ljava/lang/String;)Lorg/json/JSONObject;
    move-result-object p1
  :L18
  .line 82
    invoke-virtual { v0, v4 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p2
    if-eqz p2, :L19
    iget-object p2, p0, Lteec/shell/term_shell/runtime/RagPreflight;->context:Landroid/content/Context;
    invoke-static { p2 }, Lteec/shell/term_shell/runtime/RagPreflight;->isEnabled(Landroid/content/Context;)Z
    move-result p2
    invoke-static { p2, p1 }, Lteec/shell/term_shell/runtime/RagPreflight;->evaluate(ZLorg/json/JSONObject;)Lteec/shell/term_shell/runtime/TerminalServer$Admission;
    move-result-object p2
    goto :L20
  :L19
    invoke-virtual { p0 }, Lteec/shell/term_shell/runtime/RagPreflight;->check()Lteec/shell/term_shell/runtime/TerminalServer$Admission;
    move-result-object p2
  :L20
  .line 83
    new-instance p3, Lorg/json/JSONObject;
    invoke-virtual { p2 }, Lteec/shell/term_shell/runtime/TerminalServer$Admission;->json()Ljava/lang/String;
    move-result-object p2
    invoke-direct { p3, p2 }, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V
    const-string p2, "preflight"
    invoke-virtual { p1, p2, p3 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
  .line 84
    invoke-virtual { p1 }, Lorg/json/JSONObject;->toString()Ljava/lang/String;
    move-result-object p1
    return-object p1
  :L21
  .line 81
    new-instance p1, Ljava/io/IOException;
    const-string p2, "Onbekende RAG-opdracht"
    invoke-direct { p1, p2 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p1
.end method

.method public verify()Lteec/shell/term_shell/runtime/TerminalServer$Admission;
  .registers 5
  .line 52
    iget-object v0, p0, Lteec/shell/term_shell/runtime/RagPreflight;->context:Landroid/content/Context;
    invoke-static { v0 }, Lteec/shell/term_shell/runtime/RagPreflight;->isEnabled(Landroid/content/Context;)Z
    move-result v0
    const/4 v1, 1
    if-nez v0, :L0
    new-instance v0, Lteec/shell/term_shell/runtime/TerminalServer$Admission;
    const/4 v2, 0
    const-string v3, "owner_debug_bypass"
    invoke-direct { v0, v2, v1, v3 }, Lteec/shell/term_shell/runtime/TerminalServer$Admission;-><init>(ZZLjava/lang/String;)V
    return-object v0
  :L0
  .line 53
    iget-object v0, p0, Lteec/shell/term_shell/runtime/RagPreflight;->rag:Lteec/shell/term_shell/runtime/SemanticRag;
    invoke-virtual { v0 }, Lteec/shell/term_shell/runtime/SemanticRag;->refreshStatus()Lorg/json/JSONObject;
    move-result-object v0
    invoke-static { v1, v0 }, Lteec/shell/term_shell/runtime/RagPreflight;->evaluate(ZLorg/json/JSONObject;)Lteec/shell/term_shell/runtime/TerminalServer$Admission;
    move-result-object v0
    return-object v0
.end method
