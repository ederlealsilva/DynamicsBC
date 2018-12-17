table 269 "G/L Account Net Change"
{
    // version NAVW17.00

    Caption = 'G/L Account Net Change';

    fields
    {
        field(1;"No.";Code[20])
        {
            Caption = 'No.';
        }
        field(2;Name;Text[50])
        {
            Caption = 'Name';
        }
        field(3;"Net Change in Jnl.";Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Net Change in Jnl.';
        }
        field(4;"Balance after Posting";Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Balance after Posting';
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

