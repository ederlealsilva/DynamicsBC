table 5210 "Cause of Inactivity"
{
    // version NAVW17.00

    Caption = 'Cause of Inactivity';
    DrillDownPageID = "Causes of Inactivity";
    LookupPageID = "Causes of Inactivity";

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

