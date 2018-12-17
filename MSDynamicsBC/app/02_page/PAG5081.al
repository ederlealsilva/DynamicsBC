page 5081 "Contact Job Responsibilities"
{
    // version NAVW110.0

    Caption = 'Contact Job Responsibilities';
    DataCaptionFields = "Contact No.";
    PageType = List;
    SourceTable = "Contact Job Responsibility";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Job Responsibility Code";"Job Responsibility Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the job responsibility code.';
                }
                field("Job Responsibility Description";"Job Responsibility Description")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    ToolTip = 'Specifies the description for the job responsibility you have assigned to the contact.';
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

