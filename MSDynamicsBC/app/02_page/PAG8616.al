page 8616 "Config. Package Errors"
{
    // version NAVW113.00

    Caption = 'Config. Package Errors';
    DataCaptionExpression = FormCaption;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Config. Package Error";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Error Text";"Error Text")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the text of the error in the migration field. You can use information contained in the error text to fix migration problems before you attempt to apply migration data to the database.';
                }
                field("Field Caption";"Field Caption")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the caption of the migration field to which the error applies.';
                }
                field("Field Name";"Field Name")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the name of the field in the migration table to which the error applies.';
                    Visible = false;
                }
                field(RecordIDValue;RecordIDValue)
                {
                    ApplicationArea = Basic,Suite;
                    CaptionClass = FieldCaption("Record ID");
                    Editable = false;
                    ToolTip = 'Specifies the record in the migration table to which the error applies.';
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
    }

    trigger OnAfterGetRecord()
    begin
        RecordIDValue := Format("Record ID");
    end;

    var
        RecordIDValue: Text;

    local procedure FormCaption(): Text[1024]
    var
        ConfigPackageTable: Record "Config. Package Table";
    begin
        ConfigPackageTable.SetRange("Package Code","Package Code");
        ConfigPackageTable.SetRange("Table ID","Table ID");
        if ConfigPackageTable.FindFirst then
          ConfigPackageTable.CalcFields("Table Caption");

        exit(ConfigPackageTable."Table Caption");
    end;
}

