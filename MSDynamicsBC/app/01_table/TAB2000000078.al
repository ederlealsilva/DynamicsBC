table 2000000078 Chart
{
    // version NAVW17.10

    Caption = 'Chart';
    DataPerCompany = false;

    fields
    {
        field(3;ID;Code[20])
        {
            Caption = 'ID';
        }
        field(6;Name;Text[30])
        {
            Caption = 'Name';
        }
        field(9;BLOB;BLOB)
        {
            Caption = 'BLOB';
        }
    }

    keys
    {
        key(Key1;ID)
        {
        }
    }

    fieldgroups
    {
    }
}

