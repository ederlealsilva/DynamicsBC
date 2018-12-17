report 299 "Delete Invoiced Sales Orders"
{
    // version NAVW113.00

    Caption = 'Delete Invoiced Sales Orders';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Sales Header";"Sales Header")
        {
            DataItemTableView = SORTING("Document Type","No.") WHERE("Document Type"=CONST(Order));
            RequestFilterFields = "No.","Sell-to Customer No.","Bill-to Customer No.";
            RequestFilterHeading = 'Sales Order';

            trigger OnAfterGetRecord()
            var
                ATOLink: Record "Assemble-to-Order Link";
                ReserveSalesLine: Codeunit "Sales Line-Reserve";
                ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                PostSalesDelete: Codeunit "PostSales-Delete";
            begin
                Window.Update(1,"No.");

                AllLinesDeleted := true;
                ItemChargeAssgntSales.Reset;
                ItemChargeAssgntSales.SetRange("Document Type","Document Type");
                ItemChargeAssgntSales.SetRange("Document No.","No.");
                SalesOrderLine.Reset;
                SalesOrderLine.SetRange("Document Type","Document Type");
                SalesOrderLine.SetRange("Document No.","No.");
                SalesOrderLine.SetFilter("Quantity Invoiced",'<>0');
                if SalesOrderLine.Find('-') then begin
                  SalesOrderLine.SetRange("Quantity Invoiced");
                  SalesOrderLine.SetFilter("Outstanding Quantity",'<>0');
                  if not SalesOrderLine.Find('-') then begin
                    SalesOrderLine.SetRange("Outstanding Quantity");
                    SalesOrderLine.SetFilter("Qty. Shipped Not Invoiced",'<>0');
                    if not SalesOrderLine.Find('-') then begin
                      SalesOrderLine.LockTable;
                      if not SalesOrderLine.Find('-') then begin
                        SalesOrderLine.SetRange("Qty. Shipped Not Invoiced");

                        SalesSetup.Get;
                        if SalesSetup."Archive Orders" or SalesSetup."Archive Return Orders" then
                          ArchiveManagement.ArchSalesDocumentNoConfirm("Sales Header");

                        if SalesOrderLine.Find('-') then
                          repeat
                            SalesOrderLine.CalcFields("Qty. Assigned");
                            if (SalesOrderLine."Qty. Assigned" = SalesOrderLine."Quantity Invoiced") or
                               (SalesOrderLine.Type <> SalesOrderLine.Type::"Charge (Item)")
                            then begin
                              if SalesOrderLine.Type = SalesOrderLine.Type::"Charge (Item)" then begin
                                ItemChargeAssgntSales.SetRange("Document Line No.",SalesOrderLine."Line No.");
                                ItemChargeAssgntSales.DeleteAll;
                              end;
                              if SalesOrderLine.Type = SalesOrderLine.Type::Item then
                                ATOLink.DeleteAsmFromSalesLine(SalesOrderLine);
                              if SalesOrderLine.HasLinks then
                                SalesOrderLine.DeleteLinks;
                              SalesOrderLine.Delete;
                              OnAfterDeleteSalesLine(SalesOrderLine);
                            end else
                              AllLinesDeleted := false;
                            UpdateAssPurchOrder;
                          until SalesOrderLine.Next = 0;

                        if AllLinesDeleted then begin
                          ArchiveManagement.AutoArchiveSalesDocument("Sales Header");
                          PostSalesDelete.DeleteHeader(
                            "Sales Header",SalesShptHeader,SalesInvHeader,SalesCrMemoHeader,ReturnRcptHeader,
                            PrepmtSalesInvHeader,PrepmtSalesCrMemoHeader);

                          ReserveSalesLine.DeleteInvoiceSpecFromHeader("Sales Header");

                          SalesCommentLine.SetRange("Document Type","Document Type");
                          SalesCommentLine.SetRange("No.","No.");
                          SalesCommentLine.DeleteAll;

                          WhseRequest.SetRange("Source Type",DATABASE::"Sales Line");
                          WhseRequest.SetRange("Source Subtype","Document Type");
                          WhseRequest.SetRange("Source No.","No.");
                          if not WhseRequest.IsEmpty then
                            WhseRequest.DeleteAll(true);

                          ApprovalsMgmt.DeleteApprovalEntries(RecordId);

                          if HasLinks then
                            DeleteLinks;
                          Delete;
                        end;
                        Commit;
                      end;
                    end;
                  end;
                end;
            end;

            trigger OnPreDataItem()
            begin
                Window.Open(Text000);
            end;
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

    var
        Text000: Label 'Processing sales orders #1##########';
        SalesOrderLine: Record "Sales Line";
        SalesShptHeader: Record "Sales Shipment Header";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ReturnRcptHeader: Record "Return Receipt Header";
        PrepmtSalesInvHeader: Record "Sales Invoice Header";
        PrepmtSalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCommentLine: Record "Sales Comment Line";
        ItemChargeAssgntSales: Record "Item Charge Assignment (Sales)";
        SalesSetup: Record "Sales & Receivables Setup";
        WhseRequest: Record "Warehouse Request";
        ArchiveManagement: Codeunit ArchiveManagement;
        Window: Dialog;
        AllLinesDeleted: Boolean;

    local procedure UpdateAssPurchOrder()
    var
        PurchLine: Record "Purchase Line";
    begin
        with PurchLine do begin
          if SalesOrderLine."Special Order" then
            if Get(
                 "Document Type"::Order,SalesOrderLine."Special Order Purchase No.",SalesOrderLine."Special Order Purch. Line No.")
            then begin
              "Special Order Sales No." := '';
              "Special Order Sales Line No." := 0;
              Modify;
            end;

          if SalesOrderLine."Drop Shipment" then
            if Get(
                 "Document Type"::Order,SalesOrderLine."Purchase Order No.",SalesOrderLine."Purch. Order Line No.")
            then begin
              "Sales Order No." := '';
              "Sales Order Line No." := 0;
              Modify;
            end;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDeleteSalesLine(var SalesLine: Record "Sales Line")
    begin
    end;
}

