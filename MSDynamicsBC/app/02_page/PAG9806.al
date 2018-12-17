page 9806 "Fields Lookup"
{
    // version NAVW111.00

    Caption = 'Fields Lookup';
    Editable = false;
    PageType = List;
    SourceTable = "Field";

    layout
    {
        area(content)
        {
            repeater(Control2)
            {
                ShowCaption = false;
                field("No.";"No.")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'No.';
                    ToolTip = 'Specifies the number of the field.';
                }
                field(FieldName;FieldName)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Field Name';
                    ToolTip = 'Specifies the name of the field.';
                }
                field("Field Caption";"Field Caption")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Field Caption';
                    ToolTip = 'Specifies the caption of the field, that is, the name that will be shown in the user interface.';
                }
            }
        }
    }

    actions
    {
    }
}

