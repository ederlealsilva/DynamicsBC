table 2000000197 "Token Cache"
{
    // version NAVW113.00

    Caption = 'Token Cache';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"User Security ID";Guid)
        {
            Caption = 'User Security ID';
            TableRelation = User."User Security ID";
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(2;"User Unique ID";Guid)
        {
            Caption = 'User Unique ID';
        }
        field(3;"Tenant ID";Guid)
        {
            Caption = 'Tenant ID';
        }
        field(4;"Cache Write Time";DateTime)
        {
            Caption = 'Cache Write Time';
        }
        field(5;"Cache Data";BLOB)
        {
            Caption = 'Cache Data';
        }
        field(6;"User String Unique ID";Text[80])
        {
            Caption = 'User String Unique ID';
        }
        field(7;"Tenant String Unique ID";Text[80])
        {
            Caption = 'Tenant String Unique ID';
        }
    }

    keys
    {
        key(Key1;"User Security ID")
        {
        }
    }

    fieldgroups
    {
    }
}

