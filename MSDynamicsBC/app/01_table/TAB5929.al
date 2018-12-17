table 5929 "Service Shelf"
{
    // version NAVW17.00

    Caption = 'Service Shelf';
    LookupPageID = "Service Shelves";

    fields
    {
        field(1;"No.";Code[10])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(2;Description;Text[50])
        {
            Caption = 'Description';
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

