report 155 "Statement of Cashflows"
{
    // version NAVW113.00

    AccessByPermission = TableData "G/L Account"=R;
    ApplicationArea = #Basic,#Suite;
    Caption = 'Statement of Cashflows';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        CODEUNIT.Run(CODEUNIT::"Run Acc. Sched. CashFlow Stmt.");
    end;
}

