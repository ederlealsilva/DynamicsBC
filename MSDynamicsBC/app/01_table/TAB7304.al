table 7304 "Warehouse Class"
{
    // version NAVW17.00

    Caption = 'Warehouse Class';
    LookupPageID = "Warehouse Classes";

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

