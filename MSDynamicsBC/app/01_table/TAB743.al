table 743 "VAT Report Setup"
{
    // version NAVW111.00

    Caption = 'VAT Report Setup';
    LookupPageID = "VAT Report Setup";

    fields
    {
        field(1;"Primary key";Code[10])
        {
            Caption = 'Primary key';
        }
        field(2;"No. Series";Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
        field(3;"Modify Submitted Reports";Boolean)
        {
            Caption = 'Modify Submitted Reports';
        }
        field(4;"VAT Return No. Series";Code[20])
        {
            Caption = 'VAT Return No. Series';
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(Key1;"Primary key")
        {
        }
    }

    fieldgroups
    {
    }
}

