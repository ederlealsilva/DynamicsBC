page 1309 "O365 Getting Started"
{
    // version NAVW113.00

    Caption = 'Trial Experience';
    PageType = NavigatePage;
    SourceTable = "O365 Getting Started";

    layout
    {
        area(content)
        {
            group(Control3)
            {
                ShowCaption = false;
                Visible = CurrentPage;
                group(Control4)
                {
                    ShowCaption = false;
                    usercontrol(WelcomeWizard;"Microsoft.Dynamics.Nav.Client.WelcomeWizard")
                    {
                        ApplicationArea = Basic,Suite;
                    }
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Get Started")
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Get Started';
                InFooterBar = true;
                Promoted = true;

                trigger OnAction()
                var
                    UserPersonalization: Record "User Personalization";
                    AllProfile: Record "All Profile";
                    ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
                    SessionSet: SessionSettings;
                begin
                    if ConfPersonalizationMgt.IsCurrentProfile(ChangedProfileScope,ChangedProfileAppID,ChangedProfileID) then
                      CurrPage.Close;

                    if RoleCenterOverview.GetAcceptAction then begin
                      if not AllProfile.Get(ChangedProfileScope,ChangedProfileAppID,ChangedProfileID) then
                        CurrPage.Close;

                      ConfPersonalizationMgt.SetCurrentProfile(AllProfile);
                      UserPersonalization.Get(UserSecurityId);

                      with SessionSet do begin
                        Init;
                        ProfileId := ChangedProfileID;
                        ProfileAppId := UserPersonalization."App ID";
                        ProfileSystemScope := UserPersonalization.Scope = UserPersonalization.Scope::System;
                        LanguageId := UserPersonalization."Language ID";
                        LocaleId := UserPersonalization."Locale ID";
                        Timezone := UserPersonalization."Time Zone";
                        RequestSessionUpdate(true);
                      end;
                    end;

                    CurrPage.Close;
                end;
            }
        }
    }

    trigger OnClosePage()
    begin
        "Tour in Progress" := false;
        "Tour Completed" := true;
        Modify;
    end;

    trigger OnInit()
    var
        AllProfile: Record "All Profile";
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
    begin
        SetRange("User ID",UserId);
        CurrProfileID := ConfPersonalizationMgt.GetCurrentProfileIDNoError;

        if CurrProfileID <> '' then
          AllProfile.SetRange("Profile ID",CurrProfileID);

        if not AllProfile.FindFirst then
          exit;

        CurrProfileID := AllProfile."Profile ID";
        ChangedProfileID := AllProfile."Profile ID";
    end;

    trigger OnOpenPage()
    begin
        if not AlreadyShown then
          MarkAsShown;

        CurrentPage := true;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
    begin
        if (ConfPersonalizationMgt.GetCurrentProfileIDNoError <> ChangedProfileID) and RoleCenterOverview.GetAcceptAction then
          if not Confirm(RoleNotSavedQst) then
            Error('');
    end;

    var
        RoleCenterOverview: Page "Role Center Overview";
        CurrProfileID: Code[30];
        ChangedProfileID: Code[30];
        RoleNotSavedQst: Label 'Your choice of role center is not saved. Are you sure you want to close?';
        TitleTxt: Label 'Welcome to %1', Comment='%1 is the branding PRODUCTNAME.MARKETING string constant';
        SubTitleTxt: Label 'Let''s get started';
        ExplanationTxt: Label 'Start with basic business processes, or jump right in to advanced operations. Use our %1 demo company and data, or create a new company and import your own data.', Comment='%1 - This is the COMPANYNAME. ex. Cronus US Inc.';
        IntroTxt: Label 'Introduction';
        IntroDescTxt: Label 'Get to know Business Central';
        GetStartedTxt: Label 'Get Started';
        GetStartedDescTxt: Label 'See the important first steps';
        FindHelpTxt: Label 'Get Assistance';
        FindHelpDescTxt: Label 'Know where to go for information';
        RoleCentersTxt: Label 'Role Centers';
        RoleCentersDescTxt: Label 'Explore different business roles';
        ChangedProfileAppID: Guid;
        ChangedProfileScope: Option;
        CurrentPage: Boolean;
        LegalDescriptionTxt: Label 'Demo data is provided for demonstration purposes only and should be used only for evaluation, training and test systems.';

    [Scope('Personalization')]
    procedure GetNextPageID(Increment: Integer;CurrentPageID: Integer) NextPageID: Integer
    begin
        NextPageID := CurrentPageID + Increment;
    end;

    local procedure GetProfileDescription(): Text[250]
    var
        AllProfile: Record "All Profile";
    begin
        AllProfile.SetRange(Scope,AllProfile.Scope::System);
        AllProfile.SetFilter("Profile ID",ChangedProfileID);
        if AllProfile.FindFirst then
          exit(AllProfile.Description);
    end;
}

