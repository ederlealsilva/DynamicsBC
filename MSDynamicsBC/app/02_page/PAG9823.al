page 9823 "User Plan Members FactBox"
{
    // version NAVW110.0

    Caption = 'Users in Plan';
    Editable = false;
    PageType = ListPart;
    SourceTable = "User Plan";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("User Name";"User Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the short name for the user.';
                }
                field("Plan Name";"Plan Name")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the subscription plan.';
                }
            }
        }
    }

    actions
    {
    }
}

