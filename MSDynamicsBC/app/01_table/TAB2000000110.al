table 2000000110 "Active Session"
{
    // version NAVW113.00

    Caption = 'Active Session';
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
        field(2;"Server Instance ID";Integer)
        {
            Caption = 'Server Instance ID';
            TableRelation = "Server Instance"."Server Instance ID";
        }
        field(3;"Session ID";Integer)
        {
            Caption = 'Session ID';
        }
        field(4;"Server Instance Name";Text[250])
        {
            Caption = 'Server Instance Name';
        }
        field(5;"Server Computer Name";Text[250])
        {
            Caption = 'Server Computer Name';
        }
        field(6;"User ID";Text[132])
        {
            Caption = 'User ID';
        }
        field(7;"Client Type";Option)
        {
            Caption = 'Client Type';
            OptionCaption = 'Windows Client,SharePoint Client,Web Service,Client Service,NAS,Background,Management Client,Web Client,Unknown,Tablet,Phone,Desktop';
            OptionMembers = "Windows Client","SharePoint Client","Web Service","Client Service",NAS,Background,"Management Client","Web Client",Unknown,Tablet,Phone,Desktop;
        }
        field(8;"Client Computer Name";Text[250])
        {
            Caption = 'Client Computer Name';
        }
        field(9;"Login Datetime";DateTime)
        {
            Caption = 'Login Datetime';
        }
        field(10;"Database Name";Text[250])
        {
            Caption = 'Database Name';
        }
        field(11;"Session Unique ID";Guid)
        {
            Caption = 'Session Unique ID';
        }
    }

    keys
    {
        key(Key1;"Server Instance ID","Session ID")
        {
        }
        key(Key2;"Login Datetime")
        {
        }
        key(Key3;"User SID","Client Type")
        {
        }
    }

    fieldgroups
    {
    }
}

