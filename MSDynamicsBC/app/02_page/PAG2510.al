page 2510 "Marketplace Extn. Deployment"
{
    // version NAVW113.00

    Caption = 'Extension Installation';
    PageType = NavigatePage;

    layout
    {
        area(content)
        {
            group(General)
            {
            }
            field("Choose Language";'')
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Choose Language';
                Style = StandardAccent;
                StyleExpr = TRUE;
            }
            field(Language;LanguageName)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Language';

                trigger OnLookup(var Text: Text): Boolean
                var
                    WinLanguagesTable: Record "Windows Language";
                begin
                    WinLanguagesTable.SetRange("Globally Enabled",true);
                    WinLanguagesTable.SetRange("Localization Exist",true);
                    if PAGE.RunModal(PAGE::"Windows Languages",WinLanguagesTable) = ACTION::LookupOK then begin
                      LanguageID := WinLanguagesTable."Language ID";
                      LanguageName := WinLanguagesTable.Name;
                    end;
                end;

                trigger OnValidate()
                var
                    WinLanguagesTable: Record "Windows Language";
                begin
                    WinLanguagesTable.SetRange(Name,LanguageName);
                    WinLanguagesTable.SetRange("Globally Enabled",true);
                    WinLanguagesTable.SetRange("Localization Exist",true);
                    if WinLanguagesTable.FindFirst then
                      LanguageID := WinLanguagesTable."Language ID"
                    else
                      Error(LanguageNotFoundErr,LanguageName);
                end;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Install)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Install';
                InFooterBar = true;

                trigger OnAction()
                var
                    NavAppTable: Record "NAV App";
                    NavExtensionInstallationMgmt: Codeunit NavExtensionInstallationMgmt;
                    NavExtensionOperationMgmt: Codeunit NavExtensionOperationMgmt;
                    ExtensionNotFound: Boolean;
                begin
                    NavAppTable.SetFilter(ID,'%1',ExtensionAppId);
                    ExtensionNotFound := not NavAppTable.FindFirst;

                    if ExtensionNotFound then begin
                      // If extension not found sent the request to regional service
                      NavExtensionOperationMgmt.DeployNavExtension(ExtensionAppId,LanguageID);
                      Message(OperationProgressMsg);
                      CurrPage.Close;
                      exit;
                    end;

                    // If extension found then check whether it is third party or first party extension
                    if NavExtensionInstallationMgmt.IsInstalledByAppId(ExtensionAppId) then begin
                      CurrPage.Close;
                      Message(StrSubstNo(AlreadyInstalledMsg,NavAppTable.Name));
                      exit;
                    end;

                    // If first party extension install it locally
                    if NavAppTable.Publisher = 'Microsoft' then
                      InstallApp(ExtensionAppId)
                    else begin
                      // If extension found but is third party then send the request to regional service
                      NavExtensionOperationMgmt.DeployNavExtension(ExtensionAppId,LanguageID);
                      Message(OperationProgressMsg);
                    end;

                    CurrPage.Close;
                    exit;
                end;
            }
        }
    }

    trigger OnInit()
    var
        WinLanguagesTable: Record "Windows Language";
    begin
        LanguageID := GlobalLanguage;
        WinLanguagesTable.SetRange("Language ID",LanguageID);
        if WinLanguagesTable.FindFirst then
          LanguageName := WinLanguagesTable.Name;
    end;

    var
        LanguageName: Text;
        LanguageID: Integer;
        LanguageNotFoundErr: Label 'Cannot find the specified language, %1. Choose the lookup button to select a language.', Comment='Error message to notify user that the entered language was not found. This could mean that the language doesn''t exist or that the language is not valid within the filter set for the lookup. %1=Entered value.';
        ExtensionAppId: Guid;
        OperationProgressMsg: Label 'Extension installation is in progress. Please check the status page for updates.';
        TelemetryUrl: Text;
        AlreadyInstalledMsg: Label 'The extension %1 is already installed.', Comment='%1=name of app';
        DependenciesFoundQst: Label 'The extension %1 has a dependency on one or more extensions: %2.\\Do you wish to install %1 and all of its dependencies?', Comment='%1=name of app, %2=semicolon separated list of uninstalled dependencies';
        OperationResult: Option UserNotAuthorized,DeploymentFailedDueToPackage,DeploymentFailed,Successful,UserCancel,UserTimeOut;
        RestartActivityInstallMsg: Label 'The extension %1 was successfully installed. All active users must log out and log in again to see the navigation changes.', Comment='Indicates that users need to restart their activity to pick up new menusuite items. %1=Name of Extension';

    procedure SetAppIDAndTelemetryUrl(AppID: Guid;Url: Text)
    begin
        ExtensionAppId := AppID;
        TelemetryUrl := Url;
    end;

    local procedure MakeTelemetryCallback(Result: Option UserNotAuthorized,DeploymentFailedDueToPackage,DeploymentFailed,Successful,UserCancel,UserTimeOut;PackageId: Guid)
    var
        ExtensionMarketplaceMgmt: Codeunit ExtensionMarketplaceMgmt;
    begin
        if TelemetryUrl <> '' then
          ExtensionMarketplaceMgmt.MakeMarketplaceTelemetryCallback(TelemetryUrl,Result,PackageId);
    end;

    local procedure InstallApp(AppId: Guid)
    var
        NAVAppTable: Record "NAV App";
        NavExtensionInstallationMgmt: Codeunit NavExtensionInstallationMgmt;
        Dependencies: Text;
        CanChange: Boolean;
        Result: Option;
    begin
        NAVAppTable.SetRange("Package ID",NavExtensionInstallationMgmt.GetLatestVersionPackageId(AppId));
        NAVAppTable.FindFirst;

        Dependencies := NavExtensionInstallationMgmt.GetDependenciesForExtensionToInstall(NAVAppTable."Package ID");
        CanChange := (StrLen(Dependencies) = 0);

        if not CanChange then
          CanChange := Confirm(StrSubstNo(DependenciesFoundQst,NAVAppTable.Name,Dependencies),false);

        Result := OperationResult::Successful;
        if CanChange then begin
          NavExtensionInstallationMgmt.InstallNavExtension(NAVAppTable."Package ID",LanguageID);

          // If successfully installed, message users to restart activity for menusuites
          if NavExtensionInstallationMgmt.IsInstalled(NAVAppTable."Package ID") then
            Message(StrSubstNo(RestartActivityInstallMsg,NAVAppTable.Name))
          else
            Result := OperationResult::DeploymentFailedDueToPackage;
        end;

        MakeTelemetryCallback(Result,NAVAppTable."Package ID");
    end;
}

