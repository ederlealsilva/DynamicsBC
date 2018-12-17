page 9824 Plans
{
    // version NAVW110.0

    Caption = 'Plans';
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    ShowFilter = false;
    SourceTable = Plan;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name;Name)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the name of the record.';
                }
            }
        }
        area(factboxes)
        {
            part("Users in Plan";"User Plan Members FactBox")
            {
                ApplicationArea = Basic,Suite;
                SubPageLink = "Plan ID"=FIELD("Plan ID");
            }
            part("User Groups in Plan";"User Group Plan FactBox")
            {
                ApplicationArea = Basic,Suite;
                SubPageLink = "Plan ID"=FIELD("Plan ID");
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(PageUserGroupByPlan)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'User Group by Plan';
                Image = Users;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "User Group by Plan";
                RunPageMode = View;
                ToolTip = 'View a list of user groups filtered by plan.';
            }
        }
    }
}

