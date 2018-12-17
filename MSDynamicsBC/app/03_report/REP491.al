report 491 "Delete Invd Blnkt Purch Orders"
{
    // version NAVW113.00

    Caption = 'Delete Invd Blnkt Purch Orders';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Purchase Header";"Purchase Header")
        {
            DataItemTableView = SORTING("Document Type","No.") WHERE("Document Type"=CONST("Blanket Order"));
            RequestFilterFields = "No.","Buy-from Vendor No.","Pay-to Vendor No.";
            RequestFilterHeading = 'Blanket Purchase Order';

            trigger OnAfterGetRecord()
            var
                ApprovalsMgmt: Codeunit "Approvals Mgmt.";
            begin
                Window.Update(1,"No.");

                PurchLine.Reset;
                PurchLine.SetRange("Document Type","Document Type");
                PurchLine.SetRange("Document No.","No.");
                PurchLine.SetFilter("Quantity Invoiced",'<>0');
                if PurchLine.FindFirst then begin
                  PurchLine.SetRange("Quantity Invoiced");
                  PurchLine.SetFilter("Outstanding Quantity",'<>0');
                  if not PurchLine.FindFirst then begin
                    PurchLine.SetRange("Outstanding Quantity");
                    PurchLine.SetFilter("Qty. Rcd. Not Invoiced",'<>0');
                    if not PurchLine.FindFirst then begin
                      PurchLine.LockTable;
                      if not PurchLine.FindFirst then begin
                        PurchLine.SetRange("Qty. Rcd. Not Invoiced");
                        PurchLine2.SetRange("Blanket Order No.","No.");
                        if not PurchLine2.FindFirst then begin
                          PurchSetup.Get;
                          if PurchSetup."Archive Blanket Orders" then
                            ArchiveManagement.ArchPurchDocumentNoConfirm("Purchase Header");

                          PurchLine.DeleteAll;

                          PurchCommentLine.SetRange("Document Type","Document Type");
                          PurchCommentLine.SetRange("No.","No.");
                          PurchCommentLine.DeleteAll;

                          ApprovalsMgmt.DeleteApprovalEntries(RecordId);

                          Delete;

                          Commit;
                        end;
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
        Text000: Label 'Processing purch. orders #1##########';
        PurchLine: Record "Purchase Line";
        PurchLine2: Record "Purchase Line";
        PurchCommentLine: Record "Purch. Comment Line";
        PurchSetup: Record "Purchases & Payables Setup";
        ArchiveManagement: Codeunit ArchiveManagement;
        Window: Dialog;
}

