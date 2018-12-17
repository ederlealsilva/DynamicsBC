table 2000000176 "NAV App Resource"
{
    // version NAVW113.00

    Caption = 'NAV App Resource';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"Package ID";Guid)
        {
            Caption = 'Package ID';
        }
        field(2;Type;Integer)
        {
            Caption = 'Type';
        }
        field(3;Name;Text[250])
        {
            Caption = 'Name';
        }
        field(4;Content;BLOB)
        {
            Caption = 'Content';
        }
    }

    keys
    {
        key(Key1;"Package ID",Type,Name)
        {
        }
    }

    fieldgroups
    {
    }
}

