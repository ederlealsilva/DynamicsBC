codeunit 234 "Gen. Jnl.-B.Post+Print"
{
    // version NAVW113.00

    TableNo = "Gen. Journal Batch";

    trigger OnRun()
    begin
        GenJnlBatch.Copy(Rec);
        Code;
        Rec := GenJnlBatch;
    end;

    var
        Text000: Label 'Do you want to post the journals and print the report(s)?';
        Text001: Label 'The journals were successfully posted.';
        Text002: Label 'It was not possible to post all of the journals. ';
        Text003: Label 'The journals that were not successfully posted are now marked.';
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        GLReg: Record "G/L Register";
        CustLedgEntry: Record "Cust. Ledger Entry";
        VendLedgEntry: Record "Vendor Ledger Entry";
        GenJnlPostBatch: Codeunit "Gen. Jnl.-Post Batch";
        GenJnlManagement: Codeunit GenJnlManagement;
        JnlWithErrors: Boolean;

    local procedure "Code"()
    var
        Handled: Boolean;
        OrderByDocNoAndLineNo: Boolean;
    begin
        // If simple view is used then order gen. journal lines by doc no. and line no.
        if GenJnlManagement.GetJournalSimplePageModePreference(PAGE::"General Journal") then
          OrderByDocNoAndLineNo := true;

        with GenJnlBatch do begin
          GenJnlTemplate.Get("Journal Template Name");
          if GenJnlTemplate."Force Posting Report" or
             (GenJnlTemplate."Cust. Receipt Report ID" = 0) and (GenJnlTemplate."Vendor Receipt Report ID" = 0)
          then
            GenJnlTemplate.TestField("Posting Report ID");

          if not Confirm(Text000,false) then
            exit;

          Find('-');
          repeat
            GenJnlLine."Journal Template Name" := "Journal Template Name";
            GenJnlLine."Journal Batch Name" := Name;
            GenJnlLine."Line No." := 1;
            if OrderByDocNoAndLineNo then
              GenJnlLine.SetCurrentKey("Document No.","Line No.");
            Clear(GenJnlPostBatch);
            if GenJnlPostBatch.Run(GenJnlLine) then begin
              Mark(false);
              if GLReg.Get(GenJnlLine."Line No.") then begin
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
            end else begin
              Mark(true);
              JnlWithErrors := true;
            end;
          until Next = 0;

          if not JnlWithErrors then
            Message(Text001)
          else
            Message(
              Text002 +
              Text003);

          if not Find('=><') then begin
            Reset;
            Name := '';
          end;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGLRegPostingReportPrint(var ReportID: Integer;ReqWindow: Boolean;SystemPrinter: Boolean;var GLRegister: Record "G/L Register";var Handled: Boolean)
    begin
    end;
}

