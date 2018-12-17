table 2000000183 "Tenant Media Set"
{
    // version NAVW111.00

    Caption = 'Tenant Media Set';
    DataPerCompany = false;

    fields
    {
        field(1;ID;Guid)
        {
            Caption = 'ID';
        }
        field(2;"Media ID";Media)
        {
            Caption = 'Media ID';
        }
        field(3;"Company Name";Text[30])
        {
            Caption = 'Company Name';
            TableRelation = Company.Name;
        }
        field(4;"Media Index";BigInteger)
        {
            Caption = 'Media Index';
        }
    }

    keys
    {
        key(Key1;ID,"Media ID")
        {
        }
        key(Key2;"Media Index")
        {
        }
        key(Key3;"Company Name")
        {
        }
    }

    fieldgroups
    {
    }
}

