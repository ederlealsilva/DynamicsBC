codeunit 1508 "Notification Lifecycle Handler"
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    var
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterSalesLineInsertSetRecId(var Rec: Record "Sales Line";RunTrigger: Boolean)
    begin
        NotificationLifecycleMgt.SetRecordID(Rec.RecordId);
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterRenameEvent', '', false, false)]
    local procedure OnAfterSalesLineRenameUpdateRecId(var Rec: Record "Sales Line";var xRec: Record "Sales Line";RunTrigger: Boolean)
    begin
        NotificationLifecycleMgt.UpdateRecordID(xRec.RecordId,Rec.RecordId);
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterSalesLineDeleteRecall(var Rec: Record "Sales Line";RunTrigger: Boolean)
    begin
        NotificationLifecycleMgt.RecallNotificationsForRecord(Rec.RecordId,false);
    end;

    [EventSubscriber(ObjectType::Table, 83, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterItemJournalInsertSetRecId(var Rec: Record "Item Journal Line";RunTrigger: Boolean)
    begin
        NotificationLifecycleMgt.SetRecordID(Rec.RecordId);
    end;

    [EventSubscriber(ObjectType::Table, 83, 'OnAfterRenameEvent', '', false, false)]
    local procedure OnAfterItemJournalRenameUpdateRecId(var Rec: Record "Item Journal Line";var xRec: Record "Item Journal Line";RunTrigger: Boolean)
    begin
        NotificationLifecycleMgt.UpdateRecordID(xRec.RecordId,Rec.RecordId);
    end;

    [EventSubscriber(ObjectType::Table, 83, 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterItemJournalDeleteRecall(var Rec: Record "Item Journal Line";RunTrigger: Boolean)
    begin
        NotificationLifecycleMgt.RecallNotificationsForRecord(Rec.RecordId,false);
    end;

    [EventSubscriber(ObjectType::Table, 5741, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterTransferLineInsertSetRecId(var Rec: Record "Transfer Line";RunTrigger: Boolean)
    begin
        NotificationLifecycleMgt.SetRecordID(Rec.RecordId);
    end;

    [EventSubscriber(ObjectType::Table, 5741, 'OnAfterRenameEvent', '', false, false)]
    local procedure OnAfterTransferLineRenameUpdateRecId(var Rec: Record "Transfer Line";var xRec: Record "Transfer Line";RunTrigger: Boolean)
    begin
        NotificationLifecycleMgt.UpdateRecordID(xRec.RecordId,Rec.RecordId);
    end;

    [EventSubscriber(ObjectType::Table, 5741, 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterTransferLineDeleteRecall(var Rec: Record "Transfer Line";RunTrigger: Boolean)
    begin
        NotificationLifecycleMgt.RecallNotificationsForRecord(Rec.RecordId,false);
    end;

    [EventSubscriber(ObjectType::Table, 5902, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterServiceLineInsertSetRecId(var Rec: Record "Service Line";RunTrigger: Boolean)
    begin
        NotificationLifecycleMgt.SetRecordID(Rec.RecordId);
    end;

    [EventSubscriber(ObjectType::Table, 5902, 'OnAfterRenameEvent', '', false, false)]
    local procedure OnAfterServiceLineRenameUpdateRecId(var Rec: Record "Service Line";var xRec: Record "Service Line";RunTrigger: Boolean)
    begin
        NotificationLifecycleMgt.UpdateRecordID(xRec.RecordId,Rec.RecordId);
    end;

    [EventSubscriber(ObjectType::Table, 5902, 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterServiceLineDeleteRecall(var Rec: Record "Service Line";RunTrigger: Boolean)
    begin
        NotificationLifecycleMgt.RecallNotificationsForRecord(Rec.RecordId,false);
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterJobPlanningLineInsertSetRecId(var Rec: Record "Job Planning Line";RunTrigger: Boolean)
    begin
        NotificationLifecycleMgt.SetRecordID(Rec.RecordId);
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterRenameEvent', '', false, false)]
    local procedure OnAfterJobPlanningLineRenameUpdateRecId(var Rec: Record "Job Planning Line";var xRec: Record "Job Planning Line";RunTrigger: Boolean)
    begin
        NotificationLifecycleMgt.UpdateRecordID(xRec.RecordId,Rec.RecordId);
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterJobPlanningLineDeleteRecall(var Rec: Record "Job Planning Line";RunTrigger: Boolean)
    begin
        NotificationLifecycleMgt.RecallNotificationsForRecord(Rec.RecordId,false);
    end;

    [EventSubscriber(ObjectType::Table, 901, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterAssemblyLineInsertSetRecId(var Rec: Record "Assembly Line";RunTrigger: Boolean)
    begin
        NotificationLifecycleMgt.SetRecordID(Rec.RecordId);
    end;

    [EventSubscriber(ObjectType::Table, 901, 'OnAfterRenameEvent', '', false, false)]
    local procedure OnAfterAssemblyLineRenameUpdateRecId(var Rec: Record "Assembly Line";var xRec: Record "Assembly Line";RunTrigger: Boolean)
    begin
        NotificationLifecycleMgt.UpdateRecordID(xRec.RecordId,Rec.RecordId);
    end;

    [EventSubscriber(ObjectType::Table, 901, 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterAssemblyLineDeleteRecall(var Rec: Record "Assembly Line";RunTrigger: Boolean)
    begin
        NotificationLifecycleMgt.RecallNotificationsForRecord(Rec.RecordId,false);
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterSalesHeaderInsertSetRecId(var Rec: Record "Sales Header";RunTrigger: Boolean)
    begin
        NotificationLifecycleMgt.SetRecordID(Rec.RecordId);
    end;

    [EventSubscriber(ObjectType::Table, 81, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterGenJnlLineInsertSetRecId(var Rec: Record "Gen. Journal Line";RunTrigger: Boolean)
    begin
        NotificationLifecycleMgt.SetRecordID(Rec.RecordId);
    end;

    [EventSubscriber(ObjectType::Table, 5965, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterServiceContractHeaderInsertSetRecId(var Rec: Record "Service Contract Header";RunTrigger: Boolean)
    begin
        NotificationLifecycleMgt.SetRecordID(Rec.RecordId);
    end;

    [EventSubscriber(ObjectType::Codeunit, 312, 'OnNewCheckRemoveCustomerNotifications', '', false, false)]
    local procedure OnCustCheckCrLimitCheckRecallNotifs(RecId: RecordID;RecallCreditOverdueNotif: Boolean)
    var
        CustCheckCrLimit: Codeunit "Cust-Check Cr. Limit";
    begin
        NotificationLifecycleMgt.RecallNotificationsForRecordWithAdditionalContext(
          RecId,CustCheckCrLimit.GetCreditLimitNotificationId,true);
        if RecallCreditOverdueNotif then
          NotificationLifecycleMgt.RecallNotificationsForRecordWithAdditionalContext(
            RecId,CustCheckCrLimit.GetOverdueBalanceNotificationId,true);
    end;

    [EventSubscriber(ObjectType::Table, 83, 'OnBeforeValidateEvent', 'Entry Type', false, false)]
    local procedure OnItemJournalLineUpdateEntryTypeRecallItemNotif(var Rec: Record "Item Journal Line";var xRec: Record "Item Journal Line";CurrFieldNo: Integer)
    var
        ItemCheckAvail: Codeunit "Item-Check Avail.";
    begin
        if  (Rec."Entry Type" <> Rec."Entry Type"::Sale) and
           (xRec."Entry Type" <> Rec."Entry Type") and (CurrFieldNo = Rec.FieldNo("Entry Type"))
        then
          NotificationLifecycleMgt.RecallNotificationsForRecordWithAdditionalContext(
            Rec.RecordId,ItemCheckAvail.GetItemAvailabilityNotificationId,true);
    end;

    [EventSubscriber(ObjectType::Table, 83, 'OnBeforeValidateEvent', 'Quantity', false, false)]
    local procedure OnItemJournalLineUpdateQtyTo0RecallItemNotif(var Rec: Record "Item Journal Line";var xRec: Record "Item Journal Line";CurrFieldNo: Integer)
    var
        ItemCheckAvail: Codeunit "Item-Check Avail.";
    begin
        if (Rec.Quantity = 0) and (xRec.Quantity <> Rec.Quantity) and (CurrFieldNo = Rec.FieldNo(Quantity)) then
          NotificationLifecycleMgt.RecallNotificationsForRecordWithAdditionalContext(
            Rec.RecordId,ItemCheckAvail.GetItemAvailabilityNotificationId,true);
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnBeforeValidateEvent', 'Type', false, false)]
    local procedure OnSalesLineUpdateTypeRecallItemNotif(var Rec: Record "Sales Line";var xRec: Record "Sales Line";CurrFieldNo: Integer)
    var
        ItemCheckAvail: Codeunit "Item-Check Avail.";
    begin
        if (Rec.Type <> Rec.Type::Item) and (xRec.Type <> Rec.Type) and (CurrFieldNo = Rec.FieldNo(Type)) then
          NotificationLifecycleMgt.RecallNotificationsForRecordWithAdditionalContext(
            Rec.RecordId,ItemCheckAvail.GetItemAvailabilityNotificationId,true);
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnBeforeValidateEvent', 'Quantity', false, false)]
    local procedure OnSalesLineUpdateQtyTo0RecallItemNotif(var Rec: Record "Sales Line";var xRec: Record "Sales Line";CurrFieldNo: Integer)
    var
        ItemCheckAvail: Codeunit "Item-Check Avail.";
    begin
        if (Rec.Quantity = 0) and (xRec.Quantity <> Rec.Quantity) and (CurrFieldNo = Rec.FieldNo(Quantity)) then
          NotificationLifecycleMgt.RecallNotificationsForRecordWithAdditionalContext(
            Rec.RecordId,ItemCheckAvail.GetItemAvailabilityNotificationId,true);
    end;

    [EventSubscriber(ObjectType::Table, 5741, 'OnBeforeValidateEvent', 'Quantity', false, false)]
    local procedure OnTransferLineUpdateQtyTo0RecallItemNotif(var Rec: Record "Transfer Line";var xRec: Record "Transfer Line";CurrFieldNo: Integer)
    var
        ItemCheckAvail: Codeunit "Item-Check Avail.";
    begin
        if (Rec.Quantity = 0) and (xRec.Quantity <> Rec.Quantity) and (CurrFieldNo = Rec.FieldNo(Quantity)) then
          NotificationLifecycleMgt.RecallNotificationsForRecordWithAdditionalContext(
            Rec.RecordId,ItemCheckAvail.GetItemAvailabilityNotificationId,true);
    end;

    [EventSubscriber(ObjectType::Table, 5902, 'OnBeforeValidateEvent', 'Type', false, false)]
    local procedure OnServiceLineUpdateTypeRecallItemNotif(var Rec: Record "Service Line";var xRec: Record "Service Line";CurrFieldNo: Integer)
    var
        ItemCheckAvail: Codeunit "Item-Check Avail.";
    begin
        if (Rec.Type <> Rec.Type::Item) and (xRec.Type <> Rec.Type) and (CurrFieldNo = Rec.FieldNo(Type)) then
          NotificationLifecycleMgt.RecallNotificationsForRecordWithAdditionalContext(
            Rec.RecordId,ItemCheckAvail.GetItemAvailabilityNotificationId,true);
    end;

    [EventSubscriber(ObjectType::Table, 5902, 'OnBeforeValidateEvent', 'Quantity', false, false)]
    local procedure OnServiceLineUpdateQtyTo0RecallItemNotif(var Rec: Record "Service Line";var xRec: Record "Service Line";CurrFieldNo: Integer)
    var
        ItemCheckAvail: Codeunit "Item-Check Avail.";
    begin
        if (Rec.Quantity = 0) and (xRec.Quantity <> Rec.Quantity) and (CurrFieldNo = Rec.FieldNo(Quantity)) then
          NotificationLifecycleMgt.RecallNotificationsForRecordWithAdditionalContext(
            Rec.RecordId,ItemCheckAvail.GetItemAvailabilityNotificationId,true);
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnBeforeValidateEvent', 'Type', false, false)]
    local procedure OnJobPlanningLineUpdateTypeRecallItemNotif(var Rec: Record "Job Planning Line";var xRec: Record "Job Planning Line";CurrFieldNo: Integer)
    var
        ItemCheckAvail: Codeunit "Item-Check Avail.";
    begin
        if (Rec.Type <> Rec.Type::Item) and (xRec.Type <> Rec.Type) and (CurrFieldNo = Rec.FieldNo(Type)) then
          NotificationLifecycleMgt.RecallNotificationsForRecordWithAdditionalContext(
            Rec.RecordId,ItemCheckAvail.GetItemAvailabilityNotificationId,true);
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnBeforeValidateEvent', 'Line Type', false, false)]
    local procedure OnJobPlanningLineUpdateLineTypeRecallItemNotif(var Rec: Record "Job Planning Line";var xRec: Record "Job Planning Line";CurrFieldNo: Integer)
    var
        ItemCheckAvail: Codeunit "Item-Check Avail.";
    begin
        if (Rec."Line Type" = Rec."Line Type"::Billable) and
           (xRec."Line Type" <> Rec."Line Type") and (CurrFieldNo = Rec.FieldNo("Line Type"))
        then
          NotificationLifecycleMgt.RecallNotificationsForRecordWithAdditionalContext(
            Rec.RecordId,ItemCheckAvail.GetItemAvailabilityNotificationId,true);
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnBeforeValidateEvent', 'Quantity', false, false)]
    local procedure OnJobPlanningLineUpdateQtyTo0RecallItemNotif(var Rec: Record "Job Planning Line";var xRec: Record "Job Planning Line";CurrFieldNo: Integer)
    var
        ItemCheckAvail: Codeunit "Item-Check Avail.";
    begin
        if (Rec.Quantity = 0) and (xRec.Quantity <> Rec.Quantity) and (CurrFieldNo = Rec.FieldNo(Quantity)) then
          NotificationLifecycleMgt.RecallNotificationsForRecordWithAdditionalContext(
            Rec.RecordId,ItemCheckAvail.GetItemAvailabilityNotificationId,true);
    end;

    [EventSubscriber(ObjectType::Table, 901, 'OnBeforeValidateEvent', 'Unit of Measure Code', false, false)]
    local procedure OnAssemblyLineUpdateUnitOfMeasureCodeRecallItemNotif(var Rec: Record "Assembly Line";var xRec: Record "Assembly Line";CurrFieldNo: Integer)
    var
        ItemCheckAvail: Codeunit "Item-Check Avail.";
    begin
        if (xRec."Unit of Measure Code" <> Rec."Unit of Measure Code") and (CurrFieldNo = Rec.FieldNo("Unit of Measure Code")) then
          NotificationLifecycleMgt.RecallNotificationsForRecordWithAdditionalContext(
            Rec.RecordId,ItemCheckAvail.GetItemAvailabilityNotificationId,true);
    end;

    [EventSubscriber(ObjectType::Table, 901, 'OnBeforeValidateEvent', 'Type', false, false)]
    local procedure OnAssemblyLineUpdateTypeRecallItemNotif(var Rec: Record "Assembly Line";var xRec: Record "Assembly Line";CurrFieldNo: Integer)
    var
        ItemCheckAvail: Codeunit "Item-Check Avail.";
    begin
        if (Rec.Type <> Rec.Type::Item) and (xRec.Type <> Rec.Type) and (CurrFieldNo = Rec.FieldNo(Type)) then
          NotificationLifecycleMgt.RecallNotificationsForRecordWithAdditionalContext(
            Rec.RecordId,ItemCheckAvail.GetItemAvailabilityNotificationId,true);
    end;

    [EventSubscriber(ObjectType::Table, 901, 'OnBeforeValidateEvent', 'Quantity per', false, false)]
    local procedure OnAssemblyLineUpdateQuantityRecallItemNotif(var Rec: Record "Assembly Line";var xRec: Record "Assembly Line";CurrFieldNo: Integer)
    var
        ItemCheckAvail: Codeunit "Item-Check Avail.";
    begin
        if (xRec."Quantity per" <> Rec."Quantity per") and (CurrFieldNo = Rec.FieldNo("Quantity per")) then
          NotificationLifecycleMgt.RecallNotificationsForRecordWithAdditionalContext(
            Rec.RecordId,ItemCheckAvail.GetItemAvailabilityNotificationId,true);
    end;
}

