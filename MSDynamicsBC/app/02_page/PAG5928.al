page 5928 "Resolution Codes"
{
    // version NAVW113.00

    ApplicationArea = Service;
    Caption = 'Resolution Codes';
    PageType = List;
    SourceTable = "Resolution Code";
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
                    ToolTip = 'Specifies a code for the resolution.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies a description of the resolution code.';
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

