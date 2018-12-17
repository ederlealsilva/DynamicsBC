codeunit 1283 "Exp. Bank Conv.-Pre-Mapping"
{
    // version NAVW111.00

    Permissions = TableData "Payment Export Data"=rimd;
    TableNo = "Data Exch.";

    trigger OnRun()
    begin
        FillExportBuffer("Entry No.");
    end;

    var
        ProgressMsg: Label 'Pre-processing line no. #1######.';
        Window: Dialog;

    local procedure FillExportBuffer(DataExchEntryNo: Integer)
    var
        GenJnlLine: Record "Gen. Journal Line";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PaymentMethod: Record "Payment Method";
        PaymentExportData: Record "Payment Export Data";
        GeneralLedgerSetup: Record "General Ledger Setup";
        CompanyInformation: Record "Company Information";
        BankAccount: Record "Bank Account";
        Customer: Record Customer;
        Vendor: Record Vendor;
        VendorBankAccount: Record "Vendor Bank Account";
        CustomerBankAccount: Record "Customer Bank Account";
        BankExportImportSetup: Record "Bank Export/Import Setup";
        Employee: Record Employee;
        MessageID: Text[20];
        LineNo: Integer;
    begin
        GeneralLedgerSetup.Get;
        CompanyInformation.Get;

        GenJnlLine.SetRange("Data Exch. Entry No.",DataExchEntryNo);
        with PaymentExportData do begin
          GenJnlLine.FindSet;
          GenJnlLine.TestField("Bal. Account Type",GenJnlLine."Bal. Account Type"::"Bank Account");
          BankAccount.Get(GenJnlLine."Bal. Account No.");
          BankAccount.TestField("Bank Name - Data Conversion");
          BankAccount.GetBankExportImportSetup(BankExportImportSetup);
          MessageID := BankAccount.GetCreditTransferMessageNo;
          Window.Open(ProgressMsg);

          repeat
            Clear(PaymentExportData);
            Init;
            SetPreserveNonLatinCharacters(BankExportImportSetup."Preserve Non-Latin Characters");
            LineNo += 1;
            "Line No." := LineNo;
            "Data Exch Entry No." := DataExchEntryNo;
            "Creditor No." := BankAccount."Creditor No.";
            "Transit No." := BankAccount."Transit No.";
            "General Journal Template" := GenJnlLine."Journal Template Name";
            "General Journal Batch Name" := GenJnlLine."Journal Batch Name";
            "General Journal Line No." := GenJnlLine."Line No.";
            "Recipient ID" := GenJnlLine."Account No.";
            "Message ID" := MessageID;
            "Document No." := GenJnlLine."Document No.";
            "End-to-End ID" := "Message ID" + '/' + Format("Line No.");
            "Payment Information ID" := Format(CreateGuid);
            "Applies-to Ext. Doc. No." := GenJnlLine."Applies-to Ext. Doc. No.";
            "Short Advice" := GenJnlLine."Document No.";
            "Recipient Creditor No." := GenJnlLine."Creditor No.";

            case GenJnlLine."Account Type" of
              GenJnlLine."Account Type"::Customer:
                begin
                  Customer.Get(GenJnlLine."Account No.");
                  if CustomerBankAccount.Get(Customer."No.",GenJnlLine."Recipient Bank Account") then
                    SetCustomerAsRecipient(Customer,CustomerBankAccount);
                  if CustLedgerEntry.Get(GenJnlLine.GetAppliesToDocEntryNo) then begin
                    CustLedgerEntry.CalcFields("Original Amount");
                    "Invoice Amount" := Abs(CustLedgerEntry."Original Amount");
                    "Invoice Date" := CustLedgerEntry."Document Date";
                  end;
                end;
              GenJnlLine."Account Type"::Vendor:
                begin
                  Vendor.Get(GenJnlLine."Account No.");
                  if VendorBankAccount.Get(Vendor."No.",GenJnlLine."Recipient Bank Account") then
                    SetVendorAsRecipient(Vendor,VendorBankAccount);
                  if VendorLedgerEntry.Get(GenJnlLine.GetAppliesToDocEntryNo) then begin
                    VendorLedgerEntry.CalcFields("Original Amount");
                    "Invoice Amount" := Abs(VendorLedgerEntry."Original Amount");
                    "Invoice Date" := VendorLedgerEntry."Document Date";
                  end;
                end;
              GenJnlLine."Account Type"::Employee:
                begin
                  Employee.Get(GenJnlLine."Account No.");
                  SetEmployeeAsRecipient(Employee);
                end;
            end;

            GenJnlLine.TestField("Payment Method Code");
            PaymentMethod.Get(GenJnlLine."Payment Method Code");
            "Data Exch. Line Def Code" := PaymentMethod."Pmt. Export Line Definition";
            "Payment Type" := PaymentMethod."Bank Data Conversion Pmt. Type";
            "Payment Reference" := GenJnlLine."Payment Reference";
            "Message to Recipient 1" := CopyStr(GenJnlLine."Message to Recipient",1,35);
            "Message to Recipient 2" := CopyStr(GenJnlLine."Message to Recipient",36,70);
            Amount := GenJnlLine.Amount;
            "Currency Code" := GeneralLedgerSetup.GetCurrencyCode(GenJnlLine."Currency Code");
            "Transfer Date" := GenJnlLine."Posting Date";
            "Costs Distribution" := 'Shared';
            "Message Structure" := 'manual';
            "Own Address Info." := 'frombank';
            SetBankAsSenderBank(BankAccount);
            "Sender Bank Country/Region" := CompanyInformation.GetCountryRegionCode(BankAccount."Country/Region Code");
            "Sender Bank Account Currency" := GeneralLedgerSetup.GetCurrencyCode(BankAccount."Currency Code");

            Insert(true);
            Window.Update(1,LineNo);
          until GenJnlLine.Next = 0;
        end;

        Window.Close;
    end;
}

