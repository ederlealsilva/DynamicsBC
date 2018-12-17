codeunit 1270 "Exp. Launcher Gen. Jnl."
{
    // version NAVW19.00

    Permissions = TableData "Data Exch."=rimd;
    TableNo = "Gen. Journal Line";

    trigger OnRun()
    var
        BankAccount: Record "Bank Account";
        CreditTransferRegister: Record "Credit Transfer Register";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlLine2: Record "Gen. Journal Line";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        DataExchMapping: Record "Data Exch. Mapping";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
    begin
        GenJnlLine.CopyFilters(Rec);
        GenJnlLine.FindFirst;

        GenJnlBatch.Get(GenJnlLine."Journal Template Name",GenJnlLine."Journal Batch Name");
        BankAccount.Get(GenJnlBatch."Bal. Account No.");
        DataExchDef.Get(BankAccount."Payment Export Format");

        CreditTransferRegister.CreateNew(DataExchDef.Code,GenJnlLine."Bal. Account No.");
        Commit;

        if DataExchDef."Data Handling Codeunit" > 0 then
          CODEUNIT.Run(DataExchDef."Data Handling Codeunit",GenJnlLine);

        if DataExchDef."Validation Codeunit" > 0 then
          CODEUNIT.Run(DataExchDef."Validation Codeunit",GenJnlLine);

        PaymentExportMgt.CreateDataExch(DataExch,GenJnlLine."Bal. Account No.");
        GenJnlLine2.CopyFilters(GenJnlLine);
        GenJnlLine2.ModifyAll("Data Exch. Entry No.",DataExch."Entry No.",true);

        DataExchMapping.SetRange("Data Exch. Def Code",DataExchDef.Code);
        DataExchMapping.SetRange("Table ID",DATABASE::"Payment Export Data");
        DataExchMapping.FindFirst;

        DataExch.ExportFromDataExch(DataExchMapping);
    end;
}

