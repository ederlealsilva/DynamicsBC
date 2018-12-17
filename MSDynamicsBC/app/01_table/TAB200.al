table 200 "Work Type"
{
    // version NAVW17.00

    Caption = 'Work Type';
    DrillDownPageID = "Work Types";
    LookupPageID = "Work Types";

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
        field(3;"Unit of Measure Code";Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Unit of Measure";
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
        fieldgroup(DropDown;"Code",Description,"Unit of Measure Code")
        {
        }
    }
}

