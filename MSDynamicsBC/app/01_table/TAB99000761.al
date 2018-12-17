table 99000761 Stop
{
    // version NAVW17.00

    Caption = 'Stop';
    DrillDownPageID = "Stop Codes";
    LookupPageID = "Stop Codes";

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

