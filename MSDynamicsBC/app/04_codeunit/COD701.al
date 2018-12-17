codeunit 701 "Data Type Management"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    [Scope('Personalization')]
    procedure GetRecordRefAndFieldRef(RecRelatedVariant: Variant;FieldNumber: Integer;var RecordRef: RecordRef;var FieldRef: FieldRef): Boolean
    begin
        if not GetRecordRef(RecRelatedVariant,RecordRef) then
          exit(false);

        FieldRef := RecordRef.Field(FieldNumber);
        exit(true);
    end;

    [Scope('Personalization')]
    procedure GetRecordRef(RecRelatedVariant: Variant;var ResultRecordRef: RecordRef): Boolean
    var
        RecID: RecordID;
    begin
        case true of
          RecRelatedVariant.IsRecord:
            ResultRecordRef.GetTable(RecRelatedVariant);
          RecRelatedVariant.IsRecordRef:
            ResultRecordRef := RecRelatedVariant;
          RecRelatedVariant.IsRecordId:
            begin
              RecID := RecRelatedVariant;
              if RecID.TableNo = 0 then
                exit(false);
              if not ResultRecordRef.Get(RecID) then
                ResultRecordRef.Open(RecID.TableNo);
            end;
          else
            exit(false);
        end;
        exit(true);
    end;

    [Scope('Personalization')]
    procedure FindFieldByName(RecordRef: RecordRef;var FieldRef: FieldRef;FieldNameTxt: Text): Boolean
    var
        "Field": Record "Field";
    begin
        Field.SetRange(TableNo,RecordRef.Number);
        Field.SetFilter(ObsoleteState,'<>%1',Field.ObsoleteState::Removed);
        Field.SetRange(FieldName,FieldNameTxt);

        if not Field.FindFirst then
          exit(false);

        FieldRef := RecordRef.Field(Field."No.");
        exit(true);
    end;

    [Scope('Personalization')]
    procedure SetFieldValue(var RecordVariant: Variant;FieldName: Text;FieldValue: Variant): Boolean
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        if not GetRecordRef(RecordVariant,RecRef) then
          exit;
        if not FindFieldByName(RecRef,FieldRef,FieldName) then
          exit;

        FieldRef.Value := FieldValue;
        RecRef.SetTable(RecordVariant);
        exit(true);
    end;

    [Scope('Personalization')]
    procedure ValidateFieldValue(var RecordVariant: Variant;FieldName: Text;FieldValue: Variant): Boolean
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        if not GetRecordRef(RecordVariant,RecRef) then
          exit;
        if not FindFieldByName(RecRef,FieldRef,FieldName) then
          exit;

        FieldRef.Validate(FieldValue);
        RecRef.SetTable(RecordVariant);
        exit(true);
    end;

    procedure InsertFieldToBuffer(var TempField: Record "Field" temporary;TableNumber: Integer;FieldNumber: Integer)
    begin
        TempField.TableNo := TableNumber;
        TempField."No." := FieldNumber;
        TempField.Insert;
    end;
}

