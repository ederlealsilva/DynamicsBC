table 53 "Batch Processing Parameter Map"
{
    // version NAVW113.00

    Caption = 'Batch Processing Parameter Map';

    fields
    {
        field(1;"Record ID";RecordID)
        {
            Caption = 'Record ID';
            DataClassification = SystemMetadata;
        }
        field(2;"Batch ID";Guid)
        {
            Caption = 'Batch ID';
        }
    }

    keys
    {
        key(Key1;"Record ID")
        {
        }
    }

    fieldgroups
    {
    }
}

