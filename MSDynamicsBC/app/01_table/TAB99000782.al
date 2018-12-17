table 99000782 "Standard Task Personnel"
{
    // version NAVW16.00

    Caption = 'Standard Task Personnel';

    fields
    {
        field(1;"Standard Task Code";Code[10])
        {
            Caption = 'Standard Task Code';
            NotBlank = true;
            TableRelation = "Standard Task";
        }
        field(2;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(4;"No.";Code[20])
        {
            Caption = 'No.';
        }
        field(5;Description;Text[50])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1;"Standard Task Code","Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

