table 5057 "Industry Group"
{
    // version NAVW17.00

    Caption = 'Industry Group';
    DataCaptionFields = "Code",Description;
    LookupPageID = "Industry Groups";

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
        field(3;"No. of Contacts";Integer)
        {
            CalcFormula = Count("Contact Industry Group" WHERE ("Industry Group Code"=FIELD(Code)));
            Caption = 'No. of Contacts';
            Editable = false;
            FieldClass = FlowField;
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

