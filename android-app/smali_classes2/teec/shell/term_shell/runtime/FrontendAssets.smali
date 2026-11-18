.class public final Lteec/shell/term_shell/runtime/FrontendAssets;
.super Ljava/lang/Object;
.implements Lteec/shell/term_shell/runtime/TerminalServer$Assets;
.source "FrontendAssets.java"

.field private final directory:Ljava/io/File;

.field private final packaged:Lteec/shell/term_shell/runtime/TerminalServer$Assets;

.method public constructor <init>(Ljava/io/File;Lteec/shell/term_shell/runtime/TerminalServer$Assets;)V
  .registers 3
  .line 13
    invoke-direct { p0 }, Ljava/lang/Object;-><init>()V
  .line 14
    iput-object p1, p0, Lteec/shell/term_shell/runtime/FrontendAssets;->directory:Ljava/io/File;
  .line 15
    iput-object p2, p0, Lteec/shell/term_shell/runtime/FrontendAssets;->packaged:Lteec/shell/term_shell/runtime/TerminalServer$Assets;
  .line 16
    return-void
.end method

.method public read(Ljava/lang/String;)[B
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
  .registers 6
  .line 20
    const-string v0, "terminal/"
    invoke-virtual { p1, v0 }, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v0
    const-string v1, "Not found"
    if-eqz v0, :L20
    const/16 v0, 9
    invoke-virtual { p1, v0 }, Ljava/lang/String;->substring(I)Ljava/lang/String;
    move-result-object v2
    invoke-static { v2 }, Lteec/shell/term_shell/runtime/TerminalServer;->terminalAssetName(Ljava/lang/String;)Z
    move-result v2
    if-eqz v2, :L20
  .line 21
    new-instance v2, Ljava/io/File;
    iget-object v3, p0, Lteec/shell/term_shell/runtime/FrontendAssets;->directory:Ljava/io/File;
    invoke-virtual { p1, v0 }, Ljava/lang/String;->substring(I)Ljava/lang/String;
    move-result-object v0
    invoke-direct { v2, v3, v0 }, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
  .line 22
    invoke-virtual { v2 }, Ljava/io/File;->exists()Z
    move-result v0
    if-nez v0, :L0
    iget-object v0, p0, Lteec/shell/term_shell/runtime/FrontendAssets;->packaged:Lteec/shell/term_shell/runtime/TerminalServer$Assets;
    invoke-interface { v0, p1 }, Lteec/shell/term_shell/runtime/TerminalServer$Assets;->read(Ljava/lang/String;)[B
    move-result-object p1
    return-object p1
  :L0
  .line 23
    invoke-virtual { v2 }, Ljava/io/File;->isFile()Z
    move-result p1
    if-eqz p1, :L19
  .line 24
    new-instance p1, Ljava/io/FileInputStream;
    invoke-direct { p1, v2 }, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V
  :L1
    new-instance v0, Ljava/io/ByteArrayOutputStream;
    invoke-direct { v0 }, Ljava/io/ByteArrayOutputStream;-><init>()V
  :L2
  .line 25
    const/16 v1, 16384
  :L3
    new-array v1, v1, [B
  :L4
  .line 27
    invoke-virtual { p1, v1 }, Ljava/io/FileInputStream;->read([B)I
    move-result v2
    const/4 v3, -1
    if-eq v2, v3, :L5
    const/4 v3, 0
    invoke-virtual { v0, v1, v3, v2 }, Ljava/io/ByteArrayOutputStream;->write([BII)V
    goto :L4
  :L5
  .line 28
    invoke-virtual { v0 }, Ljava/io/ByteArrayOutputStream;->toByteArray()[B
    move-result-object v1
  :L6
  .line 29
    invoke-virtual { v0 }, Ljava/io/ByteArrayOutputStream;->close()V
  :L7
    invoke-virtual { p1 }, Ljava/io/FileInputStream;->close()V
  .line 28
    return-object v1
  :L8
  .line 24
    move-exception v1
  :L9
    invoke-virtual { v0 }, Ljava/io/ByteArrayOutputStream;->close()V
  :L10
    goto :L13
  :L11
    move-exception v0
  :L12
    invoke-virtual { v1, v0 }, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V
  :L13
    throw v1
  :L14
    move-exception v0
  :L15
    invoke-virtual { p1 }, Ljava/io/FileInputStream;->close()V
  :L16
    goto :L18
  :L17
    move-exception p1
    invoke-virtual { v0, p1 }, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V
  :L18
    throw v0
  :L19
  .line 23
    new-instance p1, Ljava/io/FileNotFoundException;
    invoke-direct { p1, v1 }, Ljava/io/FileNotFoundException;-><init>(Ljava/lang/String;)V
    throw p1
  :L20
  .line 20
    new-instance p1, Ljava/io/FileNotFoundException;
    invoke-direct { p1, v1 }, Ljava/io/FileNotFoundException;-><init>(Ljava/lang/String;)V
    throw p1
.end method
