page 9834 "User Group Permission Sets"
{
    // version NAVW113.00

    Caption = 'User Group Permission Sets';
    PageType = List;
    SourceTable = "User Group Permission Set";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Role ID";"Role ID")
                {
                    ApplicationArea = Basic,Suite;
                    Editable = true;
                    NotBlank = true;
                    ToolTip = 'Specifies a profile.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        TempPermissionSetBuffer: Record "Permission Set Buffer" temporary;
                        PermissionSets: Page "Permission Sets";
                    begin
                        PermissionSets.LookupMode(true);
                        if PermissionSets.RunModal = ACTION::LookupOK then begin
                          PermissionSets.GetRecord(TempPermissionSetBuffer);
                          "Role ID" := TempPermissionSetBuffer."Role ID";
                          Scope := TempPermissionSetBuffer.Scope;
                          "App ID" := TempPermissionSetBuffer."App ID";
                          CalcFields("Extension Name","Role Name");
                          Text := "Role ID";
                        end;
                    end;

                    trigger OnValidate()
                    var
                        AggregatePermissionSet: Record "Aggregate Permission Set";
                    begin
                        AggregatePermissionSet.SetRange("Role ID","Role ID");
                        AggregatePermissionSet.FindFirst;
                        Scope := AggregatePermissionSet.Scope;
                        "App ID" := AggregatePermissionSet."App ID";
                        CalcFields("Extension Name","Role Name");
                    end;
                }
                field("Role Name";AppRoleName)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Role Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of the profile.';
                }
                field("App Name";"Extension Name")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Extension Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of an extension.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        if Scope = Scope::Tenant then begin
          if TenantPermissionSetRec.Get("App ID","Role ID") then
            AppRoleName := TenantPermissionSetRec.Name
        end else begin
          if PermissionSetRec.Get("Role ID") then
            AppRoleName := PermissionSetRec.Name
        end
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        exit("Role ID" <> '');
    end;

    trigger OnModifyRecord(): Boolean
    begin
        TestField("Role ID");
    end;

    trigger OnOpenPage()
    begin
        if "User Group Code" = IntelligentCloudTok then
          CurrPage.Editable(false);
    end;

    var
        PermissionSetRec: Record "Permission Set";
        TenantPermissionSetRec: Record "Tenant Permission Set";
        AppRoleName: Text[30];
        IntelligentCloudTok: Label 'INTELLIGENT CLOUD', Locked=true;
}

