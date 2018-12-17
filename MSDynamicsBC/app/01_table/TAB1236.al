table 1236 "JSON Buffer"
{
    // version NAVW113.00

    Caption = 'JSON Buffer';
    ReplicateData = false;

    fields
    {
        field(1;"Entry No.";Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }
        field(2;Depth;Integer)
        {
            Caption = 'Depth';
            DataClassification = SystemMetadata;
        }
        field(3;"Token type";Option)
        {
            Caption = 'Token type';
            DataClassification = SystemMetadata;
            OptionCaption = 'None,Start Object,Start Array,Start Constructor,Property Name,Comment,Raw,Integer,Decimal,String,Boolean,Null,Undefined,End Object,End Array,End Constructor,Date,Bytes';
            OptionMembers = "None","Start Object","Start Array","Start Constructor","Property Name",Comment,Raw,"Integer",Decimal,String,Boolean,Null,Undefined,"End Object","End Array","End Constructor",Date,Bytes;
        }
        field(4;Value;Text[250])
        {
            Caption = 'Value';
            DataClassification = SystemMetadata;
        }
        field(5;"Value Type";Text[50])
        {
            Caption = 'Value Type';
            DataClassification = SystemMetadata;
        }
        field(6;Path;Text[250])
        {
            Caption = 'Path';
            DataClassification = SystemMetadata;
        }
        field(7;"Value BLOB";BLOB)
        {
            Caption = 'Value BLOB';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        DevMsgNotTemporaryErr: Label 'This function can only be used when the record is temporary.';

    [Scope('Personalization')]
    procedure ReadFromBlob(TempBlob: Record TempBlob)
    begin
        ReadFromText(TempBlob.ReadAsTextWithCRLFLineSeparator);
    end;

    [Scope('Personalization')]
    procedure ReadFromText(JSONText: Text)
    var
        JSONTextReader: DotNet JsonTextReader;
        StringReader: DotNet StringReader;
        TokenType: Integer;
    begin
        if not IsTemporary then
          Error(DevMsgNotTemporaryErr);
        DeleteAll;
        JSONTextReader := JSONTextReader.JsonTextReader(StringReader.StringReader(JSONText));
        if JSONTextReader.Read then
          repeat
            Init;
            "Entry No." += 1;
            Depth := JSONTextReader.Depth;
            TokenType := JSONTextReader.TokenType;
            "Token type" := TokenType;
            if IsNull(JSONTextReader.Value) then
              Value := ''
            else
              SetValueWithoutModifying(Format(JSONTextReader.Value));
            if IsNull(JSONTextReader.ValueType) then
              "Value Type" := ''
            else
              "Value Type" := Format(JSONTextReader.ValueType);
            Path := JSONTextReader.Path;
            Insert;
          until not JSONTextReader.Read;
    end;

    [Scope('Personalization')]
    procedure FindArray(var TempJSONBuffer: Record "JSON Buffer" temporary;ArrayName: Text): Boolean
    begin
        TempJSONBuffer.Copy(Rec,true);
        TempJSONBuffer.Reset;

        TempJSONBuffer.SetRange(Path,AppendPathToCurrent(ArrayName));
        if not TempJSONBuffer.FindFirst then
          exit(false);
        TempJSONBuffer.SetFilter(Path,AppendPathToCurrent(ArrayName) + '[*');
        TempJSONBuffer.SetRange(Depth,TempJSONBuffer.Depth + 1);
        TempJSONBuffer.SetFilter("Token type",'<>%1',"Token type"::"End Object");
        exit(TempJSONBuffer.FindSet);
    end;

    [Scope('Personalization')]
    procedure GetPropertyValue(var PropertyValue: Text;PropertyName: Text): Boolean
    begin
        exit(GetPropertyValueAtPath(PropertyValue,PropertyName,Path + '*'));
    end;

    [Scope('Personalization')]
    procedure GetPropertyValueAtPath(var PropertyValue: Text;PropertyName: Text;PropertyPath: Text): Boolean
    var
        TempJSONBuffer: Record "JSON Buffer" temporary;
    begin
        TempJSONBuffer.Copy(Rec,true);
        TempJSONBuffer.Reset;

        TempJSONBuffer.SetFilter(Path,PropertyPath);
        TempJSONBuffer.SetRange("Token type","Token type"::"Property Name");
        TempJSONBuffer.SetRange(Value,PropertyName);
        if not TempJSONBuffer.FindFirst then
          exit;
        if TempJSONBuffer.Get(TempJSONBuffer."Entry No." + 1) then begin
          PropertyValue := TempJSONBuffer.GetValue;
          exit(true);
        end;
    end;

    [Scope('Personalization')]
    procedure GetBooleanPropertyValue(var BooleanValue: Boolean;PropertyName: Text): Boolean
    var
        PropertyValue: Text;
    begin
        if GetPropertyValue(PropertyValue,PropertyName) then
          exit(Evaluate(BooleanValue,PropertyValue));
    end;

    [Scope('Personalization')]
    procedure GetIntegerPropertyValue(var IntegerValue: Integer;PropertyName: Text): Boolean
    var
        PropertyValue: Text;
    begin
        if GetPropertyValue(PropertyValue,PropertyName) then
          exit(Evaluate(IntegerValue,PropertyValue));
    end;

    [Scope('Personalization')]
    procedure GetDatePropertyValue(var DateValue: Date;PropertyName: Text): Boolean
    var
        PropertyValue: Text;
    begin
        if GetPropertyValue(PropertyValue,PropertyName) then
          exit(Evaluate(DateValue,PropertyValue));
    end;

    [Scope('Personalization')]
    procedure GetDecimalPropertyValue(var DecimalValue: Decimal;PropertyName: Text): Boolean
    var
        PropertyValue: Text;
    begin
        if GetPropertyValue(PropertyValue,PropertyName) then
          exit(Evaluate(DecimalValue,PropertyValue));
    end;

    local procedure AppendPathToCurrent(AppendPath: Text): Text
    begin
        if Path <> '' then
          exit(Path + '.' + AppendPath);
        exit(AppendPath)
    end;

    [Scope('Personalization')]
    procedure GetValue(): Text
    var
        TempBlob: Record TempBlob;
        CR: Text[1];
    begin
        CalcFields("Value BLOB");
        if not "Value BLOB".HasValue then
          exit(Value);
        CR[1] := 10;
        TempBlob.Blob := "Value BLOB";
        exit(TempBlob.ReadAsText(CR,TEXTENCODING::Windows));
    end;

    procedure SetValue(NewValue: Text)
    begin
        SetValueWithoutModifying(NewValue);
        Modify;
    end;

    procedure SetValueWithoutModifying(NewValue: Text)
    var
        TempBlob: Record TempBlob;
    begin
        Clear("Value BLOB");
        Value := CopyStr(NewValue,1,MaxStrLen(Value));
        if StrLen(NewValue) <= MaxStrLen(Value) then
          exit; // No need to store anything in the blob
        if NewValue = '' then
          exit;
        TempBlob.WriteAsText(NewValue,TEXTENCODING::Windows);
        "Value BLOB" := TempBlob.Blob;
    end;
}

