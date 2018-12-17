table 5213 "Misc. Article"
{
    // version NAVW17.00

    Caption = 'Misc. Article';
    LookupPageID = "Misc. Articles";

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

