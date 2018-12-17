codeunit 319 "Purch. Inv.-Printed"
{
    // version NAVW113.00

    Permissions = TableData "Purch. Inv. Header"=rimd;
    TableNo = "Purch. Inv. Header";

    trigger OnRun()
    begin
        Find;
        "No. Printed" := "No. Printed" + 1;
        OnBeforeModify(Rec);
        Modify;
        Commit;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModify(var PurchInvHeader: Record "Purch. Inv. Header")
    begin
    end;
}

