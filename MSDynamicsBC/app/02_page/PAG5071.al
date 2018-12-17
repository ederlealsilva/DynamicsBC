page 5071 "Web Source Launch"
{
    // version NAVW110.0

    Caption = 'Web Source Launch';
    Editable = false;
    PageType = List;
    SourceTable = "Contact Web Source";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Web Source Code";"Web Source Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Web source code. This field is not editable.';
                }
                field("Web Source Description";"Web Source Description")
                {
                    ApplicationArea = RelationshipMgmt;
                    DrillDown = false;
                    ToolTip = 'Specifies the description of the Web source you have assigned to the contact.';
                }
                field("Search Word";"Search Word")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the search word to search for information about the contact on the Internet.';
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

