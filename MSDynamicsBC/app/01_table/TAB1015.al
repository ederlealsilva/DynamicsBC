table 1015 "Job Entry No."
{
    // version NAVW111.00

    Caption = 'Job Entry No.';

    fields
    {
        field(1;"Primary Key";Code[10])
        {
            Caption = 'Primary Key';
            Editable = false;
        }
        field(2;"Entry No.";Integer)
        {
            Caption = 'Entry No.';
            Editable = false;
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

