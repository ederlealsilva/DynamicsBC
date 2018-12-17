table 130402 "CAL Test Codeunit"
{
    // version NAVW19.00

    Caption = 'CAL Test Codeunit';

    fields
    {
        field(1;ID;Integer)
        {
            Caption = 'ID';
        }
        field(2;File;Text[250])
        {
            Caption = 'File';
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

