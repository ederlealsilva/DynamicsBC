report 156 "Retained Earnings Statement"
{
    // version NAVW113.00

    AccessByPermission = TableData "G/L Account"=R;
    ApplicationArea = #Basic,#Suite;
    Caption = 'Retained Earnings Statement';
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
        CODEUNIT.Run(CODEUNIT::"Run Acc. Sched. Retained Earn.");
    end;
}

