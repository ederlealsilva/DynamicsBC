page 9803 Permissions
{
    // version NAVW113.00

    Caption = 'Permissions';
    DataCaptionFields = "Object Type","Object Name";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    PopulateAllFields = true;
    PromotedActionCategories = 'New,Process,Report,Read,Insert,Modify,Delete,Execute';
    ShowFilter = false;
    SourceTable = Permission;
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                group(Control42)
                {
                    ShowCaption = false;
                    field(CurrentRoleID;CurrentRoleID)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Permission Set';
                        Editable = false;
                        Importance = Promoted;
                        ToolTip = 'Specifies the permission set that the permission belongs to.';

                        trigger OnValidate()
                        begin
                            FillTempPermissions;
                        end;
                    }
                }
            }
            repeater(Group)
            {
                Caption = 'AllPermission';
                field("Object Type";"Object Type")
                {
                    ApplicationArea = Basic,Suite;
                    Enabled = AllowChangePrimaryKey;
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                    ToolTip = 'Specifies the type of object that the permissions apply to in the current database.';

                    trigger OnValidate()
                    begin
                        ActivateControls;
                        SetObjectZeroName(Rec);
                    end;
                }
                field("Object ID";"Object ID")
                {
                    ApplicationArea = Basic,Suite;
                    Enabled = AllowChangePrimaryKey;
                    LookupPageID = "All Objects with Caption";
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                    ToolTip = 'Specifies the ID of the object to which the permissions apply.';

                    trigger OnValidate()
                    begin
                        IsValidatedObjectID := false;
                        ActivateControls;
                        SetObjectZeroName(Rec);
                    end;
                }
                field(ObjectName;ObjectName)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Object Name';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                    ToolTip = 'Specifies the name of the object to which the permissions apply.';
                }
                field("Read Permission";"Read Permission")
                {
                    ApplicationArea = Basic,Suite;
                    Enabled = IsTableData;
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                    ToolTip = 'Specifies information about whether the permission set has read permission to this object. The values for the field are blank, Yes, and Indirect. Indirect means permission only through another object. If the field is empty, the permission set does not have read permission.';
                }
                field("Insert Permission";"Insert Permission")
                {
                    ApplicationArea = Basic,Suite;
                    Enabled = IsTableData;
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                    ToolTip = 'Specifies information about whether the permission set has insert permission to this object. The values for the field are blank, Yes, and Indirect. Indirect means permission only through another object. If the field is empty, the permission set does not have insert permission.';
                }
                field("Modify Permission";"Modify Permission")
                {
                    ApplicationArea = Basic,Suite;
                    Enabled = IsTableData;
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                    ToolTip = 'Specifies information about whether the permission set has modify permission to this object. The values for the field are blank, Yes, and Indirect. Indirect means permission only through another object. If the field is empty, the permission set does not have modify permission.';
                }
                field("Delete Permission";"Delete Permission")
                {
                    ApplicationArea = Basic,Suite;
                    Enabled = IsTableData;
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                    ToolTip = 'Specifies information about whether the permission set has delete permission to this object. The values for the field are blank, Yes, and Indirect. Indirect means permission only through another object. If the field is empty, the permission set does not have delete permission.';
                }
                field("Execute Permission";"Execute Permission")
                {
                    ApplicationArea = Basic,Suite;
                    Enabled = NOT IsTableData;
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                    ToolTip = 'Specifies information about whether the permission set has execute permission to this object. The values for the field are blank, Yes, and Indirect. Indirect means permission only through another object. If the field is empty, the permission set does not have execute permission.';
                }
                field("Security Filter";"Security Filter")
                {
                    ApplicationArea = Basic,Suite;
                    Enabled = IsTableData;
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                    ToolTip = 'Specifies the security filter that is being applied to this permission set to limit the access that this permission set has to the data contained in this table.';

                    trigger OnAssistEdit()
                    var
                        PermissionPagesMgt: Codeunit "Permission Pages Mgt.";
                        OutputSecurityFilter: Text;
                    begin
                        if PermissionPagesMgt.ShowSecurityFilterForPermission(OutputSecurityFilter,Rec) then
                          Evaluate("Security Filter",OutputSecurityFilter);
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        Permission: Record Permission;
    begin
        ActivateControls;
        SetObjectZeroName(Rec);
        if not IsNewRecord then begin
          Permission := Rec;
          PermissionRecExists := Permission.Find;
        end else
          PermissionRecExists := false;
        AllowChangePrimaryKey := not PermissionRecExists and (Show = Show::"Only In Permission Set");
        ZeroObjStyleExpr := PermissionRecExists and ("Object ID" = 0);
    end;

    trigger OnAfterGetRecord()
    begin
        SetObjectZeroName(Rec);
        ZeroObjStyleExpr := "Object ID" = 0;
        IsValidatedObjectID := false;
        IsNewRecord := false;
    end;

    trigger OnDeleteRecord(): Boolean
    var
        Permission: Record Permission;
    begin
        if (Show = Show::All) and ("Object ID" <> 0) then
          exit(false);
        Permission := Rec;
        Permission.Find;
        exit(Permission.Delete);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        Permission: Record Permission;
    begin
        if ("Object ID" = 0) and ((Show = Show::All) or IsValidatedObjectID) then
          exit(false);
        if ("Execute Permission" = "Execute Permission"::" ") and
           ("Read Permission" = "Read Permission"::" ") and
           ("Insert Permission" = "Insert Permission"::" ") and
           ("Modify Permission" = "Modify Permission"::" ") and
           ("Delete Permission" = "Delete Permission"::" ")
        then
          exit(false);

        if "Object Type" = "Object Type"::"Table Data" then
          "Execute Permission" := "Execute Permission"::" "
        else begin
          "Read Permission" := "Read Permission"::" ";
          "Insert Permission" := "Insert Permission"::" ";
          "Modify Permission" := "Modify Permission"::" ";
          "Delete Permission" := "Delete Permission"::" ";
        end;
        Permission := Rec;
        Permission.Insert;
        Rec := Permission;
        SetObjectZeroName(Rec);
        PermissionRecExists := true;
        IsNewRecord := false;
        ZeroObjStyleExpr := "Object ID" = 0;
        exit(true);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        ModifyRecord(Rec);
        PermissionRecExists := true;
        IsNewRecord := false;
        exit(Modify);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ActivateControls;
        PermissionRecExists := false;
        IsNewRecord := true;
        IsValidatedObjectID := false;
    end;

    trigger OnOpenPage()
    var
        PermissionSet: Record "Permission Set";
    begin
        if CurrentRoleID = '' then
          if GetFilter("Role ID") <> '' then
            CurrentRoleID := GetRangeMin("Role ID")
          else
            if PermissionSet.FindFirst then
              CurrentRoleID := PermissionSet."Role ID";
        Reset;
        FillTempPermissions;
    end;

    var
        CurrentRoleID: Code[20];
        Show: Option "Only In Permission Set",All;
        [InDataSet]
        IsTableData: Boolean;
        IsNewRecord: Boolean;
        IsValidatedObjectID: Boolean;
        PermissionRecExists: Boolean;
        AllowChangePrimaryKey: Boolean;
        AllObjTxt: Label 'All objects of type %1', Comment='%1= type name, e.g. Table Data or Report or Page';
        ZeroObjStyleExpr: Boolean;
        ObjectName: Text;

    local procedure FillTempPermissions()
    var
        TempPermission: Record Permission temporary;
        Permission: Record Permission;
    begin
        TempPermission.Copy(Rec,true);
        TempPermission.Reset;
        TempPermission.DeleteAll;
        FilterGroup(2);
        SetRange("Role ID",CurrentRoleID);
        Permission.SetRange("Role ID",CurrentRoleID);
        FilterGroup(0);

        if Permission.Find('-') then
          repeat
            TempPermission := Permission;
            TempPermission.Insert;
          until Permission.Next = 0;

        if Show = Show::All then
          FillTempPermissionsForAllObjects(TempPermission);
        IsNewRecord := false;
        if Find('=<>') then;
        CurrPage.Update(false);
    end;

    local procedure FillTempPermissionsForAllObjects(var Permission: Record Permission)
    var
        TempPermission: Record Permission temporary;
        AllObj: Record AllObj;
    begin
        AllObj.SetRange("Object Type");
        TempPermission.Copy(Permission,true);
        TempPermission.Init;
        if AllObj.FindSet then
          repeat
            TempPermission."Object Type" := AllObj."Object Type";
            TempPermission."Object ID" := AllObj."Object ID";
            TempPermission."Read Permission" := "Read Permission"::" ";
            TempPermission."Insert Permission" := "Insert Permission"::" ";
            TempPermission."Modify Permission" := "Modify Permission"::" ";
            TempPermission."Delete Permission" := "Delete Permission"::" ";
            TempPermission."Execute Permission" := "Execute Permission"::" ";
            SetObjectZeroName(TempPermission);
            if TempPermission.Insert then;
          until AllObj.Next = 0;
    end;

    local procedure ActivateControls()
    begin
        IsTableData := "Object Type" = "Object Type"::"Table Data"
    end;

    local procedure ModifyRecord(var ModifiedPermission: Record Permission)
    var
        Permission: Record Permission;
        IsNewPermission: Boolean;
    begin
        Permission.LockTable;
        IsNewPermission :=
          not Permission.Get(ModifiedPermission."Role ID",ModifiedPermission."Object Type",ModifiedPermission."Object ID");
        if IsNewPermission then begin
          Permission.TransferFields(ModifiedPermission,true);
          Permission.Insert;
        end else begin
          Permission.TransferFields(ModifiedPermission,false);
          Permission.Modify;
        end;

        if (Permission."Read Permission" = 0) and
           (Permission."Insert Permission" = 0) and
           (Permission."Modify Permission" = 0) and
           (Permission."Delete Permission" = 0) and
           (Permission."Execute Permission" = 0)
        then begin
          Permission.Delete;
          if Show = Show::"Only In Permission Set" then
            ModifiedPermission.Delete;
          IsNewPermission := false;
        end;
    end;

    local procedure SetObjectZeroName(var Permission: Record Permission)
    begin
        if Permission."Object ID" <> 0 then begin
          Permission.CalcFields("Object Name");
          ObjectName := Permission."Object Name";
        end else
          ObjectName := CopyStr(StrSubstNo(AllObjTxt,Permission."Object Type"),1,MaxStrLen(Permission."Object Name"));
    end;
}

