table 8402 "Record Set Buffer"
{
    // version NAVW113.00

    Caption = 'Record Set Buffer';
    ReplicateData = false;

    fields
    {
        field(1;No;Integer)
        {
            AutoIncrement = true;
            Caption = 'No';
            DataClassification = SystemMetadata;
        }
        field(2;"Value RecordID";RecordID)
        {
            Caption = 'Value RecordID';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1;No)
        {
        }
    }

    fieldgroups
    {
    }
}

