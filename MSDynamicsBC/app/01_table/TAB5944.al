table 5944 "Troubleshooting Line"
{
    // version NAVW16.00

    Caption = 'Troubleshooting Line';

    fields
    {
        field(1;"No.";Code[20])
        {
            Caption = 'No.';
            TableRelation = "Troubleshooting Header";
        }
        field(2;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(3;Comment;Text[80])
        {
            Caption = 'Comment';
        }
    }

    keys
    {
        key(Key1;"No.","Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

