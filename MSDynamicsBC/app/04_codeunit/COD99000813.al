codeunit 99000813 "Carry Out Action"
{
    // version NAVW113.00

    Permissions = TableData "Prod. Order Capacity Need"=rid;
    TableNo = "Requisition Line";

    trigger OnRun()
    begin
        ProductionExist := true;
        AssemblyExist := true;
        case TrySourceType of
          TrySourceType::Purchase:
            CarryOutToReqWksh(Rec,TryWkshTempl,TryWkshName);
          TrySourceType::Transfer:
            CarryOutTransOrder(Rec,TryChoice,TryWkshTempl,TryWkshName);
          TrySourceType::Production:
            ProductionExist := CarryOutProdOrder(Rec,TryChoice,TryWkshTempl,TryWkshName);
          TrySourceType::Assembly:
            AssemblyExist := CarryOutAsmOrder(Rec,TryChoice);
        end;

        if "Action Message" = "Action Message"::Cancel then
          Delete(true);

        ReservEntry.SetCurrentKey(
          "Source ID","Source Ref. No.","Source Type","Source Subtype",
          "Source Batch Name","Source Prod. Order Line");
        ReqLineReserve.FilterReservFor(ReservEntry,Rec);
        ReservEntry.DeleteAll(true);

        if not ("Action Message" = "Action Message"::Cancel) then begin
          BlockDynamicTracking(true);
          if TrySourceType = TrySourceType::Production then
            BlockDynamicTrackingOnComp(true);
          if ProductionExist and AssemblyExist then
            Delete(true);
          BlockDynamicTracking(false);
        end;
    end;

    var
        TempProductionOrder: Record "Production Order" temporary;
        LastTransHeader: Record "Transfer Header";
        TempTransHeaderToPrint: Record "Transfer Header" temporary;
        ReservEntry: Record "Reservation Entry";
        TempDocumentEntry: Record "Document Entry" temporary;
        CarryOutAction: Codeunit "Carry Out Action";
        CalcProdOrder: Codeunit "Calculate Prod. Order";
        ReservMgt: Codeunit "Reservation Management";
        ReqLineReserve: Codeunit "Req. Line-Reserve";
        ReservePlanningComponent: Codeunit "Plng. Component-Reserve";
        CheckDateConflict: Codeunit "Reservation-Check Date Confl.";
        PrintOrder: Boolean;
        SplitTransferOrders: Boolean;
        ProductionExist: Boolean;
        AssemblyExist: Boolean;
        TrySourceType: Option Purchase,Transfer,Production,Assembly;
        TryChoice: Option;
        TryWkshTempl: Code[10];
        TryWkshName: Code[10];
        LineNo: Integer;
        CouldNotChangeSupplyTxt: Label 'The supply type could not be changed in order %1, order line %2.', Comment='%1 - Production Order No. or Assembly Header No. or Purchase Header No., %2 - Production Order Line or Assembly Line No. or Purchase Line No.';

    [Scope('Personalization')]
    procedure TryCarryOutAction(SourceType: Option Purchase,Transfer,Production,Assembly;var ReqLine: Record "Requisition Line";Choice: Option;WkshTempl: Code[10];WkshName: Code[10]): Boolean
    begin
        CarryOutAction.SetSplitTransferOrders(SplitTransferOrders);
        CarryOutAction.SetTryParameters(SourceType,Choice,WkshTempl,WkshName);
        exit(CarryOutAction.Run(ReqLine));
    end;

    [Scope('Personalization')]
    procedure SetTryParameters(SourceType: Option Purchase,Transfer,Production,Assembly;Choice: Option;WkshTempl: Code[10];WkshName: Code[10])
    begin
        TrySourceType := SourceType;
        TryChoice := Choice;
        TryWkshTempl := WkshTempl;
        TryWkshName := WkshName;
    end;

    [Scope('Personalization')]
    procedure CarryOutProdOrder(ReqLine: Record "Requisition Line";ProdOrderChoice: Option " ",Planned,"Firm Planned","Firm Planned & Print","Copy to Req. Wksh";ProdWkshTempl: Code[10];ProdWkshName: Code[10]): Boolean
    begin
        PrintOrder := ProdOrderChoice = ProdOrderChoice::"Firm Planned & Print";
        case ReqLine."Action Message" of
          ReqLine."Action Message"::New:
            if ProdOrderChoice = ProdOrderChoice::"Copy to Req. Wksh" then
              CarryOutToReqWksh(ReqLine,ProdWkshTempl,ProdWkshName)
            else
              InsertProdOrder(ReqLine,ProdOrderChoice);
          ReqLine."Action Message"::"Change Qty.",
          ReqLine."Action Message"::Reschedule,
          ReqLine."Action Message"::"Resched. & Chg. Qty.":
            exit(ProdOrderChgAndReshedule(ReqLine));
          ReqLine."Action Message"::Cancel:
            DeleteOrderLines(ReqLine);
        end;
        exit(true);
    end;

    [Scope('Personalization')]
    procedure CarryOutTransOrder(ReqLine: Record "Requisition Line";TransOrderChoice: Option " ","Make Trans. Orders","Make Trans. Orders & Print","Copy to Req. Wksh";TransWkshTempName: Code[10];TransJournalName: Code[10])
    begin
        PrintOrder := TransOrderChoice = TransOrderChoice::"Make Trans. Orders & Print";

        if SplitTransferOrders then
          Clear(LastTransHeader);

        if TransOrderChoice = TransOrderChoice::"Copy to Req. Wksh" then
          CarryOutToReqWksh(ReqLine,TransWkshTempName,TransJournalName)
        else
          case ReqLine."Action Message" of
            ReqLine."Action Message"::New:
              InsertTransLine(ReqLine,LastTransHeader);
            ReqLine."Action Message"::"Change Qty.",
            ReqLine."Action Message"::Reschedule,
            ReqLine."Action Message"::"Resched. & Chg. Qty.":
              TransOrderChgAndReshedule(ReqLine);
            ReqLine."Action Message"::Cancel:
              DeleteOrderLines(ReqLine);
          end;
    end;

    procedure CarryOutAsmOrder(ReqLine: Record "Requisition Line";AsmOrderChoice: Option " ","Make Assembly Orders","Make Assembly Orders & Print"): Boolean
    var
        AsmHeader: Record "Assembly Header";
    begin
        PrintOrder := AsmOrderChoice = AsmOrderChoice::"Make Assembly Orders & Print";
        case ReqLine."Action Message" of
          ReqLine."Action Message"::New:
            InsertAsmHeader(ReqLine,AsmHeader);
          ReqLine."Action Message"::"Change Qty.",
          ReqLine."Action Message"::Reschedule,
          ReqLine."Action Message"::"Resched. & Chg. Qty.":
            exit(AsmOrderChgAndReshedule(ReqLine));
          ReqLine."Action Message"::Cancel:
            DeleteOrderLines(ReqLine);
        end;
        exit(true);
    end;

    [Scope('Personalization')]
    procedure CarryOutToReqWksh(ReqLine: Record "Requisition Line";ReqWkshTempName: Code[10];ReqJournalName: Code[10])
    var
        ReqLine2: Record "Requisition Line";
        PlanningComp: Record "Planning Component";
        PlanningRoutingLine: Record "Planning Routing Line";
        ProdOrderCapNeed: Record "Prod. Order Capacity Need";
        PlanningComp2: Record "Planning Component";
        PlanningRoutingLine2: Record "Planning Routing Line";
        ProdOrderCapNeed2: Record "Prod. Order Capacity Need";
        ReqLine3: Record "Requisition Line";
    begin
        ReqLine2 := ReqLine;
        ReqLine2."Worksheet Template Name" := ReqWkshTempName;
        ReqLine2."Journal Batch Name" := ReqJournalName;

        if LineNo = 0 then begin
          // we need to find the last line in worksheet
          ReqLine3.SetCurrentKey("Worksheet Template Name","Journal Batch Name","Line No.");
          ReqLine3.SetRange("Worksheet Template Name",ReqWkshTempName);
          ReqLine3.SetRange("Journal Batch Name",ReqJournalName);
          if ReqLine3.FindLast then
            LineNo := ReqLine3."Line No.";
        end;
        LineNo += 10000;
        ReqLine2."Line No." := LineNo;

        if ReqLine2."Planning Line Origin" = ReqLine2."Planning Line Origin"::"Order Planning" then begin
          ReqLine2."Planning Line Origin" := ReqLine2."Planning Line Origin"::" ";
          ReqLine2.Level := 0;
          ReqLine2.Status := 0;
          ReqLine2.Reserve := false;
          ReqLine2."Demand Type" := 0;
          ReqLine2."Demand Subtype" := 0;
          ReqLine2."Demand Order No." := '';
          ReqLine2."Demand Line No." := 0;
          ReqLine2."Demand Ref. No." := 0;
          ReqLine2."Demand Date" := 0D;
          ReqLine2."Demand Quantity" := 0;
          ReqLine2."Demand Quantity (Base)" := 0;
          ReqLine2."Needed Quantity" := 0;
          ReqLine2."Needed Quantity (Base)" := 0;
          ReqLine2."Qty. per UOM (Demand)" := 0;
          ReqLine2."Unit Of Measure Code (Demand)" := '';
        end;
        ReqLine2.Insert;

        ReqLineReserve.TransferReqLineToReqLine(ReqLine,ReqLine2,0,true);
        if ReqLine.Reserve then
          ReserveBindingOrderToReqline(ReqLine2,ReqLine);

        PlanningComp.SetRange("Worksheet Template Name",ReqLine."Worksheet Template Name");
        PlanningComp.SetRange("Worksheet Batch Name",ReqLine."Journal Batch Name");
        PlanningComp.SetRange("Worksheet Line No.",ReqLine."Line No.");
        if PlanningComp.Find('-') then
          repeat
            PlanningComp2 := PlanningComp;
            PlanningComp2."Worksheet Template Name" := ReqWkshTempName;
            PlanningComp2."Worksheet Batch Name" := ReqJournalName;

            if PlanningComp2."Planning Line Origin" = PlanningComp2."Planning Line Origin"::"Order Planning" then
              PlanningComp2."Planning Line Origin" := PlanningComp2."Planning Line Origin"::" ";
            PlanningComp2."Dimension Set ID" := ReqLine2."Dimension Set ID";
            PlanningComp2.Insert;
          until PlanningComp.Next = 0;

        PlanningRoutingLine.SetRange("Worksheet Template Name",ReqLine."Worksheet Template Name");
        PlanningRoutingLine.SetRange("Worksheet Batch Name",ReqLine."Journal Batch Name");
        PlanningRoutingLine.SetRange("Worksheet Line No.",ReqLine."Line No.");
        if PlanningRoutingLine.Find('-') then
          repeat
            PlanningRoutingLine2 := PlanningRoutingLine;
            PlanningRoutingLine2."Worksheet Template Name" := ReqWkshTempName;
            PlanningRoutingLine2."Worksheet Batch Name" := ReqJournalName;

            PlanningRoutingLine2.Insert;
          until PlanningRoutingLine.Next = 0;

        ProdOrderCapNeed.SetRange("Worksheet Template Name",ReqLine."Worksheet Template Name");
        ProdOrderCapNeed.SetRange("Worksheet Batch Name",ReqLine."Journal Batch Name");
        ProdOrderCapNeed.SetRange("Worksheet Line No.",ReqLine."Line No.");
        if ProdOrderCapNeed.Find('-') then
          repeat
            ProdOrderCapNeed2 := ProdOrderCapNeed;
            ProdOrderCapNeed2."Worksheet Template Name" := ReqWkshTempName;
            ProdOrderCapNeed2."Worksheet Batch Name" := ReqJournalName;

            ProdOrderCapNeed.Delete;
            ProdOrderCapNeed2.Insert;
          until ProdOrderCapNeed.Next = 0;
    end;

    [Scope('Personalization')]
    procedure GetTransferOrdersToPrint(var TransferHeader: Record "Transfer Header")
    begin
        if TempTransHeaderToPrint.FindSet then
          repeat
            TransferHeader := TempTransHeaderToPrint;
            TransferHeader.Insert;
          until TempTransHeaderToPrint.Next = 0;
    end;

    [Scope('Personalization')]
    procedure ProdOrderChgAndReshedule(ReqLine: Record "Requisition Line"): Boolean
    var
        ProdOrderLine: Record "Prod. Order Line";
        PlanningComponent: Record "Planning Component";
        ProdOrderCapNeed: Record "Prod. Order Capacity Need";
        ProdOrderComp: Record "Prod. Order Component";
        ProdOrder: Record "Production Order";
    begin
        with ReqLine do begin
          TestField("Ref. Order Type","Ref. Order Type"::"Prod. Order");
          ProdOrderLine.LockTable;
          if ProdOrderLine.Get("Ref. Order Status","Ref. Order No.","Ref. Line No.") then begin
            ProdOrderCapNeed.SetCurrentKey("Worksheet Template Name","Worksheet Batch Name","Worksheet Line No.");
            ProdOrderCapNeed.SetRange("Worksheet Template Name","Worksheet Template Name");
            ProdOrderCapNeed.SetRange("Worksheet Batch Name","Journal Batch Name");
            ProdOrderCapNeed.SetRange("Worksheet Line No.","Line No.");
            ProdOrderCapNeed.DeleteAll;
            ProdOrderLine.BlockDynamicTracking(true);
            ProdOrderLine.Validate(Quantity,Quantity);
            ProdOrderLine."Ending Time" := "Ending Time";
            ProdOrderLine."Due Date" := "Due Date";
            ProdOrderLine.Validate("Planning Flexibility","Planning Flexibility");
            ProdOrderLine.Validate("Ending Date","Ending Date");
            ReqLineReserve.TransferPlanningLineToPOLine(ReqLine,ProdOrderLine,0,true);
            ReqLineReserve.UpdateDerivedTracking(ReqLine);
            ReservMgt.SetProdOrderLine(ProdOrderLine);
            ReservMgt.DeleteReservEntries(false,ProdOrderLine."Remaining Qty. (Base)");
            ReservMgt.ClearSurplus;
            ReservMgt.AutoTrack(ProdOrderLine."Remaining Qty. (Base)");
            PlanningComponent.SetRange("Worksheet Template Name","Worksheet Template Name");
            PlanningComponent.SetRange("Worksheet Batch Name","Journal Batch Name");
            PlanningComponent.SetRange("Worksheet Line No.","Line No.");
            if PlanningComponent.Find('-') then
              repeat
                if ProdOrderComp.Get(
                     ProdOrderLine.Status,ProdOrderLine."Prod. Order No.",ProdOrderLine."Line No.",PlanningComponent."Line No.")
                then begin
                  ReservePlanningComponent.TransferPlanningCompToPOComp(PlanningComponent,ProdOrderComp,0,true);
                  ReservePlanningComponent.UpdateDerivedTracking(PlanningComponent);
                  ReservMgt.SetProdOrderComponent(ProdOrderComp);
                  ReservMgt.DeleteReservEntries(false,ProdOrderComp."Remaining Qty. (Base)");
                  ReservMgt.ClearSurplus;
                  ReservMgt.AutoTrack(ProdOrderComp."Remaining Qty. (Base)");
                  CheckDateConflict.ProdOrderComponentCheck(ProdOrderComp,false,false);
                end else
                  PlanningComponent.Delete(true);
              until PlanningComponent.Next = 0;

            if "Planning Level" = 0 then
              if ProdOrder.Get("Ref. Order Status","Ref. Order No.") then begin
                ProdOrder.Quantity := Quantity;
                ProdOrder."Starting Time" := "Starting Time";
                ProdOrder."Starting Date" := "Starting Date";
                ProdOrder."Ending Time" := "Ending Time";
                ProdOrder."Ending Date" := "Ending Date";
                ProdOrder."Due Date" := "Due Date";
                ProdOrder.Modify;

                FinalizeOrderHeader(ProdOrder);
              end;
            OnAfterProdOrderChgAndReshedule(ReqLine,ProdOrderLine);
          end else begin
            Message(StrSubstNo(CouldNotChangeSupplyTxt,"Ref. Order No.","Ref. Line No."));
            exit(false);
          end;
        end;
        exit(true);
    end;

    [Scope('Personalization')]
    procedure PurchOrderChgAndReshedule(ReqLine: Record "Requisition Line")
    var
        PurchLine: Record "Purchase Line";
        PurchHeader: Record "Purchase Header";
    begin
        ReqLine.TestField("Ref. Order Type",ReqLine."Ref. Order Type"::Purchase);
        if PurchLine.Get(
             PurchLine."Document Type"::Order,
             ReqLine."Ref. Order No.",
             ReqLine."Ref. Line No.")
        then begin
          PurchLine.BlockDynamicTracking(true);
          PurchLine.Validate(Quantity,ReqLine.Quantity);
          PurchLine.Validate("Expected Receipt Date",ReqLine."Due Date");
          PurchLine.Validate("Planning Flexibility",ReqLine."Planning Flexibility");
          OnPurchOrderChgAndResheduleOnBeforePurchLineModify(ReqLine,PurchLine);
          PurchLine.Modify(true);
          ReqLineReserve.TransferReqLineToPurchLine(ReqLine,PurchLine,0,true);
          ReqLineReserve.UpdateDerivedTracking(ReqLine);
          ReservMgt.SetPurchLine(PurchLine);
          ReservMgt.DeleteReservEntries(false,PurchLine."Outstanding Qty. (Base)");
          ReservMgt.ClearSurplus;
          ReservMgt.AutoTrack(PurchLine."Outstanding Qty. (Base)");

          PurchHeader.Get(PurchLine."Document Type",PurchLine."Document No.");
          PrintPurchaseOrder(PurchHeader);
        end else
          Error(CouldNotChangeSupplyTxt,ReqLine."Ref. Order No.",ReqLine."Ref. Line No.");
    end;

    [Scope('Personalization')]
    procedure TransOrderChgAndReshedule(ReqLine: Record "Requisition Line")
    var
        TransLine: Record "Transfer Line";
        TransHeader: Record "Transfer Header";
    begin
        ReqLine.TestField("Ref. Order Type",ReqLine."Ref. Order Type"::Transfer);

        if TransLine.Get(ReqLine."Ref. Order No.",ReqLine."Ref. Line No.") then begin
          TransLine.BlockDynamicTracking(true);
          TransLine.Validate(Quantity,ReqLine.Quantity);
          TransLine.Validate("Receipt Date",ReqLine."Due Date");
          TransLine."Shipment Date" := ReqLine."Transfer Shipment Date";
          TransLine.Validate("Planning Flexibility",ReqLine."Planning Flexibility");
          OnTransOrderChgAndResheduleOnBeforeTransLineModify(ReqLine,TransLine);
          TransLine.Modify(true);
          ReqLineReserve.TransferReqLineToTransLine(ReqLine,TransLine,0,true);
          ReqLineReserve.UpdateDerivedTracking(ReqLine);
          ReservMgt.SetTransferLine(TransLine,0);
          ReservMgt.DeleteReservEntries(false,TransLine."Outstanding Qty. (Base)");
          ReservMgt.ClearSurplus;
          ReservMgt.AutoTrack(TransLine."Outstanding Qty. (Base)");
          ReservMgt.SetTransferLine(TransLine,1);
          ReservMgt.DeleteReservEntries(false,TransLine."Outstanding Qty. (Base)");
          ReservMgt.ClearSurplus;
          ReservMgt.AutoTrack(TransLine."Outstanding Qty. (Base)");
          TransHeader.Get(TransLine."Document No.");
          PrintTransferOrder(TransHeader);
        end;
    end;

    [Scope('Personalization')]
    procedure AsmOrderChgAndReshedule(ReqLine: Record "Requisition Line"): Boolean
    var
        AsmHeader: Record "Assembly Header";
        PlanningComponent: Record "Planning Component";
        AsmLine: Record "Assembly Line";
    begin
        with ReqLine do begin
          TestField("Ref. Order Type","Ref. Order Type"::Assembly);
          AsmHeader.LockTable;
          if AsmHeader.Get(AsmHeader."Document Type"::Order,"Ref. Order No.") then begin
            AsmHeader.SetWarningsOff;
            AsmHeader.Validate(Quantity,Quantity);
            AsmHeader.Validate("Planning Flexibility","Planning Flexibility");
            AsmHeader.Validate("Due Date","Due Date");
            OnAsmOrderChgAndResheduleOnBeforeAsmHeaderModify(ReqLine,AsmHeader);
            AsmHeader.Modify(true);
            ReqLineReserve.TransferPlanningLineToAsmHdr(ReqLine,AsmHeader,0,true);
            ReqLineReserve.UpdateDerivedTracking(ReqLine);
            ReservMgt.SetAssemblyHeader(AsmHeader);
            ReservMgt.DeleteReservEntries(false,AsmHeader."Remaining Quantity (Base)");
            ReservMgt.ClearSurplus;
            ReservMgt.AutoTrack(AsmHeader."Remaining Quantity (Base)");

            PlanningComponent.SetRange("Worksheet Template Name","Worksheet Template Name");
            PlanningComponent.SetRange("Worksheet Batch Name","Journal Batch Name");
            PlanningComponent.SetRange("Worksheet Line No.","Line No.");
            if PlanningComponent.Find('-') then
              repeat
                if AsmLine.Get(AsmHeader."Document Type",AsmHeader."No.",PlanningComponent."Line No.") then begin
                  ReservePlanningComponent.TransferPlanningCompToAsmLine(PlanningComponent,AsmLine,0,true);
                  ReservePlanningComponent.UpdateDerivedTracking(PlanningComponent);
                  ReservMgt.SetAssemblyLine(AsmLine);
                  ReservMgt.DeleteReservEntries(false,AsmLine."Remaining Quantity (Base)");
                  ReservMgt.ClearSurplus;
                  ReservMgt.AutoTrack(AsmLine."Remaining Quantity (Base)");
                  CheckDateConflict.AssemblyLineCheck(AsmLine,false);
                end else
                  PlanningComponent.Delete(true);
              until PlanningComponent.Next = 0;

            PrintAsmOrder(AsmHeader);
          end else begin
            Message(StrSubstNo(CouldNotChangeSupplyTxt,"Ref. Order No.","Ref. Line No."));
            exit(false);
          end;
        end;
        exit(true);
    end;

    [Scope('Personalization')]
    procedure DeleteOrderLines(ReqLine: Record "Requisition Line")
    var
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        TransHeader: Record "Transfer Header";
        TransLine: Record "Transfer Line";
        AsmHeader: Record "Assembly Header";
    begin
        case ReqLine."Ref. Order Type" of
          ReqLine."Ref. Order Type"::"Prod. Order":
            begin
              ProdOrderLine.SetCurrentKey(Status,"Prod. Order No.","Line No.");
              ProdOrderLine.SetFilter("Item No.",'<>%1','');
              ProdOrderLine.SetRange(Status,ReqLine."Ref. Order Status");
              ProdOrderLine.SetRange("Prod. Order No.",ReqLine."Ref. Order No.");
              if ProdOrderLine.Count in [0,1] then begin
                if ProdOrder.Get(ReqLine."Ref. Order Status",ReqLine."Ref. Order No.") then
                  ProdOrder.Delete(true);
              end else begin
                ProdOrderLine.SetRange("Line No.",ReqLine."Ref. Line No.");
                if ProdOrderLine.FindFirst then
                  ProdOrderLine.Delete(true);
              end;
            end;
          ReqLine."Ref. Order Type"::Purchase:
            begin
              PurchLine.SetCurrentKey("Document Type","Document No.","Line No.");
              PurchLine.SetFilter(Type,'<>%1',PurchLine.Type::" ");
              PurchLine.SetRange("Document Type",PurchLine."Document Type"::Order);
              PurchLine.SetRange("Document No.",ReqLine."Ref. Order No.");
              if PurchLine.Count in [0,1] then begin
                if PurchHeader.Get(PurchHeader."Document Type"::Order,ReqLine."Ref. Order No.") then
                  PurchHeader.Delete(true);
              end else begin
                PurchLine.SetRange("Line No.",ReqLine."Ref. Line No.");
                if PurchLine.FindFirst then
                  PurchLine.Delete(true);
              end;
            end;
          ReqLine."Ref. Order Type"::Transfer:
            begin
              TransLine.SetCurrentKey("Document No.","Line No.");
              TransLine.SetRange("Document No.",ReqLine."Ref. Order No.");
              if TransLine.Count in [0,1] then begin
                if TransHeader.Get(ReqLine."Ref. Order No.") then
                  TransHeader.Delete(true);
              end else begin
                TransLine.SetRange("Line No.",ReqLine."Ref. Line No.");
                if TransLine.FindFirst then
                  TransLine.Delete(true);
              end;
            end;
          ReqLine."Ref. Order Type"::Assembly:
            begin
              AsmHeader.Get(AsmHeader."Document Type"::Order,ReqLine."Ref. Order No.");
              AsmHeader.Delete(true);
            end;
        end;
    end;

    [Scope('Personalization')]
    procedure InsertProdOrder(ReqLine: Record "Requisition Line";ProdOrderChoice: Option " ",Planned,"Firm Planned","Firm Planned & Print")
    var
        MfgSetup: Record "Manufacturing Setup";
        Item: Record Item;
        ProdOrder: Record "Production Order";
        HeaderExist: Boolean;
    begin
        Item.Get(ReqLine."No.");
        MfgSetup.Get;
        if FindTempProdOrder(ReqLine) then
          HeaderExist := ProdOrder.Get(TempProductionOrder.Status,TempProductionOrder."No.");

        if not HeaderExist then begin
          case ProdOrderChoice of
            ProdOrderChoice::Planned:
              MfgSetup.TestField("Planned Order Nos.");
            ProdOrderChoice::"Firm Planned",
            ProdOrderChoice::"Firm Planned & Print":
              MfgSetup.TestField("Firm Planned Order Nos.");
          end;

          ProdOrder.Init;
          if ProdOrderChoice = ProdOrderChoice::"Firm Planned & Print" then
            ProdOrder.Status := ProdOrder.Status::"Firm Planned"
          else
            ProdOrder.Status := ProdOrderChoice;
          ProdOrder."No. Series" := ProdOrder.GetNoSeriesCode;
          if ProdOrder."No. Series" = ReqLine."No. Series" then
            ProdOrder."No." := ReqLine."Ref. Order No.";
          ProdOrder.Insert(true);
          ProdOrder."Source Type" := ProdOrder."Source Type"::Item;
          ProdOrder."Source No." := ReqLine."No.";
          ProdOrder.Validate(Description,ReqLine.Description);
          ProdOrder."Description 2" := ReqLine."Description 2";
          ProdOrder."Creation Date" := Today;
          ProdOrder."Last Date Modified" := Today;
          ProdOrder."Inventory Posting Group" := Item."Inventory Posting Group";
          ProdOrder."Gen. Prod. Posting Group" := ReqLine."Gen. Prod. Posting Group";
          ProdOrder."Gen. Bus. Posting Group" := ReqLine."Gen. Business Posting Group";
          ProdOrder."Due Date" := ReqLine."Due Date";
          ProdOrder."Starting Time" := ReqLine."Starting Time";
          ProdOrder."Starting Date" := ReqLine."Starting Date";
          ProdOrder."Ending Time" := ReqLine."Ending Time";
          ProdOrder."Ending Date" := ReqLine."Ending Date";
          ProdOrder."Location Code" := ReqLine."Location Code";
          ProdOrder."Bin Code" := ReqLine."Bin Code";
          ProdOrder."Low-Level Code" := ReqLine."Low-Level Code";
          ProdOrder."Routing No." := ReqLine."Routing No.";
          ProdOrder.Quantity := ReqLine.Quantity;
          ProdOrder."Unit Cost" := ReqLine."Unit Cost";
          ProdOrder."Cost Amount" := ReqLine."Cost Amount";
          ProdOrder."Shortcut Dimension 1 Code" := ReqLine."Shortcut Dimension 1 Code";
          ProdOrder."Shortcut Dimension 2 Code" := ReqLine."Shortcut Dimension 2 Code";
          ProdOrder."Dimension Set ID" := ReqLine."Dimension Set ID";
          ProdOrder.UpdateDatetime;
          OnInsertProdOrderWithReqLine(ProdOrder,ReqLine);
          ProdOrder.Modify;
          InsertTempProdOrder(ReqLine,ProdOrder);
        end;
        InsertProdOrderLine(ReqLine,ProdOrder,Item);

        OnAfterInsertProdOrder(ProdOrder,ProdOrderChoice,ReqLine);
    end;

    [Scope('Personalization')]
    procedure InsertProdOrderLine(ReqLine: Record "Requisition Line";ProdOrder: Record "Production Order";Item: Record Item)
    var
        ProdOrderLine: Record "Prod. Order Line";
        NextLineNo: Integer;
    begin
        ProdOrderLine.SetRange("Prod. Order No.",ProdOrder."No.");
        ProdOrderLine.SetRange(Status,ProdOrder.Status);
        ProdOrderLine.LockTable;
        if ProdOrderLine.FindLast then
          NextLineNo := ProdOrderLine."Line No." + 10000
        else
          NextLineNo := 10000;

        ProdOrderLine.Init;
        ProdOrderLine.BlockDynamicTracking(true);
        ProdOrderLine.Status := ProdOrder.Status;
        ProdOrderLine."Prod. Order No." := ProdOrder."No.";
        ProdOrderLine."Line No." := NextLineNo;
        ProdOrderLine."Item No." := ReqLine."No.";
        ProdOrderLine.Validate("Unit of Measure Code",ReqLine."Unit of Measure Code");
        ProdOrderLine."Production BOM Version Code" := ReqLine."Production BOM Version Code";
        ProdOrderLine."Routing Version Code" := ReqLine."Routing Version Code";
        ProdOrderLine."Routing Type" := ReqLine."Routing Type";
        ProdOrderLine."Routing Reference No." := ProdOrderLine."Line No.";
        ProdOrderLine.Description := ReqLine.Description;
        ProdOrderLine."Description 2" := ReqLine."Description 2";
        ProdOrderLine."Variant Code" := ReqLine."Variant Code";
        ProdOrderLine."Location Code" := ReqLine."Location Code";
        if ReqLine."Bin Code" <> '' then
          ProdOrderLine.Validate("Bin Code",ReqLine."Bin Code")
        else
          CalcProdOrder.SetProdOrderLineBinCodeFromRoute(ProdOrderLine,ProdOrder."Location Code",ProdOrder."Routing No.");
        ProdOrderLine."Scrap %" := ReqLine."Scrap %";
        ProdOrderLine."Production BOM No." := ReqLine."Production BOM No.";
        ProdOrderLine."Inventory Posting Group" := Item."Inventory Posting Group";
        ProdOrderLine.Validate("Unit Cost",ReqLine."Unit Cost");
        ProdOrderLine."Routing No." := ReqLine."Routing No.";
        ProdOrderLine."Starting Time" := ReqLine."Starting Time";
        ProdOrderLine."Starting Date" := ReqLine."Starting Date";
        ProdOrderLine."Ending Time" := ReqLine."Ending Time";
        ProdOrderLine."Ending Date" := ReqLine."Ending Date";
        ProdOrderLine."Due Date" := ReqLine."Due Date";
        ProdOrderLine.Status := ProdOrder.Status;
        ProdOrderLine."Planning Level Code" := ReqLine."Planning Level";
        ProdOrderLine."Indirect Cost %" := ReqLine."Indirect Cost %";
        ProdOrderLine."Overhead Rate" := ReqLine."Overhead Rate";
        ProdOrderLine.Validate(Quantity,ReqLine.Quantity);
        if not (ProdOrder.Status = ProdOrder.Status::Planned) then
          ProdOrderLine."Planning Flexibility" := ReqLine."Planning Flexibility";
        ProdOrderLine.UpdateDatetime;
        ProdOrderLine."Shortcut Dimension 1 Code" := ReqLine."Shortcut Dimension 1 Code";
        ProdOrderLine."Shortcut Dimension 2 Code" := ReqLine."Shortcut Dimension 2 Code";
        ProdOrderLine."Dimension Set ID" := ReqLine."Dimension Set ID";
        OnInsertProdOrderLineWithReqLine(ProdOrderLine,ReqLine);
        ProdOrderLine.Insert;

        ReqLineReserve.TransferPlanningLineToPOLine(ReqLine,ProdOrderLine,ReqLine."Net Quantity (Base)",false);
        if ReqLine.Reserve and not (ProdOrderLine.Status = ProdOrderLine.Status::Planned) then
          ReserveBindingOrderToProd(ProdOrderLine,ReqLine);

        ProdOrderLine.Modify;
        if TransferRouting(ReqLine,ProdOrder,ProdOrderLine."Routing No.",ProdOrderLine."Routing Reference No.") then begin
          CalcProdOrder.SetProdOrderLineBinCodeFromPlanningRtngLines(ProdOrderLine,ReqLine);
          ProdOrderLine.Modify;
        end;
        TransferBOM(ReqLine,ProdOrder,ProdOrderLine."Line No.");
        TransferCapNeed(ReqLine,ProdOrder,ProdOrderLine."Routing No.",ProdOrderLine."Routing Reference No.");

        if ProdOrderLine."Planning Level Code" > 0 then
          UpdateComponentLink(ProdOrderLine);

        OnAfterInsertProdOrderLine(ReqLine,ProdOrder,ProdOrderLine,Item);

        FinalizeOrderHeader(ProdOrder);
    end;

    procedure InsertAsmHeader(ReqLine: Record "Requisition Line";var AsmHeader: Record "Assembly Header")
    var
        BOMComp: Record "BOM Component";
        Item: Record Item;
    begin
        Item.Get(ReqLine."No.");
        AsmHeader.Init;
        AsmHeader."Document Type" := AsmHeader."Document Type"::Order;
        AsmHeader.Insert(true);
        AsmHeader.SetWarningsOff;
        AsmHeader.Validate("Item No.",ReqLine."No.");
        AsmHeader.Validate("Unit of Measure Code",ReqLine."Unit of Measure Code");
        AsmHeader.Description := ReqLine.Description;
        AsmHeader."Description 2" := ReqLine."Description 2";
        AsmHeader."Variant Code" := ReqLine."Variant Code";
        AsmHeader."Location Code" := ReqLine."Location Code";
        AsmHeader."Inventory Posting Group" := Item."Inventory Posting Group";
        AsmHeader.Validate("Unit Cost",ReqLine."Unit Cost");
        AsmHeader."Due Date" := ReqLine."Due Date";
        AsmHeader."Starting Date" := ReqLine."Starting Date";
        AsmHeader."Ending Date" := ReqLine."Ending Date";

        AsmHeader.Quantity := ReqLine.Quantity;
        AsmHeader."Quantity (Base)" := ReqLine."Quantity (Base)";
        AsmHeader.InitRemainingQty;
        AsmHeader.InitQtyToAssemble;
        if ReqLine."Bin Code" <> '' then
          AsmHeader."Bin Code" := ReqLine."Bin Code"
        else
          AsmHeader.GetDefaultBin;

        AsmHeader."Planning Flexibility" := ReqLine."Planning Flexibility";
        AsmHeader."Shortcut Dimension 1 Code" := ReqLine."Shortcut Dimension 1 Code";
        AsmHeader."Shortcut Dimension 2 Code" := ReqLine."Shortcut Dimension 2 Code";
        AsmHeader."Dimension Set ID" := ReqLine."Dimension Set ID";
        ReqLineReserve.TransferPlanningLineToAsmHdr(ReqLine,AsmHeader,ReqLine."Net Quantity (Base)",false);
        if ReqLine.Reserve then
          ReserveBindingOrderToAsm(AsmHeader,ReqLine);
        AsmHeader.Modify;

        TransferAsmPlanningComp(ReqLine,AsmHeader);

        BOMComp.SetRange("Parent Item No.",ReqLine."No.");
        BOMComp.SetRange(Type,BOMComp.Type::Resource);
        if BOMComp.Find('-') then
          repeat
            AsmHeader.AddBOMLine(BOMComp);
          until BOMComp.Next = 0;

        OnAfterInsertAsmHeader(ReqLine,AsmHeader);

        PrintAsmOrder(AsmHeader);
        TempDocumentEntry.Init;
        TempDocumentEntry."Table ID" := DATABASE::"Assembly Header";
        TempDocumentEntry."Document Type" := AsmHeader."Document Type"::Order;
        TempDocumentEntry."Document No." := AsmHeader."No.";
        TempDocumentEntry."Entry No." := TempDocumentEntry.Count + 1;
        TempDocumentEntry.Insert;
    end;

    [Scope('Personalization')]
    procedure TransferAsmPlanningComp(ReqLine: Record "Requisition Line";AsmHeader: Record "Assembly Header")
    var
        AsmLine: Record "Assembly Line";
        PlanningComponent: Record "Planning Component";
    begin
        PlanningComponent.SetRange("Worksheet Template Name",ReqLine."Worksheet Template Name");
        PlanningComponent.SetRange("Worksheet Batch Name",ReqLine."Journal Batch Name");
        PlanningComponent.SetRange("Worksheet Line No.",ReqLine."Line No.");
        if PlanningComponent.Find('-') then
          repeat
            AsmLine.Init;
            AsmLine."Document Type" := AsmHeader."Document Type";
            AsmLine."Document No." := AsmHeader."No.";
            AsmLine."Line No." := PlanningComponent."Line No.";
            AsmLine.Type := AsmLine.Type::Item;
            AsmLine."Dimension Set ID" := PlanningComponent."Dimension Set ID";
            AsmLine.Validate("No.",PlanningComponent."Item No.");
            AsmLine.Description := PlanningComponent.Description;
            AsmLine."Unit of Measure Code" := PlanningComponent."Unit of Measure Code";
            AsmLine."Lead-Time Offset" := PlanningComponent."Lead-Time Offset";
            AsmLine.Position := PlanningComponent.Position;
            AsmLine."Position 2" := PlanningComponent."Position 2";
            AsmLine."Position 3" := PlanningComponent."Position 3";
            AsmLine."Variant Code" := PlanningComponent."Variant Code";
            AsmLine."Location Code" := PlanningComponent."Location Code";

            AsmLine."Quantity per" := PlanningComponent."Quantity per";
            AsmLine."Qty. per Unit of Measure" := PlanningComponent."Qty. per Unit of Measure";
            AsmLine.Quantity := PlanningComponent."Expected Quantity";
            AsmLine."Quantity (Base)" := PlanningComponent."Expected Quantity (Base)";
            AsmLine.InitRemainingQty;
            AsmLine.InitQtyToConsume;
            if PlanningComponent."Bin Code" <> '' then
              AsmLine."Bin Code" := PlanningComponent."Bin Code"
            else
              AsmLine.GetDefaultBin;

            AsmLine."Due Date" := PlanningComponent."Due Date";
            AsmLine."Unit Cost" := PlanningComponent."Unit Cost";
            AsmLine."Variant Code" := PlanningComponent."Variant Code";
            AsmLine."Cost Amount" := PlanningComponent."Cost Amount";

            AsmLine."Shortcut Dimension 1 Code" := PlanningComponent."Shortcut Dimension 1 Code";
            AsmLine."Shortcut Dimension 2 Code" := PlanningComponent."Shortcut Dimension 2 Code";

            OnAfterTransferAsmPlanningComp(PlanningComponent,AsmLine);

            AsmLine.Insert;

            ReservePlanningComponent.TransferPlanningCompToAsmLine(PlanningComponent,AsmLine,0,true);
            AsmLine.AutoReserve;
            ReservMgt.SetAssemblyLine(AsmLine);
            ReservMgt.AutoTrack(AsmLine."Remaining Quantity (Base)");
          until PlanningComponent.Next = 0;
    end;

    [Scope('Personalization')]
    procedure InsertTransHeader(ReqLine: Record "Requisition Line";var TransHeader: Record "Transfer Header")
    var
        InvtSetup: Record "Inventory Setup";
    begin
        InvtSetup.Get;
        InvtSetup.TestField("Transfer Order Nos.");

        with ReqLine do begin
          TransHeader.Init;
          TransHeader."No." := '';
          TransHeader."Posting Date" := WorkDate;
          TransHeader.Insert(true);
          TransHeader.Validate("Transfer-from Code","Transfer-from Code");
          TransHeader.Validate("Transfer-to Code","Location Code");
          TransHeader."Receipt Date" := "Due Date";
          TransHeader."Shipment Date" := "Transfer Shipment Date";
          TransHeader."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
          TransHeader."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
          TransHeader."Dimension Set ID" := "Dimension Set ID";
          TransHeader.Modify;
          TempDocumentEntry.Init;
          TempDocumentEntry."Table ID" := DATABASE::"Transfer Header";
          TempDocumentEntry."Document No." := TransHeader."No.";
          TempDocumentEntry."Entry No." := TempDocumentEntry.Count + 1;
          TempDocumentEntry.Insert;
        end;

        if PrintOrder then begin
          TempTransHeaderToPrint."No." := TransHeader."No.";
          TempTransHeaderToPrint.Insert;
        end;
    end;

    [Scope('Personalization')]
    procedure InsertTransLine(ReqLine: Record "Requisition Line";var TransHeader: Record "Transfer Header")
    var
        TransLine: Record "Transfer Line";
        NextLineNo: Integer;
    begin
        if (ReqLine."Transfer-from Code" <> TransHeader."Transfer-from Code") or
           (ReqLine."Location Code" <> TransHeader."Transfer-to Code")
        then
          InsertTransHeader(ReqLine,TransHeader);

        TransLine.SetRange("Document No.",TransHeader."No.");
        if TransLine.FindLast then
          NextLineNo := TransLine."Line No." + 10000
        else
          NextLineNo := 10000;

        TransLine.Init;
        TransLine.BlockDynamicTracking(true);
        TransLine."Document No." := TransHeader."No.";
        TransLine."Line No." := NextLineNo;
        TransLine.Validate("Item No.",ReqLine."No.");
        TransLine.Description := ReqLine.Description;
        TransLine."Description 2" := ReqLine."Description 2";
        TransLine.Validate("Variant Code",ReqLine."Variant Code");
        TransLine.Validate("Transfer-from Code",ReqLine."Transfer-from Code");
        TransLine.Validate("Transfer-to Code",ReqLine."Location Code");
        TransLine.Validate(Quantity,ReqLine.Quantity);
        TransLine.Validate("Unit of Measure Code",ReqLine."Unit of Measure Code");
        TransLine."Shortcut Dimension 1 Code" := ReqLine."Shortcut Dimension 1 Code";
        TransLine."Shortcut Dimension 2 Code" := ReqLine."Shortcut Dimension 2 Code";
        TransLine."Dimension Set ID" := ReqLine."Dimension Set ID";
        TransLine."Receipt Date" := ReqLine."Due Date";
        TransLine."Shipment Date" := ReqLine."Transfer Shipment Date";
        TransLine.Validate("Planning Flexibility",ReqLine."Planning Flexibility");
        OnInsertTransLineWithReqLine(TransLine,ReqLine);
        TransLine.Insert;

        ReqLineReserve.TransferReqLineToTransLine(ReqLine,TransLine,ReqLine."Quantity (Base)",false);
        if ReqLine.Reserve then
          ReserveBindingOrderToTrans(TransLine,ReqLine);
    end;

    [Scope('Personalization')]
    procedure PrintTransferOrders()
    begin
        CarryOutAction.GetTransferOrdersToPrint(TempTransHeaderToPrint);
        if TempTransHeaderToPrint.FindSet then begin
          PrintOrder := true;
          repeat
            PrintTransferOrder(TempTransHeaderToPrint);
          until TempTransHeaderToPrint.Next = 0;

          TempTransHeaderToPrint.DeleteAll;
        end;
    end;

    [Scope('Personalization')]
    procedure PrintTransferOrder(TransHeader: Record "Transfer Header")
    var
        ReportSelection: Record "Report Selections";
        TransHeader2: Record "Transfer Header";
    begin
        if PrintOrder then begin
          TransHeader2 := TransHeader;
          TransHeader2.SetRecFilter;
          ReportSelection.PrintWithGUIYesNoWithCheck(ReportSelection.Usage::Inv1,TransHeader2,false,0);
        end;
    end;

    [Scope('Personalization')]
    procedure PrintPurchaseOrder(PurchHeader: Record "Purchase Header")
    var
        ReportSelection: Record "Report Selections";
        PurchHeader2: Record "Purchase Header";
        PurchSetup: Record "Purchases & Payables Setup";
        PurchLine: Record "Purchase Line";
    begin
        if PrintOrder and (PurchHeader."Buy-from Vendor No." <> '') then begin
          PurchHeader2 := PurchHeader;
          PurchSetup.Get;
          if PurchSetup."Calc. Inv. Discount" then begin
            PurchLine.Reset;
            PurchLine.SetRange("Document Type",PurchHeader."Document Type");
            PurchLine.SetRange("Document No.",PurchHeader."No.");
            PurchLine.FindFirst;
            CODEUNIT.Run(CODEUNIT::"Purch.-Calc.Discount",PurchLine);
          end;
          PurchHeader2.SetRecFilter;
          ReportSelection.PrintWithGUIYesNoWithCheckVendor(
            ReportSelection.Usage::"P.Order",PurchHeader2,false,PurchHeader2.FieldNo("Buy-from Vendor No."));
        end;
    end;

    [Scope('Personalization')]
    procedure PrintAsmOrder(AsmHeader: Record "Assembly Header")
    var
        ReportSelections: Record "Report Selections";
        AsmHeader2: Record "Assembly Header";
    begin
        if PrintOrder and (AsmHeader."Item No." <> '') then begin
          AsmHeader2 := AsmHeader;
          AsmHeader2.SetRecFilter;
          ReportSelections.PrintWithGUIYesNoWithCheck(ReportSelections.Usage::"Asm. Order",AsmHeader2,false,0);
        end;
    end;

    local procedure FinalizeOrderHeader(ProdOrder: Record "Production Order")
    var
        ReportSelection: Record "Report Selections";
        ProdOrder2: Record "Production Order";
    begin
        if PrintOrder and (ProdOrder."No." <> '') then begin
          ProdOrder2 := ProdOrder;
          ProdOrder2.SetRecFilter;
          ReportSelection.PrintWithGUIYesNoWithCheck(ReportSelection.Usage::"Prod. Order",ProdOrder2,false,0);
        end;
    end;

    [Scope('Personalization')]
    procedure TransferRouting(ReqLine: Record "Requisition Line";ProdOrder: Record "Production Order";RoutingNo: Code[20];RoutingRefNo: Integer): Boolean
    var
        WorkCenter: Record "Work Center";
        MachineCenter: Record "Machine Center";
        PlanningRtngLine: Record "Planning Routing Line";
        ProdOrderRtngLine: Record "Prod. Order Routing Line";
        WMSManagement: Codeunit "WMS Management";
        FlushingMethod: Option;
    begin
        PlanningRtngLine.SetRange("Worksheet Template Name",ReqLine."Worksheet Template Name");
        PlanningRtngLine.SetRange("Worksheet Batch Name",ReqLine."Journal Batch Name");
        PlanningRtngLine.SetRange("Worksheet Line No.",ReqLine."Line No.");
        if PlanningRtngLine.Find('-') then
          repeat
            ProdOrderRtngLine.Init;
            ProdOrderRtngLine.Status := ProdOrder.Status;
            ProdOrderRtngLine."Prod. Order No." := ProdOrder."No.";
            ProdOrderRtngLine."Routing No." := RoutingNo;
            ProdOrderRtngLine."Routing Reference No." := RoutingRefNo;
            ProdOrderRtngLine."Operation No." := PlanningRtngLine."Operation No.";
            ProdOrderRtngLine."Next Operation No." := PlanningRtngLine."Next Operation No.";
            ProdOrderRtngLine."Previous Operation No." := PlanningRtngLine."Previous Operation No.";
            ProdOrderRtngLine.Type := PlanningRtngLine.Type;
            ProdOrderRtngLine."No." := PlanningRtngLine."No.";
            ProdOrderRtngLine."Work Center No." := PlanningRtngLine."Work Center No.";
            ProdOrderRtngLine."Work Center Group Code" := PlanningRtngLine."Work Center Group Code";
            ProdOrderRtngLine.Description := PlanningRtngLine.Description;
            ProdOrderRtngLine."Setup Time" := PlanningRtngLine."Setup Time";
            ProdOrderRtngLine."Run Time" := PlanningRtngLine."Run Time";
            ProdOrderRtngLine."Wait Time" := PlanningRtngLine."Wait Time";
            ProdOrderRtngLine."Move Time" := PlanningRtngLine."Move Time";
            ProdOrderRtngLine."Fixed Scrap Quantity" := PlanningRtngLine."Fixed Scrap Quantity";
            ProdOrderRtngLine."Lot Size" := PlanningRtngLine."Lot Size";
            ProdOrderRtngLine."Scrap Factor %" := PlanningRtngLine."Scrap Factor %";
            ProdOrderRtngLine."Setup Time Unit of Meas. Code" := PlanningRtngLine."Setup Time Unit of Meas. Code";
            ProdOrderRtngLine."Run Time Unit of Meas. Code" := PlanningRtngLine."Run Time Unit of Meas. Code";
            ProdOrderRtngLine."Wait Time Unit of Meas. Code" := PlanningRtngLine."Wait Time Unit of Meas. Code";
            ProdOrderRtngLine."Move Time Unit of Meas. Code" := PlanningRtngLine."Move Time Unit of Meas. Code";
            ProdOrderRtngLine."Minimum Process Time" := PlanningRtngLine."Minimum Process Time";
            ProdOrderRtngLine."Maximum Process Time" := PlanningRtngLine."Maximum Process Time";
            ProdOrderRtngLine."Concurrent Capacities" := PlanningRtngLine."Concurrent Capacities";
            ProdOrderRtngLine."Send-Ahead Quantity" := PlanningRtngLine."Send-Ahead Quantity";
            ProdOrderRtngLine."Routing Link Code" := PlanningRtngLine."Routing Link Code";
            ProdOrderRtngLine."Standard Task Code" := PlanningRtngLine."Standard Task Code";
            ProdOrderRtngLine."Unit Cost per" := PlanningRtngLine."Unit Cost per";
            ProdOrderRtngLine.Recalculate := PlanningRtngLine.Recalculate;
            ProdOrderRtngLine."Sequence No. (Forward)" := PlanningRtngLine."Sequence No.(Forward)";
            ProdOrderRtngLine."Sequence No. (Backward)" := PlanningRtngLine."Sequence No.(Backward)";
            ProdOrderRtngLine."Fixed Scrap Qty. (Accum.)" := PlanningRtngLine."Fixed Scrap Qty. (Accum.)";
            ProdOrderRtngLine."Scrap Factor % (Accumulated)" := PlanningRtngLine."Scrap Factor % (Accumulated)";
            ProdOrderRtngLine."Sequence No. (Actual)" := PlanningRtngLine."Sequence No. (Actual)";
            ProdOrderRtngLine."Starting Time" := PlanningRtngLine."Starting Time";
            ProdOrderRtngLine."Starting Date" := PlanningRtngLine."Starting Date";
            ProdOrderRtngLine."Ending Time" := PlanningRtngLine."Ending Time";
            ProdOrderRtngLine."Ending Date" := PlanningRtngLine."Ending Date";
            ProdOrderRtngLine."Unit Cost Calculation" := PlanningRtngLine."Unit Cost Calculation";
            ProdOrderRtngLine."Input Quantity" := PlanningRtngLine."Input Quantity";
            ProdOrderRtngLine."Critical Path" := PlanningRtngLine."Critical Path";
            ProdOrderRtngLine."Direct Unit Cost" := PlanningRtngLine."Direct Unit Cost";
            ProdOrderRtngLine."Indirect Cost %" := PlanningRtngLine."Indirect Cost %";
            ProdOrderRtngLine."Overhead Rate" := PlanningRtngLine."Overhead Rate";
            case ProdOrderRtngLine.Type of
              ProdOrderRtngLine.Type::"Work Center":
                begin
                  WorkCenter.Get(PlanningRtngLine."No.");
                  ProdOrderRtngLine."Flushing Method" := WorkCenter."Flushing Method";
                end;
              ProdOrderRtngLine.Type::"Machine Center":
                begin
                  MachineCenter.Get(ProdOrderRtngLine."No.");
                  ProdOrderRtngLine."Flushing Method" := MachineCenter."Flushing Method";
                end;
            end;
            ProdOrderRtngLine."Expected Operation Cost Amt." := PlanningRtngLine."Expected Operation Cost Amt.";
            ProdOrderRtngLine."Expected Capacity Ovhd. Cost" := PlanningRtngLine."Expected Capacity Ovhd. Cost";
            ProdOrderRtngLine."Expected Capacity Need" := PlanningRtngLine."Expected Capacity Need";

            ProdOrderRtngLine."Location Code" := ReqLine."Location Code";
            ProdOrderRtngLine."From-Production Bin Code" :=
              WMSManagement.GetProdCenterBinCode(PlanningRtngLine.Type,PlanningRtngLine."No.",ReqLine."Location Code",false,0);

            FlushingMethod := ProdOrderRtngLine."Flushing Method";
            if ProdOrderRtngLine."Flushing Method" = ProdOrderRtngLine."Flushing Method"::Manual then
              ProdOrderRtngLine."To-Production Bin Code" := WMSManagement.GetProdCenterBinCode(
                  PlanningRtngLine.Type,PlanningRtngLine."No.",ReqLine."Location Code",true,
                  FlushingMethod)
            else
              ProdOrderRtngLine."Open Shop Floor Bin Code" := WMSManagement.GetProdCenterBinCode(
                  PlanningRtngLine.Type,PlanningRtngLine."No.",ReqLine."Location Code",true,
                  FlushingMethod);

            ProdOrderRtngLine.UpdateDatetime;
            OnAfterTransferPlanningRtngLine(PlanningRtngLine,ProdOrderRtngLine);
            ProdOrderRtngLine.Insert;
            OnAfterProdOrderRtngLineInsert(ProdOrderRtngLine,PlanningRtngLine,ProdOrder,ReqLine);
            CalcProdOrder.TransferTaskInfo(ProdOrderRtngLine,ReqLine."Routing Version Code");
          until PlanningRtngLine.Next = 0;

        exit(not PlanningRtngLine.IsEmpty);
    end;

    [Scope('Personalization')]
    procedure TransferBOM(ReqLine: Record "Requisition Line";ProdOrder: Record "Production Order";ProdOrderLineNo: Integer)
    var
        PlanningComponent: Record "Planning Component";
        ProdOrderComp2: Record "Prod. Order Component";
    begin
        PlanningComponent.SetRange("Worksheet Template Name",ReqLine."Worksheet Template Name");
        PlanningComponent.SetRange("Worksheet Batch Name",ReqLine."Journal Batch Name");
        PlanningComponent.SetRange("Worksheet Line No.",ReqLine."Line No.");
        if PlanningComponent.Find('-') then
          repeat
            ProdOrderComp2.Init;
            ProdOrderComp2.Status := ProdOrder.Status;
            ProdOrderComp2."Prod. Order No." := ProdOrder."No.";
            ProdOrderComp2."Prod. Order Line No." := ProdOrderLineNo;
            ProdOrderComp2."Line No." := PlanningComponent."Line No.";
            ProdOrderComp2."Item No." := PlanningComponent."Item No.";
            ProdOrderComp2.Description := PlanningComponent.Description;
            ProdOrderComp2."Unit of Measure Code" := PlanningComponent."Unit of Measure Code";
            ProdOrderComp2."Quantity per" := PlanningComponent."Quantity per";
            ProdOrderComp2.Quantity := PlanningComponent.Quantity;
            ProdOrderComp2.Position := PlanningComponent.Position;
            ProdOrderComp2."Position 2" := PlanningComponent."Position 2";
            ProdOrderComp2."Position 3" := PlanningComponent."Position 3";
            ProdOrderComp2."Lead-Time Offset" := PlanningComponent."Lead-Time Offset";
            ProdOrderComp2."Routing Link Code" := PlanningComponent."Routing Link Code";
            ProdOrderComp2."Scrap %" := PlanningComponent."Scrap %";
            ProdOrderComp2."Variant Code" := PlanningComponent."Variant Code";
            ProdOrderComp2."Flushing Method" := PlanningComponent."Flushing Method";
            ProdOrderComp2."Location Code" := PlanningComponent."Location Code";
            if  PlanningComponent."Bin Code" <> '' then
              ProdOrderComp2."Bin Code" := PlanningComponent."Bin Code"
            else
              ProdOrderComp2.GetDefaultBin;
            ProdOrderComp2.Length := PlanningComponent.Length;
            ProdOrderComp2.Width := PlanningComponent.Width;
            ProdOrderComp2.Weight := PlanningComponent.Weight;
            ProdOrderComp2.Depth := PlanningComponent.Depth;
            ProdOrderComp2."Calculation Formula" := PlanningComponent."Calculation Formula";
            ProdOrderComp2."Qty. per Unit of Measure" := PlanningComponent."Qty. per Unit of Measure";
            ProdOrderComp2."Quantity (Base)" := PlanningComponent."Quantity (Base)";
            ProdOrderComp2."Due Date" := PlanningComponent."Due Date";
            ProdOrderComp2."Due Time" := PlanningComponent."Due Time";
            ProdOrderComp2."Unit Cost" := PlanningComponent."Unit Cost";
            ProdOrderComp2."Direct Unit Cost" := PlanningComponent."Direct Unit Cost";
            ProdOrderComp2."Indirect Cost %" := PlanningComponent."Indirect Cost %";
            ProdOrderComp2."Variant Code" := PlanningComponent."Variant Code";
            ProdOrderComp2."Overhead Rate" := PlanningComponent."Overhead Rate";
            ProdOrderComp2."Expected Quantity" := PlanningComponent."Expected Quantity";
            ProdOrderComp2."Expected Qty. (Base)" := PlanningComponent."Expected Quantity (Base)";
            ProdOrderComp2."Cost Amount" := PlanningComponent."Cost Amount";
            ProdOrderComp2."Overhead Amount" := PlanningComponent."Overhead Amount";
            ProdOrderComp2."Direct Cost Amount" := PlanningComponent."Direct Cost Amount";
            ProdOrderComp2."Planning Level Code" := PlanningComponent."Planning Level Code";
            if ProdOrderComp2.Status in [ProdOrderComp2.Status::Released,ProdOrderComp2.Status::Finished] then
              ProdOrderComp2.CalcFields("Act. Consumption (Qty)");
            ProdOrderComp2."Remaining Quantity" :=
              ProdOrderComp2."Expected Quantity" - ProdOrderComp2."Act. Consumption (Qty)";
            ProdOrderComp2."Remaining Qty. (Base)" :=
              Round(ProdOrderComp2."Remaining Quantity" * ProdOrderComp2."Qty. per Unit of Measure",0.00001);
            ProdOrderComp2."Shortcut Dimension 1 Code" := PlanningComponent."Shortcut Dimension 1 Code";
            ProdOrderComp2."Shortcut Dimension 2 Code" := PlanningComponent."Shortcut Dimension 2 Code";
            ProdOrderComp2."Dimension Set ID" := PlanningComponent."Dimension Set ID";
            ProdOrderComp2.UpdateDatetime;
            OnAfterTransferPlanningComp(PlanningComponent,ProdOrderComp2);
            ProdOrderComp2.Insert;
            ReservePlanningComponent.TransferPlanningCompToPOComp(PlanningComponent,ProdOrderComp2,0,true);
            if ProdOrderComp2.Status in [ProdOrderComp2.Status::"Firm Planned",ProdOrderComp2.Status::Released] then
              ProdOrderComp2.AutoReserve;

            ReservMgt.SetProdOrderComponent(ProdOrderComp2);
            ReservMgt.AutoTrack(ProdOrderComp2."Remaining Qty. (Base)");
          until PlanningComponent.Next = 0;
    end;

    [Scope('Personalization')]
    procedure TransferCapNeed(ReqLine: Record "Requisition Line";ProdOrder: Record "Production Order";RoutingNo: Code[20];RoutingRefNo: Integer)
    var
        ProdOrderCapNeed: Record "Prod. Order Capacity Need";
        NewProdOrderCapNeed: Record "Prod. Order Capacity Need";
    begin
        ProdOrderCapNeed.SetCurrentKey("Worksheet Template Name","Worksheet Batch Name","Worksheet Line No.");
        ProdOrderCapNeed.SetRange("Worksheet Template Name",ReqLine."Worksheet Template Name");
        ProdOrderCapNeed.SetRange("Worksheet Batch Name",ReqLine."Journal Batch Name");
        ProdOrderCapNeed.SetRange("Worksheet Line No.",ReqLine."Line No.");
        if ProdOrderCapNeed.Find('-') then
          repeat
            NewProdOrderCapNeed.Init;
            NewProdOrderCapNeed := ProdOrderCapNeed;
            NewProdOrderCapNeed."Requested Only" := false;
            NewProdOrderCapNeed.Status := ProdOrder.Status;
            NewProdOrderCapNeed."Prod. Order No." := ProdOrder."No.";
            NewProdOrderCapNeed."Routing No." := RoutingNo;
            NewProdOrderCapNeed."Routing Reference No." := RoutingRefNo;
            NewProdOrderCapNeed."Worksheet Template Name" := '';
            NewProdOrderCapNeed."Worksheet Batch Name" := '';
            NewProdOrderCapNeed."Worksheet Line No." := 0;
            NewProdOrderCapNeed.UpdateDatetime;
            NewProdOrderCapNeed.Insert;
          until ProdOrderCapNeed.Next = 0;
    end;

    [Scope('Personalization')]
    procedure UpdateComponentLink(ProdOrderLine: Record "Prod. Order Line")
    var
        ProdOrderComp: Record "Prod. Order Component";
    begin
        ProdOrderComp.SetCurrentKey(Status,"Prod. Order No.","Prod. Order Line No.","Item No.");
        ProdOrderComp.SetRange(Status,ProdOrderLine.Status);
        ProdOrderComp.SetRange("Prod. Order No.",ProdOrderLine."Prod. Order No.");
        ProdOrderComp.SetRange("Item No.",ProdOrderLine."Item No.");
        if ProdOrderComp.Find('-') then
          repeat
            ProdOrderComp."Supplied-by Line No." := ProdOrderLine."Line No.";
            ProdOrderComp.Modify;
          until ProdOrderComp.Next = 0;
    end;

    procedure SetCreatedDocumentBuffer(var TempDocumentEntryNew: Record "Document Entry" temporary)
    begin
        TempDocumentEntry.Copy(TempDocumentEntryNew,true);
    end;

    local procedure InsertTempProdOrder(var RequisitionLine: Record "Requisition Line";var NewProdOrder: Record "Production Order")
    begin
        if TempProductionOrder.Get(NewProdOrder.Status,NewProdOrder."No.") then
          exit;

        TempDocumentEntry.Init;
        TempDocumentEntry."Table ID" := DATABASE::"Production Order";
        TempDocumentEntry."Document Type" := NewProdOrder.Status;
        TempDocumentEntry."Document No." := NewProdOrder."No.";
        TempDocumentEntry."Entry No." := TempDocumentEntry.Count + 1;
        TempDocumentEntry.Insert;

        TempProductionOrder := NewProdOrder;
        if RequisitionLine."Ref. Order Status" = RequisitionLine."Ref. Order Status"::Planned then begin
          TempProductionOrder."Planned Order No." := RequisitionLine."Ref. Order No.";
          TempProductionOrder.Insert;
        end;
    end;

    local procedure FindTempProdOrder(var RequisitionLine: Record "Requisition Line"): Boolean
    begin
        if RequisitionLine."Ref. Order Status" = RequisitionLine."Ref. Order Status"::Planned then begin
          TempProductionOrder.SetRange("Planned Order No.",RequisitionLine."Ref. Order No.");
          exit(TempProductionOrder.FindFirst);
        end;
    end;

    [Scope('Personalization')]
    procedure SetPrintOrder(OrderPrinting: Boolean)
    begin
        PrintOrder := OrderPrinting;
    end;

    [Scope('Personalization')]
    procedure SetSplitTransferOrders(Split: Boolean)
    begin
        SplitTransferOrders := Split;
    end;

    [Scope('Personalization')]
    procedure ReserveBindingOrderToProd(var ProdOrderLine: Record "Prod. Order Line";var ReqLine: Record "Requisition Line")
    var
        SalesLine: Record "Sales Line";
        ProdOrderComp: Record "Prod. Order Component";
        AsmLine: Record "Assembly Line";
        SalesLineReserve: Codeunit "Sales Line-Reserve";
        ProdOrderCompReserve: Codeunit "Prod. Order Comp.-Reserve";
        AsmLineReserve: Codeunit "Assembly Line-Reserve";
        ReservQty: Decimal;
        ReservQtyBase: Decimal;
    begin
        ProdOrderLine.CalcFields("Reserved Quantity","Reserved Qty. (Base)");
        if ProdOrderLine."Remaining Qty. (Base)" - ProdOrderLine."Reserved Qty. (Base)" >
           ReqLine."Demand Quantity (Base)"
        then begin
          ReservQty := ReqLine."Demand Quantity";
          ReservQtyBase := ReqLine."Demand Quantity (Base)";
        end else begin
          ReservQty := ProdOrderLine."Remaining Quantity" - ProdOrderLine."Reserved Quantity";
          ReservQtyBase := ProdOrderLine."Remaining Qty. (Base)" - ProdOrderLine."Reserved Qty. (Base)";
        end;

        case ReqLine."Demand Type" of
          DATABASE::"Prod. Order Component":
            begin
              ProdOrderComp.Get(
                ReqLine."Demand Subtype",ReqLine."Demand Order No.",ReqLine."Demand Line No.",ReqLine."Demand Ref. No.");
              ProdOrderCompReserve.BindToProdOrder(ProdOrderComp,ProdOrderLine,ReservQty,ReservQtyBase);
            end;
          DATABASE::"Sales Line":
            begin
              SalesLine.Get(ReqLine."Demand Subtype",ReqLine."Demand Order No.",ReqLine."Demand Line No.");
              SalesLineReserve.BindToProdOrder(SalesLine,ProdOrderLine,ReservQty,ReservQtyBase);
              if SalesLine.Reserve = SalesLine.Reserve::Never then begin
                SalesLine.Reserve := SalesLine.Reserve::Optional;
                SalesLine.Modify;
              end;
            end;
          DATABASE::"Assembly Line":
            begin
              AsmLine.Get(ReqLine."Demand Subtype",ReqLine."Demand Order No.",ReqLine."Demand Line No.");
              AsmLineReserve.BindToProdOrder(AsmLine,ProdOrderLine,ReservQty,ReservQtyBase);
              if AsmLine.Reserve = AsmLine.Reserve::Never then begin
                AsmLine.Reserve := AsmLine.Reserve::Optional;
                AsmLine.Modify;
              end;
            end;
        end;
        ProdOrderLine.Modify;
    end;

    [Scope('Personalization')]
    procedure ReserveBindingOrderToTrans(var TransLine: Record "Transfer Line";var ReqLine: Record "Requisition Line")
    var
        ProdOrderComp: Record "Prod. Order Component";
        SalesLine: Record "Sales Line";
        AsmLine: Record "Assembly Line";
        ProdOrderCompReserve: Codeunit "Prod. Order Comp.-Reserve";
        SalesLineReserve: Codeunit "Sales Line-Reserve";
        AsmLineReserve: Codeunit "Assembly Line-Reserve";
        ReservQty: Decimal;
        ReservQtyBase: Decimal;
    begin
        TransLine.CalcFields("Reserved Quantity Inbnd.","Reserved Qty. Inbnd. (Base)");
        if (TransLine."Outstanding Qty. (Base)" - TransLine."Reserved Qty. Inbnd. (Base)") > ReqLine."Demand Quantity (Base)" then begin
          ReservQty := ReqLine."Demand Quantity";
          ReservQtyBase := ReqLine."Demand Quantity (Base)";
        end else begin
          ReservQty := TransLine."Outstanding Quantity" - TransLine."Reserved Quantity Inbnd.";
          ReservQtyBase := TransLine."Outstanding Qty. (Base)" - TransLine."Reserved Qty. Inbnd. (Base)";
        end;

        case ReqLine."Demand Type" of
          DATABASE::"Prod. Order Component":
            begin
              ProdOrderComp.Get(
                ReqLine."Demand Subtype",ReqLine."Demand Order No.",ReqLine."Demand Line No.",ReqLine."Demand Ref. No.");
              ProdOrderCompReserve.BindToTransfer(ProdOrderComp,TransLine,ReservQty,ReservQtyBase);
            end;
          DATABASE::"Sales Line":
            begin
              SalesLine.Get(ReqLine."Demand Subtype",ReqLine."Demand Order No.",ReqLine."Demand Line No.");
              SalesLineReserve.BindToTransfer(SalesLine,TransLine,ReservQty,ReservQtyBase);
              if SalesLine.Reserve = SalesLine.Reserve::Never then begin
                SalesLine.Reserve := SalesLine.Reserve::Optional;
                SalesLine.Modify;
              end;
            end;
          DATABASE::"Assembly Line":
            begin
              AsmLine.Get(ReqLine."Demand Subtype",ReqLine."Demand Order No.",ReqLine."Demand Line No.");
              AsmLineReserve.BindToTransfer(AsmLine,TransLine,ReservQty,ReservQtyBase);
              if AsmLine.Reserve = AsmLine.Reserve::Never then begin
                AsmLine.Reserve := AsmLine.Reserve::Optional;
                AsmLine.Modify;
              end;
            end;
        end;
        TransLine.Modify;
    end;

    [Scope('Personalization')]
    procedure ReserveBindingOrderToAsm(var AsmHeader: Record "Assembly Header";var ReqLine: Record "Requisition Line")
    var
        SalesLine: Record "Sales Line";
        ProdOrderComp: Record "Prod. Order Component";
        AsmLine: Record "Assembly Line";
        SalesLineReserve: Codeunit "Sales Line-Reserve";
        ProdOrderCompReserve: Codeunit "Prod. Order Comp.-Reserve";
        AsmLineReserve: Codeunit "Assembly Line-Reserve";
        ReservQty: Decimal;
        ReservQtyBase: Decimal;
    begin
        AsmHeader.CalcFields("Reserved Quantity","Reserved Qty. (Base)");
        if AsmHeader."Remaining Quantity (Base)" - AsmHeader."Reserved Qty. (Base)" >
           ReqLine."Demand Quantity (Base)"
        then begin
          ReservQty := ReqLine."Demand Quantity";
          ReservQtyBase := ReqLine."Demand Quantity (Base)";
        end else begin
          ReservQty := AsmHeader."Remaining Quantity" - AsmHeader."Reserved Quantity";
          ReservQtyBase := AsmHeader."Remaining Quantity (Base)" - AsmHeader."Reserved Qty. (Base)";
        end;

        case ReqLine."Demand Type" of
          DATABASE::"Prod. Order Component":
            begin
              ProdOrderComp.Get(
                ReqLine."Demand Subtype",ReqLine."Demand Order No.",ReqLine."Demand Line No.",ReqLine."Demand Ref. No.");
              ProdOrderCompReserve.BindToAssembly(ProdOrderComp,AsmHeader,ReservQty,ReservQtyBase);
            end;
          DATABASE::"Sales Line":
            begin
              SalesLine.Get(ReqLine."Demand Subtype",ReqLine."Demand Order No.",ReqLine."Demand Line No.");
              SalesLineReserve.BindToAssembly(SalesLine,AsmHeader,ReservQty,ReservQtyBase);
              if SalesLine.Reserve = SalesLine.Reserve::Never then begin
                SalesLine.Reserve := SalesLine.Reserve::Optional;
                SalesLine.Modify;
              end;
            end;
          DATABASE::"Assembly Line":
            begin
              AsmLine.Get(ReqLine."Demand Subtype",ReqLine."Demand Order No.",ReqLine."Demand Line No.");
              AsmLineReserve.BindToAssembly(AsmLine,AsmHeader,ReservQty,ReservQtyBase);
              if AsmLine.Reserve = AsmLine.Reserve::Never then begin
                AsmLine.Reserve := AsmLine.Reserve::Optional;
                AsmLine.Modify;
              end;
            end;
        end;
        AsmHeader.Modify;
    end;

    [Scope('Personalization')]
    procedure ReserveBindingOrderToReqline(var DemandReqLine: Record "Requisition Line";var SupplyReqLine: Record "Requisition Line")
    var
        ProdOrderComp: Record "Prod. Order Component";
        SalesLine: Record "Sales Line";
        ServiceLine: Record "Service Line";
        ProdOrderCompReserve: Codeunit "Prod. Order Comp.-Reserve";
        SalesLineReserve: Codeunit "Sales Line-Reserve";
        ServiceLineReserve: Codeunit "Service Line-Reserve";
    begin
        case SupplyReqLine."Demand Type" of
          DATABASE::"Prod. Order Component":
            begin
              ProdOrderComp.Get(
                SupplyReqLine."Demand Subtype",SupplyReqLine."Demand Order No.",SupplyReqLine."Demand Line No.",
                SupplyReqLine."Demand Ref. No.");
              ProdOrderCompReserve.BindToRequisition(
                ProdOrderComp,DemandReqLine,SupplyReqLine."Demand Quantity",SupplyReqLine."Demand Quantity (Base)");
            end;
          DATABASE::"Sales Line":
            begin
              SalesLine.Get(SupplyReqLine."Demand Subtype",SupplyReqLine."Demand Order No.",SupplyReqLine."Demand Line No.");
              if (SalesLine.Reserve = SalesLine.Reserve::Never) and not SalesLine."Drop Shipment" then begin
                SalesLine.Reserve := SalesLine.Reserve::Optional;
                SalesLine.Modify;
              end;
              SalesLineReserve.BindToRequisition(
                SalesLine,DemandReqLine,SupplyReqLine."Demand Quantity",SupplyReqLine."Demand Quantity (Base)");
            end;
          DATABASE::"Service Line":
            begin
              ServiceLine.Get(SupplyReqLine."Demand Subtype",SupplyReqLine."Demand Order No.",SupplyReqLine."Demand Line No.");
              ServiceLineReserve.BindToRequisition(
                ServiceLine,DemandReqLine,SupplyReqLine."Demand Quantity",SupplyReqLine."Demand Quantity (Base)");
            end;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertProdOrder(var ProductionOrder: Record "Production Order";ProdOrderChoice: Integer;var RequisitionLine: Record "Requisition Line")
    begin
    end;

    [IntegrationEvent(false, TRUE)]
    local procedure OnAfterInsertProdOrderLine(ReqLine: Record "Requisition Line";ProdOrder: Record "Production Order";var ProdOrderLine: Record "Prod. Order Line";Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertAsmHeader(var ReqLine: Record "Requisition Line";var AsmHeader: Record "Assembly Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransferAsmPlanningComp(var PlanningComponent: Record "Planning Component";var AssemblyLine: Record "Assembly Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransferPlanningRtngLine(var PlanningRtngLine: Record "Planning Routing Line";var ProdOrderRtngLine: Record "Prod. Order Routing Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransferPlanningComp(var PlanningComponent: Record "Planning Component";var ProdOrderComponent: Record "Prod. Order Component")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterProdOrderRtngLineInsert(var ProdOrderRoutingLine: Record "Prod. Order Routing Line";PlanningRoutingLine: Record "Planning Routing Line";ProdOrder: Record "Production Order";RequisitionLine: Record "Requisition Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterProdOrderChgAndReshedule(var RequisitionLine: Record "Requisition Line";var ProdOrderLine: Record "Prod. Order Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertProdOrderWithReqLine(var ProductionOrder: Record "Production Order";var RequisitionLine: Record "Requisition Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertProdOrderLineWithReqLine(var ProdOrderLine: Record "Prod. Order Line";var RequisitionLine: Record "Requisition Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertTransLineWithReqLine(var TransferLine: Record "Transfer Line";var RequisitionLine: Record "Requisition Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPurchOrderChgAndResheduleOnBeforePurchLineModify(var ReqLine: Record "Requisition Line";var PurchLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnTransOrderChgAndResheduleOnBeforeTransLineModify(var ReqLine: Record "Requisition Line";var TransLine: Record "Transfer Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAsmOrderChgAndResheduleOnBeforeAsmHeaderModify(var ReqLine: Record "Requisition Line";var AssemblyHeader: Record "Assembly Header")
    begin
    end;
}

