.class public final Lteec/shell/term_shell/runtime/SemanticSettings;
.super Ljava/lang/Object;
.source "SemanticSettings.java"

.method private constructor <init>()V
  .registers 1
  .line 7
    invoke-direct { p0 }, Ljava/lang/Object;-><init>()V
    return-void
.end method

.method public static request(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;
  .catch Ljava/io/IOException; { :L4 .. :L5 } :L6
  .registers 5
  .line 10
    const-string v0, "Preflight1: true"
    invoke-virtual { v0, p1 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :L1
    const-string v1, "Preflight1: false"
    invoke-virtual { v1, p1 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :L0
    goto :L1
  :L0
    const/4 v1, 0
    goto :L2
  :L1
    const/4 v1, 1
  :L2
  .line 11
    if-nez v1, :L3
    const-string v2, "Settings started"
    invoke-virtual { v2, p1 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-nez v2, :L3
    const/4 p0, 0
    return-object p0
  :L3
  .line 12
    nop
  .line 13
    if-eqz v1, :L7
  :L4
  .line 15
    invoke-virtual { v0, p1 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p1
    invoke-static { p0, p1 }, Lteec/shell/term_shell/runtime/RagPreflight;->setEnabled(Landroid/content/Context;Z)V
  :L5
  .line 18
    goto :L7
  :L6
  .line 16
    move-exception p1
  .line 17
    const-string p1, "Preflight 1 could not be saved. The previous setting is still active."
    goto :L8
  :L7
  .line 20
    const-string p1, ""
  :L8
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct { v0 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "updateSetting('Preflight1: "
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-static { p0 }, Lteec/shell/term_shell/runtime/RagPreflight;->isEnabled(Landroid/content/Context;)Z
    move-result p0
    invoke-virtual { v0, p0 }, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;
    move-result-object p0
    const-string v0, "');document.getElementById('preflight1Status').textContent='"
    invoke-virtual { p0, v0 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p0
    invoke-virtual { p0, p1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p0
    const-string p1, "';"
    invoke-virtual { p0, p1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p0
    invoke-virtual { p0 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object p0
    return-object p0
.end method
