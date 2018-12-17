table 7828 "MS-QBO Sync Buffer"
{
    // version NAVW113.00

    Caption = 'MS-QBO Sync Buffer';
    ObsoleteReason = 'replacing burntIn Extension tables with V2 Extension';
    ObsoleteState = Pending;
    ReplicateData = false;

    fields
    {
        field(1;Id;BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Id';
            DataClassification = SystemMetadata;
        }
        field(2;"Record Id";RecordID)
        {
            Caption = 'Record Id';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1;Id)
        {
        }
        key(Key2;"Record Id")
        {
        }
    }

    fieldgroups
    {
    }
}

