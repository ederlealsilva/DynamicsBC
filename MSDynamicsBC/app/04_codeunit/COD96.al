codeunit 96 "Purch.-Quote to Order"
{
    // version NAVW113.00

    TableNo = "Purchase Header";

    trigger OnRun()
    var
        Vend: Record Vendor;
        PurchCommentLine: Record "Purch. Comment Line";
        PurchCalcDiscByType: Codeunit "Purch - Calc Disc. By Type";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        ArchiveManagement: Codeunit ArchiveManagement;
        RecordLinkManagement: Codeunit "Record Link Management";
        PurchLineReserve: Codeunit "Purch. Line-Reserve";
        ShouldRedistributeInvoiceAmount: Boolean;
    begin
        TestField("Document Type","Document Type"::Quote);
        ShouldRedistributeInvoiceAmount := PurchCalcDiscByType.ShouldRedistributeInvoiceDiscountAmount(Rec);

        OnCheckPurchasePostRestrictions;

        Vend.Get("Buy-from Vendor No.");
        Vend.CheckBlockedVendOnDocs(Vend,false);

        ValidatePurchaserOnPurchHeader(Rec,true,false);

        CreatePurchHeader(Rec,Vend."Prepayment %");

        PurchQuoteLine.SetRange("Document Type","Document Type");
        PurchQuoteLine.SetRange("Document No.","No.");
        if PurchQuoteLine.FindSet then
          repeat
            PurchOrderLine := PurchQuoteLine;
            PurchOrderLine."Document Type" := PurchOrderHeader."Document Type";
            PurchOrderLine."Document No." := PurchOrderHeader."No.";
            PurchLineReserve.TransferPurchLineToPurchLine(
              PurchQuoteLine,PurchOrderLine,PurchQuoteLine."Outstanding Qty. (Base)");
            PurchOrderLine."Shortcut Dimension 1 Code" := PurchQuoteLine."Shortcut Dimension 1 Code";
            PurchOrderLine."Shortcut Dimension 2 Code" := PurchQuoteLine."Shortcut Dimension 2 Code";
            PurchOrderLine."Dimension Set ID" := PurchQuoteLine."Dimension Set ID";
            if Vend."Prepayment %" <> 0 then
              PurchOrderLine."Prepayment %" := Vend."Prepayment %";
            PrepmtMgt.SetPurchPrepaymentPct(PurchOrderLine,PurchOrderHeader."Posting Date");
            PurchOrderLine.Validate("Prepayment %");
            PurchOrderLine.DefaultDeferralCode;
            OnBeforeInsertPurchOrderLine(PurchOrderLine,PurchOrderHeader,PurchQuoteLine,Rec);
            PurchOrderLine.Insert;
            OnAfterInsertPurchOrderLine(PurchQuoteLine,PurchOrderLine);

            PurchLineReserve.VerifyQuantity(PurchOrderLine,PurchQuoteLine);
          until PurchQuoteLine.Next = 0;

        OnAfterInsertAllPurchOrderLines(PurchOrderLine,Rec);

        PurchSetup.Get;
        case PurchSetup."Archive Quotes" of
          PurchSetup."Archive Quotes"::Always:
            ArchiveManagement.ArchPurchDocumentNoConfirm(Rec);
          PurchSetup."Archive Quotes"::Question:
            ArchiveManagement.ArchivePurchDocument(Rec);
        end;

        if PurchSetup."Default Posting Date" = PurchSetup."Default Posting Date"::"No Date" then begin
          PurchOrderHeader."Posting Date" := 0D;
          PurchOrderHeader.Modify;
        end;

        PurchCommentLine.CopyComments("Document Type",PurchOrderHeader."Document Type","No.",PurchOrderHeader."No.");
        RecordLinkManagement.CopyLinks(Rec,PurchOrderHeader);

        AssignItemCharges("Document Type","No.",PurchOrderHeader."Document Type",PurchOrderHeader."No.");

        ApprovalsMgmt.CopyApprovalEntryQuoteToOrder(RecordId,PurchOrderHeader."No.",PurchOrderHeader.RecordId);
        ApprovalsMgmt.DeleteApprovalEntries(RecordId);

        OnBeforeDeletePurchQuote(Rec,PurchOrderHeader);

        DeleteLinks;
        Delete;

        PurchQuoteLine.DeleteAll;

        if not ShouldRedistributeInvoiceAmount then
          PurchCalcDiscByType.ResetRecalculateInvoiceDisc(PurchOrderHeader);
    end;

    var
        PurchQuoteLine: Record "Purchase Line";
        PurchOrderHeader: Record "Purchase Header";
        PurchOrderLine: Record "Purchase Line";
        PurchSetup: Record "Purchases & Payables Setup";
        PrepmtMgt: Codeunit "Prepayment Mgt.";

    local procedure CreatePurchHeader(PurchHeader: Record "Purchase Header";PrepmtPercent: Decimal)
    begin
        with PurchHeader do begin
          PurchOrderHeader := PurchHeader;
          PurchOrderHeader."Document Type" := PurchOrderHeader."Document Type"::Order;
          PurchOrderHeader."No. Printed" := 0;
          PurchOrderHeader.Status := PurchOrderHeader.Status::Open;
          PurchOrderHeader."No." := '';
          PurchOrderHeader."Quote No." := "No.";
          PurchOrderHeader.InitRecord;

          PurchOrderLine.LockTable;
          PurchOrderHeader.Insert(true);

          PurchOrderHeader."Order Date" := "Order Date";
          if "Posting Date" <> 0D then
            PurchOrderHeader."Posting Date" := "Posting Date";

          PurchOrderHeader.InitFromPurchHeader(PurchHeader);
          PurchOrderHeader."Inbound Whse. Handling Time" := "Inbound Whse. Handling Time";

          PurchOrderHeader."Prepayment %" := PrepmtPercent;
          if PurchOrderHeader."Posting Date" = 0D then
            PurchOrderHeader."Posting Date" := WorkDate;
          OnBeforeInsertPurchOrderHeader(PurchOrderHeader,PurchHeader);
          PurchOrderHeader.Modify;
        end;
    end;

    local procedure AssignItemCharges(FromDocType: Option;FromDocNo: Code[20];ToDocType: Option;ToDocNo: Code[20])
    var
        ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)";
    begin
        ItemChargeAssgntPurch.Reset;
        ItemChargeAssgntPurch.SetRange("Document Type",FromDocType);
        ItemChargeAssgntPurch.SetRange("Document No.",FromDocNo);
        while ItemChargeAssgntPurch.FindFirst do begin
          ItemChargeAssgntPurch.Delete;
          ItemChargeAssgntPurch."Document Type" := PurchOrderHeader."Document Type";
          ItemChargeAssgntPurch."Document No." := PurchOrderHeader."No.";
          if not (ItemChargeAssgntPurch."Applies-to Doc. Type" in
                  [ItemChargeAssgntPurch."Applies-to Doc. Type"::Receipt,
                   ItemChargeAssgntPurch."Applies-to Doc. Type"::"Return Shipment"])
          then begin
            ItemChargeAssgntPurch."Applies-to Doc. Type" := ToDocType;
            ItemChargeAssgntPurch."Applies-to Doc. No." := ToDocNo;
          end;
          ItemChargeAssgntPurch.Insert;
        end;
    end;

    [Scope('Personalization')]
    procedure GetPurchOrderHeader(var PurchHeader: Record "Purchase Header")
    begin
        PurchHeader := PurchOrderHeader;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeletePurchQuote(var QuotePurchHeader: Record "Purchase Header";var OrderPurchHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPurchOrderHeader(var PurchOrderHeader: Record "Purchase Header";PurchQuoteHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPurchOrderLine(var PurchOrderLine: Record "Purchase Line";PurchOrderHeader: Record "Purchase Header";PurchQuoteLine: Record "Purchase Line";PurchQuoteHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPurchOrderLine(var PurchaseQuoteLine: Record "Purchase Line";var PurchaseOrderLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertAllPurchOrderLines(var PurchOrderLine: Record "Purchase Line";PurchQuoteHeader: Record "Purchase Header")
    begin
    end;
}

