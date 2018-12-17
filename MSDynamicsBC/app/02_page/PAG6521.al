page 6521 "Table Field List"
{
    // version NAVW113.00

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
                field("No.";"No.")
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'No.';
                    ToolTip = 'Specifies the number of the field.';
                }
                field("Field Caption";"Field Caption")
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Field Caption';
                    ToolTip = 'Specifies the caption of the field, that is, the name that will be shown in the user interface.';
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
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        AllObjWithCaption.SetRange("Object Type",AllObjWithCaption."Object Type"::Table);
        AllObjWithCaption.SetRange("Object ID",TableNo);
        if AllObjWithCaption.FindFirst then
          exit(StrSubstNo('%1',AllObjWithCaption."Object Caption"));
        exit(StrSubstNo('%1',TableName));
    end;
}

