.class final Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;
.super Ljava/lang/Object;
.source "McpEndpoint.java"

.annotation system Ldalvik/annotation/EnclosingClass;
  value = Lteec/shell/term_shell/runtime/McpEndpoint;
.end annotation
.annotation system Ldalvik/annotation/InnerClass;
  accessFlags = 26
  name = "JsonSyntax"
.end annotation

.field private offset:I

.field private final text:Ljava/lang/String;

.method constructor <init>(Ljava/lang/String;)V
  .registers 2
  .line 208
    invoke-direct { p0 }, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->text:Ljava/lang/String;
    return-void
.end method

.method private digit()Z
  .registers 3
  .line 265
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->peek()C
    move-result v0
    const/16 v1, 48
    if-lt v0, v1, :L0
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->peek()C
    move-result v0
    const/16 v1, 57
    if-gt v0, v1, :L0
    const/4 v0, 1
    goto :L1
  :L0
    const/4 v0, 0
  :L1
    return v0
.end method

.method private digits()V
  .registers 2
  .line 266
    nop
  :L0
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->digit()Z
    move-result v0
    if-eqz v0, :L1
    iget v0, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    add-int/lit8 v0, v0, 1
    iput v0, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    goto :L0
  :L1
    return-void
.end method

.method private invalid()V
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Lorg/json/JSONException;
    }
  .end annotation
  .registers 4
  .line 267
    new-instance v0, Lorg/json/JSONException;
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct { v1 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "Invalid JSON syntax at "
    invoke-virtual { v1, v2 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v1
    iget v2, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    invoke-virtual { v1, v2 }, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    move-result-object v1
    invoke-virtual { v1 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1
    invoke-direct { v0, v1 }, Lorg/json/JSONException;-><init>(Ljava/lang/String;)V
    throw v0
.end method

.method private literal(Ljava/lang/String;)V
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Lorg/json/JSONException;
    }
  .end annotation
  .registers 4
  .line 260
    iget-object v0, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->text:Ljava/lang/String;
    iget v1, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    invoke-virtual { v0, p1, v1 }, Ljava/lang/String;->startsWith(Ljava/lang/String;I)Z
    move-result v0
    if-nez v0, :L0
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->invalid()V
  :L0
  .line 261
    iget v0, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    invoke-virtual { p1 }, Ljava/lang/String;->length()I
    move-result p1
    add-int/2addr v0, p1
    iput v0, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
  .line 262
    return-void
.end method

.method private peek()C
  .registers 3
  .line 264
    iget v0, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    iget-object v1, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->text:Ljava/lang/String;
    invoke-virtual { v1 }, Ljava/lang/String;->length()I
    move-result v1
    if-ge v0, v1, :L0
    iget-object v0, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->text:Ljava/lang/String;
    iget v1, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    invoke-virtual { v0, v1 }, Ljava/lang/String;->charAt(I)C
    move-result v0
    goto :L1
  :L0
    const/4 v0, 0
  :L1
    return v0
.end method

.method private string()V
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Lorg/json/JSONException;
    }
  .end annotation
  .registers 6
  .line 241
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->peek()C
    move-result v0
    const/16 v1, 34
    if-eq v0, v1, :L0
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->invalid()V
  :L0
  .line 242
    iget v0, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    add-int/lit8 v0, v0, 1
    iput v0, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
  :L1
  .line 243
    iget v0, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    iget-object v2, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->text:Ljava/lang/String;
    invoke-virtual { v2 }, Ljava/lang/String;->length()I
    move-result v2
    if-ge v0, v2, :L10
  .line 244
    iget-object v0, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->text:Ljava/lang/String;
    iget v2, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    add-int/lit8 v3, v2, 1
    iput v3, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    invoke-virtual { v0, v2 }, Ljava/lang/String;->charAt(I)C
    move-result v0
  .line 245
    if-ne v0, v1, :L2
    return-void
  :L2
  .line 246
    const/16 v2, 32
    if-ge v0, v2, :L3
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->invalid()V
  :L3
  .line 247
    const/16 v2, 92
    if-ne v0, v2, :L9
  .line 248
    iget v0, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    iget-object v2, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->text:Ljava/lang/String;
    invoke-virtual { v2 }, Ljava/lang/String;->length()I
    move-result v2
    if-ne v0, v2, :L4
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->invalid()V
  :L4
  .line 249
    iget-object v0, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->text:Ljava/lang/String;
    iget v2, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    add-int/lit8 v3, v2, 1
    iput v3, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    invoke-virtual { v0, v2 }, Ljava/lang/String;->charAt(I)C
    move-result v0
  .line 250
    const/16 v2, 117
    if-ne v0, v2, :L8
  .line 251
    const/4 v0, 0
  :L5
    const/4 v2, 4
    if-ge v0, v2, :L9
  .line 252
    iget v2, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    iget-object v3, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->text:Ljava/lang/String;
    invoke-virtual { v3 }, Ljava/lang/String;->length()I
    move-result v3
    if-eq v2, v3, :L6
    iget-object v2, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->text:Ljava/lang/String;
    iget v3, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    add-int/lit8 v4, v3, 1
    iput v4, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    invoke-virtual { v2, v3 }, Ljava/lang/String;->charAt(I)C
    move-result v2
    const-string v3, "0123456789abcdefABCDEF"
    invoke-virtual { v3, v2 }, Ljava/lang/String;->indexOf(I)I
    move-result v2
    if-gez v2, :L7
  :L6
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->invalid()V
  :L7
  .line 251
    add-int/lit8 v0, v0, 1
    goto :L5
  :L8
  .line 254
    const-string v2, "\"\\/bfnrt"
    invoke-virtual { v2, v0 }, Ljava/lang/String;->indexOf(I)I
    move-result v0
    if-gez v0, :L9
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->invalid()V
  :L9
  .line 256
    goto :L1
  :L10
  .line 257
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->invalid()V
  .line 258
    return-void
.end method

.method private value()V
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Lorg/json/JSONException;
    }
  .end annotation
  .registers 6
  .line 214
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->whitespace()V
  .line 215
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->peek()C
    move-result v0
  .line 216
    const/16 v1, 123
    if-eq v0, v1, :L17
    const/16 v2, 91
    if-ne v0, v2, :L0
    goto/16 :L17
  :L0
  .line 228
    const/16 v1, 34
    if-ne v0, v1, :L1
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->string()V
    goto/16 :L16
  :L1
  .line 229
    const/16 v1, 116
    if-ne v0, v1, :L2
    const-string v0, "true"
    invoke-direct { p0, v0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->literal(Ljava/lang/String;)V
    goto/16 :L16
  :L2
  .line 230
    const/16 v1, 102
    if-ne v0, v1, :L3
    const-string v0, "false"
    invoke-direct { p0, v0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->literal(Ljava/lang/String;)V
    goto/16 :L16
  :L3
  .line 231
    const/16 v1, 110
    if-ne v0, v1, :L4
    const-string v0, "null"
    invoke-direct { p0, v0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->literal(Ljava/lang/String;)V
    goto/16 :L16
  :L4
  .line 233
    const/16 v1, 45
    if-ne v0, v1, :L5
    iget v0, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    add-int/lit8 v0, v0, 1
    iput v0, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
  :L5
  .line 234
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->peek()C
    move-result v0
    const/16 v2, 48
    if-ne v0, v2, :L6
    iget v0, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    add-int/lit8 v0, v0, 1
    iput v0, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    goto :L9
  :L6
  .line 235
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->peek()C
    move-result v0
    const/16 v2, 49
    if-lt v0, v2, :L7
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->peek()C
    move-result v0
    const/16 v2, 57
    if-le v0, v2, :L8
  :L7
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->invalid()V
  :L8
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->digits()V
  :L9
  .line 236
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->peek()C
    move-result v0
    const/16 v2, 46
    if-ne v0, v2, :L11
    iget v0, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    add-int/lit8 v0, v0, 1
    iput v0, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->digit()Z
    move-result v0
    if-nez v0, :L10
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->invalid()V
  :L10
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->digits()V
  :L11
  .line 237
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->peek()C
    move-result v0
    const/16 v2, 101
    if-eq v0, v2, :L12
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->peek()C
    move-result v0
    const/16 v2, 69
    if-ne v0, v2, :L16
  :L12
    iget v0, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    add-int/lit8 v0, v0, 1
    iput v0, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->peek()C
    move-result v0
    const/16 v2, 43
    if-eq v0, v2, :L13
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->peek()C
    move-result v0
    if-ne v0, v1, :L14
  :L13
    iget v0, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    add-int/lit8 v0, v0, 1
    iput v0, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
  :L14
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->digit()Z
    move-result v0
    if-nez v0, :L15
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->invalid()V
  :L15
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->digits()V
  :L16
  .line 239
    return-void
  :L17
  .line 217
    iget v2, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    add-int/lit8 v2, v2, 1
    iput v2, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
  .line 218
    if-ne v0, v1, :L18
    const/16 v2, 125
    goto :L19
  :L18
    const/16 v2, 93
  :L19
  .line 219
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->whitespace()V
  .line 220
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->peek()C
    move-result v3
    if-ne v3, v2, :L20
    iget v0, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    add-int/lit8 v0, v0, 1
    iput v0, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    return-void
  :L20
  .line 222
    if-ne v0, v1, :L22
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->string()V
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->whitespace()V
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->peek()C
    move-result v3
    const/16 v4, 58
    if-eq v3, v4, :L21
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->invalid()V
  :L21
    iget v3, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    add-int/lit8 v3, v3, 1
    iput v3, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
  :L22
  .line 223
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->value()V
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->whitespace()V
  .line 224
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->peek()C
    move-result v3
    if-ne v3, v2, :L23
    iget v0, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    add-int/lit8 v0, v0, 1
    iput v0, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    return-void
  :L23
  .line 225
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->peek()C
    move-result v3
    const/16 v4, 44
    if-eq v3, v4, :L24
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->invalid()V
  :L24
  .line 226
    iget v3, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    add-int/lit8 v3, v3, 1
    iput v3, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->whitespace()V
    goto :L20
.end method

.method private whitespace()V
  .registers 3
  .line 263
    nop
  :L0
    iget v0, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    iget-object v1, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->text:Ljava/lang/String;
    invoke-virtual { v1 }, Ljava/lang/String;->length()I
    move-result v1
    if-ge v0, v1, :L1
    iget-object v0, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->text:Ljava/lang/String;
    iget v1, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    invoke-virtual { v0, v1 }, Ljava/lang/String;->charAt(I)C
    move-result v0
    const-string v1, " \t\r\n"
    invoke-virtual { v1, v0 }, Ljava/lang/String;->indexOf(I)I
    move-result v0
    if-ltz v0, :L1
    iget v0, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    add-int/lit8 v0, v0, 1
    iput v0, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    goto :L0
  :L1
    return-void
.end method

.method check()V
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Lorg/json/JSONException;
    }
  .end annotation
  .registers 3
  .line 210
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->value()V
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->whitespace()V
  .line 211
    iget v0, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->offset:I
    iget-object v1, p0, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->text:Ljava/lang/String;
    invoke-virtual { v1 }, Ljava/lang/String;->length()I
    move-result v1
    if-eq v0, v1, :L0
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/McpEndpoint$JsonSyntax;->invalid()V
  :L0
  .line 212
    return-void
.end method
