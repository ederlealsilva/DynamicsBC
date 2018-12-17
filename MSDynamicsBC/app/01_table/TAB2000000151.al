table 2000000151 "NAV App Tenant App"
{
    // version NAVW113.00

    Caption = 'NAV App Tenant App';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"Tenant ID";Text[128])
        {
            Caption = 'Tenant ID';
        }
        field(2;"App Package ID";Guid)
        {
            Caption = 'App Package ID';
        }
    }

    keys
    {
        key(Key1;"Tenant ID","App Package ID")
        {
        }
    }

    fieldgroups
    {
    }
}

