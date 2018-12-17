codeunit 316 "Sales Cr. Memo-Printed"
{
    // version NAVW113.00

    Permissions = TableData "Sales Cr.Memo Header"=rimd;
    TableNo = "Sales Cr.Memo Header";

    trigger OnRun()
    begin
        Find;
        "No. Printed" := "No. Printed" + 1;
        OnBeforeModify(Rec);
        Modify;
        Commit;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModify(var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
    end;
}

