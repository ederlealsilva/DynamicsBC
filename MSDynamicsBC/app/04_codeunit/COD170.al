codeunit 170 "Standard Codes Mgt."
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        GetRecurringLinesTxt: Label 'Get Recurring Lines.';
        GetSalesRecurringLinesQst: Label 'Recurring sales lines exist for customer %1. Do you want to insert them on this document?', Comment='%1 - customer number';
        GetPurchRecurringLinesQst: Label 'Recurring purchase lines exist for vendor %1. Do you want to insert them on this document?', Comment='%1 - vendor number';

    procedure GetSalesRecurringLines(SalesHeader: Record "Sales Header")
    var
        StandardCustomerSalesCode: Record "Standard Customer Sales Code";
    begin
        StandardCustomerSalesCode.SetFilterByAutomaticAndAlwaysAskCodes(SalesHeader);
        StandardCustomerSalesCode.SetRange("Customer No.",SalesHeader."Sell-to Customer No.");
        StandardCustomerSalesCode.FindFirst;
        if (StandardCustomerSalesCode.Count = 1) and
           StandardCustomerSalesCode.IsInsertRecurringLinesOnDocumentAutomatic(SalesHeader)
        then
          StandardCustomerSalesCode.ApplyStdCodesToSalesLines(SalesHeader,StandardCustomerSalesCode)
        else
          StandardCustomerSalesCode.InsertSalesLines(SalesHeader);
    end;

    procedure GetPurchRecurringLines(PurchHeader: Record "Purchase Header")
    var
        StandardVendorPurchaseCode: Record "Standard Vendor Purchase Code";
    begin
        StandardVendorPurchaseCode.SetFilterByAutomaticAndAlwaysAskCodes(PurchHeader);
        StandardVendorPurchaseCode.SetRange("Vendor No.",PurchHeader."Buy-from Vendor No.");
        StandardVendorPurchaseCode.FindFirst;
        if (StandardVendorPurchaseCode.Count = 1) and
           StandardVendorPurchaseCode.IsInsertRecurringLinesOnDocumentAutomatic(PurchHeader)
        then
          StandardVendorPurchaseCode.ApplyStdCodesToPurchaseLines(PurchHeader,StandardVendorPurchaseCode)
        else
          StandardVendorPurchaseCode.InsertPurchLines(PurchHeader);
    end;

    local procedure IsSalesDocumentEmpty(SalesHeader: Record "Sales Header"): Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type",SalesHeader."Document Type");
        SalesLine.SetRange("Document No.",SalesHeader."No.");
        exit(SalesLine.IsEmpty);
    end;

    local procedure IsPurchDocumentEmpty(PurchaseHeader: Record "Purchase Header"): Boolean
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange("Document Type",PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.",PurchaseHeader."No.");
        exit(PurchaseLine.IsEmpty);
    end;

    procedure CheckShowSalesRecurringLinesNotification(var SalesHeader: Record "Sales Header")
    begin
        if CanGetSalesRecurringLines(SalesHeader) then
          ShowGetSalesRecurringLinesNotification(SalesHeader);
    end;

    procedure CheckShowPurchRecurringLinesNotification(var PurchaseHeader: Record "Purchase Header")
    begin
        if CanGetPurchRecurringLines(PurchaseHeader) then
          ShowGetPurchRecurringLinesNotification(PurchaseHeader);
    end;

    procedure ShowGetSalesRecurringLinesNotification(SalesHeader: Record "Sales Header")
    var
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        StandardCodesExistNotification: Notification;
    begin
        StandardCodesExistNotification.Id := GetSalesRecurringLinesNotificationId;
        StandardCodesExistNotification.Message := StrSubstNo(GetSalesRecurringLinesQst,SalesHeader."Sell-to Customer No.");
        StandardCodesExistNotification.AddAction(
          GetRecurringLinesTxt,CODEUNIT::"Standard Codes Mgt.",'GetSalesRecurringLinesFromNotification');
        StandardCodesExistNotification.Scope := NOTIFICATIONSCOPE::LocalScope;
        StandardCodesExistNotification.SetData(SalesHeader.FieldName("Document Type"),Format(SalesHeader."Document Type"));
        StandardCodesExistNotification.SetData(SalesHeader.FieldName("No."),SalesHeader."No.");
        NotificationLifecycleMgt.SendNotificationWithAdditionalContext(
          StandardCodesExistNotification,SalesHeader.RecordId,GetSalesRecurringLinesNotificationId);
    end;

    procedure ShowGetPurchRecurringLinesNotification(PurchHeader: Record "Purchase Header")
    var
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        StandardCodesExistNotification: Notification;
    begin
        StandardCodesExistNotification.Id := GetPurchRecurringLinesNotificationId;
        StandardCodesExistNotification.Message := StrSubstNo(GetPurchRecurringLinesQst,PurchHeader."Buy-from Vendor No.");
        StandardCodesExistNotification.AddAction(
          GetRecurringLinesTxt,CODEUNIT::"Standard Codes Mgt.",'GetPurchRecurringLinesFromNotification');
        StandardCodesExistNotification.Scope := NOTIFICATIONSCOPE::LocalScope;
        StandardCodesExistNotification.SetData(PurchHeader.FieldName("Document Type"),Format(PurchHeader."Document Type"));
        StandardCodesExistNotification.SetData(PurchHeader.FieldName("No."),PurchHeader."No.");
        NotificationLifecycleMgt.SendNotificationWithAdditionalContext(
          StandardCodesExistNotification,PurchHeader.RecordId,GetPurchRecurringLinesNotificationId);
    end;

    procedure GetSalesRecurringLinesNotificationId(): Guid
    begin
        exit('5FBC61D4-9344-4BA4-A977-5C0E3A8E3BB9');
    end;

    procedure GetPurchRecurringLinesNotificationId(): Guid
    begin
        exit('4C35449A-FA4C-4BA2-9982-3F9D08529052');
    end;

    procedure GetSalesRecurringLinesFromNotification(Notification: Notification)
    var
        SalesHeader: Record "Sales Header";
    begin
        if not (Notification.HasData(SalesHeader.FieldName("Document Type")) and
                Notification.HasData(SalesHeader.FieldName("No.")))
        then
          exit;

        Evaluate(SalesHeader."Document Type",Notification.GetData(SalesHeader.FieldName("Document Type")));
        SalesHeader.Get(
          SalesHeader."Document Type",
          Notification.GetData(SalesHeader.FieldName("No.")));
        GetSalesRecurringLines(SalesHeader);
    end;

    procedure GetPurchRecurringLinesFromNotification(Notification: Notification)
    var
        PurchHeader: Record "Purchase Header";
    begin
        if not (Notification.HasData(PurchHeader.FieldName("Document Type")) and
                Notification.HasData(PurchHeader.FieldName("No.")))
        then
          exit;

        Evaluate(PurchHeader."Document Type",Notification.GetData(PurchHeader.FieldName("Document Type")));
        PurchHeader.Get(
          PurchHeader."Document Type",
          Notification.GetData(PurchHeader.FieldName("No.")));
        GetPurchRecurringLines(PurchHeader);
    end;

    local procedure CanGetSalesRecurringLines(var SalesHeader: Record "Sales Header"): Boolean
    var
        StandardCustomerSalesCode: Record "Standard Customer Sales Code";
    begin
        if SalesHeader.IsTemporary then
          exit(false);

        if SalesHeader."Sell-to Customer No." = '' then
          exit(false);

        if not IsSalesDocumentEmpty(SalesHeader) then
          exit(false);

        StandardCustomerSalesCode.SetFilterByAutomaticAndAlwaysAskCodes(SalesHeader);
        StandardCustomerSalesCode.SetRange("Customer No.",SalesHeader."Sell-to Customer No.");
        exit(not StandardCustomerSalesCode.IsEmpty);
    end;

    local procedure CanGetPurchRecurringLines(var PurchHeader: Record "Purchase Header"): Boolean
    var
        StandardVendorPurchaseCode: Record "Standard Vendor Purchase Code";
    begin
        if PurchHeader.IsTemporary then
          exit(false);

        if PurchHeader."Buy-from Vendor No." = '' then
          exit(false);

        if not IsPurchDocumentEmpty(PurchHeader) then
          exit(false);

        StandardVendorPurchaseCode.SetFilterByAutomaticAndAlwaysAskCodes(PurchHeader);
        StandardVendorPurchaseCode.SetRange("Vendor No.",PurchHeader."Buy-from Vendor No.");
        exit(not StandardVendorPurchaseCode.IsEmpty);
    end;
}

