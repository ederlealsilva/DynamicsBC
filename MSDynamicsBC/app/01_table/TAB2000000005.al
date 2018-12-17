table 2000000005 Permission
{
    // version NAVW113.00

    Caption = 'Permission';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"Role ID";Code[20])
        {
            Caption = 'Role ID';
            TableRelation = "Permission Set"."Role ID";
        }
        field(2;"Role Name";Text[30])
        {
            CalcFormula = Lookup("Permission Set".Name WHERE ("Role ID"=FIELD("Role ID")));
            Caption = 'Role Name';
            FieldClass = FlowField;
        }
        field(3;"Object Type";Option)
        {
            Caption = 'Object Type';
            OptionCaption = 'Table Data,Table,,Report,,Codeunit,XMLport,MenuSuite,Page,Query,System';
            OptionMembers = "Table Data","Table",,"Report",,"Codeunit","XMLport",MenuSuite,"Page","Query",System;
        }
        field(4;"Object ID";Integer)
        {
            Caption = 'Object ID';
            TableRelation = IF ("Object Type"=CONST("Table Data")) AllObjWithCaption."Object ID" WHERE ("Object Type"=CONST(Table))
                            ELSE IF ("Object Type"=CONST(Table)) AllObjWithCaption."Object ID" WHERE ("Object Type"=CONST(Table))
                            ELSE IF ("Object Type"=CONST(Report)) AllObjWithCaption."Object ID" WHERE ("Object Type"=CONST(Report))
                            ELSE IF ("Object Type"=CONST(Codeunit)) AllObjWithCaption."Object ID" WHERE ("Object Type"=CONST(Codeunit))
                            ELSE IF ("Object Type"=CONST(XMLport)) AllObjWithCaption."Object ID" WHERE ("Object Type"=CONST(XMLport))
                            ELSE IF ("Object Type"=CONST(MenuSuite)) AllObjWithCaption."Object ID" WHERE ("Object Type"=CONST(MenuSuite))
                            ELSE IF ("Object Type"=CONST(Page)) AllObjWithCaption."Object ID" WHERE ("Object Type"=CONST(Page))
                            ELSE IF ("Object Type"=CONST(Query)) AllObjWithCaption."Object ID" WHERE ("Object Type"=CONST(Query))
                            ELSE IF ("Object Type"=CONST(System)) AllObjWithCaption."Object ID" WHERE ("Object Type"=CONST(System));
        }
        field(5;"Object Name";Text[249])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE ("Object Type"=FIELD("Object Type"),
                                                                           "Object ID"=FIELD("Object ID")));
            Caption = 'Object Name';
            FieldClass = FlowField;
        }
        field(6;"Read Permission";Option)
        {
            Caption = 'Read Permission';
            InitValue = Yes;
            OptionCaption = ' ,Yes,Indirect';
            OptionMembers = " ",Yes,Indirect;
        }
        field(7;"Insert Permission";Option)
        {
            Caption = 'Insert Permission';
            InitValue = Yes;
            OptionCaption = ' ,Yes,Indirect';
            OptionMembers = " ",Yes,Indirect;
        }
        field(8;"Modify Permission";Option)
        {
            Caption = 'Modify Permission';
            InitValue = Yes;
            OptionCaption = ' ,Yes,Indirect';
            OptionMembers = " ",Yes,Indirect;
        }
        field(9;"Delete Permission";Option)
        {
            Caption = 'Delete Permission';
            InitValue = Yes;
            OptionCaption = ' ,Yes,Indirect';
            OptionMembers = " ",Yes,Indirect;
        }
        field(10;"Execute Permission";Option)
        {
            Caption = 'Execute Permission';
            InitValue = Yes;
            OptionCaption = ' ,Yes,Indirect';
            OptionMembers = " ",Yes,Indirect;
        }
        field(11;"Security Filter";TableFilter)
        {
            Caption = 'Security Filter';
        }
    }

    keys
    {
        key(Key1;"Role ID","Object Type","Object ID")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown;"Role ID","Role Name")
        {
        }
    }
}

