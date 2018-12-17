table 2000000186 "Profile Page Metadata"
{
    // version NAVW113.00

    Caption = 'Profile Page Metadata';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"Profile ID";Code[30])
        {
            Caption = 'Profile ID';
            TableRelation = Profile."Profile ID";
        }
        field(2;"Page ID";Integer)
        {
            Caption = 'Page ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE ("Object Type"=CONST(Page));
        }
        field(3;"Page Metadata";BLOB)
        {
            Caption = 'Page Metadata';
        }
        field(4;"Page AL";BLOB)
        {
            Caption = 'Page AL';
        }
    }

    keys
    {
        key(Key1;"Profile ID","Page ID")
        {
        }
    }

    fieldgroups
    {
    }
}

