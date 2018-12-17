codeunit 384 "Upd. Pending Prepmt. Purchase"
{
    // version NAVW113.00


    trigger OnRun()
    var
        PrepaymentMgt: Codeunit "Prepayment Mgt.";
    begin
        PrepaymentMgt.UpdatePendingPrepaymentPurchase;
    end;
}

