table 2000000130 Device
{
    // version NAVW113.00

    Caption = 'Device';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"MAC Address";Code[20])
        {
            Caption = 'MAC Address';
        }
        field(2;Name;Text[80])
        {
            Caption = 'Name';
        }
        field(3;"Device Type";Option)
        {
            Caption = 'Device Type';
            OptionCaption = 'Full,Limited,ISV,ISV Functional';
            OptionMembers = Full,Limited,ISV,"ISV Functional";
        }
        field(4;Enabled;Boolean)
        {
            Caption = 'Enabled';
        }
    }

    keys
    {
        key(Key1;"MAC Address")
        {
        }
    }

    fieldgroups
    {
    }
}

