codeunit 382 "BankAccStmtLines-Delete"
{
    // version NAVW13.00

    Permissions = TableData "Bank Account Statement Line"=d;
    TableNo = "Bank Account Statement";

    trigger OnRun()
    begin
        BankAccStmtLine.SetRange("Bank Account No.","Bank Account No.");
        BankAccStmtLine.SetRange("Statement No.","Statement No.");
        BankAccStmtLine.DeleteAll;
    end;

    var
        BankAccStmtLine: Record "Bank Account Statement Line";
}

