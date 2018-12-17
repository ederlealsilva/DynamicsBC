page 99000779 "Stop Codes"
{
    // version NAVW113.00

    ApplicationArea = Manufacturing;
    Caption = 'Stop Codes';
    PageType = List;
    SourceTable = Stop;
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
                    ToolTip = 'Specifies a code to identify why a machine center has stopped.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies a description for the stop code.';
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

