table 5955 "Skill Code"
{
    // version NAVW17.00

    Caption = 'Skill Code';
    DataCaptionFields = "Code",Description;
    LookupPageID = "Skill Codes";

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

