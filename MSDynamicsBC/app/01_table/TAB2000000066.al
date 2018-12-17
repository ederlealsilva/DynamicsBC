table 2000000066 "Style Sheet"
{
    // version NAVW17.00

    Caption = 'Style Sheet';
    DataPerCompany = false;

    fields
    {
        field(1;"Style Sheet ID";Guid)
        {
            Caption = 'Style Sheet ID';
        }
        field(2;"Object Type";Option)
        {
            Caption = 'Object Type';
            OptionCaption = 'Form,Report,Page';
            OptionMembers = Form,"Report","Page";
        }
        field(3;"Object ID";Integer)
        {
            Caption = 'Object ID';
            TableRelation = Object.ID WHERE (Type=FIELD("Object Type"));
        }
        field(4;"Program ID";Guid)
        {
            Caption = 'Program ID';
        }
        field(5;Name;Text[250])
        {
            Caption = 'Name';
        }
        field(6;"Style Sheet";BLOB)
        {
            Caption = 'Style Sheet';
        }
        field(7;Date;Date)
        {
            Caption = 'Date';
        }
    }

    keys
    {
        key(Key1;"Style Sheet ID")
        {
        }
        key(Key2;"Object Type","Object ID","Program ID")
        {
        }
    }

    fieldgroups
    {
    }
}

