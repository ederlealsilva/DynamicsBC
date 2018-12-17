codeunit 1296 "BankPaymentApplLines-Delete"
{
    // version NAVW18.00

    Permissions = TableData "Posted Payment Recon. Line"=d;
    TableNo = "Posted Payment Recon. Hdr";

    trigger OnRun()
    begin
        PostedPaymentReconLine.SetRange("Bank Account No.","Bank Account No.");
        PostedPaymentReconLine.SetRange("Statement No.","Statement No.");
        PostedPaymentReconLine.DeleteAll;
    end;

    var
        PostedPaymentReconLine: Record "Posted Payment Recon. Line";
}

