table 2000000075 "User Metadata"
{
    // version NAVW113.00

    Caption = 'User Metadata';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(3;"User SID";Guid)
        {
            Caption = 'User SID';
            TableRelation = User."User Security ID";
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(6;"User ID";Code[50])
        {
            CalcFormula = Lookup(User."User Name" WHERE ("User Security ID"=FIELD("User SID")));
            Caption = 'User ID';
            FieldClass = FlowField;
        }
        field(9;"Page ID";Integer)
        {
            Caption = 'Page ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE ("Object Type"=CONST(Page));
        }
        field(12;Description;Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE ("Object Type"=CONST(Page),
                                                                           "Object ID"=FIELD("Page ID")));
            Caption = 'Description';
            FieldClass = FlowField;
        }
        field(15;Date;Date)
        {
            Caption = 'Date';
        }
        field(18;Time;Time)
        {
            Caption = 'Time';
        }
        field(21;"Personalization ID";Code[40])
        {
            Caption = 'Personalization ID';
        }
        field(24;"Page Metadata Delta";BLOB)
        {
            Caption = 'Page Metadata Delta';
        }
    }

    keys
    {
        key(Key1;"User SID","Page ID","Personalization ID")
        {
        }
        key(Key2;Date)
        {
        }
    }

    fieldgroups
    {
    }
}

