page 9171 "Profile List"
{
    // version NAVW113.00

    ApplicationArea = Basic,Suite;
    Caption = 'Profiles';
    CardPageID = "Profile Card";
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Resource Translation';
    RefreshOnActivate = true;
    SourceTable = "All Profile";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Profile ID";"Profile ID")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Profile ID';
                    NotBlank = true;
                    ToolTip = 'Specifies the ID (name) of the profile.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Description';
                    ToolTip = 'Specifies a description of the profile.';
                }
                field(Scope;Scope)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Scope';
                    ToolTip = 'Specifies if the profile is general for the system or applies to a tenant database.';
                }
                field("App Name";"App Name")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Extension Name';
                    ToolTip = 'Specifies the name of the extension that provided the profile.';
                }
                field("Role Center ID";"Role Center ID")
                {
                    ApplicationArea = Basic,Suite;
                    BlankZero = true;
                    Caption = 'Role Center ID';
                    Lookup = false;
                    ToolTip = 'Specifies the ID of the Role Center associated with the profile.';
                }
                field("Default Role Center";"Default Role Center")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Default Role Center';
                    ToolTip = 'Specifies whether the Role Center associated with this profile is the default Role Center.';
                }
                field("Disable Personalization";"Disable Personalization")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Disable Personalization';
                    ToolTip = 'Specifies whether personalization is disabled for users of the profile.';
                }
                field("Use Record Notes";"Use Record Notes")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Use Record Notes';
                    ToolTip = 'Specifies information used by the OneNote integration feature. For more information, see How to: Set up OneNote Integration for a Group of Users.';
                    Visible = IsWindowsClient;
                }
                field("Record Notebook";"Record Notebook")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Record Notebook';
                    ToolTip = 'Specifies information used by the OneNote integration feature. For more information, see How to: Set up OneNote Integration for a Group of Users.';
                    Visible = IsWindowsClient;
                }
                field("Use Page Notes";"Use Page Notes")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Use Page Notes';
                    ToolTip = 'Specifies information used by the OneNote integration feature. For more information, see How to: Set up OneNote Integration for a Group of Users.';
                    Visible = IsWindowsClient;
                }
                field("Page Notebook";"Page Notebook")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Page Notebook';
                    ToolTip = 'Specifies information used by the OneNote integration feature. For more information, see How to: Set up OneNote Integration for a Group of Users.';
                    Visible = IsWindowsClient;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207;Links)
            {
                Visible = false;
            }
            systempart(Control1905767507;Notes)
            {
                Visible = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action(SetDefaultRoleCenter)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Set Default Role Center';
                    Image = Default;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Specify that this Role Center will open by default when the user starts the client.';
                    Visible = NOT IsSaaS;

                    trigger OnAction()
                    var
                        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
                    begin
                        TestField("Profile ID");
                        TestField("Role Center ID");
                        Validate("Default Role Center",true);
                        Modify;
                        ConfPersonalizationMgt.ChangeDefaultRoleCenter(Rec);
                    end;
                }
                action("Copy Profile")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Copy Profile';
                    Ellipsis = true;
                    Image = Copy;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Copy an existing profile to create a new profile based on the same content.';

                    trigger OnAction()
                    var
                        "Profile": Record "All Profile";
                        CopyProfile: Report "Copy Profile";
                    begin
                        Profile.SetRange("Profile ID","Profile ID");
                        CopyProfile.SetTableView(Profile);
                        CopyProfile.RunModal;

                        if Get(Profile.Scope,Profile."App ID",CopyProfile.GetProfileID) then;
                    end;
                }
                action("Import Profile")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Import Profile';
                    Ellipsis = true;
                    Enabled = Scope = Scope::System;
                    Image = Import;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Implement UI configurations for a profile by importing an XML file that holds the configured profile.';
                    Visible = NOT IsSaaS;

                    trigger OnAction()
                    begin
                        Commit;
                        REPORT.RunModal(REPORT::"Import Profiles",false);
                        Commit;
                    end;
                }
                action(ExportProfiles)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Export Profiles';
                    Enabled = Scope = Scope::System;
                    Image = Export;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Export a profile, for example to reuse UI configurations in other Dynamics 365 databases.';
                    Visible = NOT IsSaaS;

                    trigger OnAction()
                    var
                        "Profile": Record "All Profile";
                        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
                    begin
                        AlertIfTenantProfileSelected;
                        CurrPage.SetSelectionFilter(Profile);
                        Profile.SetRange(Scope,Profile.Scope::System);
                        ConfPersonalizationMgt.ExportProfilesInZipFile(Profile);
                    end;
                }
            }
            group("Resource Translation")
            {
                Caption = 'Resource Translation';
                action("Import Translated Profile Resources From Folder")
                {
                    ApplicationArea = All;
                    Caption = 'Import Translated Profile Resources From Folder';
                    Ellipsis = true;
                    Enabled = Scope = Scope::System;
                    Image = Language;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ToolTip = 'Import the translated profile data into the profile from a folder.';
                    Visible = CanRunDotNetOnClient AND (NOT IsSaaS);

                    trigger OnAction()
                    var
                        ProfileRec: Record "All Profile";
                        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
                    begin
                        AlertIfTenantProfileSelected;
                        CurrPage.SetSelectionFilter(ProfileRec);
                        ConfPersonalizationMgt.ImportTranslatedResourcesWithFolderSelection(ProfileRec);
                    end;
                }
                action("Import Translated Profile Resources From Zip File")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Import Translated Profile Resources From Zip File';
                    Ellipsis = true;
                    Enabled = Scope = Scope::System;
                    Image = Language;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ToolTip = 'Import the translated profile data into the profile from a Zip file.';
                    Visible = NOT IsSaaS;

                    trigger OnAction()
                    var
                        ProfileRec: Record "All Profile";
                        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
                    begin
                        AlertIfTenantProfileSelected;
                        CurrPage.SetSelectionFilter(ProfileRec);
                        ConfPersonalizationMgt.ImportTranslatedResources(ProfileRec,'',true);
                    end;
                }
                action("Export Translated Profile Resources")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Export Translated Profile Resources';
                    Ellipsis = true;
                    Enabled = Scope = Scope::System;
                    Image = ExportAttachment;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ToolTip = 'Prepare to perform customized translation of profiles by exporting and importing resource (.resx) files.';
                    Visible = NOT IsSaaS;

                    trigger OnAction()
                    var
                        ProfileRec: Record "All Profile";
                        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
                    begin
                        AlertIfTenantProfileSelected;
                        CurrPage.SetSelectionFilter(ProfileRec);
                        ProfileRec.SetRange(Scope,ProfileRec.Scope::System);
                        ConfPersonalizationMgt.ExportTranslatedResourcesWithFolderSelection(ProfileRec);
                    end;
                }
                action("Remove Translated Profile Resources")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Remove Translated Profile Resources';
                    Ellipsis = true;
                    Enabled = Scope = Scope::System;
                    Image = RemoveLine;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ToolTip = 'Remove the translated resource from the profile.';
                    Visible = NOT IsSaaS;

                    trigger OnAction()
                    var
                        ProfileRec: Record "All Profile";
                        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
                    begin
                        AlertIfTenantProfileSelected;
                        CurrPage.SetSelectionFilter(ProfileRec);
                        ProfileRec.SetRange(Scope,ProfileRec.Scope::System);
                        ConfPersonalizationMgt.RemoveTranslatedResourcesWithLanguageSelection(ProfileRec);
                    end;
                }
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        exit(FindFirstAllowedRec(Which));
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin
        exit(FindNextAllowedRec(Steps));
    end;

    trigger OnOpenPage()
    var
        FileManagement: Codeunit "File Management";
        PermissionManager: Codeunit "Permission Manager";
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
    begin
        CanRunDotNetOnClient := FileManagement.CanRunDotNetOnClient;
        RoleCenterSubtype := RoleCenterTxt;
        IsSaaS := PermissionManager.SoftwareAsAService;
        IsWindowsClient := CurrentClientType = CLIENTTYPE::Windows;
        ConfPersonalizationMgt.HideSandboxProfiles(Rec);
    end;

    var
        CanRunDotNetOnClient: Boolean;
        RoleCenterSubtype: Text;
        RoleCenterTxt: Label 'RoleCenter', Locked=true;
        ListContainsTenantProfilesErr: Label 'Tenant Profiles does not support this action. Please remove any Tenant Profiles from selection and try again.';
        IsSaaS: Boolean;
        IsWindowsClient: Boolean;

    [Scope('Personalization')]
    procedure FindFirstAllowedRec(Which: Text[1024]): Boolean
    begin
        if Find(Which) then
          repeat
            if RoleCenterExist("Role Center ID") then
              exit(true);
          until Next = 0;
        exit(false);
    end;

    [Scope('Personalization')]
    procedure FindNextAllowedRec(Steps: Integer): Integer
    var
        ProfileBrowser: Record "All Profile";
        RealSteps: Integer;
        NextSteps: Integer;
    begin
        RealSteps := 0;
        if Steps <> 0 then begin
          ProfileBrowser := Rec;
          repeat
            NextSteps := Next(Steps / Abs(Steps));
            if RoleCenterExist("Role Center ID") then begin
              RealSteps := RealSteps + NextSteps;
              ProfileBrowser := Rec;
            end;
          until (NextSteps = 0) or (RealSteps = Steps);
          Rec := ProfileBrowser;
          if not Find then ;
        end;
        exit(RealSteps);
    end;

    local procedure RoleCenterExist(PageID: Integer): Boolean
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if (PageID = PAGE::"O365 Sales Activities RC") or (PageID = PAGE::"O365 Invoicing RC") then
          exit(false);
        AllObjWithCaption.SetRange("Object Type",AllObjWithCaption."Object Type"::Page);
        AllObjWithCaption.SetRange("Object Subtype",RoleCenterSubtype);
        AllObjWithCaption.SetRange("Object ID",PageID);
        exit(not AllObjWithCaption.IsEmpty);
    end;

    local procedure IsTenantProfileSelected(): Boolean
    var
        "Profile": Record "All Profile";
    begin
        CurrPage.SetSelectionFilter(Profile);
        Profile.SetRange(Scope,Profile.Scope::Tenant);
        if Profile.FindFirst then
          exit(true);
        exit(false);
    end;

    local procedure AlertIfTenantProfileSelected()
    begin
        if IsTenantProfileSelected then
          Error(ListContainsTenantProfilesErr);
    end;
}

