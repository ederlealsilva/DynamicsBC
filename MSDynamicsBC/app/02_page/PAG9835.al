page 9835 "User Group Permissions FactBox"
{
    // version NAVW113.00

    Caption = 'Permission Sets';
    Editable = false;
    PageType = ListPart;
    SourceTable = "User Group Permission Set";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Role ID";"Role ID")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies a profile.';
                }
                field("Role Name";"Role Name")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the name of the profile.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}

