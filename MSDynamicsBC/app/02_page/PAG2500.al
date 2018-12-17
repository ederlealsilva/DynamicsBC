page 2500 "Extension Management"
{
    // version NAVW113.00

    ApplicationArea = Basic,Suite;
    Caption = 'Extension Management';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Details,Manage';
    RefreshOnActivate = true;
    SourceTable = "NAV App";
    SourceTableView = SORTING(Name)
                      ORDER(Ascending)
                      WHERE(Name=FILTER(<>'_Exclude_*'),
                            "Package Type"=FILTER(=0|2));
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Editable = false;
                field(Logo;Logo)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Logo';
                    ToolTip = 'Specifies the logo of the extension, such as the logo of the service provider.';
                }
                field(AdditionalInfo;PublisherOrStatus)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'AdditionalInfo';
                    Style = Favorable;
                    StyleExpr = Style;
                    ToolTip = 'Specifies the person or company that created the extension.';
                }
                field(Name;Name)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the name of the extension.';
                }
                field(Control18;'')
                {
                    ApplicationArea = Basic,Suite;
                    Enabled = IsSaaS;
                    HideValue = true;
                    ShowCaption = false;
                    Style = Favorable;
                    StyleExpr = TRUE;
                    ToolTip = 'Specifies a spacer for ''Brick'' view mode.';
                    Visible = NOT IsOnPremDisplay;
                }
                field(Version;VersionDisplay)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Version';
                    ToolTip = 'Specifies the version of the extension.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(ActionGroup13)
            {
                Enabled = false;
                Visible = false;
                action(Install)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Install';
                    Enabled = ActionsEnabled AND IsOnPremDisplay;
                    Image = NewRow;
                    Promoted = true;
                    PromotedCategory = Category5;
                    Scope = Repeater;
                    ToolTip = 'Install the extension for the current tenant.';
                    Visible = IsOnPremDisplay OR IsSaaSInstallAllowed;

                    trigger OnAction()
                    begin
                        if NavExtensionInstallationMgmt.IsInstalled("Package ID") then begin
                          Message(AlreadyInstalledMsg,Name);
                          exit;
                        end;

                        RunOldExtensionInstallation;
                    end;
                }
                action(Uninstall)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Uninstall';
                    Enabled = ActionsEnabled;
                    Image = RemoveLine;
                    Promoted = true;
                    PromotedCategory = Category5;
                    Scope = Repeater;
                    ToolTip = 'Remove the extension from the current tenant.';

                    trigger OnAction()
                    begin
                        if not NavExtensionInstallationMgmt.IsInstalled("Package ID") then begin
                          Message(AlreadyUninstalledMsg,Name);
                          exit;
                        end;

                        RunOldExtensionInstallation;
                    end;
                }
                action(Unpublish)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Unpublish';
                    Enabled = ActionsEnabled;
                    Image = RemoveLine;
                    Promoted = true;
                    PromotedCategory = Category5;
                    Scope = Repeater;
                    ToolTip = 'Unpublish the extension from the tenant.';
                    Visible = IsTenantExtension;

                    trigger OnAction()
                    begin
                        if NavExtensionInstallationMgmt.IsInstalled("Package ID") then begin
                          Message(CannotUnpublishIfInstalledMsg,Name);
                          exit;
                        end;

                        NavExtensionInstallationMgmt.UnpublishNavTenantExtension("Package ID");
                    end;
                }
                action(Configure)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Configure';
                    Image = Setup;
                    Promoted = true;
                    PromotedCategory = Category5;
                    RunObject = Page "Extension Settings";
                    RunPageLink = "App ID"=FIELD(ID);
                    Scope = Repeater;
                    ToolTip = 'Configure the extension.';
                }
                action("Download Source")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Download Source';
                    Enabled = IsTenantExtension AND "Show My Code";
                    Image = ExportFile;
                    Promoted = true;
                    PromotedCategory = Category5;
                    Scope = Repeater;
                    ToolTip = 'Download the source code for the extension.';

                    trigger OnAction()
                    var
                        TempBlob: Record TempBlob;
                        FileManagement: Codeunit "File Management";
                        DotNet_NavDesignerALFunctions: Codeunit DotNet_NavDesignerALFunctions;
                        NvOutStream: OutStream;
                        FileName: Text;
                        VersionString: Text;
                        CleanFileName: Text;
                    begin
                        TempBlob.Blob.CreateOutStream(NvOutStream);
                        VersionString :=
                          NavExtensionInstallationMgmt.GetVersionDisplayString("Version Major","Version Minor","Version Build","Version Revision");

                        DotNet_NavDesignerALFunctions.GenerateDesignerPackageZipStreamByVersion(NvOutStream,ID,VersionString);
                        FileName := StrSubstNo(ExtensionFileNameTxt,Name,Publisher,VersionString);
                        CleanFileName := DotNet_NavDesignerALFunctions.SanitizeDesignerFileName(FileName,'_');
                        FileManagement.BLOBExport(TempBlob,CleanFileName,true);
                    end;
                }
                action(LearnMore)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Learn More';
                    Enabled = ActionsEnabled;
                    Image = Info;
                    Promoted = true;
                    PromotedCategory = Category5;
                    Scope = Repeater;
                    ToolTip = 'View information from the extension provider.';

                    trigger OnAction()
                    begin
                        HyperLink(Help);
                    end;
                }
                action(Refresh)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Refresh';
                    Image = RefreshLines;
                    Promoted = true;
                    PromotedCategory = Category5;
                    ToolTip = 'Refresh the list of extensions.';

                    trigger OnAction()
                    begin
                        ActionsEnabled := false;
                        CurrPage.Update(false);
                    end;
                }
                action("Extension Marketplace")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Extension Marketplace';
                    Enabled = IsSaaS;
                    Image = NewItem;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    ToolTip = 'Browse the extension marketplace for new extensions to install.';
                    Visible = NOT IsOnPremDisplay;

                    trigger OnAction()
                    var
                        DotNet_AppSource: Codeunit DotNet_AppSource;
                    begin
                        if DotNet_AppSource.IsAvailable then begin
                          DotNet_AppSource.Create;
                          DotNet_AppSource.ShowAppSource;
                        end;
                    end;
                }
                action("Upload Extension")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Upload Extension';
                    Image = Import;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    RunObject = Page "Upload And Deploy Extension";
                    ToolTip = 'Upload an extension to your application.';
                    Visible = IsSaaS AND NOT IsSandbox;
                }
                action("Deployment Status")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Deployment Status';
                    Image = View;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    RunObject = Page "Extension Deployment Status";
                    ToolTip = 'Check status for upload process for extensions.';
                    Visible = IsSaaS AND NOT IsSandbox;
                }
            }
            group(Manage)
            {
                Caption = 'Manage';
                action(View)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'View';
                    Enabled = ActionsEnabled;
                    Image = View;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ShortCutKey = 'Return';
                    ToolTip = 'View extension details.';
                    Visible = NOT IsSaaS;

                    trigger OnAction()
                    begin
                        RunOldExtensionInstallation;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        IsInstalled: Boolean;
        InstalledStatus: Text[250];
    begin
        ActionsEnabled := true;
        IsInstalled := NavExtensionInstallationMgmt.IsInstalled("Package ID");
        InstalledStatus := NavExtensionInstallationMgmt.GetExtensionInstalledDisplayString("Package ID");

        VersionDisplay :=
          StrSubstNo(
            VersionFormatTxt,
            NavExtensionInstallationMgmt.GetVersionDisplayString("Version Major","Version Minor","Version Build","Version Revision"));
        // Currently using the "Tenant ID" field to identify development extensions
        IsTenantExtension := Scope = 1;

        Style := false;
        PublisherOrStatus := Publisher;

        // Set Name styling if on prem display (shows green)
        if IsOnPremDisplay or IsSaaSInstallAllowed then begin
          PublisherOrStatus := InstalledStatus;
          Style := IsInstalled;
        end;

        // Adding a '- NotInstalled' if in SaaS for PerTenant extensions
        if IsSaaS and IsTenantExtension and not IsInstalled then
          VersionDisplay := StrSubstNo(PerTenantAppendTxt,VersionDisplay,InstalledStatus);
    end;

    trigger OnOpenPage()
    begin
        SetExtensionManagementFilter;
        if not (IsOnPremDisplay or IsSaaSInstallAllowed) then
          CurrPage.Caption(SaaSCaptionTxt);
        ActionsEnabled := false;
    end;

    var
        VersionFormatTxt: Label 'v. %1', Comment='v=version abbr, %1=Version string';
        NavExtensionInstallationMgmt: Codeunit NavExtensionInstallationMgmt;
        PublisherOrStatus: Text;
        VersionDisplay: Text;
        ActionsEnabled: Boolean;
        IsSaaS: Boolean;
        SaaSCaptionTxt: Label 'Installed Extensions', Comment='The caption to display when on SaaS';
        Style: Boolean;
        ExtensionFileNameTxt: Label '%1_%2_%3.zip', Comment='{Locked};%1=Name, %2=Publisher, %3=Version';
        AlreadyInstalledMsg: Label 'The extension %1 is already installed.', Comment='%1 = name of extension';
        AlreadyUninstalledMsg: Label 'The extension %1 is not installed.', Comment='%1 = name of extension.';
        IsSaaSInstallAllowed: Boolean;
        IsTenantExtension: Boolean;
        CannotUnpublishIfInstalledMsg: Label 'The extension %1 cannot be unpublished because it is installed.', Comment='%1 = name of extension';
        IsMarketplaceEnabled: Boolean;
        IsOnPremDisplay: Boolean;
        PerTenantAppendTxt: Label '%1 - %2', Comment='{Locked};%1=formatted version string, %2=not installed constant';
        IsSandbox: Boolean;

    local procedure RunOldExtensionInstallation()
    var
        ExtensionDetails: Page "Extension Details";
    begin
        ExtensionDetails.SetRecord(Rec);
        ExtensionDetails.Run;
        if ExtensionDetails.Editable = false then
          CurrPage.Update;
    end;

    local procedure GetSaaSInstallSetting(): Boolean
    var
        ServerConfigSettingHandler: Codeunit "Server Config. Setting Handler";
        InstallAllowed: Boolean;
    begin
        InstallAllowed := ServerConfigSettingHandler.GetEnableSaaSExtensionInstallSetting;
        exit(InstallAllowed);
    end;

    local procedure SetExtensionManagementFilter()
    var
        PermissionManager: Codeunit "Permission Manager";
        ExtensionMarketplaceMgmt: Codeunit ExtensionMarketplaceMgmt;
    begin
        IsSaaS := PermissionManager.SoftwareAsAService;
        IsSandbox := PermissionManager.IsSandboxConfiguration;
        IsSaaSInstallAllowed := IsSandbox or GetSaaSInstallSetting;
        IsMarketplaceEnabled := ExtensionMarketplaceMgmt.IsMarketplaceEnabled;

        // Extension should be displayed as if they were on prem
        IsOnPremDisplay := (not IsMarketplaceEnabled or not IsSaaS);

        // Set installed filter if we are not displaying like on-prem
        if not (IsOnPremDisplay or IsSaaSInstallAllowed) then
          SetFilter("PerTenant Or Installed",'%1',true)
        else
          SetFilter("Tenant Visible",'%1',true);
    end;
}

