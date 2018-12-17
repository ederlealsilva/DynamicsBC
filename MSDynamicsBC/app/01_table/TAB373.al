table 373 "Dimension Entry Buffer"
{
    // version NAVW113.00

    Caption = 'Dimension Entry Buffer';
    ReplicateData = false;

    fields
    {
        field(1;"No.";Integer)
        {
            Caption = 'No.';
            DataClassification = SystemMetadata;
        }
        field(2;"Dimension Entry No.";Integer)
        {
            Caption = 'Dimension Entry No.';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
        key(Key2;"Dimension Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

