codeunit 1263 "Imp. Bank Conv.-Pre-Mapping"
{
    // version NAVW113.00

    TableNo = "Bank Acc. Reconciliation Line";

    trigger OnRun()
    var
        DataExch: Record "Data Exch.";
        PrePostProcessXMLImport: Codeunit "Pre & Post Process XML Import";
    begin
        DataExch.Get("Data Exch. Entry No.");
        PrePostProcessXMLImport.PreProcessFile(DataExch,StmtNoPathFilterTxt);
        PrePostProcessXMLImport.PreProcessBankAccount(DataExch,"Bank Account No.",StmtBankAccNoPathFilterTxt,'',CurrCodePathFilterTxt);
    end;

    var
        StmtBankAccNoPathFilterTxt: Label '/reportExportResponse/return/finsta/ownbankaccountidentification/bankaccount', Locked=true;
        CurrCodePathFilterTxt: Label '=''/reportExportResponse/return/finsta/statementdetails/amountdetails/currency''|=''/reportExportResponse/return/finsta/transactions/posting/currency''', Locked=true;
        StmtNoPathFilterTxt: Label '/reportExportResponse/return/finsta/statementdetails/statementno', Locked=true;
}

