table 2000000173 "Intelligent Cloud Status"
{
    // version NAVW113.00

    Caption = 'Intelligent Cloud Status';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"Table Name";Text[250])
        {
            Caption = 'Table Name';
        }
        field(2;"Company Name";Text[30])
        {
            Caption = 'Company Name';
        }
        field(3;"Table Id";Integer)
        {
            Caption = 'Table Id';
        }
        field(4;"Synced Version";BigInteger)
        {
            Caption = 'Synced Version';
        }
        field(5;Blocked;Boolean)
        {
            Caption = 'Blocked';
        }
    }

    keys
    {
        key(Key1;"Table Name","Company Name")
        {
        }
    }

    fieldgroups
    {
    }
}

