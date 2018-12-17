table 5073 "Campaign Status"
{
    // version NAVW17.00

    Caption = 'Campaign Status';
    DataCaptionFields = "Code",Description;
    LookupPageID = "Campaign Status";

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

