table 2000000168 "Tenant Web Service"
{
    // version NAVW113.00

    Caption = 'Tenant Web Service';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(3;"Object Type";Option)
        {
            Caption = 'Object Type';
            OptionCaption = ',,,,,Codeunit,,,Page,Query';
            OptionMembers = ,,,,,"Codeunit",,,"Page","Query";
        }
        field(6;"Object ID";Integer)
        {
            Caption = 'Object ID';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=FIELD("Object Type"));
        }
        field(9;"Service Name";Text[250])
        {
            Caption = 'Service Name';
        }
        field(12;Published;Boolean)
        {
            Caption = 'Published';
        }
    }

    keys
    {
        key(Key1;"Object Type","Service Name")
        {
        }
        key(Key2;"Object Type","Object ID")
        {
        }
    }

    fieldgroups
    {
    }
}

