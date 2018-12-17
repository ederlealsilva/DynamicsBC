codeunit 1511 "Notification Lifecycle Mgt."
{
    // version NAVW113.00

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        TempNotificationContext: Record "Notification Context" temporary;
        NotificationSentCategoryTxt: Label 'AL Notification Sent', Comment='{LOCKED}';
        NotificationSentTelemetryMsg: Label 'A notification with ID %1 was sent for a record of table %2.', Comment='{LOCKED}';

    [Scope('Personalization')]
    procedure SendNotification(NotificationToSend: Notification;RecId: RecordID)
    begin
        if IsNullGuid(NotificationToSend.Id) then
          NotificationToSend.Id := CreateGuid;

        NotificationToSend.Send;
        OnAfterNotificationSent(NotificationToSend,RecId.TableNo);
        CreateNotificationContext(NotificationToSend.Id,RecId);
    end;

    [Scope('Personalization')]
    procedure SendNotificationWithAdditionalContext(NotificationToSend: Notification;RecId: RecordID;AdditionalContextId: Guid)
    begin
        if IsNullGuid(NotificationToSend.Id) then
          NotificationToSend.Id := CreateGuid;

        NotificationToSend.Send;
        OnAfterNotificationSent(NotificationToSend,RecId.TableNo);
        CreateNotificationContextWithAdditionalContext(NotificationToSend.Id,RecId,AdditionalContextId);
    end;

    [Scope('Personalization')]
    procedure RecallNotificationsForRecord(RecId: RecordID;HandleDelayedInsert: Boolean)
    var
        TempNotificationContextToRecall: Record "Notification Context" temporary;
    begin
        if GetNotificationsForRecord(RecId,TempNotificationContextToRecall,HandleDelayedInsert) then
          RecallNotifications(TempNotificationContextToRecall);
    end;

    [Scope('Personalization')]
    procedure RecallNotificationsForRecordWithAdditionalContext(RecId: RecordID;AdditionalContextId: Guid;HandleDelayedInsert: Boolean)
    var
        TempNotificationContextToRecall: Record "Notification Context" temporary;
    begin
        if GetNotificationsForRecordWithAdditionalContext(RecId,AdditionalContextId,TempNotificationContextToRecall,HandleDelayedInsert) then
          RecallNotifications(TempNotificationContextToRecall);
    end;

    [Scope('Personalization')]
    procedure RecallAllNotifications()
    begin
        TempNotificationContext.Reset;
        if TempNotificationContext.FindFirst then
          RecallNotifications(TempNotificationContext);
    end;

    [Scope('Personalization')]
    procedure GetTmpNotificationContext(var TempNotificationContextOut: Record "Notification Context" temporary)
    begin
        TempNotificationContext.Reset;
        TempNotificationContextOut.Copy(TempNotificationContext,true);
    end;

    [Scope('Personalization')]
    procedure SetRecordID(RecId: RecordID)
    var
        RecRef: RecordRef;
    begin
        RecRef.Open(RecId.TableNo);
        UpdateRecordIDHandleDelayedInsert(RecRef.RecordId,RecId,false);
    end;

    [TryFunction]
    local procedure TryFctThrowsErrorIfRecordExists(RecId: RecordID;var Exists: Boolean)
    var
        RecRef: RecordRef;
    begin
        // If record exists, in some cases RecRef.GET(RecId) throws an error
        Exists := RecRef.Get(RecId);
    end;

    local procedure UpdateRecordIDHandleDelayedInsert(CurrentRecId: RecordID;NewRecId: RecordID;HandleDelayedInsert: Boolean)
    var
        TempNotificationContextToUpdate: Record "Notification Context" temporary;
        Exists: Boolean;
    begin
        if not TryFctThrowsErrorIfRecordExists(NewRecId,Exists) then
          Exists := true;

        if not Exists then
          exit;

        if GetNotificationsForRecord(CurrentRecId,TempNotificationContextToUpdate,HandleDelayedInsert) then
          repeat
            TempNotificationContextToUpdate."Record ID" := NewRecId;
            TempNotificationContextToUpdate.Modify(true);
          until TempNotificationContextToUpdate.Next = 0
    end;

    [Scope('Personalization')]
    procedure UpdateRecordID(CurrentRecId: RecordID;NewRecId: RecordID)
    begin
        UpdateRecordIDHandleDelayedInsert(CurrentRecId,NewRecId,true);
    end;

    [Scope('Personalization')]
    procedure GetNotificationsForRecord(RecId: RecordID;var TempNotificationContextOut: Record "Notification Context" temporary;HandleDelayedInsert: Boolean): Boolean
    begin
        TempNotificationContext.Reset;
        GetUsableRecordId(RecId,HandleDelayedInsert);
        TempNotificationContext.SetRange("Record ID",RecId);
        TempNotificationContextOut.Copy(TempNotificationContext,true);
        exit(TempNotificationContextOut.FindSet);
    end;

    [Scope('Personalization')]
    procedure GetNotificationsForRecordWithAdditionalContext(RecId: RecordID;AdditionalContextId: Guid;var TempNotificationContextOut: Record "Notification Context" temporary;HandleDelayedInsert: Boolean): Boolean
    begin
        TempNotificationContext.Reset;
        GetUsableRecordId(RecId,HandleDelayedInsert);
        TempNotificationContext.SetRange("Record ID",RecId);
        TempNotificationContext.SetRange("Additional Context ID",AdditionalContextId);
        TempNotificationContextOut.Copy(TempNotificationContext,true);
        exit(TempNotificationContextOut.FindSet);
    end;

    local procedure CreateNotificationContext(NotificationId: Guid;RecId: RecordID)
    begin
        DeleteAlreadyRegisteredNotificationBeforeInsert(NotificationId);
        TempNotificationContext.Init;
        TempNotificationContext."Notification ID" := NotificationId;
        GetUsableRecordId(RecId,true);
        TempNotificationContext."Record ID" := RecId;
        TempNotificationContext.Insert(true);
    end;

    local procedure CreateNotificationContextWithAdditionalContext(NotificationId: Guid;RecId: RecordID;AdditionalContextId: Guid)
    begin
        DeleteAlreadyRegisteredNotificationBeforeInsert(NotificationId);
        TempNotificationContext.Init;
        TempNotificationContext."Notification ID" := NotificationId;
        GetUsableRecordId(RecId,true);
        TempNotificationContext."Record ID" := RecId;
        TempNotificationContext."Additional Context ID" := AdditionalContextId;
        TempNotificationContext.Insert(true);
    end;

    local procedure DeleteAlreadyRegisteredNotificationBeforeInsert(NotificationId: Guid)
    begin
        TempNotificationContext.Reset;
        TempNotificationContext.SetRange("Notification ID",NotificationId);
        if TempNotificationContext.FindFirst then
          TempNotificationContext.Delete(true);
    end;

    local procedure RecallNotifications(var TempNotificationContextToRecall: Record "Notification Context" temporary)
    var
        NotificationToRecall: Notification;
    begin
        repeat
          NotificationToRecall.Id := TempNotificationContextToRecall."Notification ID";
          NotificationToRecall.Recall;

          TempNotificationContextToRecall.Delete(true);
        until TempNotificationContextToRecall.Next = 0
    end;

    local procedure GetUsableRecordId(var RecId: RecordID;HandleDelayedInsert: Boolean)
    var
        RecRef: RecordRef;
    begin
        if not HandleDelayedInsert then
          exit;

        // Handle delayed insert
        if not RecRef.Get(RecId) then begin
          RecRef.Open(RecId.TableNo);
          RecId := RecRef.RecordId;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterNotificationSent(CurrentNotification: Notification;TableNo: Integer)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 1511, 'OnAfterNotificationSent', '', true, true)]
    local procedure LogNotificationSentSubscriber(CurrentNotification: Notification;TableNo: Integer)
    begin
        SendTraceTag('00001KO',NotificationSentCategoryTxt,VERBOSITY::Normal,
          StrSubstNo(NotificationSentTelemetryMsg,CurrentNotification.Id,TableNo),DATACLASSIFICATION::SystemMetadata);
    end;
}

