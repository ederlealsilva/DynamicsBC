codeunit 225 "Gen. Jnl.-Apply"
{
    // version NAVW113.00

    TableNo = "Gen. Journal Line";

    trigger OnRun()
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        VendLedgEntry: Record "Vendor Ledger Entry";
        IsHandled: Boolean;
    begin
        GenJnlLine.Copy(Rec);

        OnBeforeRun(GenJnlLine);

        with GenJnlLine do begin
          GetCurrency;
          if "Bal. Account Type" in
             ["Bal. Account Type"::Customer,"Bal. Account Type"::Vendor,"Bal. Account Type"::Employee]
          then begin
            AccType := "Bal. Account Type";
            AccNo := "Bal. Account No.";
          end else begin
            AccType := "Account Type";
            AccNo := "Account No.";
          end;
          case AccType of
            AccType::Customer:
              begin
                OK := SelectCustLedgEntry(GenJnlLine);
                if not OK then
                  exit;

                CustLedgEntry.Reset;
                CustLedgEntry.SetCurrentKey("Customer No.",Open,Positive);
                CustLedgEntry.SetRange("Customer No.",AccNo);
                CustLedgEntry.SetRange(Open,true);
                CustLedgEntry.SetRange("Applies-to ID","Applies-to ID");
                if CustLedgEntry.Find('-') then begin
                  CurrencyCode2 := CustLedgEntry."Currency Code";
                  if Amount = 0 then begin
                    repeat
                      PaymentToleranceMgt.DelPmtTolApllnDocNo(GenJnlLine,CustLedgEntry."Document No.");
                      CheckAgainstApplnCurrency(CurrencyCode2,CustLedgEntry."Currency Code",AccType::Customer,true);
                      UpdateCustLedgEntry(CustLedgEntry);
                      IsHandled := false;
                      OnBeforeFindCustApply(GenJnlLine,CustLedgEntry,Amount,IsHandled);
                      if not IsHandled then
                        if PaymentToleranceMgt.CheckCalcPmtDiscGenJnlCust(Rec,CustLedgEntry,0,false) and
                           (Abs(CustLedgEntry."Amount to Apply") >=
                            Abs(CustLedgEntry."Remaining Amount" - CustLedgEntry."Remaining Pmt. Disc. Possible"))
                        then
                          Amount := Amount - (CustLedgEntry."Amount to Apply" - CustLedgEntry."Remaining Pmt. Disc. Possible")
                        else
                          Amount := Amount - CustLedgEntry."Amount to Apply";
                    until CustLedgEntry.Next = 0;
                    if ("Bal. Account Type" = "Bal. Account Type"::Customer) or ("Bal. Account Type" = "Bal. Account Type"::Vendor) then
                      Amount := -Amount;
                    Validate(Amount);
                  end else
                    repeat
                      CheckAgainstApplnCurrency(CurrencyCode2,CustLedgEntry."Currency Code",AccType::Customer,true);
                    until CustLedgEntry.Next = 0;
                  if "Currency Code" <> CurrencyCode2 then
                    if Amount = 0 then begin
                      if not Confirm(ConfirmChangeQst,true,TableCaption,"Currency Code",CustLedgEntry."Currency Code") then
                        Error(UpdateInterruptedErr);
                      "Currency Code" := CustLedgEntry."Currency Code"
                    end else
                      CheckAgainstApplnCurrency("Currency Code",CustLedgEntry."Currency Code",AccType::Customer,true);
                  "Applies-to Doc. Type" := 0;
                  "Applies-to Doc. No." := '';
                end else
                  "Applies-to ID" := '';
                Modify;
                if Rec.Amount <> 0 then
                  if not PaymentToleranceMgt.PmtTolGenJnl(GenJnlLine) then
                    exit;
              end;
            AccType::Vendor:
              begin
                OK := SelectVendLedgEntry(GenJnlLine);
                if not OK then
                  exit;

                VendLedgEntry.Reset;
                VendLedgEntry.SetCurrentKey("Vendor No.",Open,Positive);
                VendLedgEntry.SetRange("Vendor No.",AccNo);
                VendLedgEntry.SetRange(Open,true);
                VendLedgEntry.SetRange("Applies-to ID","Applies-to ID");
                if VendLedgEntry.Find('-') then begin
                  CurrencyCode2 := VendLedgEntry."Currency Code";
                  if Amount = 0 then begin
                    repeat
                      PaymentToleranceMgt.DelPmtTolApllnDocNo(GenJnlLine,VendLedgEntry."Document No.");
                      CheckAgainstApplnCurrency(CurrencyCode2,VendLedgEntry."Currency Code",AccType::Vendor,true);
                      UpdateVendLedgEntry(VendLedgEntry);
                      IsHandled := false;
                      OnBeforeFindVendApply(GenJnlLine,VendLedgEntry,Amount,IsHandled);
                      if not IsHandled then
                        if PaymentToleranceMgt.CheckCalcPmtDiscGenJnlVend(Rec,VendLedgEntry,0,false) and
                           (Abs(VendLedgEntry."Amount to Apply") >=
                            Abs(VendLedgEntry."Remaining Amount" - VendLedgEntry."Remaining Pmt. Disc. Possible"))
                        then
                          Amount := Amount - (VendLedgEntry."Amount to Apply" - VendLedgEntry."Remaining Pmt. Disc. Possible")
                        else
                          Amount := Amount - VendLedgEntry."Amount to Apply";
                    until VendLedgEntry.Next = 0;
                    if ("Bal. Account Type" = "Bal. Account Type"::Customer) or ("Bal. Account Type" = "Bal. Account Type"::Vendor) then
                      Amount := -Amount;
                    Validate(Amount);
                  end else
                    repeat
                      CheckAgainstApplnCurrency(CurrencyCode2,VendLedgEntry."Currency Code",AccType::Vendor,true);
                    until VendLedgEntry.Next = 0;
                  if "Currency Code" <> CurrencyCode2 then
                    if Amount = 0 then begin
                      if not Confirm(ConfirmChangeQst,true,TableCaption,"Currency Code",VendLedgEntry."Currency Code") then
                        Error(UpdateInterruptedErr);
                      "Currency Code" := VendLedgEntry."Currency Code"
                    end else
                      CheckAgainstApplnCurrency("Currency Code",VendLedgEntry."Currency Code",AccType::Vendor,true);
                  "Applies-to Doc. Type" := 0;
                  "Applies-to Doc. No." := '';
                end else
                  "Applies-to ID" := '';
                Modify;
                if Rec.Amount <> 0 then
                  if not PaymentToleranceMgt.PmtTolGenJnl(GenJnlLine) then
                    exit;
              end;
            AccType::Employee:
              ApplyEmployeeLedgerEntry(GenJnlLine);
            else
              Error(
                Text005,
                FieldCaption("Account Type"),FieldCaption("Bal. Account Type"));
          end;
        end;
        OnAfterRun(GenJnlLine);

        Rec := GenJnlLine;
    end;

    var
        Text000: Label 'You must specify %1 or %2.';
        ConfirmChangeQst: Label 'CurrencyCode in the %1 will be changed from %2 to %3.\Do you wish to continue?', Comment='%1 = Table Name, %2 and %3 = Currency Code';
        UpdateInterruptedErr: Label 'The update has been interrupted to respect the warning.';
        Text005: Label 'The %1 or %2 must be Customer or Vendor.';
        Text006: Label 'All entries in one application must be in the same currency.';
        Text007: Label 'All entries in one application must be in the same currency or one or more of the EMU currencies. ';
        GenJnlLine: Record "Gen. Journal Line";
        GLSetup: Record "General Ledger Setup";
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        PaymentToleranceMgt: Codeunit "Payment Tolerance Management";
        AccNo: Code[20];
        CurrencyCode2: Code[10];
        OK: Boolean;
        AccType: Option "G/L Account",Customer,Vendor,"Bank Account","Fixed Asset","IC Partner",Employee;

    local procedure SelectCustLedgEntry(var GenJnlLine: Record "Gen. Journal Line") OK: Boolean
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        ApplyCustEntries: Page "Apply Customer Entries";
    begin
        with GenJnlLine do begin
          CustLedgEntry.SetCurrentKey("Customer No.",Open,Positive);
          CustLedgEntry.SetRange("Customer No.",AccNo);
          CustLedgEntry.SetRange(Open,true);
          if "Applies-to ID" = '' then
            "Applies-to ID" := "Document No.";
          if "Applies-to ID" = '' then
            Error(
              Text000,
              FieldCaption("Document No."),FieldCaption("Applies-to ID"));
          ApplyCustEntries.SetGenJnlLine(GenJnlLine,FieldNo("Applies-to ID"));
          ApplyCustEntries.SetRecord(CustLedgEntry);
          ApplyCustEntries.SetTableView(CustLedgEntry);
          ApplyCustEntries.LookupMode(true);
          OK := ApplyCustEntries.RunModal = ACTION::LookupOK;
          Clear(ApplyCustEntries);
        end;
    end;

    local procedure SelectVendLedgEntry(var GenJnlLine: Record "Gen. Journal Line") OK: Boolean
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
        ApplyVendEntries: Page "Apply Vendor Entries";
    begin
        with GenJnlLine do begin
          VendLedgEntry.SetCurrentKey("Vendor No.",Open,Positive);
          VendLedgEntry.SetRange("Vendor No.",AccNo);
          VendLedgEntry.SetRange(Open,true);
          if "Applies-to ID" = '' then
            "Applies-to ID" := "Document No.";
          if "Applies-to ID" = '' then
            Error(
              Text000,
              FieldCaption("Document No."),FieldCaption("Applies-to ID"));
          ApplyVendEntries.SetGenJnlLine(GenJnlLine,FieldNo("Applies-to ID"));
          ApplyVendEntries.SetRecord(VendLedgEntry);
          ApplyVendEntries.SetTableView(VendLedgEntry);
          ApplyVendEntries.LookupMode(true);
          OK := ApplyVendEntries.RunModal = ACTION::LookupOK;
          Clear(ApplyVendEntries);
        end;
    end;

    local procedure SelectEmplLedgEntry(var GenJnlLine: Record "Gen. Journal Line") OK: Boolean
    var
        EmplLedgEntry: Record "Employee Ledger Entry";
        ApplyEmplEntries: Page "Apply Employee Entries";
    begin
        with GenJnlLine do begin
          EmplLedgEntry.SetCurrentKey("Employee No.",Open,Positive);
          EmplLedgEntry.SetRange("Employee No.",AccNo);
          EmplLedgEntry.SetRange(Open,true);
          if "Applies-to ID" = '' then
            "Applies-to ID" := "Document No.";
          if "Applies-to ID" = '' then
            Error(
              Text000,
              FieldCaption("Document No."),FieldCaption("Applies-to ID"));
          ApplyEmplEntries.SetGenJnlLine(GenJnlLine,FieldNo("Applies-to ID"));
          ApplyEmplEntries.SetRecord(EmplLedgEntry);
          ApplyEmplEntries.SetTableView(EmplLedgEntry);
          ApplyEmplEntries.LookupMode(true);
          OK := ApplyEmplEntries.RunModal = ACTION::LookupOK;
          Clear(ApplyEmplEntries);
        end;
    end;

    local procedure UpdateCustLedgEntry(var CustLedgEntry: Record "Cust. Ledger Entry")
    begin
        with GenJnlLine do begin
          CustLedgEntry.CalcFields("Remaining Amount");
          CustLedgEntry."Remaining Amount" :=
            CurrExchRate.ExchangeAmount(
              CustLedgEntry."Remaining Amount",CustLedgEntry."Currency Code","Currency Code","Posting Date");
          CustLedgEntry."Remaining Amount" :=
            Round(CustLedgEntry."Remaining Amount",Currency."Amount Rounding Precision");
          CustLedgEntry."Remaining Pmt. Disc. Possible" :=
            CurrExchRate.ExchangeAmount(
              CustLedgEntry."Remaining Pmt. Disc. Possible",CustLedgEntry."Currency Code","Currency Code","Posting Date");
          CustLedgEntry."Remaining Pmt. Disc. Possible" :=
            Round(CustLedgEntry."Remaining Pmt. Disc. Possible",Currency."Amount Rounding Precision");
          CustLedgEntry."Amount to Apply" :=
            CurrExchRate.ExchangeAmount(
              CustLedgEntry."Amount to Apply",CustLedgEntry."Currency Code","Currency Code","Posting Date");
          CustLedgEntry."Amount to Apply" :=
            Round(CustLedgEntry."Amount to Apply",Currency."Amount Rounding Precision");
        end;
    end;

    local procedure UpdateVendLedgEntry(var VendLedgEntry: Record "Vendor Ledger Entry")
    begin
        with GenJnlLine do begin
          VendLedgEntry.CalcFields("Remaining Amount");
          VendLedgEntry."Remaining Amount" :=
            CurrExchRate.ExchangeAmount(
              VendLedgEntry."Remaining Amount",VendLedgEntry."Currency Code","Currency Code","Posting Date");
          VendLedgEntry."Remaining Amount" :=
            Round(VendLedgEntry."Remaining Amount",Currency."Amount Rounding Precision");
          VendLedgEntry."Remaining Pmt. Disc. Possible" :=
            CurrExchRate.ExchangeAmount(
              VendLedgEntry."Remaining Pmt. Disc. Possible",VendLedgEntry."Currency Code","Currency Code","Posting Date");
          VendLedgEntry."Remaining Pmt. Disc. Possible" :=
            Round(VendLedgEntry."Remaining Pmt. Disc. Possible",Currency."Amount Rounding Precision");
          VendLedgEntry."Amount to Apply" :=
            CurrExchRate.ExchangeAmount(
              VendLedgEntry."Amount to Apply",VendLedgEntry."Currency Code","Currency Code","Posting Date");
          VendLedgEntry."Amount to Apply" :=
            Round(VendLedgEntry."Amount to Apply",Currency."Amount Rounding Precision");
        end;
    end;

    [Scope('Personalization')]
    procedure CheckAgainstApplnCurrency(ApplnCurrencyCode: Code[10];CompareCurrencyCode: Code[10];AccType: Option "G/L Account",Customer,Vendor,"Bank Account","Fixed Asset";Message: Boolean): Boolean
    var
        Currency: Record Currency;
        Currency2: Record Currency;
        SalesSetup: Record "Sales & Receivables Setup";
        PurchSetup: Record "Purchases & Payables Setup";
        CurrencyAppln: Option No,EMU,All;
    begin
        if ApplnCurrencyCode = CompareCurrencyCode then
          exit(true);

        case AccType of
          AccType::Customer:
            begin
              SalesSetup.Get;
              CurrencyAppln := SalesSetup."Appln. between Currencies";
              case CurrencyAppln of
                CurrencyAppln::No:
                  begin
                    if ApplnCurrencyCode <> CompareCurrencyCode then
                      if Message then
                        Error(Text006)
                      else
                        exit(false);
                  end;
                CurrencyAppln::EMU:
                  begin
                    GLSetup.Get;
                    if not Currency.Get(ApplnCurrencyCode) then
                      Currency."EMU Currency" := GLSetup."EMU Currency";
                    if not Currency2.Get(CompareCurrencyCode) then
                      Currency2."EMU Currency" := GLSetup."EMU Currency";
                    if not Currency."EMU Currency" or not Currency2."EMU Currency" then
                      if Message then
                        Error(Text007)
                      else
                        exit(false);
                  end;
              end;
            end;
          AccType::Vendor:
            begin
              PurchSetup.Get;
              CurrencyAppln := PurchSetup."Appln. between Currencies";
              case CurrencyAppln of
                CurrencyAppln::No:
                  begin
                    if ApplnCurrencyCode <> CompareCurrencyCode then
                      if Message then
                        Error(Text006)
                      else
                        exit(false);
                  end;
                CurrencyAppln::EMU:
                  begin
                    GLSetup.Get;
                    if not Currency.Get(ApplnCurrencyCode) then
                      Currency."EMU Currency" := GLSetup."EMU Currency";
                    if not Currency2.Get(CompareCurrencyCode) then
                      Currency2."EMU Currency" := GLSetup."EMU Currency";
                    if not Currency."EMU Currency" or not Currency2."EMU Currency" then
                      if Message then
                        Error(Text007)
                      else
                        exit(false);
                  end;
              end;
            end;
        end;

        exit(true);
    end;

    local procedure GetCurrency()
    begin
        with GenJnlLine do
          if "Currency Code" = '' then
            Currency.InitRoundingPrecision
          else begin
            Currency.Get("Currency Code");
            Currency.TestField("Amount Rounding Precision");
          end;
    end;

    local procedure ApplyEmployeeLedgerEntry(var GenJnlLine: Record "Gen. Journal Line")
    var
        EmplLedgEntry: Record "Employee Ledger Entry";
    begin
        with GenJnlLine do begin
          OK := SelectEmplLedgEntry(GenJnlLine);
          if not OK then
            exit;

          EmplLedgEntry.Reset;
          EmplLedgEntry.SetCurrentKey("Employee No.",Open,Positive);
          EmplLedgEntry.SetRange("Employee No.",AccNo);
          EmplLedgEntry.SetRange(Open,true);
          EmplLedgEntry.SetRange("Applies-to ID","Applies-to ID");
          if EmplLedgEntry.Find('-') then begin
            if Amount = 0 then begin
              repeat
                Amount := Amount - EmplLedgEntry."Amount to Apply";
              until EmplLedgEntry.Next = 0;
              if ("Bal. Account Type" = "Bal. Account Type"::Customer) or
                 ("Bal. Account Type" = "Bal. Account Type"::Vendor) or
                 ("Bal. Account Type" = "Bal. Account Type"::Employee)
              then
                Amount := -Amount;
              Validate(Amount);
            end;
            "Applies-to Doc. Type" := 0;
            "Applies-to Doc. No." := '';
          end else
            "Applies-to ID" := '';
          if Modify then;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRun(var GenJnlLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRun(var GenJnlLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFindCustApply(GenJournalLine: Record "Gen. Journal Line";CustLedgerEntry: Record "Cust. Ledger Entry";var Amount: Decimal;var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFindVendApply(GenJournalLine: Record "Gen. Journal Line";VendorLedgerEntry: Record "Vendor Ledger Entry";var Amount: Decimal;var IsHandled: Boolean)
    begin
    end;
}

