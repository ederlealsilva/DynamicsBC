page 405 Areas
{
    // version NAVW113.00

    ApplicationArea = Basic,Suite;
    Caption = 'Areas';
    PageType = List;
    SourceTable = "Area";
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
                    ToolTip = 'Specifies a code for the area.';
                }
                field(Text;Text)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies a description of the area.';
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

