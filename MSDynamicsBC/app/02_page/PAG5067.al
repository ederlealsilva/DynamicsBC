page 5067 "Contact Industry Groups"
{
    // version NAVW110.0

    Caption = 'Contact Industry Groups';
    DataCaptionFields = "Contact No.";
    PageType = List;
    SourceTable = "Contact Industry Group";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Industry Group Code";"Industry Group Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the industry group code. This field is not editable.';
                }
                field("Industry Group Description";"Industry Group Description")
                {
                    ApplicationArea = RelationshipMgmt;
                    DrillDown = false;
                    ToolTip = 'Specifies the description of the industry group you have assigned to the contact.';
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

