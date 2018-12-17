table 2000000120 User
{
    // version NAVW113.00

    Caption = 'User';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"User Security ID";Guid)
        {
            Caption = 'User Security ID';
        }
        field(2;"User Name";Code[50])
        {
            Caption = 'User Name';
        }
        field(3;"Full Name";Text[80])
        {
            Caption = 'Full Name';
        }
        field(4;State;Option)
        {
            Caption = 'State';
            OptionCaption = 'Enabled,Disabled';
            OptionMembers = Enabled,Disabled;
        }
        field(5;"Expiry Date";DateTime)
        {
            Caption = 'Expiry Date';
        }
        field(7;"Windows Security ID";Text[119])
        {
            Caption = 'Windows Security ID';
        }
        field(8;"Change Password";Boolean)
        {
            Caption = 'Change Password';
        }
        field(10;"License Type";Option)
        {
            Caption = 'License Type';
            OptionCaption = 'Full User,Limited User,Device Only User,Windows Group,External User';
            OptionMembers = "Full User","Limited User","Device Only User","Windows Group","External User";
        }
        field(11;"Authentication Email";Text[250])
        {
            Caption = 'Authentication Email';
        }
        field(14;"Contact Email";Text[250])
        {
            Caption = 'Contact Email';
        }
        field(15;"Exchange Identifier";Text[250])
        {
            Caption = 'Exchange Identifier';
        }
        field(16;"Application ID";Guid)
        {
            Caption = 'Application ID';
        }
    }

    keys
    {
        key(Key1;"User Security ID")
        {
        }
        key(Key2;"User Name")
        {
        }
        key(Key3;"Windows Security ID")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown;"User Name")
        {
        }
    }
}

