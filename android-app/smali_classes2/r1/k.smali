.class public final Lr1/k;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Ln1/m;


# instance fields
.field public final synthetic a:Lteec/shell/GeckoView/MyGeckoView;

.field public final synthetic b:Lteec/shell/term_shell/Applications/FileManagerApplication;


# direct methods
.method public constructor <init>(Lteec/shell/term_shell/Applications/FileManagerApplication;Lteec/shell/GeckoView/MyGeckoView;)V
    .locals 0

    .line 1
    iput-object p1, p0, Lr1/k;->b:Lteec/shell/term_shell/Applications/FileManagerApplication;

    iput-object p2, p0, Lr1/k;->a:Lteec/shell/GeckoView/MyGeckoView;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public final a(Ljava/lang/String;)Z
    .locals 1

    .line 1
    const-string v0, "FileManager initialized"

    .line 2
    .line 3
    invoke-virtual {p1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 4
    .line 5
    .line 6
    move-result p1

    .line 7
    if-nez p1, :cond_0

    .line 8
    .line 9
    const/4 p1, 0x0

    .line 10
    return p1

    .line 11
    :cond_0
    sget-object p1, Lteec/shell/term_shell/Applications/FileManagerApplication;->h:Ljava/lang/String;

    .line 12
    .line 13
    iget-object p1, p0, Lr1/k;->b:Lteec/shell/term_shell/Applications/FileManagerApplication;

    .line 14
    .line 15
    const/4 v0, 0x0

    .line 16
    invoke-virtual {p1, v0}, Lteec/shell/term_shell/Applications/FileManagerApplication;->e(Ljava/lang/String;)V

    .line 17
    .line 18
    .line 19
    iget-object p1, p0, Lr1/k;->a:Lteec/shell/GeckoView/MyGeckoView;

    .line 20
    .line 21
    iget-object p1, p1, Lteec/shell/GeckoView/MyGeckoView;->j:Ljava/util/ArrayList;

    .line 22
    .line 23
    invoke-virtual {p1, p0}, Ljava/util/ArrayList;->remove(Ljava/lang/Object;)Z

    .line 24
    .line 25
    .line 26
    const/4 p1, 0x1

    .line 27
    return p1
.end method
