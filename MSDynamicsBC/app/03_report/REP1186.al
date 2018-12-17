report 1186 "Shortcut Employee Check"
{
    // version NAVW113.00

    DefaultLayout = RDLC;
    RDLCLayout = './Shortcut Employee Check.rdlc';
    ApplicationArea = #Basic,#Suite;
    Caption = 'Employee Check';
    UsageCategory = Tasks;
    UseRequestPage = false;

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
        PAGE.Run(PAGE::"Employee Ledger Entries");
        Error(''); // To prevent pdf of this report from downloading.
    end;
}

