page 6302 "Azure AD Access Dialog"
{
    // version NAVW111.00

    Caption = 'AZURE ACTIVE DIRECTORY SERVICE PERMISSIONS';
    PageType = NavigatePage;

    layout
    {
        area(content)
        {
            field(Para0;'')
            {
                ApplicationArea = Basic,Suite;
                Caption = 'The functionality you have selected to use requires services from Azure Active Directory to access your system.';
            }
            field(Para1;'')
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Before you can begin using this functionality, you must first grant access to these services.  To grant access, choose the ''Authorize Azure Services''  link.';
            }
            usercontrol(OAuthIntegration;"Microsoft.Dynamics.Nav.Client.OAuthIntegration")
            {
                ApplicationArea = Basic,Suite;
            }
            field(Para2;'')
            {
                ApplicationArea = Basic,Suite;
                Caption = '';
                ShowCaption = false;
            }
            field(Para3;'')
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Azure Active Directory Services:';
                Style = Strong;
                StyleExpr = TRUE;
            }
            field(Para4;ResourceFriendlyName)
            {
                ApplicationArea = Basic,Suite;
                Editable = false;
                ShowCaption = false;
                Visible = ResourceFriendlyName <> '';
            }
        }
    }

    actions
    {
    }

    var
        AzureAdMgt: Codeunit "Azure AD Mgt.";
        FileManagement: Codeunit "File Management";
        AuthCode: Text;
        ResourceUrl: Text;
        AuthorizationTxt: Label 'Error occurred while trying to authorize with Azure Active Directory. Please try again or contact your system administrator if error persist.';
        ResourceFriendlyName: Text;
        CloseWindowMsg: Label 'Authorization sucessful. Close the window to proceed.';
        LinkNameTxt: Label 'Authorize Azure Services';
        LinkTooltipTxt: Label 'You will be redirected to the authorization provider in a different browser instance.';

    [Scope('Personalization')]
    procedure GetAuthorizationCode(Resource: Text;ResourceName: Text): Text
    begin
        ResourceUrl := Resource;
        ResourceFriendlyName := ResourceName;
        CurrPage.Update;
        if not AzureAdMgt.IsAzureADAppSetupDone then begin
          PAGE.RunModal(PAGE::"Azure AD App Setup Wizard");
          if not AzureAdMgt.IsAzureADAppSetupDone then
            exit('');
        end;

        CurrPage.RunModal;
        exit(AuthCode);
    end;

    local procedure ThrowError()
    begin
        if FileManagement.IsWindowsClient then
          Message(AuthorizationTxt)
        else
          Error(AuthorizationTxt)
    end;

    [IntegrationEvent(false, false)]
    procedure OnOAuthAccessDenied(description: Text;resourceFriendlyName: Text)
    begin
    end;
}

