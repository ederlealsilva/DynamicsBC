table 2000000187 "Tenant Profile Page Metadata"
{
    // version NAVW113.00

    Caption = 'Tenant Profile Page Metadata';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"App ID";Guid)
        {
            Caption = 'App ID';
        }
        field(2;"Profile ID";Code[30])
        {
            Caption = 'Profile ID';
            TableRelation = "Tenant Profile"."Profile ID";
        }
        field(3;"Page ID";Integer)
        {
            Caption = 'Page ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE ("Object Type"=CONST(Page));
        }
        field(4;"Page Metadata";BLOB)
        {
            Caption = 'Page Metadata';
        }
        field(5;"Page AL";BLOB)
        {
            Caption = 'Page AL';
        }
        field(6;Owner;Option)
        {
            Caption = 'Owner';
            OptionCaption = 'System,Tenant';
            OptionMembers = System,Tenant;
        }
    }

    keys
    {
        key(Key1;"Profile ID","Page ID","App ID",Owner)
        {
        }
    }

    fieldgroups
    {
    }
}

