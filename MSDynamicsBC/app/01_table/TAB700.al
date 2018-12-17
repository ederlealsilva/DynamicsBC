table 700 "Error Message"
{
    // version NAVW113.00

    Caption = 'Error Message';
    DrillDownPageID = "Error Messages Part";
    LookupPageID = "Error Messages Part";

    fields
    {
        field(1;ID;Integer)
        {
            AutoIncrement = true;
            Caption = 'ID';
        }
        field(2;"Record ID";RecordID)
        {
            Caption = 'Record ID';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            var
                RecordRef: RecordRef;
            begin
                if RecordRef.Get("Record ID") then
                  "Table Number" := RecordRef.Number;
            end;
        }
        field(3;"Field Number";Integer)
        {
            Caption = 'Field Number';
        }
        field(4;"Message Type";Option)
        {
            Caption = 'Message Type';
            Editable = false;
            OptionCaption = 'Error,Warning,Information';
            OptionMembers = Error,Warning,Information;
        }
        field(5;Description;Text[250])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(6;"Additional Information";Text[250])
        {
            Caption = 'Additional Information';
            Editable = false;
        }
        field(7;"Support Url";Text[250])
        {
            Caption = 'Support Url';
            Editable = false;
        }
        field(8;"Table Number";Integer)
        {
            Caption = 'Table Number';
        }
        field(10;"Context Record ID";RecordID)
        {
            Caption = 'Context Record ID';
            DataClassification = SystemMetadata;
        }
        field(11;"Field Name";Text[80])
        {
            CalcFormula = Lookup(Field."Field Caption" WHERE (TableNo=FIELD("Table Number"),
                                                              "No."=FIELD("Field Number")));
            Caption = 'Field Name';
            FieldClass = FlowField;
        }
        field(12;"Table Name";Text[80])
        {
            CalcFormula = Lookup("Table Metadata".Caption WHERE (ID=FIELD("Table Number")));
            Caption = 'Table Name';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;ID)
        {
        }
        key(Key2;"Context Record ID","Record ID")
        {
        }
        key(Key3;"Message Type",ID)
        {
        }
    }

    fieldgroups
    {
    }

    var
        IfEmptyErr: Label '''%1'' in ''%2'' must not be blank.', Comment='%1=caption of a field, %2=key of record';
        IfLengthExceededErr: Label 'The maximum length of ''%1'' in ''%2'' is %3 characters. The actual length is %4.', Comment='%1=caption of a field, %2=key of record, %3=integer, %4=integer';
        IfInvalidCharactersErr: Label '''%1'' in ''%2'' contains characters that are not valid.', Comment='%1=caption of a field, %2=key of record';
        IfOutsideRangeErr: Label '''%1'' in ''%2'' is outside of the permitted range from %3 to %4.', Comment='%1=caption of a field, %2=key of record, %3=integer, %4=integer';
        IfGreaterThanErr: Label '''%1'' in ''%2'' must be less than or equal to %3.', Comment='%1=caption of a field, %2=key of record, %3=integer';
        IfLessThanErr: Label '''%1'' in ''%2'' must be greater than or equal to %3.', Comment='%1=caption of a field, %2=key of record, %3=integer';
        IfEqualToErr: Label '''%1'' in ''%2'' must not be equal to %3.', Comment='%1=caption of a field, %2=key of record, %3=integer';
        IfNotEqualToErr: Label '''%1'' in ''%2'' must be equal to %3.', Comment='%1=caption of a field, %2=key of record, %3=integer';
        HasErrorsMsg: Label 'One or more errors were found. You must resolve all the errors before you can proceed.';
        DataTypeManagement: Codeunit "Data Type Management";
        DevMsgNotTemporaryErr: Label 'This function can only be used when the record is temporary.';
        ContextRecordID: RecordID;

    [Scope('Personalization')]
    procedure LogIfEmpty(RecRelatedVariant: Variant;FieldNumber: Integer;MessageType: Option): Integer
    var
        RecordRef: RecordRef;
        TempRecordRef: RecordRef;
        FieldRef: FieldRef;
        EmptyFieldRef: FieldRef;
        NewDescription: Text;
    begin
        if not DataTypeManagement.GetRecordRefAndFieldRef(RecRelatedVariant,FieldNumber,RecordRef,FieldRef) then
          exit(0);

        TempRecordRef.Open(RecordRef.Number,true);
        EmptyFieldRef := TempRecordRef.Field(FieldNumber);

        if FieldRef.Value <> EmptyFieldRef.Value then
          exit(0);

        NewDescription := StrSubstNo(IfEmptyErr,FieldRef.Caption,Format(RecordRef.RecordId));

        exit(LogMessage(RecRelatedVariant,FieldNumber,MessageType,NewDescription));
    end;

    [Scope('Personalization')]
    procedure LogIfLengthExceeded(RecRelatedVariant: Variant;FieldNumber: Integer;MessageType: Option;MaxLength: Integer): Integer
    var
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        NewDescription: Text;
        StringLength: Integer;
    begin
        if not DataTypeManagement.GetRecordRefAndFieldRef(RecRelatedVariant,FieldNumber,RecordRef,FieldRef) then
          exit(0);

        StringLength := StrLen(Format(FieldRef.Value));
        if StringLength <= MaxLength then
          exit(0);

        NewDescription := StrSubstNo(IfLengthExceededErr,FieldRef.Caption,Format(RecordRef.RecordId),MaxLength,StringLength);

        exit(LogMessage(RecRelatedVariant,FieldNumber,MessageType,NewDescription));
    end;

    [Scope('Personalization')]
    procedure LogIfInvalidCharacters(RecRelatedVariant: Variant;FieldNumber: Integer;MessageType: Option;ValidCharacters: Text): Integer
    var
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        NewDescription: Text;
    begin
        if not DataTypeManagement.GetRecordRefAndFieldRef(RecRelatedVariant,FieldNumber,RecordRef,FieldRef) then
          exit(0);

        if DelChr(Format(FieldRef.Value),'=',ValidCharacters) = '' then
          exit(0);

        NewDescription := StrSubstNo(IfInvalidCharactersErr,FieldRef.Caption,Format(RecordRef.RecordId));

        exit(LogMessage(RecRelatedVariant,FieldNumber,MessageType,NewDescription));
    end;

    [Scope('Personalization')]
    procedure LogIfOutsideRange(RecRelatedVariant: Variant;FieldNumber: Integer;MessageType: Option;LowerBound: Variant;UpperBound: Variant): Integer
    var
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        NewDescription: Text;
    begin
        if FieldValueIsWithinFilter(RecRelatedVariant,FieldNumber,RecordRef,FieldRef,'%1..%2',LowerBound,UpperBound) then
          exit(0);

        NewDescription := StrSubstNo(IfOutsideRangeErr,FieldRef.Caption,Format(RecordRef.RecordId),LowerBound,UpperBound);

        exit(LogMessage(RecRelatedVariant,FieldNumber,MessageType,NewDescription));
    end;

    [Scope('Personalization')]
    procedure LogIfGreaterThan(RecRelatedVariant: Variant;FieldNumber: Integer;MessageType: Option;LowerBound: Variant): Integer
    var
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        NewDescription: Text;
    begin
        if FieldValueIsWithinFilter(RecRelatedVariant,FieldNumber,RecordRef,FieldRef,'<=%1',LowerBound,'') then
          exit(0);

        NewDescription := StrSubstNo(IfGreaterThanErr,FieldRef.Caption,Format(RecordRef.RecordId),LowerBound);

        exit(LogMessage(RecRelatedVariant,FieldNumber,MessageType,NewDescription));
    end;

    [Scope('Personalization')]
    procedure LogIfLessThan(RecRelatedVariant: Variant;FieldNumber: Integer;MessageType: Option;UpperBound: Variant): Integer
    var
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        NewDescription: Text;
    begin
        if FieldValueIsWithinFilter(RecRelatedVariant,FieldNumber,RecordRef,FieldRef,'>=%1',UpperBound,'') then
          exit(0);

        NewDescription := StrSubstNo(IfLessThanErr,FieldRef.Caption,Format(RecordRef.RecordId),UpperBound);

        exit(LogMessage(RecRelatedVariant,FieldNumber,MessageType,NewDescription));
    end;

    [Scope('Personalization')]
    procedure LogIfEqualTo(RecRelatedVariant: Variant;FieldNumber: Integer;MessageType: Option;ValueVariant: Variant): Integer
    var
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        NewDescription: Text;
    begin
        if FieldValueIsWithinFilter(RecRelatedVariant,FieldNumber,RecordRef,FieldRef,'<>%1',ValueVariant,'') then
          exit(0);

        NewDescription := StrSubstNo(IfEqualToErr,FieldRef.Caption,Format(RecordRef.RecordId),ValueVariant);

        exit(LogMessage(RecRelatedVariant,FieldNumber,MessageType,NewDescription));
    end;

    [Scope('Personalization')]
    procedure LogIfNotEqualTo(RecRelatedVariant: Variant;FieldNumber: Integer;MessageType: Option;ValueVariant: Variant): Integer
    var
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        NewDescription: Text;
    begin
        if FieldValueIsWithinFilter(RecRelatedVariant,FieldNumber,RecordRef,FieldRef,'=%1',ValueVariant,'') then
          exit(0);

        NewDescription := StrSubstNo(IfNotEqualToErr,FieldRef.Caption,Format(RecordRef.RecordId),ValueVariant);

        exit(LogMessage(RecRelatedVariant,FieldNumber,MessageType,NewDescription));
    end;

    [Scope('Personalization')]
    procedure LogSimpleMessage(MessageType: Option;NewDescription: Text): Integer
    begin
        AssertRecordTemporaryOrInContext;

        ID := 1;
        ClearFilters;
        if FindLast then
          ID += 1;

        Init;
        Validate("Message Type",MessageType);
        Validate(Description,CopyStr(NewDescription,1,MaxStrLen(Description)));
        Validate("Context Record ID",ContextRecordID);
        Insert(true);

        exit(ID);
    end;

    [Scope('Personalization')]
    procedure LogMessage(RecRelatedVariant: Variant;FieldNumber: Integer;MessageType: Option;NewDescription: Text): Integer
    var
        RecordRef: RecordRef;
        ErrorMessageID: Integer;
    begin
        if not DataTypeManagement.GetRecordRef(RecRelatedVariant,RecordRef) then
          exit(0);

        ErrorMessageID := FindRecord(RecordRef.RecordId,FieldNumber,MessageType,NewDescription);
        if ErrorMessageID <> 0 then
          exit(ErrorMessageID);

        LogSimpleMessage(MessageType,NewDescription);
        Validate("Record ID",RecordRef.RecordId);
        Validate("Field Number",FieldNumber);
        Modify(true);

        exit(ID);
    end;

    [Scope('Personalization')]
    procedure LogDetailedMessage(RecRelatedVariant: Variant;FieldNumber: Integer;MessageType: Option;NewDescription: Text;AdditionalInformation: Text[250];SupportUrl: Text[250]): Integer
    begin
        LogMessage(RecRelatedVariant,FieldNumber,MessageType,NewDescription);
        Validate("Additional Information",AdditionalInformation);
        Validate("Support Url",SupportUrl);
        Modify(true);

        exit(ID);
    end;

    [Scope('Personalization')]
    procedure AddMessageDetails(MessageID: Integer;AdditionalInformation: Text[250];SupportUrl: Text[250])
    begin
        if MessageID = 0 then
          exit;

        Get(MessageID);
        Validate("Additional Information",AdditionalInformation);
        Validate("Support Url",SupportUrl);
        Modify(true);
    end;

    [Scope('Personalization')]
    procedure SetContext(ContextRecordVariant: Variant)
    var
        RecordRef: RecordRef;
    begin
        if DataTypeManagement.GetRecordRef(ContextRecordVariant,RecordRef) then
          ContextRecordID := RecordRef.RecordId;
    end;

    [Scope('Personalization')]
    procedure ClearContext()
    begin
        Clear(ContextRecordID);
    end;

    [Scope('Personalization')]
    procedure ClearLog()
    begin
        AssertRecordTemporaryOrInContext;

        ClearFilters;
        SetContextFilter;
        DeleteAll(true);
    end;

    [Scope('Personalization')]
    procedure ClearLogRec(RecordVariant: Variant)
    begin
        AssertRecordTemporaryOrInContext;

        ClearFilters;
        SetContextFilter;
        SetRecordFilter(RecordVariant);
        DeleteAll(true);
    end;

    [Scope('Personalization')]
    procedure HasErrorMessagesRelatedTo(RecRelatedVariant: Variant): Boolean
    var
        RecordRef: RecordRef;
    begin
        AssertRecordTemporaryOrInContext;

        if not DataTypeManagement.GetRecordRef(RecRelatedVariant,RecordRef) then
          exit(false);

        ClearFilters;
        SetContextFilter;
        SetRange("Record ID",RecordRef.RecordId);
        exit(not IsEmpty);
    end;

    [Scope('Personalization')]
    procedure ErrorMessageCount(LowestSeverityMessageType: Option): Integer
    begin
        AssertRecordTemporaryOrInContext;

        ClearFilters;
        SetContextFilter;
        SetRange("Message Type","Message Type"::Error,LowestSeverityMessageType);
        exit(Count);
    end;

    [Scope('Personalization')]
    procedure HasErrors(ShowMessage: Boolean): Boolean
    begin
        if ErrorMessageCount("Message Type"::Error) = 0 then
          exit(false);

        if ShowMessage and GuiAllowed then
          Message(HasErrorsMsg);

        exit(true);
    end;

    [Scope('Personalization')]
    procedure ShowErrorMessages(RollBackOnError: Boolean) ErrorString: Text
    var
        ErrorMessages: Page "Error Messages";
    begin
        AssertRecordTemporaryOrInContext;

        ClearFilters;
        SetContextFilter;
        if IsEmpty then
          exit;

        if GuiAllowed then begin
          ErrorMessages.SetRecords(Rec);
          ErrorMessages.Run;
        end;

        ErrorString := ToString;

        if RollBackOnError then
          if HasErrors(false) then
            Error('');

        exit;
    end;

    [Scope('Personalization')]
    procedure ToString(): Text
    var
        ErrorString: Text;
    begin
        AssertRecordTemporaryOrInContext;

        ClearFilters;
        SetContextFilter;
        SetCurrentKey("Message Type",ID);
        if FindSet then
          repeat
            if ErrorString <> '' then
              ErrorString += '\';
            ErrorString += Format("Message Type") + ': ' + Description;
          until Next = 0;
        ClearFilters;
        exit(ErrorString);
    end;

    [Scope('Personalization')]
    procedure ThrowError()
    begin
        AssertRecordTemporaryOrInContext;

        if HasErrors(false) then
          Error(ToString);
    end;

    local procedure FieldValueIsWithinFilter(RecRelatedVariant: Variant;FieldNumber: Integer;var RecordRef: RecordRef;var FieldRef: FieldRef;FilterString: Text;FilterValue1: Variant;FilterValue2: Variant): Boolean
    var
        TempRecordRef: RecordRef;
        TempFieldRef: FieldRef;
    begin
        if not DataTypeManagement.GetRecordRefAndFieldRef(RecRelatedVariant,FieldNumber,RecordRef,FieldRef) then
          exit(false);

        TempRecordRef.Open(RecordRef.Number,true);
        TempRecordRef.Init;
        TempFieldRef := TempRecordRef.Field(FieldNumber);
        TempFieldRef.Value(FieldRef.Value);
        TempRecordRef.Insert;

        TempFieldRef.SetFilter(FilterString,FilterValue1,FilterValue2);

        exit(not TempRecordRef.IsEmpty);
    end;

    [Scope('Personalization')]
    procedure FindRecord(RecordID: RecordID;FieldNumber: Integer;MessageType: Option;NewDescription: Text): Integer
    begin
        ClearFilters;
        SetContextFilter;
        SetRange("Record ID",RecordID);
        SetRange("Field Number",FieldNumber);
        SetRange("Message Type",MessageType);
        SetRange(Description,CopyStr(NewDescription,1,MaxStrLen(Description)));
        if FindFirst then
          exit(ID);
        exit(0);
    end;

    local procedure AssertRecordTemporary()
    begin
        if not IsTemporary then
          Error(DevMsgNotTemporaryErr);
    end;

    local procedure AssertRecordTemporaryOrInContext()
    var
        DummyEmptyRecordID: RecordID;
    begin
        if ContextRecordID = DummyEmptyRecordID then
          AssertRecordTemporary;
    end;

    [Scope('Personalization')]
    procedure CopyToTemp(var TempErrorMessage: Record "Error Message" temporary)
    var
        TempID: Integer;
    begin
        if not FindSet then
          exit;

        TempErrorMessage.Reset;
        if TempErrorMessage.FindLast then ;
        TempID := TempErrorMessage.ID;

        repeat
          if TempErrorMessage.FindRecord("Record ID","Field Number","Message Type",Description) = 0 then begin
            TempID += 1;
            TempErrorMessage := Rec;
            TempErrorMessage.ID := TempID;
            TempErrorMessage.Insert;
          end;
        until Next = 0;
        TempErrorMessage.Reset;
    end;

    [Scope('Personalization')]
    procedure CopyFromTemp(var TempErrorMessage: Record "Error Message" temporary)
    var
        ErrorMessage: Record "Error Message";
    begin
        if not TempErrorMessage.FindSet then
          exit;

        repeat
          ErrorMessage := TempErrorMessage;
          ErrorMessage.ID := 0;
          ErrorMessage.Insert(true);
        until TempErrorMessage.Next = 0;
    end;

    [Scope('Personalization')]
    procedure CopyFromContext(ContextRecordVariant: Variant)
    var
        ErrorMessage: Record "Error Message";
        RecordRef: RecordRef;
    begin
        AssertRecordTemporary;

        if not DataTypeManagement.GetRecordRef(ContextRecordVariant,RecordRef) then
          exit;

        ErrorMessage.SetRange("Context Record ID",RecordRef.RecordId);
        ErrorMessage.CopyToTemp(Rec);
    end;

    local procedure ClearFilters()
    var
        LocalContextRecordID: RecordID;
    begin
        LocalContextRecordID := ContextRecordID;
        Reset;
        ContextRecordID := LocalContextRecordID;
    end;

    local procedure SetContextFilter()
    var
        DummyEmptyContextRecordID: RecordID;
    begin
        if ContextRecordID = DummyEmptyContextRecordID then
          SetRange("Context Record ID")
        else
          SetRange("Context Record ID",ContextRecordID);
    end;

    local procedure SetRecordFilter(RecordVariant: Variant)
    var
        RecordRef: RecordRef;
    begin
        DataTypeManagement.GetRecordRef(RecordVariant,RecordRef);
        SetRange("Record ID",RecordRef.RecordId);
    end;
}

