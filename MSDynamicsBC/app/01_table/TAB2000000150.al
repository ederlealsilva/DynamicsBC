table 2000000150 "NAV App Object Metadata"
{
    // version NAVW113.00

    Caption = 'NAV App Object Metadata';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"App Package ID";Guid)
        {
            Caption = 'App Package ID';
        }
        field(2;"Object Type";Option)
        {
            Caption = 'Object Type';
            OptionCaption = ',Table,,Report,,Codeunit,XMLport,MenuSuite,Page,Query,,,,,PageExtension,TableExtension';
            OptionMembers = ,"Table",,"Report",,"Codeunit","XMLport",MenuSuite,"Page","Query",,,,,"PageExtension","TableExtension";
        }
        field(3;"Object ID";Integer)
        {
            Caption = 'Object ID';
        }
        field(4;"Metadata Format";Option)
        {
            Caption = 'Metadata Format';
            OptionCaption = 'Full,Delta';
            OptionMembers = Full,Delta;
        }
        field(5;Metadata;BLOB)
        {
            Caption = 'Metadata';
        }
        field(6;"User Code";BLOB)
        {
            Caption = 'User Code';
        }
        field(7;"User AL Code";BLOB)
        {
            Caption = 'User AL Code';
        }
        field(8;"Metadata Version";Integer)
        {
            Caption = 'Metadata Version';
        }
        field(9;"Object Subtype";Text[30])
        {
            Caption = 'Object Subtype';
        }
        field(10;"Object Name";Text[30])
        {
            Caption = 'Object Name';
        }
        field(11;"Metadata Hash";Text[50])
        {
            Caption = 'Metadata Hash';
        }
    }

    keys
    {
        key(Key1;"App Package ID","Object Type","Object ID")
        {
        }
    }

    fieldgroups
    {
    }
}

