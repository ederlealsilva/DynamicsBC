table 402 "Change Log Setup"
{
    // version NAVW113.00

    Caption = 'Change Log Setup';
    ReplicateData = false;

    fields
    {
        field(1;"Primary Key";Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2;"Change Log Activated";Boolean)
        {
            Caption = 'Change Log Activated';
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

