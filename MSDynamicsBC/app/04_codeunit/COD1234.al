codeunit 1234 "Json Text Reader/Writer"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        StringBuilder: DotNet StringBuilder;
        StringWriter: DotNet StringWriter;
        JsonTextWriter: DotNet JsonTextWriter;
        DoNotFormat: Boolean;

    [Scope('Personalization')]
    procedure ReadJSonToJSonBuffer(Json: Text;var JsonBuffer: Record "JSON Buffer")
    begin
        JsonBuffer.ReadFromText(Json);
    end;

    local procedure InitializeWriter()
    var
        Formatting: DotNet Formatting;
    begin
        if not IsNull(StringBuilder) then
          exit;
        StringBuilder := StringBuilder.StringBuilder;
        StringWriter := StringWriter.StringWriter(StringBuilder);
        JsonTextWriter := JsonTextWriter.JsonTextWriter(StringWriter);
        if DoNotFormat then
          JsonTextWriter.Formatting := Formatting.None
        else
          JsonTextWriter.Formatting := Formatting.Indented;
    end;

    [Scope('Personalization')]
    procedure SetDoNotFormat()
    begin
        DoNotFormat := true;
    end;

    [Scope('Personalization')]
    procedure WriteStartConstructor(Name: Text)
    begin
        InitializeWriter;

        JsonTextWriter.WriteStartConstructor(Name);
    end;

    [Scope('Personalization')]
    procedure WriteEndConstructor()
    begin
        JsonTextWriter.WriteEndConstructor;
    end;

    [Scope('Personalization')]
    procedure WriteStartObject(ObjectName: Text)
    begin
        InitializeWriter;

        if ObjectName <> '' then
          JsonTextWriter.WritePropertyName(ObjectName);
        JsonTextWriter.WriteStartObject;
    end;

    [Scope('Personalization')]
    procedure WriteEndObject()
    begin
        JsonTextWriter.WriteEndObject;
    end;

    [Scope('Personalization')]
    procedure WriteStartArray(ArrayName: Text)
    begin
        InitializeWriter;

        if ArrayName <> '' then
          JsonTextWriter.WritePropertyName(ArrayName);
        JsonTextWriter.WriteStartArray;
    end;

    [Scope('Personalization')]
    procedure WriteEndArray()
    begin
        JsonTextWriter.WriteEndArray;
    end;

    [Scope('Personalization')]
    procedure WriteStringProperty(VariableName: Text;Variable: Variant)
    begin
        JsonTextWriter.WritePropertyName(VariableName);
        JsonTextWriter.WriteValue(Format(Variable,0,9));
    end;

    [Scope('Personalization')]
    procedure WriteNumberProperty(VariableName: Text;Variable: Variant)
    var
        Decimal: Decimal;
    begin
        case true of
          Variable.IsInteger,Variable.IsDecimal:
            Decimal := Variable;
          else
            Evaluate(Decimal,Variable);
        end;
        JsonTextWriter.WritePropertyName(VariableName);
        JsonTextWriter.WriteValue(Decimal);
    end;

    [Scope('Personalization')]
    procedure WriteBooleanProperty(VariableName: Text;Variable: Variant)
    var
        Bool: Boolean;
    begin
        case true of
          Variable.IsBoolean:
            Bool := Variable;
          else
            Evaluate(Bool,Variable);
        end;
        JsonTextWriter.WritePropertyName(VariableName);
        JsonTextWriter.WriteValue(Bool);
    end;

    [Scope('Personalization')]
    procedure WriteNullProperty(VariableName: Text)
    begin
        JsonTextWriter.WritePropertyName(VariableName);
        JsonTextWriter.WriteNull;
    end;

    [Scope('Personalization')]
    procedure WriteBytesProperty(VariableName: Text;TempBlob: Record TempBlob)
    var
        MemoryStream: DotNet MemoryStream;
        InStr: InStream;
    begin
        TempBlob.Blob.CreateInStream(InStr);
        MemoryStream := MemoryStream.MemoryStream;
        CopyStream(MemoryStream,InStr);
        JsonTextWriter.WritePropertyName(VariableName);
        JsonTextWriter.WriteValue(MemoryStream.ToArray);
    end;

    [Scope('Personalization')]
    procedure WriteRawProperty(VariableName: Text;Variable: Variant)
    begin
        JsonTextWriter.WritePropertyName(VariableName);
        JsonTextWriter.WriteValue(Variable);
    end;

    [Scope('Personalization')]
    procedure GetJSonAsText() JSon: Text
    begin
        JSon := StringBuilder.ToString;
    end;
}

