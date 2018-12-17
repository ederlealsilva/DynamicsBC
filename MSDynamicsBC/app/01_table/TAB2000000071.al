table 2000000071 "Object Metadata"
{
    // version NAVW113.00

    Caption = 'Object Metadata';
    DataPerCompany = false;

    fields
    {
        field(3;"Object Type";Option)
        {
            Caption = 'Object Type';
            OptionCaption = 'TableData,Table,,Report,,Codeunit,XMLport,MenuSuite,Page,Query,System,FieldNumber';
            OptionMembers = TableData,"Table",,"Report",,"Codeunit","XMLport",MenuSuite,"Page","Query",System,FieldNumber;
        }
        field(6;"Object ID";Integer)
        {
            Caption = 'Object ID';
            TableRelation = Object.ID WHERE (Type=FIELD("Object Type"));
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(9;Metadata;BLOB)
        {
            Caption = 'Metadata';
        }
        field(15;"User Code";BLOB)
        {
            Caption = 'User Code';
        }
        field(18;"User AL Code";BLOB)
        {
            Caption = 'User AL Code';
        }
        field(27;"Metadata Version";Integer)
        {
            Caption = 'Metadata Version';
        }
        field(30;Hash;Text[32])
        {
            Caption = 'Hash';
        }
        field(33;"Object Subtype";Text[30])
        {
            Caption = 'Object Subtype';
        }
        field(34;"Has Subscribers";Boolean)
        {
            Caption = 'Has Subscribers';
        }
        field(35;"Symbol Reference";BLOB)
        {
            Caption = 'Symbol Reference';
        }
        field(36;"Schema Hash";Integer)
        {
            Caption = 'Schema Hash';
        }
    }

    keys
    {
        key(Key1;"Object Type","Object ID")
        {
        }
    }

    fieldgroups
    {
    }
}

