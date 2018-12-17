page 5214 "Causes of Inactivity"
{
    // version NAVW113.00

    ApplicationArea = Advanced;
    Caption = 'Causes of Inactivity';
    PageType = List;
    SourceTable = "Cause of Inactivity";
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
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies a cause of inactivity code.';
                }
                field(Description;Description)
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies a description for the cause of inactivity.';
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

