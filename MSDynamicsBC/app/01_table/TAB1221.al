table 1221 "Data Exch. Field"
{
    // version NAVW111.00

    Caption = 'Data Exch. Field';

    fields
    {
        field(1;"Data Exch. No.";Integer)
        {
            Caption = 'Data Exch. No.';
            NotBlank = true;
            TableRelation = "Data Exch.";
        }
        field(2;"Line No.";Integer)
        {
            Caption = 'Line No.';
            NotBlank = true;
        }
        field(3;"Column No.";Integer)
        {
            Caption = 'Column No.';
            NotBlank = true;
        }
        field(4;Value;Text[250])
        {
            Caption = 'Value';
        }
        field(5;"Node ID";Text[250])
        {
            Caption = 'Node ID';
        }
        field(6;"Data Exch. Line Def Code";Code[20])
        {
            Caption = 'Data Exch. Line Def Code';
            TableRelation = "Data Exch. Line Def".Code;
        }
        field(10;"Parent Node ID";Text[250])
        {
            Caption = 'Parent Node ID';
        }
        field(11;"Data Exch. Def Code";Code[20])
        {
            CalcFormula = Lookup("Data Exch."."Data Exch. Def Code" WHERE ("Entry No."=FIELD("Data Exch. No.")));
            Caption = 'Data Exch. Def Code';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Data Exch. No.","Line No.","Column No.","Node ID")
        {
        }
    }

    fieldgroups
    {
    }

    [Scope('Personalization')]
    procedure InsertRec(DataExchNo: Integer;LineNo: Integer;ColumnNo: Integer;NewValue: Text[250];DataExchLineDefCode: Code[20])
    begin
        Init;
        Validate("Data Exch. No.",DataExchNo);
        Validate("Line No.",LineNo);
        Validate("Column No.",ColumnNo);
        Validate(Value,NewValue);
        Validate("Data Exch. Line Def Code",DataExchLineDefCode);
        Insert;
    end;

    [Scope('Personalization')]
    procedure InsertRecXMLField(DataExchNo: Integer;LineNo: Integer;ColumnNo: Integer;NodeId: Text[250];NodeValue: Text;DataExchLineDefCode: Code[20])
    begin
        InsertRecXMLFieldWithParentNodeID(DataExchNo,LineNo,ColumnNo,NodeId,'',NodeValue,DataExchLineDefCode)
    end;

    [Scope('Personalization')]
    procedure InsertRecXMLFieldWithParentNodeID(DataExchNo: Integer;LineNo: Integer;ColumnNo: Integer;NodeId: Text[250];ParentNodeId: Text[250];NodeValue: Text;DataExchLineDefCode: Code[20])
    begin
        Init;
        Validate("Data Exch. No.",DataExchNo);
        Validate("Line No.",LineNo);
        Validate("Column No.",ColumnNo);
        Validate("Node ID",NodeId);
        Validate(Value,CopyStr(NodeValue,1,MaxStrLen(Value)));
        Validate("Parent Node ID",ParentNodeId);
        Validate("Data Exch. Line Def Code",DataExchLineDefCode);
        Insert;
    end;

    [Scope('Personalization')]
    procedure InsertRecXMLFieldDefinition(DataExchNo: Integer;LineNo: Integer;NodeId: Text[250];ParentNodeId: Text[250];NewValue: Text[250];DataExchLineDefCode: Code[20])
    begin
        // this record represents the line definition and it has ColumnNo set to -1
        // even if we are not extracting anything from the line, we need to insert the definition
        // so that the child nodes can hook up to their parent.
        InsertRecXMLFieldWithParentNodeID(DataExchNo,LineNo,-1,NodeId,ParentNodeId,NewValue,DataExchLineDefCode)
    end;

    [Scope('Personalization')]
    procedure GetFieldName(): Text
    var
        DataExchColumnDef: Record "Data Exch. Column Def";
        DataExch: Record "Data Exch.";
    begin
        DataExch.Get("Data Exch. No.");
        if DataExchColumnDef.Get(DataExch."Data Exch. Def Code",DataExch."Data Exch. Line Def Code","Column No.") then
          exit(DataExchColumnDef.Name);
        exit('');
    end;

    [Scope('Personalization')]
    procedure DeleteRelatedRecords(DataExchNo: Integer;LineNo: Integer)
    begin
        SetRange("Data Exch. No.",DataExchNo);
        SetRange("Line No.",LineNo);
        DeleteAll(true);
    end;
}

