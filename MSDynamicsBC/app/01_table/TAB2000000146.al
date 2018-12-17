table 2000000146 "Intelligent Cloud"
{
    // version NAVW113.00

    Caption = 'Intelligent Cloud';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"Primary Key";Text[10])
        {
            Caption = 'Primary Key';
        }
        field(2;Enabled;Boolean)
        {
            Caption = 'Enabled';
        }
    }

    keys
    {
        key(Key1;"Primary Key")
        {
        }
    }

    fieldgroups
    {
    }
}

