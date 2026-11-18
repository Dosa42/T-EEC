.class public final Lr1/h;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lorg/mozilla/geckoview/GeckoSession$ProgressDelegate;


# instance fields
.field public final synthetic a:Lteec/shell/term_shell/Applications/BrowserApplication;


# direct methods
.method public constructor <init>(Lteec/shell/term_shell/Applications/BrowserApplication;)V
    .locals 0

    .line 1
    iput-object p1, p0, Lr1/h;->a:Lteec/shell/term_shell/Applications/BrowserApplication;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public final onPageStart(Lorg/mozilla/geckoview/GeckoSession;Ljava/lang/String;)V
    .locals 0

    .line 1
    sget-object p1, Lteec/shell/term_shell/Applications/BrowserApplication;->v:Ljava/lang/String;

    iget-object p1, p0, Lr1/h;->a:Lteec/shell/term_shell/Applications/BrowserApplication;

    const/4 p2, 0x1

    invoke-virtual {p1, p2}, Lteec/shell/term_shell/Applications/BrowserApplication;->k(Z)V

    return-void
.end method

.method public final onPageStop(Lorg/mozilla/geckoview/GeckoSession;Z)V
    .locals 0

    .line 1
    sget-object p1, Lteec/shell/term_shell/Applications/BrowserApplication;->v:Ljava/lang/String;

    iget-object p1, p0, Lr1/h;->a:Lteec/shell/term_shell/Applications/BrowserApplication;

    const/4 p2, 0x0

    invoke-virtual {p1, p2}, Lteec/shell/term_shell/Applications/BrowserApplication;->k(Z)V

    return-void
.end method

.method public final onProgressChange(Lorg/mozilla/geckoview/GeckoSession;I)V
    .locals 0

    .line 1
    return-void
.end method
