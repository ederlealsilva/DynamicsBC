codeunit 320 "PurchCrMemo-Printed"
{
    // version NAVW113.00

    Permissions = TableData "Purch. Cr. Memo Hdr."=rimd;
    TableNo = "Purch. Cr. Memo Hdr.";

    trigger OnRun()
    begin
        Find;
        "No. Printed" := "No. Printed" + 1;
        OnBeforeModify(Rec);
        Modify;
        Commit;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModify(var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.")
    begin
    end;
}

