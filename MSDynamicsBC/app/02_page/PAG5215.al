page 5215 "Grounds for Termination"
{
    // version NAVW113.00

    ApplicationArea = Advanced;
    Caption = 'Grounds for Termination';
    PageType = List;
    SourceTable = "Grounds for Termination";
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
                    ToolTip = 'Specifies a grounds for termination code.';
                }
                field(Description;Description)
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies a description for the grounds for termination.';
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

