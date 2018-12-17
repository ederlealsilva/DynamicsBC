report 7315 "Calculate Whse. Adjustment"
{
    // version NAVW113.00

    Caption = 'Calculate Warehouse Adjustment';
    ProcessingOnly = true;

    dataset
    {
        dataitem(Item;Item)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.","Location Filter","Variant Filter";
            dataitem("Integer";"Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number=CONST(1));

                trigger OnAfterGetRecord()
                begin
                    with AdjmtBinQuantityBuffer do begin
                      Location.Reset;
                      Item.CopyFilter("Location Filter",Location.Code);
                      Location.SetRange("Directed Put-away and Pick",true);
                      if Location.FindSet then
                        repeat
                          WhseEntry.SetRange("Location Code",Location.Code);
                          WhseEntry.SetRange("Bin Code",Location."Adjustment Bin Code");
                          if WhseEntry.FindSet then
                            repeat
                              if WhseEntry."Qty. (Base)" <> 0 then begin
                                Reset;
                                SetRange("Item No.",WhseEntry."Item No.");
                                SetRange("Variant Code",WhseEntry."Variant Code");
                                SetRange("Location Code",WhseEntry."Location Code");
                                SetRange("Bin Code",WhseEntry."Bin Code");
                                SetRange("Unit of Measure Code",WhseEntry."Unit of Measure Code");
                                if WhseEntry."Lot No." <> '' then
                                  SetRange("Lot No.",WhseEntry."Lot No.");
                                if WhseEntry."Serial No." <> '' then
                                  SetRange("Serial No.",WhseEntry."Serial No.");
                                if FindSet then begin
                                  "Qty. to Handle (Base)" := "Qty. to Handle (Base)" + WhseEntry."Qty. (Base)";
                                  Modify;
                                end else begin
                                  Init;
                                  "Item No." := WhseEntry."Item No.";
                                  "Variant Code" := WhseEntry."Variant Code";
                                  "Location Code" := WhseEntry."Location Code";
                                  "Bin Code" := WhseEntry."Bin Code";
                                  "Unit of Measure Code" := WhseEntry."Unit of Measure Code";
                                  "Base Unit of Measure" := Item."Base Unit of Measure";
                                  "Lot No." := WhseEntry."Lot No.";
                                  "Serial No." := WhseEntry."Serial No.";
                                  "Qty. to Handle (Base)" := WhseEntry."Qty. (Base)";
                                  "Qty. Outstanding (Base)" := WhseEntry."Qty. (Base)";
                                  Insert;
                                end;
                              end;
                            until WhseEntry.Next = 0;
                        until Location.Next = 0;

                      Reset;
                      ReservEntry.Reset;
                      ReservEntry.SetCurrentKey("Source ID");
                      ItemJnlLine.Reset;
                      ItemJnlLine.SetCurrentKey("Item No.");
                      if FindSet then begin
                        repeat
                          ItemJnlLine.Reset;
                          ItemJnlLine.SetCurrentKey("Item No.");
                          ItemJnlLine.SetRange("Journal Template Name",ItemJnlLine."Journal Template Name");
                          ItemJnlLine.SetRange("Journal Batch Name",ItemJnlLine."Journal Batch Name");
                          ItemJnlLine.SetRange("Item No.","Item No.");
                          ItemJnlLine.SetRange("Location Code","Location Code");
                          ItemJnlLine.SetRange("Unit of Measure Code","Unit of Measure Code");
                          ItemJnlLine.SetRange("Warehouse Adjustment",true);
                          if ItemJnlLine.FindSet then
                            repeat
                              ReservEntry.SetRange("Source Type",DATABASE::"Item Journal Line");
                              ReservEntry.SetRange("Source ID",ItemJnlLine."Journal Template Name");
                              ReservEntry.SetRange("Source Batch Name",ItemJnlLine."Journal Batch Name");
                              ReservEntry.SetRange("Source Ref. No.",ItemJnlLine."Line No.");
                              if "Lot No." <> '' then
                                ReservEntry.SetRange("Lot No.","Lot No.");
                              if "Serial No." <> '' then
                                ReservEntry.SetRange("Serial No.","Serial No.");
                              if ReservEntry.FindSet then
                                repeat
                                  "Qty. to Handle (Base)" += ReservEntry."Qty. to Handle (Base)";
                                  "Qty. Outstanding (Base)" += ReservEntry."Qty. to Handle (Base)";
                                until ReservEntry.Next = 0;
                            until ItemJnlLine.Next = 0;
                        until Next = 0;
                        Modify;
                      end;
                    end;
                end;

                trigger OnPostDataItem()
                var
                    ItemUOM: Record "Item Unit of Measure";
                    QtyInUOM: Decimal;
                begin
                    with AdjmtBinQuantityBuffer do begin
                      Reset;
                      if FindSet then
                        repeat
                          if "Location Code" <> '' then
                            SetRange("Location Code","Location Code");
                          SetRange("Variant Code","Variant Code");
                          SetRange("Unit of Measure Code","Unit of Measure Code");

                          WhseQtyBase := 0;
                          SetFilter("Qty. to Handle (Base)",'>0');
                          if FindSet then begin
                            repeat
                              WhseQtyBase := WhseQtyBase - "Qty. to Handle (Base)";
                            until Next = 0
                          end;

                          ItemUOM.Get("Item No.","Unit of Measure Code");
                          QtyInUOM := Round(WhseQtyBase / ItemUOM."Qty. per Unit of Measure",0.00001);
                          if (QtyInUOM <> 0) and FindFirst then
                            InsertItemJnlLine(
                              "Item No.","Variant Code","Location Code",
                              QtyInUOM,WhseQtyBase,"Unit of Measure Code",1);

                          WhseQtyBase := 0;
                          SetFilter("Qty. to Handle (Base)",'<0');
                          if FindSet then
                            repeat
                              WhseQtyBase := WhseQtyBase - "Qty. to Handle (Base)";
                            until Next = 0;
                          QtyInUOM := Round(WhseQtyBase / ItemUOM."Qty. per Unit of Measure",0.00001);
                          if (QtyInUOM <> 0) and FindFirst then
                            InsertItemJnlLine(
                              "Item No.","Variant Code","Location Code",
                              QtyInUOM,WhseQtyBase,"Unit of Measure Code",0);

                          WhseQtyBase := 0;
                          SetRange("Qty. to Handle (Base)");
                          if FindSet then
                            repeat
                              WhseQtyBase := WhseQtyBase - "Qty. to Handle (Base)";
                            until Next = 0;
                          QtyInUOM := Round(WhseQtyBase / ItemUOM."Qty. per Unit of Measure",0.00001);
                          if ((QtyInUOM = 0) and (WhseQtyBase < 0)) and FindFirst then
                            InsertItemJnlLine(
                              "Item No.","Variant Code","Location Code",
                              WhseQtyBase,WhseQtyBase,"Base Unit of Measure",1);

                          FindLast;
                          SetRange("Location Code");
                          SetRange("Variant Code");
                          SetRange("Unit of Measure Code");
                        until Next = 0;
                      Reset;
                      DeleteAll;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    Clear(Location);
                    WhseEntry.Reset;
                    WhseEntry.SetCurrentKey("Item No.","Bin Code","Location Code","Variant Code");
                    WhseEntry.SetRange("Item No.",Item."No.");
                    Item.CopyFilter("Variant Filter",WhseEntry."Variant Code");
                    Item.CopyFilter("Lot No. Filter",WhseEntry."Lot No.");
                    Item.CopyFilter("Serial No. Filter",WhseEntry."Serial No.");

                    if not WhseEntry.Find('-') then
                      CurrReport.Break;

                    AdjmtBinQuantityBuffer.Reset;
                    AdjmtBinQuantityBuffer.DeleteAll;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if not HideValidationDialog then
                  Window.Update;
            end;

            trigger OnPostDataItem()
            begin
                if not HideValidationDialog then
                  Window.Close;
            end;

            trigger OnPreDataItem()
            var
                ItemJnlTemplate: Record "Item Journal Template";
                ItemJnlBatch: Record "Item Journal Batch";
            begin
                if PostingDate = 0D then
                  Error(Text000);

                ItemJnlTemplate.Get(ItemJnlLine."Journal Template Name");
                ItemJnlBatch.Get(ItemJnlLine."Journal Template Name",ItemJnlLine."Journal Batch Name");
                if NextDocNo = '' then begin
                  if ItemJnlBatch."No. Series" <> '' then begin
                    ItemJnlLine.SetRange("Journal Template Name",ItemJnlLine."Journal Template Name");
                    ItemJnlLine.SetRange("Journal Batch Name",ItemJnlLine."Journal Batch Name");
                    if not ItemJnlLine.Find('-') then
                      NextDocNo := NoSeriesMgt.GetNextNo(ItemJnlBatch."No. Series",PostingDate,false);
                    ItemJnlLine.Init;
                  end;
                  if NextDocNo = '' then
                    Error(Text001);
                end;

                NextLineNo := 0;

                if not HideValidationDialog then
                  Window.Open(Text002,"No.");
            end;
        }
    }

    requestpage
    {
        Caption = 'Calculate Inventory';
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(PostingDate;PostingDate)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Posting Date';
                        ToolTip = 'Specifies the date for the posting of this batch job. The program automatically enters the work date in this field, but you can change it.';

                        trigger OnValidate()
                        begin
                            ValidatePostingDate;
                        end;
                    }
                    field(NextDocNo;NextDocNo)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Document No.';
                        ToolTip = 'Specifies a manually entered document number that will be entered in the Document No. field, on the journal lines created by the batch job.';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            if PostingDate = 0D then
              PostingDate := WorkDate;
            ValidatePostingDate;
        end;
    }

    labels
    {
    }

    var
        Text000: Label 'Enter the posting date.';
        Text001: Label 'Enter the document no.';
        Text002: Label 'Processing items    #1##########';
        ItemJnlBatch: Record "Item Journal Batch";
        ItemJnlLine: Record "Item Journal Line";
        WhseEntry: Record "Warehouse Entry";
        Location: Record Location;
        SourceCodeSetup: Record "Source Code Setup";
        AdjmtBinQuantityBuffer: Record "Bin Content Buffer" temporary;
        ReservEntry: Record "Reservation Entry";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Window: Dialog;
        PostingDate: Date;
        NextDocNo: Code[20];
        WhseQtyBase: Decimal;
        NextLineNo: Integer;
        HideValidationDialog: Boolean;

    [Scope('Personalization')]
    procedure SetItemJnlLine(var NewItemJnlLine: Record "Item Journal Line")
    begin
        ItemJnlLine := NewItemJnlLine;
    end;

    local procedure ValidatePostingDate()
    begin
        ItemJnlBatch.Get(ItemJnlLine."Journal Template Name",ItemJnlLine."Journal Batch Name");
        if ItemJnlBatch."No. Series" = '' then
          NextDocNo := ''
        else begin
          NextDocNo := NoSeriesMgt.GetNextNo(ItemJnlBatch."No. Series",PostingDate,false);
          Clear(NoSeriesMgt);
        end;
    end;

    local procedure InsertItemJnlLine(ItemNo: Code[20];VariantCode2: Code[10];LocationCode2: Code[10];Quantity2: Decimal;QuantityBase2: Decimal;UOM2: Code[10];EntryType2: Option "Negative Adjmt.","Positive Adjmt.")
    var
        Location: Record Location;
        WhseEntry2: Record "Warehouse Entry";
        WhseEntry3: Record "Warehouse Entry";
        ReservEntry: Record "Reservation Entry";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        OrderLineNo: Integer;
    begin
        OnBeforeFunctionInsertItemJnlLine(ItemNo,VariantCode2,LocationCode2,Quantity2,QuantityBase2,UOM2,EntryType2);

        with ItemJnlLine do begin
          if NextLineNo = 0 then begin
            LockTable;
            Reset;
            SetRange("Journal Template Name","Journal Template Name");
            SetRange("Journal Batch Name","Journal Batch Name");
            if Find('+') then
              NextLineNo := "Line No.";

            SourceCodeSetup.Get;
          end;
          NextLineNo := NextLineNo + 10000;

          if QuantityBase2 <> 0 then begin
            Init;
            "Line No." := NextLineNo;
            Validate("Posting Date",PostingDate);
            if QuantityBase2 > 0 then
              Validate("Entry Type","Entry Type"::"Positive Adjmt.")
            else begin
              Validate("Entry Type","Entry Type"::"Negative Adjmt.");
              Quantity2 := -Quantity2;
              QuantityBase2 := -QuantityBase2;
            end;
            Validate("Document No.",NextDocNo);
            Validate("Item No.",ItemNo);
            Validate("Variant Code",VariantCode2);
            Validate("Location Code",LocationCode2);
            Validate("Source Code",SourceCodeSetup."Item Journal");
            Validate("Unit of Measure Code",UOM2);
            if LocationCode2 <> '' then
              Location.Get(LocationCode2);
            "Posting No. Series" := ItemJnlBatch."Posting No. Series";

            Validate(Quantity,Quantity2);
            "Quantity (Base)" := QuantityBase2;
            "Invoiced Qty. (Base)" := QuantityBase2;
            "Warehouse Adjustment" := true;
            Insert(true);
            OnAfterInsertItemJnlLine(ItemJnlLine);

            if Location.Code <> '' then
              if Location."Directed Put-away and Pick" then begin
                WhseEntry2.SetCurrentKey(
                  "Item No.","Bin Code","Location Code","Variant Code","Unit of Measure Code",
                  "Lot No.","Serial No.","Entry Type");
                WhseEntry2.SetRange("Item No.","Item No.");
                WhseEntry2.SetRange("Bin Code",Location."Adjustment Bin Code");
                WhseEntry2.SetRange("Location Code","Location Code");
                WhseEntry2.SetRange("Variant Code","Variant Code");
                WhseEntry2.SetRange("Unit of Measure Code",UOM2);
                WhseEntry2.SetFilter("Lot No.",Item.GetFilter("Lot No. Filter"));
                WhseEntry2.SetFilter("Serial No.",Item.GetFilter("Serial No. Filter"));
                WhseEntry2.SetFilter("Entry Type",'%1|%2',EntryType2,WhseEntry2."Entry Type"::Movement);
                if WhseEntry2.Find('-') then
                  repeat
                    WhseEntry2.SetRange("Lot No.",WhseEntry2."Lot No.");
                    WhseEntry2.SetRange("Serial No.",WhseEntry2."Serial No.");
                    WhseEntry2.CalcSums("Qty. (Base)");

                    WhseEntry3.SetCurrentKey(
                      "Item No.","Bin Code","Location Code","Variant Code","Unit of Measure Code",
                      "Lot No.","Serial No.","Entry Type");
                    WhseEntry3.CopyFilters(WhseEntry2);
                    case EntryType2 of
                      EntryType2::"Positive Adjmt.":
                        WhseEntry3.SetRange("Entry Type",WhseEntry3."Entry Type"::"Negative Adjmt.");
                      EntryType2::"Negative Adjmt.":
                        WhseEntry3.SetRange("Entry Type",WhseEntry3."Entry Type"::"Positive Adjmt.");
                    end;
                    WhseEntry3.CalcSums("Qty. (Base)");
                    if Abs(WhseEntry3."Qty. (Base)") > Abs(WhseEntry2."Qty. (Base)") then
                      WhseEntry2."Qty. (Base)" := 0
                    else
                      WhseEntry2."Qty. (Base)" := WhseEntry2."Qty. (Base)" + WhseEntry3."Qty. (Base)";

                    if WhseEntry2."Qty. (Base)" <> 0 then begin
                      if "Order Type" = "Order Type"::Production then
                        OrderLineNo := "Order Line No.";
                      CreateReservEntry.CreateReservEntryFor(
                        DATABASE::"Item Journal Line",
                        "Entry Type",
                        "Journal Template Name",
                        "Journal Batch Name",
                        OrderLineNo,
                        "Line No.",
                        "Qty. per Unit of Measure",
                        Abs(WhseEntry2.Quantity),
                        Abs(WhseEntry2."Qty. (Base)"),
                        WhseEntry2."Serial No.",
                        WhseEntry2."Lot No.");
                      if WhseEntry2."Qty. (Base)" < 0 then             // Only Date on positive adjustments
                        CreateReservEntry.SetDates(WhseEntry2."Warranty Date",WhseEntry2."Expiration Date");
                      CreateReservEntry.CreateEntry(
                        "Item No.",
                        "Variant Code",
                        "Location Code",
                        Description,
                        0D,
                        0D,
                        0,
                        ReservEntry."Reservation Status"::Prospect);
                    end;
                    WhseEntry2.Find('+');
                    WhseEntry2.SetFilter("Lot No.",Item.GetFilter("Lot No. Filter"));
                    WhseEntry2.SetFilter("Serial No.",Item.GetFilter("Serial No. Filter"));
                  until WhseEntry2.Next = 0;
              end;
          end;
        end;
        OnAfterFunctionInsertItemJnlLine(ItemNo,VariantCode2,LocationCode2,Quantity2,QuantityBase2,UOM2,EntryType2,ItemJnlLine);
    end;

    [Scope('Personalization')]
    procedure InitializeRequest(NewPostingDate: Date;DocNo: Code[20])
    begin
        PostingDate := NewPostingDate;
        NextDocNo := DocNo;
    end;

    [Scope('Personalization')]
    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFunctionInsertItemJnlLine(ItemNo: Code[20];VariantCode2: Code[10];LocationCode2: Code[10];Quantity2: Decimal;QuantityBase2: Decimal;UOM2: Code[10];EntryType2: Option "Negative Adjmt.","Positive Adjmt.")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertItemJnlLine(var ItemJournalLine: Record "Item Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFunctionInsertItemJnlLine(ItemNo: Code[20];VariantCode2: Code[10];LocationCode2: Code[10];Quantity2: Decimal;QuantityBase2: Decimal;UOM2: Code[10];EntryType2: Option "Negative Adjmt.","Positive Adjmt.";var ItemJournalLine: Record "Item Journal Line")
    begin
    end;
}

