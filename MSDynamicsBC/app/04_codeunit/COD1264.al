codeunit 1264 "Imp. Bank Conv.-Post-Mapping"
{
    // version NAVW19.00

    TableNo = "Bank Acc. Reconciliation Line";

    trigger OnRun()
    var
        DataExch: Record "Data Exch.";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        PrePostProcessXMLImport: Codeunit "Pre & Post Process XML Import";
        RecRef: RecordRef;
    begin
        DataExch.Get("Data Exch. Entry No.");
        BankAccReconciliation.Get("Statement Type","Bank Account No.","Statement No.");

        RecRef.GetTable(BankAccReconciliation);
        PrePostProcessXMLImport.PostProcessStatementEndingBalance(DataExch,RecRef,
          BankAccReconciliation.FieldNo("Statement Ending Balance"),'EndBalance',StmtBalTypePathFilterTxt,StmtAmtPathFilterTxt,'',2);
        PrePostProcessXMLImport.PostProcessStatementDate(DataExch,RecRef,BankAccReconciliation.FieldNo("Statement Date"),
          StmtDatePathFilterTxt);
    end;

    var
        StmtDatePathFilterTxt: Label '/reportExportResponse/return/finsta/statementdetails/todate', Locked=true;
        StmtBalTypePathFilterTxt: Label '/reportExportResponse/return/finsta/statementdetails/amountdetails/type', Locked=true;
        StmtAmtPathFilterTxt: Label '/reportExportResponse/return/finsta/statementdetails/amountdetails/value', Locked=true;
}

