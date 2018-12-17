table 99000762 Scrap
{
    // version NAVW17.00

    Caption = 'Scrap';
    DrillDownPageID = "Scrap Codes";
    LookupPageID = "Scrap Codes";

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2;Description;Text[50])
        {
            Caption = 'Description';
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

