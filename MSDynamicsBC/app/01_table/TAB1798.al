table 1798 "Data Migration Parameters"
{
    // version NAVW113.00

    Caption = 'Data Migration Parameters';
    ReplicateData = false;

    fields
    {
        field(1;"Key";Integer)
        {
            AutoIncrement = true;
            Caption = 'Key';
        }
        field(2;"Migration Type";Text[250])
        {
            Caption = 'Migration Type';
        }
        field(3;"Staging Table Migr. Codeunit";Integer)
        {
            Caption = 'Staging Table Migr. Codeunit';
            DataClassification = SystemMetadata;
        }
        field(4;"Staging Table RecId To Process";RecordID)
        {
            Caption = 'Staging Table RecId To Process';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1;"Key")
        {
        }
    }

    fieldgroups
    {
    }
}

