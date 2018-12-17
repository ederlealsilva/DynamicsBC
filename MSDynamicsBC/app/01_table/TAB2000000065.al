table 2000000065 "Send-To Program"
{
    // version NAVW16.00

    Caption = 'Send-To Program';
    DataPerCompany = false;

    fields
    {
        field(1;"Program ID";Guid)
        {
            Caption = 'Program ID';
        }
        field(2;Executable;Text[250])
        {
            Caption = 'Executable';
        }
        field(3;Parameter;Text[250])
        {
            Caption = 'Parameter';
        }
        field(4;Name;Text[250])
        {
            Caption = 'Name';
        }
    }

    keys
    {
        key(Key1;"Program ID")
        {
        }
    }

    fieldgroups
    {
    }
}

