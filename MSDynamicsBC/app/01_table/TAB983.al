table 983 "Document Search Result"
{
    // version NAVW17.10

    Caption = 'Document Search Result';
    DataCaptionFields = "Doc. No.",Description;

    fields
    {
        field(1;"Doc. Type";Integer)
        {
            Caption = 'Doc. Type';
        }
        field(2;"Doc. No.";Code[20])
        {
            Caption = 'Doc. No.';
        }
        field(3;Amount;Decimal)
        {
            Caption = 'Amount';
        }
        field(4;"Table ID";Integer)
        {
            Caption = 'Table ID';
        }
        field(5;Description;Text[50])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1;"Doc. Type","Doc. No.","Table ID")
        {
        }
        key(Key2;Amount)
        {
        }
        key(Key3;Description)
        {
        }
        key(Key4;"Doc. No.")
        {
        }
    }

    fieldgroups
    {
    }
}

