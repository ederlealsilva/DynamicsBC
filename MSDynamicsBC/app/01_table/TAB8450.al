table 8450 "Field Buffer"
{
    // version NAVW113.00

    Caption = 'Field Buffer';
    ReplicateData = false;

    fields
    {
        field(1;"Order";Integer)
        {
            Caption = 'Order';
            DataClassification = SystemMetadata;
        }
        field(2;"Table ID";Integer)
        {
            Caption = 'Table ID';
            DataClassification = SystemMetadata;
        }
        field(3;"Field ID";Integer)
        {
            Caption = 'Field ID';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1;"Order")
        {
        }
        key(Key2;"Table ID","Field ID")
        {
        }
    }

    fieldgroups
    {
    }
}

