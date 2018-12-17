report 5405 "Calc. Consumption"
{
    // version NAVW113.00

    Caption = 'Calc. Consumption';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Production Order";"Production Order")
        {
            DataItemTableView = SORTING(Status,"No.") WHERE(Status=CONST(Released));
            RequestFilterFields = "No.";
            dataitem("Prod. Order Component";"Prod. Order Component")
            {
                DataItemLink = Status=FIELD(Status),"Prod. Order No."=FIELD("No.");
                RequestFilterFields = "Item No.";

                trigger OnAfterGetRecord()
                var
                    NeededQty: Decimal;
                begin
                    Window.Update(2,"Item No.");

                    Clear(ItemJnlLine);
                    Item.Get("Item No.");
                    ProdOrderLine.Get(Status,"Prod. Order No.","Prod. Order Line No.");

                    NeededQty := GetNeededQty(CalcBasedOn,true);

                    if NeededQty <> 0 then begin
                      if LocationCode <> '' then
                        CreateConsumpJnlLine(LocationCode,'',NeededQty)
                      else
                        CreateConsumpJnlLine("Location Code","Bin Code",NeededQty);
                      LastItemJnlLine := ItemJnlLine;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    SetFilter("Flushing Method",'<>%1&<>%2',"Flushing Method"::Backward,"Flushing Method"::"Pick + Backward");
                end;
            }

            trigger OnAfterGetRecord()
            begin
                Window.Update(1,"No.");
            end;

            trigger OnPreDataItem()
            begin
                ItemJnlLine.SetRange("Journal Template Name",ToTemplateName);
                ItemJnlLine.SetRange("Journal Batch Name",ToBatchName);
                if ItemJnlLine.FindLast then
                  NextConsumpJnlLineNo := ItemJnlLine."Line No." + 10000
                else
                  NextConsumpJnlLineNo := 10000;

                Window.Open(
                  Text000 +
                  Text001 +
                  Text002 +
                  Text003);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(PostingDate;PostingDate)
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Posting Date';
                        ToolTip = 'Specifies the posting date that you want the program to use in the Consumption Journal window.';
                    }
                    field(CalcBasedOn;CalcBasedOn)
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Calculation Based on';
                        OptionCaption = 'Actual Output,Expected Output';
                        ToolTip = 'Specifies whether the calculation of the quantity to consume is based on the actual output or on the expected output (the quantity of finished goods that you expect to produce).';
                    }
                    field(LocationCode;LocationCode)
                    {
                        ApplicationArea = Location;
                        Caption = 'Picking Location';
                        ToolTip = 'Specifies the location from where you want the program to post the items.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            Location: Record Location;
                        begin
                            if PAGE.RunModal(0,Location) = ACTION::LookupOK then begin
                              Text := Location.Code;
                              exit(true);
                            end;
                            exit(false);
                        end;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            InitializeRequest(WorkDate,CalcBasedOn::"Expected Output");
        end;
    }

    labels
    {
    }

    var
        Text000: Label 'Calculating consumption...\\';
        Text001: Label 'Prod. Order No.   #1##########\';
        Text002: Label 'Item No.          #2##########\';
        Text003: Label 'Quantity          #3##########';
        Item: Record Item;
        ProdOrderLine: Record "Prod. Order Line";
        ItemJnlLine: Record "Item Journal Line";
        LastItemJnlLine: Record "Item Journal Line";
        Window: Dialog;
        PostingDate: Date;
        CalcBasedOn: Option "Actual Output","Expected Output";
        LocationCode: Code[10];
        ToTemplateName: Code[10];
        ToBatchName: Code[10];
        NextConsumpJnlLineNo: Integer;

    [Scope('Personalization')]
    procedure InitializeRequest(NewPostingDate: Date;NewCalcBasedOn: Option)
    begin
        PostingDate := NewPostingDate;
        CalcBasedOn := NewCalcBasedOn;
    end;

    local procedure CreateConsumpJnlLine(LocationCode: Code[10];BinCode: Code[20];QtyToPost: Decimal)
    var
        Location: Record Location;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
    begin
        OnBeforeCreateConsumpJnlLine(LocationCode,BinCode,QtyToPost);

        Window.Update(3,QtyToPost);

        if Location.Get(LocationCode) and Location."Require Pick" and Location."Require Shipment" then
          "Prod. Order Component".AdjustQtyToQtyPicked(QtyToPost);

        if (ItemJnlLine."Item No." = "Prod. Order Component"."Item No.") and
           (LocationCode = ItemJnlLine."Location Code") and
           (BinCode = ItemJnlLine."Bin Code")
        then begin
          if Item."Rounding Precision" > 0 then
            ItemJnlLine.Validate(Quantity,ItemJnlLine.Quantity + Round(QtyToPost,Item."Rounding Precision",'>'))
          else
            ItemJnlLine.Validate(Quantity,ItemJnlLine.Quantity + Round(QtyToPost,0.00001));
          ItemJnlLine.Modify;
        end else begin
          ItemJnlLine.Init;
          ItemJnlLine."Journal Template Name" := ToTemplateName;
          ItemJnlLine."Journal Batch Name" := ToBatchName;
          ItemJnlLine.SetUpNewLine(LastItemJnlLine);
          ItemJnlLine."Line No." := NextConsumpJnlLineNo;

          ItemJnlLine.Validate("Entry Type",ItemJnlLine."Entry Type"::Consumption);
          ItemJnlLine.Validate("Order Type",ItemJnlLine."Order Type"::Production);
          ItemJnlLine.Validate("Order No.","Prod. Order Component"."Prod. Order No.");
          ItemJnlLine.Validate("Source No.",ProdOrderLine."Item No.");
          ItemJnlLine.Validate("Posting Date",PostingDate);
          ItemJnlLine.Validate("Item No.","Prod. Order Component"."Item No.");
          ItemJnlLine.Validate("Unit of Measure Code","Prod. Order Component"."Unit of Measure Code");
          ItemJnlLine.Description := "Prod. Order Component".Description;
          if Item."Rounding Precision" > 0 then
            ItemJnlLine.Validate(Quantity,Round(QtyToPost,Item."Rounding Precision",'>'))
          else
            ItemJnlLine.Validate(Quantity,Round(QtyToPost,0.00001));
          ItemJnlLine."Variant Code" := "Prod. Order Component"."Variant Code";
          ItemJnlLine.Validate("Location Code",LocationCode);
          if BinCode <> '' then
            ItemJnlLine."Bin Code" := BinCode;
          ItemJnlLine.Validate("Order Line No.","Prod. Order Component"."Prod. Order Line No.");
          ItemJnlLine.Validate("Prod. Order Comp. Line No.","Prod. Order Component"."Line No.");

          ItemJnlLine.Insert;
          OnAfterInsertItemJnlLine(ItemJnlLine);

          if Item."Item Tracking Code" <> '' then
            ItemTrackingMgt.CopyItemTracking("Prod. Order Component".RowID1,ItemJnlLine.RowID1,false);
        end;

        NextConsumpJnlLineNo := NextConsumpJnlLineNo + 10000;

        OnAfterCreateConsumpJnlLine(LocationCode,BinCode,QtyToPost,ItemJnlLine);
    end;

    [Scope('Personalization')]
    procedure SetTemplateAndBatchName(TemplateName: Code[10];BatchName: Code[10])
    begin
        ToTemplateName := TemplateName;
        ToBatchName := BatchName;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertItemJnlLine(var ItemJournalLine: Record "Item Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateConsumpJnlLine(LocationCode: Code[10];BinCode: Code[20];QtyToPost: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateConsumpJnlLine(LocationCode: Code[10];BinCode: Code[20];QtyToPost: Decimal;var ItemJournalLine: Record "Item Journal Line")
    begin
    end;
}

