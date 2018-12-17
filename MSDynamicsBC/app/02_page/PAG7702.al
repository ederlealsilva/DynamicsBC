page 7702 "Fields"
{
    // version NAVW113.00

    Caption = 'Fields';
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
                field(TableNo;TableNo)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'TableNo';
                    ToolTip = 'Specifies the source table number, if any, for this codeunit.';
                }
                field("No.";"No.")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'No.';
                    ToolTip = 'Specifies the number of the field.';
                }
                field(TableName;TableName)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'TableName';
                    ToolTip = 'Specifies the name of the table.';
                }
                field(FieldName;FieldName)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'FieldName';
                    ToolTip = 'Specifies the name of the field.';
                }
                field(Type;Type)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Type';
                    ToolTip = 'Specifies the data type of the selected field.';
                }
                field(Class;Class)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Class';
                    ToolTip = 'Specifies the class of the field.';
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
}

