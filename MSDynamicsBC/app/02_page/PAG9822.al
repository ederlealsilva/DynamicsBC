page 9822 "User Plan Members"
{
    // version NAVW110.0

    Caption = 'User Plan Members';
    Editable = false;
    LinksAllowed = false;
    PageType = List;
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
                field("User Full Name";"User Full Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the full name of the user.';
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

