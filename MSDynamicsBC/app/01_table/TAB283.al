table 283 "Line Number Buffer"
{
    // version NAVW113.00

    Caption = 'Line Number Buffer';
    ReplicateData = false;

    fields
    {
        field(1;"Old Line Number";Integer)
        {
            Caption = 'Old Line Number';
            DataClassification = SystemMetadata;
        }
        field(2;"New Line Number";Integer)
        {
            Caption = 'New Line Number';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1;"Old Line Number")
        {
        }
    }

    fieldgroups
    {
    }
}

