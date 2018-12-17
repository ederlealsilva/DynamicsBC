codeunit 2315 "O365 Setup Mgmt"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    procedure InvoicesExist(): Boolean
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if SalesInvoiceHeader.FindFirst then
          exit(true);

        SalesHeader.SetRange("Document Type",SalesHeader."Document Type"::Invoice);
        if SalesHeader.FindFirst then
          exit(true);
    end;

    procedure EstimatesExist(): Boolean
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetRange("Document Type",SalesHeader."Document Type"::Quote);
        if SalesHeader.FindFirst then
          exit(true);
    end;

    procedure DocumentsExist(): Boolean
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if SalesInvoiceHeader.FindFirst then
          exit(true);

        SalesHeader.SetFilter("Document Type",'%1|%2',SalesHeader."Document Type"::Invoice,SalesHeader."Document Type"::Quote);
        if SalesHeader.FindFirst then
          exit(true);
    end;

    procedure ShowCreateTestInvoice(): Boolean
    begin
        exit(DocumentsExist);
    end;
}

