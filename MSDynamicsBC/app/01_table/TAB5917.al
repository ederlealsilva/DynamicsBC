table 5917 "Fault Reason Code"
{
    // version NAVW17.00

    Caption = 'Fault Reason Code';
    DataCaptionFields = "Code",Description;
    DrillDownPageID = "Fault Reason Codes";
    LookupPageID = "Fault Reason Codes";

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
        field(3;"Exclude Warranty Discount";Boolean)
        {
            Caption = 'Exclude Warranty Discount';
        }
        field(4;"Exclude Contract Discount";Boolean)
        {
            Caption = 'Exclude Contract Discount';
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
        fieldgroup(DropDown;"Code",Description,"Exclude Warranty Discount","Exclude Contract Discount")
        {
        }
    }
}

