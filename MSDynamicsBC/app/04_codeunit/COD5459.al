codeunit 5459 "JSON Management"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        JsonArray: DotNet JArray;
        JsonObject: DotNet JObject;

    [Scope('Personalization')]
    procedure InitializeCollection(JSONString: Text)
    begin
        InitializeCollectionFromString(JSONString);
    end;

    [Scope('Personalization')]
    procedure InitializeEmptyCollection()
    begin
        JsonArray := JsonArray.JArray;
    end;

    [Scope('Personalization')]
    procedure InitializeObject(JSONString: Text)
    begin
        InitializeObjectFromString(JSONString);
    end;

    procedure InitializeObjectFromJObject(NewJsonObject: DotNet JObject)
    begin
        JsonObject := NewJsonObject;
    end;

    procedure InitializeCollectionFromJArray(NewJsonArray: DotNet JArray)
    begin
        JsonArray := NewJsonArray;
    end;

    [Scope('Personalization')]
    procedure InitializeEmptyObject()
    begin
        JsonObject := JsonObject.JObject;
    end;

    local procedure InitializeCollectionFromString(JSONString: Text)
    begin
        Clear(JsonArray);
        if JSONString <> '' then
          JsonArray := JsonArray.Parse(JSONString)
        else
          InitializeEmptyCollection;
    end;

    local procedure InitializeObjectFromString(JSONString: Text)
    begin
        Clear(JsonObject);
        if JSONString <> '' then
          JsonObject := JsonObject.Parse(JSONString)
        else
          InitializeEmptyObject;
    end;

    procedure GetJSONObject(var JObject: DotNet JObject)
    begin
        JObject := JsonObject;
    end;

    procedure GetJsonArray(var JArray: DotNet JArray)
    begin
        JArray := JsonArray;
    end;

    [Scope('Personalization')]
    procedure GetObjectFromCollectionByIndex(var "Object": Text;Index: Integer): Boolean
    var
        JObject: DotNet JObject;
    begin
        if not GetJObjectFromCollectionByIndex(JObject,Index) then
          exit(false);

        Object := JObject.ToString();
        exit(true);
    end;

    procedure GetJObjectFromCollectionByIndex(var JObject: DotNet JObject;Index: Integer): Boolean
    begin
        if (GetCollectionCount = 0) or (GetCollectionCount <= Index) then
          exit(false);

        JObject := JsonArray.Item(Index);
        exit(not IsNull(JObject))
    end;

    procedure GetJObjectFromCollectionByPropertyValue(var JObject: DotNet JObject;propertyName: Text;value: Text): Boolean
    var
        IEnumerable: DotNet IEnumerable_Of_T;
        IEnumerator: DotNet IEnumerator_Of_T;
    begin
        Clear(JObject);
        IEnumerable := JsonArray.SelectTokens(StrSubstNo('$[?(@.%1 == ''%2'')]',propertyName,value),false);
        IEnumerator := IEnumerable.GetEnumerator;

        if IEnumerator.MoveNext then begin
          JObject := IEnumerator.Current;
          exit(true);
        end;
    end;

    procedure GetPropertyValueFromJObjectByName(JObject: DotNet JObject;propertyName: Text;var value: Variant): Boolean
    var
        JProperty: DotNet JProperty;
        JToken: DotNet JToken;
    begin
        Clear(value);
        if JObject.TryGetValue(propertyName,JToken) then begin
          JProperty := JObject.Property(propertyName);
          value := JProperty.Value;
          exit(true);
        end;
    end;

    procedure GetPropertyValueByName(propertyName: Text;var value: Variant): Boolean
    begin
        exit(GetPropertyValueFromJObjectByName(JsonObject,propertyName,value));
    end;

    procedure GetPropertyValueFromJObjectByPathSetToFieldRef(JObject: DotNet JObject;propertyPath: Text;var FieldRef: FieldRef): Boolean
    var
        TempBlob: Record TempBlob;
        OutlookSynchTypeConv: Codeunit "Outlook Synch. Type Conv";
        JProperty: DotNet JProperty;
        Value: Variant;
        DecimalVal: Decimal;
        BoolVal: Boolean;
        GuidVal: Guid;
        DateVal: Date;
        Success: Boolean;
        IntVar: Integer;
    begin
        Success := false;
        JProperty := JObject.SelectToken(propertyPath);

        if IsNull(JProperty) then
          exit(false);

        Value := Format(JProperty.Value,0,9);

        case Format(FieldRef.Type) of
          'Integer',
          'Decimal':
            begin
              Success := Evaluate(DecimalVal,Value,9);
              FieldRef.Value(DecimalVal);
            end;
          'Date':
            begin
              Success := Evaluate(DateVal,Value,9);
              FieldRef.Value(DateVal);
            end;
          'Boolean':
            begin
              Success := Evaluate(BoolVal,Value,9);
              FieldRef.Value(BoolVal);
            end;
          'GUID':
            begin
              Success := Evaluate(GuidVal,Value);
              FieldRef.Value(GuidVal);
            end;
          'Text',
          'Code':
            begin
              FieldRef.Value(CopyStr(Value,1,FieldRef.Length));
              Success := true;
            end;
          'Option':
            begin
              if not Evaluate(IntVar,Value) then
                IntVar := OutlookSynchTypeConv.TextToOptionValue(Value,FieldRef.OptionCaption);
              if IntVar >= 0 then begin
                FieldRef.Value := IntVar;
                Success := true;
              end;
            end;
          'BLOB':
            if TryReadAsBase64(TempBlob,Value) then begin
              FieldRef.Value := TempBlob.Blob;
              Success := true;
            end;
        end;

        exit(Success);
    end;

    procedure GetPropertyValueFromJObjectByPath(JObject: DotNet JObject;fullyQualifiedPropertyName: Text;var value: Variant): Boolean
    var
        containerJObject: DotNet JObject;
        propertyName: Text;
    begin
        Clear(value);
        DecomposeQualifiedPathToContainerObjectAndPropertyName(JObject,fullyQualifiedPropertyName,containerJObject,propertyName);
        if IsNull(containerJObject) then
          exit(false);

        exit(GetPropertyValueFromJObjectByName(containerJObject,propertyName,value));
    end;

    procedure GetStringPropertyValueFromJObjectByName(JObject: DotNet JObject;propertyName: Text;var value: Text): Boolean
    var
        VariantValue: Variant;
    begin
        Clear(value);
        if GetPropertyValueFromJObjectByName(JObject,propertyName,VariantValue) then begin
          value := Format(VariantValue);
          exit(true);
        end;
        exit(false);
    end;

    [Scope('Personalization')]
    procedure GetStringPropertyValueByName(propertyName: Text;var value: Text): Boolean
    begin
        exit(GetStringPropertyValueFromJObjectByName(JsonObject,propertyName,value));
    end;

    procedure GetStringPropertyValueFromJObjectByPath(JObject: DotNet JObject;fullyQualifiedPropertyName: Text;var value: Text): Boolean
    var
        VariantValue: Variant;
    begin
        Clear(value);
        if GetPropertyValueFromJObjectByPath(JObject,fullyQualifiedPropertyName,VariantValue) then begin
          value := Format(VariantValue);
          exit(true);
        end;
        exit(false);
    end;

    procedure GetEnumPropertyValueFromJObjectByName(JObject: DotNet JObject;propertyName: Text;var value: Option)
    var
        StringValue: Text;
    begin
        GetStringPropertyValueFromJObjectByName(JObject,propertyName,StringValue);
        Evaluate(value,StringValue,0);
    end;

    procedure GetBoolPropertyValueFromJObjectByName(JObject: DotNet JObject;propertyName: Text;var value: Boolean): Boolean
    var
        StringValue: Text;
    begin
        if GetStringPropertyValueFromJObjectByName(JObject,propertyName,StringValue) then begin
          Evaluate(value,StringValue,2);
          exit(true);
        end;
        exit(false);
    end;

    procedure GetArrayPropertyValueFromJObjectByName(JObject: DotNet JObject;propertyName: Text;var JArray: DotNet JArray): Boolean
    var
        JProperty: DotNet JProperty;
        JToken: DotNet JToken;
    begin
        Clear(JArray);
        if JObject.TryGetValue(propertyName,JToken) then begin
          JProperty := JObject.Property(propertyName);
          JArray := JProperty.Value;
          exit(true);
        end;
        exit(false);
    end;

    [Scope('Personalization')]
    procedure GetArrayPropertyValueAsStringByName(propertyName: Text;var value: Text): Boolean
    var
        JArray: DotNet JArray;
    begin
        if not GetArrayPropertyValueFromJObjectByName(JsonObject,propertyName,JArray) then
          exit(false);

        value := JArray.ToString();
        exit(true);
    end;

    procedure GetObjectPropertyValueFromJObjectByName(JObject: DotNet JObject;propertyName: Text;var JSubObject: DotNet JObject): Boolean
    var
        JProperty: DotNet JProperty;
        JToken: DotNet JToken;
    begin
        Clear(JSubObject);
        if JObject.TryGetValue(propertyName,JToken) then begin
          JProperty := JObject.Property(propertyName);
          JSubObject := JProperty.Value;
          exit(true);
        end;
        exit(false);
    end;

    procedure GetDecimalPropertyValueFromJObjectByName(JObject: DotNet JObject;propertyName: Text;var value: Decimal): Boolean
    var
        StringValue: Text;
    begin
        if GetStringPropertyValueFromJObjectByName(JObject,propertyName,StringValue) then begin
          Evaluate(value,StringValue);
          exit(true);
        end;
        exit(false);
    end;

    procedure GetGuidPropertyValueFromJObjectByName(JObject: DotNet JObject;propertyName: Text;var value: Guid): Boolean
    var
        StringValue: Text;
    begin
        if GetStringPropertyValueFromJObjectByName(JObject,propertyName,StringValue) then begin
          Evaluate(value,StringValue);
          exit(true);
        end;
        exit(false);
    end;

    local procedure GetValueFromJObject(JObject: DotNet JObject;var value: Variant)
    var
        JValue: DotNet JValue;
    begin
        Clear(value);
        JValue := JObject;
        value := JValue.Value;
    end;

    procedure GetStringValueFromJObject(JObject: DotNet JObject;var value: Text)
    var
        VariantValue: Variant;
    begin
        Clear(value);
        GetValueFromJObject(JObject,VariantValue);
        value := Format(VariantValue);
    end;

    procedure AddJArrayToJObject(var JObject: DotNet JObject;propertyName: Text;value: Variant)
    var
        JArray2: DotNet JArray;
        JProperty: DotNet JProperty;
    begin
        JArray2 := value;
        JObject.Add(JProperty.JProperty(propertyName,JArray2));
    end;

    procedure AddJObjectToJObject(var JObject: DotNet JObject;propertyName: Text;value: Variant)
    var
        JObject2: DotNet JObject;
        JToken: DotNet JToken;
        ValueText: Text;
    begin
        JObject2 := value;
        ValueText := Format(value);
        JObject.Add(propertyName,JToken.Parse(ValueText));
    end;

    procedure AddJObjectToJArray(var JArray: DotNet JArray;value: Variant)
    var
        JObject: DotNet JObject;
    begin
        JObject := value;
        JArray.Add(JObject.DeepClone);
    end;

    procedure AddJPropertyToJObject(var JObject: DotNet JObject;propertyName: Text;value: Variant)
    var
        JProperty: DotNet JProperty;
        ValueText: Text;
    begin
        case true of
          value.IsInteger,
          value.IsDecimal:
            JProperty := JProperty.JProperty(propertyName,value);
          else begin
            ValueText := Format(value,0,9);
            JProperty := JProperty.JProperty(propertyName,ValueText);
          end;
        end;

        JObject.Add(JProperty);
    end;

    procedure AddNullJPropertyToJObject(var JObject: DotNet JObject;propertyName: Text)
    var
        JValue: DotNet JValue;
    begin
        JObject.Add(propertyName,JValue.CreateNull);
    end;

    procedure AddJValueToJObject(var JObject: DotNet JObject;value: Variant)
    var
        JValue: DotNet JValue;
    begin
        JObject := JValue.JValue(value);
    end;

    procedure AddJObjectToCollection(JObject: DotNet JObject)
    begin
        JsonArray.Add(JObject.DeepClone);
    end;

    procedure AddJArrayContentToCollection(JArray: DotNet JArray)
    begin
        JsonArray.Merge(JArray.DeepClone);
    end;

    procedure ReplaceOrAddJPropertyInJObject(var JObject: DotNet JObject;propertyName: Text;value: Variant): Boolean
    var
        JProperty: DotNet JProperty;
        OldProperty: DotNet JProperty;
        oldValue: Variant;
    begin
        JProperty := JObject.Property(propertyName);
        if not IsNull(JProperty) then begin
          OldProperty := JObject.Property(propertyName);
          oldValue := OldProperty.Value;
          JProperty.Replace(JProperty.JProperty(propertyName,value));
          exit(Format(oldValue) <> Format(value));
        end;

        AddJPropertyToJObject(JObject,propertyName,value);
        exit(true);
    end;

    procedure ReplaceOrAddDescendantJPropertyInJObject(var JObject: DotNet JObject;fullyQualifiedPropertyName: Text;value: Variant): Boolean
    var
        containerJObject: DotNet JObject;
        propertyName: Text;
    begin
        DecomposeQualifiedPathToContainerObjectAndPropertyName(JObject,fullyQualifiedPropertyName,containerJObject,propertyName);
        exit(ReplaceOrAddJPropertyInJObject(containerJObject,propertyName,value));
    end;

    [Scope('Personalization')]
    procedure GetCollectionCount(): Integer
    begin
        exit(JsonArray.Count);
    end;

    [Scope('Personalization')]
    procedure WriteCollectionToString(): Text
    begin
        exit(JsonArray.ToString);
    end;

    [Scope('Personalization')]
    procedure WriteObjectToString(): Text
    begin
        exit(JsonObject.ToString);
    end;

    [Scope('Personalization')]
    procedure FormatDecimalToJSONProperty(Value: Decimal;PropertyName: Text): Text
    var
        JProperty: DotNet JProperty;
    begin
        JProperty := JProperty.JProperty(PropertyName,Value);
        exit(JProperty.ToString);
    end;

    local procedure GetLastIndexOfPeriod(String: Text) LastIndex: Integer
    var
        Index: Integer;
    begin
        Index := StrPos(String,'.');
        LastIndex := Index;
        while Index > 0 do begin
          String := CopyStr(String,Index + 1);
          Index := StrPos(String,'.');
          LastIndex += Index;
        end;
    end;

    local procedure GetSubstringToLastPeriod(String: Text): Text
    var
        Index: Integer;
    begin
        Index := GetLastIndexOfPeriod(String);
        if Index > 0 then
          exit(CopyStr(String,1,Index - 1));
    end;

    local procedure DecomposeQualifiedPathToContainerObjectAndPropertyName(var JObject: DotNet JObject;fullyQualifiedPropertyName: Text;var containerJObject: DotNet JObject;var propertyName: Text)
    var
        containerJToken: DotNet JToken;
        containingPath: Text;
    begin
        Clear(containerJObject);
        propertyName := '';

        containingPath := GetSubstringToLastPeriod(fullyQualifiedPropertyName);
        containerJToken := JObject.SelectToken(containingPath);
        if IsNull(containerJToken) then
          exit;

        containerJObject := containerJToken;
        if containingPath <> '' then
          propertyName := CopyStr(fullyQualifiedPropertyName,StrLen(containingPath) + 2)
        else
          propertyName := fullyQualifiedPropertyName;
    end;

    [Scope('Personalization')]
    procedure XMLTextToJSONText(Xml: Text) Json: Text
    var
        XMLDOMMgt: Codeunit "XML DOM Management";
        JsonConvert: DotNet JsonConvert;
        JsonFormatting: DotNet Formatting;
        XmlDocument: DotNet XmlDocument;
    begin
        XMLDOMMgt.LoadXMLDocumentFromText(Xml,XmlDocument);
        Json := JsonConvert.SerializeXmlNode(XmlDocument.DocumentElement,JsonFormatting.Indented,true);
    end;

    [Scope('Personalization')]
    procedure JSONTextToXMLText(Json: Text;DocumentElementName: Text) Xml: Text
    var
        JsonConvert: DotNet JsonConvert;
        XmlDocument: DotNet XmlDocument;
    begin
        XmlDocument := JsonConvert.DeserializeXmlNode(Json,DocumentElementName);
        Xml := XmlDocument.OuterXml;
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure TryParseJObjectFromString(var JObject: DotNet JObject;StringToParse: Variant)
    begin
        JObject := JObject.Parse(Format(StringToParse));
    end;

    [TryFunction]
    local procedure TryReadAsBase64(var TempBlob: Record TempBlob;Value: Text)
    begin
        TempBlob.FromBase64String(Value);
    end;
}

