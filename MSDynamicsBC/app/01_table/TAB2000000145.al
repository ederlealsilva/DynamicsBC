table 2000000145 "Power BI Default Selection"
{
    // version NAVW113.00

    Caption = 'Power BI Default Selection';
    DataPerCompany = false;

    fields
    {
        field(1;Id;Guid)
        {
            Caption = 'Id';
        }
        field(2;Context;Text[30])
        {
            Caption = 'Context';
        }
        field(3;Selected;Boolean)
        {
            Caption = 'Selected';
        }
    }

    keys
    {
        key(Key1;Id,Context)
        {
        }
    }

    fieldgroups
    {
    }
}

