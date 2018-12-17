codeunit 9023 "Pmt. Rec. Jnl. Import Trans."
{
    // version NAVW110.0


    trigger OnRun()
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
    begin
        BankAccReconciliation.ImportAndProcessToNewStatement
    end;
}

