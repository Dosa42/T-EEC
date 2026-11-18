.class public final synthetic Lr1/z;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Ln1/m;


# instance fields
.field public final synthetic a:Lteec/shell/term_shell/Applications/SelfThemedApplication;

.field public final synthetic b:Z


# direct methods
.method public synthetic constructor <init>(Lteec/shell/term_shell/Applications/SelfThemedApplication;Z)V
    .locals 0

    .line 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lr1/z;->a:Lteec/shell/term_shell/Applications/SelfThemedApplication;

    iput-boolean p2, p0, Lr1/z;->b:Z

    return-void
.end method


# virtual methods
.method public final a(Ljava/lang/String;)Z
    .locals 2

    .line 1
    iget-object v0, p0, Lr1/z;->a:Lteec/shell/term_shell/Applications/SelfThemedApplication;

    .line 2
    .line 3
    invoke-virtual {v0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    .line 4
    .line 5
    .line 6
    const-string v1, "Page started"

    .line 7
    .line 8
    invoke-virtual {p1, v1}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    .line 9
    .line 10
    .line 11
    move-result p1

    .line 12
    if-eqz p1, :cond_0

    .line 13
    .line 14
    iget-boolean p1, p0, Lr1/z;->b:Z

    .line 15
    .line 16
    if-eqz p1, :cond_0

    .line 17
    .line 18
    iget-object p1, v0, Lteec/shell/term_shell/Applications/SelfThemedApplication;->d:La2/p;

    .line 19
    .line 20
    iget-object p1, p1, La2/i;->f:Lteec/shell/GeckoView/MyGeckoView;

    .line 21
    .line 22
    const-string v0, "EnableCloseButton"

    .line 23
    .line 24
    invoke-virtual {p1, v0}, Lteec/shell/GeckoView/MyGeckoView;->g(Ljava/lang/String;)V

    .line 25
    .line 26
    .line 27
    :cond_0
    const/4 p1, 0x0

    .line 28
    return p1
.end method
