.class public final Lr1/d0;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lorg/mozilla/geckoview/GeckoSession$ContentDelegate;


# instance fields
.field public final synthetic a:Lteec/shell/term_shell/Applications/SelfThemedApplication;


# direct methods
.method public constructor <init>(Lteec/shell/term_shell/Applications/SelfThemedApplication;)V
    .locals 0

    .line 1
    iput-object p1, p0, Lr1/d0;->a:Lteec/shell/term_shell/Applications/SelfThemedApplication;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public final onTitleChange(Lorg/mozilla/geckoview/GeckoSession;Ljava/lang/String;)V
    .locals 2

    .line 1
    iget-object p1, p0, Lr1/d0;->a:Lteec/shell/term_shell/Applications/SelfThemedApplication;

    .line 2
    .line 3
    iget-object p1, p1, Lteec/shell/term_shell/Applications/SelfThemedApplication;->d:La2/p;

    .line 4
    .line 5
    iget-object p1, p1, La2/i;->f:Lteec/shell/GeckoView/MyGeckoView;

    .line 6
    .line 7
    new-instance v0, Ljava/lang/StringBuilder;

    .line 8
    .line 9
    const-string v1, "document.getElementById(\'titleBar\').textContent = `"

    .line 10
    .line 11
    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    .line 12
    .line 13
    .line 14
    invoke-virtual {v0, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 15
    .line 16
    .line 17
    const-string p2, "`"

    .line 18
    .line 19
    invoke-virtual {v0, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 20
    .line 21
    .line 22
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 23
    .line 24
    .line 25
    move-result-object p2

    .line 26
    invoke-virtual {p1, p2}, Lteec/shell/GeckoView/MyGeckoView;->e(Ljava/lang/String;)V

    .line 27
    .line 28
    .line 29
    return-void
.end method
