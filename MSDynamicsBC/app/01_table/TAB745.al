table 745 "VAT Report Error Log"
{
    // version NAVW113.00

    Caption = 'VAT Report Error Log';
    ReplicateData = false;

    fields
    {
        field(1;"Entry No.";Integer)
        {
            Caption = 'Entry No.';
        }
        field(2;"Error Message";Text[250])
        {
            Caption = 'Error Message';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

