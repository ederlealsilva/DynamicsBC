codeunit 321 "Purch.HeaderArch-Printed"
{
    // version NAVW113.00

    TableNo = "Purchase Header Archive";

    trigger OnRun()
    begin
        Find;
        "No. Printed" := "No. Printed" + 1;
        OnBeforeModify(Rec);
        Modify;
        Commit;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModify(var PurchaseHeaderArchive: Record "Purchase Header Archive")
    begin
    end;
}

