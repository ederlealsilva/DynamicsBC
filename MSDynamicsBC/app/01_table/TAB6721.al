table 6721 "Booking Mgr. Setup"
{
    // version NAVW110.0

    Caption = 'Booking Mgr. Setup';

    fields
    {
        field(1;"Primary Key";Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2;"Booking Mgr. Codeunit";Integer)
        {
            Caption = 'Booking Mgr. Codeunit';
            InitValue = 6722;
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

