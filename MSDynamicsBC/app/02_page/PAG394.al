page 394 "Entry/Exit Points"
{
    // version NAVW113.00

    ApplicationArea = Basic,Suite;
    Caption = 'Entry/Exit Points';
    PageType = List;
    SourceTable = "Entry/Exit Point";
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
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the code for the shipping location (Entry/Exit Point).';
                }
                field(Description;Description)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies a description of the shipping location (Entry/Exit Point).';
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

