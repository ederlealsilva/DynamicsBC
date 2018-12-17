codeunit 325 "Update Currency Factor"
{
    // version NAVW111.00

    Permissions = TableData "Sales Invoice Header"=rm,
                  TableData "Sales Cr.Memo Header"=rm,
                  TableData "Purch. Inv. Header"=rm,
                  TableData "Purch. Cr. Memo Hdr."=rm;

    trigger OnRun()
    begin
    end;

    [Scope('Personalization')]
    procedure ModifyPostedSalesInvoice(var SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
        SalesInvoiceHeader.Modify;
    end;

    [Scope('Personalization')]
    procedure ModifyPostedSalesCreditMemo(var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        SalesCrMemoHeader.Modify;
    end;

    [Scope('Personalization')]
    procedure ModifyPostedPurchaseInvoice(var PurchInvHeader: Record "Purch. Inv. Header")
    begin
        PurchInvHeader.Modify;
    end;

    [Scope('Personalization')]
    procedure ModifyPostedPurchaseCreditMemo(var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.")
    begin
        PurchCrMemoHdr.Modify;
    end;
}

