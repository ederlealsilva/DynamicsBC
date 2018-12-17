table 2000000111 "Session Event"
{
    // version NAVW113.00

    Caption = 'Session Event';
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
            ValidateTableRelation = false;
        }
        field(2;"Server Instance ID";Integer)
        {
            Caption = 'Server Instance ID';
            TableRelation = "Server Instance"."Server Instance ID";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(3;"Session ID";Integer)
        {
            Caption = 'Session ID';
        }
        field(4;"Event Type";Option)
        {
            Caption = 'Event Type';
            OptionCaption = 'Logon,Logoff,Start,Stop,Close';
            OptionMembers = Logon,Logoff,Start,Stop,Close;
        }
        field(5;"Event Datetime";DateTime)
        {
            Caption = 'Event Datetime';
        }
        field(6;"Client Type";Option)
        {
            Caption = 'Client Type';
            OptionCaption = 'Windows Client,SharePoint Client,Web Service,Client Service,NAS,Background,Management Client,Web Client,Unknown,Tablet,Phone,Desktop';
            OptionMembers = "Windows Client","SharePoint Client","Web Service","Client Service",NAS,Background,"Management Client","Web Client",Unknown,Tablet,Phone,Desktop;
        }
        field(7;"Database Name";Text[250])
        {
            Caption = 'Database Name';
        }
        field(8;"Client Computer Name";Text[250])
        {
            Caption = 'Client Computer Name';
        }
        field(9;"User ID";Text[132])
        {
            Caption = 'User ID';
        }
        field(10;Comment;Text[132])
        {
            Caption = 'Comment';
        }
        field(11;"Session Unique ID";Guid)
        {
            Caption = 'Session Unique ID';
        }
    }

    keys
    {
        key(Key1;"User SID","Server Instance ID","Session ID","Event Datetime","Event Type")
        {
        }
        key(Key2;"Session Unique ID")
        {
        }
        key(Key3;"Event Datetime")
        {
        }
    }

    fieldgroups
    {
    }
}

