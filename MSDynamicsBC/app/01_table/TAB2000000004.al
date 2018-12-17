table 2000000004 "Permission Set"
{
    // version NAVW113.00

    Caption = 'Permission Set';
    DataCaptionFields = "Role ID",Name;
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"Role ID";Code[20])
        {
            Caption = 'Role ID';
        }
        field(2;Name;Text[30])
        {
            Caption = 'Name';
        }
        field(3;Hash;Text[250])
        {
            Caption = 'Hash';
        }
    }

    keys
    {
        key(Key1;"Role ID")
        {
        }
    }

    fieldgroups
    {
    }
}

