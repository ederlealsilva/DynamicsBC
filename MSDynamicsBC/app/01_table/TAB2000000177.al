table 2000000177 "Tenant Profile"
{
    // version NAVW113.00

    Caption = 'Tenant Profile';
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
        }
        field(3;Description;Text[250])
        {
            Caption = 'Description';
        }
        field(4;"Role Center ID";Integer)
        {
            Caption = 'Role Center ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE ("Object Type"=CONST(Page));
        }
        field(5;"Default Role Center";Boolean)
        {
            Caption = 'Default Role Center';
        }
        field(6;"Disable Personalization";Boolean)
        {
            Caption = 'Disable Personalization';
        }
    }

    keys
    {
        key(Key1;"App ID","Profile ID")
        {
        }
    }

    fieldgroups
    {
    }
}

