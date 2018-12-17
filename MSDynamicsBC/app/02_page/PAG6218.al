page 6218 "Field List"
{
    // version NAVW110.0

    Caption = 'Field List';
    DataCaptionExpression = Caption;
    Editable = false;
    PageType = List;
    SourceTable = "Field";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(FieldName;FieldName)
                {
                    ApplicationArea = Suite;
                    Caption = 'Name';
                    ToolTip = 'Specifies the name of the record.';
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

    local procedure Caption(): Text[100]
    begin
        exit(StrSubstNo('%1',TableName));
    end;
}

