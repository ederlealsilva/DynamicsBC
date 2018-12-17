codeunit 322 "SalesCount-PrintedArch"
{
    // version NAVW113.00

    TableNo = "Sales Header Archive";

    trigger OnRun()
    begin
        Find;
        "No. Printed" := "No. Printed" + 1;
        OnBeforeModify(Rec);
        Modify;
        Commit;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModify(var SalesHeaderArchive: Record "Sales Header Archive")
    begin
    end;
}

