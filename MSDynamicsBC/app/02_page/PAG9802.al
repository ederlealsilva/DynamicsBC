page 9802 "Permission Sets"
{
    // version NAVW113.00

    ApplicationArea = Basic,Suite;
    Caption = 'Permission Sets';
    DelayedInsert = true;
    PageType = List;
    Permissions = TableData "Permission Set Link"=d,
                  TableData "Aggregate Permission Set"=rimd;
    SourceTable = "Permission Set Buffer";
    SourceTableTemporary = true;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = 'Permission Set';
                field(PermissionSet;"Role ID")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Permission Set';
                    Editable = IsPermissionSetEditable;
                    ToolTip = 'Specifies the permission set.';
                }
                field(Name;Name)
                {
                    ApplicationArea = Basic,Suite;
                    Editable = IsPermissionSetEditable;
                    ToolTip = 'Specifies the name of the record.';
                }
                field(Type;Type)
                {
                    ApplicationArea = Basic,Suite;
                    Editable = false;
                    Enabled = false;
                }
                field("App Name";"App Name")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Extension Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of the extension.';
                }
            }
        }
        area(factboxes)
        {
            part("System Permissions";"Permissions FactBox")
            {
                ApplicationArea = Basic,Suite;
                Caption = 'System Permissions';
                Editable = false;
                SubPageLink = "Role ID"=FIELD("Role ID");
            }
            part("Tenant Permissions";"Tenant Permissions FactBox")
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Tenant Permissions';
                Editable = false;
                SubPageLink = "Role ID"=FIELD("Role ID"),
                              "App ID"=FIELD("App ID");
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(ShowPermissions)
            {
                Caption = 'Permissions';
                Image = Permission;
                action(Permissions)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Permissions';
                    Image = Permission;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Scope = Repeater;
                    ShortCutKey = 'Shift+Ctrl+p';
                    ToolTip = 'View or edit which feature objects users need to access, and set up the related permissions in permission sets that you can assign to the users of the database.';

                    trigger OnAction()
                    var
                        PermissionPagesMgt: Codeunit "Permission Pages Mgt.";
                    begin
                        PermissionPagesMgt.ShowPermissions(Scope,"App ID","Role ID",false);
                    end;
                }
                action("Permission Set by User")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Permission Set by User';
                    Image = Permission;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Permission Set by User";
                    ToolTip = 'View or edit the available permission sets and apply permission sets to existing users.';
                }
                action("Permission Set by User Group")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Permission Set by User Group';
                    Image = Permission;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Permission Set by User Group";
                    ToolTip = 'View or edit the available permission sets and apply permission sets to existing user groups.';
                }
            }
            group("User Groups")
            {
                Caption = 'User Groups';
                action("User by User Group")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'User by User Group';
                    Image = User;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "User by User Group";
                    ToolTip = 'View and assign user groups to users.';
                }
                action(UserGroups)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'User Groups';
                    Image = Users;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "User Groups";
                    ToolTip = 'Set up or modify user groups as a fast way of giving users access to the functionality that is relevant to their work.';
                }
            }
        }
        area(processing)
        {
            group("<Functions>")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action(CopyPermissionSet)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Copy Permission Set';
                    Ellipsis = true;
                    Enabled = CanManageUsersOnTenant;
                    Image = Copy;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ToolTip = 'Create a copy of the selected permission set with a name that you specify.';

                    trigger OnAction()
                    var
                        AggregatePermissionSet: Record "Aggregate Permission Set";
                        CopyPermissionSet: Report "Copy Permission Set";
                        ZeroGuid: Guid;
                    begin
                        AggregatePermissionSet.SetRange(Scope,Scope);
                        AggregatePermissionSet.SetRange("App ID","App ID");
                        AggregatePermissionSet.SetRange("Role ID","Role ID");

                        CopyPermissionSet.SetTableView(AggregatePermissionSet);
                        CopyPermissionSet.RunModal;

                        if AggregatePermissionSet.Get(AggregatePermissionSet.Scope::Tenant,ZeroGuid,CopyPermissionSet.GetNewRoleID) then begin
                          Init;
                          TransferFields(AggregatePermissionSet);
                          SetType;
                          Insert;
                          Get(Type,"Role ID");
                        end;
                    end;
                }
                action(ImportPermissionSets)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Import Permission Sets';
                    Enabled = CanManageUsersOnTenant;
                    Image = Import;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = false;
                    PromotedOnly = true;
                    ToolTip = 'Import a file with permissions.';

                    trigger OnAction()
                    begin
                        XMLPORT.Run(XMLPORT::"Import Tenant Permission Sets",false,true);
                        FillRecordBuffer;
                    end;
                }
                action(ExportPermissionSets)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Export Permission Sets';
                    Image = Export;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = false;
                    PromotedOnly = true;
                    ToolTip = 'Export one or more permission sets to a file.';

                    trigger OnAction()
                    var
                        AggregatePermissionSet: Record "Aggregate Permission Set";
                        TempBlob: Record TempBlob;
                        PermissionManager: Codeunit "Permission Manager";
                        FileManagement: Codeunit "File Management";
                        ExportPermissionSets: XMLport "Export Permission Sets";
                        OutStr: OutStream;
                        "Filter": Text;
                    begin
                        CurrPage.SetSelectionFilter(Rec);
                        if FindSet then begin
                          Filter := "Role ID";
                          if Next <> 0 then
                            repeat
                              Filter += '|' + "Role ID";
                            until Next = 0
                        end;
                        Reset;

                        AggregatePermissionSet.SetFilter("Role ID",Filter);
                        if PermissionManager.IsSandboxConfiguration then
                          if Confirm(ExportExtensionSchemaQst) then begin
                            TempBlob.Init;
                            TempBlob.Blob.CreateOutStream(OutStr);
                            ExportPermissionSets.SetExportToExtensionSchema(true);
                            ExportPermissionSets.SetTableView(AggregatePermissionSet);
                            ExportPermissionSets.SetDestination(OutStr);
                            ExportPermissionSets.Export;

                            FileManagement.BLOBExport(TempBlob,FileManagement.ServerTempFileName('xml'),true);
                            exit;
                          end;

                        XMLPORT.Run(XMLPORT::"Export Permission Sets",false,false,AggregatePermissionSet);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        PermissionEditable := (Type = Type::"User-Defined") and CanManageUsersOnTenant;
        IsPermissionSetEditable := PermissionEditable; // PermissionEditable is used instead of doing the same check
    end;

    trigger OnAfterGetRecord()
    begin
        PermissionEditable := (Type = Type::"User-Defined") and CanManageUsersOnTenant;
        IsPermissionSetEditable := PermissionEditable; // PermissionEditable is used instead of doing the same check
    end;

    trigger OnDeleteRecord(): Boolean
    var
        PermissionSetLink: Record "Permission Set Link";
        TenantPermissionSet: Record "Tenant Permission Set";
        PermissionPagesMgt: Codeunit "Permission Pages Mgt.";
    begin
        PermissionPagesMgt.DisallowEditingPermissionSetsForNonAdminUsers;

        if Type <> Type::"User-Defined" then
          Error(CannotDeletePermissionSetErr);

        PermissionSetLink.SetRange("Linked Permission Set ID","Role ID");
        PermissionSetLink.DeleteAll;

        TenantPermissionSet.Get("App ID","Role ID");
        TenantPermissionSet.Delete;

        CurrPage.Update;
        exit(true);
    end;

    trigger OnInit()
    begin
        CanManageUsersOnTenant := PermissionManager.CanManageUsersOnTenant(UserSecurityId);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        TenantPermissionSet: Record "Tenant Permission Set";
        PermissionPagesMgt: Codeunit "Permission Pages Mgt.";
        ZeroGUID: Guid;
    begin
        PermissionPagesMgt.DisallowEditingPermissionSetsForNonAdminUsers;

        TenantPermissionSet.Init;
        TenantPermissionSet."App ID" := ZeroGUID;
        TenantPermissionSet."Role ID" := "Role ID";
        TenantPermissionSet.Name := Name;
        TenantPermissionSet.Insert;

        Insert;
        Get(Type::"User-Defined","Role ID");
        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        TenantPermissionSet: Record "Tenant Permission Set";
        PermissionPagesMgt: Codeunit "Permission Pages Mgt.";
    begin
        PermissionPagesMgt.DisallowEditingPermissionSetsForNonAdminUsers;

        if Type = Type::"User-Defined" then begin
          TenantPermissionSet.Get(xRec."App ID",xRec."Role ID");
          if xRec."Role ID" <> "Role ID" then begin
            TenantPermissionSet.Rename(xRec."App ID","Role ID");
            TenantPermissionSet.Get(xRec."App ID","Role ID");
          end;
          TenantPermissionSet.Name := Name;
          TenantPermissionSet.Modify;
          CurrPage.Update(false);
          exit(true);
        end;
        exit(false); // Causes UI to stop processing the action - we handled it manually
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Type := Type::"User-Defined";
        IsPermissionSetEditable := true;
        PermissionEditable := true;
        Scope := Scope::Tenant;
    end;

    trigger OnOpenPage()
    var
        PermissionPagesMgt: Codeunit "Permission Pages Mgt.";
    begin
        PermissionPagesMgt.CheckAndRaiseNotificationIfAppDBPermissionSetsChanged;
        FillRecordBuffer;

        if PermissionManager.IsIntelligentCloud then
          SetRange("Role ID",PermissionManager.GetIntelligentCloudTok);
    end;

    var
        PermissionManager: Codeunit "Permission Manager";
        [InDataSet]
        CanManageUsersOnTenant: Boolean;
        [InDataSet]
        IsPermissionSetEditable: Boolean;
        [InDataSet]
        PermissionEditable: Boolean;
        CannotDeletePermissionSetErr: Label 'You can only delete user-created or copied permission sets.';
        ExportExtensionSchemaQst: Label 'Do you want to export permission sets in a schema that is supported by the extension package?';
}

