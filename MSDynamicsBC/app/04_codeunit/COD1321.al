codeunit 1321 "Getting Started Mgt."
{
    // version NAVW111.00


    trigger OnRun()
    begin
        if IsGettingStartedVisible then
          DisableGettingStartedForCurrentUser
        else
          EnableGettingStartedForCurrentUser;

        Message(GettingStartedRefreshThePageMsg);
    end;

    var
        GettingStartedRefreshThePageMsg: Label 'Refresh the page to see the change.';
        WelcomePageTxt: Label 'Welcome!';
        SettingUpYourSystemPageTxt: Label 'Setting up Your System';
        ForwardLinkMgt: Codeunit "Forward Link Mgt.";
        ClientTypeManagement: Codeunit ClientTypeManagement;

    local procedure EnableGettingStartedForCurrentUser()
    var
        UserPreference: Record "User Preference";
    begin
        UserPreference.EnableInstruction(GetGettingStartedCode);
    end;

    local procedure DisableGettingStartedForCurrentUser()
    var
        UserPreference: Record "User Preference";
    begin
        UserPreference.DisableInstruction(GetGettingStartedCode);
    end;

    [Scope('Personalization')]
    procedure IsGettingStartedVisible(): Boolean
    var
        UserPreference: Record "User Preference";
    begin
        exit(not UserPreference.Get(UserId,GetGettingStartedCode) and NotDevice);
    end;

    [Scope('Personalization')]
    procedure PlayWelcomeVideoOnFirstLogin()
    begin
        if ShouldWelcomeVideoBePlayed then begin
          SetWelcomeVideoPlayed;
          PlayWelcomeVideoForWebClient;
        end;
    end;

    [Scope('Personalization')]
    procedure PlayWelcomeVideoForWebClient()
    begin
        PlayVideo(WelcomePageTxt,
          ForwardLinkMgt.GetLanguageSpecificUrl('https://go.microsoft.com/fwlink/?LinkID=506729'));
    end;

    [Scope('Personalization')]
    procedure PlaySettingUpYourSystemVideoForWebClient()
    begin
        PlayVideo(SettingUpYourSystemPageTxt,
          ForwardLinkMgt.GetLanguageSpecificUrl('https://go.microsoft.com/fwlink/?LinkID=506736'));
    end;

    [Scope('Personalization')]
    procedure PlaySettingUpYourSystemVideoForTablet()
    begin
        PlayVideoTablet(
          SettingUpYourSystemPageTxt,
          ForwardLinkMgt.GetLanguageSpecificUrl('https://go.microsoft.com/fwlink/?LinkID=506791'),
          ForwardLinkMgt.GetLanguageSpecificUrl('https://go.microsoft.com/fwlink/?LinkID=507484'));
    end;

    local procedure PlayVideo(PageCaption: Text;Src: Text)
    var
        VideoPlayerPage: Page "Video Player Page";
        Height: Integer;
        Width: Integer;
    begin
        Height := 415;
        Width := 740;

        VideoPlayerPage.SetParameters(Height,Width,Src,PageCaption);
        VideoPlayerPage.Run;
    end;

    local procedure PlayVideoTablet(PageCaption: Text;Src: Text;SrcLink: Text)
    var
        VideoPlayerPageTablet: Page "Video Player Page Tablet";
        Height: Integer;
        Width: Integer;
    begin
        Height := 415;
        Width := 740;

        VideoPlayerPageTablet.SetParameters(Height,Width,Src,SrcLink,PageCaption);
        VideoPlayerPageTablet.Run;
    end;

    [Scope('Personalization')]
    procedure ShouldWelcomeVideoBePlayed(): Boolean
    var
        UserPreference: Record "User Preference";
    begin
        exit(not UserPreference.Get(UserId,GetWelcomeVideoCode));
    end;

    local procedure SetWelcomeVideoPlayed()
    var
        UserPreference: Record "User Preference";
    begin
        UserPreference.DisableInstruction(GetWelcomeVideoCode);
    end;

    local procedure GetGettingStartedCode(): Code[20]
    begin
        exit('GETTINGSTARTED');
    end;

    local procedure GetWelcomeVideoCode(): Code[20]
    begin
        exit('WELCOMEVIDEOPLAYED');
    end;

    local procedure NotDevice(): Boolean
    begin
        exit(not (ClientTypeManagement.GetCurrentClientType in [CLIENTTYPE::Tablet,CLIENTTYPE::Phone]));
    end;
}

