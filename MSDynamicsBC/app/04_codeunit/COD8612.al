codeunit 8612 "Config. Template Management"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'The template %1 is in this hierarchy and contains the same field.';
        Text001: Label 'A number series has not been set up for table %1 %2. The instance could not be created.', Comment='%1 = Table ID, %2 = Table caption';
        Text002: Label 'The instance %1 already exists in table %2 %3.', Comment='%2 = Table ID, %3 = Table caption';
        Text003: Label 'The value for the key field %1 is not filled for the instance.';
        UpdatingRelatedTable: Boolean;

    [Scope('Personalization')]
    procedure UpdateFromTemplateSelection(var RecRef: RecordRef)
    var
        ConfigTemplateHeader: Record "Config. Template Header";
    begin
        ConfigTemplateHeader.SetRange("Table ID",RecRef.Number);
        if PAGE.RunModal(PAGE::"Config. Template List",ConfigTemplateHeader,ConfigTemplateHeader.Code) = ACTION::LookupOK then
          UpdateRecord(ConfigTemplateHeader,RecRef);
    end;

    [Scope('Personalization')]
    procedure UpdateRecord(ConfigTemplateHeader: Record "Config. Template Header";var RecRef: RecordRef)
    var
        TempDummyField: Record "Field" temporary;
    begin
        UpdateRecordWithSkipFields(ConfigTemplateHeader,RecRef,false,TempDummyField);
    end;

    local procedure UpdateRecordWithSkipFields(ConfigTemplateHeader: Record "Config. Template Header";var RecRef: RecordRef;SkipFields: Boolean;var TempSkipFields: Record "Field" temporary)
    begin
        if TestKeyFields(RecRef) then
          InsertTemplate(RecRef,ConfigTemplateHeader,SkipFields,TempSkipFields)
        else begin
          InsertRecordWithKeyFields(RecRef,ConfigTemplateHeader);
          if TestKeyFields(RecRef) then
            InsertTemplate(RecRef,ConfigTemplateHeader,SkipFields,TempSkipFields)
          else
            Error(Text001,RecRef.Number,RecRef.Caption);
        end;
    end;

    local procedure InsertTemplate(var RecRef: RecordRef;ConfigTemplateHeader: Record "Config. Template Header";SkipFields: Boolean;var TempSkipField: Record "Field")
    var
        ConfigTemplateLine: Record "Config. Template Line";
        ConfigTemplateHeader2: Record "Config. Template Header";
        FieldRef: FieldRef;
        RecRef2: RecordRef;
        SkipCurrentField: Boolean;
    begin
        ConfigTemplateLine.SetRange("Data Template Code",ConfigTemplateHeader.Code);
        if ConfigTemplateLine.FindSet then
          repeat
            case ConfigTemplateLine.Type of
              ConfigTemplateLine.Type::Field:
                if ConfigTemplateLine."Field ID" <> 0 then begin
                  if SkipFields then
                    SkipCurrentField := ShouldSkipField(TempSkipField,ConfigTemplateLine."Field ID",ConfigTemplateLine."Table ID")
                  else
                    SkipCurrentField := false;

                  if not SkipCurrentField then begin
                    FieldRef := RecRef.Field(ConfigTemplateLine."Field ID");
                    ModifyRecordWithField(RecRef,FieldRef,ConfigTemplateLine."Default Value",ConfigTemplateLine."Language ID");
                  end;
                end;
              ConfigTemplateLine.Type::Template:
                if ConfigTemplateLine."Template Code" <> '' then
                  if ConfigTemplateHeader2.Get(ConfigTemplateLine."Template Code") then
                    if ConfigTemplateHeader2."Table ID" = ConfigTemplateHeader."Table ID" then
                      InsertTemplate(RecRef,ConfigTemplateHeader2,SkipFields,TempSkipField)
                    else begin
                      UpdatingRelatedTable := true;
                      RecRef2.Open(ConfigTemplateHeader2."Table ID");
                      UpdateRecord(ConfigTemplateHeader2,RecRef2);
                      UpdatingRelatedTable := false;
                    end;
            end;
          until ConfigTemplateLine.Next = 0;
    end;

    [Scope('Personalization')]
    procedure ApplyTemplate(var OriginalRecRef: RecordRef;var TempFieldsAssigned: Record "Field" temporary;var TemplateAppliedRecRef: RecordRef): Boolean
    var
        ConfigTmplSelectionRules: Record "Config. Tmpl. Selection Rules";
        ConfigTemplateHeader: Record "Config. Template Header";
        BackupRecRef: RecordRef;
        AssignedFieldRef: FieldRef;
        APIFieldRef: FieldRef;
        SkipFields: Boolean;
    begin
        if not ConfigTmplSelectionRules.FindTemplateBasedOnRecordFields(OriginalRecRef,ConfigTemplateHeader) then
          exit(false);

        TempFieldsAssigned.Reset;
        SkipFields := TempFieldsAssigned.FindSet;

        BackupRecRef := OriginalRecRef.Duplicate;
        TemplateAppliedRecRef := OriginalRecRef.Duplicate;

        UpdateRecordWithSkipFields(ConfigTemplateHeader,TemplateAppliedRecRef,SkipFields,TempFieldsAssigned);

        // Assign values set back in case validating unrelated field has modified them
        if SkipFields then
          repeat
            AssignedFieldRef := BackupRecRef.Field(TempFieldsAssigned."No.");
            APIFieldRef := TemplateAppliedRecRef.Field(TempFieldsAssigned."No.");
            APIFieldRef.Value := AssignedFieldRef.Value;
          until TempFieldsAssigned.Next = 0;

        exit(true);
    end;

    local procedure ModifyRecordWithField(var RecRef: RecordRef;FieldRef: FieldRef;Value: Text[250];LanguageID: Integer)
    var
        ConfigValidateMgt: Codeunit "Config. Validate Management";
    begin
        ConfigValidateMgt.ValidateFieldValue(RecRef,FieldRef,Value,false,LanguageID);
        RecRef.Modify(true);
    end;

    local procedure TestKeyFields(var RecRef: RecordRef): Boolean
    var
        KeyRef: KeyRef;
        FieldRef: FieldRef;
        KeyFieldCount: Integer;
    begin
        KeyRef := RecRef.KeyIndex(1);
        for KeyFieldCount := 1 to KeyRef.FieldCount do begin
          FieldRef := KeyRef.FieldIndex(KeyFieldCount);
          if Format(FieldRef.Value) = '' then
            exit(false);
        end;
        exit(true);
    end;

    [Scope('Personalization')]
    procedure TestHierarchy(ConfigTemplateLine: Record "Config. Template Line")
    var
        TempConfigTemplateLine: Record "Config. Template Line" temporary;
    begin
        GetHierarchicalLines(TempConfigTemplateLine,ConfigTemplateLine);
        with TempConfigTemplateLine do begin
          SetFilter("Field ID",'>%1',0); // exclude config. lines not handled yet
          if FindSet then
            repeat
              SetRange("Field ID","Field ID");
              if Count > 1 then
                Error(Text000,"Data Template Code");
              DeleteAll;
              SetFilter("Field ID",'>%1',0);
            until Next = 0;
        end;
    end;

    local procedure GetHierarchicalLines(var ConfigTemplateLineBuf: Record "Config. Template Line";ConfigTemplateLine: Record "Config. Template Line")
    var
        SubConfigTemplateLine: Record "Config. Template Line";
        CurrConfigTemplateLine: Record "Config. Template Line";
    begin
        with CurrConfigTemplateLine do begin
          SetRange("Data Template Code",ConfigTemplateLine."Data Template Code");
          if FindSet then
            repeat
              // get current version of record because it's may not be in DB yet
              if "Line No." = ConfigTemplateLine."Line No." then
                CurrConfigTemplateLine := ConfigTemplateLine;
              if Type = Type::Field then begin
                ConfigTemplateLineBuf := CurrConfigTemplateLine;
                if not ConfigTemplateLineBuf.Find then
                  ConfigTemplateLineBuf.Insert;
              end else begin
                SubConfigTemplateLine.Init;
                SubConfigTemplateLine."Data Template Code" := "Template Code";
                GetHierarchicalLines(ConfigTemplateLineBuf,SubConfigTemplateLine);
              end;
            until Next = 0;
        end;
    end;

    local procedure InsertRecordWithKeyFields(var RecRef: RecordRef;ConfigTemplateHeader: Record "Config. Template Header")
    var
        ConfigTemplateLine: Record "Config. Template Line";
        ConfigValidateMgt: Codeunit "Config. Validate Management";
        RecRef1: RecordRef;
        KeyRef: KeyRef;
        FieldRef: FieldRef;
        KeyFieldCount: Integer;
        MessageString: Text[250];
    begin
        ConfigTemplateLine.SetRange("Data Template Code",ConfigTemplateHeader.Code);

        KeyRef := RecRef.KeyIndex(1);
        for KeyFieldCount := 1 to KeyRef.FieldCount do begin
          FieldRef := KeyRef.FieldIndex(KeyFieldCount);
          ConfigTemplateLine.SetRange("Field ID",FieldRef.Number);
          if ConfigTemplateLine.FindFirst then begin
            ConfigValidateMgt.ValidateFieldValue(
              RecRef,FieldRef,ConfigTemplateLine."Default Value",false,ConfigTemplateLine."Language ID");
          end else
            if KeyRef.FieldCount <> 1 then
              Error(Text003,FieldRef.Name);
        end;

        RecRef1 := RecRef.Duplicate;

        if RecRef1.Find('=') then
          if not UpdatingRelatedTable then begin
            MessageString := MessageString + ' ' + Format(FieldRef.Value);
            MessageString := DelChr(MessageString,'<');
            Error(Text002,MessageString,RecRef.Number,RecRef.Caption);
          end else
            exit;

        RecRef.Insert(true);
    end;

    [Scope('Personalization')]
    procedure SetUpdatingRelatedTable(NewUpdatingRelatedTable: Boolean)
    begin
        UpdatingRelatedTable := NewUpdatingRelatedTable;
    end;

    [Scope('Personalization')]
    procedure CreateConfigTemplateAndLines(var "Code": Code[10];Description: Text[50];TableID: Integer;DefaultValuesFieldRefArray: array [100] of FieldRef)
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        FieldRef: FieldRef;
        I: Integer;
    begin
        ConfigTemplateHeader.Init;

        if Code = '' then
          Code := GetNextAvailableCode(TableID);

        ConfigTemplateHeader.Code := Code;
        ConfigTemplateHeader.Description := Description;
        ConfigTemplateHeader."Table ID" := TableID;
        ConfigTemplateHeader.Insert(true);

        for I := 1 to ArrayLen(DefaultValuesFieldRefArray) do begin
          FieldRef := DefaultValuesFieldRefArray[I];
          InsertConfigTemplateLineFromField(Code,FieldRef,TableID);
        end;
    end;

    [Scope('Personalization')]
    procedure UpdateConfigTemplateAndLines("Code": Code[10];Description: Text[50];TableID: Integer;DefaultValuesFieldRefArray: array [100] of FieldRef)
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateLine: Record "Config. Template Line";
        FieldRef: FieldRef;
        I: Integer;
        Value: Text[250];
    begin
        ConfigTemplateHeader.Get(Code);
        ConfigTemplateHeader.Description := Description;
        ConfigTemplateHeader.Modify;

        for I := 1 to ArrayLen(DefaultValuesFieldRefArray) do begin
          FieldRef := DefaultValuesFieldRefArray[I];
          ConfigTemplateLine.SetFilter("Data Template Code",Code);
          ConfigTemplateLine.SetFilter(Type,'=%1',ConfigTemplateLine.Type::Field);
          ConfigTemplateLine.SetFilter("Field ID",'=%1',FieldRef.Number);
          ConfigTemplateLine.SetFilter("Table ID",'=%1',TableID);

          if ConfigTemplateLine.FindLast then begin
            Value := Format(FieldRef.Value);
            if Value <> ConfigTemplateLine."Default Value" then begin
              ConfigTemplateLine."Default Value" := Value;
              ConfigTemplateLine."Language ID" := GlobalLanguage;
              ConfigTemplateLine.Modify(true);
            end;
          end else
            InsertConfigTemplateLineFromField(Code,FieldRef,TableID);
        end;
    end;

    [Scope('Personalization')]
    procedure ApplyTemplateLinesWithoutValidation(ConfigTemplateHeader: Record "Config. Template Header";var RecordRef: RecordRef)
    var
        ConfigTemplateLine: Record "Config. Template Line";
        ConfigValidateMgt: Codeunit "Config. Validate Management";
        FieldRef: FieldRef;
    begin
        ConfigTemplateLine.SetFilter("Data Template Code",ConfigTemplateHeader.Code);

        if ConfigTemplateLine.FindSet then
          repeat
            if ConfigTemplateLine.Type = ConfigTemplateLine.Type::Field then
              if RecordRef.FieldExist(ConfigTemplateLine."Field ID") then begin
                FieldRef := RecordRef.Field(ConfigTemplateLine."Field ID");
                ConfigValidateMgt.ValidateFieldValue(
                  RecordRef,FieldRef,ConfigTemplateLine."Default Value",true,ConfigTemplateLine."Language ID");
                RecordRef.Modify(false);
                OnApplyTemplLinesWithoutValidationAfterRecRefCheck(ConfigTemplateHeader,ConfigTemplateLine,RecordRef);
              end;
          until ConfigTemplateLine.Next = 0;
    end;

    [Scope('Personalization')]
    procedure GetNextAvailableCode(TableID: Integer): Code[10]
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        NextCode: Code[10];
        TplExists: Boolean;
    begin
        if TableID in [DATABASE::Customer,DATABASE::Vendor,DATABASE::Item] then begin
          ConfigTemplateHeader.SetRange("Table ID",TableID);
          TplExists := ConfigTemplateHeader.FindLast;

          if TplExists and (IncStr(ConfigTemplateHeader.Code) <> '') then
            NextCode := ConfigTemplateHeader.Code
          else begin
            ConfigTemplateHeader."Table ID" := TableID;
            ConfigTemplateHeader.CalcFields("Table Caption");
            NextCode := CopyStr(ConfigTemplateHeader."Table Caption",1,4) + '000001';
          end;

          while ConfigTemplateHeader.Get(NextCode) do
            NextCode := IncStr(NextCode);
        end else begin
          NextCode := '0000000001';
          while ConfigTemplateHeader.Get(NextCode) do
            NextCode := IncStr(NextCode);
        end;
        exit(NextCode);
    end;

    [Scope('Personalization')]
    procedure AddRelatedTemplate("Code": Code[10];RelatedTemplateCode: Code[10])
    var
        ConfigTemplateLine: Record "Config. Template Line";
    begin
        ConfigTemplateLine.SetRange("Data Template Code",Code);
        ConfigTemplateLine.SetRange(Type,ConfigTemplateLine.Type::"Related Template");
        ConfigTemplateLine.SetRange("Template Code",RelatedTemplateCode);

        if not ConfigTemplateLine.IsEmpty then
          exit;

        Clear(ConfigTemplateLine);
        ConfigTemplateLine."Data Template Code" := Code;
        ConfigTemplateLine."Template Code" := RelatedTemplateCode;
        ConfigTemplateLine."Line No." := GetNextLineNo(Code);
        ConfigTemplateLine.Type := ConfigTemplateLine.Type::"Related Template";
        ConfigTemplateLine.Insert(true);
    end;

    [Scope('Personalization')]
    procedure RemoveRelatedTemplate("Code": Code[10];RelatedTemplateCode: Code[10])
    var
        ConfigTemplateLine: Record "Config. Template Line";
    begin
        ConfigTemplateLine.SetRange("Data Template Code",Code);
        ConfigTemplateLine.SetRange(Type,ConfigTemplateLine.Type::"Related Template");
        ConfigTemplateLine.SetRange("Template Code",RelatedTemplateCode);

        if ConfigTemplateLine.FindFirst then
          ConfigTemplateLine.Delete(true);
    end;

    [Scope('Personalization')]
    procedure DeleteRelatedTemplates(ConfigTemplateHeaderCode: Code[10];TableID: Integer)
    var
        ConfigTemplateLine: Record "Config. Template Line";
        RelatedConfigTemplateHeader: Record "Config. Template Header";
    begin
        ConfigTemplateLine.SetRange("Data Template Code",ConfigTemplateHeaderCode);
        ConfigTemplateLine.SetRange(Type,ConfigTemplateLine.Type::"Related Template");

        if ConfigTemplateLine.FindSet then
          repeat
            RelatedConfigTemplateHeader.Get(ConfigTemplateLine."Template Code");
            if RelatedConfigTemplateHeader."Table ID" = TableID then begin
              RelatedConfigTemplateHeader.Delete(true);
              ConfigTemplateLine.Delete(true);
            end;
          until ConfigTemplateLine.Next = 0;
    end;

    [Scope('Personalization')]
    procedure ReplaceDefaultValueForAllTemplates(TableID: Integer;FieldID: Integer;DefaultValue: Text[250])
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateLine: Record "Config. Template Line";
    begin
        ConfigTemplateHeader.SetRange("Table ID",TableID);
        if ConfigTemplateHeader.FindSet then
          repeat
            ConfigTemplateLine.SetRange("Data Template Code",ConfigTemplateHeader.Code);
            ConfigTemplateLine.SetRange("Field ID",FieldID);
            ConfigTemplateLine.DeleteAll;
            InsertConfigTemplateLine(ConfigTemplateHeader.Code,FieldID,DefaultValue,TableID);
          until ConfigTemplateHeader.Next = 0;
    end;

    [Scope('Personalization')]
    procedure InsertConfigTemplateLineFromField(ConfigTemplateHeaderCode: Code[10];FieldRef: FieldRef;TableID: Integer)
    var
        DummyConfigTemplateLine: Record "Config. Template Line";
    begin
        DummyConfigTemplateLine."Default Value" := FieldRef.Value;
        InsertConfigTemplateLine(ConfigTemplateHeaderCode,FieldRef.Number,DummyConfigTemplateLine."Default Value",TableID);
    end;

    [Scope('Personalization')]
    procedure InsertConfigTemplateLine(ConfigTemplateHeaderCode: Code[10];FieldID: Integer;DefaultValue: Text[250];TableID: Integer)
    var
        ConfigTemplateLine: Record "Config. Template Line";
    begin
        ConfigTemplateLine.Init;
        ConfigTemplateLine."Data Template Code" := ConfigTemplateHeaderCode;
        ConfigTemplateLine.Type := ConfigTemplateLine.Type::Field;
        ConfigTemplateLine."Line No." := GetNextLineNo(ConfigTemplateHeaderCode);
        ConfigTemplateLine."Field ID" := FieldID;
        ConfigTemplateLine."Table ID" := TableID;
        ConfigTemplateLine."Default Value" := DefaultValue;

        ConfigTemplateLine.Insert(true);
    end;

    local procedure GetNextLineNo(ConfigTemplateHeaderCode: Code[10]): Integer
    var
        ConfigTemplateLine: Record "Config. Template Line";
    begin
        ConfigTemplateLine.SetFilter("Data Template Code",ConfigTemplateHeaderCode);

        if ConfigTemplateLine.FindLast then
          exit(ConfigTemplateLine."Line No." + 10000);

        exit(10000);
    end;

    procedure RemoveEmptyFieldsFromTemplateHeader(var RecRef: RecordRef;ConfigTemplateHeader: Record "Config. Template Header")
    var
        ConfigTemplateLine: Record "Config. Template Line";
        FieldRef: FieldRef;
    begin
        ConfigTemplateLine.SetRange("Data Template Code",ConfigTemplateHeader.Code);
        if ConfigTemplateLine.FindSet then
          repeat
            if ConfigTemplateLine.Type = ConfigTemplateLine.Type::Field then
              if ConfigTemplateLine."Field ID" <> 0 then begin
                FieldRef := RecRef.Field(ConfigTemplateLine."Field ID");
                if Format(FieldRef.Value) = '' then
                  ConfigTemplateLine.Delete;
              end;
          until ConfigTemplateLine.Next = 0;
    end;

    local procedure ShouldSkipField(var TempSkipField: Record "Field";CurrentFieldNo: Integer;CurrentTableNo: Integer): Boolean
    begin
        TempSkipField.Reset;
        exit(TempSkipField.Get(CurrentTableNo,CurrentFieldNo));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnApplyTemplLinesWithoutValidationAfterRecRefCheck(ConfigTemplateHeader: Record "Config. Template Header";ConfigTemplateLine: Record "Config. Template Line";var RecordRef: RecordRef)
    begin
    end;
}

