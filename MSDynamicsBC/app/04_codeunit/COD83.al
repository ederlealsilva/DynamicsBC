codeunit 83 "Sales-Quote to Order (Yes/No)"
{
    // version NAVW111.00

    TableNo = "Sales Header";

    trigger OnRun()
    var
        OfficeMgt: Codeunit "Office Management";
        SalesOrder: Page "Sales Order";
        OpenPage: Boolean;
    begin
        TestField("Document Type","Document Type"::Quote);
        if GuiAllowed then
          if not Confirm(ConfirmConvertToOrderQst,false) then
            exit;

        if CheckCustomerCreated(true) then
          Get("Document Type"::Quote,"No.")
        else
          exit;

        SalesQuoteToOrder.Run(Rec);
        SalesQuoteToOrder.GetSalesOrderHeader(SalesHeader2);
        Commit;

        if GuiAllowed then
          if OfficeMgt.AttachAvailable then
            OpenPage := true
          else
            OpenPage := Confirm(StrSubstNo(OpenNewInvoiceQst,SalesHeader2."No."),true);
        if OpenPage then begin
          Clear(SalesOrder);
          SalesOrder.CheckNotificationsOnce;
          SalesHeader2.SetRecFilter;
          SalesOrder.SetTableView(SalesHeader2);
          SalesOrder.Run;
        end;
    end;

    var
        ConfirmConvertToOrderQst: Label 'Do you want to convert the quote to an order?';
        OpenNewInvoiceQst: Label 'The quote has been converted to order %1. Do you want to open the new order?', Comment='%1 = No. of the new sales order document.';
        SalesHeader2: Record "Sales Header";
        SalesQuoteToOrder: Codeunit "Sales-Quote to Order";
}

