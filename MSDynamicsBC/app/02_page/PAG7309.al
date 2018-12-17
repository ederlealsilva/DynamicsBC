page 7309 "Special Equipment"
{
    // version NAVW113.00

    ApplicationArea = Warehouse;
    Caption = 'Special Equipment';
    PageType = List;
    SourceTable = "Special Equipment";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code";Code)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the code of the special equipment.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the description of the special equipment.';
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

