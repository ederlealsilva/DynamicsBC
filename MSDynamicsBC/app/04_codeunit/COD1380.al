codeunit 1380 "Batch Processing Mgt."
{
    // version NAVW113.00

    Permissions = TableData "Batch Processing Parameter"=rimd,
                  TableData "Batch Processing Parameter Map"=rimd;

    trigger OnRun()
    begin
        RunCustomProcessing;
    end;

    var
        PostingTemplateMsg: Label 'Processing: @1@@@@@@@', Comment='1 - overall progress';
        TempErrorMessage: Record "Error Message" temporary;
        RecRefCustomerProcessing: RecordRef;
        ProcessingCodeunitID: Integer;
        BatchID: Guid;
        ProcessingCodeunitNotSetErr: Label 'A processing codeunit has not been selected.';
        BatchCompletedMsg: Label 'All the documents were posted.';
        BatchCompletedWithErrorsMsg: Label 'One or more of the documents could not be posted.';
        IsCustomProcessingHandled: Boolean;

    procedure BatchProcess(var RecRef: RecordRef)
    var
        Window: Dialog;
        CounterTotal: Integer;
        CounterToPost: Integer;
        CounterPosted: Integer;
        BatchConfirm: Option " ",Skip,Update;
    begin
        if ProcessingCodeunitID = 0 then
          Error(ProcessingCodeunitNotSetErr);

        with RecRef do begin
          if IsEmpty then
            exit;

          TempErrorMessage.DeleteAll;

          FillBatchProcessingMap(RecRef);
          Commit;

          FindSet;

          if GuiAllowed then begin
            Window.Open(PostingTemplateMsg);
            CounterTotal := Count;
          end;

          repeat
            if GuiAllowed then begin
              CounterToPost += 1;
              Window.Update(1,Round(CounterToPost / CounterTotal * 10000,1));
            end;

            if CanProcessRecord(RecRef) then
              if ProcessRecord(RecRef,BatchConfirm) then
                CounterPosted += 1;
          until Next = 0;

          ResetBatchID;

          if GuiAllowed then begin
            Window.Close;
            if CounterPosted <> CounterTotal then
              Message(BatchCompletedWithErrorsMsg)
            else
              Message(BatchCompletedMsg);
          end;
        end;

        OnAfterBatchProcess(RecRef,CounterPosted);
    end;

    local procedure CanProcessRecord(var RecRef: RecordRef): Boolean
    var
        Result: Boolean;
    begin
        Result := true;
        OnVerifyRecord(RecRef,Result);

        exit(Result);
    end;

    local procedure FillBatchProcessingMap(var RecRef: RecordRef)
    begin
        with RecRef do begin
          FindSet;
          repeat
            InsertBatchParameterMapEntry(RecRef);
          until Next = 0;
        end;
    end;

    procedure GetErrorMessages(var TempErrorMessageResult: Record "Error Message" temporary)
    begin
        TempErrorMessageResult.Copy(TempErrorMessage,true);
    end;

    local procedure InsertBatchParameterMapEntry(RecRef: RecordRef)
    var
        BatchProcessingParameterMap: Record "Batch Processing Parameter Map";
    begin
        if IsNullGuid(BatchID) then
          exit;

        BatchProcessingParameterMap.Init;
        BatchProcessingParameterMap."Record ID" := RecRef.RecordId;
        BatchProcessingParameterMap."Batch ID" := BatchID;
        BatchProcessingParameterMap.Insert;
    end;

    local procedure InvokeProcessing(var RecRef: RecordRef): Boolean
    var
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        RecVar: Variant;
        Result: Boolean;
    begin
        ClearLastError;

        BatchProcessingMgt.SetRecRefForCustomProcessing(RecRef);
        Result := BatchProcessingMgt.Run;
        BatchProcessingMgt.GetRecRefForCustomProcessing(RecRef);

        RecVar := RecRef;

        if (GetLastErrorCallstack = '') and Result and not BatchProcessingMgt.GetIsCustomProcessingHandled then
          Result := CODEUNIT.Run(ProcessingCodeunitID,RecVar);

        LogError(RecVar,Result);

        RecRef.GetTable(RecVar);

        exit(Result);
    end;

    local procedure RunCustomProcessing()
    var
        Handled: Boolean;
    begin
        OnCustomProcessing(RecRefCustomerProcessing,Handled);
        IsCustomProcessingHandled := Handled;
    end;

    local procedure InitBatchID()
    begin
        if IsNullGuid(BatchID) then
          BatchID := CreateGuid;
    end;

    local procedure LogError(RecVar: Variant;RunResult: Boolean)
    begin
        if not RunResult then
          TempErrorMessage.LogMessage(RecVar,0,TempErrorMessage."Message Type"::Error,GetLastErrorText);
    end;

    local procedure ProcessRecord(var RecRef: RecordRef;var BatchConfirm: Option): Boolean
    var
        ProcessingResult: Boolean;
    begin
        OnBeforeBatchProcessing(RecRef,BatchConfirm);

        ProcessingResult := InvokeProcessing(RecRef);

        OnAfterBatchProcessing(RecRef,ProcessingResult);

        exit(ProcessingResult);
    end;

    procedure ResetBatchID()
    var
        BatchProcessingParameter: Record "Batch Processing Parameter";
        BatchProcessingParameterMap: Record "Batch Processing Parameter Map";
    begin
        BatchProcessingParameter.SetRange("Batch ID",BatchID);
        BatchProcessingParameter.DeleteAll;

        BatchProcessingParameterMap.SetRange("Batch ID",BatchID);
        BatchProcessingParameterMap.DeleteAll;

        Clear(BatchID);

        Commit;
    end;

    procedure AddParameter(ParameterId: Integer;Value: Variant)
    var
        BatchProcessingParameter: Record "Batch Processing Parameter";
    begin
        InitBatchID;

        BatchProcessingParameter.Init;
        BatchProcessingParameter."Batch ID" := BatchID;
        BatchProcessingParameter."Parameter Id" := ParameterId;
        BatchProcessingParameter."Parameter Value" := Format(Value);
        BatchProcessingParameter.Insert;
    end;

    procedure GetParameterText(RecordID: RecordID;ParameterId: Integer;var ParameterValue: Text[250]): Boolean
    var
        BatchProcessingParameter: Record "Batch Processing Parameter";
        BatchProcessingParameterMap: Record "Batch Processing Parameter Map";
    begin
        BatchProcessingParameterMap.SetRange("Record ID",RecordID);
        if not BatchProcessingParameterMap.FindFirst then
          exit(false);

        if not BatchProcessingParameter.Get(BatchProcessingParameterMap."Batch ID",ParameterId) then
          exit(false);

        ParameterValue := BatchProcessingParameter."Parameter Value";
        exit(true);
    end;

    [Scope('Personalization')]
    procedure GetParameterBoolean(RecordID: RecordID;ParameterId: Integer;var ParameterValue: Boolean): Boolean
    var
        Result: Boolean;
        Value: Text[250];
    begin
        if not GetParameterText(RecordID,ParameterId,Value) then
          exit(false);

        if not Evaluate(Result,Value) then
          exit(false);

        ParameterValue := Result;
        exit(true);
    end;

    procedure GetParameterInteger(RecordID: RecordID;ParameterId: Integer;var ParameterValue: Integer): Boolean
    var
        Result: Integer;
        Value: Text[250];
    begin
        if not GetParameterText(RecordID,ParameterId,Value) then
          exit(false);

        if not Evaluate(Result,Value) then
          exit(false);

        ParameterValue := Result;
        exit(true);
    end;

    [Scope('Personalization')]
    procedure GetParameterDate(RecordID: RecordID;ParameterId: Integer;var ParameterValue: Date): Boolean
    var
        Result: Date;
        Value: Text[250];
    begin
        if not GetParameterText(RecordID,ParameterId,Value) then
          exit(false);

        if not Evaluate(Result,Value) then
          exit(false);

        ParameterValue := Result;
        exit(true);
    end;

    procedure GetIsCustomProcessingHandled(): Boolean
    begin
        exit(IsCustomProcessingHandled);
    end;

    procedure GetRecRefForCustomProcessing(var RecRef: RecordRef)
    begin
        RecRef := RecRefCustomerProcessing;
    end;

    procedure SetRecRefForCustomProcessing(RecRef: RecordRef)
    begin
        RecRefCustomerProcessing := RecRef;
    end;

    procedure SetProcessingCodeunit(NewProcessingCodeunitID: Integer)
    begin
        ProcessingCodeunitID := NewProcessingCodeunitID;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnVerifyRecord(var RecRef: RecordRef;var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeBatchProcessing(var RecRef: RecordRef;var BatchConfirm: Option)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterBatchProcess(var RecRef: RecordRef;var CounterPosted: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterBatchProcessing(var RecRef: RecordRef;PostingResult: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCustomProcessing(var RecRef: RecordRef;var Handled: Boolean)
    begin
    end;
}

