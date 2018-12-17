page 1753 "Field Content Buffer"
{
    // version NAVW113.00

    Caption = 'Field Contents';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Field Content Buffer";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Value;Value)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

