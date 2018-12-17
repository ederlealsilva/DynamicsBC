page 5926 "Symptom Codes"
{
    // version NAVW113.00

    ApplicationArea = Service;
    Caption = 'Symptom Codes';
    PageType = List;
    SourceTable = "Symptom Code";
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
                    ToolTip = 'Specifies a code for the symptom.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies a description of the symptom code.';
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

