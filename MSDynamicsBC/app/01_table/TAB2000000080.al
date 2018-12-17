table 2000000080 "Page Data Personalization"
{
    // version NAVW113.00

    Caption = 'Page Data Personalization';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(3;"User SID";Guid)
        {
            Caption = 'User SID';
            TableRelation = User."User Security ID";
        }
        field(6;"User ID";Code[50])
        {
            CalcFormula = Lookup(User."User Name" WHERE ("User Security ID"=FIELD("User SID")));
            Caption = 'User ID';
            FieldClass = FlowField;
        }
        field(9;"Object Type";Option)
        {
            Caption = 'Object Type';
            OptionCaption = ',,,Report,,,XMLport,,Page';
            OptionMembers = ,,,"Report",,,"XMLport",,"Page";
        }
        field(12;"Object ID";Integer)
        {
            Caption = 'Object ID';
            TableRelation = Object.ID WHERE (Type=FIELD("Object Type"));
        }
        field(15;Date;Date)
        {
            Caption = 'Date';
        }
        field(18;Time;Time)
        {
            Caption = 'Time';
        }
        field(21;"Personalization ID";Code[40])
        {
            Caption = 'Personalization ID';
        }
        field(24;ValueName;Code[40])
        {
            Caption = 'ValueName';
        }
        field(27;Value;BLOB)
        {
            Caption = 'Value';
        }
    }

    keys
    {
        key(Key1;"User SID","Object Type","Object ID","Personalization ID",ValueName)
        {
        }
        key(Key2;Date)
        {
        }
    }

    fieldgroups
    {
    }
}

