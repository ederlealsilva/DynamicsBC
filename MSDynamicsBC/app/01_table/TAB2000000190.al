table 2000000190 "Entitlement Set"
{
    // version NAVW113.00

    Caption = 'Entitlement Set';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;ID;Code[20])
        {
            Caption = 'ID';
        }
        field(2;Name;Text[250])
        {
            Caption = 'Name';
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

