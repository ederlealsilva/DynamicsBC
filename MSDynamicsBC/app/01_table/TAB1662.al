table 1662 "Payroll Import Buffer"
{
    // version NAVW113.00

    Caption = 'Payroll Import Buffer';
    ReplicateData = false;

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }
        field(10;"Transaction date";Date)
        {
            Caption = 'Transaction date';
            DataClassification = SystemMetadata;
        }
        field(11;"Account No.";Code[20])
        {
            Caption = 'Account No.';
            DataClassification = SystemMetadata;
        }
        field(12;Amount;Decimal)
        {
            Caption = 'Amount';
            DataClassification = SystemMetadata;
        }
        field(13;Description;Text[50])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

