codeunit 574 "Run Acc. Sched. CashFlow Stmt."
{
    // version NAVW110.0


    trigger OnRun()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
    begin
        GLAccountCategoryMgt.GetGLSetup(GeneralLedgerSetup);
        GLAccountCategoryMgt.RunAccountScheduleReport(GeneralLedgerSetup."Acc. Sched. for Cash Flow Stmt");
    end;
}

