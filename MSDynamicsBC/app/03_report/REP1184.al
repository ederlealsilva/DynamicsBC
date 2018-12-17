report 1184 "Shortcut Receive Customer Pay"
{
    // version NAVW113.00

    DefaultLayout = RDLC;
    RDLCLayout = './Shortcut Receive Customer Pay.rdlc';
    ApplicationArea = #Basic,#Suite;
    Caption = 'Receive Customer Payments';
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
        PAGE.Run(PAGE::"Payment Registration");
        Error(''); // To prevent pdf of this report from downloading.
    end;
}

