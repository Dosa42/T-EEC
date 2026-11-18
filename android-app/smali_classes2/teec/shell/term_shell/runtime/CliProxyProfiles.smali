.class public final Lteec/shell/term_shell/runtime/CliProxyProfiles;
.super Ljava/lang/Object;
.source "CliProxyProfiles.java"

.field private final static ROUTE:Ljava/lang/String; = "/control/cliproxy/profiles"

.field private final file:Ljava/io/File;

.method public constructor <init>(Ljava/io/File;)V
  .registers 2
  .line 23
    invoke-direct { p0 }, Ljava/lang/Object;-><init>()V
  .line 24
    iput-object p1, p0, Lteec/shell/term_shell/runtime/CliProxyProfiles;->file:Ljava/io/File;
  .line 25
    return-void
.end method

.method private static key(Lorg/json/JSONObject;)Ljava/lang/String;
  .registers 2
  .line 112
    const-string v0, "api_key"
    invoke-virtual { p0, v0 }, Lorg/json/JSONObject;->opt(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object p0
  .line 113
    instance-of v0, p0, Ljava/lang/String;
    if-eqz v0, :L0
    check-cast p0, Ljava/lang/String;
    goto :L1
  :L0
    const-string p0, ""
  :L1
    return-object p0
.end method

.method private read()Lorg/json/JSONObject;
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/io/IOException;,
      Lorg/json/JSONException;
    }
  .end annotation
  .catch Ljava/io/IOException; { :L0 .. :L1 } :L32
  .catchall { :L1 .. :L2 } :L26
  .catchall { :L3 .. :L6 } :L20
  .catchall { :L6 .. :L7 } :L26
  .catch Ljava/io/IOException; { :L7 .. :L8 } :L32
  .catch Ljava/nio/charset/CharacterCodingException; { :L9 .. :L10 } :L19
  .catchall { :L21 .. :L22 } :L23
  .catchall { :L24 .. :L26 } :L26
  .catchall { :L27 .. :L28 } :L29
  .catch Ljava/io/IOException; { :L30 .. :L32 } :L32
  .registers 8
  .line 66
    iget-object v0, p0, Lteec/shell/term_shell/runtime/CliProxyProfiles;->file:Ljava/io/File;
    invoke-virtual { v0 }, Ljava/io/File;->exists()Z
    move-result v0
    if-nez v0, :L0
    const/4 v0, 0
    return-object v0
  :L0
  .line 68
    new-instance v0, Ljava/io/FileInputStream;
    iget-object v1, p0, Lteec/shell/term_shell/runtime/CliProxyProfiles;->file:Ljava/io/File;
    invoke-direct { v0, v1 }, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V
  :L1
    new-instance v1, Ljava/io/ByteArrayOutputStream;
    invoke-direct { v1 }, Ljava/io/ByteArrayOutputStream;-><init>()V
  :L2
  .line 69
    const/16 v2, 8192
  :L3
    new-array v2, v2, [B
  :L4
  .line 71
    invoke-virtual { v0, v2 }, Ljava/io/FileInputStream;->read([B)I
    move-result v3
    const/4 v4, -1
    const/4 v5, 0
    if-eq v3, v4, :L5
    invoke-virtual { v1, v2, v5, v3 }, Ljava/io/ByteArrayOutputStream;->write([BII)V
    goto :L4
  :L5
  .line 72
    invoke-virtual { v1 }, Ljava/io/ByteArrayOutputStream;->toByteArray()[B
    move-result-object v2
  :L6
  .line 73
    invoke-virtual { v1 }, Ljava/io/ByteArrayOutputStream;->close()V
  :L7
    invoke-virtual { v0 }, Ljava/io/FileInputStream;->close()V
  :L8
  .line 75
    nop
  :L9
  .line 78
    sget-object v0, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;
    invoke-virtual { v0 }, Ljava/nio/charset/Charset;->newDecoder()Ljava/nio/charset/CharsetDecoder;
    move-result-object v0
    sget-object v1, Ljava/nio/charset/CodingErrorAction;->REPORT:Ljava/nio/charset/CodingErrorAction;
    invoke-virtual { v0, v1 }, Ljava/nio/charset/CharsetDecoder;->onMalformedInput(Ljava/nio/charset/CodingErrorAction;)Ljava/nio/charset/CharsetDecoder;
    move-result-object v0
    sget-object v1, Ljava/nio/charset/CodingErrorAction;->REPORT:Ljava/nio/charset/CodingErrorAction;
    invoke-virtual { v0, v1 }, Ljava/nio/charset/CharsetDecoder;->onUnmappableCharacter(Ljava/nio/charset/CodingErrorAction;)Ljava/nio/charset/CharsetDecoder;
    move-result-object v0
  .line 79
    invoke-static { v2 }, Ljava/nio/ByteBuffer;->wrap([B)Ljava/nio/ByteBuffer;
    move-result-object v1
    invoke-virtual { v0, v1 }, Ljava/nio/charset/CharsetDecoder;->decode(Ljava/nio/ByteBuffer;)Ljava/nio/CharBuffer;
    move-result-object v0
    invoke-virtual { v0 }, Ljava/nio/CharBuffer;->toString()Ljava/lang/String;
    move-result-object v0
  :L10
  .line 82
    nop
  .line 83
    new-instance v1, Lorg/json/JSONTokener;
    invoke-direct { v1, v0 }, Lorg/json/JSONTokener;-><init>(Ljava/lang/String;)V
  .line 84
    invoke-virtual { v1 }, Lorg/json/JSONTokener;->nextValue()Ljava/lang/Object;
    move-result-object v0
  .line 85
    instance-of v2, v0, Lorg/json/JSONObject;
    if-eqz v2, :L18
    invoke-virtual { v1 }, Lorg/json/JSONTokener;->nextClean()C
    move-result v1
    if-nez v1, :L18
  .line 86
    check-cast v0, Lorg/json/JSONObject;
  .line 87
    const-string v1, "base_url"
    invoke-static { v0, v1 }, Lteec/shell/term_shell/runtime/CliProxyProfiles;->requiredString(Lorg/json/JSONObject;Ljava/lang/String;)Ljava/lang/String;
  .line 88
    const-string v1, "upstream_provider"
    invoke-static { v0, v1 }, Lteec/shell/term_shell/runtime/CliProxyProfiles;->requiredString(Lorg/json/JSONObject;Ljava/lang/String;)Ljava/lang/String;
  .line 89
    const-string v1, "profiles"
    invoke-virtual { v0, v1 }, Lorg/json/JSONObject;->opt(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v2
    instance-of v2, v2, Lorg/json/JSONArray;
    if-eqz v2, :L17
  .line 90
    invoke-virtual { v0, v1 }, Lorg/json/JSONObject;->getJSONArray(Ljava/lang/String;)Lorg/json/JSONArray;
    move-result-object v1
  .line 91
    new-instance v2, Ljava/util/HashSet;
    invoke-direct { v2 }, Ljava/util/HashSet;-><init>()V
  .line 92
    nop
  :L11
    invoke-virtual { v1 }, Lorg/json/JSONArray;->length()I
    move-result v3
    if-ge v5, v3, :L16
  .line 93
    invoke-virtual { v1, v5 }, Lorg/json/JSONArray;->opt(I)Ljava/lang/Object;
    move-result-object v3
    instance-of v3, v3, Lorg/json/JSONObject;
    if-eqz v3, :L15
  .line 94
    invoke-virtual { v1, v5 }, Lorg/json/JSONArray;->getJSONObject(I)Lorg/json/JSONObject;
    move-result-object v3
  .line 95
    const-string v4, "name"
    invoke-static { v3, v4 }, Lteec/shell/term_shell/runtime/CliProxyProfiles;->requiredString(Lorg/json/JSONObject;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v4
  .line 96
    const-string v6, "endpoint"
    invoke-static { v3, v6 }, Lteec/shell/term_shell/runtime/CliProxyProfiles;->requiredString(Lorg/json/JSONObject;Ljava/lang/String;)Ljava/lang/String;
  .line 97
    const-string v6, "header"
    invoke-static { v3, v6 }, Lteec/shell/term_shell/runtime/CliProxyProfiles;->requiredString(Lorg/json/JSONObject;Ljava/lang/String;)Ljava/lang/String;
  .line 98
    invoke-virtual { v4 }, Ljava/lang/String;->isEmpty()Z
    move-result v6
    if-nez v6, :L14
    invoke-interface { v2, v4 }, Ljava/util/Set;->add(Ljava/lang/Object;)Z
    move-result v4
    if-eqz v4, :L14
  .line 99
    const-string v4, "api_key"
    invoke-virtual { v3, v4 }, Lorg/json/JSONObject;->opt(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v3
  .line 100
    if-eqz v3, :L13
    sget-object v4, Lorg/json/JSONObject;->NULL:Ljava/lang/Object;
    if-eq v3, v4, :L13
    instance-of v3, v3, Ljava/lang/String;
    if-eqz v3, :L12
    goto :L13
  :L12
    new-instance v0, Ljava/io/IOException;
    const-string v1, "CLIProxy-profielbestand bevat een ongeldige API-sleutel"
    invoke-direct { v0, v1 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw v0
  :L13
  .line 92
    add-int/lit8 v5, v5, 1
    goto :L11
  :L14
  .line 98
    new-instance v0, Ljava/io/IOException;
    const-string v1, "CLIProxy-profielnamen moeten ingevuld en uniek zijn"
    invoke-direct { v0, v1 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw v0
  :L15
  .line 93
    new-instance v0, Ljava/io/IOException;
    const-string v1, "CLIProxy-profielbestand bevat een ongeldig profiel"
    invoke-direct { v0, v1 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw v0
  :L16
  .line 102
    return-object v0
  :L17
  .line 89
    new-instance v0, Ljava/io/IOException;
    const-string v1, "CLIProxy-profielbestand mist een geldige profielenlijst"
    invoke-direct { v0, v1 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw v0
  :L18
  .line 85
    new-instance v0, Ljava/io/IOException;
    const-string v1, "CLIProxy-profielbestand bevat ongeldige JSON"
    invoke-direct { v0, v1 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw v0
  :L19
  .line 80
    move-exception v0
  .line 81
    new-instance v0, Ljava/io/IOException;
    const-string v1, "CLIProxy-profielbestand bevat ongeldige UTF-8"
    invoke-direct { v0, v1 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw v0
  :L20
  .line 68
    move-exception v2
  :L21
    invoke-virtual { v1 }, Ljava/io/ByteArrayOutputStream;->close()V
  :L22
    goto :L25
  :L23
    move-exception v1
  :L24
    invoke-virtual { v2, v1 }, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V
  :L25
    throw v2
  :L26
    move-exception v1
  :L27
    invoke-virtual { v0 }, Ljava/io/FileInputStream;->close()V
  :L28
    goto :L31
  :L29
    move-exception v0
  :L30
    invoke-virtual { v1, v0 }, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V
  :L31
    throw v1
  :L32
  .line 73
    move-exception v0
  .line 74
    new-instance v0, Ljava/io/IOException;
    const-string v1, "CLIProxy-profielbestand kon niet worden gelezen"
    invoke-direct { v0, v1 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw v0
.end method

.method private static requiredString(Lorg/json/JSONObject;Ljava/lang/String;)Ljava/lang/String;
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/io/IOException;
    }
  .end annotation
  .registers 2
  .line 106
    invoke-virtual { p0, p1 }, Lorg/json/JSONObject;->opt(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object p0
  .line 107
    instance-of p1, p0, Ljava/lang/String;
    if-eqz p1, :L0
  .line 108
    check-cast p0, Ljava/lang/String;
    return-object p0
  :L0
  .line 107
    new-instance p0, Ljava/io/IOException;
    const-string p1, "CLIProxy-profielbestand bevat een ongeldig tekstveld"
    invoke-direct { p0, p1 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p0
.end method

.method public request(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/io/IOException;
    }
  .end annotation
  .catch Ljava/lang/IllegalArgumentException; { :L0 .. :L1 } :L20
  .catch Lorg/json/JSONException; { :L2 .. :L3 } :L18
  .catch Lorg/json/JSONException; { :L4 .. :L18 } :L18
  .registers 13
  .line 29
    const-string p3, "header"
    const-string v0, "endpoint"
    const-string v1, "upstream_provider"
    const-string v2, "base_url"
  :L0
    invoke-static { p2 }, Ljava/net/URI;->create(Ljava/lang/String;)Ljava/net/URI;
    move-result-object p2
    invoke-virtual { p2 }, Ljava/net/URI;->getPath()Ljava/lang/String;
    move-result-object p2
  :L1
  .line 30
    nop
  .line 31
    const-string v3, "GET"
    invoke-virtual { v3, p1 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p1
    if-eqz p1, :L19
    if-eqz p2, :L19
    const-string p1, "/control/cliproxy/profiles"
    invoke-virtual { p2, p1 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-nez v3, :L2
    const-string v3, "/control/cliproxy/profiles/"
    invoke-virtual { p2, v3 }, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v3
    if-eqz v3, :L19
  :L2
  .line 35
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/CliProxyProfiles;->read()Lorg/json/JSONObject;
    move-result-object v3
  .line 36
    invoke-virtual { p2, p1 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v4
  :L3
    const-string v5, "name"
    const/4 v6, 0
    const-string v7, "profiles"
    const/4 v8, 1
    if-eqz v4, :L12
  :L4
  .line 37
    new-instance p1, Lorg/json/JSONObject;
    invoke-direct { p1 }, Lorg/json/JSONObject;-><init>()V
    const-string p2, "configured"
    if-eqz v3, :L5
    move v4, v8
    goto :L6
  :L5
    move v4, v6
  :L6
    invoke-virtual { p1, p2, v4 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Z)Lorg/json/JSONObject;
    move-result-object p1
    new-instance p2, Lorg/json/JSONArray;
    invoke-direct { p2 }, Lorg/json/JSONArray;-><init>()V
    invoke-virtual { p1, v7, p2 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object p1
  .line 38
    if-nez v3, :L7
    invoke-virtual { p1 }, Lorg/json/JSONObject;->toString()Ljava/lang/String;
    move-result-object p1
    return-object p1
  :L7
  .line 39
    invoke-virtual { v3, v2 }, Lorg/json/JSONObject;->getString(Ljava/lang/String;)Ljava/lang/String;
    move-result-object p2
    invoke-virtual { p1, v2, p2 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object p2
    invoke-virtual { v3, v1 }, Lorg/json/JSONObject;->getString(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2
    invoke-virtual { p2, v1, v2 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
  .line 40
    invoke-virtual { v3, v7 }, Lorg/json/JSONObject;->getJSONArray(Ljava/lang/String;)Lorg/json/JSONArray;
    move-result-object p2
  .line 41
    invoke-virtual { p1, v7 }, Lorg/json/JSONObject;->getJSONArray(Ljava/lang/String;)Lorg/json/JSONArray;
    move-result-object v1
  .line 42
    move v2, v6
  :L8
    invoke-virtual { p2 }, Lorg/json/JSONArray;->length()I
    move-result v3
    if-ge v2, v3, :L11
  .line 43
    invoke-virtual { p2, v2 }, Lorg/json/JSONArray;->getJSONObject(I)Lorg/json/JSONObject;
    move-result-object v3
  .line 44
    new-instance v4, Lorg/json/JSONObject;
    invoke-direct { v4 }, Lorg/json/JSONObject;-><init>()V
    invoke-virtual { v3, v5 }, Lorg/json/JSONObject;->getString(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v7
    invoke-virtual { v4, v5, v7 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v4
    invoke-virtual { v3, v0 }, Lorg/json/JSONObject;->getString(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v7
    invoke-virtual { v4, v0, v7 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v4
  .line 45
    invoke-virtual { v3, p3 }, Lorg/json/JSONObject;->getString(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v7
    invoke-virtual { v4, p3, v7 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v4
    const-string v7, "has_key"
    invoke-static { v3 }, Lteec/shell/term_shell/runtime/CliProxyProfiles;->key(Lorg/json/JSONObject;)Ljava/lang/String;
    move-result-object v3
    invoke-virtual { v3 }, Ljava/lang/String;->isEmpty()Z
    move-result v3
    if-nez v3, :L9
    move v3, v8
    goto :L10
  :L9
    move v3, v6
  :L10
    invoke-virtual { v4, v7, v3 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Z)Lorg/json/JSONObject;
    move-result-object v3
  .line 44
    invoke-virtual { v1, v3 }, Lorg/json/JSONArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;
  .line 42
    add-int/lit8 v2, v2, 1
    goto :L8
  :L11
  .line 47
    invoke-virtual { p1 }, Lorg/json/JSONObject;->toString()Ljava/lang/String;
    move-result-object p1
    return-object p1
  :L12
  .line 49
    if-eqz v3, :L17
  .line 50
    invoke-virtual { p1 }, Ljava/lang/String;->length()I
    move-result p1
    add-int/2addr p1, v8
    invoke-virtual { p2, p1 }, Ljava/lang/String;->substring(I)Ljava/lang/String;
    move-result-object p1
  .line 51
    invoke-virtual { v3, v7 }, Lorg/json/JSONObject;->getJSONArray(Ljava/lang/String;)Lorg/json/JSONArray;
    move-result-object p2
  .line 52
    nop
  :L13
    invoke-virtual { p2 }, Lorg/json/JSONArray;->length()I
    move-result p3
    if-ge v6, p3, :L16
  .line 53
    invoke-virtual { p2, v6 }, Lorg/json/JSONArray;->getJSONObject(I)Lorg/json/JSONObject;
    move-result-object p3
  .line 54
    invoke-virtual { p3, v5 }, Lorg/json/JSONObject;->getString(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    invoke-virtual { p1, v0 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-nez v0, :L14
  .line 52
    add-int/lit8 v6, v6, 1
    goto :L13
  :L14
  .line 55
    invoke-static { p3 }, Lteec/shell/term_shell/runtime/CliProxyProfiles;->key(Lorg/json/JSONObject;)Ljava/lang/String;
    move-result-object p2
  .line 56
    invoke-virtual { p2 }, Ljava/lang/String;->isEmpty()Z
    move-result p3
    if-nez p3, :L15
  .line 57
    new-instance p3, Lorg/json/JSONObject;
    invoke-direct { p3 }, Lorg/json/JSONObject;-><init>()V
    invoke-virtual { p3, v5, p1 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object p1
    const-string p3, "api_key"
    invoke-virtual { p1, p3, p2 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object p1
    invoke-virtual { p1 }, Lorg/json/JSONObject;->toString()Ljava/lang/String;
    move-result-object p1
    return-object p1
  :L15
  .line 56
    new-instance p1, Ljava/io/IOException;
    const-string p2, "Dit CLIProxy-profiel heeft geen API-sleutel"
    invoke-direct { p1, p2 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p1
  :L16
  .line 59
    new-instance p1, Ljava/io/IOException;
    const-string p2, "CLIProxy-profiel niet gevonden"
    invoke-direct { p1, p2 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p1
  :L17
  .line 49
    new-instance p1, Ljava/io/IOException;
    const-string p2, "CLIProxy-profielen zijn nog niet ingesteld"
    invoke-direct { p1, p2 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p1
  :L18
  .line 60
    move-exception p1
  .line 61
    new-instance p1, Ljava/io/IOException;
    const-string p2, "CLIProxy-profielbestand heeft een ongeldige structuur"
    invoke-direct { p1, p2 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p1
  :L19
  .line 32
    new-instance p1, Ljava/io/IOException;
    const-string p2, "Onbekende CLIProxy-profielopdracht"
    invoke-direct { p1, p2 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p1
  :L20
  .line 30
    move-exception p1
    new-instance p1, Ljava/io/IOException;
    const-string p2, "Ongeldige CLIProxy-profielroute"
    invoke-direct { p1, p2 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p1
.end method
