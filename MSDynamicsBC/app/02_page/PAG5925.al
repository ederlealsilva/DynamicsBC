page 5925 "Fault Areas"
{
    // version NAVW113.00

    ApplicationArea = Service;
    Caption = 'Fault Areas';
    PageType = List;
    SourceTable = "Fault Area";
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
                    ApplicationArea = Service;
                    ToolTip = 'Specifies a code for the fault area.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies a description of the fault area.';
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

