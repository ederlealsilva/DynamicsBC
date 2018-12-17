codeunit 484 "Change Global Dim. Log Mgt."
{
    // version NAVW113.00

    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
    end;

    var
        TempChangeGlobalDimLogEntry: Record "Change Global Dim. Log Entry" temporary;

    [Scope('Personalization')]
    procedure AreAllCompleted(): Boolean
    begin
        TempChangeGlobalDimLogEntry.Reset;
        TempChangeGlobalDimLogEntry.SetFilter(Status,'<>%1',TempChangeGlobalDimLogEntry.Status::Completed);
        exit(TempChangeGlobalDimLogEntry.IsEmpty);
    end;

    [Scope('Personalization')]
    procedure ClearBuffer()
    begin
        TempChangeGlobalDimLogEntry.Reset;
        TempChangeGlobalDimLogEntry.DeleteAll;
    end;

    [Scope('Personalization')]
    procedure IsBufferClear(): Boolean
    begin
        TempChangeGlobalDimLogEntry.Reset;
        exit(TempChangeGlobalDimLogEntry.IsEmpty);
    end;

    [Scope('Personalization')]
    procedure IsStarted(): Boolean
    begin
        TempChangeGlobalDimLogEntry.Reset;
        TempChangeGlobalDimLogEntry.SetFilter(Status,'<>%1',TempChangeGlobalDimLogEntry.Status::" ");
        exit(not TempChangeGlobalDimLogEntry.IsEmpty);
    end;

    [Scope('Personalization')]
    procedure ExcludeTable(TableId: Integer)
    begin
        if TempChangeGlobalDimLogEntry.Get(TableId) then
          TempChangeGlobalDimLogEntry.Delete;
        if AreAllCompleted then
          ClearBuffer;
    end;

    [Scope('Personalization')]
    procedure FindChildTable(ParentTableID: Integer): Integer
    var
        TempChildChangeGlobalDimLogEntry: Record "Change Global Dim. Log Entry" temporary;
    begin
        TempChildChangeGlobalDimLogEntry.Copy(TempChangeGlobalDimLogEntry,true);
        TempChildChangeGlobalDimLogEntry.SetRange("Parent Table ID",ParentTableID);
        if TempChildChangeGlobalDimLogEntry.FindFirst then
          exit(TempChildChangeGlobalDimLogEntry."Table ID");
    end;

    [Scope('Personalization')]
    procedure FillBuffer(): Boolean
    var
        ChangeGlobalDimLogEntry: Record "Change Global Dim. Log Entry";
    begin
        ClearBuffer;
        if ChangeGlobalDimLogEntry.IsEmpty then
          exit(false);
        ChangeGlobalDimLogEntry.FindSet;
        repeat
          TempChangeGlobalDimLogEntry := ChangeGlobalDimLogEntry;
          TempChangeGlobalDimLogEntry.Insert;
        until ChangeGlobalDimLogEntry.Next = 0;
        TempChangeGlobalDimLogEntry.SetRange("Total Records",0);
        TempChangeGlobalDimLogEntry.DeleteAll;
        exit(not IsBufferClear);
    end;

    [EventSubscriber(ObjectType::Codeunit, 5150, 'OnGetIntegrationDisabled', '', false, false)]
    local procedure OnGetIntegrationDisabledHandler(var IsSyncDisabled: Boolean)
    begin
        IsSyncDisabled := true
    end;
}

