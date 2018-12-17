codeunit 232 "Gen. Jnl.-Post+Print"
{
    // version NAVW113.00

    TableNo = "Gen. Journal Line";

    trigger OnRun()
    begin
        GenJnlLine.Copy(Rec);
        Code;
        Copy(GenJnlLine);
    end;

    var
        Text000: Label 'cannot be filtered when posting recurring journals';
        Text001: Label 'Do you want to post the journal lines and print the report(s)?';
        Text002: Label 'There is nothing to post.';
        Text003: Label 'The journal lines were successfully posted.';
        Text004: Label 'The journal lines were successfully posted. You are now in the %1 journal.';
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlLine: Record "Gen. Journal Line";
        GLReg: Record "G/L Register";
        CustLedgEntry: Record "Cust. Ledger Entry";
        VendLedgEntry: Record "Vendor Ledger Entry";
        TempJnlBatchName: Code[10];

    local procedure "Code"()
    var
        Handled: Boolean;
    begin
        with GenJnlLine do begin
          GenJnlTemplate.Get("Journal Template Name");
          if GenJnlTemplate."Force Posting Report" or
             (GenJnlTemplate."Cust. Receipt Report ID" = 0) and (GenJnlTemplate."Vendor Receipt Report ID" = 0)
          then
            GenJnlTemplate.TestField("Posting Report ID");
          if GenJnlTemplate.Recurring and (GetFilter("Posting Date") <> '') then
            FieldError("Posting Date",Text000);

          OnBeforePostJournalBatch(GenJnlLine);

          if not Confirm(Text001,false) then
            exit;

          TempJnlBatchName := "Journal Batch Name";

          CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post Batch",GenJnlLine);

          if GLReg.Get("Line No.") then begin
            if GenJnlTemplate."Cust. Receipt Report ID" <> 0 then begin
              CustLedgEntry.SetRange("Entry No.",GLReg."From Entry No.",GLReg."To Entry No.");
              REPORT.Run(GenJnlTemplate."Cust. Receipt Report ID",false,false,CustLedgEntry);
            end;
            if GenJnlTemplate."Vendor Receipt Report ID" <> 0 then begin
              VendLedgEntry.SetRange("Entry No.",GLReg."From Entry No.",GLReg."To Entry No.");
              REPORT.Run(GenJnlTemplate."Vendor Receipt Report ID",false,false,VendLedgEntry);
            end;
            if GenJnlTemplate."Posting Report ID" <> 0 then begin
              GLReg.SetRecFilter;
              OnBeforeGLRegPostingReportPrint(GenJnlTemplate."Posting Report ID",false,false,GLReg,Handled);
              if not Handled then
                REPORT.Run(GenJnlTemplate."Posting Report ID",false,false,GLReg);
            end;
          end;

          if "Line No." = 0 then
            Message(Text002)
          else
            if TempJnlBatchName = "Journal Batch Name" then
              Message(Text003)
            else
              Message(
                Text004,
                "Journal Batch Name");

          if not Find('=><') or (TempJnlBatchName <> "Journal Batch Name") then begin
            Reset;
            FilterGroup(2);
            SetRange("Journal Template Name","Journal Template Name");
            SetRange("Journal Batch Name","Journal Batch Name");
            FilterGroup(0);
            "Line No." := 1;
          end;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGLRegPostingReportPrint(var ReportID: Integer;ReqWindow: Boolean;SystemPrinter: Boolean;var GLRegister: Record "G/L Register";var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostJournalBatch(var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;
}

