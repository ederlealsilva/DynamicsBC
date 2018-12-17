codeunit 383 "Upd. Pending Prepmt. Sales"
{
    // version NAVW113.00


    trigger OnRun()
    var
        PrepaymentMgt: Codeunit "Prepayment Mgt.";
    begin
        PrepaymentMgt.UpdatePendingPrepaymentSales;
    end;
}

