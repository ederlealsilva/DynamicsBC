table 2000000100 "Debugger Breakpoint"
{
    // version NAVW113.00

    Caption = 'Debugger Breakpoint';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"Breakpoint ID";Integer)
        {
            AutoIncrement = true;
            Caption = 'Breakpoint ID';
        }
        field(7;"Object Type";Option)
        {
            Caption = 'Object Type';
            InitValue = "Page";
            OptionCaption = ',Table,,Report,,Codeunit,XMLport,,Page,Query,,,,,PageExtension';
            OptionMembers = ,"Table",,"Report",,"Codeunit","XMLport",,"Page","Query",,,,,"PageExtension";
        }
        field(9;"Object ID";Integer)
        {
            Caption = 'Object ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE ("Object Type"=FIELD("Object Type"));
        }
        field(10;"Object Name";Text[30])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Name" WHERE ("Object Type"=FIELD("Object Type"),
                                                                        "Object ID"=FIELD("Object ID")));
            Caption = 'Object Name';
            FieldClass = FlowField;
        }
        field(11;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(13;"Column No.";Integer)
        {
            Caption = 'Column No.';
        }
        field(15;"End Line No.";Integer)
        {
            Caption = 'End Line No.';
        }
        field(17;"End Column No.";Integer)
        {
            Caption = 'End Column No.';
        }
        field(19;"Function Name";Text[128])
        {
            Caption = 'Function Name';
        }
        field(21;Enabled;Boolean)
        {
            Caption = 'Enabled';
            InitValue = true;
        }
        field(23;Condition;Text[250])
        {
            Caption = 'Condition';
        }
        field(27;"Session Breakpoint ID";BigInteger)
        {
            Caption = 'Session Breakpoint ID';
        }
        field(29;"Relative Line No.";Integer)
        {
            Caption = 'Relative Line No.';
        }
        field(31;"Relative End Line No.";Integer)
        {
            Caption = 'Relative End Line No.';
        }
        field(33;"Function ID";Integer)
        {
            Caption = 'Function ID';
        }
    }

    keys
    {
        key(Key1;"Breakpoint ID")
        {
        }
        key(Key2;"Object Type","Object ID","Line No.","Column No.")
        {
        }
    }

    fieldgroups
    {
    }
}

