.class public final Lteec/shell/term_shell/runtime/UbuntuRuntimeService;
.super Landroid/app/Service;
.source "UbuntuRuntimeService.java"

.field private final static CHANNEL:Ljava/lang/String; = "ubuntu-runtime"

.field private final static NOTIFICATION:I = 2204

.field public final static READ:I = 4

.field public final static RESIZE:I = 3

.field public final static START:I = 1

.field public final static STATE:I = 5

.field public final static STOP:I = 6

.field public final static WRITE:I = 2

.field private browsers:Lteec/shell/term_shell/runtime/TerminalSessions;

.field private commands:Landroid/os/Handler;

.field private engine:Lteec/shell/term_shell/runtime/MachineEngine;

.field private error:Ljava/lang/String;

.field private filesWorkspace:Lteec/shell/term_shell/runtime/FileWorkspace;

.field private initialTerminalPending:Z

.field private messenger:Landroid/os/Messenger;

.field private preflight:Lteec/shell/term_shell/runtime/RagPreflight;

.field private preflightPolling:Z

.field private rag:Lteec/shell/term_shell/runtime/SemanticRag;

.field private sshError:Ljava/lang/String;

.field private sshSession:Lteec/shell/term_shell/runtime/PtySession;

.field private sshSessionId:Ljava/lang/String;

.field private stopping:Z

.field private wake:Landroid/os/PowerManager$WakeLock;

.field private web:Lteec/shell/term_shell/runtime/TerminalServer;

.field private worker:Landroid/os/HandlerThread;

