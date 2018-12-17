codeunit 66 "Purch - Calc Disc. By Type"
{
    // version NAVW113.00

    TableNo = "Purchase Line";

    trigger OnRun()
    var
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
    begin
        PurchLine.Copy(Rec);

        if PurchHeader.Get("Document Type","Document No.") then begin
          ApplyDefaultInvoiceDiscount(0,PurchHeader);
          // on new order might be no line
          if Get(PurchLine."Document Type",PurchLine."Document No.",PurchLine."Line No.") then;
        end;
    end;

    var
        InvDiscBaseAmountIsZeroErr: Label 'There is no amount that you can apply an invoice discount to.';
        InvDiscSetToZeroMsg: Label 'The current %1 is %2.\\The value will be set to zero because the total has changed. Review the new total and then re-enter the %1.', Comment='%1 - Invoice discount amount, %2 Previous value of Invoice discount amount';
        AmountInvDiscErr: Label 'Manual %1 is not allowed.';

    [Scope('Personalization')]
    procedure ApplyDefaultInvoiceDiscount(InvoiceDiscountAmount: Decimal;var PurchHeader: Record "Purchase Header")
    var
        AutoFormatManagement: Codeunit AutoFormatManagement;
        PreviousInvoiceDiscountAmount: Decimal;
        ShowSetToZeroMessage: Boolean;
    begin
        if not ShouldRedistributeInvoiceDiscountAmount(PurchHeader) then
          exit;

        if PurchHeader."Invoice Discount Calculation" = PurchHeader."Invoice Discount Calculation"::Amount then begin
          PreviousInvoiceDiscountAmount := PurchHeader."Invoice Discount Value";
          ShowSetToZeroMessage := (InvoiceDiscountAmount = 0) and (PurchHeader."Invoice Discount Value" <> 0);
          ApplyInvDiscBasedOnAmt(InvoiceDiscountAmount,PurchHeader);
          if ShowSetToZeroMessage then
            Message(
              StrSubstNo(
                InvDiscSetToZeroMsg,
                PurchHeader.FieldCaption("Invoice Discount Amount"),
                Format(PreviousInvoiceDiscountAmount,0,AutoFormatManagement.AutoFormatTranslate(1,PurchHeader."Currency Code"))));
        end else
          ApplyInvDiscBasedOnPct(PurchHeader);

        ResetRecalculateInvoiceDisc(PurchHeader);
    end;

    [Scope('Personalization')]
    procedure ApplyInvDiscBasedOnAmt(InvoiceDiscountAmount: Decimal;var PurchHeader: Record "Purchase Header")
    var
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        PurchLine: Record "Purchase Line";
        InvDiscBaseAmount: Decimal;
    begin
        with PurchHeader do begin
          if not InvoiceDiscIsAllowed("Invoice Disc. Code") then
            Error(AmountInvDiscErr,FieldCaption("Invoice Discount Amount"));

          PurchLine.SetRange("Document No.","No.");
          PurchLine.SetRange("Document Type","Document Type");

          PurchLine.CalcVATAmountLines(0,PurchHeader,PurchLine,TempVATAmountLine);

          InvDiscBaseAmount := TempVATAmountLine.GetTotalInvDiscBaseAmount(false,"Currency Code");

          if (InvDiscBaseAmount = 0) and (InvoiceDiscountAmount > 0) then
            Error(InvDiscBaseAmountIsZeroErr);

          TempVATAmountLine.SetInvoiceDiscountAmount(InvoiceDiscountAmount,"Currency Code",
            "Prices Including VAT","VAT Base Discount %");

          PurchLine.UpdateVATOnLines(0,PurchHeader,PurchLine,TempVATAmountLine);

          "Invoice Discount Calculation" := "Invoice Discount Calculation"::Amount;
          "Invoice Discount Value" := InvoiceDiscountAmount;

          Modify;

          ResetRecalculateInvoiceDisc(PurchHeader);
        end;
    end;

    local procedure ApplyInvDiscBasedOnPct(var PurchHeader: Record "Purchase Header")
    var
        PurchLine: Record "Purchase Line";
    begin
        with PurchHeader do begin
          PurchLine.SetRange("Document No.","No.");
          PurchLine.SetRange("Document Type","Document Type");
          if PurchLine.FindFirst then begin
            CODEUNIT.Run(CODEUNIT::"Purch.-Calc.Discount",PurchLine);
            Get("Document Type","No.");
          end;
        end;
    end;

    [Scope('Personalization')]
    procedure GetVendInvoiceDiscountPct(PurchLine: Record "Purchase Line"): Decimal
    var
        PurchHeader: Record "Purchase Header";
        InvoiceDiscountValue: Decimal;
        AmountIncludingVATDiscountAllowed: Decimal;
        AmountDiscountAllowed: Decimal;
    begin
        with PurchHeader do begin
          if not Get(PurchLine."Document Type",PurchLine."Document No.") then
            exit(0);

          CalcFields("Invoice Discount Amount");
          if "Invoice Discount Amount" = 0 then
            exit(0);

          case "Invoice Discount Calculation" of
            "Invoice Discount Calculation"::"%":
              begin
                // Only if VendorInvDisc table is empty header is not updated
                if not VendorInvDiscRecExists("Invoice Disc. Code") then
                  exit(0);

                exit("Invoice Discount Value");
              end;
            "Invoice Discount Calculation"::None,
            "Invoice Discount Calculation"::Amount:
              begin
                CalcAmountWithDiscountAllowed(PurchHeader,AmountIncludingVATDiscountAllowed,AmountDiscountAllowed);
                if AmountDiscountAllowed + InvoiceDiscountValue = 0 then
                  exit(0);

                if "Invoice Discount Calculation" = "Invoice Discount Calculation"::None then
                  InvoiceDiscountValue := "Invoice Discount Amount"
                else
                  InvoiceDiscountValue := "Invoice Discount Value";

                if "Prices Including VAT" then
                  exit(Round(InvoiceDiscountValue / (AmountIncludingVATDiscountAllowed + InvoiceDiscountValue) * 100,0.01));

                exit(Round(InvoiceDiscountValue / (AmountDiscountAllowed + InvoiceDiscountValue) * 100,0.01));
              end;
          end;
        end;

        exit(0);
    end;

    [Scope('Personalization')]
    procedure ShouldRedistributeInvoiceDiscountAmount(PurchHeader: Record "Purchase Header"): Boolean
    var
        PurchPayablesSetup: Record "Purchases & Payables Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        PurchHeader.CalcFields("Recalculate Invoice Disc.");

        if not PurchHeader."Recalculate Invoice Disc." then
          exit(false);

        if (PurchHeader."Invoice Discount Calculation" = PurchHeader."Invoice Discount Calculation"::Amount) and
           (PurchHeader."Invoice Discount Value" = 0)
        then
          exit(false);

        PurchPayablesSetup.Get;
        if (not ApplicationAreaMgmtFacade.IsFoundationEnabled and
            (not PurchPayablesSetup."Calc. Inv. Discount" and
             (PurchHeader."Invoice Discount Calculation" = PurchHeader."Invoice Discount Calculation"::None)))
        then
          exit(false);

        exit(true);
    end;

    [Scope('Personalization')]
    procedure ResetRecalculateInvoiceDisc(PurchHeader: Record "Purchase Header")
    var
        PurchLine: Record "Purchase Line";
    begin
        PurchLine.SetRange("Document Type",PurchHeader."Document Type");
        PurchLine.SetRange("Document No.",PurchHeader."No.");
        PurchLine.ModifyAll("Recalculate Invoice Disc.",false);

        OnAfterResetRecalculateInvoiceDisc(PurchHeader);
    end;

    local procedure VendorInvDiscRecExists(InvDiscCode: Code[20]): Boolean
    var
        VendorInvoiceDisc: Record "Vendor Invoice Disc.";
    begin
        VendorInvoiceDisc.SetRange(Code,InvDiscCode);
        exit(not VendorInvoiceDisc.IsEmpty);
    end;

    [Scope('Personalization')]
    procedure InvoiceDiscIsAllowed(InvDiscCode: Code[20]): Boolean
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        PurchasesPayablesSetup.Get;
        exit((ApplicationAreaMgmtFacade.IsFoundationEnabled or not
              (PurchasesPayablesSetup."Calc. Inv. Discount" and VendorInvDiscRecExists(InvDiscCode))));
    end;

    local procedure CalcAmountWithDiscountAllowed(PurchHeader: Record "Purchase Header";var AmountIncludingVATDiscountAllowed: Decimal;var AmountDiscountAllowed: Decimal)
    var
        PurchLine: Record "Purchase Line";
    begin
        with PurchLine do begin
          SetRange("Document Type",PurchHeader."Document Type");
          SetRange("Document No.",PurchHeader."No.");
          SetRange("Allow Invoice Disc.",true);
          CalcSums(Amount,"Amount Including VAT");
          AmountIncludingVATDiscountAllowed := "Amount Including VAT";
          AmountDiscountAllowed := Amount;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterResetRecalculateInvoiceDisc(var PurchaseHeader: Record "Purchase Header")
    begin
    end;
}

