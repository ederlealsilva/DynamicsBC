codeunit 56 "Sales - Calc Discount By Type"
{
    // version NAVW113.00

    TableNo = "Sales Line";

    trigger OnRun()
    var
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
    begin
        SalesLine.Copy(Rec);

        if SalesHeader.Get("Document Type","Document No.") then begin
          ApplyDefaultInvoiceDiscount(SalesHeader."Invoice Discount Value",SalesHeader);
          // on new order might be no line
          if Get(SalesLine."Document Type",SalesLine."Document No.",SalesLine."Line No.") then;
        end;
    end;

    var
        InvDiscBaseAmountIsZeroErr: Label 'There is no amount that you can apply an invoice discount to.';
        AmountInvDiscErr: Label 'Manual %1 is not allowed.', Comment='%1 will be "Invoice Discount Amount"';
        CalcInvoiceDiscountOnSalesLine: Boolean;

    [Scope('Personalization')]
    procedure ApplyDefaultInvoiceDiscount(InvoiceDiscountAmount: Decimal;var SalesHeader: Record "Sales Header")
    begin
        if not ShouldRedistributeInvoiceDiscountAmount(SalesHeader) then
          exit;

        if SalesHeader."Invoice Discount Calculation" = SalesHeader."Invoice Discount Calculation"::Amount then
          ApplyInvDiscBasedOnAmt(InvoiceDiscountAmount,SalesHeader)
        else
          ApplyInvDiscBasedOnPct(SalesHeader);

        ResetRecalculateInvoiceDisc(SalesHeader);
    end;

    [Scope('Personalization')]
    procedure ApplyInvDiscBasedOnAmt(InvoiceDiscountAmount: Decimal;var SalesHeader: Record "Sales Header")
    var
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        SalesLine: Record "Sales Line";
        InvDiscBaseAmount: Decimal;
    begin
        with SalesHeader do begin
          if not InvoiceDiscIsAllowed("Invoice Disc. Code") then
            Error(AmountInvDiscErr,FieldCaption("Invoice Discount Amount"));

          SalesLine.SetRange("Document No.","No.");
          SalesLine.SetRange("Document Type","Document Type");

          SalesLine.CalcVATAmountLines(0,SalesHeader,SalesLine,TempVATAmountLine);

          InvDiscBaseAmount := TempVATAmountLine.GetTotalInvDiscBaseAmount(false,"Currency Code");

          if (InvDiscBaseAmount = 0) and (InvoiceDiscountAmount > 0) then
            Error(InvDiscBaseAmountIsZeroErr);

          TempVATAmountLine.SetInvoiceDiscountAmount(InvoiceDiscountAmount,"Currency Code",
            "Prices Including VAT","VAT Base Discount %");

          SalesLine.UpdateVATOnLines(0,SalesHeader,SalesLine,TempVATAmountLine);

          "Invoice Discount Calculation" := "Invoice Discount Calculation"::Amount;
          "Invoice Discount Value" := InvoiceDiscountAmount;

          ResetRecalculateInvoiceDisc(SalesHeader);

          Modify;
        end;
    end;

    local procedure ApplyInvDiscBasedOnPct(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        SalesCalcDiscount: Codeunit "Sales-Calc. Discount";
    begin
        with SalesHeader do begin
          SalesLine.SetRange("Document No.","No.");
          SalesLine.SetRange("Document Type","Document Type");
          if SalesLine.FindFirst then begin
            if CalcInvoiceDiscountOnSalesLine then
              SalesCalcDiscount.CalculateInvoiceDiscountOnLine(SalesLine)
            else
              CODEUNIT.Run(CODEUNIT::"Sales-Calc. Discount",SalesLine);
            Get("Document Type","No.");
          end;
        end;
    end;

    [Scope('Personalization')]
    procedure GetCustInvoiceDiscountPct(SalesLine: Record "Sales Line"): Decimal
    var
        SalesHeader: Record "Sales Header";
        InvoiceDiscountValue: Decimal;
        AmountIncludingVATDiscountAllowed: Decimal;
        AmountDiscountAllowed: Decimal;
    begin
        with SalesHeader do begin
          if not Get(SalesLine."Document Type",SalesLine."Document No.") then
            exit(0);

          CalcFields("Invoice Discount Amount");
          if "Invoice Discount Amount" = 0 then
            exit(0);

          case "Invoice Discount Calculation" of
            "Invoice Discount Calculation"::"%":
              begin
                // Only if CustInvDisc table is empty header is not updated
                if not CustInvDiscRecExists("Invoice Disc. Code") then
                  exit(0);

                exit("Invoice Discount Value");
              end;
            "Invoice Discount Calculation"::None,
            "Invoice Discount Calculation"::Amount:
              begin
                if "Invoice Discount Calculation" = "Invoice Discount Calculation"::None then
                  InvoiceDiscountValue := "Invoice Discount Amount"
                else
                  InvoiceDiscountValue := "Invoice Discount Value";

                CalcAmountWithDiscountAllowed(SalesHeader,AmountIncludingVATDiscountAllowed,AmountDiscountAllowed);
                if AmountDiscountAllowed + InvoiceDiscountValue = 0 then
                  exit(0);

                if "Prices Including VAT" then
                  exit(Round(InvoiceDiscountValue / (AmountIncludingVATDiscountAllowed + InvoiceDiscountValue) * 100,0.01));

                exit(Round(InvoiceDiscountValue / (AmountDiscountAllowed + InvoiceDiscountValue) * 100,0.01));
              end;
          end;
        end;

        exit(0);
    end;

    [Scope('Personalization')]
    procedure ShouldRedistributeInvoiceDiscountAmount(var SalesHeader: Record "Sales Header"): Boolean
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        SalesHeader.CalcFields("Recalculate Invoice Disc.");

        if not SalesHeader."Recalculate Invoice Disc." then
          exit(false);

        case SalesHeader."Invoice Discount Calculation" of
          SalesHeader."Invoice Discount Calculation"::Amount:
            exit(SalesHeader."Invoice Discount Value" <> 0);
          SalesHeader."Invoice Discount Calculation"::"%":
            exit(true);
          SalesHeader."Invoice Discount Calculation"::None:
            begin
              if ApplicationAreaMgmtFacade.IsFoundationEnabled then
                exit(true);

              exit(not InvoiceDiscIsAllowed(SalesHeader."Invoice Disc. Code"));
            end;
          else
            exit(true);
        end;
    end;

    [Scope('Personalization')]
    procedure ResetRecalculateInvoiceDisc(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type",SalesHeader."Document Type");
        SalesLine.SetRange("Document No.",SalesHeader."No.");
        SalesLine.SetRange("Recalculate Invoice Disc.",true);
        SalesLine.ModifyAll("Recalculate Invoice Disc.",false);

        OnAfterResetRecalculateInvoiceDisc(SalesHeader);
    end;

    local procedure CustInvDiscRecExists(InvDiscCode: Code[20]): Boolean
    var
        CustInvDisc: Record "Cust. Invoice Disc.";
    begin
        CustInvDisc.SetRange(Code,InvDiscCode);
        exit(not CustInvDisc.IsEmpty);
    end;

    [Scope('Personalization')]
    procedure InvoiceDiscIsAllowed(InvDiscCode: Code[20]): Boolean
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivablesSetup.Get;
        if not SalesReceivablesSetup."Calc. Inv. Discount" then
          exit(true);

        exit(not CustInvDiscRecExists(InvDiscCode));
    end;

    local procedure CalcAmountWithDiscountAllowed(SalesHeader: Record "Sales Header";var AmountIncludingVATDiscountAllowed: Decimal;var AmountDiscountAllowed: Decimal)
    var
        SalesLine: Record "Sales Line";
    begin
        with SalesLine do begin
          SetRange("Document Type",SalesHeader."Document Type");
          SetRange("Document No.",SalesHeader."No.");
          SetRange("Allow Invoice Disc.",true);
          CalcSums(Amount,"Amount Including VAT");
          AmountIncludingVATDiscountAllowed := "Amount Including VAT";
          AmountDiscountAllowed := Amount;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterResetRecalculateInvoiceDisc(var SalesHeader: Record "Sales Header")
    begin
    end;

    procedure CalcInvoiceDiscOnLine(CalcInvoiceDiscountOnLine: Boolean)
    begin
        CalcInvoiceDiscountOnSalesLine := CalcInvoiceDiscountOnLine;
    end;
}

