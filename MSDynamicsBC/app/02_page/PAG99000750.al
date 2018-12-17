page 99000750 "Work Shifts"
{
    // version NAVW113.00

    ApplicationArea = Manufacturing;
    Caption = 'Work Shifts';
    PageType = List;
    SourceTable = "Work Shift";
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
                    ToolTip = 'Specifies a code to identify this work shift.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies a description of the work shift.';
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

