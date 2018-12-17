table 130403 "CAL Test Enabled Codeunit"
{
    // version NAVW19.00

    Caption = 'CAL Test Enabled Codeunit';

    fields
    {
        field(1;"No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'No.';
        }
        field(2;"Test Codeunit ID";Integer)
        {
            Caption = 'Test Codeunit ID';
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
    }

    fieldgroups
    {
    }
}

