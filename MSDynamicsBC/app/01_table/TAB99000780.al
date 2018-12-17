table 99000780 "Capacity Unit of Measure"
{
    // version NAVW17.00

    Caption = 'Capacity Unit of Measure';
    DrillDownPageID = "Capacity Units of Measure";
    LookupPageID = "Capacity Units of Measure";

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
        field(3;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = ' ,100/Hour,Minutes,Hours,Days';
            OptionMembers = " ","100/Hour",Minutes,Hours,Days;
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

