codeunit 5904 "Service Cr. Memo-Printed"
{
    // version NAVW113.00

    Permissions = TableData "Service Cr.Memo Header"=rimd;
    TableNo = "Service Cr.Memo Header";

    trigger OnRun()
    begin
        Find;
        "No. Printed" := "No. Printed" + 1;
        OnBeforeModify(Rec);
        Modify;
        Commit;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModify(var ServiceCrMemoHeader: Record "Service Cr.Memo Header")
    begin
    end;
}

