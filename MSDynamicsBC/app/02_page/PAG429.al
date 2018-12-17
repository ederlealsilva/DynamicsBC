page 429 Territories
{
    // version NAVW113.00

    ApplicationArea = RelationshipMgmt;
    Caption = 'Territories';
    PageType = List;
    SourceTable = Territory;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code";Code)
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies a territory code.';
                }
                field(Name;Name)
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies a description of the territory.';
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

