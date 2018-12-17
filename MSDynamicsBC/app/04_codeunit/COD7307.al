codeunit 7307 "Whse.-Activity-Register"
{
    // version NAVW113.00

    Permissions = TableData "Registered Whse. Activity Hdr."=i,
                  TableData "Registered Whse. Activity Line"=i,
                  TableData "Whse. Item Tracking Line"=rim,
                  TableData "Warehouse Journal Batch"=imd,
                  TableData "Posted Whse. Receipt Header"=m,
                  TableData "Posted Whse. Receipt Line"=m,
                  TableData "Registered Invt. Movement Hdr."=i,
                  TableData "Registered Invt. Movement Line"=i;
    TableNo = "Warehouse Activity Line";

    trigger OnRun()
    begin
        WhseActivLine.Copy(Rec);
        WhseActivLine.SetAutoCalcFields;
        Code;
        Rec := WhseActivLine;
    end;

    var
        Text000: Label 'Warehouse Activity    #1##########\\';
        Text001: Label 'Checking lines        #2######\';
        Text002: Label 'Registering lines     #3###### @4@@@@@@@@@@@@@';
        Location: Record Location;
        Item: Record Item;
        WhseActivHeader: Record "Warehouse Activity Header";
        WhseActivLine: Record "Warehouse Activity Line";
        RegisteredWhseActivHeader: Record "Registered Whse. Activity Hdr.";
        RegisteredWhseActivLine: Record "Registered Whse. Activity Line";
        RegisteredInvtMovementHdr: Record "Registered Invt. Movement Hdr.";
        RegisteredInvtMovementLine: Record "Registered Invt. Movement Line";
        WhseShptHeader: Record "Warehouse Shipment Header";
        PostedWhseRcptHeader: Record "Posted Whse. Receipt Header";
        WhseInternalPickHeader: Record "Whse. Internal Pick Header";
        WhseInternalPutAwayHeader: Record "Whse. Internal Put-away Header";
        WhseShptLine: Record "Warehouse Shipment Line";
        PostedWhseRcptLine: Record "Posted Whse. Receipt Line";
        WhseInternalPickLine: Record "Whse. Internal Pick Line";
        WhseInternalPutAwayLine: Record "Whse. Internal Put-away Line";
        ProdCompLine: Record "Prod. Order Component";
        AssemblyLine: Record "Assembly Line";
        ProdOrder: Record "Production Order";
        AssemblyHeader: Record "Assembly Header";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        TempBinContentBuffer: Record "Bin Content Buffer" temporary;
        SourceCodeSetup: Record "Source Code Setup";
        Cust: Record Customer;
        TempTrackingSpecification: Record "Tracking Specification" temporary;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        WhseJnlRegisterLine: Codeunit "Whse. Jnl.-Register Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Window: Dialog;
        NoOfRecords: Integer;
        LineCount: Integer;
        HideDialog: Boolean;
        Text003: Label 'There is nothing to register.';
        Text004: Label 'Item tracking defined for the source line accounts for more than the quantity you have entered.\You must adjust the existing item tracking and then reenter the new quantity.';
        Text005: Label '%1 %2 is not available on inventory or it has already been reserved for another document.';
        OrderToOrderBindingOnSalesLineQst: Label 'Registering the pick will remove the existing order-to-order reservation for the sales order.\Do you want to continue?';
        RegisterInterruptedErr: Label 'The action has been interrupted to respect the warning.';

    local procedure "Code"()
    var
        OldWhseActivLine: Record "Warehouse Activity Line";
        TempWhseActivLineToReserve: Record "Warehouse Activity Line" temporary;
        QtyDiff: Decimal;
        QtyBaseDiff: Decimal;
        LastLine: Boolean;
    begin
        OnBeforeCode(WhseActivLine);

        with WhseActivHeader do begin
          WhseActivLine.SetRange("Activity Type",WhseActivLine."Activity Type");
          WhseActivLine.SetRange("No.",WhseActivLine."No.");
          WhseActivLine.SetFilter("Qty. to Handle (Base)",'<>0');
          if WhseActivLine.IsEmpty then
            Error(Text003);
          CheckWhseItemTrkgLine(WhseActivLine);

          Get(WhseActivLine."Activity Type",WhseActivLine."No.");
          LocationGet("Location Code");

          UpdateWindow(1,"No.");

          // Check Lines
          CheckLines;

          // Register lines
          SourceCodeSetup.Get;
          LineCount := 0;
          WhseActivLine.LockTable;
          if WhseActivLine.Find('-') then begin
            CreateRegActivHeader(WhseActivHeader);
            repeat
              LineCount := LineCount + 1;
              UpdateWindow(3,'');
              UpdateWindow(4,'');
              if Location."Bin Mandatory" then
                RegisterWhseJnlLine(WhseActivLine);
              CreateRegActivLine(WhseActivLine);
              OnAfterCreateRegActivLine(WhseActivLine,RegisteredWhseActivLine,RegisteredInvtMovementLine);
            until WhseActivLine.Next = 0;
          end;

          TempWhseActivLineToReserve.DeleteAll;
          WhseActivLine.SetCurrentKey(
            "Activity Type","No.","Whse. Document Type","Whse. Document No.");
          if WhseActivLine.Find('-') then
            repeat
              CopyWhseActivityLineToReservBuf(TempWhseActivLineToReserve,WhseActivLine);
              if Type <> Type::Movement then
                UpdateWhseSourceDocLine(WhseActivLine);
              OnAfterFindWhseActivLine(WhseActivLine);
              if WhseActivLine."Qty. Outstanding" = WhseActivLine."Qty. to Handle" then begin
                OnBeforeWhseActivLineDelete(WhseActivLine);
                WhseActivLine.Delete
              end else begin
                QtyDiff := WhseActivLine."Qty. Outstanding" - WhseActivLine."Qty. to Handle";
                QtyBaseDiff := WhseActivLine."Qty. Outstanding (Base)" - WhseActivLine."Qty. to Handle (Base)";
                WhseActivLine.Validate("Qty. Outstanding",QtyDiff);
                if WhseActivLine."Qty. Outstanding (Base)" > QtyBaseDiff then // round off error- qty same, not base qty
                  WhseActivLine."Qty. Outstanding (Base)" := QtyBaseDiff;
                WhseActivLine.Validate("Qty. to Handle",QtyDiff);
                if WhseActivLine."Qty. to Handle (Base)" > QtyBaseDiff then // round off error- qty same, not base qty
                  WhseActivLine."Qty. to Handle (Base)" := QtyBaseDiff;
                if HideDialog then
                  WhseActivLine.Validate("Qty. to Handle",0);
                WhseActivLine.Validate(
                  "Qty. Handled",WhseActivLine.Quantity - WhseActivLine."Qty. Outstanding");
                WhseActivLine.Modify;
              end;

              OldWhseActivLine := WhseActivLine;
              LastLine := WhseActivLine.Next = 0;

              if LastLine or
                 (OldWhseActivLine."Whse. Document Type" <> WhseActivLine."Whse. Document Type") or
                 (OldWhseActivLine."Whse. Document No." <> WhseActivLine."Whse. Document No.") or
                 (OldWhseActivLine."Action Type" <> WhseActivLine."Action Type")
              then
                UpdateWhseDocHeader(OldWhseActivLine);

              OldWhseActivLine.DeleteBinContent(OldWhseActivLine."Action Type"::Take);
            until LastLine;

          CheckAndRemoveOrderToOrderBinding(TempWhseActivLineToReserve);
          ItemTrackingMgt.SetPick(OldWhseActivLine."Activity Type" = OldWhseActivLine."Activity Type"::Pick);
          ItemTrackingMgt.SynchronizeWhseItemTracking(TempTrackingSpecification,RegisteredWhseActivLine."No.",false);
          AutoReserveForSalesLine(TempWhseActivLineToReserve);

          if Location."Bin Mandatory" then begin
            LineCount := 0;
            Clear(OldWhseActivLine);
            WhseActivLine.Reset;
            WhseActivLine.SetCurrentKey(
              "Activity Type","No.","Whse. Document Type","Whse. Document No.");
            WhseActivLine.SetRange("Activity Type",Type);
            WhseActivLine.SetRange("No.","No.");
            if WhseActivLine.Find('-') then
              repeat
                if ((LineCount = 1) and
                    ((OldWhseActivLine."Whse. Document Type" <> WhseActivLine."Whse. Document Type") or
                     (OldWhseActivLine."Whse. Document No." <> WhseActivLine."Whse. Document No.")))
                then begin
                  LineCount := 0;
                  OldWhseActivLine.Delete;
                end;
                OldWhseActivLine := WhseActivLine;
                LineCount := LineCount + 1;
              until WhseActivLine.Next = 0;
            if LineCount = 1 then
              OldWhseActivLine.Delete;
          end;
          OnBeforeUpdWhseActivHeader(WhseActivHeader);
          WhseActivLine.Reset;
          WhseActivLine.SetRange("Activity Type",Type);
          WhseActivLine.SetRange("No.","No.");
          WhseActivLine.SetFilter("Qty. Outstanding",'<>%1',0);
          if not WhseActivLine.Find('-') then
            Delete(true)
          else begin
            "Last Registering No." := "Registering No.";
            "Registering No." := '';
            Modify;
            if not HideDialog then
              WhseActivLine.AutofillQtyToHandle(WhseActivLine);
            OnAfterAutofillQtyToHandle(WhseActivLine);
          end;
          if not HideDialog then
            Window.Close;
          Commit;
          Clear(WhseJnlRegisterLine);
        end;

        OnAfterRegisterWhseActivity(WhseActivHeader);
    end;

    local procedure RegisterWhseJnlLine(WhseActivLine: Record "Warehouse Activity Line")
    var
        WhseJnlLine: Record "Warehouse Journal Line";
        WMSMgt: Codeunit "WMS Management";
    begin
        with WhseActivLine do begin
          WhseJnlLine.Init;
          WhseJnlLine."Location Code" := "Location Code";
          WhseJnlLine."Item No." := "Item No.";
          WhseJnlLine."Registering Date" := WorkDate;
          WhseJnlLine."User ID" := UserId;
          WhseJnlLine."Variant Code" := "Variant Code";
          WhseJnlLine."Entry Type" := WhseJnlLine."Entry Type"::Movement;
          if "Action Type" = "Action Type"::Take then begin
            WhseJnlLine."From Zone Code" := "Zone Code";
            WhseJnlLine."From Bin Code" := "Bin Code";
          end else begin
            WhseJnlLine."To Zone Code" := "Zone Code";
            WhseJnlLine."To Bin Code" := "Bin Code";
          end;
          WhseJnlLine.Description := Description;

          LocationGet("Location Code");
          if Location."Directed Put-away and Pick" then begin
            WhseJnlLine.Quantity := "Qty. to Handle";
            WhseJnlLine."Unit of Measure Code" := "Unit of Measure Code";
            WhseJnlLine."Qty. per Unit of Measure" := "Qty. per Unit of Measure";
            GetItemUnitOfMeasure("Item No.","Unit of Measure Code");
            WhseJnlLine.Cubage :=
              Abs(WhseJnlLine.Quantity) * ItemUnitOfMeasure.Cubage;
            WhseJnlLine.Weight :=
              Abs(WhseJnlLine.Quantity) * ItemUnitOfMeasure.Weight;
          end else begin
            WhseJnlLine.Quantity := "Qty. to Handle (Base)";
            WhseJnlLine."Unit of Measure Code" := WMSMgt.GetBaseUOM("Item No.");
            WhseJnlLine."Qty. per Unit of Measure" := 1;
          end;
          WhseJnlLine."Qty. (Base)" := "Qty. to Handle (Base)";
          WhseJnlLine."Qty. (Absolute)" := WhseJnlLine.Quantity;
          WhseJnlLine."Qty. (Absolute, Base)" := "Qty. to Handle (Base)";

          WhseJnlLine.SetSource("Source Type","Source Subtype","Source No.","Source Line No.","Source Subline No.");
          WhseJnlLine."Source Document" := "Source Document";
          WhseJnlLine."Reference No." := RegisteredWhseActivHeader."No.";
          case "Activity Type" of
            "Activity Type"::"Put-away":
              begin
                WhseJnlLine."Source Code" := SourceCodeSetup."Whse. Put-away";
                WhseJnlLine.SetWhseDoc("Whse. Document Type","Whse. Document No.","Whse. Document Line No.");
                WhseJnlLine."Reference Document" := WhseJnlLine."Reference Document"::"Put-away";
              end;
            "Activity Type"::Pick:
              begin
                WhseJnlLine."Source Code" := SourceCodeSetup."Whse. Pick";
                WhseJnlLine.SetWhseDoc("Whse. Document Type","Whse. Document No.","Whse. Document Line No.");
                WhseJnlLine."Reference Document" := WhseJnlLine."Reference Document"::Pick;
              end;
            "Activity Type"::Movement:
              begin
                WhseJnlLine."Source Code" := SourceCodeSetup."Whse. Movement";
                WhseJnlLine."Whse. Document Type" := WhseJnlLine."Whse. Document Type"::" ";
                WhseJnlLine."Reference Document" := WhseJnlLine."Reference Document"::Movement;
              end;
            "Activity Type"::"Invt. Put-away",
            "Activity Type"::"Invt. Pick",
            "Activity Type"::"Invt. Movement":
              WhseJnlLine."Whse. Document Type" := WhseJnlLine."Whse. Document Type"::" ";
          end;
          if "Serial No." <> '' then
            TestField("Qty. per Unit of Measure",1);
          WhseJnlLine.SetTracking("Serial No.","Lot No.","Warranty Date","Expiration Date");
          WhseJnlRegisterLine.Run(WhseJnlLine);
        end;
    end;

    local procedure CreateRegActivHeader(WhseActivHeader: Record "Warehouse Activity Header")
    var
        WhseCommentLine: Record "Warehouse Comment Line";
        WhseCommentLine2: Record "Warehouse Comment Line";
        TableNameFrom: Option;
        TableNameTo: Option;
        RegisteredType: Option;
        RegisteredNo: Code[20];
        IsHandled: Boolean;
    begin
        OnBeforeCreateRegActivHeader(WhseActivHeader,IsHandled,RegisteredWhseActivHeader);
        if IsHandled then
          exit;

        TableNameFrom := WhseCommentLine."Table Name"::"Whse. Activity Header";
        if WhseActivHeader.Type = WhseActivHeader.Type::"Invt. Movement" then begin
          RegisteredInvtMovementHdr.Init;
          RegisteredInvtMovementHdr.TransferFields(WhseActivHeader);
          RegisteredInvtMovementHdr."No." := WhseActivHeader."Registering No.";
          RegisteredInvtMovementHdr."Invt. Movement No." := WhseActivHeader."No.";
          RegisteredInvtMovementHdr.Insert;

          TableNameTo := WhseCommentLine."Table Name"::"Registered Invt. Movement";
          RegisteredType := 0;
          RegisteredNo := RegisteredInvtMovementHdr."No.";
        end else begin
          RegisteredWhseActivHeader.Init;
          RegisteredWhseActivHeader.TransferFields(WhseActivHeader);
          RegisteredWhseActivHeader.Type := WhseActivHeader.Type;
          RegisteredWhseActivHeader."No." := WhseActivHeader."Registering No.";
          RegisteredWhseActivHeader."Whse. Activity No." := WhseActivHeader."No.";
          RegisteredWhseActivHeader."Registering Date" := WorkDate;
          RegisteredWhseActivHeader."No. Series" := WhseActivHeader."Registering No. Series";
          RegisteredWhseActivHeader.Insert;

          TableNameTo := WhseCommentLine2."Table Name"::"Rgstrd. Whse. Activity Header";
          RegisteredType := RegisteredWhseActivHeader.Type;
          RegisteredNo := RegisteredWhseActivHeader."No.";
        end;

        WhseCommentLine.SetRange("Table Name",TableNameFrom);
        WhseCommentLine.SetRange(Type,WhseActivHeader.Type);
        WhseCommentLine.SetRange("No.",WhseActivHeader."No.");
        WhseCommentLine.LockTable;

        if WhseCommentLine.Find('-') then
          repeat
            WhseCommentLine2.Init;
            WhseCommentLine2 := WhseCommentLine;
            WhseCommentLine2."Table Name" := TableNameTo;
            WhseCommentLine2.Type := RegisteredType;
            WhseCommentLine2."No." := RegisteredNo;
            WhseCommentLine2.Insert;
          until WhseCommentLine.Next = 0;
    end;

    local procedure CreateRegActivLine(WhseActivLine: Record "Warehouse Activity Line")
    begin
        if WhseActivLine."Activity Type" = WhseActivLine."Activity Type"::"Invt. Movement" then begin
          RegisteredInvtMovementLine.Init;
          RegisteredInvtMovementLine.TransferFields(WhseActivLine);
          RegisteredInvtMovementLine."No." := RegisteredInvtMovementHdr."No.";
          RegisteredInvtMovementLine.Validate(Quantity,WhseActivLine."Qty. to Handle");
          RegisteredInvtMovementLine.Insert;
        end else begin
          RegisteredWhseActivLine.Init;
          RegisteredWhseActivLine.TransferFields(WhseActivLine);
          RegisteredWhseActivLine."Activity Type" := RegisteredWhseActivHeader.Type;
          RegisteredWhseActivLine."No." := RegisteredWhseActivHeader."No.";
          OnAfterInitRegActLine(WhseActivLine,RegisteredWhseActivLine);
          RegisteredWhseActivLine.Quantity := WhseActivLine."Qty. to Handle";
          RegisteredWhseActivLine."Qty. (Base)" := WhseActivLine."Qty. to Handle (Base)";
          RegisteredWhseActivLine.Insert;
        end;
    end;

    local procedure UpdateWhseSourceDocLine(WhseActivLine: Record "Warehouse Activity Line")
    var
        WhseDocType2: Option;
    begin
        with WhseActivLine do begin
          if "Original Breakbulk" then
            exit;
          if ("Whse. Document Type" = "Whse. Document Type"::Shipment) and "Assemble to Order" then
            WhseDocType2 := "Whse. Document Type"::Assembly
          else
            WhseDocType2 := "Whse. Document Type";
          case WhseDocType2 of
            "Whse. Document Type"::Shipment:
              if ("Action Type" <> "Action Type"::Take) and ("Breakbulk No." = 0) then begin
                UpdateWhseShptLine(
                  "Whse. Document No.","Whse. Document Line No.",
                  "Qty. to Handle","Qty. to Handle (Base)","Qty. per Unit of Measure");
                RegisterWhseItemTrkgLine(WhseActivLine);
              end;
            "Whse. Document Type"::"Internal Pick":
              if ("Action Type" <> "Action Type"::Take) and ("Breakbulk No." = 0) then begin
                UpdateWhseIntPickLine(
                  "Whse. Document No.","Whse. Document Line No.",
                  "Qty. to Handle","Qty. to Handle (Base)","Qty. per Unit of Measure");
                RegisterWhseItemTrkgLine(WhseActivLine);
              end;
            "Whse. Document Type"::Production:
              if ("Action Type" <> "Action Type"::Take) and ("Breakbulk No." = 0) then begin
                UpdateProdCompLine(
                  "Source Subtype","Source No.","Source Line No.","Source Subline No.",
                  "Qty. to Handle","Qty. to Handle (Base)","Qty. per Unit of Measure");
                RegisterWhseItemTrkgLine(WhseActivLine);
              end;
            "Whse. Document Type"::Assembly:
              if ("Action Type" <> "Action Type"::Take) and ("Breakbulk No." = 0) then begin
                UpdateAssemblyLine(
                  "Source Subtype","Source No.","Source Line No.",
                  "Qty. to Handle","Qty. to Handle (Base)","Qty. per Unit of Measure");
                RegisterWhseItemTrkgLine(WhseActivLine);
              end;
            "Whse. Document Type"::Receipt:
              if "Action Type" <> "Action Type"::Place then begin
                UpdatePostedWhseRcptLine(
                  "Whse. Document No.","Whse. Document Line No.",
                  "Qty. to Handle","Qty. to Handle (Base)","Qty. per Unit of Measure");
                RegisterWhseItemTrkgLine(WhseActivLine);
              end;
            "Whse. Document Type"::"Internal Put-away":
              if "Action Type" <> "Action Type"::Take then begin
                UpdateWhseIntPutAwayLine(
                  "Whse. Document No.","Whse. Document Line No.",
                  "Qty. to Handle","Qty. to Handle (Base)","Qty. per Unit of Measure");
                RegisterWhseItemTrkgLine(WhseActivLine);
              end;
          end;
        end;

        if WhseActivLine."Activity Type" = WhseActivLine."Activity Type"::"Invt. Movement" then
          UpdateSourceDocForInvtMovement(WhseActivLine);
    end;

    local procedure UpdateWhseDocHeader(WhseActivLine: Record "Warehouse Activity Line")
    var
        WhsePutAwayRqst: Record "Whse. Put-away Request";
        WhsePickRqst: Record "Whse. Pick Request";
    begin
        with WhseActivLine do
          case "Whse. Document Type" of
            "Whse. Document Type"::Shipment:
              if "Action Type" <> "Action Type"::Take then begin
                WhseShptHeader.Get("Whse. Document No.");
                WhseShptHeader.Validate(
                  "Document Status",WhseShptHeader.GetDocumentStatus(0));
                WhseShptHeader.Modify;
              end;
            "Whse. Document Type"::Receipt:
              if "Action Type" <> "Action Type"::Place then begin
                PostedWhseRcptHeader.Get("Whse. Document No.");
                PostedWhseRcptLine.Reset;
                PostedWhseRcptLine.SetRange("No.",PostedWhseRcptHeader."No.");
                if PostedWhseRcptLine.FindFirst then begin
                  PostedWhseRcptHeader."Document Status" := PostedWhseRcptHeader.GetHeaderStatus(0);
                  PostedWhseRcptHeader.Modify;
                end;
                if PostedWhseRcptHeader."Document Status" =
                   PostedWhseRcptHeader."Document Status"::"Completely Put Away"
                then begin
                  WhsePutAwayRqst.SetRange("Document Type",WhsePutAwayRqst."Document Type"::Receipt);
                  WhsePutAwayRqst.SetRange("Document No.",PostedWhseRcptHeader."No.");
                  WhsePutAwayRqst.DeleteAll;
                  ItemTrackingMgt.DeleteWhseItemTrkgLines(
                    DATABASE::"Posted Whse. Receipt Line",0,PostedWhseRcptHeader."No.",'',0,0,'',false);
                end;
              end;
            "Whse. Document Type"::"Internal Pick":
              if "Action Type" <> "Action Type"::Take then begin
                WhseInternalPickHeader.Get("Whse. Document No.");
                WhseInternalPickLine.Reset;
                WhseInternalPickLine.SetRange("No.","Whse. Document No.");
                if WhseInternalPickLine.FindFirst then begin
                  WhseInternalPickHeader."Document Status" :=
                    WhseInternalPickHeader.GetDocumentStatus(0);
                  WhseInternalPickHeader.Modify;
                  if WhseInternalPickHeader."Document Status" =
                     WhseInternalPickHeader."Document Status"::"Completely Picked"
                  then begin
                    WhseInternalPickHeader.DeleteRelatedLines;
                    WhseInternalPickHeader.Delete;
                  end;
                end else begin
                  WhseInternalPickHeader.DeleteRelatedLines;
                  WhseInternalPickHeader.Delete;
                end;
              end;
            "Whse. Document Type"::"Internal Put-away":
              if "Action Type" <> "Action Type"::Take then begin
                WhseInternalPutAwayHeader.Get("Whse. Document No.");
                WhseInternalPutAwayLine.Reset;
                WhseInternalPutAwayLine.SetRange("No.","Whse. Document No.");
                if WhseInternalPutAwayLine.FindFirst then begin
                  WhseInternalPutAwayHeader."Document Status" :=
                    WhseInternalPutAwayHeader.GetDocumentStatus(0);
                  WhseInternalPutAwayHeader.Modify;
                  if WhseInternalPutAwayHeader."Document Status" =
                     WhseInternalPutAwayHeader."Document Status"::"Completely Put Away"
                  then begin
                    WhseInternalPutAwayHeader.DeleteRelatedLines;
                    WhseInternalPutAwayHeader.Delete;
                  end;
                end else begin
                  WhseInternalPutAwayHeader.DeleteRelatedLines;
                  WhseInternalPutAwayHeader.Delete;
                end;
              end;
            "Whse. Document Type"::Production:
              if "Action Type" <> "Action Type"::Take then begin
                ProdOrder.Get("Source Subtype","Source No.");
                ProdOrder.CalcFields("Completely Picked");
                if ProdOrder."Completely Picked" then begin
                  WhsePickRqst.SetRange("Document Type",WhsePickRqst."Document Type"::Production);
                  WhsePickRqst.SetRange("Document No.",ProdOrder."No.");
                  WhsePickRqst.ModifyAll("Completely Picked",true);
                  ItemTrackingMgt.DeleteWhseItemTrkgLines(
                    DATABASE::"Prod. Order Component","Source Subtype","Source No.",'',0,0,'',false);
                end;
              end;
            "Whse. Document Type"::Assembly:
              if "Action Type" <> "Action Type"::Take then begin
                AssemblyHeader.Get("Source Subtype","Source No.");
                if AssemblyHeader.CompletelyPicked then begin
                  WhsePickRqst.SetRange("Document Type",WhsePickRqst."Document Type"::Assembly);
                  WhsePickRqst.SetRange("Document No.",AssemblyHeader."No.");
                  WhsePickRqst.ModifyAll("Completely Picked",true);
                  ItemTrackingMgt.DeleteWhseItemTrkgLines(
                    DATABASE::"Assembly Line","Source Subtype","Source No.",'',0,0,'',false);
                end;
              end;
          end;
    end;

    local procedure UpdateWhseShptLine(WhseDocNo: Code[20];WhseDocLineNo: Integer;QtyToHandle: Decimal;QtyToHandleBase: Decimal;QtyPerUOM: Decimal)
    begin
        WhseShptLine.Get(WhseDocNo,WhseDocLineNo);
        WhseShptLine."Qty. Picked (Base)" :=
          WhseShptLine."Qty. Picked (Base)" + QtyToHandleBase;
        if QtyPerUOM = WhseShptLine."Qty. per Unit of Measure" then
          WhseShptLine."Qty. Picked" := WhseShptLine."Qty. Picked" + QtyToHandle
        else
          WhseShptLine."Qty. Picked" :=
            Round(WhseShptLine."Qty. Picked" + QtyToHandleBase / QtyPerUOM);

        WhseShptLine."Completely Picked" :=
          (WhseShptLine."Qty. Picked" = WhseShptLine.Quantity) or (WhseShptLine."Qty. Picked (Base)" = WhseShptLine."Qty. (Base)");

        // Handle rounding residual when completely picked
        if WhseShptLine."Completely Picked" and (WhseShptLine."Qty. Picked" <> WhseShptLine.Quantity) then
          WhseShptLine."Qty. Picked" := WhseShptLine.Quantity;

        WhseShptLine.Validate("Qty. to Ship",WhseShptLine."Qty. Picked" - WhseShptLine."Qty. Shipped");
        WhseShptLine."Qty. to Ship (Base)" := WhseShptLine."Qty. Picked (Base)" - WhseShptLine."Qty. Shipped (Base)";
        WhseShptLine.Status := WhseShptLine.CalcStatusShptLine;
        WhseShptLine.Modify;
        OnAfterWhseShptLineModify(WhseShptLine);
    end;

    local procedure UpdatePostedWhseRcptLine(WhseDocNo: Code[20];WhseDocLineNo: Integer;QtyToHandle: Decimal;QtyToHandleBase: Decimal;QtyPerUOM: Decimal)
    begin
        PostedWhseRcptHeader.LockTable;
        PostedWhseRcptHeader.Get(WhseDocNo);
        PostedWhseRcptLine.LockTable;
        PostedWhseRcptLine.Get(WhseDocNo,WhseDocLineNo);
        PostedWhseRcptLine."Qty. Put Away (Base)" :=
          PostedWhseRcptLine."Qty. Put Away (Base)" + QtyToHandleBase;
        if QtyPerUOM = PostedWhseRcptLine."Qty. per Unit of Measure" then
          PostedWhseRcptLine."Qty. Put Away" :=
            PostedWhseRcptLine."Qty. Put Away" + QtyToHandle
        else
          PostedWhseRcptLine."Qty. Put Away" :=
            Round(
              PostedWhseRcptLine."Qty. Put Away" +
              QtyToHandleBase / PostedWhseRcptLine."Qty. per Unit of Measure");
        PostedWhseRcptLine.Status := PostedWhseRcptLine.GetLineStatus;
        PostedWhseRcptLine.Modify;
    end;

    local procedure UpdateWhseIntPickLine(WhseDocNo: Code[20];WhseDocLineNo: Integer;QtyToHandle: Decimal;QtyToHandleBase: Decimal;QtyPerUOM: Decimal)
    begin
        WhseInternalPickLine.Get(WhseDocNo,WhseDocLineNo);
        if WhseInternalPickLine."Qty. (Base)" =
           WhseInternalPickLine."Qty. Picked (Base)" + QtyToHandleBase
        then
          WhseInternalPickLine.Delete
        else begin
          WhseInternalPickLine."Qty. Picked (Base)" :=
            WhseInternalPickLine."Qty. Picked (Base)" + QtyToHandleBase;
          if QtyPerUOM = WhseInternalPickLine."Qty. per Unit of Measure" then
            WhseInternalPickLine."Qty. Picked" :=
              WhseInternalPickLine."Qty. Picked" + QtyToHandle
          else
            WhseInternalPickLine."Qty. Picked" :=
              Round(
                WhseInternalPickLine."Qty. Picked" + QtyToHandleBase / QtyPerUOM);
          WhseInternalPickLine.Validate(
            "Qty. Outstanding",WhseInternalPickLine."Qty. Outstanding" - QtyToHandle);
          WhseInternalPickLine.Status := WhseInternalPickLine.CalcStatusPickLine;
          WhseInternalPickLine.Modify;
        end;
    end;

    local procedure UpdateWhseIntPutAwayLine(WhseDocNo: Code[20];WhseDocLineNo: Integer;QtyToHandle: Decimal;QtyToHandleBase: Decimal;QtyPerUOM: Decimal)
    begin
        WhseInternalPutAwayLine.Get(WhseDocNo,WhseDocLineNo);
        if WhseInternalPutAwayLine."Qty. (Base)" =
           WhseInternalPutAwayLine."Qty. Put Away (Base)" + QtyToHandleBase
        then
          WhseInternalPutAwayLine.Delete
        else begin
          WhseInternalPutAwayLine."Qty. Put Away (Base)" :=
            WhseInternalPutAwayLine."Qty. Put Away (Base)" + QtyToHandleBase;
          if QtyPerUOM = WhseInternalPutAwayLine."Qty. per Unit of Measure" then
            WhseInternalPutAwayLine."Qty. Put Away" :=
              WhseInternalPutAwayLine."Qty. Put Away" + QtyToHandle
          else
            WhseInternalPutAwayLine."Qty. Put Away" :=
              Round(
                WhseInternalPutAwayLine."Qty. Put Away" +
                QtyToHandleBase / WhseInternalPutAwayLine."Qty. per Unit of Measure");
          WhseInternalPutAwayLine.Validate(
            "Qty. Outstanding",WhseInternalPutAwayLine."Qty. Outstanding" - QtyToHandle);
          WhseInternalPutAwayLine.Status := WhseInternalPutAwayLine.CalcStatusPutAwayLine;
          WhseInternalPutAwayLine.Modify;
        end;
    end;

    local procedure UpdateProdCompLine(SourceSubType: Option;SourceNo: Code[20];SourceLineNo: Integer;SourceSubLineNo: Integer;QtyToHandle: Decimal;QtyToHandleBase: Decimal;QtyPerUOM: Decimal)
    begin
        ProdCompLine.Get(SourceSubType,SourceNo,SourceLineNo,SourceSubLineNo);
        ProdCompLine."Qty. Picked (Base)" :=
          ProdCompLine."Qty. Picked (Base)" + QtyToHandleBase;
        if QtyPerUOM = ProdCompLine."Qty. per Unit of Measure" then
          ProdCompLine."Qty. Picked" := ProdCompLine."Qty. Picked" + QtyToHandle
        else
          ProdCompLine."Qty. Picked" :=
            Round(ProdCompLine."Qty. Picked" + QtyToHandleBase / QtyPerUOM);
        ProdCompLine."Completely Picked" :=
          ProdCompLine."Qty. Picked" = ProdCompLine."Expected Quantity";
        ProdCompLine.Modify;
    end;

    local procedure UpdateAssemblyLine(SourceSubType: Option;SourceNo: Code[20];SourceLineNo: Integer;QtyToHandle: Decimal;QtyToHandleBase: Decimal;QtyPerUOM: Decimal)
    begin
        AssemblyLine.Get(SourceSubType,SourceNo,SourceLineNo);
        AssemblyLine."Qty. Picked (Base)" :=
          AssemblyLine."Qty. Picked (Base)" + QtyToHandleBase;
        if QtyPerUOM = AssemblyLine."Qty. per Unit of Measure" then
          AssemblyLine."Qty. Picked" := AssemblyLine."Qty. Picked" + QtyToHandle
        else
          AssemblyLine."Qty. Picked" :=
            Round(AssemblyLine."Qty. Picked" + QtyToHandleBase / QtyPerUOM);
        AssemblyLine.Modify;
    end;

    [Scope('Personalization')]
    procedure LocationGet(LocationCode: Code[10])
    begin
        if LocationCode = '' then
          Clear(Location)
        else
          if Location.Code <> LocationCode then
            Location.Get(LocationCode);
    end;

    [Scope('Personalization')]
    procedure GetItemUnitOfMeasure(ItemNo: Code[20];UOMCode: Code[10])
    begin
        if (ItemUnitOfMeasure."Item No." <> ItemNo) or
           (ItemUnitOfMeasure.Code <> UOMCode)
        then
          if not ItemUnitOfMeasure.Get(ItemNo,UOMCode) then
            ItemUnitOfMeasure.Init;
    end;

    local procedure UpdateTempBinContentBuffer(WhseActivLine: Record "Warehouse Activity Line")
    var
        WMSMgt: Codeunit "WMS Management";
        UOMCode: Code[10];
        Sign: Integer;
    begin
        with WhseActivLine do begin
          if Location."Directed Put-away and Pick" then
            UOMCode := "Unit of Measure Code"
          else
            UOMCode := WMSMgt.GetBaseUOM("Item No.");
          if not TempBinContentBuffer.Get("Location Code","Bin Code","Item No.","Variant Code",UOMCode,"Lot No.","Serial No.")
          then begin
            TempBinContentBuffer.Init;
            TempBinContentBuffer."Location Code" := "Location Code";
            TempBinContentBuffer."Zone Code" := "Zone Code";
            TempBinContentBuffer."Bin Code" := "Bin Code";
            TempBinContentBuffer."Item No." := "Item No.";
            TempBinContentBuffer."Variant Code" := "Variant Code";
            TempBinContentBuffer."Unit of Measure Code" := UOMCode;
            TempBinContentBuffer."Lot No." := "Lot No.";
            TempBinContentBuffer."Serial No." := "Serial No.";
            TempBinContentBuffer.Insert;
          end;
          Sign := 1;
          if "Action Type" = "Action Type"::Take then
            Sign := -1;

          TempBinContentBuffer."Base Unit of Measure" := WMSMgt.GetBaseUOM("Item No.");
          TempBinContentBuffer."Qty. to Handle (Base)" := TempBinContentBuffer."Qty. to Handle (Base)" + Sign * "Qty. to Handle (Base)";
          TempBinContentBuffer."Qty. Outstanding (Base)" :=
            TempBinContentBuffer."Qty. Outstanding (Base)" + Sign * "Qty. Outstanding (Base)";
          TempBinContentBuffer.Cubage := TempBinContentBuffer.Cubage + Sign * Cubage;
          TempBinContentBuffer.Weight := TempBinContentBuffer.Weight + Sign * Weight;
          TempBinContentBuffer.Modify;
        end;
    end;

    local procedure CheckBin()
    var
        Bin: Record Bin;
    begin
        with TempBinContentBuffer do begin
          SetFilter("Qty. to Handle (Base)",'>0');
          if Find('-') then
            repeat
              SetRange("Qty. to Handle (Base)");
              SetRange("Bin Code","Bin Code");
              CalcSums(Cubage,Weight);
              Bin.Get("Location Code","Bin Code");
              Bin.CheckIncreaseBin(
                "Bin Code",'',"Qty. to Handle (Base)",Cubage,Weight,Cubage,Weight,true,false);
              SetFilter("Qty. to Handle (Base)",'>0');
              Find('+');
              SetRange("Bin Code");
            until Next = 0;
        end;
    end;

    local procedure CheckBinContent()
    var
        BinContent: Record "Bin Content";
        Bin: Record Bin;
        UOMMgt: Codeunit "Unit of Measure Management";
        BreakBulkQtyBaseToPlace: Decimal;
        AbsQtyToHandle: Decimal;
        AbsQtyToHandleBase: Decimal;
        WhseSNRequired: Boolean;
        WhseLNRequired: Boolean;
    begin
        with TempBinContentBuffer do begin
          SetFilter("Qty. to Handle (Base)",'<>0');
          if Find('-') then
            repeat
              if "Qty. to Handle (Base)" < 0 then begin
                BinContent.Get(
                  "Location Code","Bin Code",
                  "Item No.","Variant Code","Unit of Measure Code");
                ItemTrackingMgt.CheckWhseItemTrkgSetup(BinContent."Item No.",WhseSNRequired,WhseLNRequired,false);

                BinContent.SetRange("Lot No. Filter");
                BinContent.SetRange("Serial No. Filter");
                if WhseLNRequired then
                  BinContent.SetRange("Lot No. Filter","Lot No.");
                if WhseSNRequired then
                  BinContent.SetRange("Serial No. Filter","Serial No.");

                BreakBulkQtyBaseToPlace := CalcBreakBulkQtyToPlace(TempBinContentBuffer);
                GetItem("Item No.");
                AbsQtyToHandleBase := Abs("Qty. to Handle (Base)");
                AbsQtyToHandle := Round(AbsQtyToHandleBase / UOMMgt.GetQtyPerUnitOfMeasure(Item,"Unit of Measure Code"),0.00001);
                if BreakBulkQtyBaseToPlace > 0 then
                  BinContent.CheckDecreaseBinContent(AbsQtyToHandle,AbsQtyToHandleBase,BreakBulkQtyBaseToPlace - "Qty. to Handle (Base)")
                else
                  BinContent.CheckDecreaseBinContent(AbsQtyToHandle,AbsQtyToHandleBase,Abs("Qty. Outstanding (Base)"));
                if AbsQtyToHandleBase <> Abs("Qty. to Handle (Base)") then begin
                  "Qty. to Handle (Base)" := AbsQtyToHandleBase * "Qty. to Handle (Base)" / Abs("Qty. to Handle (Base)");
                  Modify;
                end;
              end else begin
                Bin.Get("Location Code","Bin Code");
                Bin.CheckWhseClass("Item No.",false);
              end;
            until Next = 0;
        end;
    end;

    local procedure CalcBreakBulkQtyToPlace(TempBinContentBuffer: Record "Bin Content Buffer") QtyBase: Decimal
    var
        BreakBulkWhseActivLine: Record "Warehouse Activity Line";
    begin
        with TempBinContentBuffer do begin
          BreakBulkWhseActivLine.SetCurrentKey(
            "Item No.","Bin Code","Location Code","Action Type","Variant Code",
            "Unit of Measure Code","Breakbulk No.","Activity Type","Lot No.","Serial No.");
          BreakBulkWhseActivLine.SetRange("Item No.","Item No.");
          BreakBulkWhseActivLine.SetRange("Bin Code","Bin Code");
          BreakBulkWhseActivLine.SetRange("Location Code","Location Code");
          BreakBulkWhseActivLine.SetRange("Action Type",BreakBulkWhseActivLine."Action Type"::Place);
          BreakBulkWhseActivLine.SetRange("Variant Code","Variant Code");
          BreakBulkWhseActivLine.SetRange("Unit of Measure Code","Unit of Measure Code");
          BreakBulkWhseActivLine.SetFilter("Breakbulk No.",'<>0');
          BreakBulkWhseActivLine.SetRange("Activity Type",WhseActivHeader.Type);
          BreakBulkWhseActivLine.SetRange("No.",WhseActivHeader."No.");
          BreakBulkWhseActivLine.SetTrackingFilter("Serial No.","Lot No.");
          if BreakBulkWhseActivLine.Find('-') then
            repeat
              QtyBase := QtyBase + BreakBulkWhseActivLine."Qty. to Handle (Base)";
            until BreakBulkWhseActivLine.Next = 0;
        end;
        exit(QtyBase);
    end;

    local procedure CheckWhseItemTrkgLine(var WhseActivLine: Record "Warehouse Activity Line")
    var
        TempWhseActivLine: Record "Warehouse Activity Line" temporary;
        QtyAvailToRegisterBase: Decimal;
        QtyAvailToInsertBase: Decimal;
        QtyToRegisterBase: Decimal;
        WhseSNRequired: Boolean;
        WhseLNRequired: Boolean;
    begin
        if not
           ((WhseActivLine."Activity Type" = WhseActivLine."Activity Type"::Pick) or
            (WhseActivLine."Activity Type" = WhseActivLine."Activity Type"::"Invt. Movement"))
        then
          exit;

        if WhseActivLine.Find('-') then
          repeat
            TempWhseActivLine := WhseActivLine;
            if not (TempWhseActivLine."Action Type" = TempWhseActivLine."Action Type"::Place) then
              TempWhseActivLine.Insert;
          until WhseActivLine.Next = 0;

        TempWhseActivLine.SetCurrentKey("Item No.");
        if TempWhseActivLine.Find('-') then
          repeat
            TempWhseActivLine.SetRange("Item No.",TempWhseActivLine."Item No.");
            ItemTrackingMgt.CheckWhseItemTrkgSetup(TempWhseActivLine."Item No.",WhseSNRequired,WhseLNRequired,false);
            if WhseSNRequired or WhseLNRequired then
              repeat
                if WhseSNRequired then begin
                  TempWhseActivLine.TestField("Serial No.");
                  TempWhseActivLine.TestField("Qty. (Base)",1);
                end;
                if WhseLNRequired then
                  TempWhseActivLine.TestField("Lot No.");
              until TempWhseActivLine.Next = 0
            else begin
              TempWhseActivLine.Find('+');
              TempWhseActivLine.DeleteAll;
            end;
            TempWhseActivLine.SetRange("Item No.");
          until TempWhseActivLine.Next = 0;

        TempWhseActivLine.Reset;
        TempWhseActivLine.SetCurrentKey(
          "Source Type","Source Subtype","Source No.","Source Line No.","Source Subline No.");
        TempWhseActivLine.SetRange("Breakbulk No.",0);
        if TempWhseActivLine.Find('-') then
          repeat
            ItemTrackingMgt.CheckWhseItemTrkgSetup(TempWhseActivLine."Item No.",WhseSNRequired,WhseLNRequired,false);
            // Per document
            TempWhseActivLine.SetSourceFilter(
              TempWhseActivLine."Source Type",TempWhseActivLine."Source Subtype",TempWhseActivLine."Source No.",
              TempWhseActivLine."Source Line No.",TempWhseActivLine."Source Subline No.",false);
            repeat
              // Per Lot/SN
              TempWhseActivLine.SetRange("Item No.",TempWhseActivLine."Item No.");
              QtyAvailToInsertBase := CalcQtyAvailToInsertBase(TempWhseActivLine);
              TempWhseActivLine.SetTrackingFilter(TempWhseActivLine."Serial No.",TempWhseActivLine."Lot No.");
              QtyToRegisterBase := 0;
              repeat
                QtyToRegisterBase := QtyToRegisterBase + TempWhseActivLine."Qty. to Handle (Base)";
              until TempWhseActivLine.Next = 0;

              QtyAvailToRegisterBase := CalcQtyAvailToRegisterBase(TempWhseActivLine);
              if QtyToRegisterBase > QtyAvailToRegisterBase then
                QtyAvailToInsertBase -= QtyToRegisterBase - QtyAvailToRegisterBase;
              OnBeforeCheckQtyAvailToInsertBase(TempWhseActivLine,QtyAvailToInsertBase);
              if QtyAvailToInsertBase < 0 then
                Error(Text004);

              if (TempWhseActivLine."Serial No." <> '') or (TempWhseActivLine."Lot No." <> '') then
                if not IsQtyAvailToPickNonSpecificReservation(TempWhseActivLine,WhseSNRequired,WhseLNRequired,QtyToRegisterBase) then
                  AvailabilityError(TempWhseActivLine);

              // Clear filters, Lot/SN
              TempWhseActivLine.ClearTrackingFilter;
              TempWhseActivLine.SetRange("Item No.");
            until TempWhseActivLine.Next = 0; // Per Lot/SN
            // Clear filters, document
            TempWhseActivLine.ClearSourceFilter;
          until TempWhseActivLine.Next = 0;   // Per document
    end;

    local procedure RegisterWhseItemTrkgLine(WhseActivLine2: Record "Warehouse Activity Line")
    var
        ProdOrderComp: Record "Prod. Order Component";
        AssemblyLine: Record "Assembly Line";
        WhseShptLine: Record "Warehouse Shipment Line";
        QtyToRegisterBase: Decimal;
        DueDate: Date;
        NextEntryNo: Integer;
        WhseSNRequired: Boolean;
        WhseLNRequired: Boolean;
        WhseDocType2: Option;
    begin
        ItemTrackingMgt.CheckWhseItemTrkgSetup(WhseActivLine2."Item No.",WhseSNRequired,WhseLNRequired,false);
        if not (WhseSNRequired or WhseLNRequired) then
          exit;

        QtyToRegisterBase := InitTempTrackingSpecification(WhseActivLine2,TempTrackingSpecification);

        TempTrackingSpecification.Reset;

        if QtyToRegisterBase > 0 then begin
          if (WhseActivLine2."Activity Type" = WhseActivLine2."Activity Type"::Pick) or
             (WhseActivLine2."Activity Type" = WhseActivLine2."Activity Type"::"Invt. Movement")
          then
            InsertRegWhseItemTrkgLine(WhseActivLine2,QtyToRegisterBase);

          if (WhseActivLine2."Whse. Document Type" in
              [WhseActivLine2."Whse. Document Type"::Shipment,
               WhseActivLine2."Whse. Document Type"::Production,
               WhseActivLine2."Whse. Document Type"::Assembly]) or
             ((WhseActivLine2."Activity Type" = WhseActivLine2."Activity Type"::"Invt. Movement") and
              (WhseActivLine2."Source Type" > 0))
          then begin
            if (WhseActivLine2."Whse. Document Type" = WhseActivLine2."Whse. Document Type"::Shipment) and
               WhseActivLine2."Assemble to Order"
            then
              WhseDocType2 := WhseActivLine2."Whse. Document Type"::Assembly
            else
              WhseDocType2 := WhseActivLine2."Whse. Document Type";
            case WhseDocType2 of
              WhseActivLine2."Whse. Document Type"::Shipment:
                begin
                  WhseShptLine.Get(WhseActivLine2."Whse. Document No.",WhseActivLine2."Whse. Document Line No.");
                  DueDate := WhseShptLine."Shipment Date";
                end;
              WhseActivLine2."Whse. Document Type"::Production:
                begin
                  ProdOrderComp.Get(WhseActivLine2."Source Subtype",WhseActivLine2."Source No.",
                    WhseActivLine2."Source Line No.",WhseActivLine2."Source Subline No.");
                  DueDate := ProdOrderComp."Due Date";
                end;
              WhseActivLine2."Whse. Document Type"::Assembly:
                begin
                  AssemblyLine.Get(WhseActivLine2."Source Subtype",WhseActivLine2."Source No.",
                    WhseActivLine2."Source Line No.");
                  DueDate := AssemblyLine."Due Date";
                end;
            end;

            if WhseActivLine2."Activity Type" = WhseActivLine2."Activity Type"::"Invt. Movement" then
              case WhseActivLine2."Source Type" of
                DATABASE::"Prod. Order Component":
                  begin
                    ProdOrderComp.Get(WhseActivLine2."Source Subtype",WhseActivLine2."Source No.",
                      WhseActivLine2."Source Line No.",WhseActivLine2."Source Subline No.");
                    DueDate := ProdOrderComp."Due Date";
                  end;
                DATABASE::"Assembly Line":
                  begin
                    AssemblyLine.Get(WhseActivLine2."Source Subtype",WhseActivLine2."Source No.",
                      WhseActivLine2."Source Line No.");
                    DueDate := AssemblyLine."Due Date";
                  end;
              end;

            NextEntryNo := GetNextTempEntryNo(TempTrackingSpecification);

            TempTrackingSpecification.Init;
            TempTrackingSpecification."Entry No." := NextEntryNo;
            if WhseActivLine."Source Type" = DATABASE::"Prod. Order Component" then
              TempTrackingSpecification.SetSource(
                WhseActivLine2."Source Type",WhseActivLine2."Source Subtype",WhseActivLine2."Source No.",
                WhseActivLine2."Source Subline No.",'',WhseActivLine2."Source Line No.")
            else
              TempTrackingSpecification.SetSource(
                WhseActivLine2."Source Type",WhseActivLine2."Source Subtype",WhseActivLine2."Source No.",
                WhseActivLine2."Source Line No.",'',0);
            TempTrackingSpecification."Creation Date" := DueDate;
            TempTrackingSpecification."Qty. to Handle (Base)" := QtyToRegisterBase;
            TempTrackingSpecification."Item No." := WhseActivLine2."Item No.";
            TempTrackingSpecification."Variant Code" := WhseActivLine2."Variant Code";
            TempTrackingSpecification."Location Code" := WhseActivLine2."Location Code";
            TempTrackingSpecification.Description := WhseActivLine2.Description;
            TempTrackingSpecification."Qty. per Unit of Measure" := WhseActivLine2."Qty. per Unit of Measure";
            TempTrackingSpecification.SetTracking(
              WhseActivLine2."Serial No.",WhseActivLine2."Lot No.",
              WhseActivLine2."Warranty Date",WhseActivLine2."Expiration Date");
            TempTrackingSpecification."Quantity (Base)" := QtyToRegisterBase;
            TempTrackingSpecification.Insert;
            OnAfterRegWhseItemTrkgLine(WhseActivLine2,TempTrackingSpecification);
          end;
        end;
    end;

    local procedure InitTempTrackingSpecification(WhseActivLine2: Record "Warehouse Activity Line";var TempTrackingSpecification: Record "Tracking Specification" temporary) QtyToRegisterBase: Decimal
    var
        WhseItemTrkgLine: Record "Whse. Item Tracking Line";
        QtyToHandleBase: Decimal;
    begin
        QtyToRegisterBase := WhseActivLine2."Qty. to Handle (Base)";
        SetPointerFilter(WhseActivLine2,WhseItemTrkgLine);

        with WhseItemTrkgLine do begin
          SetRange("Serial No.",WhseActivLine2."Serial No.");
          SetRange("Lot No.",WhseActivLine2."Lot No.");
          if FindSet then
            repeat
              if "Quantity (Base)" > "Qty. Registered (Base)" then begin
                if QtyToRegisterBase > ("Quantity (Base)" - "Qty. Registered (Base)") then begin
                  QtyToHandleBase := "Quantity (Base)" - "Qty. Registered (Base)";
                  QtyToRegisterBase := QtyToRegisterBase - QtyToHandleBase;
                  "Qty. Registered (Base)" := "Quantity (Base)";
                end else begin
                  "Qty. Registered (Base)" += QtyToRegisterBase;
                  QtyToHandleBase := QtyToRegisterBase;
                  QtyToRegisterBase := 0;
                end;
                if not UpdateTempTracking(WhseActivLine2,QtyToHandleBase,TempTrackingSpecification) then begin
                  TempTrackingSpecification.SetCurrentKey("Lot No.","Serial No.");
                  TempTrackingSpecification.SetTrackingFilter(WhseActivLine2."Serial No.",WhseActivLine2."Lot No.");
                  if TempTrackingSpecification.FindFirst then begin
                    TempTrackingSpecification."Qty. to Handle (Base)" += QtyToHandleBase;
                    TempTrackingSpecification.Modify;
                  end;
                end;
                ItemTrackingMgt.SetRegistering(true);
                ItemTrackingMgt.CalcWhseItemTrkgLine(WhseItemTrkgLine);
                Modify;
              end;
            until (Next = 0) or (QtyToRegisterBase = 0);
        end;
    end;

    local procedure CalcQtyAvailToRegisterBase(WhseActivLine: Record "Warehouse Activity Line"): Decimal
    var
        WhseItemTrkgLine: Record "Whse. Item Tracking Line";
    begin
        SetPointerFilter(WhseActivLine,WhseItemTrkgLine);
        WhseItemTrkgLine.SetTrackingFilter(WhseActivLine."Serial No.",WhseActivLine."Lot No.");
        WhseItemTrkgLine.CalcSums("Quantity (Base)","Qty. Registered (Base)");
        exit(WhseItemTrkgLine."Quantity (Base)" - WhseItemTrkgLine."Qty. Registered (Base)");
    end;

    local procedure SourceLineQtyBase(WhseActivLine: Record "Warehouse Activity Line"): Decimal
    var
        WhsePostedRcptLine: Record "Posted Whse. Receipt Line";
        WhseShipmentLine: Record "Warehouse Shipment Line";
        WhseIntPutAwayLine: Record "Whse. Internal Put-away Line";
        WhseIntPickLine: Record "Whse. Internal Pick Line";
        ProdOrderComponent: Record "Prod. Order Component";
        AssemblyLine: Record "Assembly Line";
        WhseMovementWksh: Record "Whse. Worksheet Line";
        WhseActivLine2: Record "Warehouse Activity Line";
        QtyBase: Decimal;
        WhseDocType2: Option;
    begin
        if (WhseActivLine."Whse. Document Type" = WhseActivLine."Whse. Document Type"::Shipment) and
           WhseActivLine."Assemble to Order"
        then
          WhseDocType2 := WhseActivLine."Whse. Document Type"::Assembly
        else
          WhseDocType2 := WhseActivLine."Whse. Document Type";
        case WhseDocType2 of
          WhseActivLine."Whse. Document Type"::Receipt:
            if WhsePostedRcptLine.Get(
                 WhseActivLine."Whse. Document No.",WhseActivLine."Whse. Document Line No.")
            then
              exit(WhsePostedRcptLine."Qty. (Base)");
          WhseActivLine."Whse. Document Type"::Shipment:
            if WhseShipmentLine.Get(
                 WhseActivLine."Whse. Document No.",WhseActivLine."Whse. Document Line No.")
            then
              exit(WhseShipmentLine."Qty. (Base)");
          WhseActivLine."Whse. Document Type"::"Internal Put-away":
            if WhseIntPutAwayLine.Get(
                 WhseActivLine."Whse. Document No.",WhseActivLine."Whse. Document Line No.")
            then
              exit(WhseIntPutAwayLine."Qty. (Base)");
          WhseActivLine."Whse. Document Type"::"Internal Pick":
            if WhseIntPickLine.Get(
                 WhseActivLine."Whse. Document No.",WhseActivLine."Whse. Document Line No.")
            then
              exit(WhseIntPickLine."Qty. (Base)");
          WhseActivLine."Whse. Document Type"::Production:
            if ProdOrderComponent.Get(
                 WhseActivLine."Source Subtype",WhseActivLine."Source No.",
                 WhseActivLine."Source Line No.",WhseActivLine."Source Subline No.")
            then
              exit(ProdOrderComponent."Expected Qty. (Base)");
          WhseActivLine."Whse. Document Type"::Assembly:
            if AssemblyLine.Get(
                 WhseActivLine."Source Subtype",WhseActivLine."Source No.",
                 WhseActivLine."Source Line No.")
            then
              exit(AssemblyLine."Quantity (Base)");
          WhseActivLine."Whse. Document Type"::"Movement Worksheet":
            if WhseMovementWksh.Get(
                 WhseActivLine."Whse. Document No.",WhseActivLine."Source No.",
                 WhseActivLine."Location Code",WhseActivLine."Source Line No.")
            then
              exit(WhseMovementWksh."Qty. (Base)");
        end;

        if WhseActivLine."Activity Type" = WhseActivLine."Activity Type"::"Invt. Movement" then
          case WhseActivLine."Source Document" of
            WhseActivLine."Source Document"::"Prod. Consumption":
              if ProdOrderComponent.Get(
                   WhseActivLine."Source Subtype",WhseActivLine."Source No.",
                   WhseActivLine."Source Line No.",WhseActivLine."Source Subline No.")
              then
                exit(ProdOrderComponent."Expected Qty. (Base)");
            WhseActivLine."Source Document"::"Assembly Consumption":
              if AssemblyLine.Get(
                   WhseActivLine."Source Subtype",WhseActivLine."Source No.",
                   WhseActivLine."Source Line No.")
              then
                exit(AssemblyLine."Quantity (Base)");
            WhseActivLine."Source Document"::" ":
              begin
                WhseActivLine2.SetCurrentKey("No.","Line No.","Activity Type");
                WhseActivLine2.SetRange("Activity Type",WhseActivLine."Activity Type");
                WhseActivLine2.SetRange("No.",WhseActivLine."No.");
                WhseActivLine2.SetFilter("Action Type",'<%1',WhseActivLine2."Action Type"::Place);
                WhseActivLine2.SetFilter("Qty. to Handle (Base)",'<>0');
                WhseActivLine2.SetRange("Breakbulk No.",0);
                if WhseActivLine2.Find('-') then
                  repeat
                    QtyBase += WhseActivLine2."Qty. (Base)";
                  until WhseActivLine2.Next = 0;
                exit(QtyBase);
              end;
          end;
    end;

    local procedure CalcQtyAvailToInsertBase(WhseActivLine: Record "Warehouse Activity Line"): Decimal
    var
        WhseItemTrkgLine: Record "Whse. Item Tracking Line";
    begin
        SetPointerFilter(WhseActivLine,WhseItemTrkgLine);
        WhseItemTrkgLine.CalcSums(WhseItemTrkgLine."Quantity (Base)");
        exit(SourceLineQtyBase(WhseActivLine) - WhseItemTrkgLine."Quantity (Base)");
    end;

    local procedure CalcQtyReservedOnInventory(WhseActivLine: Record "Warehouse Activity Line";SNRequired: Boolean;LNRequired: Boolean)
    begin
        with WhseActivLine do begin
          GetItem("Item No.");
          Item.SetRange("Location Filter","Location Code");
          Item.SetRange("Variant Filter","Variant Code");
          if "Lot No." <> '' then begin
            if LNRequired then
              Item.SetRange("Lot No. Filter","Lot No.")
            else
              Item.SetFilter("Lot No. Filter",'%1|%2',"Lot No.",'')
          end else
            Item.SetRange("Lot No. Filter");
          if "Serial No." <> '' then begin
            if SNRequired then
              Item.SetRange("Serial No. Filter","Serial No.")
            else
              Item.SetFilter("Serial No. Filter",'%1|%2',"Serial No.",'');
          end else
            Item.SetRange("Serial No. Filter");
          Item.CalcFields("Reserved Qty. on Inventory");
        end;
    end;

    local procedure InsertRegWhseItemTrkgLine(WhseActivLine: Record "Warehouse Activity Line";QtyToRegisterBase: Decimal)
    var
        WhseItemTrkgLine2: Record "Whse. Item Tracking Line";
        NextEntryNo: Integer;
    begin
        with WhseItemTrkgLine2 do begin
          Reset;
          if FindLast then
            NextEntryNo := "Entry No." + 1;

          Init;
          "Entry No." := NextEntryNo;
          "Item No." := WhseActivLine."Item No.";
          Description := WhseActivLine.Description;
          "Variant Code" := WhseActivLine."Variant Code";
          "Location Code" := WhseActivLine."Location Code";
          SetPointer(WhseActivLine,WhseItemTrkgLine2);
          SetTracking(
            WhseActivLine."Serial No.",WhseActivLine."Lot No.",WhseActivLine."Warranty Date",WhseActivLine."Expiration Date");
          "Quantity (Base)" := QtyToRegisterBase;
          "Qty. per Unit of Measure" := WhseActivLine."Qty. per Unit of Measure";
          "Qty. Registered (Base)" := QtyToRegisterBase;
          "Created by Whse. Activity Line" := true;
          ItemTrackingMgt.SetRegistering(true);
          ItemTrackingMgt.CalcWhseItemTrkgLine(WhseItemTrkgLine2);
          Insert;
        end;
        OnAfterInsRegWhseItemTrkgLine(WhseActivLine,WhseItemTrkgLine2);
    end;

    [Scope('Personalization')]
    procedure SetPointer(WhseActivLine: Record "Warehouse Activity Line";var WhseItemTrkgLine: Record "Whse. Item Tracking Line")
    var
        WhseDocType2: Option;
    begin
        with WhseActivLine do begin
          if ("Whse. Document Type" = "Whse. Document Type"::Shipment) and "Assemble to Order" then
            WhseDocType2 := "Whse. Document Type"::Assembly
          else
            WhseDocType2 := "Whse. Document Type";
          case WhseDocType2 of
            "Whse. Document Type"::Receipt:
              WhseItemTrkgLine.SetSource(
                DATABASE::"Posted Whse. Receipt Line",0,"Whse. Document No.","Whse. Document Line No.",'',0);
            "Whse. Document Type"::Shipment:
              WhseItemTrkgLine.SetSource(
                DATABASE::"Warehouse Shipment Line",0,"Whse. Document No.","Whse. Document Line No.",'',0);
            "Whse. Document Type"::"Internal Put-away":
              WhseItemTrkgLine.SetSource(
                DATABASE::"Whse. Internal Put-away Line",0,"Whse. Document No.","Whse. Document Line No.",'',0);
            "Whse. Document Type"::"Internal Pick":
              WhseItemTrkgLine.SetSource(
                DATABASE::"Whse. Internal Pick Line",0,"Whse. Document No.","Whse. Document Line No.",'',0);
            "Whse. Document Type"::Production:
              WhseItemTrkgLine.SetSource(
                DATABASE::"Prod. Order Component","Source Subtype","Source No.","Source Subline No.",'',"Source Line No.");
            "Whse. Document Type"::Assembly:
              WhseItemTrkgLine.SetSource(
                DATABASE::"Assembly Line","Source Subtype","Source No.","Source Line No.",'',0);
            "Whse. Document Type"::"Movement Worksheet":
              WhseItemTrkgLine.SetSource(
                DATABASE::"Whse. Worksheet Line",0,"Source No.","Whse. Document Line No.",
                CopyStr("Whse. Document No.",1,MaxStrLen(WhseItemTrkgLine."Source Batch Name")),0);
          end;
          WhseItemTrkgLine."Location Code" := "Location Code";
          if "Activity Type" = "Activity Type"::"Invt. Movement" then begin
            WhseItemTrkgLine.SetSource("Source Type","Source Subtype","Source No.","Source Line No.",'',0);
            if "Source Type" = DATABASE::"Prod. Order Component" then
              WhseItemTrkgLine.SetSource("Source Type","Source Subtype","Source No.","Source Subline No.",'',"Source Line No.")
            else
              WhseItemTrkgLine.SetSource("Source Type","Source Subtype","Source No.","Source Line No.",'',0);
            WhseItemTrkgLine."Location Code" := "Location Code";
          end;
        end;
    end;

    [Scope('Personalization')]
    procedure SetPointerFilter(WhseActivLine: Record "Warehouse Activity Line";var WhseItemTrkgLine: Record "Whse. Item Tracking Line")
    var
        WhseItemTrkgLine2: Record "Whse. Item Tracking Line";
    begin
        SetPointer(WhseActivLine,WhseItemTrkgLine2);
        WhseItemTrkgLine.SetSourceFilter(
          WhseItemTrkgLine2."Source Type",WhseItemTrkgLine2."Source Subtype",
          WhseItemTrkgLine2."Source ID",WhseItemTrkgLine2."Source Ref. No.",true);
        WhseItemTrkgLine.SetSourceFilter2(WhseItemTrkgLine2."Source Batch Name",WhseItemTrkgLine2."Source Prod. Order Line");
        WhseItemTrkgLine.SetRange("Location Code",WhseItemTrkgLine2."Location Code");
    end;

    [Scope('Personalization')]
    procedure ShowHideDialog(HideDialog2: Boolean)
    begin
        HideDialog := HideDialog2;
    end;

    local procedure CalcTotalAvailQtyToPick(WhseActivLine: Record "Warehouse Activity Line";SNRequired: Boolean;LNRequired: Boolean): Decimal
    var
        WhseEntry: Record "Warehouse Entry";
        ItemLedgEntry: Record "Item Ledger Entry";
        TempWhseActivLine2: Record "Warehouse Activity Line" temporary;
        WarehouseActivityLine: Record "Warehouse Activity Line";
        CreatePick: Codeunit "Create Pick";
        WhseAvailMgt: Codeunit "Warehouse Availability Mgt.";
        BinTypeFilter: Text;
        TotalAvailQtyBase: Decimal;
        QtyInWhseBase: Decimal;
        QtyOnPickBinsBase: Decimal;
        QtyOnOutboundBinsBase: Decimal;
        QtyOnDedicatedBinsBase: Decimal;
        SubTotalBase: Decimal;
        QtyReservedOnPickShipBase: Decimal;
        LineReservedQtyBase: Decimal;
        QtyPickedNotShipped: Decimal;
    begin
        with WhseActivLine do begin
          CalcQtyReservedOnInventory(WhseActivLine,SNRequired,LNRequired);

          LocationGet("Location Code");
          if Location."Directed Put-away and Pick" or
             ("Activity Type" = "Activity Type"::"Invt. Movement")
          then begin
            WhseEntry.SetCurrentKey("Item No.","Location Code","Variant Code","Bin Type Code");
            WhseEntry.SetRange("Item No.","Item No.");
            WhseEntry.SetRange("Location Code","Location Code");
            WhseEntry.SetRange("Variant Code","Variant Code");
            if "Lot No." <> '' then
              if LNRequired then
                WhseEntry.SetRange("Lot No.","Lot No.")
              else
                WhseEntry.SetFilter("Lot No.",'%1|%2',"Lot No.",'');
            if "Serial No." <> '' then
              if SNRequired then
                WhseEntry.SetRange("Serial No.","Serial No.")
              else
                WhseEntry.SetFilter("Serial No.",'%1|%2',"Serial No.",'');
            WhseEntry.CalcSums("Qty. (Base)");
            QtyInWhseBase := WhseEntry."Qty. (Base)";

            BinTypeFilter := CreatePick.GetBinTypeFilter(0);
            if BinTypeFilter <> '' then
              WhseEntry.SetFilter("Bin Type Code",'<>%1',BinTypeFilter); // Pick from all but Receive area
            WhseEntry.CalcSums("Qty. (Base)");
            QtyOnPickBinsBase := WhseEntry."Qty. (Base)";

            QtyOnOutboundBinsBase :=
              CreatePick.CalcQtyOnOutboundBins(
                "Location Code","Item No.","Variant Code","Lot No.","Serial No.",true);

            QtyOnDedicatedBinsBase :=
              WhseAvailMgt.CalcQtyOnDedicatedBins("Location Code","Item No.","Variant Code","Lot No.","Serial No.");

            SubTotalBase :=
              QtyInWhseBase -
              QtyOnPickBinsBase - QtyOnOutboundBinsBase - QtyOnDedicatedBinsBase;
            if "Activity Type" <> "Activity Type"::"Invt. Movement" then
              SubTotalBase -= Abs(Item."Reserved Qty. on Inventory");

            if SubTotalBase < 0 then begin
              CreatePick.FilterWhsePickLinesWithUndefinedBin(
                WarehouseActivityLine,"Item No.","Location Code","Variant Code",
                LNRequired,"Lot No.",SNRequired,"Serial No.");
              if WarehouseActivityLine.FindSet then
                repeat
                  TempWhseActivLine2 := WarehouseActivityLine;
                  TempWhseActivLine2."Qty. Outstanding (Base)" *= -1;
                  TempWhseActivLine2.Insert;
                until WarehouseActivityLine.Next = 0;

              QtyReservedOnPickShipBase :=
                WhseAvailMgt.CalcReservQtyOnPicksShips("Location Code","Item No.","Variant Code",TempWhseActivLine2);

              LineReservedQtyBase :=
                WhseAvailMgt.CalcLineReservedQtyOnInvt(
                  "Source Type","Source Subtype","Source No.","Source Line No.","Source Subline No.",true,'','',TempWhseActivLine2);

              if Abs(SubTotalBase) < QtyReservedOnPickShipBase + LineReservedQtyBase then
                QtyReservedOnPickShipBase := Abs(SubTotalBase) - LineReservedQtyBase;

              TotalAvailQtyBase :=
                QtyOnPickBinsBase +
                SubTotalBase +
                QtyReservedOnPickShipBase +
                LineReservedQtyBase;
            end else
              TotalAvailQtyBase := QtyOnPickBinsBase;
          end else begin
            ItemLedgEntry.SetCurrentKey(
              "Item No.",Open,"Variant Code",Positive,"Location Code","Posting Date","Expiration Date","Lot No.","Serial No.");
            ItemLedgEntry.SetRange("Item No.","Item No.");
            ItemLedgEntry.SetRange("Variant Code","Variant Code");
            ItemLedgEntry.SetRange(Open,true);
            ItemLedgEntry.SetRange("Location Code","Location Code");

            if "Serial No." <> '' then
              if SNRequired then
                ItemLedgEntry.SetRange("Serial No.","Serial No.")
              else
                ItemLedgEntry.SetFilter("Serial No.",'%1|%2',"Serial No.",'');

            if "Lot No." <> '' then
              if LNRequired then
                ItemLedgEntry.SetRange("Lot No.","Lot No.")
              else
                ItemLedgEntry.SetFilter("Lot No.",'%1|%2',"Lot No.",'');

            ItemLedgEntry.CalcSums("Remaining Quantity");
            QtyInWhseBase := ItemLedgEntry."Remaining Quantity";

            QtyPickedNotShipped := CalcQtyPickedNotShipped(WhseActivLine,SNRequired,LNRequired);

            LineReservedQtyBase :=
              WhseAvailMgt.CalcLineReservedQtyOnInvt(
                "Source Type","Source Subtype","Source No.","Source Line No.","Source Subline No.",false,'','',TempWhseActivLine2);

            TotalAvailQtyBase :=
              QtyInWhseBase -
              QtyPickedNotShipped -
              Abs(Item."Reserved Qty. on Inventory") +
              LineReservedQtyBase;
          end;

          exit(TotalAvailQtyBase);
        end;
    end;

    local procedure IsQtyAvailToPickNonSpecificReservation(WhseActivLine: Record "Warehouse Activity Line";SNRequired: Boolean;LNRequired: Boolean;QtyToRegister: Decimal): Boolean
    var
        QtyAvailToPick: Decimal;
    begin
        QtyAvailToPick := CalcTotalAvailQtyToPick(WhseActivLine,SNRequired,LNRequired);
        if QtyAvailToPick < QtyToRegister then
          if ReleaseNonSpecificReservations(WhseActivLine,SNRequired,LNRequired,QtyToRegister - QtyAvailToPick) then
            QtyAvailToPick := CalcTotalAvailQtyToPick(WhseActivLine,SNRequired,LNRequired);

        exit(QtyAvailToPick >= QtyToRegister);
    end;

    local procedure CalcQtyPickedNotShipped(WhseActivLine: Record "Warehouse Activity Line";SNRequired: Boolean;LNRequired: Boolean) QtyBasePicked: Decimal
    var
        ReservEntry: Record "Reservation Entry";
        RegWhseActivLine: Record "Registered Whse. Activity Line";
        QtyHandled: Decimal;
    begin
        with WhseActivLine do begin
          ReservEntry.Reset;
          ReservEntry.SetCurrentKey("Item No.","Variant Code","Location Code","Reservation Status");
          ReservEntry.SetRange("Item No.","Item No.");
          ReservEntry.SetRange("Variant Code","Variant Code");
          ReservEntry.SetRange("Location Code","Location Code");
          ReservEntry.SetRange("Reservation Status",ReservEntry."Reservation Status"::Surplus);

          if SNRequired then
            ReservEntry.SetRange("Serial No.","Serial No.")
          else
            ReservEntry.SetFilter("Serial No.",'%1|%2',"Serial No.",'');

          if LNRequired then
            ReservEntry.SetRange("Lot No.","Lot No.")
          else
            ReservEntry.SetFilter("Lot No.",'%1|%2',"Lot No.",'');

          if ReservEntry.Find('-') then
            repeat
              if not ((ReservEntry."Source Type" = "Source Type") and
                      (ReservEntry."Source Subtype" = "Source Subtype") and
                      (ReservEntry."Source ID" = "Source No.") and
                      ((ReservEntry."Source Ref. No." = "Source Line No.") or
                       (ReservEntry."Source Ref. No." = "Source Subline No."))) and
                 not ReservEntry.Positive
              then
                QtyBasePicked := QtyBasePicked + Abs(ReservEntry."Quantity (Base)");
            until ReservEntry.Next = 0;

          if SNRequired or LNRequired then begin
            RegWhseActivLine.SetRange("Activity Type","Activity Type");
            RegWhseActivLine.SetRange("No.","No.");
            RegWhseActivLine.SetRange("Line No.","Line No.");
            RegWhseActivLine.SetRange("Lot No.","Lot No.");
            RegWhseActivLine.SetRange("Serial No.","Serial No.");
            RegWhseActivLine.SetRange("Bin Code","Bin Code");
            if RegWhseActivLine.FindSet then
              repeat
                QtyHandled := QtyHandled + RegWhseActivLine."Qty. (Base)";
              until RegWhseActivLine.Next = 0;
            QtyBasePicked := QtyBasePicked + QtyHandled;
          end else
            QtyBasePicked := QtyBasePicked + "Qty. Handled (Base)";
        end;

        exit(QtyBasePicked);
    end;

    [Scope('Personalization')]
    procedure GetItem(ItemNo: Code[20])
    begin
        if ItemNo <> Item."No." then
          Item.Get(ItemNo);
    end;

    local procedure UpdateTempTracking(WhseActivLine2: Record "Warehouse Activity Line";QtyToHandleBase: Decimal;var TempTrackingSpecification: Record "Tracking Specification" temporary): Boolean
    var
        NextEntryNo: Integer;
        Inserted: Boolean;
    begin
        with WhseActivLine2 do begin
          NextEntryNo := GetNextTempEntryNo(TempTrackingSpecification);
          TempTrackingSpecification.Init;
          if WhseActivLine."Source Type" = DATABASE::"Prod. Order Component" then
            TempTrackingSpecification.SetSource("Source Type","Source Subtype","Source No.","Source Subline No.",'',"Source Line No.")
          else
            TempTrackingSpecification.SetSource("Source Type","Source Subtype","Source No.","Source Line No.",'',0);

          ItemTrackingMgt.SetPointerFilter(TempTrackingSpecification);
          TempTrackingSpecification.SetTrackingFilter("Serial No.","Lot No.");
          if TempTrackingSpecification.IsEmpty then begin
            TempTrackingSpecification."Entry No." := NextEntryNo;
            TempTrackingSpecification."Creation Date" := Today;
            TempTrackingSpecification."Qty. to Handle (Base)" := QtyToHandleBase;
            TempTrackingSpecification."Item No." := "Item No.";
            TempTrackingSpecification."Variant Code" := "Variant Code";
            TempTrackingSpecification."Location Code" := "Location Code";
            TempTrackingSpecification.Description := Description;
            TempTrackingSpecification."Qty. per Unit of Measure" := "Qty. per Unit of Measure";
            TempTrackingSpecification.SetTracking("Serial No.","Lot No.","Warranty Date","Expiration Date");
            TempTrackingSpecification.Correction := true;
            TempTrackingSpecification.Insert;
            Inserted := true;
            TempTrackingSpecification.Reset;
            OnAfterRegWhseItemTrkgLine(WhseActivLine2,TempTrackingSpecification);
          end;
        end;
        exit(Inserted);
    end;

    local procedure CheckItemTrackingInfoBlocked(ItemNo: Code[20];VariantCode: Code[10];SerialNo: Code[50];LotNo: Code[50])
    var
        SerialNoInfo: Record "Serial No. Information";
        LotNoInfo: Record "Lot No. Information";
    begin
        if (SerialNo = '') and (LotNo = '') then
          exit;

        if SerialNo <> '' then
          if SerialNoInfo.Get(ItemNo,VariantCode,SerialNo) then
            SerialNoInfo.TestField(Blocked,false);

        if LotNo <> '' then
          if LotNoInfo.Get(ItemNo,VariantCode,LotNo) then
            LotNoInfo.TestField(Blocked,false);
    end;

    local procedure UpdateWindow(ControlNo: Integer;Value: Code[20])
    begin
        if not HideDialog then
          case ControlNo of
            1:
              begin
                Window.Open(Text000 + Text001 + Text002);
                Window.Update(1,Value);
              end;
            2:
              Window.Update(2,LineCount);
            3:
              Window.Update(3,LineCount);
            4:
              Window.Update(4,Round(LineCount / NoOfRecords * 10000,1));
          end;
    end;

    local procedure CheckLines()
    begin
        OnBeforeCheckLines(WhseActivHeader,WhseActivLine);

        with WhseActivHeader do begin
          TempBinContentBuffer.DeleteAll;
          LineCount := 0;
          if WhseActivLine.Find('-') then
            repeat
              LineCount := LineCount + 1;
              UpdateWindow(2,'');
              WhseActivLine.CheckBinInSourceDoc;
              WhseActivLine.TestField("Item No.");
              if (WhseActivLine."Activity Type" = WhseActivLine."Activity Type"::Pick) and
                 (WhseActivLine."Destination Type" = WhseActivLine."Destination Type"::Customer)
              then begin
                WhseActivLine.TestField("Destination No.");
                Cust.Get(WhseActivLine."Destination No.");
                Cust.CheckBlockedCustOnDocs(Cust,"Source Document",false,false);
              end;
              if Location."Bin Mandatory" then begin
                WhseActivLine.TestField("Unit of Measure Code");
                WhseActivLine.TestField("Bin Code");
                WhseActivLine.CheckWhseDocLine;
                UpdateTempBinContentBuffer(WhseActivLine);
              end;
              OnAfterCheckWhseActivLine(WhseActivLine);

              if ((WhseActivLine."Activity Type" = WhseActivLine."Activity Type"::Pick) or
                  (WhseActivLine."Activity Type" = WhseActivLine."Activity Type"::"Invt. Pick") or
                  (WhseActivLine."Activity Type" = WhseActivLine."Activity Type"::"Invt. Movement")) and
                 (WhseActivLine."Action Type" = WhseActivLine."Action Type"::Take)
              then
                CheckItemTrackingInfoBlocked(
                  WhseActivLine."Item No.",WhseActivLine."Variant Code",WhseActivLine."Serial No.",WhseActivLine."Lot No.");
            until WhseActivLine.Next = 0;
          NoOfRecords := LineCount;

          if Location."Bin Mandatory" then begin
            CheckBinContent;
            CheckBin;
          end;

          if "Registering No." = '' then begin
            TestField("Registering No. Series");
            "Registering No." := NoSeriesMgt.GetNextNo("Registering No. Series","Assignment Date",true);
            Modify;
            Commit;
          end;
        end;
    end;

    local procedure UpdateSourceDocForInvtMovement(WhseActivityLine: Record "Warehouse Activity Line")
    begin
        if (WhseActivityLine."Action Type" = WhseActivityLine."Action Type"::Take) or
           (WhseActivityLine."Source Document" = WhseActivityLine."Source Document"::" ")
        then
          exit;

        with WhseActivityLine do
          case "Source Document" of
            "Source Document"::"Prod. Consumption":
              begin
                UpdateProdCompLine(
                  "Source Subtype","Source No.","Source Line No.","Source Subline No.",
                  "Qty. to Handle","Qty. to Handle (Base)","Qty. per Unit of Measure");
                RegisterWhseItemTrkgLine(WhseActivLine);
              end;
            "Source Document"::"Assembly Consumption":
              begin
                UpdateAssemblyLine(
                  "Source Subtype","Source No.","Source Line No.",
                  "Qty. to Handle","Qty. to Handle (Base)","Qty. per Unit of Measure");
                RegisterWhseItemTrkgLine(WhseActivLine);
              end;
            else
          end;
    end;

    local procedure GetNextTempEntryNo(var TempTrackingSpecification: Record "Tracking Specification" temporary): Integer
    begin
        TempTrackingSpecification.Reset;
        if TempTrackingSpecification.FindLast then
          exit(TempTrackingSpecification."Entry No." + 1);

        exit(1);
    end;

    local procedure AutoReserveForSalesLine(var TempWhseActivLineToReserve: Record "Warehouse Activity Line" temporary)
    var
        SalesLine: Record "Sales Line";
        ReservMgt: Codeunit "Reservation Management";
        FullAutoReservation: Boolean;
    begin
        if TempWhseActivLineToReserve.FindSet then
          repeat
            SalesLine.Get(
              SalesLine."Document Type"::Order,TempWhseActivLineToReserve."Source No.",TempWhseActivLineToReserve."Source Line No.");

            if not IsSalesLineCompletelyReserved(
                 SalesLine,TempWhseActivLineToReserve."Serial No.",TempWhseActivLineToReserve."Lot No.")
            then begin
              ReservMgt.SetSalesLine(SalesLine);
              ReservMgt.SetSerialLotNo(TempWhseActivLineToReserve."Serial No.",TempWhseActivLineToReserve."Lot No.");
              ReservMgt.AutoReserve(
                FullAutoReservation,'',SalesLine."Shipment Date",TempWhseActivLineToReserve."Qty. to Handle",
                TempWhseActivLineToReserve."Qty. to Handle (Base)");
            end;
          until TempWhseActivLineToReserve.Next = 0;
    end;

    local procedure CheckAndRemoveOrderToOrderBinding(var TempWhseActivLineToReserve: Record "Warehouse Activity Line" temporary)
    var
        SalesLine: Record "Sales Line";
        ReservationEntry: Record "Reservation Entry";
        ReservMgt: Codeunit "Reservation Management";
        ReservationEngineMgt: Codeunit "Reservation Engine Mgt.";
        IsConfirmed: Boolean;
    begin
        if TempWhseActivLineToReserve.FindSet then
          repeat
            SalesLine.Get(
              SalesLine."Document Type"::Order,TempWhseActivLineToReserve."Source No.",TempWhseActivLineToReserve."Source Line No.");
            ReservationEntry.SetSourceFilter(
              DATABASE::"Sales Line",SalesLine."Document Type",SalesLine."Document No.",SalesLine."Line No.",true);
            ReservationEntry.SetFilter("Item Tracking",'<>%1',ReservationEntry."Item Tracking"::None);
            ReservationEntry.SetRange(Binding,ReservationEntry.Binding::"Order-to-Order");

            if ReservationEntry.FindSet then begin
              if not IsConfirmed and GuiAllowed then
                if not Confirm(OrderToOrderBindingOnSalesLineQst) then
                  Error(RegisterInterruptedErr);
              IsConfirmed := true;
              repeat
                ReservationEngineMgt.CancelReservation(ReservationEntry);
                ReservMgt.SetSalesLine(SalesLine);
                ReservMgt.SetItemTrackingHandling(1);
                ReservMgt.ClearSurplus;
              until ReservationEntry.Next = 0;
            end;
          until TempWhseActivLineToReserve.Next = 0;
    end;

    local procedure CopyWhseActivityLineToReservBuf(var TempWhseActivLineToReserve: Record "Warehouse Activity Line" temporary;WhseActivLine: Record "Warehouse Activity Line")
    begin
        if not IsPickPlaceForSalesOrderTrackedItem(WhseActivLine) then
          exit;

        TempWhseActivLineToReserve.TransferFields(WhseActivLine);
        TempWhseActivLineToReserve.Insert;
    end;

    local procedure ReleaseNonSpecificReservations(WhseActivLine: Record "Warehouse Activity Line";SNRequired: Boolean;LNRequired: Boolean;QtyToRelease: Decimal): Boolean
    var
        LateBindingMgt: Codeunit "Late Binding Management";
        xReservedQty: Decimal;
    begin
        if QtyToRelease <= 0 then
          exit;

        CalcQtyReservedOnInventory(WhseActivLine,SNRequired,LNRequired);

        if LNRequired or SNRequired then
          if Item."Reserved Qty. on Inventory" > 0 then begin
            xReservedQty := Item."Reserved Qty. on Inventory";
            LateBindingMgt.ReleaseForReservation(
              WhseActivLine."Item No.",WhseActivLine."Variant Code",WhseActivLine."Location Code",
              WhseActivLine."Serial No.",WhseActivLine."Lot No.",QtyToRelease);
            Item.CalcFields("Reserved Qty. on Inventory");
          end;

        exit(xReservedQty > Item."Reserved Qty. on Inventory");
    end;

    local procedure AvailabilityError(WhseActivLine: Record "Warehouse Activity Line")
    begin
        if WhseActivLine."Serial No." <> '' then
          Error(Text005,WhseActivLine.FieldCaption("Serial No."),WhseActivLine."Serial No.");

        if WhseActivLine."Lot No." <> '' then
          Error(Text005,WhseActivLine.FieldCaption("Lot No."),WhseActivLine."Lot No.");
    end;

    local procedure IsPickPlaceForSalesOrderTrackedItem(WhseActivityLine: Record "Warehouse Activity Line"): Boolean
    begin
        exit(
          (WhseActivityLine."Activity Type" = WhseActivityLine."Activity Type"::Pick) and
          (WhseActivityLine."Action Type" in [WhseActivityLine."Action Type"::Place,WhseActivityLine."Action Type"::" "]) and
          (WhseActivityLine."Source Document" = WhseActivityLine."Source Document"::"Sales Order") and
          ((WhseActivityLine."Serial No." <> '') or (WhseActivityLine."Lot No." <> '')));
    end;

    local procedure IsSalesLineCompletelyReserved(SalesLine: Record "Sales Line";SerialNo: Code[50];LotNo: Code[50]): Boolean
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        ReservationEntry.SetRange("Source Type",DATABASE::"Sales Line");
        ReservationEntry.SetRange("Source Subtype",SalesLine."Document Type");
        ReservationEntry.SetRange("Source ID",SalesLine."Document No.");
        ReservationEntry.SetRange("Source Ref. No.",SalesLine."Line No.");
        ReservationEntry.SetRange("Serial No.",SerialNo);
        ReservationEntry.SetRange("Lot No.",LotNo);
        if ReservationEntry.IsEmpty then
          exit(false);

        ReservationEntry.SetFilter("Reservation Status",'<>%1',ReservationEntry."Reservation Status"::Reservation);
        exit(ReservationEntry.IsEmpty);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCode(var WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeWhseActivLineDelete(var WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindWhseActivLine(var WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterWhseShptLineModify(var WarehouseShipmentLine: Record "Warehouse Shipment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateRegActivLine(var WarehouseActivityLine: Record "Warehouse Activity Line";var RegisteredWhseActivLine: Record "Registered Whse. Activity Line";var RegisteredInvtMovementLine: Record "Registered Invt. Movement Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAutofillQtyToHandle(var WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckLines(var WarehouseActivityHeader: Record "Warehouse Activity Header";var WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckWhseActivLine(var WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRegWhseItemTrkgLine(var WhseActivLine2: Record "Warehouse Activity Line";var TempTrackingSpecification: Record "Tracking Specification" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsRegWhseItemTrkgLine(var WhseActivLine2: Record "Warehouse Activity Line";var WhseItemTrkgLine: Record "Whse. Item Tracking Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRegisterWhseActivity(var WarehouseActivityHeader: Record "Warehouse Activity Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckQtyAvailToInsertBase(var TempWhseActivLine: Record "Warehouse Activity Line" temporary;var QtyAvailToInsertBase: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdWhseActivHeader(var WhseActivityHeader: Record "Warehouse Activity Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitRegActLine(var WarehouseActivityLine: Record "Warehouse Activity Line";var RegisteredWhseActivityLine: Record "Registered Whse. Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateRegActivHeader(var WhseActivityHeader: Record "Warehouse Activity Header";var IsHandled: Boolean;var RegisteredWhseActivityHdr: Record "Registered Whse. Activity Hdr.")
    begin
    end;
}

