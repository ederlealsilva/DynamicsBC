codeunit 19 "Gen. Jnl.-Post Preview"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        NothingToPostMsg: Label 'There is nothing to post.';
        PreviewModeErr: Label 'Preview mode.';
        PostingPreviewEventHandler: Codeunit "Posting Preview Event Handler";
        SubscriberTypeErr: Label 'Invalid Subscriber type. The type must be CODEUNIT.';
        RecVarTypeErr: Label 'Invalid RecVar type. The type must be RECORD.';
        PreviewExitStateErr: Label 'The posting preview has stopped because of a state that is not valid.';

    [Scope('Personalization')]
    procedure Preview(Subscriber: Variant;RecVar: Variant)
    var
        RunResult: Boolean;
    begin
        if not Subscriber.IsCodeunit then
          Error(SubscriberTypeErr);
        if not RecVar.IsRecord then
          Error(RecVarTypeErr);

        BindSubscription(PostingPreviewEventHandler);
        OnAfterBindSubscription;

        RunResult := RunPreview(Subscriber,RecVar);

        UnbindSubscription(PostingPreviewEventHandler);
        OnAfterUnbindSubscription;

        // The OnRunPreview event expects subscriber following template: Result := <Codeunit>.RUN
        // So we assume RunPreview returns FALSE with the error.
        // To prevent return FALSE without thrown error we check error call stack.
        if RunResult or (GetLastErrorCallstack = '') then
          Error(PreviewExitStateErr);

        if GetLastErrorText <> PreviewModeErr then
          Error(GetLastErrorText);
        ShowAllEntries;
        Error('');
    end;

    [Scope('Personalization')]
    procedure IsActive(): Boolean
    var
        EventSubscription: Record "Event Subscription";
        Result: Boolean;
    begin
        EventSubscription.SetRange("Subscriber Codeunit ID",CODEUNIT::"Posting Preview Event Handler");
        EventSubscription.SetFilter("Active Manual Instances",'<>%1',0);
        Result := not EventSubscription.IsEmpty;

        Clear(EventSubscription);
        EventSubscription.SetRange("Publisher Object ID",CODEUNIT::"Gen. Jnl.-Post Preview");
        EventSubscription.SetFilter("Active Manual Instances",'<>%1',0);
        Result := Result and (not EventSubscription.IsEmpty);
        OnAfterIsActive(Result);
        exit(Result);
    end;

    local procedure RunPreview(Subscriber: Variant;RecVar: Variant): Boolean
    var
        Result: Boolean;
    begin
        OnRunPreview(Result,Subscriber,RecVar);
        exit(Result);
    end;

    local procedure ShowAllEntries()
    var
        TempDocumentEntry: Record "Document Entry" temporary;
        GLPostingPreview: Page "G/L Posting Preview";
    begin
        PostingPreviewEventHandler.FillDocumentEntry(TempDocumentEntry);
        if not TempDocumentEntry.IsEmpty then begin
          GLPostingPreview.Set(TempDocumentEntry,PostingPreviewEventHandler);
          GLPostingPreview.Run
        end else
          Message(NothingToPostMsg);
    end;

    procedure ShowDimensions(TableID: Integer;EntryNo: Integer;DimensionSetID: Integer)
    var
        DimMgt: Codeunit DimensionManagement;
        RecRef: RecordRef;
    begin
        RecRef.Open(TableID);
        DimMgt.ShowDimensionSet(DimensionSetID,StrSubstNo('%1 %2',RecRef.Caption,EntryNo));
    end;

    [Scope('Personalization')]
    procedure ThrowError()
    begin
        OnBeforeThrowError;
        Error(PreviewModeErr);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunPreview(var Result: Boolean;Subscriber: Variant;RecVar: Variant)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterBindSubscription()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUnbindSubscription()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIsActive(var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeThrowError()
    begin
    end;
}

