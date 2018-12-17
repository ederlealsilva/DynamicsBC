codeunit 99000773 "Calculate Prod. Order"
{
    // version NAVW113.00

    Permissions = TableData Item=r,
                  TableData "Prod. Order Line"=rimd,
                  TableData "Prod. Order Component"=rimd,
                  TableData "Manufacturing Setup"=r,
                  TableData "Production BOM Line"=rimd,
                  TableData "Production BOM Comment Line"=rimd,
                  TableData "Production Order"=rimd,
                  TableData "Prod. Order Comp. Cmt Line"=rimd;

    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'BOM phantom structure for %1 is higher than 50 levels.';
        Text001: Label '%1 %2 %3 can not be calculated, if at least one %4 has been posted.';
        Text002: Label 'Operation No. %1 cannot follow another operation in the routing of this Prod. Order Line';
        Text003: Label 'Operation No. %1 cannot precede another operation in the routing of this Prod. Order Line';
        Item: Record Item;
        Location: Record Location;
        SKU: Record "Stockkeeping Unit";
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComp: Record "Prod. Order Component";
        ProdOrderRoutingLine2: Record "Prod. Order Routing Line";
        ProdOrderBOMCompComment: Record "Prod. Order Comp. Cmt Line";
        ProdBOMLine: array [99] of Record "Production BOM Line";
        UOMMgt: Codeunit "Unit of Measure Management";
        CostCalcMgt: Codeunit "Cost Calculation Management";
        VersionMgt: Codeunit VersionManagement;
        ProdOrderRouteMgt: Codeunit "Prod. Order Route Management";
        GetPlanningParameters: Codeunit "Planning-Get Parameters";
        LeadTimeMgt: Codeunit "Lead-Time Management";
        CalendarMgt: Codeunit CalendarManagement;
        WMSManagement: Codeunit "WMS Management";
        NextProdOrderCompLineNo: Integer;
        Blocked: Boolean;
        ProdOrderModify: Boolean;

    local procedure TransferRouting()
    var
        RoutingHeader: Record "Routing Header";
        RoutingLine: Record "Routing Line";
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        WorkCenter: Record "Work Center";
        MachineCenter: Record "Machine Center";
    begin
        if ProdOrderLine."Routing No." = '' then
          exit;

        RoutingHeader.Get(ProdOrderLine."Routing No.");

        ProdOrderRoutingLine.SetRange(Status,ProdOrderLine.Status);
        ProdOrderRoutingLine.SetRange("Prod. Order No.",ProdOrderLine."Prod. Order No.");
        ProdOrderRoutingLine.SetRange("Routing Reference No.",ProdOrderLine."Routing Reference No.");
        ProdOrderRoutingLine.SetRange("Routing No.",ProdOrderLine."Routing No.");
        if not ProdOrderRoutingLine.IsEmpty then
          exit;

        RoutingLine.SetRange("Routing No.",ProdOrderLine."Routing No.");
        RoutingLine.SetRange("Version Code",ProdOrderLine."Routing Version Code");
        if RoutingLine.Find('-') then
          repeat
            RoutingLine.TestField(Recalculate,false);
            ProdOrderRoutingLine.Init;
            ProdOrderRoutingLine.Status := ProdOrderLine.Status;
            ProdOrderRoutingLine."Prod. Order No." := ProdOrderLine."Prod. Order No.";
            ProdOrderRoutingLine."Routing Reference No." := ProdOrderLine."Routing Reference No.";
            ProdOrderRoutingLine."Routing No." := ProdOrderLine."Routing No.";
            ProdOrderRoutingLine."Operation No." := RoutingLine."Operation No.";
            ProdOrderRoutingLine."Next Operation No." := RoutingLine."Next Operation No.";
            ProdOrderRoutingLine."Previous Operation No." := RoutingLine."Previous Operation No.";
            ProdOrderRoutingLine.Type := RoutingLine.Type;
            ProdOrderRoutingLine."No." := RoutingLine."No.";
            ProdOrderRoutingLine.FillDefaultLocationAndBins;
            ProdOrderRoutingLine."Work Center No." := RoutingLine."Work Center No.";
            ProdOrderRoutingLine."Work Center Group Code" := RoutingLine."Work Center Group Code";
            ProdOrderRoutingLine.Description := RoutingLine.Description;
            ProdOrderRoutingLine."Setup Time" := RoutingLine."Setup Time";
            ProdOrderRoutingLine."Run Time" := RoutingLine."Run Time";
            ProdOrderRoutingLine."Wait Time" := RoutingLine."Wait Time";
            ProdOrderRoutingLine."Move Time" := RoutingLine."Move Time";
            ProdOrderRoutingLine."Fixed Scrap Quantity" := RoutingLine."Fixed Scrap Quantity";
            ProdOrderRoutingLine."Lot Size" := RoutingLine."Lot Size";
            ProdOrderRoutingLine."Scrap Factor %" := RoutingLine."Scrap Factor %";
            ProdOrderRoutingLine."Minimum Process Time" := RoutingLine."Minimum Process Time";
            ProdOrderRoutingLine."Maximum Process Time" := RoutingLine."Maximum Process Time";
            ProdOrderRoutingLine."Concurrent Capacities" := RoutingLine."Concurrent Capacities";
            if ProdOrderRoutingLine."Concurrent Capacities" = 0 then
              ProdOrderRoutingLine."Concurrent Capacities" := 1;
            ProdOrderRoutingLine."Send-Ahead Quantity" := RoutingLine."Send-Ahead Quantity";
            ProdOrderRoutingLine."Setup Time Unit of Meas. Code" := RoutingLine."Setup Time Unit of Meas. Code";
            ProdOrderRoutingLine."Run Time Unit of Meas. Code" := RoutingLine."Run Time Unit of Meas. Code";
            ProdOrderRoutingLine."Wait Time Unit of Meas. Code" := RoutingLine."Wait Time Unit of Meas. Code";
            ProdOrderRoutingLine."Move Time Unit of Meas. Code" := RoutingLine."Move Time Unit of Meas. Code";
            ProdOrderRoutingLine."Routing Link Code" := RoutingLine."Routing Link Code";
            ProdOrderRoutingLine."Standard Task Code" := RoutingLine."Standard Task Code";
            ProdOrderRoutingLine."Sequence No. (Forward)" := RoutingLine."Sequence No. (Forward)";
            ProdOrderRoutingLine."Sequence No. (Backward)" := RoutingLine."Sequence No. (Backward)";
            ProdOrderRoutingLine."Fixed Scrap Qty. (Accum.)" := RoutingLine."Fixed Scrap Qty. (Accum.)";
            ProdOrderRoutingLine."Scrap Factor % (Accumulated)" := RoutingLine."Scrap Factor % (Accumulated)";
            ProdOrderRoutingLine."Unit Cost per" := RoutingLine."Unit Cost per";
            case ProdOrderRoutingLine.Type of
              ProdOrderRoutingLine.Type::"Work Center":
                begin
                  WorkCenter.Get(RoutingLine."Work Center No.");
                  ProdOrderRoutingLine."Flushing Method" := WorkCenter."Flushing Method";
                end;
              ProdOrderRoutingLine.Type::"Machine Center":
                begin
                  MachineCenter.Get(ProdOrderRoutingLine."No.");
                  ProdOrderRoutingLine."Flushing Method" := MachineCenter."Flushing Method";
                end;
            end;
            CostCalcMgt.RoutingCostPerUnit(
              ProdOrderRoutingLine.Type,
              ProdOrderRoutingLine."No.",
              ProdOrderRoutingLine."Direct Unit Cost",
              ProdOrderRoutingLine."Indirect Cost %",
              ProdOrderRoutingLine."Overhead Rate",
              ProdOrderRoutingLine."Unit Cost per",
              ProdOrderRoutingLine."Unit Cost Calculation");
            ProdOrderRoutingLine.Validate("Direct Unit Cost");
            ProdOrderRoutingLine."Starting Time" := ProdOrderLine."Starting Time";
            ProdOrderRoutingLine."Starting Date" := ProdOrderLine."Starting Date";
            ProdOrderRoutingLine."Ending Time" := ProdOrderLine."Ending Time";
            ProdOrderRoutingLine."Ending Date" := ProdOrderLine."Ending Date";
            ProdOrderRoutingLine.UpdateDatetime;
            OnAfterTransferRoutingLine(ProdOrderLine,RoutingLine,ProdOrderRoutingLine);
            ProdOrderRoutingLine.Insert;
            OnAfterInsertProdRoutingLine(ProdOrderRoutingLine,ProdOrderLine);
            TransferTaskInfo(ProdOrderRoutingLine,ProdOrderLine."Routing Version Code");
          until RoutingLine.Next = 0;

        OnAfterTransferRouting(ProdOrderLine);
    end;

    [Scope('Personalization')]
    procedure TransferTaskInfo(var FromProdOrderRoutingLine: Record "Prod. Order Routing Line";VersionCode: Code[20])
    var
        RoutingTool: Record "Routing Tool";
        RoutingPersonnel: Record "Routing Personnel";
        RoutingQualityMeasure: Record "Routing Quality Measure";
        RoutingCommentLine: Record "Routing Comment Line";
        ProdOrderRoutingTool: Record "Prod. Order Routing Tool";
        ProdOrderRoutingPersonnel: Record "Prod. Order Routing Personnel";
        ProdOrderRtngQltyMeas: Record "Prod. Order Rtng Qlty Meas.";
        ProdOrderRtngCommentLine: Record "Prod. Order Rtng Comment Line";
    begin
        RoutingTool.SetRange("Routing No.",FromProdOrderRoutingLine."Routing No.");
        RoutingTool.SetRange("Operation No.",FromProdOrderRoutingLine."Operation No.");
        RoutingTool.SetRange("Version Code",VersionCode);
        if RoutingTool.Find('-') then
          repeat
            ProdOrderRoutingTool.TransferFields(RoutingTool);
            ProdOrderRoutingTool.Status := FromProdOrderRoutingLine.Status;
            ProdOrderRoutingTool."Prod. Order No." := FromProdOrderRoutingLine."Prod. Order No.";
            ProdOrderRoutingTool."Routing Reference No." := FromProdOrderRoutingLine."Routing Reference No.";
            ProdOrderRoutingTool.Insert;
          until RoutingTool.Next = 0;

        RoutingPersonnel.SetRange("Routing No.",FromProdOrderRoutingLine."Routing No.");
        RoutingPersonnel.SetRange("Operation No.",FromProdOrderRoutingLine."Operation No.");
        RoutingPersonnel.SetRange("Version Code",VersionCode);
        if RoutingPersonnel.Find('-') then
          repeat
            ProdOrderRoutingPersonnel.TransferFields(RoutingPersonnel);
            ProdOrderRoutingPersonnel.Status := FromProdOrderRoutingLine.Status;
            ProdOrderRoutingPersonnel."Prod. Order No." := FromProdOrderRoutingLine."Prod. Order No.";
            ProdOrderRoutingPersonnel."Routing Reference No." := FromProdOrderRoutingLine."Routing Reference No.";
            ProdOrderRoutingPersonnel.Insert;
          until RoutingPersonnel.Next = 0;

        RoutingQualityMeasure.SetRange("Routing No.",FromProdOrderRoutingLine."Routing No.");
        RoutingQualityMeasure.SetRange("Operation No.",FromProdOrderRoutingLine."Operation No.");
        RoutingQualityMeasure.SetRange("Version Code",VersionCode);
        if RoutingQualityMeasure.Find('-') then
          repeat
            ProdOrderRtngQltyMeas.TransferFields(RoutingQualityMeasure);
            ProdOrderRtngQltyMeas.Status := FromProdOrderRoutingLine.Status;
            ProdOrderRtngQltyMeas."Prod. Order No." := FromProdOrderRoutingLine."Prod. Order No.";
            ProdOrderRtngQltyMeas."Routing Reference No." := FromProdOrderRoutingLine."Routing Reference No.";
            ProdOrderRtngQltyMeas.Insert;
          until RoutingQualityMeasure.Next = 0;

        RoutingCommentLine.SetRange("Routing No.",FromProdOrderRoutingLine."Routing No.");
        RoutingCommentLine.SetRange("Operation No.",FromProdOrderRoutingLine."Operation No.");
        RoutingCommentLine.SetRange("Version Code",VersionCode);
        if RoutingCommentLine.Find('-') then
          repeat
            ProdOrderRtngCommentLine.TransferFields(RoutingCommentLine);
            ProdOrderRtngCommentLine.Status := FromProdOrderRoutingLine.Status;
            ProdOrderRtngCommentLine."Prod. Order No." := FromProdOrderRoutingLine."Prod. Order No.";
            ProdOrderRtngCommentLine."Routing Reference No." := FromProdOrderRoutingLine."Routing Reference No.";
            ProdOrderRtngCommentLine.Insert;
          until RoutingCommentLine.Next = 0;

        OnAfterTransferTaskInfo(FromProdOrderRoutingLine,VersionCode);
    end;

    local procedure TransferBOM(ProdBOMNo: Code[20];Level: Integer;LineQtyPerUOM: Decimal;ItemQtyPerUOM: Decimal): Boolean
    var
        BOMHeader: Record "Production BOM Header";
        ComponentSKU: Record "Stockkeeping Unit";
        Item2: Record Item;
        ProductionBOMVersion: Record "Production BOM Version";
        ProdBOMCommentLine: Record "Production BOM Comment Line";
        ReqQty: Decimal;
        ErrorOccured: Boolean;
        VersionCode: Code[20];
    begin
        if ProdBOMNo = '' then
          exit;

        ProdOrderComp.LockTable;

        if Level > 50 then
          Error(
            Text000,
            ProdBOMNo);

        BOMHeader.Get(ProdBOMNo);

        if Level > 1 then
          VersionCode := VersionMgt.GetBOMVersion(ProdBOMNo,ProdOrderLine."Starting Date",true)
        else
          VersionCode := ProdOrderLine."Production BOM Version Code";

        if VersionCode <> '' then begin
          ProductionBOMVersion.Get(ProdBOMNo,VersionCode);
          ProductionBOMVersion.TestField(Status,ProductionBOMVersion.Status::Certified);
        end else
          BOMHeader.TestField(Status,BOMHeader.Status::Certified);

        ProdBOMLine[Level].SetRange("Production BOM No.",ProdBOMNo);
        ProdBOMLine[Level].SetRange("Version Code",VersionCode);
        ProdBOMLine[Level].SetFilter("Starting Date",'%1|..%2',0D,ProdOrderLine."Starting Date");
        ProdBOMLine[Level].SetFilter("Ending Date",'%1|%2..',0D,ProdOrderLine."Starting Date");
        if ProdBOMLine[Level].Find('-') then
          repeat
            if ProdBOMLine[Level]."Routing Link Code" <> '' then begin
              ProdOrderRoutingLine2.SetRange(Status,ProdOrderLine.Status);
              ProdOrderRoutingLine2.SetRange("Prod. Order No.",ProdOrderLine."Prod. Order No.");
              ProdOrderRoutingLine2.SetRange("Routing Link Code",ProdBOMLine[Level]."Routing Link Code");
              ProdOrderRoutingLine2.FindFirst;
              ReqQty :=
                ProdBOMLine[Level].Quantity *
                (1 + ProdBOMLine[Level]."Scrap %" / 100) *
                (1 + ProdOrderRoutingLine2."Scrap Factor % (Accumulated)") *
                LineQtyPerUOM / ItemQtyPerUOM +
                ProdOrderRoutingLine2."Fixed Scrap Qty. (Accum.)";
            end else
              ReqQty :=
                ProdBOMLine[Level].Quantity *
                (1 + ProdBOMLine[Level]."Scrap %" / 100) *
                LineQtyPerUOM / ItemQtyPerUOM;

            case ProdBOMLine[Level].Type of
              ProdBOMLine[Level].Type::Item:
                begin
                  if ReqQty <> 0 then begin
                    ProdOrderComp.SetCurrentKey(Status,"Prod. Order No.","Prod. Order Line No.","Item No.");
                    ProdOrderComp.SetRange(Status,ProdOrderLine.Status);
                    ProdOrderComp.SetRange("Prod. Order No.",ProdOrderLine."Prod. Order No.");
                    ProdOrderComp.SetRange("Prod. Order Line No.",ProdOrderLine."Line No.");
                    ProdOrderComp.SetRange("Item No.",ProdBOMLine[Level]."No.");
                    ProdOrderComp.SetRange("Variant Code",ProdBOMLine[Level]."Variant Code");
                    ProdOrderComp.SetRange("Routing Link Code",ProdBOMLine[Level]."Routing Link Code");
                    ProdOrderComp.SetRange(Position,ProdBOMLine[Level].Position);
                    ProdOrderComp.SetRange("Position 2",ProdBOMLine[Level]."Position 2");
                    ProdOrderComp.SetRange("Position 3",ProdBOMLine[Level]."Position 3");
                    ProdOrderComp.SetRange(Length,ProdBOMLine[Level].Length);
                    ProdOrderComp.SetRange(Width,ProdBOMLine[Level].Width);
                    ProdOrderComp.SetRange(Weight,ProdBOMLine[Level].Weight);
                    ProdOrderComp.SetRange(Depth,ProdBOMLine[Level].Depth);
                    ProdOrderComp.SetRange("Unit of Measure Code",ProdBOMLine[Level]."Unit of Measure Code");
                    OnAfterProdOrderCompFilter(ProdOrderComp,ProdBOMLine[Level]);
                    if not ProdOrderComp.FindFirst then begin
                      ProdOrderComp.Reset;
                      ProdOrderComp.SetRange(Status,ProdOrderLine.Status);
                      ProdOrderComp.SetRange("Prod. Order No.",ProdOrderLine."Prod. Order No.");
                      ProdOrderComp.SetRange("Prod. Order Line No.",ProdOrderLine."Line No.");
                      if ProdOrderComp.FindLast then
                        NextProdOrderCompLineNo := ProdOrderComp."Line No." + 10000
                      else
                        NextProdOrderCompLineNo := 10000;
                      ProdOrderComp.Init;
                      ProdOrderComp.SetIgnoreErrors;
                      ProdOrderComp.BlockDynamicTracking(Blocked);
                      ProdOrderComp.Status := ProdOrderLine.Status;
                      ProdOrderComp."Prod. Order No." := ProdOrderLine."Prod. Order No.";
                      ProdOrderComp."Prod. Order Line No." := ProdOrderLine."Line No.";
                      ProdOrderComp."Line No." := NextProdOrderCompLineNo;
                      ProdOrderComp.Validate("Item No.",ProdBOMLine[Level]."No.");
                      ProdOrderComp."Variant Code" := ProdBOMLine[Level]."Variant Code";
                      ProdOrderComp."Location Code" := SKU."Components at Location";
                      ProdOrderComp."Bin Code" := GetDefaultBin;
                      ProdOrderComp.Description := ProdBOMLine[Level].Description;
                      ProdOrderComp.Validate("Unit of Measure Code",ProdBOMLine[Level]."Unit of Measure Code");
                      ProdOrderComp."Quantity per" := ProdBOMLine[Level]."Quantity per" * LineQtyPerUOM / ItemQtyPerUOM;
                      ProdOrderComp.Length := ProdBOMLine[Level].Length;
                      ProdOrderComp.Width := ProdBOMLine[Level].Width;
                      ProdOrderComp.Weight := ProdBOMLine[Level].Weight;
                      ProdOrderComp.Depth := ProdBOMLine[Level].Depth;
                      ProdOrderComp.Position := ProdBOMLine[Level].Position;
                      ProdOrderComp."Position 2" := ProdBOMLine[Level]."Position 2";
                      ProdOrderComp."Position 3" := ProdBOMLine[Level]."Position 3";
                      ProdOrderComp."Lead-Time Offset" := ProdBOMLine[Level]."Lead-Time Offset";
                      ProdOrderComp.Validate("Routing Link Code",ProdBOMLine[Level]."Routing Link Code");
                      ProdOrderComp.Validate("Scrap %",ProdBOMLine[Level]."Scrap %");
                      ProdOrderComp.Validate("Calculation Formula",ProdBOMLine[Level]."Calculation Formula");

                      GetPlanningParameters.AtSKU(
                        ComponentSKU,ProdOrderComp."Item No.",
                        ProdOrderComp."Variant Code",
                        ProdOrderComp."Location Code");

                      ProdOrderComp."Flushing Method" := ComponentSKU."Flushing Method";
                      if (SKU."Manufacturing Policy" = SKU."Manufacturing Policy"::"Make-to-Order") and
                         (ComponentSKU."Manufacturing Policy" = ComponentSKU."Manufacturing Policy"::"Make-to-Order") and
                         (ComponentSKU."Replenishment System" = ComponentSKU."Replenishment System"::"Prod. Order")
                      then begin
                        ProdOrderComp."Planning Level Code" := ProdOrderLine."Planning Level Code" + 1;
                        Item2.Get(ProdOrderComp."Item No.");
                        ProdOrderComp."Item Low-Level Code" := Item2."Low-Level Code";
                      end;
                      ProdOrderComp.GetDefaultBin;
                      OnAfterTransferBOMComponent(ProdOrderLine,ProdBOMLine[Level],ProdOrderComp);
                      ProdOrderComp.Insert(true);
                    end else begin
                      ProdOrderComp.SetIgnoreErrors;
                      ProdOrderComp.SetCurrentKey(Status,"Prod. Order No."); // Reset key
                      ProdOrderComp.BlockDynamicTracking(Blocked);
                      ProdOrderComp.Validate(
                        "Quantity per",
                        ProdOrderComp."Quantity per" + ProdBOMLine[Level]."Quantity per" * LineQtyPerUOM / ItemQtyPerUOM);
                      ProdOrderComp.Validate("Routing Link Code",ProdBOMLine[Level]."Routing Link Code");
                      ProdOrderComp.Modify;
                    end;
                    if ProdOrderComp.HasErrorOccured then
                      ErrorOccured := true;
                    ProdOrderComp.AutoReserve;

                    ProdBOMCommentLine.SetRange("Production BOM No.",ProdBOMLine[Level]."Production BOM No.");
                    ProdBOMCommentLine.SetRange("BOM Line No.",ProdBOMLine[Level]."Line No.");
                    ProdBOMCommentLine.SetRange("Version Code",ProdBOMLine[Level]."Version Code");
                    if ProdBOMCommentLine.Find('-') then
                      repeat
                        ProdOrderBOMCompComment.TransferFields(ProdBOMCommentLine);
                        ProdOrderBOMCompComment.Status := ProdOrderComp.Status;
                        ProdOrderBOMCompComment."Prod. Order No." := ProdOrderComp."Prod. Order No.";
                        ProdOrderBOMCompComment."Prod. Order Line No." := ProdOrderComp."Prod. Order Line No.";
                        ProdOrderBOMCompComment."Prod. Order BOM Line No." := ProdOrderComp."Line No.";
                        if not ProdOrderBOMCompComment.Insert then
                          ProdOrderBOMCompComment.Modify;
                      until ProdBOMCommentLine.Next = 0;
                  end;
                end;
              ProdBOMLine[Level].Type::"Production BOM":
                begin
                  TransferBOM(ProdBOMLine[Level]."No.",Level + 1,ReqQty,1);
                  ProdBOMLine[Level].SetRange("Production BOM No.",ProdBOMNo);
                  if Level > 1 then
                    ProdBOMLine[Level].SetRange("Version Code",VersionMgt.GetBOMVersion(ProdBOMNo,ProdOrderLine."Starting Date",true))
                  else
                    ProdBOMLine[Level].SetRange("Version Code",ProdOrderLine."Production BOM Version Code");
                  ProdBOMLine[Level].SetFilter("Starting Date",'%1|..%2',0D,ProdOrderLine."Starting Date");
                  ProdBOMLine[Level].SetFilter("Ending Date",'%1|%2..',0D,ProdOrderLine."Starting Date");
                end;
            end;
          until ProdBOMLine[Level].Next = 0;
        exit(not ErrorOccured);
    end;

    [Scope('Personalization')]
    procedure CalculateComponents()
    var
        ProdOrderComp: Record "Prod. Order Component";
    begin
        ProdOrderComp.SetRange(Status,ProdOrderLine.Status);
        ProdOrderComp.SetRange("Prod. Order No.",ProdOrderLine."Prod. Order No.");
        ProdOrderComp.SetRange("Prod. Order Line No.",ProdOrderLine."Line No.");
        if ProdOrderComp.Find('-') then
          repeat
            ProdOrderComp.BlockDynamicTracking(Blocked);
            ProdOrderComp.Validate("Routing Link Code");
            ProdOrderComp.Modify;
            ProdOrderComp.AutoReserve;
          until ProdOrderComp.Next = 0;
    end;

    [Scope('Personalization')]
    procedure CalculateRoutingFromActual(ProdOrderRoutingLine: Record "Prod. Order Routing Line";Direction: Option Forward,Backward;CalcStartEndDate: Boolean)
    var
        CalculateRoutingLine: Codeunit "Calculate Routing Line";
    begin
        if ProdOrderRouteMgt.NeedsCalculation(
             ProdOrderRoutingLine.Status,
             ProdOrderRoutingLine."Prod. Order No.",
             ProdOrderRoutingLine."Routing Reference No.",
             ProdOrderRoutingLine."Routing No.")
        then begin
          ProdOrderLine.SetRange(Status,ProdOrderRoutingLine.Status);
          ProdOrderLine.SetRange("Prod. Order No.",ProdOrderRoutingLine."Prod. Order No.");
          ProdOrderLine.SetRange("Routing Reference No.",ProdOrderRoutingLine."Routing Reference No.");
          ProdOrderLine.SetRange("Routing No.",ProdOrderRoutingLine."Routing No.");
          ProdOrderLine.FindFirst;
          ProdOrderRouteMgt.Calculate(ProdOrderLine);
          ProdOrderRoutingLine.Get(
            ProdOrderRoutingLine.Status,
            ProdOrderRoutingLine."Prod. Order No.",
            ProdOrderRoutingLine."Routing Reference No.",
            ProdOrderRoutingLine."Routing No.",
            ProdOrderRoutingLine."Operation No.");
        end;
        if Direction = Direction::Forward then
          ProdOrderRoutingLine.SetCurrentKey(Status,"Prod. Order No.","Routing Reference No.",
            "Routing No.","Sequence No. (Forward)")
        else
          ProdOrderRoutingLine.SetCurrentKey(Status,"Prod. Order No.","Routing Reference No.",
            "Routing No.","Sequence No. (Backward)");

        ProdOrderRoutingLine.SetRange(Status,ProdOrderRoutingLine.Status);
        ProdOrderRoutingLine.SetRange("Prod. Order No.",ProdOrderRoutingLine."Prod. Order No.");
        ProdOrderRoutingLine.SetRange("Routing Reference No.",ProdOrderRoutingLine."Routing Reference No.");
        ProdOrderRoutingLine.SetRange("Routing No.",ProdOrderRoutingLine."Routing No.");
        ProdOrderRoutingLine.SetFilter("Routing Status",'<>%1',ProdOrderRoutingLine."Routing Status"::Finished);
        repeat
          if CalcStartEndDate and not ProdOrderRoutingLine."Schedule Manually" then begin
            if ((Direction = Direction::Forward) and (ProdOrderRoutingLine."Previous Operation No." <> '')) or
               ((Direction = Direction::Backward) and (ProdOrderRoutingLine."Next Operation No." <> ''))
            then begin
              ProdOrderRoutingLine."Starting Time" := 0T;
              ProdOrderRoutingLine."Starting Date" := 0D;
              ProdOrderRoutingLine."Ending Time" := 235959T;
              ProdOrderRoutingLine."Ending Date" := CalendarMgt.GetMaxDate;
            end;
          end;
          CalculateRoutingLine.CalculateRoutingLine(ProdOrderRoutingLine,Direction,CalcStartEndDate);
          CalcStartEndDate := true;
        until ProdOrderRoutingLine.Next = 0;
    end;

    local procedure CalculateRouting(Direction: Option Forward,Backward;LetDueDateDecrease: Boolean)
    var
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        LeadTime: Code[20];
    begin
        if ProdOrderRouteMgt.NeedsCalculation(
             ProdOrderLine.Status,
             ProdOrderLine."Prod. Order No.",
             ProdOrderLine."Routing Reference No.",
             ProdOrderLine."Routing No.")
        then
          ProdOrderRouteMgt.Calculate(ProdOrderLine);

        if Direction = Direction::Forward then
          ProdOrderRoutingLine.SetCurrentKey(Status,"Prod. Order No.","Routing Reference No.","Routing No.",
            "Sequence No. (Forward)")
        else
          ProdOrderRoutingLine.SetCurrentKey(Status,"Prod. Order No.","Routing Reference No.","Routing No.",
            "Sequence No. (Backward)");

        ProdOrderRoutingLine.SetRange(Status,ProdOrderLine.Status);
        ProdOrderRoutingLine.SetRange("Prod. Order No.",ProdOrderLine."Prod. Order No.");
        ProdOrderRoutingLine.SetRange("Routing Reference No.",ProdOrderLine."Routing Reference No.");
        ProdOrderRoutingLine.SetRange("Routing No.",ProdOrderLine."Routing No.");
        ProdOrderRoutingLine.SetFilter("Routing Status",'<>%1',ProdOrderRoutingLine."Routing Status"::Finished);
        if not ProdOrderRoutingLine.FindFirst then begin
          LeadTime :=
            LeadTimeMgt.ManufacturingLeadTime(
              ProdOrderLine."Item No.",
              ProdOrderLine."Location Code",
              ProdOrderLine."Variant Code");
          if Direction = Direction::Forward then
            // Ending Date calculated forward from Starting Date
            ProdOrderLine."Ending Date" :=
              LeadTimeMgt.PlannedEndingDate2(
                ProdOrderLine."Item No.",
                ProdOrderLine."Location Code",
                ProdOrderLine."Variant Code",
                '',
                LeadTime,
                2,
                ProdOrderLine."Starting Date")
          else
            // Starting Date calculated backward from Ending Date
            ProdOrderLine."Starting Date" :=
              LeadTimeMgt.PlannedStartingDate(
                ProdOrderLine."Item No.",
                ProdOrderLine."Location Code",
                ProdOrderLine."Variant Code",
                '',
                LeadTime,
                2,
                ProdOrderLine."Ending Date");

          CalculateProdOrderDates(ProdOrderLine,LetDueDateDecrease);
          exit;
        end;

        if Direction = Direction::Forward then begin
          ProdOrderRoutingLine."Starting Date" := ProdOrderLine."Starting Date";
          ProdOrderRoutingLine."Starting Time" := ProdOrderLine."Starting Time";
        end else begin
          ProdOrderRoutingLine."Ending Date" := ProdOrderLine."Ending Date";
          ProdOrderRoutingLine."Ending Time" := ProdOrderLine."Ending Time";
        end;
        ProdOrderRoutingLine.UpdateDatetime;
        CalculateRoutingFromActual(ProdOrderRoutingLine,Direction,false);

        CalculateProdOrderDates(ProdOrderLine,LetDueDateDecrease);
    end;

    [Scope('Personalization')]
    procedure CalculateProdOrderDates(var ProdOrderLine: Record "Prod. Order Line";LetDueDateDecrease: Boolean)
    var
        ProdOrderLine2: Record "Prod. Order Line";
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        NewDueDate: Date;
    begin
        ProdOrder.Get(ProdOrderLine.Status,ProdOrderLine."Prod. Order No.");

        ProdOrderRoutingLine.SetRange(Status,ProdOrderLine.Status);
        ProdOrderRoutingLine.SetRange("Prod. Order No.",ProdOrderLine."Prod. Order No.");
        ProdOrderRoutingLine.SetRange("Routing No.",ProdOrderLine."Routing No.");
        if ProdOrder."Source Type" <> ProdOrder."Source Type"::Family then
          ProdOrderRoutingLine.SetRange("Routing Reference No.",ProdOrderLine."Line No.")
        else
          ProdOrderRoutingLine.SetRange("Routing Reference No.",0);
        ProdOrderRoutingLine.SetFilter("Routing Status",'<>%1',ProdOrderRoutingLine."Routing Status"::Finished);
        ProdOrderRoutingLine.SetFilter("Next Operation No.",'%1','');

        if ProdOrderRoutingLine.FindFirst then begin
          ProdOrderLine."Ending Date" := ProdOrderRoutingLine."Ending Date";
          ProdOrderLine."Ending Time" := ProdOrderRoutingLine."Ending Time";
        end;

        ProdOrderRoutingLine.SetRange("Next Operation No.");
        ProdOrderRoutingLine.SetFilter("Previous Operation No.",'%1','');

        if ProdOrderRoutingLine.FindFirst then begin
          ProdOrderLine."Starting Date" := ProdOrderRoutingLine."Starting Date";
          ProdOrderLine."Starting Time" := ProdOrderRoutingLine."Starting Time";
        end;

        if ProdOrderLine."Planning Level Code" = 0 then
          NewDueDate :=
            LeadTimeMgt.PlannedDueDate(
              ProdOrderLine."Item No.",
              ProdOrderLine."Location Code",
              ProdOrderLine."Variant Code",
              ProdOrderLine."Ending Date",
              '',
              2)
        else
          NewDueDate := ProdOrderLine."Ending Date";

        if LetDueDateDecrease or (NewDueDate > ProdOrderLine."Due Date") then
          ProdOrderLine."Due Date" := NewDueDate;

        ProdOrderLine.UpdateDatetime;

        ProdOrderLine.Modify;

        ProdOrder."Due Date" := 0D;
        ProdOrder."Ending Date" := 0D;
        ProdOrder."Ending Time" := 0T;
        ProdOrder."Starting Date" := CalendarMgt.GetMaxDate;
        ProdOrder."Starting Time" := 235959T;

        ProdOrderLine2.SetRange(Status,ProdOrderLine.Status);
        ProdOrderLine2.SetRange("Prod. Order No.",ProdOrderLine."Prod. Order No.");
        if ProdOrderLine2.Find('-') then
          repeat
            if (ProdOrderLine2."Ending Date" > ProdOrder."Ending Date") or
               ((ProdOrderLine2."Ending Date" = ProdOrder."Ending Date") and
                (ProdOrderLine2."Ending Time" > ProdOrder."Ending Time"))
            then begin
              ProdOrder."Ending Date" := ProdOrderLine2."Ending Date";
              ProdOrder."Ending Time" := ProdOrderLine2."Ending Time";
            end;
            if (ProdOrderLine2."Starting Date" < ProdOrder."Starting Date") or
               ((ProdOrderLine2."Starting Date" = ProdOrder."Starting Date") and
                (ProdOrderLine2."Starting Time" < ProdOrder."Starting Time"))
            then begin
              ProdOrder."Starting Date" := ProdOrderLine2."Starting Date";
              ProdOrder."Starting Time" := ProdOrderLine2."Starting Time";
            end;

            if ProdOrderLine2."Due Date" > ProdOrder."Due Date" then
              ProdOrder."Due Date" := ProdOrderLine2."Due Date";
          until ProdOrderLine2.Next = 0;

        ProdOrder.UpdateDatetime;

        if not ProdOrderModify then
          ProdOrder.Modify;
    end;

    [Scope('Personalization')]
    procedure Calculate(ProdOrderLine2: Record "Prod. Order Line";Direction: Option Forward,Backward;CalcRouting: Boolean;CalcComponents: Boolean;DeleteRelations: Boolean;LetDueDateDecrease: Boolean): Boolean
    var
        CapLedgEntry: Record "Capacity Ledger Entry";
        ItemLedgEntry: Record "Item Ledger Entry";
        ProdOrderRoutingLine3: Record "Prod. Order Routing Line";
        ProdOrderRoutingLine4: Record "Prod. Order Routing Line";
        RoutingHeader: Record "Routing Header";
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        ErrorOccured: Boolean;
    begin
        ProdOrderLine := ProdOrderLine2;

        if ProdOrderLine.Status = ProdOrderLine.Status::Released then begin
          ItemLedgEntry.SetCurrentKey("Order Type","Order No.");
          ItemLedgEntry.SetRange("Order Type",ItemLedgEntry."Order Type"::Production);
          ItemLedgEntry.SetRange("Order No.",ProdOrderLine."Prod. Order No.");
          if not ItemLedgEntry.IsEmpty then
            Error(
              Text001,
              ProdOrderLine.Status,ProdOrderLine.TableCaption,ProdOrderLine."Prod. Order No.",
              ItemLedgEntry.TableCaption);

          CapLedgEntry.SetCurrentKey("Order Type","Order No.");
          CapLedgEntry.SetRange("Order Type",CapLedgEntry."Order Type"::Production);
          CapLedgEntry.SetRange("Order No.",ProdOrderLine."Prod. Order No.");
          if not CapLedgEntry.IsEmpty then
            Error(
              Text001,
              ProdOrderLine.Status,ProdOrderLine.TableCaption,ProdOrderLine."Prod. Order No.",
              CapLedgEntry.TableCaption);
        end;

        ProdOrderLine.TestField(Quantity);
        if Direction = Direction::Backward then
          ProdOrderLine.TestField("Ending Date")
        else
          ProdOrderLine.TestField("Starting Date");

        if DeleteRelations then
          ProdOrderLine.DeleteRelations;

        if CalcRouting then begin
          TransferRouting;
          if not CalcComponents then begin // components will not be calculated later- update bin code
            ProdOrderRoutingLine.SetRange(Status,ProdOrderLine.Status);
            ProdOrderRoutingLine.SetRange("Prod. Order No.",ProdOrderLine."Prod. Order No.");
            ProdOrderRoutingLine.SetRange("Routing Reference No.",ProdOrderLine."Routing Reference No.");
            ProdOrderRoutingLine.SetRange("Routing No.",ProdOrderLine."Routing No.");
            if not ProdOrderRouteMgt.UpdateComponentsBin(ProdOrderRoutingLine,true) then
              ErrorOccured := true;
          end;
        end else begin
          if RoutingHeader.Get(ProdOrderLine2."Routing No.") or (ProdOrderLine2."Routing No." = '') then
            if RoutingHeader.Type <> RoutingHeader.Type::Parallel then begin
              ProdOrderRoutingLine3.SetRange(Status,ProdOrderLine2.Status);
              ProdOrderRoutingLine3.SetRange("Prod. Order No.",ProdOrderLine2."Prod. Order No.");
              ProdOrderRoutingLine3.SetRange("Routing Reference No.",ProdOrderLine2."Routing Reference No.");
              ProdOrderRoutingLine3.SetRange("Routing No.",ProdOrderLine2."Routing No.");
              ProdOrderRoutingLine3.SetFilter("Routing Status",'<>%1',ProdOrderRoutingLine3."Routing Status"::Finished);
              ProdOrderRoutingLine4.CopyFilters(ProdOrderRoutingLine3);
              if ProdOrderRoutingLine3.Find('-') then
                repeat
                  if ProdOrderRoutingLine3."Next Operation No." <> '' then begin
                    ProdOrderRoutingLine4.SetRange("Operation No.",ProdOrderRoutingLine3."Next Operation No.");
                    if ProdOrderRoutingLine4.IsEmpty then
                      Error(
                        Text002,
                        ProdOrderRoutingLine3."Next Operation No.");
                  end;
                  if ProdOrderRoutingLine3."Previous Operation No." <> '' then begin
                    ProdOrderRoutingLine4.SetRange("Operation No.",ProdOrderRoutingLine3."Previous Operation No.");
                    if ProdOrderRoutingLine4.IsEmpty then
                      Error(
                        Text003,
                        ProdOrderRoutingLine3."Previous Operation No.");
                  end;
                until ProdOrderRoutingLine3.Next = 0;
            end;
        end;

        if CalcComponents then begin
          if ProdOrderLine."Production BOM No." <> '' then begin
            Item.Get(ProdOrderLine."Item No.");
            GetPlanningParameters.AtSKU(
              SKU,
              ProdOrderLine."Item No.",
              ProdOrderLine."Variant Code",
              ProdOrderLine."Location Code");

            if not TransferBOM(
                 ProdOrderLine."Production BOM No.",
                 1,
                 ProdOrderLine."Qty. per Unit of Measure",
                 UOMMgt.GetQtyPerUnitOfMeasure(
                   Item,
                   VersionMgt.GetBOMUnitOfMeasure(
                     ProdOrderLine."Production BOM No.",
                     ProdOrderLine."Production BOM Version Code")))
            then
              ErrorOccured := true;
          end;
        end;
        Recalculate(ProdOrderLine,Direction,LetDueDateDecrease);
        exit(not ErrorOccured);
    end;

    [Scope('Personalization')]
    procedure Recalculate(var ProdOrderLine2: Record "Prod. Order Line";Direction: Option Forward,Backward;LetDueDateDecrease: Boolean)
    begin
        ProdOrderLine := ProdOrderLine2;
        ProdOrderLine.BlockDynamicTracking(Blocked);

        CalculateRouting(Direction,LetDueDateDecrease);
        CalculateComponents;
        ProdOrderLine2 := ProdOrderLine;
    end;

    [Scope('Personalization')]
    procedure BlockDynamicTracking(SetBlock: Boolean)
    begin
        Blocked := SetBlock;
    end;

    [Scope('Personalization')]
    procedure SetParameter(NewProdOrderModify: Boolean)
    begin
        ProdOrderModify := NewProdOrderModify;
    end;

    local procedure GetDefaultBin() BinCode: Code[20]
    var
        WMSMgt: Codeunit "WMS Management";
    begin
        with ProdOrderComp do
          if "Location Code" <> '' then begin
            if Location.Code <> "Location Code" then
              Location.Get("Location Code");
            if Location."Bin Mandatory" and (not Location."Directed Put-away and Pick") then
              WMSMgt.GetDefaultBin("Item No.","Variant Code","Location Code",BinCode);
          end;
    end;

    [Scope('Personalization')]
    procedure SetProdOrderLineBinCodeFromRoute(var ProdOrderLine: Record "Prod. Order Line";ParentLocationCode: Code[10];RoutingNo: Code[20])
    var
        RouteBinCode: Code[20];
    begin
        RouteBinCode :=
          WMSManagement.GetLastOperationFromBinCode(
            RoutingNo,
            ProdOrderLine."Routing Version Code",
            ProdOrderLine."Location Code",
            false,
            0);
        SetProdOrderLineBinCode(ProdOrderLine,RouteBinCode,ParentLocationCode);
    end;

    [Scope('Personalization')]
    procedure SetProdOrderLineBinCodeFromProdRtngLines(var ProdOrderLine: Record "Prod. Order Line")
    var
        ProdOrderRoutingLineBinCode: Code[20];
    begin
        if ProdOrderLine."Planning Level Code" > 0 then
          exit;

        ProdOrderRoutingLineBinCode :=
          WMSManagement.GetProdRtngLastOperationFromBinCode(
            ProdOrderLine.Status,
            ProdOrderLine."Prod. Order No.",
            ProdOrderLine."Line No.",
            ProdOrderLine."Routing No.",
            ProdOrderLine."Location Code");
        SetProdOrderLineBinCode(ProdOrderLine,ProdOrderRoutingLineBinCode,ProdOrderLine."Location Code");
    end;

    [Scope('Personalization')]
    procedure SetProdOrderLineBinCodeFromPlanningRtngLines(var ProdOrderLine: Record "Prod. Order Line";ReqLine: Record "Requisition Line")
    var
        PlanningLinesBinCode: Code[20];
    begin
        if ProdOrderLine."Planning Level Code" > 0 then
          exit;

        PlanningLinesBinCode :=
          WMSManagement.GetPlanningRtngLastOperationFromBinCode(
            ReqLine."Worksheet Template Name",
            ReqLine."Journal Batch Name",
            ReqLine."Line No.",
            ReqLine."Location Code");
        SetProdOrderLineBinCode(ProdOrderLine,PlanningLinesBinCode,ReqLine."Location Code");
    end;

    local procedure SetProdOrderLineBinCode(var ProdOrderLine: Record "Prod. Order Line";ParentBinCode: Code[20];ParentLocationCode: Code[10])
    var
        Location: Record Location;
        FromProdBinCode: Code[20];
    begin
        if ParentBinCode <> '' then
          ProdOrderLine.Validate("Bin Code",ParentBinCode)
        else
          if ProdOrderLine."Bin Code" = '' then begin
            if Location.Get(ParentLocationCode) then
              FromProdBinCode := Location."From-Production Bin Code";
            if FromProdBinCode <> '' then
              ProdOrderLine.Validate("Bin Code",FromProdBinCode)
            else
              if Location."Bin Mandatory" and not Location."Directed Put-away and Pick" then
                if WMSManagement.GetDefaultBin(ProdOrderLine."Item No.",ProdOrderLine."Variant Code",Location.Code,FromProdBinCode) then
                  ProdOrderLine.Validate("Bin Code",FromProdBinCode);
          end;
    end;

    [Scope('Personalization')]
    procedure FindAndSetProdOrderLineBinCodeFromProdRtngLines(ProdOrderStatus: Option;ProdOrderNo: Code[20];ProdOrderLineNo: Integer)
    begin
        if ProdOrderLine.Get(ProdOrderStatus,ProdOrderNo,ProdOrderLineNo) then begin
          SetProdOrderLineBinCodeFromProdRtngLines(ProdOrderLine);
          ProdOrderLine.Modify;
        end;
    end;

    [Scope('Personalization')]
    procedure AssignProdOrderLineBinCodeFromProdRtngLineMachineCenter(var ProdOrderRoutingLine: Record "Prod. Order Routing Line")
    var
        MachineCenter: Record "Machine Center";
    begin
        MachineCenter.SetRange("Work Center No.",ProdOrderRoutingLine."Work Center No.");
        if PAGE.RunModal(PAGE::"Machine Center List",MachineCenter) = ACTION::LookupOK then
          if (ProdOrderRoutingLine."No." <> MachineCenter."No.") or
             (ProdOrderRoutingLine.Type = ProdOrderRoutingLine.Type::"Work Center")
          then begin
            ProdOrderRoutingLine.Type := ProdOrderRoutingLine.Type::"Machine Center";
            ProdOrderRoutingLine.Validate("No.",MachineCenter."No.");
            FindAndSetProdOrderLineBinCodeFromProdRtngLines(
              ProdOrderRoutingLine.Status,ProdOrderRoutingLine."Prod. Order No.",ProdOrderRoutingLine."Routing Reference No.");
          end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertProdRoutingLine(var ProdOrderRoutingLine: Record "Prod. Order Routing Line";ProdOrderLine: Record "Prod. Order Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransferTaskInfo(var ProdOrderRoutingLine: Record "Prod. Order Routing Line";VersionCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransferRouting(var ProdOrderLine: Record "Prod. Order Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransferRoutingLine(var ProdOrderLine: Record "Prod. Order Line";var RoutingLine: Record "Routing Line";var ProdOrderRoutingLine: Record "Prod. Order Routing Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransferBOMComponent(var ProdOrderLine: Record "Prod. Order Line";var ProductionBOMLine: Record "Production BOM Line";var ProdOrderComponent: Record "Prod. Order Component")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterProdOrderCompFilter(var ProdOrderComp: Record "Prod. Order Component";ProdBOMLine: Record "Production BOM Line")
    begin
    end;
}

