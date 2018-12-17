report 151 "Balance Sheet"
{
    // version NAVW113.00

    AccessByPermission = TableData "G/L Account"=R;
    ApplicationArea = #Basic,#Suite;
    Caption = 'Balance Sheet';
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
        CODEUNIT.Run(CODEUNIT::"Run Acc. Sched. Balance Sheet");
    end;
}

