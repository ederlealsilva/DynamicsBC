table 2000000067 "User Default Style Sheet"
{
    // version NAVW17.00

    Caption = 'User Default Style Sheet';
    DataPerCompany = false;

    fields
    {
        field(1;"User ID";Guid)
        {
            Caption = 'User ID';
            TableRelation = User."User Security ID";
            //This property is currently not supported
            //TestTableRelation = false;
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
        field(5;"Style Sheet ID";Guid)
        {
            Caption = 'Style Sheet ID';
        }
    }

    keys
    {
        key(Key1;"User ID","Object Type","Object ID","Program ID")
        {
        }
    }

    fieldgroups
    {
    }
}

