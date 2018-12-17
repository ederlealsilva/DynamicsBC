report 153 "Customer Statement"
{
    // version NAVW113.00

    ApplicationArea = #Basic,#Suite;
    Caption = 'Customer Statement';
    ProcessingOnly = true;
    UsageCategory = Documents;

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
        CODEUNIT.Run(CODEUNIT::"Customer Layout - Statement");
    end;
}

