table 1445 "Headline RC Administrator"
{
    // version NAVW113.00

    Caption = 'Headline RC Administrator';

    fields
    {
        field(1;"Key";Code[10])
        {
            Caption = 'Key';
            DataClassification = SystemMetadata;
        }
        field(2;"Workdate for computations";Date)
        {
            Caption = 'Workdate for computations';
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

