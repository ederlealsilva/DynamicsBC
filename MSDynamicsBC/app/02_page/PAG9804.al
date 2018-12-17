page 9804 "Permissions FactBox"
{
    // version NAVW113.00

    Caption = 'Permissions';
    Editable = false;
    PageType = ListPart;
    SourceTable = Permission;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Object Type";"Object Type")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the type of object that the permissions apply to in the current database.';
                }
                field("Object ID";"Object ID")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the ID of the object to which the permissions apply.';
                }
                field("Object Name";"Object Name")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the name of the object to which the permissions apply.';
                }
            }
        }
    }

    actions
    {
    }
}

