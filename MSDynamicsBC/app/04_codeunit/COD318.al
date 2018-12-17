codeunit 318 "Purch.Rcpt.-Printed"
{
    // version NAVW113.00

    Permissions = TableData "Purch. Rcpt. Header"=rimd;
    TableNo = "Purch. Rcpt. Header";

    trigger OnRun()
    begin
        Find;
        "No. Printed" := "No. Printed" + 1;
        OnBeforeModify(Rec);
        Modify;
        Commit;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModify(var PurchRcptHeader: Record "Purch. Rcpt. Header")
    begin
    end;
}

