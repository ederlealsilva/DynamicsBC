codeunit 57 "Document Totals"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        TotalVATLbl: Label 'Total VAT';
        TotalAmountInclVatLbl: Label 'Total Incl. VAT';
        TotalAmountExclVATLbl: Label 'Total Excl. VAT';
        InvoiceDiscountAmountLbl: Label 'Invoice Discount Amount';
        RefreshMsgTxt: Label 'Totals or discounts may not be up-to-date. Choose the link to update.';
        PreviousTotalSalesHeader: Record "Sales Header";
        PreviousTotalPurchaseHeader: Record "Purchase Header";
        ForceTotalsRecalculation: Boolean;
        PreviousTotalSalesVATDifference: Decimal;
        PreviousTotalPurchVATDifference: Decimal;
        TotalLineAmountLbl: Label 'Subtotal';

    [Scope('Personalization')]
    procedure CalculateSalesPageTotals(var TotalSalesLine: Record "Sales Line";var VATAmount: Decimal;var SalesLine: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
    begin
        if SalesHeader.Get(SalesLine."Document Type",SalesLine."Document No.") then
          CalculateTotalSalesLineAndVATAmount(SalesHeader,VATAmount,TotalSalesLine);
    end;

    [Scope('Personalization')]
    procedure CalculateSalesTotals(var TotalSalesLine: Record "Sales Line";var VATAmount: Decimal;var SalesLine: Record "Sales Line")
    begin
        CalculateSalesPageTotals(TotalSalesLine,VATAmount,SalesLine);
    end;

    [Scope('Personalization')]
    procedure CalculatePostedSalesInvoiceTotals(var SalesInvoiceHeader: Record "Sales Invoice Header";var VATAmount: Decimal;SalesInvoiceLine: Record "Sales Invoice Line")
    begin
        if SalesInvoiceHeader.Get(SalesInvoiceLine."Document No.") then begin
          SalesInvoiceHeader.CalcFields(Amount,"Amount Including VAT","Invoice Discount Amount");
          VATAmount := SalesInvoiceHeader."Amount Including VAT" - SalesInvoiceHeader.Amount;
        end;
    end;

    [Scope('Personalization')]
    procedure CalculatePostedSalesCreditMemoTotals(var SalesCrMemoHeader: Record "Sales Cr.Memo Header";var VATAmount: Decimal;SalesCrMemoLine: Record "Sales Cr.Memo Line")
    begin
        if SalesCrMemoHeader.Get(SalesCrMemoLine."Document No.") then begin
          SalesCrMemoHeader.CalcFields(Amount,"Amount Including VAT","Invoice Discount Amount");
          VATAmount := SalesCrMemoHeader."Amount Including VAT" - SalesCrMemoHeader.Amount;
        end;
    end;

    [Scope('Personalization')]
    procedure CalcTotalPurchAmountOnlyDiscountAllowed(PurchLine: Record "Purchase Line"): Decimal
    var
        TotalPurchLine: Record "Purchase Line";
    begin
        with TotalPurchLine do begin
          SetRange("Document Type",PurchLine."Document Type");
          SetRange("Document No.",PurchLine."Document No.");
          SetRange("Allow Invoice Disc.",true);
          CalcSums("Line Amount");
          exit("Line Amount");
        end;
    end;

    [Scope('Personalization')]
    procedure CalcTotalSalesAmountOnlyDiscountAllowed(SalesLine: Record "Sales Line"): Decimal
    var
        TotalSalesLine: Record "Sales Line";
    begin
        with TotalSalesLine do begin
          SetRange("Document Type",SalesLine."Document Type");
          SetRange("Document No.",SalesLine."Document No.");
          SetRange("Allow Invoice Disc.",true);
          CalcSums("Line Amount");
          exit("Line Amount");
        end;
    end;

    local procedure CalcTotalPurchVATDifference(PurchHeader: Record "Purchase Header"): Decimal
    var
        PurchLine: Record "Purchase Line";
    begin
        with PurchLine do begin
          SetRange("Document Type",PurchHeader."Document Type");
          SetRange("Document No.",PurchHeader."No.");
          CalcSums("VAT Difference");
          exit("VAT Difference");
        end;
    end;

    local procedure CalcTotalSalesVATDifference(SalesHeader: Record "Sales Header"): Decimal
    var
        SalesLine: Record "Sales Line";
    begin
        with SalesLine do begin
          SetRange("Document Type",SalesHeader."Document Type");
          SetRange("Document No.",SalesHeader."No.");
          CalcSums("VAT Difference");
          exit("VAT Difference");
        end;
    end;

    local procedure CalculateTotalSalesLineAndVATAmount(SalesHeader: Record "Sales Header";var VATAmount: Decimal;var TempTotalSalesLine: Record "Sales Line" temporary)
    var
        TempSalesLine: Record "Sales Line" temporary;
        TempTotalSalesLineLCY: Record "Sales Line" temporary;
        SalesPost: Codeunit "Sales-Post";
        VATAmountText: Text[30];
        ProfitLCY: Decimal;
        ProfitPct: Decimal;
        TotalAdjCostLCY: Decimal;
    begin
        SalesPost.GetSalesLines(SalesHeader,TempSalesLine,0);
        Clear(SalesPost);
        SalesPost.SumSalesLinesTemp(
          SalesHeader,TempSalesLine,0,TempTotalSalesLine,TempTotalSalesLineLCY,
          VATAmount,VATAmountText,ProfitLCY,ProfitPct,TotalAdjCostLCY);
    end;

    local procedure CalculateTotalPurchaseLineAndVATAmount(PurchaseHeader: Record "Purchase Header";var VATAmount: Decimal;var TempTotalPurchaseLine: Record "Purchase Line" temporary)
    var
        TempTotalPurchaseLineLCY: Record "Purchase Line" temporary;
        TempPurchaseLine: Record "Purchase Line" temporary;
        PurchPost: Codeunit "Purch.-Post";
        VATAmountText: Text[30];
    begin
        PurchPost.GetPurchLines(PurchaseHeader,TempPurchaseLine,0);
        Clear(PurchPost);

        PurchPost.SumPurchLinesTemp(
          PurchaseHeader,TempPurchaseLine,0,TempTotalPurchaseLine,TempTotalPurchaseLineLCY,VATAmount,VATAmountText);
    end;

    [Scope('Personalization')]
    procedure SalesUpdateTotalsControls(CurrentSalesLine: Record "Sales Line";var TotalSalesHeader: Record "Sales Header";var TotalsSalesLine: Record "Sales Line";var RefreshMessageEnabled: Boolean;var ControlStyle: Text;var RefreshMessageText: Text;var InvDiscAmountEditable: Boolean;CurrPageEditable: Boolean;var VATAmount: Decimal)
    var
        SalesLine: Record "Sales Line";
        SalesCalcDiscountByType: Codeunit "Sales - Calc Discount By Type";
    begin
        if CurrentSalesLine."Document No." = '' then
          exit;

        TotalSalesHeader.Get(CurrentSalesLine."Document Type",CurrentSalesLine."Document No.");
        RefreshMessageEnabled := SalesCalcDiscountByType.ShouldRedistributeInvoiceDiscountAmount(TotalSalesHeader);

        if not RefreshMessageEnabled then
          RefreshMessageEnabled := not SalesUpdateTotals(TotalSalesHeader,CurrentSalesLine,TotalsSalesLine,VATAmount);

        SalesLine.SetRange("Document Type",CurrentSalesLine."Document Type");
        SalesLine.SetRange("Document No.",CurrentSalesLine."Document No.");
        InvDiscAmountEditable := SalesLine.FindFirst and
          SalesCalcDiscountByType.InvoiceDiscIsAllowed(TotalSalesHeader."Invoice Disc. Code") and
          (not RefreshMessageEnabled) and CurrPageEditable;

        TotalControlsUpdateStyle(RefreshMessageEnabled,ControlStyle,RefreshMessageText);

        if RefreshMessageEnabled then
          ClearSalesAmounts(TotalsSalesLine,VATAmount);
    end;

    local procedure SalesUpdateTotals(var SalesHeader: Record "Sales Header";CurrentSalesLine: Record "Sales Line";var TotalsSalesLine: Record "Sales Line";var VATAmount: Decimal): Boolean
    begin
        SalesHeader.CalcFields(Amount,"Amount Including VAT","Invoice Discount Amount");

        if SalesHeader."No." <> PreviousTotalSalesHeader."No." then
          ForceTotalsRecalculation := true;

        if (not ForceTotalsRecalculation) and
           (PreviousTotalSalesHeader.Amount = SalesHeader.Amount) and
           (PreviousTotalSalesHeader."Amount Including VAT" = SalesHeader."Amount Including VAT") and
           (PreviousTotalSalesVATDifference = CalcTotalSalesVATDifference(SalesHeader))
        then
          exit(true);

        ForceTotalsRecalculation := false;

        if not SalesCheckNumberOfLinesLimit(SalesHeader) then
          exit(false);

        SalesCalculateTotalsWithInvoiceRounding(CurrentSalesLine,VATAmount,TotalsSalesLine);
        exit(true);
    end;

    local procedure SalesCalculateTotalsWithInvoiceRounding(var TempCurrentSalesLine: Record "Sales Line" temporary;var VATAmount: Decimal;var TempTotalSalesLine: Record "Sales Line" temporary)
    var
        SalesHeader: Record "Sales Header";
    begin
        Clear(TempTotalSalesLine);
        if SalesHeader.Get(TempCurrentSalesLine."Document Type",TempCurrentSalesLine."Document No.") then begin
          CalculateTotalSalesLineAndVATAmount(SalesHeader,VATAmount,TempTotalSalesLine);

          if PreviousTotalSalesHeader."No." <> TempCurrentSalesLine."Document No." then begin
            PreviousTotalSalesHeader.Get(TempCurrentSalesLine."Document Type",TempCurrentSalesLine."Document No.");
            ForceTotalsRecalculation := true;
          end;
          PreviousTotalSalesHeader.CalcFields(Amount,"Amount Including VAT");
          PreviousTotalSalesVATDifference := CalcTotalSalesVATDifference(PreviousTotalSalesHeader);
        end;
    end;

    [Scope('Personalization')]
    procedure SalesRedistributeInvoiceDiscountAmounts(var TempSalesLine: Record "Sales Line" temporary;var VATAmount: Decimal;var TempTotalSalesLine: Record "Sales Line" temporary)
    var
        SalesHeader: Record "Sales Header";
    begin
        with SalesHeader do
          if Get(TempSalesLine."Document Type",TempSalesLine."Document No.") then begin
            TestField(Status,Status::Open);
            CalcFields("Recalculate Invoice Disc.");
            if "Recalculate Invoice Disc." then
              CODEUNIT.Run(CODEUNIT::"Sales - Calc Discount By Type",TempSalesLine);

            SalesCalculateTotalsWithInvoiceRounding(TempSalesLine,VATAmount,TempTotalSalesLine);
          end;
    end;

    procedure PurchaseUpdateTotalsControls(CurrentPurchaseLine: Record "Purchase Line";var TotalPurchaseHeader: Record "Purchase Header";var TotalsPurchaseLine: Record "Purchase Line";var RefreshMessageEnabled: Boolean;var ControlStyle: Text;var RefreshMessageText: Text;var InvDiscAmountEditable: Boolean;var VATAmount: Decimal)
    begin
        PurchaseUpdateTotalsControlsForceable(
          CurrentPurchaseLine,TotalPurchaseHeader,TotalsPurchaseLine,RefreshMessageEnabled,ControlStyle,RefreshMessageText,
          InvDiscAmountEditable,VATAmount,false);
    end;

    procedure PurchaseUpdateTotalsControlsForceable(CurrentPurchaseLine: Record "Purchase Line";var TotalPurchaseHeader: Record "Purchase Header";var TotalsPurchaseLine: Record "Purchase Line";var RefreshMessageEnabled: Boolean;var ControlStyle: Text;var RefreshMessageText: Text;var InvDiscAmountEditable: Boolean;var VATAmount: Decimal;Force: Boolean)
    var
        PurchCalcDiscByType: Codeunit "Purch - Calc Disc. By Type";
    begin
        ClearPurchaseAmounts(TotalsPurchaseLine,VATAmount);

        if CurrentPurchaseLine."Document No." = '' then
          exit;

        TotalPurchaseHeader.Get(CurrentPurchaseLine."Document Type",CurrentPurchaseLine."Document No.");
        RefreshMessageEnabled := PurchCalcDiscByType.ShouldRedistributeInvoiceDiscountAmount(TotalPurchaseHeader);

        if not RefreshMessageEnabled then
          RefreshMessageEnabled := not PurchaseUpdateTotals(TotalPurchaseHeader,CurrentPurchaseLine,TotalsPurchaseLine,VATAmount,Force);

        InvDiscAmountEditable := PurchCalcDiscByType.InvoiceDiscIsAllowed(TotalPurchaseHeader."Invoice Disc. Code") and
          (not RefreshMessageEnabled);
        TotalControlsUpdateStyle(RefreshMessageEnabled,ControlStyle,RefreshMessageText);

        if RefreshMessageEnabled then
          ClearPurchaseAmounts(TotalsPurchaseLine,VATAmount);
    end;

    local procedure PurchaseUpdateTotals(var PurchaseHeader: Record "Purchase Header";CurrentPurchaseLine: Record "Purchase Line";var TotalsPurchaseLine: Record "Purchase Line";var VATAmount: Decimal;Force: Boolean): Boolean
    begin
        PurchaseHeader.CalcFields(Amount,"Amount Including VAT","Invoice Discount Amount");

        if (PreviousTotalPurchaseHeader.Amount = PurchaseHeader.Amount) and
           (PreviousTotalPurchaseHeader."Amount Including VAT" = PurchaseHeader."Amount Including VAT") and
           (PreviousTotalPurchVATDifference = CalcTotalPurchVATDifference(PurchaseHeader))
        then
          exit(true);

        if not Force then
          if not PurchaseCheckNumberOfLinesLimit(PurchaseHeader) then
            exit(false);

        PurchaseCalculateTotalsWithInvoiceRounding(CurrentPurchaseLine,VATAmount,TotalsPurchaseLine);
        exit(true);
    end;

    [Scope('Personalization')]
    procedure PurchaseCalculateTotalsWithInvoiceRounding(var TempCurrentPurchaseLine: Record "Purchase Line" temporary;var VATAmount: Decimal;var TempTotalPurchaseLine: Record "Purchase Line" temporary)
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        Clear(TempTotalPurchaseLine);

        if PurchaseHeader.Get(TempCurrentPurchaseLine."Document Type",TempCurrentPurchaseLine."Document No.") then begin
          CalculateTotalPurchaseLineAndVATAmount(PurchaseHeader,VATAmount,TempTotalPurchaseLine);

          if PreviousTotalPurchaseHeader."No." <> TempCurrentPurchaseLine."Document No." then
            PreviousTotalPurchaseHeader.Get(TempCurrentPurchaseLine."Document Type",TempCurrentPurchaseLine."Document No.");
          PreviousTotalPurchaseHeader.CalcFields(Amount,"Amount Including VAT");
          PreviousTotalPurchVATDifference := CalcTotalPurchVATDifference(PreviousTotalPurchaseHeader);

          // calculate correct amount including vat if the VAT Calc type is Sales Tax
          if TempCurrentPurchaseLine."VAT Calculation Type" = TempCurrentPurchaseLine."VAT Calculation Type"::"Sales Tax" then
            CalculateSalesTaxForTempTotalPurchaseLine(PurchaseHeader,TempCurrentPurchaseLine,TempTotalPurchaseLine);
        end;
    end;

    procedure PurchaseRedistributeInvoiceDiscountAmounts(var TempPurchaseLine: Record "Purchase Line" temporary;var VATAmount: Decimal;var TempTotalPurchaseLine: Record "Purchase Line" temporary)
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        with PurchaseHeader do
          if Get(TempPurchaseLine."Document Type",TempPurchaseLine."Document No.") then begin
            CalcFields("Recalculate Invoice Disc.");
            if "Recalculate Invoice Disc." then
              CODEUNIT.Run(CODEUNIT::"Purch - Calc Disc. By Type",TempPurchaseLine);

            PurchaseCalculateTotalsWithInvoiceRounding(TempPurchaseLine,VATAmount,TempTotalPurchaseLine);
          end;
    end;

    [Scope('Personalization')]
    procedure CalculatePurchasePageTotals(var TotalPurchaseLine: Record "Purchase Line";var VATAmount: Decimal;var PurchaseLine: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        if PurchaseHeader.Get(PurchaseLine."Document Type",PurchaseLine."Document No.") then
          CalculateTotalPurchaseLineAndVATAmount(PurchaseHeader,VATAmount,TotalPurchaseLine);
    end;

    [Scope('Personalization')]
    procedure CalculatePurchaseTotals(var TotalPurchaseLine: Record "Purchase Line";var VATAmount: Decimal;var PurchaseLine: Record "Purchase Line")
    begin
        CalculatePurchasePageTotals(TotalPurchaseLine,VATAmount,PurchaseLine);
    end;

    [Scope('Personalization')]
    procedure CalculatePostedPurchInvoiceTotals(var PurchInvHeader: Record "Purch. Inv. Header";var VATAmount: Decimal;PurchInvLine: Record "Purch. Inv. Line")
    begin
        if PurchInvHeader.Get(PurchInvLine."Document No.") then begin
          PurchInvHeader.CalcFields(Amount,"Amount Including VAT","Invoice Discount Amount");
          VATAmount := PurchInvHeader."Amount Including VAT" - PurchInvHeader.Amount;
        end;
    end;

    [Scope('Personalization')]
    procedure CalculatePostedPurchCreditMemoTotals(var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";var VATAmount: Decimal;PurchCrMemoLine: Record "Purch. Cr. Memo Line")
    begin
        if PurchCrMemoHdr.Get(PurchCrMemoLine."Document No.") then begin
          PurchCrMemoHdr.CalcFields(Amount,"Amount Including VAT","Invoice Discount Amount");
          VATAmount := PurchCrMemoHdr."Amount Including VAT" - PurchCrMemoHdr.Amount;
        end;
    end;

    local procedure ClearSalesAmounts(var TotalsSalesLine: Record "Sales Line";var VATAmount: Decimal)
    begin
        TotalsSalesLine.Amount := 0;
        TotalsSalesLine."Amount Including VAT" := 0;
        VATAmount := 0;
        Clear(PreviousTotalSalesHeader);
    end;

    local procedure ClearPurchaseAmounts(var TotalsPurchaseLine: Record "Purchase Line";var VATAmount: Decimal)
    begin
        TotalsPurchaseLine.Amount := 0;
        TotalsPurchaseLine."Amount Including VAT" := 0;
        VATAmount := 0;
        Clear(PreviousTotalPurchaseHeader);
    end;

    local procedure TotalControlsUpdateStyle(RefreshMessageEnabled: Boolean;var ControlStyle: Text;var RefreshMessageText: Text)
    begin
        if RefreshMessageEnabled then begin
          ControlStyle := 'Subordinate';
          RefreshMessageText := RefreshMsgTxt;
        end else begin
          ControlStyle := 'Strong';
          RefreshMessageText := '';
        end;
    end;

    [Scope('Personalization')]
    procedure GetTotalVATCaption(CurrencyCode: Code[10]): Text
    begin
        exit(GetCaptionClassWithCurrencyCode(TotalVATLbl,CurrencyCode));
    end;

    [Scope('Personalization')]
    procedure GetTotalInclVATCaption(CurrencyCode: Code[10]): Text
    begin
        exit(GetCaptionClassWithCurrencyCode(TotalAmountInclVatLbl,CurrencyCode));
    end;

    [Scope('Personalization')]
    procedure GetTotalExclVATCaption(CurrencyCode: Code[10]): Text
    begin
        exit(GetCaptionClassWithCurrencyCode(TotalAmountExclVATLbl,CurrencyCode));
    end;

    local procedure GetCaptionClassWithCurrencyCode(CaptionWithoutCurrencyCode: Text;CurrencyCode: Code[10]): Text
    begin
        exit('3,' + GetCaptionWithCurrencyCode(CaptionWithoutCurrencyCode,CurrencyCode));
    end;

    local procedure GetCaptionWithCurrencyCode(CaptionWithoutCurrencyCode: Text;CurrencyCode: Code[10]): Text
    var
        GLSetup: Record "General Ledger Setup";
    begin
        if CurrencyCode = '' then begin
          GLSetup.Get;
          CurrencyCode := GLSetup.GetCurrencyCode(CurrencyCode);
        end;

        if CurrencyCode <> '' then
          exit(CaptionWithoutCurrencyCode + StrSubstNo(' (%1)',CurrencyCode));

        exit(CaptionWithoutCurrencyCode);
    end;

    local procedure GetCaptionWithVATInfo(CaptionWithoutVATInfo: Text;IncludesVAT: Boolean): Text
    begin
        if IncludesVAT then
          exit('2,1,' + CaptionWithoutVATInfo);

        exit('2,0,' + CaptionWithoutVATInfo);
    end;

    [Scope('Personalization')]
    procedure GetInvoiceDiscAmountWithVATCaption(IncludesVAT: Boolean): Text
    begin
        exit(GetCaptionWithVATInfo(InvoiceDiscountAmountLbl,IncludesVAT));
    end;

    [Scope('Personalization')]
    procedure GetInvoiceDiscAmountWithVATAndCurrencyCaption(InvDiscAmountCaptionClassWithVAT: Text;CurrencyCode: Code[10]): Text
    begin
        exit(GetCaptionWithCurrencyCode(InvDiscAmountCaptionClassWithVAT,CurrencyCode));
    end;

    [Scope('Personalization')]
    procedure GetTotalLineAmountWithVATAndCurrencyCaption(CurrencyCode: Code[10];IncludesVAT: Boolean): Text
    begin
        exit(GetCaptionWithCurrencyCode(CaptionClassTranslate(GetCaptionWithVATInfo(TotalLineAmountLbl,IncludesVAT)),CurrencyCode));
    end;

    [Scope('Personalization')]
    procedure SalesCheckNumberOfLinesLimit(SalesHeader: Record "Sales Header"): Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document No.",SalesHeader."No.");
        SalesLine.SetRange("Document Type",SalesHeader."Document Type");
        SalesLine.SetFilter(Type,'<>%1',SalesLine.Type::" ");
        SalesLine.SetFilter("No.",'<>%1','');

        if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then
          exit(SalesLine.Count <= 10);

        exit(SalesLine.Count <= 100);
    end;

    [Scope('Personalization')]
    procedure PurchaseCheckNumberOfLinesLimit(PurchaseHeader: Record "Purchase Header"): Boolean
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange("Document No.",PurchaseHeader."No.");
        PurchaseLine.SetRange("Document Type",PurchaseHeader."Document Type");
        PurchaseLine.SetFilter(Type,'<>%1',PurchaseLine.Type::" ");
        PurchaseLine.SetFilter("No.",'<>%1','');

        if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order then
          exit(PurchaseLine.Count <= 10);

        exit(PurchaseLine.Count <= 100);
    end;

    local procedure CalculateSalesTaxForTempTotalPurchaseLine(PurchaseHeader: Record "Purchase Header";CurrentPurchaseLine: Record "Purchase Line";var TempTotalPurchaseLine: Record "Purchase Line" temporary)
    var
        Currency: Record Currency;
        SalesTaxCalculate: Codeunit "Sales Tax Calculate";
        TotalVATAmount: Decimal;
    begin
        if PurchaseHeader."Currency Code" = '' then
          Currency.InitRoundingPrecision
        else
          Currency.Get(PurchaseHeader."Currency Code");

        CurrentPurchaseLine.SetRange("Document No.",CurrentPurchaseLine."Document No.");
        CurrentPurchaseLine.SetRange("Document Type",CurrentPurchaseLine."Document Type");
        CurrentPurchaseLine.FindSet;
        TotalVATAmount := 0;

        // Loop through all purchase lines and calculate correct sales tax.
        repeat
          TotalVATAmount := TotalVATAmount + Round(
              SalesTaxCalculate.CalculateTax(
                CurrentPurchaseLine."Tax Area Code",CurrentPurchaseLine."Tax Group Code",CurrentPurchaseLine."Tax Liable",
                PurchaseHeader."Posting Date",
                CurrentPurchaseLine."Line Amount" - CurrentPurchaseLine."Inv. Discount Amount",
                CurrentPurchaseLine."Quantity (Base)",PurchaseHeader."Currency Factor"),
              Currency."Amount Rounding Precision");
        until CurrentPurchaseLine.Next = 0;

        TempTotalPurchaseLine."Amount Including VAT" := TempTotalPurchaseLine."Line Amount" -
          TempTotalPurchaseLine."Inv. Discount Amount" + TotalVATAmount;
    end;
}

