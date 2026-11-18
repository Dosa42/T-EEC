.class public final Lteec/shell/term_shell/runtime/McpEndpoint;
.super Ljava/lang/Object;
.source "McpEndpoint.java"

.annotation system Ldalvik/annotation/MemberClasses;
  value = {
    Lteec/shell/term_shell/runtime/McpEndpoint$Reply;,
    Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;,
    Lteec/shell/term_shell/runtime/McpEndpoint$ProtocolFailure;
  }
.end annotation

.field private final static LATEST:Ljava/lang/String; = "2025-11-25"

.field private final static VERSIONS:Ljava/util/List;
  .annotation system Ldalvik/annotation/Signature;
    value = {
      "Ljava/util/List<",
      "Ljava/lang/String;",
      ">;"
    }
  .end annotation
.end field

.field private final control:Lteec/shell/term_shell/runtime/TerminalServer$Control;

.method static constructor <clinit>()V
  .registers 2
  .line 19
    const-string v0, "2025-11-25"
    const-string v1, "2025-06-18"
    filled-new-array { v0, v1 }, [Ljava/lang/String;
    move-result-object v0
    invoke-static { v0 }, Ljava/util/Arrays;->asList([Ljava/lang/Object;)Ljava/util/List;
    move-result-object v0
    sput-object v0, Lteec/shell/term_shell/runtime/McpEndpoint;->VERSIONS:Ljava/util/List;
    return-void
.end method

.method public constructor <init>(Lteec/shell/term_shell/runtime/TerminalServer$Control;)V
  .registers 2
  .line 38
    invoke-direct { p0 }, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lteec/shell/term_shell/runtime/McpEndpoint;->control:Lteec/shell/term_shell/runtime/TerminalServer$Control;
    return-void
.end method

.method private static acceptsJson(Ljava/lang/String;)Z
  .registers 10
  .line 183
    const-string v0, ","
    invoke-virtual { p0, v0 }, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;
    move-result-object p0
    array-length v0, p0
    const/4 v1, 0
    move v2, v1
  :L0
    if-ge v2, v0, :L5
    aget-object v3, p0, v2
  .line 184
    invoke-virtual { v3 }, Ljava/lang/String;->trim()Ljava/lang/String;
    move-result-object v3
    const-string v4, ";"
    invoke-virtual { v3, v4 }, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;
    move-result-object v3
  .line 185
    aget-object v4, v3, v1
    invoke-virtual { v4 }, Ljava/lang/String;->trim()Ljava/lang/String;
    move-result-object v4
    const-string v5, "application/json"
    invoke-virtual { v4, v5 }, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z
    move-result v4
    if-eqz v4, :L4
  .line 186
    nop
  .line 187
    const/4 v4, 1
    move v5, v4
    move v6, v5
  :L1
    array-length v7, v3
    if-ge v5, v7, :L3
    aget-object v7, v3, v5
    invoke-virtual { v7 }, Ljava/lang/String;->trim()Ljava/lang/String;
    move-result-object v7
    const-string v8, "(?i)q\\s*=\\s*0(?:\\.0*)?"
    invoke-virtual { v7, v8 }, Ljava/lang/String;->matches(Ljava/lang/String;)Z
    move-result v7
    if-eqz v7, :L2
    move v6, v1
  :L2
    add-int/lit8 v5, v5, 1
    goto :L1
  :L3
  .line 188
    if-eqz v6, :L4
    return v4
  :L4
  .line 183
    add-int/lit8 v2, v2, 1
    goto :L0
  :L5
  .line 191
    return v1
.end method

.method public static badTransport(Ljava/lang/String;)Lteec/shell/term_shell/runtime/McpEndpoint$Reply;
  .registers 5
  .line 194
    sget-object v0, Lorg/json/JSONObject;->NULL:Ljava/lang/Object;
    const/16 v1, -32600
    const-string v2, ""
    const/16 v3, 400
    invoke-static { v3, v0, v1, p0, v2 }, Lteec/shell/term_shell/runtime/McpEndpoint;->error(ILjava/lang/Object;ILjava/lang/String;Ljava/lang/String;)Lteec/shell/term_shell/runtime/McpEndpoint$Reply;
    move-result-object p0
    return-object p0
.end method

.method private call(Lorg/json/JSONObject;)Lorg/json/JSONObject;
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/lang/Exception;
    }
  .end annotation
  .catch Ljava/lang/Exception; { :L1 .. :L3 } :L15
  .catch Ljava/lang/Exception; { :L4 .. :L15 } :L15
  .registers 12
  .line 100
    const-string v0, "cwd"
    const-string v1, "source"
    const-string v2, "argv"
    const-string v3, "name"
    invoke-static { p1, v3 }, Lteec/shell/term_shell/runtime/McpEndpoint;->string(Lorg/json/JSONObject;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v3
  .line 101
    const-string v4, "engine_status"
    const-string v5, "engine_submit"
    const-string v6, "engine_order"
    filled-new-array { v4, v5, v6 }, [Ljava/lang/String;
    move-result-object v5
    invoke-static { v5 }, Ljava/util/Arrays;->asList([Ljava/lang/Object;)Ljava/util/List;
    move-result-object v5
    invoke-interface { v5, v3 }, Ljava/util/List;->contains(Ljava/lang/Object;)Z
    move-result v5
    const/16 v7, -32602
    if-eqz v5, :L18
  .line 102
    const-string v5, "arguments"
    invoke-virtual { p1, v5 }, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z
    move-result v8
    if-eqz v8, :L0
    invoke-static { p1, v5 }, Lteec/shell/term_shell/runtime/McpEndpoint;->object(Lorg/json/JSONObject;Ljava/lang/String;)Lorg/json/JSONObject;
    move-result-object p1
    goto :L1
  :L0
    new-instance p1, Lorg/json/JSONObject;
    invoke-direct { p1 }, Lorg/json/JSONObject;-><init>()V
  :L1
  .line 104
    const-string v5, "GET"
  .line 106
    const-string v8, ""
  .line 107
    invoke-virtual { v3, v4 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v4
    const/4 v9, 0
    if-eqz v4, :L2
  .line 108
    new-array v0, v9, [Ljava/lang/String;
    invoke-static { p1, v0 }, Lteec/shell/term_shell/runtime/McpEndpoint;->keys(Lorg/json/JSONObject;[Ljava/lang/String;)V
  .line 109
    const-string p1, "/control/summary"
    goto/16 :L10
  :L2
  .line 110
    invoke-virtual { v3, v6 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
  :L3
    const-string v4, "id"
    if-eqz v3, :L5
  :L4
  .line 111
    filled-new-array { v4 }, [Ljava/lang/String;
    move-result-object v0
    invoke-static { p1, v0 }, Lteec/shell/term_shell/runtime/McpEndpoint;->keys(Lorg/json/JSONObject;[Ljava/lang/String;)V
  .line 112
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct { v0 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "/control/orders/"
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-static { p1, v4 }, Lteec/shell/term_shell/runtime/McpEndpoint;->string(Lorg/json/JSONObject;Ljava/lang/String;)Ljava/lang/String;
    move-result-object p1
    invoke-virtual { v0, p1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p1
    invoke-virtual { p1 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object p1
    goto/16 :L10
  :L5
  .line 114
    filled-new-array { v4, v1, v0, v2 }, [Ljava/lang/String;
    move-result-object v3
    invoke-static { p1, v3 }, Lteec/shell/term_shell/runtime/McpEndpoint;->keys(Lorg/json/JSONObject;[Ljava/lang/String;)V
  .line 115
    invoke-static { p1, v4 }, Lteec/shell/term_shell/runtime/McpEndpoint;->string(Lorg/json/JSONObject;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v3
  .line 116
    invoke-static { p1, v1 }, Lteec/shell/term_shell/runtime/McpEndpoint;->string(Lorg/json/JSONObject;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
  .line 117
    invoke-static { p1, v0 }, Lteec/shell/term_shell/runtime/McpEndpoint;->string(Lorg/json/JSONObject;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
  .line 118
    const-string v4, "/"
    invoke-virtual { v0, v4 }, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v4
    if-eqz v4, :L14
  .line 119
    invoke-virtual { p1, v2 }, Lorg/json/JSONObject;->opt(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v4
    instance-of v4, v4, Lorg/json/JSONArray;
    if-eqz v4, :L13
  .line 120
    invoke-virtual { p1, v2 }, Lorg/json/JSONObject;->getJSONArray(Ljava/lang/String;)Lorg/json/JSONArray;
    move-result-object p1
  .line 121
    invoke-virtual { p1 }, Lorg/json/JSONArray;->length()I
    move-result v2
    if-eqz v2, :L12
  .line 122
    new-instance v2, Ljava/lang/StringBuilder;
    const-string v4, "id="
    invoke-direct { v2, v4 }, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V
    invoke-static { v3 }, Lteec/shell/term_shell/runtime/McpEndpoint;->encode(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v3
    invoke-virtual { v2, v3 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v2
    const-string v3, "&source="
    invoke-virtual { v2, v3 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v2
    invoke-static { v1 }, Lteec/shell/term_shell/runtime/McpEndpoint;->encode(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    invoke-virtual { v2, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v1
    const-string v2, "&cwd="
    invoke-virtual { v1, v2 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v1
    invoke-static { v0 }, Lteec/shell/term_shell/runtime/McpEndpoint;->encode(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    invoke-virtual { v1, v0 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
  .line 123
    move v1, v9
  :L6
    invoke-virtual { p1 }, Lorg/json/JSONArray;->length()I
    move-result v2
    if-ge v1, v2, :L9
  .line 124
    invoke-virtual { p1, v1 }, Lorg/json/JSONArray;->get(I)Ljava/lang/Object;
    move-result-object v2
    instance-of v2, v2, Ljava/lang/String;
    if-eqz v2, :L8
    if-nez v1, :L7
    invoke-virtual { p1, v1 }, Lorg/json/JSONArray;->getString(I)Ljava/lang/String;
    move-result-object v2
    invoke-virtual { v2 }, Ljava/lang/String;->isEmpty()Z
    move-result v2
    if-nez v2, :L8
  :L7
  .line 125
    const-string v2, "&arg="
    invoke-virtual { v0, v2 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v2
    invoke-virtual { p1, v1 }, Lorg/json/JSONArray;->getString(I)Ljava/lang/String;
    move-result-object v3
    invoke-static { v3 }, Lteec/shell/term_shell/runtime/McpEndpoint;->encode(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v3
    invoke-virtual { v2, v3 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
  .line 123
    add-int/lit8 v1, v1, 1
    goto :L6
  :L8
  .line 124
    new-instance p1, Lteec/shell/term_shell/runtime/McpEndpoint$ProtocolFailure;
    const-string v0, "argv must contain strings and a nonempty executable"
    invoke-direct { p1, v7, v0 }, Lteec/shell/term_shell/runtime/McpEndpoint$ProtocolFailure;-><init>(ILjava/lang/String;)V
    throw p1
  :L9
  .line 127
    const-string v5, "POST"
    const-string p1, "/control/orders"
    invoke-virtual { v0 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v8
  :L10
  .line 129
    iget-object v0, p0, Lteec/shell/term_shell/runtime/McpEndpoint;->control:Lteec/shell/term_shell/runtime/TerminalServer$Control;
    if-eqz v0, :L11
  .line 130
    new-instance v0, Lorg/json/JSONObject;
    iget-object v1, p0, Lteec/shell/term_shell/runtime/McpEndpoint;->control:Lteec/shell/term_shell/runtime/TerminalServer$Control;
    invoke-interface { v1, v5, p1, v8 }, Lteec/shell/term_shell/runtime/TerminalServer$Control;->request(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object p1
    invoke-direct { v0, p1 }, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V
    invoke-static { v0, v9 }, Lteec/shell/term_shell/runtime/McpEndpoint;->toolResult(Lorg/json/JSONObject;Z)Lorg/json/JSONObject;
    move-result-object p1
    return-object p1
  :L11
  .line 129
    new-instance p1, Ljava/lang/IllegalStateException;
    const-string v0, "Machine engine is unavailable"
    invoke-direct { p1, v0 }, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V
    throw p1
  :L12
  .line 121
    new-instance p1, Lteec/shell/term_shell/runtime/McpEndpoint$ProtocolFailure;
    const-string v0, "argv must not be empty"
    invoke-direct { p1, v7, v0 }, Lteec/shell/term_shell/runtime/McpEndpoint$ProtocolFailure;-><init>(ILjava/lang/String;)V
    throw p1
  :L13
  .line 119
    new-instance p1, Lteec/shell/term_shell/runtime/McpEndpoint$ProtocolFailure;
    const-string v0, "argv must be an array of strings"
    invoke-direct { p1, v7, v0 }, Lteec/shell/term_shell/runtime/McpEndpoint$ProtocolFailure;-><init>(ILjava/lang/String;)V
    throw p1
  :L14
  .line 118
    new-instance p1, Lteec/shell/term_shell/runtime/McpEndpoint$ProtocolFailure;
    const-string v0, "cwd must be absolute"
    invoke-direct { p1, v7, v0 }, Lteec/shell/term_shell/runtime/McpEndpoint$ProtocolFailure;-><init>(ILjava/lang/String;)V
    throw p1
  :L15
  .line 131
    move-exception p1
  .line 132
    new-instance v0, Lorg/json/JSONObject;
    invoke-direct { v0 }, Lorg/json/JSONObject;-><init>()V
    invoke-virtual { p1 }, Ljava/lang/Exception;->getMessage()Ljava/lang/String;
    move-result-object v1
    if-nez v1, :L16
    invoke-virtual { p1 }, Ljava/lang/Exception;->toString()Ljava/lang/String;
    move-result-object p1
    goto :L17
  :L16
    invoke-virtual { p1 }, Ljava/lang/Exception;->getMessage()Ljava/lang/String;
    move-result-object p1
  :L17
    const-string v1, "error"
    invoke-virtual { v0, v1, p1 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object p1
    const/4 v0, 1
    invoke-static { p1, v0 }, Lteec/shell/term_shell/runtime/McpEndpoint;->toolResult(Lorg/json/JSONObject;Z)Lorg/json/JSONObject;
    move-result-object p1
    return-object p1
  :L18
  .line 101
    new-instance p1, Lteec/shell/term_shell/runtime/McpEndpoint$ProtocolFailure;
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct { v0 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "Unknown tool: "
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual { v0, v3 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual { v0 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-direct { p1, v7, v0 }, Lteec/shell/term_shell/runtime/McpEndpoint$ProtocolFailure;-><init>(ILjava/lang/String;)V
    throw p1
.end method

.method private static encode(Ljava/lang/String;)Ljava/lang/String;
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/io/UnsupportedEncodingException;
    }
  .end annotation
  .registers 2
  .line 180
    const-string v0, "UTF-8"
    invoke-static { p0, v0 }, Ljava/net/URLEncoder;->encode(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object p0
    return-object p0
.end method

.method private static error(ILjava/lang/Object;ILjava/lang/String;Ljava/lang/String;)Lteec/shell/term_shell/runtime/McpEndpoint$Reply;
  .catch Lorg/json/JSONException; { :L0 .. :L3 } :L4
  .registers 9
  :L0
  .line 198
    new-instance v0, Lorg/json/JSONObject;
    invoke-direct { v0 }, Lorg/json/JSONObject;-><init>()V
    const-string v1, "jsonrpc"
    const-string v2, "2.0"
    invoke-virtual { v0, v1, v2 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v0
    const-string v1, "error"
    new-instance v2, Lorg/json/JSONObject;
    invoke-direct { v2 }, Lorg/json/JSONObject;-><init>()V
    const-string v3, "code"
  .line 199
    invoke-virtual { v2, v3, p2 }, Lorg/json/JSONObject;->put(Ljava/lang/String;I)Lorg/json/JSONObject;
    move-result-object p2
    const-string v2, "message"
    if-nez p3, :L1
    const-string p3, "Invalid request"
  :L1
    invoke-virtual { p2, v2, p3 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object p2
    invoke-virtual { v0, v1, p2 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object p2
  .line 200
    if-eqz p1, :L2
    sget-object p3, Lorg/json/JSONObject;->NULL:Ljava/lang/Object;
    if-eq p1, p3, :L2
    const-string p3, "id"
    invoke-virtual { p2, p3, p1 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
  :L2
  .line 201
    new-instance p1, Lteec/shell/term_shell/runtime/McpEndpoint$Reply;
    invoke-virtual { p2 }, Lorg/json/JSONObject;->toString()Ljava/lang/String;
    move-result-object p2
    invoke-direct { p1, p0, p2, p4 }, Lteec/shell/term_shell/runtime/McpEndpoint$Reply;-><init>(ILjava/lang/String;Ljava/lang/String;)V
  :L3
    return-object p1
  :L4
  .line 202
    move-exception p0
    new-instance p1, Ljava/lang/IllegalStateException;
    invoke-direct { p1, p0 }, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/Throwable;)V
    throw p1
.end method

.method private static varargs keys(Lorg/json/JSONObject;[Ljava/lang/String;)V
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Lteec/shell/term_shell/runtime/McpEndpoint$ProtocolFailure;
    }
  .end annotation
  .registers 4
  .line 161
    invoke-virtual { p0 }, Lorg/json/JSONObject;->keys()Ljava/util/Iterator;
    move-result-object p0
  :L0
  .line 162
    invoke-interface { p0 }, Ljava/util/Iterator;->hasNext()Z
    move-result v0
    if-eqz v0, :L2
  .line 163
    invoke-interface { p0 }, Ljava/util/Iterator;->next()Ljava/lang/Object;
    move-result-object v0
    check-cast v0, Ljava/lang/String;
  .line 164
    invoke-static { p1 }, Ljava/util/Arrays;->asList([Ljava/lang/Object;)Ljava/util/List;
    move-result-object v1
    invoke-interface { v1, v0 }, Ljava/util/List;->contains(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :L1
  .line 165
    goto :L0
  :L1
  .line 164
    new-instance p0, Lteec/shell/term_shell/runtime/McpEndpoint$ProtocolFailure;
    new-instance p1, Ljava/lang/StringBuilder;
    invoke-direct { p1 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "Unexpected argument: "
    invoke-virtual { p1, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p1
    invoke-virtual { p1, v0 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p1
    invoke-virtual { p1 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object p1
    const/16 v0, -32602
    invoke-direct { p0, v0, p1 }, Lteec/shell/term_shell/runtime/McpEndpoint$ProtocolFailure;-><init>(ILjava/lang/String;)V
    throw p0
  :L2
  .line 166
    return-void
.end method

.method private static object(Lorg/json/JSONObject;Ljava/lang/String;)Lorg/json/JSONObject;
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Lteec/shell/term_shell/runtime/McpEndpoint$ProtocolFailure;
    }
  .end annotation
  .registers 3
  .line 169
    invoke-virtual { p0, p1 }, Lorg/json/JSONObject;->opt(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object p0
  .line 170
    instance-of v0, p0, Lorg/json/JSONObject;
    if-eqz v0, :L0
  .line 171
    check-cast p0, Lorg/json/JSONObject;
    return-object p0
  :L0
  .line 170
    new-instance p0, Lteec/shell/term_shell/runtime/McpEndpoint$ProtocolFailure;
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct { v0 }, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual { v0, p1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p1
    const-string v0, " must be an object"
    invoke-virtual { p1, v0 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p1
    invoke-virtual { p1 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object p1
    const/16 v0, -32602
    invoke-direct { p0, v0, p1 }, Lteec/shell/term_shell/runtime/McpEndpoint$ProtocolFailure;-><init>(ILjava/lang/String;)V
    throw p0
.end method

.method private static string(Lorg/json/JSONObject;Ljava/lang/String;)Ljava/lang/String;
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Lteec/shell/term_shell/runtime/McpEndpoint$ProtocolFailure;
    }
  .end annotation
  .registers 3
  .line 175
    invoke-virtual { p0, p1 }, Lorg/json/JSONObject;->opt(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object p0
  .line 176
    instance-of v0, p0, Ljava/lang/String;
    if-eqz v0, :L0
    check-cast p0, Ljava/lang/String;
    invoke-virtual { p0 }, Ljava/lang/String;->isEmpty()Z
    move-result v0
    if-nez v0, :L0
  .line 177
    return-object p0
  :L0
  .line 176
    new-instance p0, Lteec/shell/term_shell/runtime/McpEndpoint$ProtocolFailure;
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct { v0 }, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual { v0, p1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p1
    const-string v0, " must be a nonempty string"
    invoke-virtual { p1, v0 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p1
    invoke-virtual { p1 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object p1
    const/16 v0, -32602
    invoke-direct { p0, v0, p1 }, Lteec/shell/term_shell/runtime/McpEndpoint$ProtocolFailure;-><init>(ILjava/lang/String;)V
    throw p0
.end method

.method private static tool(Ljava/lang/String;Ljava/lang/String;Lorg/json/JSONObject;Z)Lorg/json/JSONObject;
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Lorg/json/JSONException;
    }
  .end annotation
  .registers 6
  .line 156
    new-instance v0, Lorg/json/JSONObject;
    invoke-direct { v0 }, Lorg/json/JSONObject;-><init>()V
    const-string v1, "name"
    invoke-virtual { v0, v1, p0 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object p0
    const-string v0, "description"
    invoke-virtual { p0, v0, p1 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object p0
    const-string p1, "inputSchema"
    invoke-virtual { p0, p1, p2 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object p0
    new-instance p1, Lorg/json/JSONObject;
    invoke-direct { p1 }, Lorg/json/JSONObject;-><init>()V
  .line 157
    const-string p2, "readOnlyHint"
    invoke-virtual { p1, p2, p3 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Z)Lorg/json/JSONObject;
    move-result-object p1
    xor-int/lit8 p2, p3, 1
    const-string v0, "destructiveHint"
    invoke-virtual { p1, v0, p2 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Z)Lorg/json/JSONObject;
    move-result-object p1
    const-string p2, "idempotentHint"
    const/4 v0, 1
    invoke-virtual { p1, p2, v0 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Z)Lorg/json/JSONObject;
    move-result-object p1
    xor-int/lit8 p2, p3, 1
    const-string p3, "openWorldHint"
    invoke-virtual { p1, p3, p2 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Z)Lorg/json/JSONObject;
    move-result-object p1
    const-string p2, "annotations"
    invoke-virtual { p0, p2, p1 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object p0
  .line 156
    return-object p0
.end method

.method private static toolResult(Lorg/json/JSONObject;Z)Lorg/json/JSONObject;
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Lorg/json/JSONException;
    }
  .end annotation
  .registers 7
  .line 137
    new-instance v0, Lorg/json/JSONObject;
    invoke-direct { v0 }, Lorg/json/JSONObject;-><init>()V
    new-instance v1, Lorg/json/JSONArray;
    invoke-direct { v1 }, Lorg/json/JSONArray;-><init>()V
    new-instance v2, Lorg/json/JSONObject;
    invoke-direct { v2 }, Lorg/json/JSONObject;-><init>()V
    const-string v3, "type"
    const-string v4, "text"
    invoke-virtual { v2, v3, v4 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v2
    invoke-virtual { p0 }, Lorg/json/JSONObject;->toString()Ljava/lang/String;
    move-result-object v3
    invoke-virtual { v2, v4, v3 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v2
    invoke-virtual { v1, v2 }, Lorg/json/JSONArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;
    move-result-object v1
    const-string v2, "content"
    invoke-virtual { v0, v2, v1 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v0
  .line 138
    const-string v1, "structuredContent"
    invoke-virtual { v0, v1, p0 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object p0
    const-string v0, "isError"
    invoke-virtual { p0, v0, p1 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Z)Lorg/json/JSONObject;
    move-result-object p0
  .line 137
    return-object p0
.end method

.method private static tools()Lorg/json/JSONArray;
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Lorg/json/JSONException;
    }
  .end annotation
  .registers 16
  .line 142
    new-instance v0, Lorg/json/JSONObject;
    invoke-direct { v0 }, Lorg/json/JSONObject;-><init>()V
    const-string v1, "type"
    const-string v2, "object"
    invoke-virtual { v0, v1, v2 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v0
    new-instance v3, Lorg/json/JSONObject;
    invoke-direct { v3 }, Lorg/json/JSONObject;-><init>()V
    const-string v4, "properties"
    invoke-virtual { v0, v4, v3 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v0
    const-string v3, "additionalProperties"
    const/4 v5, 0
    invoke-virtual { v0, v3, v5 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Z)Lorg/json/JSONObject;
    move-result-object v0
  .line 143
    new-instance v6, Lorg/json/JSONObject;
    invoke-direct { v6 }, Lorg/json/JSONObject;-><init>()V
    const-string v7, "string"
    invoke-virtual { v6, v1, v7 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v6
    const-string v8, "minLength"
    const/4 v9, 1
    invoke-virtual { v6, v8, v9 }, Lorg/json/JSONObject;->put(Ljava/lang/String;I)Lorg/json/JSONObject;
    move-result-object v6
  .line 144
    new-instance v8, Lorg/json/JSONObject;
    invoke-direct { v8 }, Lorg/json/JSONObject;-><init>()V
    invoke-virtual { v8, v1, v2 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v8
    new-instance v10, Lorg/json/JSONObject;
    invoke-direct { v10 }, Lorg/json/JSONObject;-><init>()V
    const-string v11, "id"
    invoke-virtual { v10, v11, v6 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v10
    invoke-virtual { v8, v4, v10 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v8
    new-instance v10, Lorg/json/JSONArray;
    invoke-direct { v10 }, Lorg/json/JSONArray;-><init>()V
    invoke-virtual { v10, v11 }, Lorg/json/JSONArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;
    move-result-object v10
    const-string v12, "required"
    invoke-virtual { v8, v12, v10 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v8
    invoke-virtual { v8, v3, v5 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Z)Lorg/json/JSONObject;
    move-result-object v8
  .line 145
    new-instance v10, Lorg/json/JSONObject;
    invoke-direct { v10 }, Lorg/json/JSONObject;-><init>()V
    invoke-virtual { v10, v1, v2 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v2
    new-instance v10, Lorg/json/JSONObject;
    invoke-direct { v10 }, Lorg/json/JSONObject;-><init>()V
    invoke-virtual { v10, v11, v6 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v10
    const-string v13, "source"
    invoke-virtual { v10, v13, v6 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v6
    new-instance v10, Lorg/json/JSONObject;
    invoke-direct { v10 }, Lorg/json/JSONObject;-><init>()V
  .line 146
    invoke-virtual { v10, v1, v7 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v10
    const-string v14, "pattern"
    const-string v15, "^/"
    invoke-virtual { v10, v14, v15 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v10
    const-string v14, "cwd"
    invoke-virtual { v6, v14, v10 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v6
    new-instance v10, Lorg/json/JSONObject;
    invoke-direct { v10 }, Lorg/json/JSONObject;-><init>()V
  .line 147
    const-string v15, "array"
    invoke-virtual { v10, v1, v15 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v10
    new-instance v15, Lorg/json/JSONObject;
    invoke-direct { v15 }, Lorg/json/JSONObject;-><init>()V
    invoke-virtual { v15, v1, v7 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v1
    const-string v7, "items"
    invoke-virtual { v10, v7, v1 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v1
    const-string v7, "minItems"
    invoke-virtual { v1, v7, v9 }, Lorg/json/JSONObject;->put(Ljava/lang/String;I)Lorg/json/JSONObject;
    move-result-object v1
    const-string v7, "argv"
    invoke-virtual { v6, v7, v1 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v1
  .line 145
    invoke-virtual { v2, v4, v1 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v1
    new-instance v2, Lorg/json/JSONArray;
    invoke-direct { v2 }, Lorg/json/JSONArray;-><init>()V
  .line 148
    invoke-virtual { v2, v11 }, Lorg/json/JSONArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;
    move-result-object v2
    invoke-virtual { v2, v13 }, Lorg/json/JSONArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;
    move-result-object v2
    invoke-virtual { v2, v14 }, Lorg/json/JSONArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;
    move-result-object v2
    invoke-virtual { v2, v7 }, Lorg/json/JSONArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;
    move-result-object v2
    invoke-virtual { v1, v12, v2 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v1
    invoke-virtual { v1, v3, v5 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Z)Lorg/json/JSONObject;
    move-result-object v1
  .line 149
    new-instance v2, Lorg/json/JSONArray;
    invoke-direct { v2 }, Lorg/json/JSONArray;-><init>()V
  .line 150
    const-string v3, "engine_status"
    const-string v4, "Read compact executor metadata and order counts without loading output history."
    invoke-static { v3, v4, v0, v9 }, Lteec/shell/term_shell/runtime/McpEndpoint;->tool(Ljava/lang/String;Ljava/lang/String;Lorg/json/JSONObject;Z)Lorg/json/JSONObject;
    move-result-object v0
    invoke-virtual { v2, v0 }, Lorg/json/JSONArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;
    move-result-object v0
  .line 151
    const-string v2, "engine_submit"
    const-string v3, "Persist and start one Ubuntu order using exact argv and absolute cwd. Use a unique id; duplicate ids fail without another execution. Shell syntax requires explicit /bin/bash -c arguments."
    invoke-static { v2, v3, v1, v5 }, Lteec/shell/term_shell/runtime/McpEndpoint;->tool(Ljava/lang/String;Ljava/lang/String;Lorg/json/JSONObject;Z)Lorg/json/JSONObject;
    move-result-object v1
    invoke-virtual { v0, v1 }, Lorg/json/JSONArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;
    move-result-object v0
  .line 152
    const-string v1, "engine_order"
    const-string v2, "Read one persisted order by id, including status, exit, stdout and stderr. Other orders' output is not read."
    invoke-static { v1, v2, v8, v9 }, Lteec/shell/term_shell/runtime/McpEndpoint;->tool(Ljava/lang/String;Ljava/lang/String;Lorg/json/JSONObject;Z)Lorg/json/JSONObject;
    move-result-object v1
    invoke-virtual { v0, v1 }, Lorg/json/JSONArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;
    move-result-object v0
  .line 149
    return-object v0
.end method

.method public handle(Ljava/lang/String;Ljava/util/Map;[B)Lteec/shell/term_shell/runtime/McpEndpoint$Reply;
  .annotation system Ldalvik/annotation/Signature;
    value = {
      "(",
      "Ljava/lang/String;",
      "Ljava/util/Map<",
      "Ljava/lang/String;",
      "Ljava/lang/String;",
      ">;[B)",
      "Lteec/shell/term_shell/runtime/McpEndpoint$Reply;"
    }
  .end annotation
  .catch Lorg/json/JSONException; { :L5 .. :L7 } :L56
  .catch Ljava/nio/charset/CharacterCodingException; { :L5 .. :L7 } :L55
  .catch Lteec/shell/term_shell/runtime/McpEndpoint$ProtocolFailure; { :L25 .. :L33 } :L46
  .catch Ljava/lang/Exception; { :L25 .. :L33 } :L43
  .catch Lteec/shell/term_shell/runtime/McpEndpoint$ProtocolFailure; { :L34 .. :L36 } :L39
  .catch Ljava/lang/Exception; { :L34 .. :L36 } :L38
  .catch Lteec/shell/term_shell/runtime/McpEndpoint$ProtocolFailure; { :L37 .. :L41 } :L42
  .catch Ljava/lang/Exception; { :L37 .. :L41 } :L41
  .registers 22
  .line 41
    move-object/from16 v0, p2
    const-string v1, "version"
    const-string v2, "name"
    const-string v3, "capabilities"
    const-string v4, "protocolVersion"
    const-string v5, "2025-03-26"
    const-string v6, "mcp-protocol-version"
    invoke-interface { v0, v6, v5 }, Ljava/util/Map;->getOrDefault(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v5
    check-cast v5, Ljava/lang/String;
  .line 42
    const-string v7, "POST"
    move-object/from16 v8, p1
    invoke-virtual { v8, v7 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v7
    const-string v8, ""
    if-nez v7, :L0
    new-instance v0, Lteec/shell/term_shell/runtime/McpEndpoint$Reply;
    const/16 v1, 405
    const-string v2, "Allow: POST\r\n"
    invoke-direct { v0, v1, v8, v2 }, Lteec/shell/term_shell/runtime/McpEndpoint$Reply;-><init>(ILjava/lang/String;Ljava/lang/String;)V
    return-object v0
  :L0
  .line 43
    invoke-interface { v0, v6 }, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z
    move-result v6
    const/16 v7, -32600
    const/16 v9, 400
    if-eqz v6, :L1
    sget-object v6, Lteec/shell/term_shell/runtime/McpEndpoint;->VERSIONS:Ljava/util/List;
    invoke-interface { v6, v5 }, Ljava/util/List;->contains(Ljava/lang/Object;)Z
    move-result v6
    if-nez v6, :L1
    sget-object v0, Lorg/json/JSONObject;->NULL:Ljava/lang/Object;
    const-string v1, "Unsupported MCP-Protocol-Version"
    invoke-static { v9, v0, v7, v1, v8 }, Lteec/shell/term_shell/runtime/McpEndpoint;->error(ILjava/lang/Object;ILjava/lang/String;Ljava/lang/String;)Lteec/shell/term_shell/runtime/McpEndpoint$Reply;
    move-result-object v0
    return-object v0
  :L1
  .line 44
    sget-object v6, Lteec/shell/term_shell/runtime/McpEndpoint;->VERSIONS:Ljava/util/List;
    invoke-interface { v6, v5 }, Ljava/util/List;->contains(Ljava/lang/Object;)Z
    move-result v6
    const-string v10, "\r\n"
    const-string v11, "MCP-Protocol-Version: "
    if-eqz v6, :L2
    new-instance v6, Ljava/lang/StringBuilder;
    invoke-direct { v6 }, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual { v6, v11 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v6
    invoke-virtual { v6, v5 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v6
    invoke-virtual { v6, v10 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v6
    invoke-virtual { v6 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v6
    goto :L3
  :L2
    move-object v6, v8
  :L3
  .line 45
    const-string v12, "content-type"
    invoke-interface { v0, v12, v8 }, Ljava/util/Map;->getOrDefault(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v12
    check-cast v12, Ljava/lang/String;
    const-string v13, ";"
    const/4 v14, 2
    invoke-virtual { v12, v13, v14 }, Ljava/lang/String;->split(Ljava/lang/String;I)[Ljava/lang/String;
    move-result-object v12
    const/4 v13, 0
    aget-object v12, v12, v13
    invoke-virtual { v12 }, Ljava/lang/String;->trim()Ljava/lang/String;
    move-result-object v12
  .line 46
    const-string v14, "application/json"
    invoke-virtual { v12, v14 }, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z
    move-result v12
    if-nez v12, :L4
    sget-object v0, Lorg/json/JSONObject;->NULL:Ljava/lang/Object;
    const-string v1, "Content-Type must be application/json"
    const/16 v2, 415
    invoke-static { v2, v0, v7, v1, v6 }, Lteec/shell/term_shell/runtime/McpEndpoint;->error(ILjava/lang/Object;ILjava/lang/String;Ljava/lang/String;)Lteec/shell/term_shell/runtime/McpEndpoint$Reply;
    move-result-object v0
    return-object v0
  :L4
  .line 47
    const-string v12, "accept"
    invoke-interface { v0, v12, v8 }, Ljava/util/Map;->getOrDefault(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v0
    check-cast v0, Ljava/lang/String;
    invoke-static { v0 }, Lteec/shell/term_shell/runtime/McpEndpoint;->acceptsJson(Ljava/lang/String;)Z
    move-result v0
    if-nez v0, :L5
    sget-object v0, Lorg/json/JSONObject;->NULL:Ljava/lang/Object;
    const-string v1, "Accept must include application/json"
    const/16 v2, 406
    invoke-static { v2, v0, v7, v1, v6 }, Lteec/shell/term_shell/runtime/McpEndpoint;->error(ILjava/lang/Object;ILjava/lang/String;Ljava/lang/String;)Lteec/shell/term_shell/runtime/McpEndpoint$Reply;
    move-result-object v0
    return-object v0
  :L5
  .line 50
    sget-object v0, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;
    invoke-virtual { v0 }, Ljava/nio/charset/Charset;->newDecoder()Ljava/nio/charset/CharsetDecoder;
    move-result-object v0
    sget-object v12, Ljava/nio/charset/CodingErrorAction;->REPORT:Ljava/nio/charset/CodingErrorAction;
    invoke-virtual { v0, v12 }, Ljava/nio/charset/CharsetDecoder;->onMalformedInput(Ljava/nio/charset/CodingErrorAction;)Ljava/nio/charset/CharsetDecoder;
    move-result-object v0
    sget-object v12, Ljava/nio/charset/CodingErrorAction;->REPORT:Ljava/nio/charset/CodingErrorAction;
    invoke-virtual { v0, v12 }, Ljava/nio/charset/CharsetDecoder;->onUnmappableCharacter(Ljava/nio/charset/CodingErrorAction;)Ljava/nio/charset/CharsetDecoder;
    move-result-object v0
    invoke-static/range { p3 .. p3 }, Ljava/nio/ByteBuffer;->wrap([B)Ljava/nio/ByteBuffer;
    move-result-object v12
    invoke-virtual { v0, v12 }, Ljava/nio/charset/CharsetDecoder;->decode(Ljava/nio/ByteBuffer;)Ljava/nio/CharBuffer;
    move-result-object v0
    invoke-virtual { v0 }, Ljava/nio/CharBuffer;->toString()Ljava/lang/String;
    move-result-object v0
  .line 51
    new-instance v12, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;
    invoke-direct { v12, v0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;-><init>(Ljava/lang/String;)V
    invoke-virtual { v12 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->check()V
  .line 52
    new-instance v12, Lorg/json/JSONTokener;
    invoke-direct { v12, v0 }, Lorg/json/JSONTokener;-><init>(Ljava/lang/String;)V
    invoke-virtual { v12 }, Lorg/json/JSONTokener;->nextValue()Ljava/lang/Object;
    move-result-object v0
  .line 53
    instance-of v12, v0, Lorg/json/JSONObject;
    if-nez v12, :L6
    sget-object v0, Lorg/json/JSONObject;->NULL:Ljava/lang/Object;
    const-string v1, "A single JSON-RPC object is required"
    invoke-static { v9, v0, v7, v1, v6 }, Lteec/shell/term_shell/runtime/McpEndpoint;->error(ILjava/lang/Object;ILjava/lang/String;Ljava/lang/String;)Lteec/shell/term_shell/runtime/McpEndpoint$Reply;
    move-result-object v0
    return-object v0
  :L6
  .line 54
    check-cast v0, Lorg/json/JSONObject;
  :L7
  .line 57
    nop
  .line 58
    const-string v12, "id"
    invoke-virtual { v0, v12 }, Lorg/json/JSONObject;->opt(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v14
  .line 59
    invoke-virtual { v0, v12 }, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z
    move-result v15
  .line 60
    const-string v13, "jsonrpc"
    invoke-virtual { v0, v13 }, Lorg/json/JSONObject;->opt(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v7
    const-string v9, "2.0"
    invoke-virtual { v9, v7 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v7
    if-eqz v7, :L53
    if-eqz v15, :L8
    instance-of v7, v14, Ljava/lang/String;
    if-nez v7, :L8
    instance-of v7, v14, Ljava/lang/Integer;
    if-nez v7, :L8
    instance-of v7, v14, Ljava/lang/Long;
    if-nez v7, :L8
    move-object/from16 v1, p0
    const/16 v2, -32600
    const/16 v3, 400
    goto/16 :L54
  :L8
  .line 61
    sget-object v7, Lteec/shell/term_shell/runtime/McpEndpoint;->VERSIONS:Ljava/util/List;
    invoke-interface { v7, v5 }, Ljava/util/List;->contains(Ljava/lang/Object;)Z
    move-result v5
    const-string v7, "initialize"
    move/from16 p2, v5
    const-string v5, "method"
    if-nez p2, :L11
    move/from16 p2, v15
    invoke-virtual { v0, v5 }, Lorg/json/JSONObject;->opt(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v15
    invoke-virtual { v7, v15 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v15
    if-nez v15, :L12
    if-eqz p2, :L9
    goto :L10
  :L9
    sget-object v14, Lorg/json/JSONObject;->NULL:Ljava/lang/Object;
  :L10
    const-string v0, "MCP-Protocol-Version must be 2025-11-25 or 2025-06-18"
    const/16 v1, -32600
    const/16 v2, 400
    invoke-static { v2, v14, v1, v0, v6 }, Lteec/shell/term_shell/runtime/McpEndpoint;->error(ILjava/lang/Object;ILjava/lang/String;Ljava/lang/String;)Lteec/shell/term_shell/runtime/McpEndpoint$Reply;
    move-result-object v0
    return-object v0
  :L11
    move/from16 p2, v15
  :L12
  .line 62
    invoke-virtual { v0, v5 }, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z
    move-result v15
    move/from16 p3, v15
    const-string v15, "error"
    move-object/from16 v17, v12
    const-string v12, "result"
    if-nez p3, :L16
  .line 63
    if-eqz p2, :L13
    invoke-virtual { v0, v12 }, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z
    move-result v1
    invoke-virtual { v0, v15 }, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z
    move-result v0
    if-eq v1, v0, :L13
    new-instance v0, Lteec/shell/term_shell/runtime/McpEndpoint$Reply;
    const/16 v1, 202
    invoke-direct { v0, v1, v8, v6 }, Lteec/shell/term_shell/runtime/McpEndpoint$Reply;-><init>(ILjava/lang/String;Ljava/lang/String;)V
    return-object v0
  :L13
  .line 64
    if-eqz p2, :L14
    goto :L15
  :L14
    sget-object v14, Lorg/json/JSONObject;->NULL:Ljava/lang/Object;
  :L15
    const-string v0, "JSON-RPC method is required"
    const/16 v1, -32600
    const/16 v2, 400
    invoke-static { v2, v14, v1, v0, v6 }, Lteec/shell/term_shell/runtime/McpEndpoint;->error(ILjava/lang/Object;ILjava/lang/String;Ljava/lang/String;)Lteec/shell/term_shell/runtime/McpEndpoint$Reply;
    move-result-object v0
    return-object v0
  :L16
  .line 66
    move-object/from16 p3, v14
    invoke-virtual { v0, v5 }, Lorg/json/JSONObject;->opt(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v14
    instance-of v14, v14, Ljava/lang/String;
    if-eqz v14, :L49
    invoke-virtual { v0, v12 }, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z
    move-result v14
    if-nez v14, :L49
    invoke-virtual { v0, v15 }, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z
    move-result v14
    if-eqz v14, :L17
    move-object/from16 v1, p0
    move-object/from16 v4, p3
    goto/16 :L50
  :L17
  .line 67
    const-string v14, "params"
    invoke-virtual { v0, v14 }, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z
    move-result v15
    move/from16 v16, v15
    if-eqz v16, :L22
    invoke-virtual { v0, v14 }, Lorg/json/JSONObject;->opt(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v15
    instance-of v15, v15, Lorg/json/JSONObject;
    if-nez v15, :L22
    if-eqz p2, :L18
    const/16 v9, 200
    goto :L19
  :L18
    const/16 v9, 400
  :L19
    if-eqz p2, :L20
    move-object/from16 v14, p3
    goto :L21
  :L20
    sget-object v14, Lorg/json/JSONObject;->NULL:Ljava/lang/Object;
  :L21
    const-string v0, "params must be an object"
    const/16 v1, -32602
    invoke-static { v9, v14, v1, v0, v6 }, Lteec/shell/term_shell/runtime/McpEndpoint;->error(ILjava/lang/Object;ILjava/lang/String;Ljava/lang/String;)Lteec/shell/term_shell/runtime/McpEndpoint$Reply;
    move-result-object v0
    return-object v0
  :L22
  .line 68
    if-nez p2, :L23
    new-instance v0, Lteec/shell/term_shell/runtime/McpEndpoint$Reply;
    const/16 v1, 202
    invoke-direct { v0, v1, v8, v6 }, Lteec/shell/term_shell/runtime/McpEndpoint$Reply;-><init>(ILjava/lang/String;Ljava/lang/String;)V
    return-object v0
  :L23
  .line 69
    invoke-virtual { v0, v14 }, Lorg/json/JSONObject;->optJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;
    move-result-object v8
  .line 70
    if-nez v8, :L24
    new-instance v8, Lorg/json/JSONObject;
    invoke-direct { v8 }, Lorg/json/JSONObject;-><init>()V
  :L24
  .line 71
    invoke-virtual { v0, v5 }, Lorg/json/JSONObject;->optString(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
  :L25
  .line 74
    invoke-virtual { v0, v7 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v5
    if-eqz v5, :L28
  .line 75
    invoke-static { v8, v4 }, Lteec/shell/term_shell/runtime/McpEndpoint;->string(Lorg/json/JSONObject;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
  .line 76
    invoke-static { v8, v3 }, Lteec/shell/term_shell/runtime/McpEndpoint;->object(Lorg/json/JSONObject;Ljava/lang/String;)Lorg/json/JSONObject;
  .line 77
    const-string v5, "clientInfo"
    invoke-static { v8, v5 }, Lteec/shell/term_shell/runtime/McpEndpoint;->object(Lorg/json/JSONObject;Ljava/lang/String;)Lorg/json/JSONObject;
    move-result-object v5
  .line 78
    invoke-static { v5, v2 }, Lteec/shell/term_shell/runtime/McpEndpoint;->string(Lorg/json/JSONObject;Ljava/lang/String;)Ljava/lang/String;
    invoke-static { v5, v1 }, Lteec/shell/term_shell/runtime/McpEndpoint;->string(Lorg/json/JSONObject;Ljava/lang/String;)Ljava/lang/String;
  .line 79
    sget-object v5, Lteec/shell/term_shell/runtime/McpEndpoint;->VERSIONS:Ljava/util/List;
    invoke-interface { v5, v0 }, Ljava/util/List;->contains(Ljava/lang/Object;)Z
    move-result v5
    if-eqz v5, :L26
    goto :L27
  :L26
    const-string v0, "2025-11-25"
  :L27
  .line 80
    new-instance v5, Ljava/lang/StringBuilder;
    invoke-direct { v5 }, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual { v5, v11 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v5
    invoke-virtual { v5, v0 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v5
    invoke-virtual { v5, v10 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v5
    invoke-virtual { v5 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v6
  .line 81
    new-instance v5, Lorg/json/JSONObject;
    invoke-direct { v5 }, Lorg/json/JSONObject;-><init>()V
    invoke-virtual { v5, v4, v0 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v0
    new-instance v4, Lorg/json/JSONObject;
    invoke-direct { v4 }, Lorg/json/JSONObject;-><init>()V
    const-string v5, "tools"
    new-instance v7, Lorg/json/JSONObject;
    invoke-direct { v7 }, Lorg/json/JSONObject;-><init>()V
    const-string v8, "listChanged"
  .line 82
    const/4 v10, 0
    invoke-virtual { v7, v8, v10 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Z)Lorg/json/JSONObject;
    move-result-object v7
    invoke-virtual { v4, v5, v7 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v4
    invoke-virtual { v0, v3, v4 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v0
    const-string v3, "serverInfo"
    new-instance v4, Lorg/json/JSONObject;
    invoke-direct { v4 }, Lorg/json/JSONObject;-><init>()V
    const-string v5, "teec-machine-engine"
  .line 83
    invoke-virtual { v4, v2, v5 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v2
    const-string v4, "1.0.0"
    invoke-virtual { v2, v1, v4 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v1
    invoke-virtual { v0, v3, v1 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v0
    const-string v1, "instructions"
    const-string v2, "Submit explicit argv with a unique order id, then fetch that id with engine_order. Reusing an id does not execute again. Interrupted orders are never replayed."
  .line 84
    invoke-virtual { v0, v1, v2 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v0
    goto :L29
  :L28
  .line 85
    const-string v1, "ping"
    invoke-virtual { v0, v1 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :L30
    new-instance v0, Lorg/json/JSONObject;
    invoke-direct { v0 }, Lorg/json/JSONObject;-><init>()V
  :L29
    move-object/from16 v1, p0
    goto :L35
  :L30
  .line 86
    const-string v1, "tools/list"
    invoke-virtual { v0, v1 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :L32
  .line 87
    const-string v0, "cursor"
    invoke-virtual { v8, v0 }, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z
    move-result v0
    if-nez v0, :L31
  .line 88
    new-instance v0, Lorg/json/JSONObject;
    invoke-direct { v0 }, Lorg/json/JSONObject;-><init>()V
    const-string v1, "tools"
    invoke-static { }, Lteec/shell/term_shell/runtime/McpEndpoint;->tools()Lorg/json/JSONArray;
    move-result-object v2
    invoke-virtual { v0, v1, v2 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v0
    move-object/from16 v1, p0
    goto :L35
  :L31
  .line 87
    new-instance v0, Lteec/shell/term_shell/runtime/McpEndpoint$ProtocolFailure;
    const-string v1, "This fixed tool list has no pagination cursor"
    const/16 v2, -32602
    invoke-direct { v0, v2, v1 }, Lteec/shell/term_shell/runtime/McpEndpoint$ProtocolFailure;-><init>(ILjava/lang/String;)V
    throw v0
  :L32
  .line 89
    const-string v1, "tools/call"
    invoke-virtual { v0, v1 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
  :L33
    if-eqz v1, :L40
    move-object/from16 v1, p0
  :L34
    invoke-direct { v1, v8 }, Lteec/shell/term_shell/runtime/McpEndpoint;->call(Lorg/json/JSONObject;)Lorg/json/JSONObject;
    move-result-object v0
  :L35
  .line 91
    new-instance v2, Lteec/shell/term_shell/runtime/McpEndpoint$Reply;
    new-instance v3, Lorg/json/JSONObject;
    invoke-direct { v3 }, Lorg/json/JSONObject;-><init>()V
    invoke-virtual { v3, v13, v9 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v3
  :L36
    move-object/from16 v4, p3
    move-object/from16 v5, v17
  :L37
    invoke-virtual { v3, v5, v4 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v3
    invoke-virtual { v3, v12, v0 }, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    move-result-object v0
    invoke-virtual { v0 }, Lorg/json/JSONObject;->toString()Ljava/lang/String;
    move-result-object v0
    const/16 v3, 200
    invoke-direct { v2, v3, v0, v6 }, Lteec/shell/term_shell/runtime/McpEndpoint$Reply;-><init>(ILjava/lang/String;Ljava/lang/String;)V
    return-object v2
  :L38
  .line 94
    move-exception v0
    goto :L44
  :L39
  .line 92
    move-exception v0
    goto :L47
  :L40
  .line 90
    move-object/from16 v1, p0
    move-object/from16 v4, p3
    new-instance v2, Lteec/shell/term_shell/runtime/McpEndpoint$ProtocolFailure;
    new-instance v3, Ljava/lang/StringBuilder;
    invoke-direct { v3 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v5, "Method not found: "
    invoke-virtual { v3, v5 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v3
    invoke-virtual { v3, v0 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual { v0 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    const/16 v3, -32601
    invoke-direct { v2, v3, v0 }, Lteec/shell/term_shell/runtime/McpEndpoint$ProtocolFailure;-><init>(ILjava/lang/String;)V
    throw v2
  :L41
  .line 94
    move-exception v0
    goto :L45
  :L42
  .line 92
    move-exception v0
    goto :L48
  :L43
  .line 94
    move-exception v0
    move-object/from16 v1, p0
  :L44
    move-object/from16 v4, p3
  :L45
  .line 95
    const/16 v2, -32603
    invoke-virtual { v0 }, Ljava/lang/Exception;->toString()Ljava/lang/String;
    move-result-object v0
    const/16 v3, 200
    invoke-static { v3, v4, v2, v0, v6 }, Lteec/shell/term_shell/runtime/McpEndpoint;->error(ILjava/lang/Object;ILjava/lang/String;Ljava/lang/String;)Lteec/shell/term_shell/runtime/McpEndpoint$Reply;
    move-result-object v0
    return-object v0
  :L46
  .line 92
    move-exception v0
    move-object/from16 v1, p0
  :L47
    move-object/from16 v4, p3
  :L48
    const/16 v3, 200
  .line 93
    iget v2, v0, Lteec/shell/term_shell/runtime/McpEndpoint$ProtocolFailure;->code:I
    invoke-virtual { v0 }, Lteec/shell/term_shell/runtime/McpEndpoint$ProtocolFailure;->getMessage()Ljava/lang/String;
    move-result-object v0
    invoke-static { v3, v4, v2, v0, v6 }, Lteec/shell/term_shell/runtime/McpEndpoint;->error(ILjava/lang/Object;ILjava/lang/String;Ljava/lang/String;)Lteec/shell/term_shell/runtime/McpEndpoint$Reply;
    move-result-object v0
    return-object v0
  :L49
  .line 66
    move-object/from16 v1, p0
    move-object/from16 v4, p3
  :L50
    if-eqz p2, :L51
    move-object v14, v4
    goto :L52
  :L51
    sget-object v14, Lorg/json/JSONObject;->NULL:Ljava/lang/Object;
  :L52
    const-string v0, "Invalid JSON-RPC request"
    const/16 v2, -32600
    const/16 v3, 400
    invoke-static { v3, v14, v2, v0, v6 }, Lteec/shell/term_shell/runtime/McpEndpoint;->error(ILjava/lang/Object;ILjava/lang/String;Ljava/lang/String;)Lteec/shell/term_shell/runtime/McpEndpoint$Reply;
    move-result-object v0
    return-object v0
  :L53
  .line 60
    move-object/from16 v1, p0
    const/16 v2, -32600
    const/16 v3, 400
  :L54
    sget-object v0, Lorg/json/JSONObject;->NULL:Ljava/lang/Object;
    const-string v4, "Invalid JSON-RPC envelope"
    invoke-static { v3, v0, v2, v4, v6 }, Lteec/shell/term_shell/runtime/McpEndpoint;->error(ILjava/lang/Object;ILjava/lang/String;Ljava/lang/String;)Lteec/shell/term_shell/runtime/McpEndpoint$Reply;
    move-result-object v0
    return-object v0
  :L55
  .line 55
    move-exception v0
    goto :L57
  :L56
    move-exception v0
  :L57
    move-object/from16 v1, p0
  .line 56
    sget-object v2, Lorg/json/JSONObject;->NULL:Ljava/lang/Object;
    new-instance v3, Ljava/lang/StringBuilder;
    invoke-direct { v3 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v4, "Invalid JSON: "
    invoke-virtual { v3, v4 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v3
    invoke-virtual { v0 }, Ljava/lang/Exception;->getMessage()Ljava/lang/String;
    move-result-object v0
    invoke-virtual { v3, v0 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual { v0 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    const/16 v3, -32700
    const/16 v4, 400
    invoke-static { v4, v2, v3, v0, v6 }, Lteec/shell/term_shell/runtime/McpEndpoint;->error(ILjava/lang/Object;ILjava/lang/String;Ljava/lang/String;)Lteec/shell/term_shell/runtime/McpEndpoint$Reply;
    move-result-object v0
    return-object v0
.end method
