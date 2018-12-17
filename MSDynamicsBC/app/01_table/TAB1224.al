table 1224 "Data Exch. Mapping"
{
    // version NAVW113.00

    Caption = 'Data Exch. Mapping';

    fields
    {
        field(1;"Data Exch. Def Code";Code[20])
        {
            Caption = 'Data Exch. Def Code';
            NotBlank = true;
            TableRelation = "Data Exch. Def";
        }
        field(2;"Table ID";Integer)
        {
            Caption = 'Table ID';
            NotBlank = true;
            TableRelation = AllObjWithCaption."Object ID" WHERE ("Object Type"=CONST(Table));
        }
        field(3;Name;Text[50])
        {
            Caption = 'Name';
        }
        field(4;"Mapping Codeunit";Integer)
        {
            Caption = 'Mapping Codeunit';
            TableRelation = AllObjWithCaption."Object ID" WHERE ("Object Type"=CONST(Codeunit));
        }
        field(6;"Data Exch. No. Field ID";Integer)
        {
            Caption = 'Data Exch. No. Field ID';
            Description = 'The ID of the field in the target table that contains the Data Exchange No..';
            TableRelation = Field."No." WHERE (TableNo=FIELD("Table ID"));
        }
        field(7;"Data Exch. Line Field ID";Integer)
        {
            Caption = 'Data Exch. Line Field ID';
            Description = 'The ID of the field in the target table that contains the Data Exchange Line No..';
            TableRelation = Field."No." WHERE (TableNo=FIELD("Table ID"));
        }
        field(8;"Data Exch. Line Def Code";Code[20])
        {
            Caption = 'Data Exch. Line Def Code';
            NotBlank = true;
            TableRelation = "Data Exch. Line Def".Code WHERE ("Data Exch. Def Code"=FIELD("Data Exch. Def Code"));
        }
        field(9;"Pre-Mapping Codeunit";Integer)
        {
            Caption = 'Pre-Mapping Codeunit';
            TableRelation = AllObjWithCaption."Object ID" WHERE ("Object Type"=CONST(Codeunit));
        }
        field(10;"Post-Mapping Codeunit";Integer)
        {
            Caption = 'Post-Mapping Codeunit';
            TableRelation = AllObjWithCaption."Object ID" WHERE ("Object Type"=CONST(Codeunit));
        }
        field(20;"Use as Intermediate Table";Boolean)
        {
            Caption = 'Use as Intermediate Table';
        }
    }

    keys
    {
        key(Key1;"Data Exch. Def Code","Data Exch. Line Def Code","Table ID")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        DataExchFieldMapping.SetRange("Data Exch. Def Code","Data Exch. Def Code");
        DataExchFieldMapping.SetRange("Table ID","Table ID");
        DataExchFieldMapping.DeleteAll;
    end;

    trigger OnRename()
    begin
        if HasFieldMappings then
          Error(RenameErr);
    end;

    var
        DataExchFieldMapping: Record "Data Exch. Field Mapping";
        RecordNameFormatTok: Label '%1 to %2';
        RenameErr: Label 'You cannot rename the record if one or more field mapping lines exist.';

    [Scope('Personalization')]
    procedure InsertRec(DataExchDefCode: Code[20];DataExchLineDefCode: Code[20];TableId: Integer;NewName: Text[50];MappingCodeunit: Integer;DataExchNoFieldId: Integer;DataExchLineFieldId: Integer)
    begin
        Init;
        Validate("Data Exch. Def Code",DataExchDefCode);
        Validate("Data Exch. Line Def Code",DataExchLineDefCode);
        Validate("Table ID",TableId);
        Validate(Name,NewName);
        Validate("Mapping Codeunit",MappingCodeunit);
        Validate("Data Exch. No. Field ID",DataExchNoFieldId);
        Validate("Data Exch. Line Field ID",DataExchLineFieldId);
        Insert;
    end;

    [Scope('Personalization')]
    procedure InsertRecForExport(DataExchDefCode: Code[20];DataExchLineDefCode: Code[20];TableId: Integer;NewName: Text[50];ProcessingCodeunit: Integer)
    begin
        Init;
        Validate("Data Exch. Def Code",DataExchDefCode);
        Validate("Data Exch. Line Def Code",DataExchLineDefCode);
        Validate("Table ID",TableId);
        Validate(Name,NewName);
        Validate("Mapping Codeunit",ProcessingCodeunit);
        Insert;
    end;

    [Scope('Personalization')]
    procedure InsertRecForImport(DataExchDefCode: Code[20];DataExchLineDefCode: Code[20];TableId: Integer;NewName: Text[50];DataExchNoFieldId: Integer;DataExchLineFieldId: Integer)
    begin
        Init;
        Validate("Data Exch. Def Code",DataExchDefCode);
        Validate("Data Exch. Line Def Code",DataExchLineDefCode);
        Validate("Table ID",TableId);
        Validate(Name,NewName);
        Validate("Data Exch. No. Field ID",DataExchNoFieldId);
        Validate("Data Exch. Line Field ID",DataExchLineFieldId);
        Insert;
    end;

    procedure CreateDataExchMapping(TableID: Integer;CodeunitID: Integer;DataExchNoFieldID: Integer;DataExchLineFieldID: Integer)
    begin
        InsertRec("Data Exch. Def Code","Data Exch. Line Def Code",TableID,
          CreateName(TableID,"Data Exch. Def Code"),CodeunitID,DataExchNoFieldID,DataExchLineFieldID);
    end;

    local procedure CreateName(TableID: Integer;"Code": Code[20]): Text[50]
    var
        recRef: RecordRef;
    begin
        recRef.Open(TableID);
        exit(StrSubstNo(RecordNameFormatTok,Code,recRef.Caption));
    end;

    local procedure HasFieldMappings(): Boolean
    var
        DataExchFieldMapping: Record "Data Exch. Field Mapping";
    begin
        DataExchFieldMapping.SetRange("Data Exch. Def Code","Data Exch. Def Code");
        DataExchFieldMapping.SetRange("Data Exch. Line Def Code","Data Exch. Line Def Code");
        DataExchFieldMapping.SetRange("Table ID",xRec."Table ID");
        DataExchFieldMapping.SetFilter("Column No.",'<>%1',0);
        exit(not DataExchFieldMapping.IsEmpty);
    end;

    [Scope('Personalization')]
    procedure PositivePayUpdateCodeunits(): Boolean
    var
        DataExchDef: Record "Data Exch. Def";
        DataExchLineDef: Record "Data Exch. Line Def";
    begin
        DataExchDef.SetRange(Code,"Data Exch. Def Code");
        if DataExchDef.FindFirst then
          if DataExchDef.Type = DataExchDef.Type::"Positive Pay Export" then begin
            DataExchLineDef.SetRange("Data Exch. Def Code","Data Exch. Def Code");
            DataExchLineDef.SetRange(Code,"Data Exch. Line Def Code");
            if DataExchLineDef.FindFirst then begin
              case DataExchLineDef."Line Type" of
                DataExchLineDef."Line Type"::Header:
                  begin
                    "Pre-Mapping Codeunit" := CODEUNIT::"Exp. Pre-Mapping Head Pos. Pay";
                    "Mapping Codeunit" := CODEUNIT::"Exp. Mapping Head Pos. Pay";
                  end;
                DataExchLineDef."Line Type"::Detail:
                  begin
                    "Pre-Mapping Codeunit" := CODEUNIT::"Exp. Pre-Mapping Det Pos. Pay";
                    "Mapping Codeunit" := CODEUNIT::"Exp. Mapping Det Pos. Pay";
                  end;
                DataExchLineDef."Line Type"::Footer:
                  begin
                    "Pre-Mapping Codeunit" := CODEUNIT::"Exp. Pre-Mapping Foot Pos. Pay";
                    "Mapping Codeunit" := CODEUNIT::"Exp. Mapping Foot Pos. Pay";
                  end;
              end;
              exit(true);
            end;
          end;

        if DataExchDef.Type <> DataExchDef.Type::"Positive Pay Export" then begin
          "Pre-Mapping Codeunit" := 0;
          "Mapping Codeunit" := 0;
        end;

        exit(false);
    end;
}

