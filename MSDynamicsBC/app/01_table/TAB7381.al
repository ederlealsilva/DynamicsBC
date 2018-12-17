table 7381 "Phys. Invt. Counting Period"
{
    // version NAVW17.00

    Caption = 'Phys. Invt. Counting Period';
    LookupPageID = "Phys. Invt. Counting Periods";

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
        field(3;"Count Frequency per Year";Integer)
        {
            Caption = 'Count Frequency per Year';
            InitValue = 1;
            MinValue = 1;
            NotBlank = true;
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
        fieldgroup(DropDown;"Code",Description,"Count Frequency per Year")
        {
        }
    }
}

