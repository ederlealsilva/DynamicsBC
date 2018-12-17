table 2000000107 "Isolated Storage"
{
    // version NAVW113.00

    Caption = 'Isolated Storage';
    DataPerCompany = false;

    fields
    {
        field(1;"App Id";Guid)
        {
            Caption = 'App Id';
        }
        field(2;Scope;Option)
        {
            Caption = 'Scope';
            OptionCaption = 'Module,User,Company,UserAndCompany';
            OptionMembers = Module,User,Company,UserAndCompany;
        }
        field(3;"Company Name";Text[30])
        {
            Caption = 'Company Name';
            TableRelation = Company.Name;
        }
        field(4;"User Id";Guid)
        {
            Caption = 'User Id';
            TableRelation = User."User Security ID";
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(5;"Key";Text[200])
        {
            Caption = 'Key';
        }
        field(6;Value;BLOB)
        {
            Caption = 'Value';
        }
    }

    keys
    {
        key(Key1;"App Id",Scope,"Company Name","User Id","Key")
        {
        }
    }

    fieldgroups
    {
    }
}

