table 1214 "Intermediate Data Import"
{
    // version NAVW111.00

    Caption = 'Intermediate Data Import';

    fields
    {
        field(1;ID;Integer)
        {
            AutoIncrement = true;
            Caption = 'ID';
        }
        field(2;"Data Exch. No.";Integer)
        {
            Caption = 'Data Exch. No.';
            NotBlank = true;
            TableRelation = "Data Exch.";
        }
        field(3;"Table ID";Integer)
        {
            Caption = 'Table ID';
            NotBlank = true;
            TableRelation = AllObjWithCaption."Object ID" WHERE ("Object Type"=CONST(Table));
        }
        field(4;"Record No.";Integer)
        {
            Caption = 'Record No.';
        }
        field(5;"Field ID";Integer)
        {
            Caption = 'Field ID';
            TableRelation = Field."No." WHERE (TableNo=FIELD("Table ID"));
        }
        field(6;Value;Text[250])
        {
            Caption = 'Value';
        }
        field(7;"Validate Only";Boolean)
        {
            Caption = 'Validate Only';
        }
        field(8;"Parent Record No.";Integer)
        {
            Caption = 'Parent Record No.';
        }
    }

    keys
    {
        key(Key1;ID)
        {
        }
        key(Key2;"Data Exch. No.","Table ID","Record No.","Field ID")
        {
        }
        key(Key3;"Data Exch. No.","Table ID","Field ID")
        {
        }
    }

    fieldgroups
    {
    }

    [Scope('Personalization')]
    procedure InsertOrUpdateEntry(EntryNo: Integer;TableID: Integer;FieldID: Integer;ParentRecordNo: Integer;RecordNo: Integer;NewValue: Text[250])
    begin
        if FindEntry(EntryNo,TableID,FieldID,ParentRecordNo,RecordNo) then begin
          Value := NewValue;
          Modify;
        end else begin
          Clear(Rec);
          "Data Exch. No." := EntryNo;
          "Table ID" := TableID;
          "Record No." := RecordNo;
          "Field ID" := FieldID;
          Value := NewValue;
          "Parent Record No." := ParentRecordNo;
          "Validate Only" := false;
          Insert;
        end;
    end;

    [Scope('Personalization')]
    procedure FindEntry(EntryNo: Integer;TableID: Integer;FieldID: Integer;ParentRecordNo: Integer;RecordNo: Integer): Boolean
    begin
        Reset;

        SetRange("Data Exch. No.",EntryNo);
        SetRange("Table ID",TableID);
        SetRange("Field ID",FieldID);
        SetRange("Parent Record No.",ParentRecordNo);
        SetRange("Record No.",RecordNo);

        exit(FindFirst);
    end;

    [Scope('Personalization')]
    procedure GetEntryValue(EntryNo: Integer;TableID: Integer;FieldID: Integer;ParentRecordNo: Integer;RecordNo: Integer): Text[250]
    begin
        if FindEntry(EntryNo,TableID,FieldID,ParentRecordNo,RecordNo) then
          exit(Value);

        exit('');
    end;
}

