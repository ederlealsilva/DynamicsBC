table 5217 "Grounds for Termination"
{
    // version NAVW17.00

    Caption = 'Grounds for Termination';
    DrillDownPageID = "Grounds for Termination";
    LookupPageID = "Grounds for Termination";

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

