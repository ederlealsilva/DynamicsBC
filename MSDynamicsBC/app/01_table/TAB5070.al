table 5070 "Organizational Level"
{
    // version NAVW17.00

    Caption = 'Organizational Level';
    DataCaptionFields = "Code",Description;
    LookupPageID = "Organizational Levels";

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

