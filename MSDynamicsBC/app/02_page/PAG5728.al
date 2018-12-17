page 5728 Manufacturers
{
    // version NAVW113.00

    ApplicationArea = Manufacturing;
    Caption = 'Manufacturers';
    PageType = List;
    SourceTable = Manufacturer;
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
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the code you want to use for the manufacturer.';
                }
                field(Name;Name)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the name of the manufacturer.';
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

