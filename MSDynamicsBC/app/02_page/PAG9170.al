page 9170 "Profile Card"
{
    // version NAVW113.00

    Caption = 'Profile Card';
    DataCaptionExpression = "Profile ID" + ' ' + Description;
    PageType = Card;
    PromotedActionCategories = 'New,Process,Report,Resource Translation';
    SourceTable = "All Profile";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                Editable = (NOT IsSaaS) OR ((Scope = Scope::Tenant) AND IsSaaS);
                group(Control24)
                {
                    ShowCaption = false;
                    field(Scope;Scope)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Scope';
                        Enabled = IsNewProfile AND NOT (IsSaaS);
                        ToolTip = 'Specifies if the profile is general for the system or applies to a tenant database.';
                    }
                    field("App Name";"App Name")
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Extension Name';
                        Enabled = false;
                        ToolTip = 'Specifies the name of the extension that provided the profile.';
                    }
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
                    field("Role Center ID";"Role Center ID")
                    {
                        ApplicationArea = Basic,Suite;
                        BlankZero = true;
                        Caption = 'Role Center ID';
                        ToolTip = 'Specifies the ID of the Role Center associated with the profile.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            AllObjWithCaption: Record AllObjWithCaption;
                            AllObjectsWithCaption: Page "All Objects with Caption";
                        begin
                            AllObjWithCaption.SetRange("Object Type",AllObjWithCaption."Object Type"::Page);
                            AllObjWithCaption.SetRange("Object Subtype",RoleCenterSubtype);
                            AllObjectsWithCaption.SetTableView(AllObjWithCaption);

                            if AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Page,"Role Center ID") then
                              AllObjectsWithCaption.SetRecord(AllObjWithCaption);

                            AllObjectsWithCaption.LookupMode := true;
                            if AllObjectsWithCaption.RunModal = ACTION::LookupOK then begin
                              AllObjectsWithCaption.GetRecord(AllObjWithCaption);
                              Validate("Role Center ID",AllObjWithCaption."Object ID");
                            end;
                        end;

                        trigger OnValidate()
                        var
                            AllObjWithCaption: Record AllObjWithCaption;
                        begin
                            if "Default Role Center" then
                              TestField("Role Center ID");

                            AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Page,"Role Center ID");
                            AllObjWithCaption.TestField("Object Subtype",RoleCenterSubtype);
                        end;
                    }
                    field("Default Role Center";"Default Role Center")
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Default Role Center';
                        Enabled = NOT IsSaaS;
                        ToolTip = 'Specifies whether the Role Center associated with this profile is the default Role Center.';

                        trigger OnValidate()
                        begin
                            TestField("Profile ID");
                            TestField("Role Center ID");
                        end;
                    }
                    field("Disable Personalization";"Disable Personalization")
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Disable Personalization';
                        ToolTip = 'Specifies whether personalization is disabled for users of the profile.';
                    }
                }
                group(OneNote)
                {
                    Caption = 'OneNote';
                    Enabled = Scope = Scope::System;
                    Visible = IsWindowsClient;
                    field("Use Record Notes";"Use Record Notes")
                    {
                        ApplicationArea = Basic,Suite;
                        ToolTip = 'Specifies information used by the OneNote integration feature. For more information, see How to: Set up OneNote Integration for a Group of Users.';
                    }
                    field("Record Notebook";"Record Notebook")
                    {
                        ApplicationArea = Basic,Suite;
                        ToolTip = 'Specifies information used by the OneNote integration feature. For more information, see How to: Set up OneNote Integration for a Group of Users.';
                    }
                    field("Use Page Notes";"Use Page Notes")
                    {
                        ApplicationArea = Basic,Suite;
                        ToolTip = 'Specifies information used by the OneNote integration feature. For more information, see How to: Set up OneNote Integration for a Group of Users.';
                    }
                    field("Page Notebook";"Page Notebook")
                    {
                        ApplicationArea = Basic,Suite;
                        ToolTip = 'Specifies information used by the OneNote integration feature. For more information, see How to: Set up OneNote Integration for a Group of Users.';
                    }
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
        area(navigation)
        {
            group("&Profile")
            {
                Caption = '&Profile';
                Image = User;
                action(List)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'List';
                    Image = OpportunitiesList;
                    ShortCutKey = 'Shift+Ctrl+L';
                    ToolTip = 'View a list of all profiles.';

                    trigger OnAction()
                    var
                        ProfileList: Page "Profile List";
                    begin
                        ProfileList.LookupMode := true;
                        ProfileList.SetRecord(Rec);
                        if ProfileList.RunModal = ACTION::LookupOK then
                          ProfileList.GetRecord(Rec);
                    end;
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Copy Profile")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Copy Profile';
                    Ellipsis = true;
                    Image = Copy;
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
                action("C&lear Configured Pages")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'C&lear Configured Pages';
                    Enabled = Scope = Scope::System;
                    Image = Cancel;
                    ToolTip = 'Delete all configurations that are made for the profile.';
                    Visible = NOT IsSaaS;

                    trigger OnAction()
                    begin
                        ConfPersonalizationMgt.ClearProfileConfiguration(Rec);
                    end;
                }
                separator(Separator50)
                {
                }
                action("E&xport Profiles")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'E&xport Profiles';
                    Ellipsis = true;
                    Enabled = Scope = Scope::System;
                    Image = Export;
                    ToolTip = 'Export a profile, for example to reuse UI configurations in other Dynamics 365 databases.';
                    Visible = NOT IsSaaS;

                    trigger OnAction()
                    var
                        "Profile": Record "All Profile";
                    begin
                        Profile.SetRange("Profile ID","Profile ID");
                        REPORT.Run(REPORT::"Export Profiles",true,false,Profile);
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
                        "Profile": Record "All Profile";
                        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
                    begin
                        Profile.SetRange("Profile ID","Profile ID");
                        ConfPersonalizationMgt.ImportTranslatedResourcesWithFolderSelection(Profile);
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
                        "Profile": Record "All Profile";
                        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
                    begin
                        Profile.SetRange("Profile ID","Profile ID");
                        ConfPersonalizationMgt.ImportTranslatedResources(Profile,'',true);
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
                        "Profile": Record "All Profile";
                        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
                    begin
                        Profile.SetRange("Profile ID","Profile ID");
                        Profile.SetRange(Scope,Profile.Scope::System);
                        ConfPersonalizationMgt.ExportTranslatedResourcesWithFolderSelection(Profile);
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
                        "Profile": Record "All Profile";
                        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
                    begin
                        CurrPage.SetSelectionFilter(Profile);
                        Profile.SetRange(Scope,Profile.Scope::System);
                        ConfPersonalizationMgt.RemoveTranslatedResourcesWithLanguageSelection(Profile);
                    end;
                }
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    begin
        ConfPersonalizationMgt.ValidateDeleteProfile(Rec);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if "Default Role Center" then
          ConfPersonalizationMgt.ChangeDefaultRoleCenter(Rec);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if "Default Role Center" then
          ConfPersonalizationMgt.ChangeDefaultRoleCenter(Rec);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if IsSaaS then
          Scope := Scope::Tenant;
    end;

    trigger OnOpenPage()
    var
        FileManagement: Codeunit "File Management";
        PermissionManager: Codeunit "Permission Manager";
    begin
        RoleCenterSubtype := RoleCenterTxt;
        CanRunDotNetOnClient := FileManagement.CanRunDotNetOnClient;
        IsSaaS := PermissionManager.SoftwareAsAService;
        IsWindowsClient := CurrentClientType = CLIENTTYPE::Windows;
        if "Profile ID" = '' then
          IsNewProfile := true;
    end;

    var
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
        RoleCenterSubtype: Text[30];
        RoleCenterTxt: Label 'RoleCenter', Locked=true;
        CanRunDotNetOnClient: Boolean;
        IsNewProfile: Boolean;
        IsSaaS: Boolean;
        IsWindowsClient: Boolean;
}

