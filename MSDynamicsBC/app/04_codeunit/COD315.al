codeunit 315 "Sales Inv.-Printed"
{
    // version NAVW113.00

    Permissions = TableData "Sales Invoice Header"=rimd;
    TableNo = "Sales Invoice Header";

    trigger OnRun()
    begin
        Find;
        "No. Printed" := "No. Printed" + 1;
        OnBeforeModify(Rec);
        Modify;
        Commit;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModify(var SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
    end;
}

