table 2000000082 "Report Layout"
{
    // version NAVW111.00

    Caption = 'Report Layout';
    DataPerCompany = false;

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
        }
        field(2;"Report ID";Integer)
        {
            Caption = 'Report ID';
        }
        field(3;"Report Name";Text[80])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE ("Object Type"=CONST(Report),
                                                                           "Object ID"=FIELD("Report ID")));
            Caption = 'Report Name';
            FieldClass = FlowField;
        }
        field(6;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'RDLC,Word';
            OptionMembers = RDLC,Word;
        }
        field(7;"Layout";BLOB)
        {
            Caption = 'Layout';
        }
        field(10;"File Extension";Text[10])
        {
            Caption = 'File Extension';
        }
        field(11;Description;Text[80])
        {
            Caption = 'Description';
        }
        field(12;"Custom XML Part";BLOB)
        {
            Caption = 'Custom XML Part';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }
}

