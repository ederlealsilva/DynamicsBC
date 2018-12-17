report 152 "Calculate Low Level Code"
{
    // version NAVW113.00

    ApplicationArea = #Manufacturing;
    Caption = 'Calculate Low Level Code';
    ProcessingOnly = true;
    UsageCategory = Tasks;

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
        CODEUNIT.Run(CODEUNIT::"Calc. Low-level code");
    end;
}

