table 2000000074 "Profile Metadata"
{
    // version NAVW113.00

    Caption = 'Profile Metadata';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(3;"Profile ID";Code[30])
        {
            Caption = 'Profile ID';
            TableRelation = Profile."Profile ID";
        }
        field(6;"Page ID";Integer)
        {
            Caption = 'Page ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE ("Object Type"=CONST(Page));
        }
        field(9;Description;Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE ("Object Type"=CONST(Page),
                                                                           "Object ID"=FIELD("Page ID")));
            Caption = 'Description';
            FieldClass = FlowField;
        }
        field(12;Date;Date)
        {
            Caption = 'Date';
        }
        field(15;Time;Time)
        {
            Caption = 'Time';
        }
        field(18;"Personalization ID";Code[40])
        {
            Caption = 'Personalization ID';
        }
        field(21;"Page Metadata Delta";BLOB)
        {
            Caption = 'Page Metadata Delta';
        }
    }

    keys
    {
        key(Key1;"Profile ID","Page ID","Personalization ID")
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

