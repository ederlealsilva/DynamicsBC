codeunit 1312 "Vendor Mgt."
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    [Scope('Personalization')]
    procedure CalcAmountsOnPostedInvoices(VendNo: Code[20];var RecCount: Integer): Decimal
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        exit(CalcAmountsOnPostedDocs(VendNo,RecCount,VendorLedgerEntry."Document Type"::Invoice));
    end;

    [Scope('Personalization')]
    procedure CalcAmountsOnPostedCrMemos(VendNo: Code[20];var RecCount: Integer): Decimal
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        exit(CalcAmountsOnPostedDocs(VendNo,RecCount,VendorLedgerEntry."Document Type"::"Credit Memo"));
    end;

    [Scope('Personalization')]
    procedure CalcAmountsOnPostedOrders(VendNo: Code[20];var RecCount: Integer): Decimal
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        exit(CalcAmountsOnPostedDocs(VendNo,RecCount,VendorLedgerEntry."Document Type"::" "));
    end;

    [Scope('Personalization')]
    procedure CalcAmountsOnUnpostedInvoices(VendNo: Code[20];var RecCount: Integer): Decimal
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        exit(CalcAmountsOnUnpostedDocs(VendNo,RecCount,VendorLedgerEntry."Document Type"::Invoice));
    end;

    [Scope('Personalization')]
    procedure CalcAmountsOnUnpostedCrMemos(VendNo: Code[20];var RecCount: Integer): Decimal
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        exit(CalcAmountsOnUnpostedDocs(VendNo,RecCount,VendorLedgerEntry."Document Type"::"Credit Memo"));
    end;

    [Scope('Personalization')]
    procedure DrillDownOnPostedInvoices(VendNo: Code[20])
    var
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        with PurchInvHeader do begin
          SetRange("Buy-from Vendor No.",VendNo);
          SetFilter("Posting Date",GetCurrentYearFilter);

          PAGE.Run(PAGE::"Posted Purchase Invoices",PurchInvHeader);
        end;
    end;

    [Scope('Personalization')]
    procedure DrillDownOnPostedCrMemo(VendNo: Code[20])
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
    begin
        with PurchCrMemoHdr do begin
          SetRange("Buy-from Vendor No.",VendNo);
          SetFilter("Posting Date",GetCurrentYearFilter);

          PAGE.Run(PAGE::"Posted Purchase Credit Memos",PurchCrMemoHdr);
        end;
    end;

    [Scope('Personalization')]
    procedure DrillDownOnPostedOrders(VendNo: Code[20])
    var
        PurchaseLine: Record "Purchase Line";
    begin
        with PurchaseLine do begin
          SetRange("Buy-from Vendor No.",VendNo);
          SetRange("Document Type","Document Type"::Order);
          SetFilter("Order Date",GetCurrentYearFilter);

          PAGE.Run(PAGE::"Purchase Orders",PurchaseLine);
        end;
    end;

    [Scope('Personalization')]
    procedure DrillDownOnOutstandingInvoices(VendNo: Code[20])
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        SetFilterForUnpostedLines(PurchaseLine,VendNo,PurchaseHeader."Document Type"::Invoice);
        PAGE.Run(PAGE::"Purchase Invoices",PurchaseHeader);
    end;

    [Scope('Personalization')]
    procedure DrillDownOnOutstandingCrMemos(VendNo: Code[20])
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        SetFilterForUnpostedLines(PurchaseLine,VendNo,PurchaseHeader."Document Type"::"Credit Memo");
        PAGE.Run(PAGE::"Purchase Credit Memos",PurchaseHeader);
    end;

    local procedure CalcAmountsOnPostedDocs(VendNo: Code[20];var RecCount: Integer;DocType: Integer): Decimal
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
    begin
        with VendLedgEntry do begin
          SetFilterForPostedDocs(VendLedgEntry,VendNo,DocType);
          RecCount := Count;
          CalcSums("Purchase (LCY)");
          exit("Purchase (LCY)");
        end;
    end;

    local procedure CalcAmountsOnUnpostedDocs(VendNo: Code[20];var RecCount: Integer;DocType: Integer): Decimal
    var
        PurchaseLine: Record "Purchase Line";
        Result: Decimal;
        VAT: Decimal;
        OutstandingAmount: Decimal;
        OldDocumentNo: Code[20];
    begin
        RecCount := 0;
        Result := 0;

        SetFilterForUnpostedLines(PurchaseLine,VendNo,DocType);
        with PurchaseLine do begin
          if FindSet then
            repeat
              case "Document Type" of
                "Document Type"::Invoice:
                  OutstandingAmount := "Outstanding Amount (LCY)";
                "Document Type"::"Credit Memo":
                  OutstandingAmount := -"Outstanding Amount (LCY)";
              end;
              VAT := 100 + "VAT %";
              Result += OutstandingAmount * 100 / VAT;

              if OldDocumentNo <> "Document No." then begin
                OldDocumentNo := "Document No.";
                RecCount += 1;
              end;
            until Next = 0;
        end;
        exit(Round(Result));
    end;

    local procedure SetFilterForUnpostedLines(var PurchaseLine: Record "Purchase Line";VendNo: Code[20];DocumentType: Integer)
    begin
        with PurchaseLine do begin
          SetRange("Buy-from Vendor No.",VendNo);

          if DocumentType = -1 then
            SetFilter("Document Type",'%1|%2',"Document Type"::Invoice,"Document Type"::"Credit Memo")
          else
            SetRange("Document Type",DocumentType);
        end;
    end;

    local procedure SetFilterForPostedDocs(var VendLedgEntry: Record "Vendor Ledger Entry";VendNo: Code[20];DocumentType: Integer)
    begin
        with VendLedgEntry do begin
          SetRange("Buy-from Vendor No.",VendNo);
          SetFilter("Posting Date",GetCurrentYearFilter);
          SetRange("Document Type",DocumentType);
        end;
    end;

    [Scope('Personalization')]
    procedure GetCurrentYearFilter(): Text[30]
    var
        DateFilterCalc: Codeunit "DateFilter-Calc";
        CustDateFilter: Text[30];
        CustDateName: Text[30];
    begin
        DateFilterCalc.CreateFiscalYearFilter(CustDateFilter,CustDateName,WorkDate,0);
        exit(CustDateFilter);
    end;
}

