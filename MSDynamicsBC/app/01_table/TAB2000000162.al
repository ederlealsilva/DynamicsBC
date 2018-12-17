table 2000000162 "NAV App Capabilities"
{
    // version NAVW113.00

    Caption = 'NAV App Capabilities';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"Package ID";Guid)
        {
            Caption = 'Package ID';
        }
        field(2;"Capability ID";Integer)
        {
            Caption = 'Capability ID';
        }
    }

    keys
    {
        key(Key1;"Package ID","Capability ID")
        {
        }
    }

    fieldgroups
    {
    }
}

