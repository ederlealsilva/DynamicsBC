report 740 "VAT Report Print"
{
    // version NAVW111.00

    DefaultLayout = RDLC;
    RDLCLayout = './VAT Report Print.rdlc';
    Caption = 'VAT Report Print';

    dataset
    {
        dataitem("VAT Report Header";"VAT Report Header")
        {
        }
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
        Error('');
    end;
}

