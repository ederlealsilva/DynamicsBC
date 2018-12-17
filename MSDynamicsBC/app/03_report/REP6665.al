report 6665 "Batch Post Purch. Ret. Orders"
{
    // version NAVW111.00

    Caption = 'Batch Post Purch. Ret. Orders';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Purchase Header";"Purchase Header")
        {
            DataItemTableView = SORTING("Document Type","No.") WHERE("Document Type"=CONST("Return Order"));
            RequestFilterFields = "No.",Status;
            RequestFilterHeading = 'Purchase Return Order';

            trigger OnPreDataItem()
            var
                BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
                BatchPostParameterTypes: Codeunit "Batch Post Parameter Types";
                PurchaseBatchPostMgt: Codeunit "Purchase Batch Post Mgt.";
            begin
                BatchProcessingMgt.AddParameter(BatchPostParameterTypes.Ship,ShipReq);

                PurchaseBatchPostMgt.SetBatchProcessor(BatchProcessingMgt);
                PurchaseBatchPostMgt.RunBatch("Purchase Header",ReplacePostingDate,PostingDateReq,ReplaceDocumentDate,CalcInvDisc,false,InvReq);

                CurrReport.Break;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(Ship;ShipReq)
                    {
                        ApplicationArea = PurchReturnOrder;
                        Caption = 'Ship';
                        ToolTip = 'Specifies if the orders are shipped when posted. If you select this check box, it applies to all orders that are posted.';
                    }
                    field(Invoice;InvReq)
                    {
                        ApplicationArea = PurchReturnOrder;
                        Caption = 'Invoice';
                        ToolTip = 'Specifies if the orders are invoiced when posted. If you select this check box, it applies to all the orders that are posted.';
                    }
                    field(PostingDate;PostingDateReq)
                    {
                        ApplicationArea = PurchReturnOrder;
                        Caption = 'Posting Date';
                        ToolTip = 'Specifies the date that you want to use as the document date or the posting date when you post if you select the Replace Document Date check box or the Replace Posting Date check box.';
                    }
                    field(ReplacePostingDate;ReplacePostingDate)
                    {
                        ApplicationArea = PurchReturnOrder;
                        Caption = 'Replace Posting Date';
                        ToolTip = 'Specifies if you want to replace the posting date of the orders with the date that is entered in the Posting Date field.';

                        trigger OnValidate()
                        begin
                            if ReplacePostingDate then
                              Message(Text003);
                        end;
                    }
                    field(ReplaceDocumentDate;ReplaceDocumentDate)
                    {
                        ApplicationArea = PurchReturnOrder;
                        Caption = 'Replace Document Date';
                        ToolTip = 'Specifies if you want to replace the document date of the orders with the date in the Posting Date field.';
                    }
                    field(CalcInvDiscount;CalcInvDisc)
                    {
                        ApplicationArea = PurchReturnOrder;
                        Caption = 'Calc. Inv. Discount';
                        ToolTip = 'Specifies if you want the invoice discount amount to be automatically calculated on the orders before posting.';

                        trigger OnValidate()
                        var
                            PurchasesPayablesSetup: Record "Purchases & Payables Setup";
                        begin
                            PurchasesPayablesSetup.Get;
                            PurchasesPayablesSetup.TestField("Calc. Inv. Discount",false);
                        end;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        var
            PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        begin
            PurchasesPayablesSetup.Get;
            CalcInvDisc := PurchasesPayablesSetup."Calc. Inv. Discount";
        end;
    }

    labels
    {
    }

    var
        PostingDateReq: Date;
        ShipReq: Boolean;
        InvReq: Boolean;
        ReplacePostingDate: Boolean;
        ReplaceDocumentDate: Boolean;
        CalcInvDisc: Boolean;
        Text003: Label 'The exchange rate associated with the new posting date on the purchase header will not apply to the purchase lines.';
}

