table 2000 "Time Series Buffer"
{
    // version NAVW113.00

    Caption = 'Time Series Buffer';
    ReplicateData = false;

    fields
    {
        field(1;"Group ID";Code[50])
        {
            Caption = 'Group ID';
            DataClassification = SystemMetadata;
        }
        field(2;"Period No.";Integer)
        {
            Caption = 'Period No.';
            DataClassification = SystemMetadata;
        }
        field(3;"Period Start Date";Date)
        {
            Caption = 'Period Start Date';
            DataClassification = SystemMetadata;
        }
        field(4;Value;Decimal)
        {
            Caption = 'Value';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1;"Group ID","Period No.")
        {
        }
    }

    fieldgroups
    {
    }
}

