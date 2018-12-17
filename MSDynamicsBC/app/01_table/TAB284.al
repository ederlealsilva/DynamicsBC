table 284 "Area"
{
    // version NAVW17.00

    Caption = 'Area';
    LookupPageID = Areas;

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2;Text;Text[50])
        {
            Caption = 'Text';
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
        fieldgroup(DropDown;"Code",Text)
        {
        }
    }
}

