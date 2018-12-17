page 548 "Dimension List"
{
    // version NAVW113.00

    Caption = 'Dimension List';
    Editable = false;
    PageType = List;
    SourceTable = Dimension;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code";Code)
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for the dimension.';
                }
                field(Name;Name)
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the dimension code you enter in the Code field.';
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
        Name := GetMLName(GlobalLanguage);
    end;
}

