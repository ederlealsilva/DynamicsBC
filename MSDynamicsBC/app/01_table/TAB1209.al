table 1209 "Credit Trans Re-export History"
{
    // version NAVW113.00

    Caption = 'Credit Trans Re-export History';

    fields
    {
        field(1;"No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'No.';
        }
        field(2;"Credit Transfer Register No.";Integer)
        {
            Caption = 'Credit Transfer Register No.';
            TableRelation = "Credit Transfer Register";
        }
        field(3;"Re-export Date";DateTime)
        {
            Caption = 'Re-export Date';
        }
        field(4;"Re-exported By";Code[50])
        {
            Caption = 'Re-exported By';
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Re-export Date" := CurrentDateTime;
        "Re-exported By" := UserId;
    end;
}

