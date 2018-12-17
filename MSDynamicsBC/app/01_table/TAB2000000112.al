table 2000000112 "Server Instance"
{
    // version NAVW113.00

    Caption = 'Server Instance';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"Server Instance ID";Integer)
        {
            AutoIncrement = true;
            Caption = 'Server Instance ID';
        }
        field(2;"Service Name";Text[250])
        {
            Caption = 'Service Name';
        }
        field(3;"Server Computer Name";Text[250])
        {
            Caption = 'Server Computer Name';
        }
        field(4;"Last Active";DateTime)
        {
            Caption = 'Last Active';
        }
        field(5;"Server Instance Name";Text[250])
        {
            Caption = 'Server Instance Name';
        }
        field(6;"Server Port";Integer)
        {
            Caption = 'Server Port';
        }
        field(7;"Management Port";Integer)
        {
            Caption = 'Management Port';
        }
        field(8;Status;Option)
        {
            Caption = 'Status';
            OptionCaption = 'Started,Stopped,Crashed';
            OptionMembers = Started,Stopped,Crashed;
        }
        field(9;"Last Tenant Config Version";BigInteger)
        {
            Caption = 'Last Tenant Config Version';
        }
    }

    keys
    {
        key(Key1;"Server Instance ID")
        {
        }
    }

    fieldgroups
    {
    }
}

