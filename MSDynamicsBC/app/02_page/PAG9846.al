page 9846 "Changed Permission Set List"
{
    // version NAVW113.00

    Caption = 'Changed Permission Set List';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    Permissions = TableData "Permission Set Link"=r;
    SourceTable = "Permission Set Link";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Permission Set ID";"Permission Set ID")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Permission Set';
                }
                field("Linked Permission Set ID";"Linked Permission Set ID")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Copied Permission Set';
                }
            }
        }
    }

    actions
    {
    }
}

