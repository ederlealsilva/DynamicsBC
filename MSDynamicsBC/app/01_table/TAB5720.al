table 5720 Manufacturer
{
    // version NAVW113.00

    Caption = 'Manufacturer';
    LookupPageID = Manufacturers;

    fields
    {
        field(10;"Code";Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(20;Name;Text[50])
        {
            Caption = 'Name';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }
}

