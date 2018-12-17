table 8650 "DataExch-RapidStart Buffer"
{
    // version NAVW113.00

    Caption = 'DataExch-RapidStart Buffer';
    ReplicateData = false;

    fields
    {
        field(1;"Node ID";Text[250])
        {
            Caption = 'Node ID';
            DataClassification = SystemMetadata;
        }
        field(2;"RapidStart No.";Integer)
        {
            Caption = 'RapidStart No.';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1;"Node ID")
        {
        }
    }

    fieldgroups
    {
    }
}

