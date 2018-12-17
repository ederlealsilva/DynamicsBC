table 5212 "Employee Statistics Group"
{
    // version NAVW17.00

    Caption = 'Employee Statistics Group';
    DrillDownPageID = "Employee Statistics Groups";
    LookupPageID = "Employee Statistics Groups";

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

