table 2000000196 "Object Options"
{
    // version NAVW113.00

    Caption = 'Object Options';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"Parameter Name";Text[50])
        {
            Caption = 'Parameter Name';
        }
        field(2;"Object ID";Integer)
        {
            Caption = 'Object ID';
        }
        field(3;"Object Type";Option)
        {
            Caption = 'Object Type';
            OptionCaption = ',,,Report,,,XMLport';
            OptionMembers = ,,,"Report",,,"XMLport";
        }
        field(4;"Company Name";Text[30])
        {
            Caption = 'Company Name';
            TableRelation = Company.Name;
        }
        field(5;"User Name";Code[50])
        {
            Caption = 'User Name';
        }
        field(6;"Option Data";BLOB)
        {
            Caption = 'Option Data';
            SubType = UserDefined;
        }
        field(7;"Public Visible";Boolean)
        {
            Caption = 'Public Visible';
        }
        field(8;"Temporary";Boolean)
        {
            Caption = 'Temporary';
        }
        field(9;"Created By";Code[50])
        {
            Caption = 'Created By';
        }
    }

    keys
    {
        key(Key1;"Parameter Name","Object ID","Object Type","User Name","Company Name")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown;"Parameter Name")
        {
        }
    }
}

