table 5204 Relative
{
    // version NAVW17.00

    Caption = 'Relative';
    DrillDownPageID = Relatives;
    LookupPageID = Relatives;

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

