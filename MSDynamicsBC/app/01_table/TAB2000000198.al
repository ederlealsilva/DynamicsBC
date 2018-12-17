table 2000000198 "Page Documentation"
{
    // version NAVW110.0

    Caption = 'Page Documentation';
    DataPerCompany = false;

    fields
    {
        field(1;"Page ID";Integer)
        {
            Caption = 'Page ID';
        }
        field(2;"Relative Path";Text[250])
        {
            Caption = 'Relative Path';
        }
    }

    keys
    {
        key(Key1;"Page ID")
        {
        }
    }

    fieldgroups
    {
    }
}

