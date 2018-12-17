codeunit 1373 "Batch Posting Print Mgt."
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 1380, 'OnAfterBatchProcessing', '', false, false)]
    local procedure PrintDocumentOnAfterBatchPosting(var RecRef: RecordRef;PostingResult: Boolean)
    var
        BatchPostParameterTypes: Codeunit "Batch Post Parameter Types";
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        Print: Boolean;
    begin
        if not PostingResult then
          exit;

        if not BatchProcessingMgt.GetParameterBoolean(RecRef.RecordId,BatchPostParameterTypes.Print,Print) or not Print then
          exit;

        PrintSalesDocument(RecRef);
        PrintPurchaseDocument(RecRef);
    end;

    local procedure PrintSalesDocument(RecRef: RecordRef)
    var
        SalesHeader: Record "Sales Header";
        ReportSelections: Record "Report Selections";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        if RecRef.Number <> DATABASE::"Sales Header" then
          exit;

        RecRef.SetTable(SalesHeader);

        with SalesHeader do
          case "Document Type" of
            "Document Type"::Order:
              begin
                if Ship then begin
                  SalesShipmentHeader."No." := "Last Shipping No.";
                  SalesShipmentHeader.SetRecFilter;
                  PrintDocument(ReportSelections.Usage::"S.Shipment",SalesShipmentHeader);
                end;
                if Invoice then begin
                  SalesInvoiceHeader."No." := "Last Posting No.";
                  SalesInvoiceHeader.SetRecFilter;
                  PrintDocument(ReportSelections.Usage::"S.Invoice",SalesInvoiceHeader);
                end;
              end;
            "Document Type"::Invoice:
              begin
                if "Last Posting No." = '' then
                  SalesInvoiceHeader."No." := "No."
                else
                  SalesInvoiceHeader."No." := "Last Posting No.";
                SalesInvoiceHeader.SetRecFilter;
                PrintDocument(ReportSelections.Usage::"S.Invoice",SalesInvoiceHeader);
              end;
            "Document Type"::"Credit Memo":
              begin
                if "Last Posting No." = '' then
                  SalesCrMemoHeader."No." := "No."
                else
                  SalesCrMemoHeader."No." := "Last Posting No.";
                SalesCrMemoHeader.SetRecFilter;
                PrintDocument(ReportSelections.Usage::"S.Cr.Memo",SalesCrMemoHeader);
              end;
          end;
    end;

    local procedure PrintPurchaseDocument(RecRef: RecordRef)
    var
        PurchaseHeader: Record "Purchase Header";
        ReportSelections: Record "Report Selections";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
    begin
        if RecRef.Number <> DATABASE::"Purchase Header" then
          exit;

        RecRef.SetTable(PurchaseHeader);

        with PurchaseHeader do
          case "Document Type" of
            "Document Type"::Order:
              begin
                if Receive then begin
                  PurchRcptHeader."No." := "Last Receiving No.";
                  PurchRcptHeader.SetRecFilter;
                  PrintDocument(ReportSelections.Usage::"P.Receipt",PurchRcptHeader);
                end;
                if Invoice then begin
                  PurchInvHeader."No." := "Last Posting No.";
                  PurchInvHeader.SetRecFilter;
                  PrintDocument(ReportSelections.Usage::"P.Invoice",PurchInvHeader);
                end;
              end;
            "Document Type"::Invoice:
              begin
                if "Last Posting No." = '' then
                  PurchInvHeader."No." := "No."
                else
                  PurchInvHeader."No." := "Last Posting No.";
                PurchInvHeader.SetRecFilter;
                PrintDocument(ReportSelections.Usage::"P.Invoice",PurchInvHeader);
              end;
            "Document Type"::"Credit Memo":
              begin
                if "Last Posting No." = '' then
                  PurchCrMemoHdr."No." := "No."
                else
                  PurchCrMemoHdr."No." := "Last Posting No.";
                PurchCrMemoHdr.SetRecFilter;
                PrintDocument(ReportSelections.Usage::"P.Cr.Memo",PurchCrMemoHdr);
              end;
          end;
    end;

    local procedure PrintDocument(ReportUsage: Option;RecVar: Variant)
    var
        ReportSelections: Record "Report Selections";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePrintDocument(ReportUsage,RecVar,IsHandled);
        if IsHandled then
          exit;

        ReportSelections.Reset;
        ReportSelections.SetRange(Usage,ReportUsage);
        ReportSelections.FindSet;
        repeat
          ReportSelections.TestField("Report ID");
          REPORT.Run(ReportSelections."Report ID",false,false,RecVar);
        until ReportSelections.Next = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintDocument(ReportUsage: Option;RecVar: Variant;var IsHandled: Boolean)
    begin
    end;
}

