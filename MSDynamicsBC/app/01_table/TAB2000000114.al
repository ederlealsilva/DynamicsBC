table 2000000114 "Document Service"
{
    // version NAVW113.00

    Caption = 'Document Service';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"Service ID";Code[30])
        {
            Caption = 'Service ID';
        }
        field(3;Description;Text[80])
        {
            Caption = 'Description';
        }
        field(5;Location;Text[250])
        {
            Caption = 'Location';
        }
        field(7;"User Name";Text[128])
        {
            Caption = 'User Name';
        }
        field(9;Password;Text[128])
        {
            Caption = 'Password';
        }
        field(11;"Document Repository";Text[250])
        {
            Caption = 'Document Repository';
        }
        field(13;Folder;Text[250])
        {
            Caption = 'Folder';
        }
    }

    keys
    {
        key(Key1;"Service ID")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown;"Service ID",Description)
        {
        }
    }
}

