report 1187 "Shortcut Employee Expense"
{
    // version NAVW113.00

    DefaultLayout = RDLC;
    RDLCLayout = './Shortcut Employee Expense.rdlc';
    ApplicationArea = #Basic,#Suite;
    Caption = 'Employee Expense';
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

