page 7609 "Monthly Calendar"
{
    // version NAVW110.0

    Caption = 'Monthly Calendar';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = Card;
    SaveValues = true;
    SourceTable = Date;
    SourceTableView = WHERE("Period Type"=CONST(Week));

    layout
    {
    }

    actions
    {
    }
}

