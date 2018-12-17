table 2000000170 "Configuration Package File"
{
    // version NAVW113.00

    Caption = 'Configuration Package File';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
        }
        field(2;Name;Text[50])
        {
            Caption = 'Name';
        }
        field(3;"Language ID";Integer)
        {
            Caption = 'Language ID';
        }
        field(4;"Setup Type";Option)
        {
            Caption = 'Setup Type';
            OptionCaption = 'Company,Application,Other';
            OptionMembers = Company,Application,Other;
        }
        field(5;"Processing Order";Integer)
        {
            Caption = 'Processing Order';
        }
        field(6;Package;BLOB)
        {
            Caption = 'Package';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }
}

