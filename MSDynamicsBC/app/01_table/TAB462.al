table 462 "Payment Term Translation"
{
    // version NAVW16.00

    Caption = 'Payment Term Translation';

    fields
    {
        field(1;"Payment Term";Code[10])
        {
            Caption = 'Payment Term';
            TableRelation = "Payment Terms";
        }
        field(2;"Language Code";Code[10])
        {
            Caption = 'Language Code';
            TableRelation = Language;
        }
        field(3;Description;Text[50])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1;"Payment Term","Language Code")
        {
        }
    }

    fieldgroups
    {
    }
}

