table 99000750 "Work Shift"
{
    // version NAVW17.00

    Caption = 'Work Shift';
    DrillDownPageID = "Work Shifts";
    LookupPageID = "Work Shifts";

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

