table 2000000188 "User Page Metadata"
{
    // version NAVW113.00

    Caption = 'User Page Metadata';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"User SID";Guid)
        {
            Caption = 'User SID';
            TableRelation = User."User Security ID";
            //This property is currently not supported
            //TestTableRelation = false;
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
        key(Key1;"User SID","Page ID")
        {
        }
    }

    fieldgroups
    {
    }
}

