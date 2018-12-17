table 99000777 "Routing Link"
{
    // version NAVW18.00

    Caption = 'Routing Link';
    LookupPageID = "Routing Links";

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
        key(Key2;Description)
        {
        }
    }

    fieldgroups
    {
    }
}

