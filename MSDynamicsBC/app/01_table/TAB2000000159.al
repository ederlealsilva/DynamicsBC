table 2000000159 "Data Sensitivity"
{
    // version NAVW113.00

    Caption = 'Data Sensitivity';
    DataPerCompany = false;

    fields
    {
        field(1;"Company Name";Text[30])
        {
            Caption = 'Company Name';
            TableRelation = Company.Name;
        }
        field(2;"Table No";Integer)
        {
            Caption = 'Table No';
        }
        field(3;"Field No";Integer)
        {
            Caption = 'Field No';
        }
        field(4;"Table Caption";Text[80])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE ("Object Type"=CONST(Table),
                                                                           "Object ID"=FIELD("Table No")));
            Caption = 'Table Caption';
            FieldClass = FlowField;
        }
        field(5;"Field Caption";Text[80])
        {
            CalcFormula = Lookup(Field."Field Caption" WHERE (TableNo=FIELD("Table No"),
                                                              "No."=FIELD("Field No")));
            Caption = 'Field Caption';
            FieldClass = FlowField;
        }
        field(6;"Field Type";Option)
        {
            CalcFormula = Lookup(Field.Type WHERE (TableNo=FIELD("Table No"),
                                                   "No."=FIELD("Field No")));
            Caption = 'Field Type';
            FieldClass = FlowField;
            OptionCaption = 'TableFilter,RecordID,OemText,Date,Time,DateFormula,Decimal,Media,MediaSet,Text,Code,Binary,BLOB,Boolean,Integer,OemCode,Option,BigInteger,Duration,GUID,DateTime';
            OptionMembers = TableFilter,RecordID,OemText,Date,Time,DateFormula,Decimal,Media,MediaSet,Text,"Code",Binary,BLOB,Boolean,"Integer",OemCode,Option,BigInteger,Duration,GUID,DateTime;
        }
        field(7;"Data Sensitivity";Option)
        {
            Caption = 'Data Sensitivity';
            OptionCaption = 'Unclassified,Sensitive,Personal,Company Confidential,Normal';
            OptionMembers = Unclassified,Sensitive,Personal,"Company Confidential",Normal;
        }
        field(8;"Last Modified By";Guid)
        {
            Caption = 'Last Modified By';
        }
        field(9;"Last Modified";DateTime)
        {
            Caption = 'Last Modified';
        }
        field(10;"Data Classification";Option)
        {
            CalcFormula = Lookup(Field.DataClassification WHERE (TableNo=FIELD("Table No"),
                                                                 "No."=FIELD("Field No")));
            Caption = 'Data Classification';
            FieldClass = FlowField;
            OptionCaption = 'CustomerContent,ToBeClassified,EndUserIdentifiableInformation,AccountData,EndUserPseudonymousIdentifiers,OrganizationIdentifiableInformation,SystemMetadata';
            OptionMembers = CustomerContent,ToBeClassified,EndUserIdentifiableInformation,AccountData,EndUserPseudonymousIdentifiers,OrganizationIdentifiableInformation,SystemMetadata;
        }
    }

    keys
    {
        key(Key1;"Company Name","Table No","Field No")
        {
        }
    }

    fieldgroups
    {
    }
}

