report 150 "Transfer GL Entries to CA"
{
    // version NAVW113.00

    ApplicationArea = #CostAccounting;
    Caption = 'Transfer GL Entries to CA';
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
        CODEUNIT.Run(CODEUNIT::"Transfer GL Entries to CA");
    end;
}

