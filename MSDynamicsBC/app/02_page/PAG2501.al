page 2501 "Extension Details"
{
    // version NAVW113.00

    Caption = 'Extension Details';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = NavigatePage;
    SourceTable = "NAV App";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group("Install NAV Extension")
            {
                Caption = 'Install Extension';
                Editable = false;
                Visible = Step1Enabled;
                group(InstallGroup)
                {
                    Caption = 'Install Extension';
                    Editable = false;
                    InstructionalText = 'Extensions add new capabilities that extend and enhance functionality.';
                    field(In_Name;Name)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Name';
                    }
                    field(In_Des;AppDescription)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Description';
                        Editable = false;
                        MultiLine = true;
                    }
                    field(In_Ver;VersionDisplay)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Version';
                    }
                    field(In_Pub;Publisher)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Publisher';
                    }
                    field(In_Id;AppIdDisplay)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'App ID';
                    }
                    field(In_Url;UrlLbl)
                    {
                        ApplicationArea = Basic,Suite;
                        Editable = false;
                        ShowCaption = false;

                        trigger OnDrillDown()
                        begin
                            HyperLink(Url);
                        end;
                    }
                    field(In_Help;HelpLbl)
                    {
                        ApplicationArea = Basic,Suite;
                        Editable = false;
                        ShowCaption = false;

                        trigger OnDrillDown()
                        begin
                            HyperLink(Help);
                        end;
                    }
                }
            }
            group("Uninstall NAV Extension")
            {
                Caption = 'Uninstall Extension';
                Visible = IsInstalled;
                group(UninstallGroup)
                {
                    Caption = 'Uninstall Extension';
                    Editable = false;
                    InstructionalText = 'Uninstall extension to remove added features.';
                    field(Un_Name;Name)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Name';
                    }
                    field(Un_Des;AppDescription)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Description';
                        Editable = false;
                        MultiLine = true;
                    }
                    field(Un_Ver;VersionDisplay)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Version';
                    }
                    field(Un_Pub;Publisher)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Publisher';
                    }
                    field(Un_Id;AppIdDisplay)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'App ID';
                    }
                    field(Un_Terms;TermsLbl)
                    {
                        ApplicationArea = Basic,Suite;
                        Editable = false;
                        ShowCaption = false;
                        Visible = Legal;

                        trigger OnDrillDown()
                        var
                            PermissionManager: Codeunit "Permission Manager";
                        begin
                            if PermissionManager.SoftwareAsAService then
                              if EULA = OnPremEULALbl then
                                EULA := SaaSEULALbl;
                            HyperLink(EULA);
                        end;
                    }
                    field(Un_Privacy;PrivacyLbl)
                    {
                        ApplicationArea = Basic,Suite;
                        Editable = false;
                        ShowCaption = false;
                        Visible = Legal;

                        trigger OnDrillDown()
                        var
                            PermissionManager: Codeunit "Permission Manager";
                        begin
                            if PermissionManager.SoftwareAsAService then
                              if "Privacy Statement" = OnPremPrivacyLbl then
                                "Privacy Statement" := SaaSPrivacyLbl;
                            HyperLink("Privacy Statement");
                        end;
                    }
                    field(Un_Url;UrlLbl)
                    {
                        ApplicationArea = Basic,Suite;
                        Editable = false;
                        ShowCaption = false;

                        trigger OnDrillDown()
                        begin
                            HyperLink(Url);
                        end;
                    }
                    field(Un_Help;HelpLbl)
                    {
                        ApplicationArea = Basic,Suite;
                        Editable = false;
                        ShowCaption = false;

                        trigger OnDrillDown()
                        begin
                            HyperLink(Help);
                        end;
                    }
                }
            }
            group(Installation)
            {
                Caption = 'Installation';
                Visible = BackEnabled;
                group("Review Extension Information before installation")
                {
                    Caption = 'Review Extension Information before installation';
                    field(Name;Name)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Name';
                        Editable = false;
                    }
                    field(Publisher;Publisher)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Publisher';
                        Editable = false;
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
                    group(Control30)
                    {
                        ShowCaption = false;
                        Visible = Legal;
                        field(Terms;TermsLbl)
                        {
                            ApplicationArea = Basic,Suite;
                            Editable = false;
                            ShowCaption = false;

                            trigger OnDrillDown()
                            begin
                                HyperLink(EULA);
                            end;
                        }
                        field(Privacy;PrivacyLbl)
                        {
                            ApplicationArea = Basic,Suite;
                            Editable = false;
                            ShowCaption = false;

                            trigger OnDrillDown()
                            begin
                                HyperLink("Privacy Statement");
                            end;
                        }
                        field(Accepted;Accepted)
                        {
                            ApplicationArea = Basic,Suite;
                            Caption = 'I accept the terms and conditions';
                        }
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Back)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Back';
                Image = PreviousRecord;
                InFooterBar = true;
                Visible = BackEnabled;

                trigger OnAction()
                begin
                    BackEnabled := false;
                    NextEnabled := true;
                    Step1Enabled := true;
                    InstallEnabled := false;
                end;
            }
            action(Next)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Next';
                Image = NextRecord;
                InFooterBar = true;
                Visible = NextEnabled;

                trigger OnAction()
                begin
                    BackEnabled := true;
                    NextEnabled := false;
                    Step1Enabled := false;
                    InstallEnabled := true;
                end;
            }
            action(Install)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Install';
                Enabled = Accepted;
                Image = Approve;
                InFooterBar = true;
                Visible = InstallEnabled;

                trigger OnAction()
                var
                    Dependencies: Text;
                    CanChange: Boolean;
                begin
                    CanChange := NavExtensionInstallationMgmt.IsInstalled("Package ID");

                    if CanChange then begin
                      Message(StrSubstNo(AlreadyInstalledMsg,Name));
                      exit;
                    end;

                    Dependencies := NavExtensionInstallationMgmt.GetDependenciesForExtensionToInstall("Package ID");
                    CanChange := (StrLen(Dependencies) = 0);

                    if not CanChange then
                      CanChange := Confirm(StrSubstNo(DependenciesFoundQst,Name,Dependencies),false);

                    if CanChange then
                      NavExtensionInstallationMgmt.InstallNavExtension("Package ID",LanguageID);

                    // If successfully installed, message users to restart activity for menusuites
                    if NavExtensionInstallationMgmt.IsInstalled("Package ID") then
                      Message(StrSubstNo(RestartActivityInstallMsg,Name));

                    CurrPage.Close;
                end;
            }
            action(Uninstall)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Uninstall';
                Image = Approve;
                InFooterBar = true;
                Visible = IsInstalled;

                trigger OnAction()
                var
                    Dependents: Text;
                    CanChange: Boolean;
                begin
                    CanChange := NavExtensionInstallationMgmt.IsInstalled("Package ID");
                    if not CanChange then
                      Message(StrSubstNo(AlreadyUninstalledMsg,Name));

                    Dependents := NavExtensionInstallationMgmt.GetDependentForExtensionToUninstall("Package ID");
                    CanChange := (StrLen(Dependents) = 0);
                    if not CanChange then
                      CanChange := Confirm(StrSubstNo(DependentsFoundQst,Name,Dependents),false);

                    if CanChange then
                      NavExtensionInstallationMgmt.UninstallNavExtension("Package ID");

                    // If successfully uninstalled, message users to restart activity for menusuites
                    if not NavExtensionInstallationMgmt.IsInstalled("Package ID") then
                      Message(StrSubstNo(RestartActivityUninstallMsg,Name));

                    CurrPage.Close;
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        WinLanguagesTable: Record "Windows Language";
    begin
        NavAppTable.SetFilter("Package ID",'%1',"Package ID");
        if not NavAppTable.FindFirst then
          CurrPage.Close;

        SetNavAppRecord;

        IsInstalled := NavExtensionInstallationMgmt.IsInstalled("Package ID");
        if IsInstalled then
          CurrPage.Caption(UninstallationPageCaptionMsg)
        else
          CurrPage.Caption(InstallationPageCaptionMsg);

        // Any legal info to display
        Legal := ((StrLen("Privacy Statement") <> 0) or (StrLen(EULA) <> 0));

        // Next only enabled if legal info is found
        NextEnabled := not IsInstalled;

        // Step1 enabled if installing
        Step1Enabled := not IsInstalled;

        // Auto accept if no legal info
        Accepted := not Legal;

        LanguageID := GlobalLanguage;
        WinLanguagesTable.SetRange("Language ID",LanguageID);
        if WinLanguagesTable.FindFirst then
          LanguageName := WinLanguagesTable.Name;
    end;

    var
        NavAppTable: Record "NAV App";
        NavExtensionInstallationMgmt: Codeunit NavExtensionInstallationMgmt;
        AppDescription: BigText;
        AppIdDisplay: Text;
        VersionDisplay: Text;
        LanguageName: Text;
        BackEnabled: Boolean;
        NextEnabled: Boolean;
        InstallEnabled: Boolean;
        Accepted: Boolean;
        IsInstalled: Boolean;
        Legal: Boolean;
        Step1Enabled: Boolean;
        DependenciesFoundQst: Label 'The extension %1 has a dependency on one or more extensions: %2. \ \Do you wish to install %1 and all of its dependencies?', Comment='%1=name of app, %2=semicolon separated list of uninstalled dependencies';
        DependentsFoundQst: Label 'The extension %1 is a dependency for on or more extensions: %2. \ \Do you wish to uninstall %1 and all of its dependents?', Comment='%1=name of app, %2=semicolon separated list of installed dependents';
        AlreadyInstalledMsg: Label 'The extension %1 is already installed.', Comment='%1=name of app';
        AlreadyUninstalledMsg: Label 'The extension %1 is not installed.', Comment='%1=name of app';
        InstallationPageCaptionMsg: Label 'Extension Installation', Comment='Caption for when extension needs to be installed';
        RestartActivityInstallMsg: Label 'The %1 extension was successfully installed. All active users must log out and log in again to see the navigation changes.', Comment='Indicates that users need to restart their activity to pick up new menusuite items. %1=Name of Extension';
        RestartActivityUninstallMsg: Label 'The %1 extension was successfully uninstalled. All active users must log out and log in again to see the navigation changes.', Comment='Indicates that users need to restart their activity to pick up new menusuite items. %1=Name of Extension';
        UninstallationPageCaptionMsg: Label 'Extension Uninstallation', Comment='Caption for when extension needs to be uninstalled';
        LanguageNotFoundErr: Label 'Language %1 does not exist, or is not enabled globally and contains a localization. Use the lookup to select a language.', Comment='Error message to notify user that the entered language was not found. This could mean that the language doesn''t exist or that the language is not valid within the filter set for the lookup. %1=Entered value.';
        TermsLbl: Label 'Terms and Conditions';
        PrivacyLbl: Label 'Privacy Statement', Comment='Label for privacy statement link';
        UrlLbl: Label 'Website';
        HelpLbl: Label 'Help';
        LanguageID: Integer;
        SaaSEULALbl: Label ' https://go.microsoft.com/fwlink/?linkid=834880', Locked=true;
        SaaSPrivacyLbl: Label 'https://go.microsoft.com/fwlink/?linkid=834881', Locked=true;
        OnPremEULALbl: Label 'https://go.microsoft.com/fwlink/?LinkId=724010', Locked=true;
        OnPremPrivacyLbl: Label 'https://go.microsoft.com/fwlink/?LinkId=724009', Locked=true;

    local procedure SetNavAppRecord()
    var
        DescriptionStream: InStream;
    begin
        "Package ID" := NavAppTable."Package ID";
        ID := NavAppTable.ID;
        AppIdDisplay := LowerCase(DelChr(Format(ID),'=','{}'));
        Name := NavAppTable.Name;
        Publisher := NavAppTable.Publisher;
        VersionDisplay :=
          NavExtensionInstallationMgmt.GetVersionDisplayString(
            NavAppTable."Version Major",NavAppTable."Version Minor",
            NavAppTable."Version Build",NavAppTable."Version Revision");
        NavAppTable.CalcFields(Description);
        NavAppTable.Description.CreateInStream(DescriptionStream,TEXTENCODING::UTF8);
        AppDescription.Read(DescriptionStream);
        Url := NavAppTable.Url;
        Help := NavAppTable.Help;
        "Privacy Statement" := NavAppTable."Privacy Statement";
        EULA := NavAppTable.EULA;
        Insert;
    end;
}

