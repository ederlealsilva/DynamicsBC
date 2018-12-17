codeunit 5922 "Serv-Quote to Order (Yes/No)"
{
    // version NAVW15.00

    TableNo = "Service Header";

    trigger OnRun()
    begin
        TestField("Document Type","Document Type"::Quote);
        TestField("Customer No.");
        TestField("Bill-to Customer No.");
        if not Confirm(Text000,false) then
          exit;

        ServQuoteToOrder.Run(Rec);

        Message(Text001,"No.",ServQuoteToOrder.ReturnOrderNo);
    end;

    var
        Text000: Label 'Do you want to convert the quote to an order?';
        Text001: Label 'Service quote %1 has been converted to service order no. %2.';
        ServQuoteToOrder: Codeunit "Service-Quote to Order";
}