.method public static synthetic $r8$lambda$CkshUilJPGpXCaazzEGzoGiGrGs(Lteec/shell/term_shell/runtime/UbuntuRuntimeService;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
  .registers 4
    invoke-direct { p0, p1, p2, p3 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->control(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object p0
    return-object p0
.end method

.method public static synthetic $r8$lambda$KsaG_tLKFU6gsYWDU7OJW5omdjo(Lteec/shell/term_shell/runtime/UbuntuRuntimeService;)V
  .registers 1
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->pollPreflight()V
    return-void
.end method

.method public static synthetic $r8$lambda$Tb5bTHL-f_KC1sRed_ferzMMb0g(Lteec/shell/term_shell/runtime/UbuntuRuntimeService;)V
  .registers 1
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->shutdown()V
    return-void
.end method

.method public static synthetic $r8$lambda$Y71EEhwxVMpfZFUw05zFsT4xEeA(Lteec/shell/term_shell/runtime/UbuntuRuntimeService;Ljava/lang/String;)[B
  .registers 2
    invoke-direct { p0, p1 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->readAsset(Ljava/lang/String;)[B
    move-result-object p0
    return-object p0
.end method

.method public static synthetic $r8$lambda$gGZa-gsS8zFRDNRKqHG5UVXHWz0(Lteec/shell/term_shell/runtime/UbuntuRuntimeService;Landroid/os/Message;)Z
  .registers 2
    invoke-direct { p0, p1 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->handle(Landroid/os/Message;)Z
    move-result p0
    return p0
.end method

.method public static synthetic $r8$lambda$zvV42Iow4-QPQmlJXNt9QvGwVOM(Lteec/shell/term_shell/runtime/UbuntuRuntimeService;)V
  .registers 1
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->startSession()V
    return-void
.end method

.method public constructor <init>()V
  .registers 2
  .line 26
    invoke-direct { p0 }, Landroid/app/Service;-><init>()V
  .line 41
    const-string v0, ""
    iput-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->sshError:Ljava/lang/String;
  .line 42
    iput-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->sshSessionId:Ljava/lang/String;
  .line 43
    iput-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->error:Ljava/lang/String;
    return-void
.end method

.method private control(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/lang/Exception;
    }
  .end annotation
  .registers 8
  .line 145
    invoke-static { p2 }, Ljava/net/URI;->create(Ljava/lang/String;)Ljava/net/URI;
    move-result-object v0
  .line 146
    invoke-virtual { v0 }, Ljava/net/URI;->getPath()Ljava/lang/String;
    move-result-object v1
    const-string v2, "/control/rag/"
    invoke-virtual { v1, v2 }, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v1
    if-eqz v1, :L0
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->preflight:Lteec/shell/term_shell/runtime/RagPreflight;
    invoke-virtual { v0, p1, p2, p3 }, Lteec/shell/term_shell/runtime/RagPreflight;->request(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object p1
    return-object p1
  :L0
  .line 147
    invoke-virtual { v0 }, Ljava/net/URI;->getPath()Ljava/lang/String;
    move-result-object v1
    const-string v2, "/control/cliproxy/"
    invoke-virtual { v1, v2 }, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v1
    if-eqz v1, :L1
    new-instance v0, Lteec/shell/term_shell/runtime/CliProxyProfiles;
    new-instance v1, Ljava/io/File;
    invoke-virtual { p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->getFilesDir()Ljava/io/File;
    move-result-object v2
    const-string v3, "Ubuntu22.04Bare/opt/easycliproxyapi/client-profiles.json"
    invoke-direct { v1, v2, v3 }, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    invoke-direct { v0, v1 }, Lteec/shell/term_shell/runtime/CliProxyProfiles;-><init>(Ljava/io/File;)V
    invoke-virtual { v0, p1, p2, p3 }, Lteec/shell/term_shell/runtime/CliProxyProfiles;->request(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object p1
    return-object p1
  :L1
  .line 148
    iget-object p2, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->engine:Lteec/shell/term_shell/runtime/MachineEngine;
    invoke-virtual { v0 }, Ljava/net/URI;->getPath()Ljava/lang/String;
    move-result-object v0
    invoke-virtual { p2, p1, v0, p3 }, Lteec/shell/term_shell/runtime/MachineEngine;->request(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object p1
    return-object p1
.end method

.method private handle(Landroid/os/Message;)Z
  .catch Ljava/lang/Exception; { :L0 .. :L1 } :L12
  .catch Ljava/lang/Exception; { :L2 .. :L12 } :L12
  .catch Landroid/os/RemoteException; { :L22 .. :L23 } :L24
  .registers 12
  .line 215
    const-string v0, "cursor"
    const-string v1, "ok"
    new-instance v2, Landroid/os/Bundle;
    invoke-direct { v2 }, Landroid/os/Bundle;-><init>()V
  .line 217
    const/4 v3, 0
    const/4 v4, 1
  :L0
    invoke-virtual { p1 }, Landroid/os/Message;->getData()Landroid/os/Bundle;
    move-result-object v5
  .line 218
    iget v6, p1, Landroid/os/Message;->what:I
  :L1
    const-string v7, "bytes"
    packed-switch v6, :L26
  :L2
  .line 238
    new-instance v0, Ljava/io/IOException;
    goto :L11
  :L3
  .line 237
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->shutdown()V
    goto :L10
  :L4
  .line 236
    goto :L10
  :L5
  .line 231
    invoke-direct { p0, v5 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->requireSession(Landroid/os/Bundle;)Lteec/shell/term_shell/runtime/PtySession;
    move-result-object v6
    const-wide/16 v8, 0
    invoke-virtual { v5, v0, v8, v9 }, Landroid/os/Bundle;->getLong(Ljava/lang/String;J)J
    move-result-wide v8
    invoke-virtual { v6, v8, v9 }, Lteec/shell/term_shell/runtime/PtySession;->output(J)Lteec/shell/term_shell/runtime/PtySession$Output;
    move-result-object v5
  .line 232
    iget-object v6, v5, Lteec/shell/term_shell/runtime/PtySession$Output;->bytes:[B
    invoke-virtual { v2, v7, v6 }, Landroid/os/Bundle;->putByteArray(Ljava/lang/String;[B)V
  .line 233
    iget-wide v6, v5, Lteec/shell/term_shell/runtime/PtySession$Output;->cursor:J
    invoke-virtual { v2, v0, v6, v7 }, Landroid/os/Bundle;->putLong(Ljava/lang/String;J)V
  .line 234
    const-string v0, "truncated"
    iget-boolean v5, v5, Lteec/shell/term_shell/runtime/PtySession$Output;->truncated:Z
    invoke-virtual { v2, v0, v5 }, Landroid/os/Bundle;->putBoolean(Ljava/lang/String;Z)V
  .line 235
    goto :L10
  :L6
  .line 228
    invoke-direct { p0, v5 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->requireSession(Landroid/os/Bundle;)Lteec/shell/term_shell/runtime/PtySession;
    move-result-object v0
    const-string v6, "rows"
    invoke-virtual { v5, v6 }, Landroid/os/Bundle;->getInt(Ljava/lang/String;)I
    move-result v6
    const-string v7, "columns"
    invoke-virtual { v5, v7 }, Landroid/os/Bundle;->getInt(Ljava/lang/String;)I
    move-result v5
    invoke-virtual { v0, v6, v5 }, Lteec/shell/term_shell/runtime/PtySession;->resize(II)V
  .line 229
    goto :L10
  :L7
  .line 221
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->preflight:Lteec/shell/term_shell/runtime/RagPreflight;
    invoke-virtual { v0 }, Lteec/shell/term_shell/runtime/RagPreflight;->verify()Lteec/shell/term_shell/runtime/TerminalServer$Admission;
    move-result-object v0
    invoke-virtual { v0 }, Lteec/shell/term_shell/runtime/TerminalServer$Admission;->require()V
  .line 222
    invoke-direct { p0, v5 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->requireSession(Landroid/os/Bundle;)Lteec/shell/term_shell/runtime/PtySession;
    move-result-object v0
  .line 223
    invoke-virtual { v5, v7 }, Landroid/os/Bundle;->getByteArray(Ljava/lang/String;)[B
    move-result-object v5
  .line 224
    if-eqz v5, :L8
  .line 225
    invoke-virtual { v0, v5 }, Lteec/shell/term_shell/runtime/PtySession;->write([B)V
  .line 226
    goto :L10
  :L8
  .line 224
    new-instance v0, Ljava/io/IOException;
    const-string v5, "bytes ontbreekt"
    invoke-direct { v0, v5 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw v0
  :L9
  .line 219
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->startSession()V
  :L10
  .line 240
    invoke-virtual { v2, v1, v4 }, Landroid/os/Bundle;->putBoolean(Ljava/lang/String;Z)V
  .line 244
    goto :L13
  :L11
  .line 238
    new-instance v5, Ljava/lang/StringBuilder;
    invoke-direct { v5 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v6, "Onbekende runtime-opdracht: "
    invoke-virtual { v5, v6 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v5
    iget v6, p1, Landroid/os/Message;->what:I
    invoke-virtual { v5, v6 }, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    move-result-object v5
    invoke-virtual { v5 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v5
    invoke-direct { v0, v5 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw v0
  :L12
  .line 241
    move-exception v0
  .line 242
    invoke-virtual { v2, v1, v3 }, Landroid/os/Bundle;->putBoolean(Ljava/lang/String;Z)V
  .line 243
    const-string v1, "error"
    invoke-virtual { v0 }, Ljava/lang/Exception;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-virtual { v2, v1, v0 }, Landroid/os/Bundle;->putString(Ljava/lang/String;Ljava/lang/String;)V
  :L13
  .line 245
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->browsers:Lteec/shell/term_shell/runtime/TerminalSessions;
    invoke-virtual { p1 }, Landroid/os/Message;->getData()Landroid/os/Bundle;
    move-result-object v1
    const-string v5, ""
    const-string v6, "session"
    invoke-virtual { v1, v6, v5 }, Landroid/os/Bundle;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    invoke-virtual { v0, v1 }, Lteec/shell/term_shell/runtime/TerminalSessions;->find(Ljava/lang/String;)Lteec/shell/term_shell/runtime/TerminalServer$State;
    move-result-object v0
  .line 246
    if-nez v0, :L14
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->browsers:Lteec/shell/term_shell/runtime/TerminalSessions;
    invoke-virtual { v0 }, Lteec/shell/term_shell/runtime/TerminalSessions;->current()Lteec/shell/term_shell/runtime/TerminalServer$State;
    move-result-object v0
  :L14
  .line 247
    iget-object v1, v0, Lteec/shell/term_shell/runtime/TerminalServer$State;->session:Lteec/shell/term_shell/runtime/PtySession;
  .line 248
    iget-object v0, v0, Lteec/shell/term_shell/runtime/TerminalServer$State;->id:Ljava/lang/String;
    invoke-virtual { v2, v6, v0 }, Landroid/os/Bundle;->putString(Ljava/lang/String;Ljava/lang/String;)V
  .line 249
    if-eqz v1, :L15
    invoke-virtual { v1 }, Lteec/shell/term_shell/runtime/PtySession;->running()Z
    move-result v0
    if-eqz v0, :L15
    move v3, v4
  :L15
    const-string v0, "running"
    invoke-virtual { v2, v0, v3 }, Landroid/os/Bundle;->putBoolean(Ljava/lang/String;Z)V
  .line 250
    const/4 v0, -1
    if-nez v1, :L16
    move v3, v0
    goto :L17
  :L16
    invoke-virtual { v1 }, Lteec/shell/term_shell/runtime/PtySession;->pid()I
    move-result v3
  :L17
    const-string v5, "pid"
    invoke-virtual { v2, v5, v3 }, Landroid/os/Bundle;->putInt(Ljava/lang/String;I)V
  .line 251
    if-nez v1, :L18
    goto :L19
  :L18
    invoke-virtual { v1 }, Lteec/shell/term_shell/runtime/PtySession;->exitStatus()I
    move-result v0
  :L19
    const-string v1, "exit"
    invoke-virtual { v2, v1, v0 }, Landroid/os/Bundle;->putInt(Ljava/lang/String;I)V
  .line 252
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->preflight:Lteec/shell/term_shell/runtime/RagPreflight;
    invoke-virtual { v0 }, Lteec/shell/term_shell/runtime/RagPreflight;->check()Lteec/shell/term_shell/runtime/TerminalServer$Admission;
    move-result-object v0
  .line 253
    const-string v1, "terminalAllowed"
    iget-boolean v3, v0, Lteec/shell/term_shell/runtime/TerminalServer$Admission;->terminalAllowed:Z
    invoke-virtual { v2, v1, v3 }, Landroid/os/Bundle;->putBoolean(Ljava/lang/String;Z)V
  .line 254
    const-string v1, "preflightEnabled"
    iget-boolean v3, v0, Lteec/shell/term_shell/runtime/TerminalServer$Admission;->enabled:Z
    invoke-virtual { v2, v1, v3 }, Landroid/os/Bundle;->putBoolean(Ljava/lang/String;Z)V
  .line 255
    const-string v1, "preflightReason"
    iget-object v3, v0, Lteec/shell/term_shell/runtime/TerminalServer$Admission;->reason:Ljava/lang/String;
    invoke-virtual { v2, v1, v3 }, Landroid/os/Bundle;->putString(Ljava/lang/String;Ljava/lang/String;)V
  .line 256
    iget-boolean v1, v0, Lteec/shell/term_shell/runtime/TerminalServer$Admission;->terminalAllowed:Z
    if-eqz v1, :L20
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->error:Ljava/lang/String;
    goto :L21
  :L20
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct { v1 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v3, "Preflight1: "
    invoke-virtual { v1, v3 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v1
    iget-object v0, v0, Lteec/shell/term_shell/runtime/TerminalServer$Admission;->reason:Ljava/lang/String;
    invoke-virtual { v1, v0 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual { v0 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
  :L21
    const-string v1, "runtimeError"
    invoke-virtual { v2, v1, v0 }, Landroid/os/Bundle;->putString(Ljava/lang/String;Ljava/lang/String;)V
  .line 257
    iget-object v0, p1, Landroid/os/Message;->replyTo:Landroid/os/Messenger;
    if-eqz v0, :L25
  .line 258
    const/4 v0, 0
    iget v1, p1, Landroid/os/Message;->what:I
    invoke-static { v0, v1 }, Landroid/os/Message;->obtain(Landroid/os/Handler;I)Landroid/os/Message;
    move-result-object v0
  .line 259
    iget v1, p1, Landroid/os/Message;->arg1:I
    iput v1, v0, Landroid/os/Message;->arg1:I
  .line 260
    invoke-virtual { v0, v2 }, Landroid/os/Message;->setData(Landroid/os/Bundle;)V
  :L22
  .line 261
    iget-object p1, p1, Landroid/os/Message;->replyTo:Landroid/os/Messenger;
    invoke-virtual { p1, v0 }, Landroid/os/Messenger;->send(Landroid/os/Message;)V
  :L23
  .line 262
    goto :L25
  :L24
    move-exception p1
    const-string p1, "UbuntuRuntime"
    const-string v0, "Terminalclient losgekoppeld"
    invoke-static { p1, v0 }, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
  :L25
  .line 264
    return v4
  :L26
  .packed-switch 1
    :L9
    :L7
    :L6
    :L5
    :L4
    :L3
  .end packed-switch
.end method

.method private notification(Ljava/lang/String;)Landroid/app/Notification;
  .registers 7
  .line 92
    new-instance v0, Landroid/content/Intent;
    const-class v1, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;
    invoke-direct { v0, p0, v1 }, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V
    const-string v1, "stop"
    invoke-virtual { v0, v1 }, Landroid/content/Intent;->setAction(Ljava/lang/String;)Landroid/content/Intent;
    move-result-object v0
  .line 93
    const/4 v1, 0
    const/high16 v2, 201326592
    invoke-static { p0, v1, v0, v2 }, Landroid/app/PendingIntent;->getService(Landroid/content/Context;ILandroid/content/Intent;I)Landroid/app/PendingIntent;
    move-result-object v0
  .line 94
    new-instance v1, Landroid/content/Intent;
    const-string v3, "http://0.0.0.0:8866/terminal"
    invoke-static { v3 }, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;
    move-result-object v3
    const-string v4, "android.intent.action.VIEW"
    invoke-direct { v1, v4, v3 }, Landroid/content/Intent;-><init>(Ljava/lang/String;Landroid/net/Uri;)V
  .line 95
    const/4 v3, 1
    invoke-static { p0, v3, v1, v2 }, Landroid/app/PendingIntent;->getActivity(Landroid/content/Context;ILandroid/content/Intent;I)Landroid/app/PendingIntent;
    move-result-object v1
  .line 96
    sget v2, Landroid/os/Build$VERSION;->SDK_INT:I
    const/16 v4, 26
    if-lt v2, v4, :L0
    new-instance v2, Landroid/app/Notification$Builder;
    const-string v4, "ubuntu-runtime"
    invoke-direct { v2, p0, v4 }, Landroid/app/Notification$Builder;-><init>(Landroid/content/Context;Ljava/lang/String;)V
    goto :L1
  :L0
    new-instance v2, Landroid/app/Notification$Builder;
    invoke-direct { v2, p0 }, Landroid/app/Notification$Builder;-><init>(Landroid/content/Context;)V
  :L1
  .line 97
    const v4, 17301628
    invoke-virtual { v2, v4 }, Landroid/app/Notification$Builder;->setSmallIcon(I)Landroid/app/Notification$Builder;
    move-result-object v2
    const-string v4, "T-EEC \u00b7 Ubuntu Bare"
    invoke-virtual { v2, v4 }, Landroid/app/Notification$Builder;->setContentTitle(Ljava/lang/CharSequence;)Landroid/app/Notification$Builder;
    move-result-object v2
  .line 98
    invoke-virtual { v2, p1 }, Landroid/app/Notification$Builder;->setContentText(Ljava/lang/CharSequence;)Landroid/app/Notification$Builder;
    move-result-object p1
    invoke-virtual { p1, v1 }, Landroid/app/Notification$Builder;->setContentIntent(Landroid/app/PendingIntent;)Landroid/app/Notification$Builder;
    move-result-object p1
    invoke-virtual { p1, v3 }, Landroid/app/Notification$Builder;->setOngoing(Z)Landroid/app/Notification$Builder;
    move-result-object p1
    new-instance v1, Landroid/app/Notification$Action$Builder;
    const v2, 17301560
    const-string v3, "Stop"
    invoke-direct { v1, v2, v3, v0 }, Landroid/app/Notification$Action$Builder;-><init>(ILjava/lang/CharSequence;Landroid/app/PendingIntent;)V
  .line 99
    invoke-virtual { v1 }, Landroid/app/Notification$Action$Builder;->build()Landroid/app/Notification$Action;
    move-result-object v0
    invoke-virtual { p1, v0 }, Landroid/app/Notification$Builder;->addAction(Landroid/app/Notification$Action;)Landroid/app/Notification$Builder;
    move-result-object p1
    invoke-virtual { p1 }, Landroid/app/Notification$Builder;->build()Landroid/app/Notification;
    move-result-object p1
  .line 97
    return-object p1
.end method

.method private notifyRuntime()V
  .registers 3
  .line 199
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->sshSession:Lteec/shell/term_shell/runtime/PtySession;
    if-eqz v0, :L0
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->sshSession:Lteec/shell/term_shell/runtime/PtySession;
    invoke-virtual { v0 }, Lteec/shell/term_shell/runtime/PtySession;->running()Z
    move-result v0
    if-eqz v0, :L0
    const-string v0, "Browser :8866 \u00b7 SSH :8122"
    invoke-direct { p0, v0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->notifyState(Ljava/lang/String;)V
    goto :L3
  :L0
  .line 200
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->sshError:Ljava/lang/String;
    invoke-virtual { v0 }, Ljava/lang/String;->isEmpty()Z
    move-result v0
    if-nez v0, :L1
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct { v0 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "SSH: "
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    iget-object v1, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->sshError:Ljava/lang/String;
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual { v0 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-direct { p0, v0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->notifyState(Ljava/lang/String;)V
    goto :L3
  :L1
  .line 201
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->browsers:Lteec/shell/term_shell/runtime/TerminalSessions;
    invoke-virtual { v0 }, Lteec/shell/term_shell/runtime/TerminalSessions;->running()Z
    move-result v0
    if-eqz v0, :L2
    const-string v0, "T-EEC terminal actief"
    invoke-direct { p0, v0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->notifyState(Ljava/lang/String;)V
    goto :L3
  :L2
  .line 202
    const-string v0, "T-EEC terminal afgesloten"
    invoke-direct { p0, v0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->notifyState(Ljava/lang/String;)V
  :L3
  .line 203
    return-void
.end method

.method private notifyState(Ljava/lang/String;)V
  .registers 4
  .line 103
    const-class v0, Landroid/app/NotificationManager;
    invoke-virtual { p0, v0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->getSystemService(Ljava/lang/Class;)Ljava/lang/Object;
    move-result-object v0
    check-cast v0, Landroid/app/NotificationManager;
    const/16 v1, 2204
    invoke-direct { p0, p1 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->notification(Ljava/lang/String;)Landroid/app/Notification;
    move-result-object p1
    invoke-virtual { v0, v1, p1 }, Landroid/app/NotificationManager;->notify(ILandroid/app/Notification;)V
  .line 104
    return-void
.end method

.method private pollPreflight()V
  .catch Ljava/lang/Exception; { :L2 .. :L3 } :L5
  .catch Ljava/lang/LinkageError; { :L2 .. :L3 } :L4
  .registers 5
  .line 152
    iget-boolean v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->stopping:Z
    if-eqz v0, :L0
    return-void
  :L0
  .line 153
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->preflight:Lteec/shell/term_shell/runtime/RagPreflight;
    invoke-virtual { v0 }, Lteec/shell/term_shell/runtime/RagPreflight;->check()Lteec/shell/term_shell/runtime/TerminalServer$Admission;
    move-result-object v0
  .line 154
    iget-boolean v1, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->initialTerminalPending:Z
    if-eqz v1, :L9
  .line 155
    iget-object v1, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->browsers:Lteec/shell/term_shell/runtime/TerminalSessions;
    invoke-virtual { v1 }, Lteec/shell/term_shell/runtime/TerminalSessions;->running()Z
    move-result v1
    const/4 v2, 0
    if-eqz v1, :L1
    iput-boolean v2, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->initialTerminalPending:Z
    goto :L8
  :L1
  .line 156
    iget-boolean v1, v0, Lteec/shell/term_shell/runtime/TerminalServer$Admission;->terminalAllowed:Z
    if-eqz v1, :L7
  :L2
  .line 157
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->browsers:Lteec/shell/term_shell/runtime/TerminalSessions;
    invoke-virtual { v0 }, Lteec/shell/term_shell/runtime/TerminalSessions;->create()Lteec/shell/term_shell/runtime/TerminalServer$State;
    iput-boolean v2, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->initialTerminalPending:Z
    const-string v0, ""
    iput-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->error:Ljava/lang/String;
  :L3
  .line 158
    goto :L8
  :L4
    move-exception v0
    goto :L6
  :L5
    move-exception v0
  :L6
    invoke-virtual { v0 }, Ljava/lang/Throwable;->toString()Ljava/lang/String;
    move-result-object v0
    iput-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->error:Ljava/lang/String;
    goto :L8
  :L7
  .line 159
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct { v1 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "Preflight1: "
    invoke-virtual { v1, v2 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v1
    iget-object v0, v0, Lteec/shell/term_shell/runtime/TerminalServer$Admission;->reason:Ljava/lang/String;
    invoke-virtual { v1, v0 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual { v0 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    iput-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->error:Ljava/lang/String;
  :L8
  .line 160
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->publishState()V
  .line 161
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->updateWake()V
  .line 162
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->notifyRuntime()V
  :L9
  .line 164
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->commands:Landroid/os/Handler;
    new-instance v1, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$6;
    invoke-direct { v1, p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$6;-><init>(Lteec/shell/term_shell/runtime/UbuntuRuntimeService;)V
    const-wide/16 v2, 1000
    invoke-virtual { v0, v1, v2, v3 }, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z
  .line 165
    return-void
.end method

.method private publishState()V
  .registers 4
  .line 188
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->browsers:Lteec/shell/term_shell/runtime/TerminalSessions;
    iget-object v1, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->error:Ljava/lang/String;
    invoke-virtual { v0, v1 }, Lteec/shell/term_shell/runtime/TerminalSessions;->error(Ljava/lang/String;)V
  .line 189
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->browsers:Lteec/shell/term_shell/runtime/TerminalSessions;
    iget-object v1, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->sshSession:Lteec/shell/term_shell/runtime/PtySession;
    iget-object v2, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->sshError:Ljava/lang/String;
    invoke-virtual { v0, v1, v2 }, Lteec/shell/term_shell/runtime/TerminalSessions;->ssh(Lteec/shell/term_shell/runtime/PtySession;Ljava/lang/String;)V
  .line 190
    return-void
.end method

.method private readAsset(Ljava/lang/String;)[B
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/io/IOException;
    }
  .end annotation
  .catchall { :L0 .. :L1 } :L14
  .catchall { :L2 .. :L5 } :L8
  .catchall { :L5 .. :L6 } :L14
  .catchall { :L9 .. :L10 } :L11
  .catchall { :L12 .. :L14 } :L14
  .catchall { :L15 .. :L16 } :L17
  .registers 6
  .line 206
    invoke-virtual { p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->getAssets()Landroid/content/res/AssetManager;
    move-result-object v0
    invoke-virtual { v0, p1 }, Landroid/content/res/AssetManager;->open(Ljava/lang/String;)Ljava/io/InputStream;
    move-result-object p1
  :L0
    new-instance v0, Ljava/io/ByteArrayOutputStream;
    invoke-direct { v0 }, Ljava/io/ByteArrayOutputStream;-><init>()V
  :L1
  .line 207
    const/16 v1, 16384
  :L2
    new-array v1, v1, [B
  :L3
  .line 209
    invoke-virtual { p1, v1 }, Ljava/io/InputStream;->read([B)I
    move-result v2
    const/4 v3, -1
    if-eq v2, v3, :L4
    const/4 v3, 0
    invoke-virtual { v0, v1, v3, v2 }, Ljava/io/ByteArrayOutputStream;->write([BII)V
    goto :L3
  :L4
  .line 210
    invoke-virtual { v0 }, Ljava/io/ByteArrayOutputStream;->toByteArray()[B
    move-result-object v1
  :L5
  .line 211
    invoke-virtual { v0 }, Ljava/io/ByteArrayOutputStream;->close()V
  :L6
    if-eqz p1, :L7
    invoke-virtual { p1 }, Ljava/io/InputStream;->close()V
  :L7
  .line 210
    return-object v1
  :L8
  .line 206
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
    if-eqz p1, :L18
  :L15
    invoke-virtual { p1 }, Ljava/io/InputStream;->close()V
  :L16
    goto :L18
  :L17
    move-exception p1
    invoke-virtual { v0, p1 }, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V
  :L18
    throw v0
.end method

.method private requireSession(Landroid/os/Bundle;)Lteec/shell/term_shell/runtime/PtySession;
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/io/IOException;
    }
  .end annotation
  .registers 5
  .line 268
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->browsers:Lteec/shell/term_shell/runtime/TerminalSessions;
    const-string v1, "session"
    const-string v2, ""
    invoke-virtual { p1, v1, v2 }, Landroid/os/Bundle;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object p1
    invoke-virtual { v0, p1 }, Lteec/shell/term_shell/runtime/TerminalSessions;->find(Ljava/lang/String;)Lteec/shell/term_shell/runtime/TerminalServer$State;
    move-result-object p1
  .line 269
    if-eqz p1, :L0
    iget-object v0, p1, Lteec/shell/term_shell/runtime/TerminalServer$State;->session:Lteec/shell/term_shell/runtime/PtySession;
    if-eqz v0, :L0
  .line 270
    iget-object p1, p1, Lteec/shell/term_shell/runtime/TerminalServer$State;->session:Lteec/shell/term_shell/runtime/PtySession;
    return-object p1
  :L0
  .line 269
    new-instance p1, Ljava/io/IOException;
    const-string v0, "Onbekende terminalsessie"
    invoke-direct { p1, v0 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p1
.end method

.method private shutdown()V
  .registers 2
  .line 274
    const/4 v0, 1
    iput-boolean v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->stopping:Z
  .line 275
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->web:Lteec/shell/term_shell/runtime/TerminalServer;
    if-eqz v0, :L0
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->web:Lteec/shell/term_shell/runtime/TerminalServer;
    invoke-virtual { v0 }, Lteec/shell/term_shell/runtime/TerminalServer;->close()V
  :L0
  .line 276
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->filesWorkspace:Lteec/shell/term_shell/runtime/FileWorkspace;
    if-eqz v0, :L1
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->filesWorkspace:Lteec/shell/term_shell/runtime/FileWorkspace;
    invoke-virtual { v0 }, Lteec/shell/term_shell/runtime/FileWorkspace;->close()V
  :L1
  .line 277
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->engine:Lteec/shell/term_shell/runtime/MachineEngine;
    if-eqz v0, :L2
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->engine:Lteec/shell/term_shell/runtime/MachineEngine;
    invoke-virtual { v0 }, Lteec/shell/term_shell/runtime/MachineEngine;->close()V
  :L2
  .line 278
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->rag:Lteec/shell/term_shell/runtime/SemanticRag;
    if-eqz v0, :L3
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->rag:Lteec/shell/term_shell/runtime/SemanticRag;
    invoke-virtual { v0 }, Lteec/shell/term_shell/runtime/SemanticRag;->close()V
  :L3
  .line 279
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->browsers:Lteec/shell/term_shell/runtime/TerminalSessions;
    invoke-virtual { v0 }, Lteec/shell/term_shell/runtime/TerminalSessions;->close()V
  .line 280
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->sshSession:Lteec/shell/term_shell/runtime/PtySession;
    if-eqz v0, :L4
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->sshSession:Lteec/shell/term_shell/runtime/PtySession;
    invoke-virtual { v0 }, Lteec/shell/term_shell/runtime/PtySession;->stop()V
  :L4
  .line 281
    invoke-virtual { p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->stopSelf()V
  .line 282
    return-void
.end method

.method private startSession()V
  .catch Ljava/lang/Exception; { :L0 .. :L4 } :L15
  .catch Ljava/lang/LinkageError; { :L0 .. :L4 } :L14
  .catch Ljava/lang/Exception; { :L4 .. :L5 } :L7
  .catch Ljava/lang/LinkageError; { :L4 .. :L5 } :L6
  .catch Ljava/lang/Exception; { :L8 .. :L14 } :L15
  .catch Ljava/lang/LinkageError; { :L8 .. :L14 } :L14
  .registers 9
  .line 107
    const-string v1, "UbuntuRuntime"
    iget-boolean v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->stopping:Z
    if-eqz v0, :L0
    return-void
  :L0
  .line 109
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->filesWorkspace:Lteec/shell/term_shell/runtime/FileWorkspace;
    if-nez v0, :L1
  .line 110
    new-instance v0, Lteec/shell/term_shell/runtime/ProotCommand;
    invoke-virtual { p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->getFilesDir()Ljava/io/File;
    move-result-object v2
    new-instance v3, Ljava/io/File;
    invoke-virtual { p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->getApplicationInfo()Landroid/content/pm/ApplicationInfo;
    move-result-object v4
    iget-object v4, v4, Landroid/content/pm/ApplicationInfo;->nativeLibraryDir:Ljava/lang/String;
    invoke-direct { v3, v4 }, Ljava/io/File;-><init>(Ljava/lang/String;)V
    invoke-direct { v0, v2, v3 }, Lteec/shell/term_shell/runtime/ProotCommand;-><init>(Ljava/io/File;Ljava/io/File;)V
  .line 111
    new-instance v2, Lteec/shell/term_shell/runtime/FileWorkspace;
    invoke-static { v0 }, Ljava/util/Objects;->requireNonNull(Ljava/lang/Object;)Ljava/lang/Object;
    new-instance v3, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$10;
    invoke-direct { v3, v0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$10;-><init>(Lteec/shell/term_shell/runtime/ProotCommand;)V
    const-string v0, "/host-rootfs"
    invoke-direct { v2, v3, v0 }, Lteec/shell/term_shell/runtime/FileWorkspace;-><init>(Lteec/shell/term_shell/runtime/FileWorkspace$Runner;Ljava/lang/String;)V
    iput-object v2, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->filesWorkspace:Lteec/shell/term_shell/runtime/FileWorkspace;
  :L1
  .line 113
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->engine:Lteec/shell/term_shell/runtime/MachineEngine;
    if-nez v0, :L2
  .line 114
    new-instance v0, Lteec/shell/term_shell/runtime/ProotCommand;
    invoke-virtual { p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->getFilesDir()Ljava/io/File;
    move-result-object v2
    new-instance v3, Ljava/io/File;
    invoke-virtual { p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->getApplicationInfo()Landroid/content/pm/ApplicationInfo;
    move-result-object v4
    iget-object v4, v4, Landroid/content/pm/ApplicationInfo;->nativeLibraryDir:Ljava/lang/String;
    invoke-direct { v3, v4 }, Ljava/io/File;-><init>(Ljava/lang/String;)V
    invoke-direct { v0, v2, v3 }, Lteec/shell/term_shell/runtime/ProotCommand;-><init>(Ljava/io/File;Ljava/io/File;)V
  .line 115
    new-instance v2, Lteec/shell/term_shell/runtime/MachineEngine;
    new-instance v3, Ljava/io/File;
    invoke-virtual { p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->getFilesDir()Ljava/io/File;
    move-result-object v4
    const-string v5, "ubuntu-engine"
    invoke-direct { v3, v4, v5 }, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    invoke-static { v0 }, Ljava/util/Objects;->requireNonNull(Ljava/lang/Object;)Ljava/lang/Object;
    new-instance v4, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$11;
    invoke-direct { v4, v0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$11;-><init>(Lteec/shell/term_shell/runtime/ProotCommand;)V
    invoke-direct { v2, v3, v4 }, Lteec/shell/term_shell/runtime/MachineEngine;-><init>(Ljava/io/File;Lteec/shell/term_shell/runtime/MachineEngine$Runner;)V
    iput-object v2, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->engine:Lteec/shell/term_shell/runtime/MachineEngine;
  :L2
  .line 117
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->web:Lteec/shell/term_shell/runtime/TerminalServer;
    if-nez v0, :L3
    new-instance v2, Lteec/shell/term_shell/runtime/TerminalServer;
    new-instance v4, Lteec/shell/term_shell/runtime/FrontendAssets;
    new-instance v0, Ljava/io/File;
    invoke-virtual { p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->getFilesDir()Ljava/io/File;
    move-result-object v3
    const-string v5, "Ubuntu22.04Bare/opt/t-eec/frontend"
    invoke-direct { v0, v3, v5 }, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    new-instance v3, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$12;
    invoke-direct { v3, p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$12;-><init>(Lteec/shell/term_shell/runtime/UbuntuRuntimeService;)V
    invoke-direct { v4, v0, v3 }, Lteec/shell/term_shell/runtime/FrontendAssets;-><init>(Ljava/io/File;Lteec/shell/term_shell/runtime/TerminalServer$Assets;)V
    iget-object v5, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->browsers:Lteec/shell/term_shell/runtime/TerminalSessions;
    iget-object v6, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->filesWorkspace:Lteec/shell/term_shell/runtime/FileWorkspace;
    new-instance v7, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$13;
    invoke-direct { v7, p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$13;-><init>(Lteec/shell/term_shell/runtime/UbuntuRuntimeService;)V
    const/16 v3, 8866
    invoke-direct/range { v2 .. v7 }, Lteec/shell/term_shell/runtime/TerminalServer;-><init>(ILteec/shell/term_shell/runtime/TerminalServer$Assets;Lteec/shell/term_shell/runtime/TerminalServer$Provider;Lteec/shell/term_shell/runtime/FileWorkspace;Lteec/shell/term_shell/runtime/TerminalServer$Control;)V
    iput-object v2, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->web:Lteec/shell/term_shell/runtime/TerminalServer;
  :L3
  .line 118
    invoke-virtual { p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->getFilesDir()Ljava/io/File;
    move-result-object v0
  .line 119
    invoke-static { v0 }, Lteec/shell/term_shell/runtime/UbuntuImage;->ready(Ljava/io/File;)Z
    move-result v2
    if-eqz v2, :L13
  .line 120
    new-instance v2, Lteec/shell/term_shell/runtime/ProotCommand;
    new-instance v3, Ljava/io/File;
    invoke-virtual { p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->getApplicationInfo()Landroid/content/pm/ApplicationInfo;
    move-result-object v4
    iget-object v4, v4, Landroid/content/pm/ApplicationInfo;->nativeLibraryDir:Ljava/lang/String;
    invoke-direct { v3, v4 }, Ljava/io/File;-><init>(Ljava/lang/String;)V
    invoke-direct { v2, v0, v3 }, Lteec/shell/term_shell/runtime/ProotCommand;-><init>(Ljava/io/File;Ljava/io/File;)V
  .line 121
    iget-object v3, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->rag:Lteec/shell/term_shell/runtime/SemanticRag;
    invoke-virtual { v3, p0, v2 }, Lteec/shell/term_shell/runtime/SemanticRag;->start(Landroid/content/Context;Lteec/shell/term_shell/runtime/ProotCommand;)V
  :L4
  .line 122
    invoke-direct { p0, v2, v0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->startSsh(Lteec/shell/term_shell/runtime/ProotCommand;Ljava/io/File;)V
  :L5
  .line 126
    goto :L9
  :L6
  .line 123
    move-exception v0
    goto :L8
  :L7
    move-exception v0
  :L8
  .line 124
    invoke-virtual { v0 }, Ljava/lang/Throwable;->toString()Ljava/lang/String;
    move-result-object v2
    iput-object v2, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->sshError:Ljava/lang/String;
  .line 125
    const-string v2, "SSH-start mislukt"
    invoke-static { v1, v2, v0 }, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
  :L9
  .line 127
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->browsers:Lteec/shell/term_shell/runtime/TerminalSessions;
    invoke-virtual { v0 }, Lteec/shell/term_shell/runtime/TerminalSessions;->running()Z
    move-result v0
    const/4 v2, 1
    if-nez v0, :L10
    move v0, v2
    goto :L11
  :L10
    const/4 v0, 0
  :L11
    iput-boolean v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->initialTerminalPending:Z
  .line 128
    iget-boolean v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->preflightPolling:Z
    if-nez v0, :L12
  .line 129
    iput-boolean v2, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->preflightPolling:Z
  .line 130
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->commands:Landroid/os/Handler;
    new-instance v2, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$6;
    invoke-direct { v2, p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$6;-><init>(Lteec/shell/term_shell/runtime/UbuntuRuntimeService;)V
    invoke-virtual { v0, v2 }, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z
  :L12
  .line 132
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->publishState()V
  .line 133
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->updateWake()V
  .line 134
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->notifyRuntime()V
  .line 141
    goto :L17
  :L13
  .line 119
    new-instance v0, Ljava/io/IOException;
    const-string v2, "Ubuntu Bare is nog niet ge\u00efnstalleerd"
    invoke-direct { v0, v2 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw v0
  :L14
  .line 135
    move-exception v0
    goto :L16
  :L15
    move-exception v0
  :L16
  .line 136
    invoke-virtual { v0 }, Ljava/lang/Throwable;->toString()Ljava/lang/String;
    move-result-object v2
    iput-object v2, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->error:Ljava/lang/String;
  .line 137
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->publishState()V
  .line 138
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->updateWake()V
  .line 139
    const-string v2, "Terminalstart mislukt"
    invoke-static { v1, v2, v0 }, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
  .line 140
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct { v0 }, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "Terminalstart mislukt: "
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    iget-object v1, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->error:Ljava/lang/String;
    invoke-virtual { v0, v1 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual { v0 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-direct { p0, v0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->notifyState(Ljava/lang/String;)V
  :L17
  .line 142
    return-void
.end method

.method private startSsh(Lteec/shell/term_shell/runtime/ProotCommand;Ljava/io/File;)V
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/lang/Exception;
    }
  .end annotation
  .catchall { :L1 .. :L2 } :L13
  .catchall { :L2 .. :L3 } :L7
  .catchall { :L4 .. :L5 } :L13
  .catchall { :L8 .. :L9 } :L10
  .catchall { :L11 .. :L13 } :L13
  .catchall { :L14 .. :L15 } :L16
  .registers 15
  .line 168
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->sshSession:Lteec/shell/term_shell/runtime/PtySession;
    if-eqz v0, :L0
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->sshSession:Lteec/shell/term_shell/runtime/PtySession;
    invoke-virtual { v0 }, Lteec/shell/term_shell/runtime/PtySession;->running()Z
    move-result v0
    if-eqz v0, :L0
    return-void
  :L0
  .line 169
    invoke-virtual { p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->getAssets()Landroid/content/res/AssetManager;
    move-result-object v0
    const-string v1, "linux/ssh-runtime-arm64.tar.gz"
    invoke-virtual { v0, v1 }, Landroid/content/res/AssetManager;->open(Ljava/lang/String;)Ljava/io/InputStream;
    move-result-object v1
  :L1
    invoke-virtual { p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->getAssets()Landroid/content/res/AssetManager;
    move-result-object v0
    const-string v2, "linux/ssh-authorized-key.pub"
    invoke-virtual { v0, v2 }, Landroid/content/res/AssetManager;->open(Ljava/lang/String;)Ljava/io/InputStream;
    move-result-object v2
  :L2
  .line 170
    invoke-static { v1, v2, p2 }, Lteec/shell/term_shell/runtime/UbuntuSsh;->install(Ljava/io/InputStream;Ljava/io/InputStream;Ljava/io/File;)V
  :L3
  .line 171
    if-eqz v2, :L5
  :L4
    invoke-virtual { v2 }, Ljava/io/InputStream;->close()V
  :L5
    if-eqz v1, :L6
    invoke-virtual { v1 }, Ljava/io/InputStream;->close()V
  :L6
  .line 172
    invoke-static { p1, p2 }, Lteec/shell/term_shell/runtime/UbuntuSsh;->ensureHostKey(Lteec/shell/term_shell/runtime/ProotCommand;Ljava/io/File;)V
  .line 173
    const-string v0, ""
    iput-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->sshError:Ljava/lang/String;
  .line 174
    invoke-static { }, Ljava/util/UUID;->randomUUID()Ljava/util/UUID;
    move-result-object v0
    invoke-virtual { v0 }, Ljava/util/UUID;->toString()Ljava/lang/String;
    move-result-object v0
    iput-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->sshSessionId:Ljava/lang/String;
  .line 175
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->sshSessionId:Ljava/lang/String;
  .line 176
    new-instance v1, Lteec/shell/term_shell/runtime/PtySession;
    const-string v10, "-P"
    const-string v11, "/run/dropbear.pid"
    const-string v2, "/usr/sbin/dropbear"
    const-string v3, "-F"
    const-string v4, "-E"
    const-string v5, "-s"
    const-string v6, "-p"
    const-string v7, "0.0.0.0:8122"
    const-string v8, "-r"
    const-string v9, "/etc/dropbear/dropbear_ecdsa_host_key"
    filled-new-array/range { v2 .. v11 }, [Ljava/lang/String;
    move-result-object v2
    invoke-virtual { p1, v2 }, Lteec/shell/term_shell/runtime/ProotCommand;->command([Ljava/lang/String;)[Ljava/lang/String;
    move-result-object v2
  .line 177
    invoke-virtual { p1 }, Lteec/shell/term_shell/runtime/ProotCommand;->environment()[Ljava/lang/String;
    move-result-object v3
    invoke-virtual { p2 }, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v4
    new-instance v7, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$4;
    invoke-direct { v7, p0, v0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$4;-><init>(Lteec/shell/term_shell/runtime/UbuntuRuntimeService;Ljava/lang/String;)V
    const/16 v5, 24
    const/16 v6, 80
    invoke-direct/range { v1 .. v7 }, Lteec/shell/term_shell/runtime/PtySession;-><init>([Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;IILteec/shell/term_shell/runtime/PtySession$Listener;)V
    iput-object v1, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->sshSession:Lteec/shell/term_shell/runtime/PtySession;
  .line 185
    return-void
  :L7
  .line 169
    move-exception v0
    move-object p1, v0
    if-eqz v2, :L12
  :L8
    invoke-virtual { v2 }, Ljava/io/InputStream;->close()V
  :L9
    goto :L12
  :L10
    move-exception v0
    move-object p2, v0
  :L11
    invoke-virtual { p1, p2 }, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V
  :L12
    throw p1
  :L13
    move-exception v0
    move-object p1, v0
    if-eqz v1, :L17
  :L14
    invoke-virtual { v1 }, Ljava/io/InputStream;->close()V
  :L15
    goto :L17
  :L16
    move-exception v0
    move-object p2, v0
    invoke-virtual { p1, p2 }, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V
  :L17
    throw p1
.end method

.method private updateWake()V
  .registers 3
  .line 193
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->browsers:Lteec/shell/term_shell/runtime/TerminalSessions;
    invoke-virtual { v0 }, Lteec/shell/term_shell/runtime/TerminalSessions;->running()Z
    move-result v0
    if-nez v0, :L1
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->sshSession:Lteec/shell/term_shell/runtime/PtySession;
    if-eqz v0, :L0
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->sshSession:Lteec/shell/term_shell/runtime/PtySession;
    invoke-virtual { v0 }, Lteec/shell/term_shell/runtime/PtySession;->running()Z
    move-result v0
    if-eqz v0, :L0
    goto :L1
  :L0
    const/4 v0, 0
    goto :L2
  :L1
    const/4 v0, 1
  :L2
  .line 194
    if-eqz v0, :L3
    iget-object v1, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->wake:Landroid/os/PowerManager$WakeLock;
    invoke-virtual { v1 }, Landroid/os/PowerManager$WakeLock;->isHeld()Z
    move-result v1
    if-nez v1, :L3
    iget-object v1, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->wake:Landroid/os/PowerManager$WakeLock;
    invoke-virtual { v1 }, Landroid/os/PowerManager$WakeLock;->acquire()V
  :L3
  .line 195
    if-nez v0, :L4
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->wake:Landroid/os/PowerManager$WakeLock;
    invoke-virtual { v0 }, Landroid/os/PowerManager$WakeLock;->isHeld()Z
    move-result v0
    if-eqz v0, :L4
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->wake:Landroid/os/PowerManager$WakeLock;
    invoke-virtual { v0 }, Landroid/os/PowerManager$WakeLock;->release()V
  :L4
  .line 196
    return-void
.end method

.method synthetic lambda$onCreate$0$teec-shell-term_shell-runtime-UbuntuRuntimeService(Ljava/lang/String;Lteec/shell/term_shell/runtime/PtySession$Listener;)Lteec/shell/term_shell/runtime/PtySession;
  .annotation system Ldalvik/annotation/Throws;
    value = {
      Ljava/io/IOException;
    }
  .end annotation
  .registers 13
  .line 72
    invoke-virtual { p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->getFilesDir()Ljava/io/File;
    move-result-object p1
  .line 73
    invoke-static { p1 }, Lteec/shell/term_shell/runtime/UbuntuImage;->ready(Ljava/io/File;)Z
    move-result v0
    if-eqz v0, :L0
  .line 74
    new-instance v0, Lteec/shell/term_shell/runtime/ProotCommand;
    new-instance v1, Ljava/io/File;
    invoke-virtual { p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->getApplicationInfo()Landroid/content/pm/ApplicationInfo;
    move-result-object v2
    iget-object v2, v2, Landroid/content/pm/ApplicationInfo;->nativeLibraryDir:Ljava/lang/String;
    invoke-direct { v1, v2 }, Ljava/io/File;-><init>(Ljava/lang/String;)V
    invoke-direct { v0, p1, v1 }, Lteec/shell/term_shell/runtime/ProotCommand;-><init>(Ljava/io/File;Ljava/io/File;)V
  .line 75
    new-instance v3, Lteec/shell/term_shell/runtime/PtySession;
    const-string v1, "--norc"
    const-string v2, "-i"
    const-string v4, "/bin/bash"
    const-string v5, "--noprofile"
    filled-new-array { v4, v5, v1, v2 }, [Ljava/lang/String;
    move-result-object v1
    invoke-virtual { v0, v1 }, Lteec/shell/term_shell/runtime/ProotCommand;->command([Ljava/lang/String;)[Ljava/lang/String;
    move-result-object v4
    invoke-virtual { v0 }, Lteec/shell/term_shell/runtime/ProotCommand;->environment()[Ljava/lang/String;
    move-result-object v5
    invoke-virtual { p1 }, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v6
    const/16 v7, 24
    const/16 v8, 80
    move-object v9, p2
    invoke-direct/range { v3 .. v9 }, Lteec/shell/term_shell/runtime/PtySession;-><init>([Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;IILteec/shell/term_shell/runtime/PtySession$Listener;)V
    return-object v3
  :L0
  .line 73
    new-instance p1, Ljava/io/IOException;
    const-string p2, "Ubuntu Bare is nog niet ge\u00efnstalleerd"
    invoke-direct { p1, p2 }, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw p1
.end method

.method synthetic lambda$onCreate$1$teec-shell-term_shell-runtime-UbuntuRuntimeService()V
  .registers 2
  .line 76
    iget-boolean v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->stopping:Z
    if-nez v0, :L0
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->updateWake()V
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->notifyRuntime()V
  :L0
    return-void
.end method

.method synthetic lambda$onCreate$2$teec-shell-term_shell-runtime-UbuntuRuntimeService()V
  .registers 3
  .line 76
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->commands:Landroid/os/Handler;
    new-instance v1, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$7;
    invoke-direct { v1, p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$7;-><init>(Lteec/shell/term_shell/runtime/UbuntuRuntimeService;)V
    invoke-virtual { v0, v1 }, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z
    return-void
.end method

.method synthetic lambda$onDestroy$5$teec-shell-term_shell-runtime-UbuntuRuntimeService()V
  .catch Ljava/lang/InterruptedException; { :L4 .. :L5 } :L6
  .registers 4
  .line 287
    const/4 v0, 1
    iput-boolean v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->stopping:Z
  .line 288
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->web:Lteec/shell/term_shell/runtime/TerminalServer;
    if-eqz v0, :L0
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->web:Lteec/shell/term_shell/runtime/TerminalServer;
    invoke-virtual { v0 }, Lteec/shell/term_shell/runtime/TerminalServer;->close()V
  :L0
  .line 289
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->filesWorkspace:Lteec/shell/term_shell/runtime/FileWorkspace;
    if-eqz v0, :L1
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->filesWorkspace:Lteec/shell/term_shell/runtime/FileWorkspace;
    invoke-virtual { v0 }, Lteec/shell/term_shell/runtime/FileWorkspace;->close()V
  :L1
  .line 290
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->engine:Lteec/shell/term_shell/runtime/MachineEngine;
    if-eqz v0, :L2
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->engine:Lteec/shell/term_shell/runtime/MachineEngine;
    invoke-virtual { v0 }, Lteec/shell/term_shell/runtime/MachineEngine;->close()V
  :L2
  .line 291
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->rag:Lteec/shell/term_shell/runtime/SemanticRag;
    if-eqz v0, :L3
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->rag:Lteec/shell/term_shell/runtime/SemanticRag;
    invoke-virtual { v0 }, Lteec/shell/term_shell/runtime/SemanticRag;->close()V
  :L3
  .line 292
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->browsers:Lteec/shell/term_shell/runtime/TerminalSessions;
    invoke-virtual { v0 }, Lteec/shell/term_shell/runtime/TerminalSessions;->close()V
  .line 293
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->sshSession:Lteec/shell/term_shell/runtime/PtySession;
    if-eqz v0, :L7
  .line 294
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->sshSession:Lteec/shell/term_shell/runtime/PtySession;
    invoke-virtual { v0 }, Lteec/shell/term_shell/runtime/PtySession;->stop()V
  :L4
  .line 295
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->sshSession:Lteec/shell/term_shell/runtime/PtySession;
    const-wide/16 v1, 3000
    invoke-virtual { v0, v1, v2 }, Lteec/shell/term_shell/runtime/PtySession;->join(J)V
  :L5
  .line 296
    goto :L7
  :L6
    move-exception v0
    invoke-static { }, Ljava/lang/Thread;->currentThread()Ljava/lang/Thread;
    move-result-object v0
    invoke-virtual { v0 }, Ljava/lang/Thread;->interrupt()V
  :L7
  .line 298
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->wake:Landroid/os/PowerManager$WakeLock;
    invoke-virtual { v0 }, Landroid/os/PowerManager$WakeLock;->isHeld()Z
    move-result v0
    if-eqz v0, :L8
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->wake:Landroid/os/PowerManager$WakeLock;
    invoke-virtual { v0 }, Landroid/os/PowerManager$WakeLock;->release()V
  :L8
  .line 299
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->worker:Landroid/os/HandlerThread;
    invoke-virtual { v0 }, Landroid/os/HandlerThread;->quitSafely()Z
  .line 300
    return-void
.end method

.method synthetic lambda$startSsh$3$teec-shell-term_shell-runtime-UbuntuRuntimeService(Ljava/lang/String;Ljava/lang/String;I)V
  .registers 5
  .line 179
    iget-boolean v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->stopping:Z
    if-nez v0, :L2
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->sshSessionId:Ljava/lang/String;
    invoke-virtual { v0, p1 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p1
    if-nez p1, :L0
    goto :L2
  :L0
  .line 180
    invoke-virtual { p2 }, Ljava/lang/String;->isEmpty()Z
    move-result p1
    if-eqz p1, :L1
    new-instance p1, Ljava/lang/StringBuilder;
    invoke-direct { p1 }, Ljava/lang/StringBuilder;-><init>()V
    const-string p2, "SSH afgesloten \u00b7 exit "
    invoke-virtual { p1, p2 }, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object p1
    invoke-virtual { p1, p3 }, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    move-result-object p1
    invoke-virtual { p1 }, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object p2
  :L1
    iput-object p2, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->sshError:Ljava/lang/String;
  .line 181
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->publishState()V
  .line 182
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->updateWake()V
  .line 183
    invoke-direct { p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->notifyRuntime()V
  .line 184
    return-void
  :L2
  .line 179
    return-void
.end method

.method synthetic lambda$startSsh$4$teec-shell-term_shell-runtime-UbuntuRuntimeService(Ljava/lang/String;ILjava/lang/String;)V
  .registers 6
  .line 178
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->commands:Landroid/os/Handler;
    new-instance v1, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$3;
    invoke-direct { v1, p0, p1, p3, p2 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$3;-><init>(Lteec/shell/term_shell/runtime/UbuntuRuntimeService;Ljava/lang/String;Ljava/lang/String;I)V
    invoke-virtual { v0, v1 }, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z
    return-void
.end method

.method public onBind(Landroid/content/Intent;)Landroid/os/IBinder;
  .registers 2
  .line 88
    iget-object p1, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->messenger:Landroid/os/Messenger;
    invoke-virtual { p1 }, Landroid/os/Messenger;->getBinder()Landroid/os/IBinder;
    move-result-object p1
    return-object p1
.end method

.method public onCreate()V
  .registers 6
  .line 55
    invoke-super { p0 }, Landroid/app/Service;->onCreate()V
  .line 56
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I
    const/16 v1, 26
    if-lt v0, v1, :L0
  .line 57
    const-class v0, Landroid/app/NotificationManager;
    invoke-virtual { p0, v0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->getSystemService(Ljava/lang/Class;)Ljava/lang/Object;
    move-result-object v0
    check-cast v0, Landroid/app/NotificationManager;
    new-instance v1, Landroid/app/NotificationChannel;
    const-string v2, "T-EEC terminal"
    const/4 v3, 2
    const-string v4, "ubuntu-runtime"
    invoke-direct { v1, v4, v2, v3 }, Landroid/app/NotificationChannel;-><init>(Ljava/lang/String;Ljava/lang/CharSequence;I)V
    invoke-virtual { v0, v1 }, Landroid/app/NotificationManager;->createNotificationChannel(Landroid/app/NotificationChannel;)V
  :L0
  .line 60
    const-string v0, "T-EEC terminal starten"
    invoke-direct { p0, v0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->notification(Ljava/lang/String;)Landroid/app/Notification;
    move-result-object v0
  .line 61
    sget v1, Landroid/os/Build$VERSION;->SDK_INT:I
    const/16 v2, 34
    const/16 v3, 2204
    if-lt v1, v2, :L1
    const/high16 v1, 1073741824
    invoke-virtual { p0, v3, v0, v1 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->startForeground(ILandroid/app/Notification;I)V
    goto :L2
  :L1
  .line 62
    invoke-virtual { p0, v3, v0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->startForeground(ILandroid/app/Notification;)V
  :L2
  .line 63
    const-string v0, "power"
    invoke-virtual { p0, v0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v0
    check-cast v0, Landroid/os/PowerManager;
    const/4 v1, 1
    const-string v2, "io.teec:UbuntuRuntime"
    invoke-virtual { v0, v1, v2 }, Landroid/os/PowerManager;->newWakeLock(ILjava/lang/String;)Landroid/os/PowerManager$WakeLock;
    move-result-object v0
    iput-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->wake:Landroid/os/PowerManager$WakeLock;
  .line 64
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->wake:Landroid/os/PowerManager$WakeLock;
    const/4 v1, 0
    invoke-virtual { v0, v1 }, Landroid/os/PowerManager$WakeLock;->setReferenceCounted(Z)V
  .line 65
    new-instance v0, Landroid/os/HandlerThread;
    const-string v1, "Ubuntu-runtime-commands"
    invoke-direct { v0, v1 }, Landroid/os/HandlerThread;-><init>(Ljava/lang/String;)V
    iput-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->worker:Landroid/os/HandlerThread;
  .line 66
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->worker:Landroid/os/HandlerThread;
    invoke-virtual { v0 }, Landroid/os/HandlerThread;->start()V
  .line 67
    new-instance v0, Landroid/os/Handler;
    iget-object v1, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->worker:Landroid/os/HandlerThread;
    invoke-virtual { v1 }, Landroid/os/HandlerThread;->getLooper()Landroid/os/Looper;
    move-result-object v1
    new-instance v2, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$0;
    invoke-direct { v2, p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$0;-><init>(Lteec/shell/term_shell/runtime/UbuntuRuntimeService;)V
    invoke-direct { v0, v1, v2 }, Landroid/os/Handler;-><init>(Landroid/os/Looper;Landroid/os/Handler$Callback;)V
    iput-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->commands:Landroid/os/Handler;
  .line 68
    new-instance v0, Landroid/os/Messenger;
    iget-object v1, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->commands:Landroid/os/Handler;
    invoke-direct { v0, v1 }, Landroid/os/Messenger;-><init>(Landroid/os/Handler;)V
    iput-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->messenger:Landroid/os/Messenger;
  .line 69
    new-instance v0, Lteec/shell/term_shell/runtime/SemanticRag;
    invoke-direct { v0 }, Lteec/shell/term_shell/runtime/SemanticRag;-><init>()V
    iput-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->rag:Lteec/shell/term_shell/runtime/SemanticRag;
  .line 70
    new-instance v0, Lteec/shell/term_shell/runtime/RagPreflight;
    iget-object v1, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->rag:Lteec/shell/term_shell/runtime/SemanticRag;
    invoke-direct { v0, p0, v1 }, Lteec/shell/term_shell/runtime/RagPreflight;-><init>(Landroid/content/Context;Lteec/shell/term_shell/runtime/SemanticRag;)V
    iput-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->preflight:Lteec/shell/term_shell/runtime/RagPreflight;
  .line 71
    new-instance v0, Lteec/shell/term_shell/runtime/TerminalSessions;
    new-instance v1, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$1;
    invoke-direct { v1, p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$1;-><init>(Lteec/shell/term_shell/runtime/UbuntuRuntimeService;)V
    new-instance v2, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$2;
    invoke-direct { v2, p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$2;-><init>(Lteec/shell/term_shell/runtime/UbuntuRuntimeService;)V
    iget-object v3, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->preflight:Lteec/shell/term_shell/runtime/RagPreflight;
    invoke-direct { v0, v1, v2, v3 }, Lteec/shell/term_shell/runtime/TerminalSessions;-><init>(Lteec/shell/term_shell/runtime/TerminalSessions$Factory;Ljava/lang/Runnable;Lteec/shell/term_shell/runtime/TerminalServer$Preflight;)V
    iput-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->browsers:Lteec/shell/term_shell/runtime/TerminalSessions;
  .line 77
    return-void
.end method

.method public onDestroy()V
  .registers 3
  .line 286
    iget-object v0, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->commands:Landroid/os/Handler;
    new-instance v1, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$5;
    invoke-direct { v1, p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$5;-><init>(Lteec/shell/term_shell/runtime/UbuntuRuntimeService;)V
    invoke-virtual { v0, v1 }, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z
  .line 301
    invoke-super { p0 }, Landroid/app/Service;->onDestroy()V
  .line 302
    return-void
.end method

.method public onStartCommand(Landroid/content/Intent;II)I
  .registers 4
  .line 81
    if-eqz p1, :L0
    const-string p2, "stop"
    invoke-virtual { p1 }, Landroid/content/Intent;->getAction()Ljava/lang/String;
    move-result-object p1
    invoke-virtual { p2, p1 }, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result p1
    if-eqz p1, :L0
    iget-object p1, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->commands:Landroid/os/Handler;
    new-instance p2, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$8;
    invoke-direct { p2, p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$8;-><init>(Lteec/shell/term_shell/runtime/UbuntuRuntimeService;)V
    invoke-virtual { p1, p2 }, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z
    goto :L1
  :L0
  .line 82
    iget-object p1, p0, Lteec/shell/term_shell/runtime/UbuntuRuntimeService;->commands:Landroid/os/Handler;
    new-instance p2, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$9;
    invoke-direct { p2, p0 }, Lteec/shell/term_shell/runtime/UbuntuRuntimeService$9;-><init>(Lteec/shell/term_shell/runtime/UbuntuRuntimeService;)V
    invoke-virtual { p1, p2 }, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z
  :L1
  .line 83
    const/4 p1, 2
    return p1
.end method
