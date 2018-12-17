page 9841 "Permission Set Lookup"
{
    // version NAVW113.00

    Caption = 'Permission Set Lookup';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Aggregate Permission Set";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Role ID";"Role ID")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies a profile.';
                }
                field(Name;Name)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the name of the record.';
                }
                field("App Name";"App Name")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Extension Name';
                    ToolTip = 'Specifies the name of an extension.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        SelectedRecord := Rec;
    end;

    var
        SelectedRecord: Record "Aggregate Permission Set";

    procedure GetSelectedRecord(var CurrSelectedRecord: Record "Aggregate Permission Set")
    begin
        CurrSelectedRecord := SelectedRecord;
    end;
}

