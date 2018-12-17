report 154 "Income Statement"
{
    // version NAVW113.00

    AccessByPermission = TableData "G/L Account"=R;
    ApplicationArea = #Basic,#Suite;
    Caption = 'Income Statement';
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
        CODEUNIT.Run(CODEUNIT::"Run Acc. Sched. Income Stmt.");
    end;
}

