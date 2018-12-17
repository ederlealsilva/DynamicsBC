table 2000000179 "OData Edm Type"
{
    // version NAVW111.00

    Caption = 'OData Edm Type';
    DataPerCompany = false;

    fields
    {
        field(1;"Key";Code[50])
        {
            Caption = 'Key';
        }
        field(2;Description;Text[250])
        {
            Caption = 'Description';
        }
        field(10;"Edm Xml";BLOB)
        {
            Caption = 'Edm Xml';
            SubType = UserDefined;
        }
    }

    keys
    {
        key(Key1;"Key")
        {
        }
    }

    fieldgroups
    {
    }
}

