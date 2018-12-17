table 260 "Tariff Number"
{
    // version NAVW17.00

    Caption = 'Tariff Number';
    LookupPageID = "Tariff Numbers";

    fields
    {
        field(1;"No.";Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
            Numeric = true;
        }
        field(2;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(3;"Supplementary Units";Boolean)
        {
            Caption = 'Supplementary Units';
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

