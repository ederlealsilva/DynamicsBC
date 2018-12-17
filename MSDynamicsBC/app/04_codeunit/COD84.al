codeunit 84 "Blnkt Sales Ord. to Ord. (Y/N)"
{
    // version NAVW13.00

    TableNo = "Sales Header";

    trigger OnRun()
    begin
        TestField("Document Type","Document Type"::"Blanket Order");
        if not Confirm(Text000,false) then
          exit;

        BlanketSalesOrderToOrder.Run(Rec);
        BlanketSalesOrderToOrder.GetSalesOrderHeader(SalesHeader2);

        Message(
          Text001,
          SalesHeader2."No.","No.");
    end;

    var
        Text000: Label 'Do you want to create an order from the blanket order?';
        Text001: Label 'Order %1 has been created from blanket order %2.';
        SalesHeader2: Record "Sales Header";
        BlanketSalesOrderToOrder: Codeunit "Blanket Sales Order to Order";
}

