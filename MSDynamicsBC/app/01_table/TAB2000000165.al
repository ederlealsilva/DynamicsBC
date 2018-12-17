table 2000000165 "Tenant Permission Set"
{
    // version NAVW113.00

    Caption = 'Tenant Permission Set';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"App ID";Guid)
        {
            Caption = 'App ID';
        }
        field(2;"Role ID";Code[20])
        {
            Caption = 'Role ID';
        }
        field(3;Name;Text[30])
        {
            Caption = 'Name';
        }
    }

    keys
    {
        key(Key1;"App ID","Role ID")
        {
        }
    }

    fieldgroups
    {
    }
}

