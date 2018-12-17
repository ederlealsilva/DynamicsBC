table 9999 "Upgrade Tags"
{
    // version NAVW113.00

    Caption = 'Upgrade Tags';
    DataClassification = SystemMetadata;
    DataPerCompany = false;

    fields
    {
        field(1;Tag;Code[250])
        {
            Caption = 'Tag';
            DataClassification = SystemMetadata;
        }
        field(2;"Tag Timestamp";DateTime)
        {
            Caption = 'Tag Timestamp';
            DataClassification = SystemMetadata;
        }
        field(3;Company;Code[30])
        {
            Caption = 'Company';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1;Tag,Company)
        {
        }
    }

    fieldgroups
    {
    }
}

