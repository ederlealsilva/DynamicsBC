codeunit 99000809 "Planning Line Management"
{
    // version NAVW113.00

    Permissions = TableData "Manufacturing Setup"=rm,
                  TableData "Routing Header"=r,
                  TableData "Production BOM Header"=r,
                  TableData "Production BOM Line"=r,
                  TableData "Prod. Order Capacity Need"=rd,
                  TableData "Planning Component"=rimd,
                  TableData "Planning Routing Line"=rimd;

    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'BOM phantom structure for %1 is higher than 50 levels.';
        Text002: Label 'There is not enough space to insert lower level Make-to-Order lines.';
        Item: Record Item;
        SKU: Record "Stockkeeping Unit";
        ReqLine: Record "Requisition Line";
        ProdBOMLine: array [50] of Record "Production BOM Line";
        AsmBOMComp: array [50] of Record "BOM Component";
        PlanningRtngLine2: Record "Planning Routing Line";
        PlanningComponent: Record "Planning Component";
        TempPlanningComponent: Record "Planning Component" temporary;
        TempPlanningErrorLog: Record "Planning Error Log" temporary;
        CalcPlanningRtngLine: Codeunit "Calculate Planning Route Line";
        UOMMgt: Codeunit "Unit of Measure Management";
        CostCalcMgt: Codeunit "Cost Calculation Management";
        PlanningRoutingMgt: Codeunit PlanningRoutingManagement;
        VersionMgt: Codeunit VersionManagement;
        GetPlanningParameters: Codeunit "Planning-Get Parameters";
        LeadTimeMgt: Codeunit "Lead-Time Management";
        CalendarMgt: Codeunit CalendarManagement;
        LineSpacing: array [50] of Integer;
        NextPlanningCompLineNo: Integer;
        Blocked: Boolean;
        PlanningResiliency: Boolean;
        Text010: Label 'The line with %1 %2 for %3 %4 or one of its versions, has no %5 defined.';
        Text011: Label '%1 has recalculate set to false.';
        Text012: Label 'You must specify %1 in %2 %3.';
        Text014: Label 'Production BOM Header No. %1 used by Item %2 has BOM levels that exceed 50.';
        Text015: Label 'There is no more space to insert another line in the worksheet.';

    local procedure TransferRouting()
    var
        RtngHeader: Record "Routing Header";
        RtngLine: Record "Routing Line";
        PlanningRtngLine: Record "Planning Routing Line";
        MachCenter: Record "Machine Center";
    begin
        if ReqLine."Routing No." = '' then
          exit;

        RtngHeader.Get(ReqLine."Routing No.");
        RtngLine.SetRange("Routing No.",ReqLine."Routing No.");
        RtngLine.SetRange("Version Code",ReqLine."Routing Version Code");
        if RtngLine.Find('-') then
          repeat
            if PlanningResiliency and PlanningRtngLine.Recalculate then
              TempPlanningErrorLog.SetError(
                StrSubstNo(Text011,PlanningRtngLine.TableCaption),
                DATABASE::"Routing Header",RtngHeader.GetPosition);
            PlanningRtngLine.TestField(Recalculate,false);

            PlanningRtngLine."Worksheet Template Name" := ReqLine."Worksheet Template Name";
            PlanningRtngLine."Worksheet Batch Name" := ReqLine."Journal Batch Name";
            PlanningRtngLine."Worksheet Line No." := ReqLine."Line No.";
            PlanningRtngLine."Operation No." := RtngLine."Operation No.";
            PlanningRtngLine."Next Operation No." := RtngLine."Next Operation No.";
            PlanningRtngLine."Previous Operation No." := RtngLine."Previous Operation No.";
            PlanningRtngLine.Type := RtngLine.Type;
            PlanningRtngLine."No." := RtngLine."No.";
            if PlanningResiliency and (RtngLine."No." = '') then begin
              RtngHeader.Get(RtngLine."Routing No.");
              TempPlanningErrorLog.SetError(
                StrSubstNo(
                  Text010,
                  RtngLine.FieldCaption("Operation No."),RtngLine."Operation No.",
                  RtngHeader.TableCaption,RtngHeader."No.",
                  RtngLine.FieldCaption("No.")),
                DATABASE::"Routing Header",RtngHeader.GetPosition);
            end;
            RtngLine.TestField("No.");

            if PlanningResiliency and (RtngLine."Work Center No." = '') then begin
              MachCenter.Get(RtngLine."No.");
              TempPlanningErrorLog.SetError(
                StrSubstNo(
                  Text012,
                  MachCenter.FieldCaption("Work Center No."),
                  MachCenter.TableCaption,
                  MachCenter."No."),
                DATABASE::"Machine Center",MachCenter.GetPosition);
            end;
            RtngLine.TestField("Work Center No.");

            PlanningRtngLine."Work Center No." := RtngLine."Work Center No.";
            PlanningRtngLine."Work Center Group Code" := RtngLine."Work Center Group Code";
            PlanningRtngLine.Description := RtngLine.Description;
            PlanningRtngLine."Setup Time" := RtngLine."Setup Time";
            PlanningRtngLine."Run Time" := RtngLine."Run Time";
            PlanningRtngLine."Wait Time" := RtngLine."Wait Time";
            PlanningRtngLine."Move Time" := RtngLine."Move Time";
            PlanningRtngLine."Fixed Scrap Quantity" := RtngLine."Fixed Scrap Quantity";
            PlanningRtngLine."Lot Size" := RtngLine."Lot Size";
            PlanningRtngLine."Scrap Factor %" := RtngLine."Scrap Factor %";
            PlanningRtngLine."Setup Time Unit of Meas. Code" := RtngLine."Setup Time Unit of Meas. Code";
            PlanningRtngLine."Run Time Unit of Meas. Code" := RtngLine."Run Time Unit of Meas. Code";
            PlanningRtngLine."Wait Time Unit of Meas. Code" := RtngLine."Wait Time Unit of Meas. Code";
            PlanningRtngLine."Move Time Unit of Meas. Code" := RtngLine."Move Time Unit of Meas. Code";
            PlanningRtngLine."Minimum Process Time" := RtngLine."Minimum Process Time";
            PlanningRtngLine."Maximum Process Time" := RtngLine."Maximum Process Time";
            PlanningRtngLine."Concurrent Capacities" := RtngLine."Concurrent Capacities";
            if PlanningRtngLine."Concurrent Capacities" = 0 then
              PlanningRtngLine."Concurrent Capacities" := 1;

            PlanningRtngLine."Send-Ahead Quantity" := RtngLine."Send-Ahead Quantity";
            PlanningRtngLine."Routing Link Code" := RtngLine."Routing Link Code";
            PlanningRtngLine."Standard Task Code" := RtngLine."Standard Task Code";
            PlanningRtngLine."Unit Cost per" := RtngLine."Unit Cost per";
            CostCalcMgt.RoutingCostPerUnit(
              PlanningRtngLine.Type,
              PlanningRtngLine."No.",
              PlanningRtngLine."Direct Unit Cost",
              PlanningRtngLine."Indirect Cost %",
              PlanningRtngLine."Overhead Rate",
              PlanningRtngLine."Unit Cost per",
              PlanningRtngLine."Unit Cost Calculation");
            PlanningRtngLine.Validate("Direct Unit Cost");
            PlanningRtngLine."Sequence No.(Forward)" := RtngLine."Sequence No. (Forward)";
            PlanningRtngLine."Sequence No.(Backward)" := RtngLine."Sequence No. (Backward)";
            PlanningRtngLine."Fixed Scrap Qty. (Accum.)" := RtngLine."Fixed Scrap Qty. (Accum.)";
            PlanningRtngLine."Scrap Factor % (Accumulated)" := RtngLine."Scrap Factor % (Accumulated)";
            PlanningRtngLine."Output Quantity" := ReqLine.Quantity;
            PlanningRtngLine."Starting Date" := ReqLine."Starting Date";
            PlanningRtngLine."Starting Time" := ReqLine."Starting Time";
            PlanningRtngLine."Ending Date" := ReqLine."Ending Date";
            PlanningRtngLine."Ending Time" := ReqLine."Ending Time";
            PlanningRtngLine."Input Quantity" := ReqLine.Quantity;
            PlanningRtngLine.UpdateDatetime;
            OnAfterTransferRtngLine(ReqLine,RtngLine,PlanningRtngLine);
            PlanningRtngLine.Insert;
          until RtngLine.Next = 0;

        OnAfterTransferRouting(ReqLine);
    end;

    local procedure TransferBOM(ProdBOMNo: Code[20];Level: Integer;LineQtyPerUOM: Decimal;ItemQtyPerUOM: Decimal)
    var
        BOMHeader: Record "Production BOM Header";
        CompSKU: Record "Stockkeeping Unit";
        Item2: Record Item;
        ReqQty: Decimal;
    begin
        if ReqLine."Production BOM No." = '' then
          exit;

        PlanningComponent.LockTable;

        if Level > 50 then begin
          if PlanningResiliency then begin
            BOMHeader.Get(ReqLine."Production BOM No.");
            TempPlanningErrorLog.SetError(
              StrSubstNo(Text014,ReqLine."Production BOM No.",ReqLine."No."),
              DATABASE::"Production BOM Header",BOMHeader.GetPosition);
          end;
          Error(
            Text000,
            ProdBOMNo);
        end;

        if NextPlanningCompLineNo = 0 then begin
          PlanningComponent.SetRange("Worksheet Template Name",ReqLine."Worksheet Template Name");
          PlanningComponent.SetRange("Worksheet Batch Name",ReqLine."Journal Batch Name");
          PlanningComponent.SetRange("Worksheet Line No.",ReqLine."Line No.");
          if PlanningComponent.Find('+') then
            NextPlanningCompLineNo := PlanningComponent."Line No.";
          PlanningComponent.Reset;
        end;

        BOMHeader.Get(ProdBOMNo);

        ProdBOMLine[Level].SetRange("Production BOM No.",ProdBOMNo);
        if Level > 1 then
          ProdBOMLine[Level].SetRange("Version Code",VersionMgt.GetBOMVersion(BOMHeader."No.",ReqLine."Starting Date",true))
        else
          ProdBOMLine[Level].SetRange("Version Code",ReqLine."Production BOM Version Code");

        ProdBOMLine[Level].SetFilter("Starting Date",'%1|..%2',0D,ReqLine."Starting Date");
        ProdBOMLine[Level].SetFilter("Ending Date",'%1|%2..',0D,ReqLine."Starting Date");
        if ProdBOMLine[Level].Find('-') then
          repeat
            if ProdBOMLine[Level]."Routing Link Code" <> '' then begin
              PlanningRtngLine2.SetRange("Worksheet Template Name",ReqLine."Worksheet Template Name");
              PlanningRtngLine2.SetRange("Worksheet Batch Name",ReqLine."Journal Batch Name");
              PlanningRtngLine2.SetRange("Worksheet Line No.",ReqLine."Line No.");
              PlanningRtngLine2.SetRange("Routing Link Code",ProdBOMLine[Level]."Routing Link Code");
              PlanningRtngLine2.FindFirst;
              ReqQty :=
                ProdBOMLine[Level].Quantity *
                (1 + ProdBOMLine[Level]."Scrap %" / 100) *
                (1 + PlanningRtngLine2."Scrap Factor % (Accumulated)") *
                (1 + ReqLine."Scrap %" / 100) *
                LineQtyPerUOM /
                ItemQtyPerUOM +
                PlanningRtngLine2."Fixed Scrap Qty. (Accum.)";
            end else
              ReqQty :=
                ProdBOMLine[Level].Quantity *
                (1 + ProdBOMLine[Level]."Scrap %" / 100) *
                (1 + ReqLine."Scrap %" / 100) *
                LineQtyPerUOM /
                ItemQtyPerUOM;
            case ProdBOMLine[Level].Type of
              ProdBOMLine[Level].Type::Item:
                begin
                  if ReqQty <> 0 then begin
                    if not IsPlannedComp(PlanningComponent,ReqLine,ProdBOMLine[Level]) then begin
                      NextPlanningCompLineNo := NextPlanningCompLineNo + 10000;

                      PlanningComponent.Reset;
                      PlanningComponent.Init;
                      PlanningComponent.BlockDynamicTracking(Blocked);
                      PlanningComponent."Worksheet Template Name" := ReqLine."Worksheet Template Name";
                      PlanningComponent."Worksheet Batch Name" := ReqLine."Journal Batch Name";
                      PlanningComponent."Worksheet Line No." := ReqLine."Line No.";
                      PlanningComponent."Line No." := NextPlanningCompLineNo;
                      PlanningComponent.Validate("Item No.",ProdBOMLine[Level]."No.");
                      PlanningComponent."Variant Code" := ProdBOMLine[Level]."Variant Code";
                      PlanningComponent."Location Code" := SKU."Components at Location";
                      PlanningComponent.Description := ProdBOMLine[Level].Description;
                      PlanningComponent."Planning Line Origin" := ReqLine."Planning Line Origin";
                      PlanningComponent.Validate("Unit of Measure Code",ProdBOMLine[Level]."Unit of Measure Code");
                      PlanningComponent."Quantity per" := ProdBOMLine[Level]."Quantity per" * LineQtyPerUOM / ItemQtyPerUOM;
                      PlanningComponent.Validate("Routing Link Code",ProdBOMLine[Level]."Routing Link Code");
                      OnTransferBOMOnBeforeGetDefaultBin(PlanningComponent,ProdBOMLine[Level]);
                      PlanningComponent.GetDefaultBin;
                      PlanningComponent.Length := ProdBOMLine[Level].Length;
                      PlanningComponent.Width := ProdBOMLine[Level].Width;
                      PlanningComponent.Weight := ProdBOMLine[Level].Weight;
                      PlanningComponent.Depth := ProdBOMLine[Level].Depth;
                      PlanningComponent.Quantity := ProdBOMLine[Level].Quantity;
                      PlanningComponent.Position := ProdBOMLine[Level].Position;
                      PlanningComponent."Position 2" := ProdBOMLine[Level]."Position 2";
                      PlanningComponent."Position 3" := ProdBOMLine[Level]."Position 3";
                      PlanningComponent."Lead-Time Offset" := ProdBOMLine[Level]."Lead-Time Offset";
                      PlanningComponent.Validate("Scrap %",ProdBOMLine[Level]."Scrap %");
                      PlanningComponent.Validate("Calculation Formula",ProdBOMLine[Level]."Calculation Formula");

                      GetPlanningParameters.AtSKU(
                        CompSKU,
                        PlanningComponent."Item No.",
                        PlanningComponent."Variant Code",
                        PlanningComponent."Location Code");
                      if Item2.Get(PlanningComponent."Item No.") then
                        PlanningComponent.Critical := Item2.Critical;

                      PlanningComponent."Flushing Method" := CompSKU."Flushing Method";
                      if (SKU."Manufacturing Policy" = SKU."Manufacturing Policy"::"Make-to-Order") and
                         (CompSKU."Manufacturing Policy" = CompSKU."Manufacturing Policy"::"Make-to-Order") and
                         (CompSKU."Replenishment System" = CompSKU."Replenishment System"::"Prod. Order")
                      then
                        PlanningComponent."Planning Level Code" := ReqLine."Planning Level" + 1;

                      PlanningComponent."Ref. Order Type" := ReqLine."Ref. Order Type";
                      PlanningComponent."Ref. Order Status" := ReqLine."Ref. Order Status";
                      PlanningComponent."Ref. Order No." := ReqLine."Ref. Order No.";
                      OnBeforeInsertPlanningComponent(ReqLine,ProdBOMLine[Level],PlanningComponent);
                      PlanningComponent.Insert;
                    end else begin
                      PlanningComponent.Reset;
                      PlanningComponent.BlockDynamicTracking(Blocked);
                      PlanningComponent.Validate(
                        "Quantity per",
                        PlanningComponent."Quantity per" + ProdBOMLine[Level]."Quantity per" * LineQtyPerUOM / ItemQtyPerUOM);
                      PlanningComponent.Validate("Routing Link Code",ProdBOMLine[Level]."Routing Link Code");
                      OnBeforeModifyPlanningComponent(ReqLine,ProdBOMLine[Level],PlanningComponent);
                      PlanningComponent.Modify;
                    end;

                    // A temporary list of Planning Components handled is sustained:
                    TempPlanningComponent := PlanningComponent;
                    if not TempPlanningComponent.Insert then
                      TempPlanningComponent.Modify;
                  end;
                end;
              ProdBOMLine[Level].Type::"Production BOM":
                begin
                  TransferBOM(ProdBOMLine[Level]."No.",Level + 1,ReqQty,1);
                  ProdBOMLine[Level].SetRange("Production BOM No.",ProdBOMNo);
                  ProdBOMLine[Level].SetRange(
                    "Version Code",VersionMgt.GetBOMVersion(ProdBOMNo,ReqLine."Starting Date",true));
                  ProdBOMLine[Level].SetFilter("Starting Date",'%1|..%2',0D,ReqLine."Starting Date");
                  ProdBOMLine[Level].SetFilter("Ending Date",'%1|%2..',0D,ReqLine."Starting Date");
                end;
            end;
          until ProdBOMLine[Level].Next = 0;
    end;

    local procedure TransferAsmBOM(ParentItemNo: Code[20];Level: Integer;Quantity: Decimal)
    var
        ParentItem: Record Item;
        CompSKU: Record "Stockkeeping Unit";
        Item2: Record Item;
        ReqQty: Decimal;
    begin
        PlanningComponent.LockTable;

        if Level > 50 then begin
          if PlanningResiliency then begin
            Item.Get(ReqLine."No.");
            TempPlanningErrorLog.SetError(
              StrSubstNo(Text014,ReqLine."No.",ReqLine."No."),
              DATABASE::Item,Item.GetPosition);
          end;
          Error(
            Text000,
            ParentItemNo);
        end;

        if NextPlanningCompLineNo = 0 then begin
          PlanningComponent.SetRange("Worksheet Template Name",ReqLine."Worksheet Template Name");
          PlanningComponent.SetRange("Worksheet Batch Name",ReqLine."Journal Batch Name");
          PlanningComponent.SetRange("Worksheet Line No.",ReqLine."Line No.");
          if PlanningComponent.Find('+') then
            NextPlanningCompLineNo := PlanningComponent."Line No.";
          PlanningComponent.Reset;
        end;

        ParentItem.Get(ParentItemNo);

        AsmBOMComp[Level].SetRange("Parent Item No.",ParentItemNo);
        if AsmBOMComp[Level].Find('-') then
          repeat
            ReqQty := Quantity * AsmBOMComp[Level]."Quantity per";
            case AsmBOMComp[Level].Type of
              AsmBOMComp[Level].Type::Item:
                begin
                  if ReqQty <> 0 then begin
                    if not IsPlannedAsmComp(PlanningComponent,ReqLine,AsmBOMComp[Level]) then begin
                      NextPlanningCompLineNo := NextPlanningCompLineNo + 10000;

                      PlanningComponent.Reset;
                      PlanningComponent.Init;
                      PlanningComponent.BlockDynamicTracking(Blocked);
                      PlanningComponent."Worksheet Template Name" := ReqLine."Worksheet Template Name";
                      PlanningComponent."Worksheet Batch Name" := ReqLine."Journal Batch Name";
                      PlanningComponent."Worksheet Line No." := ReqLine."Line No.";
                      PlanningComponent."Line No." := NextPlanningCompLineNo;
                      PlanningComponent.Validate("Item No.",AsmBOMComp[Level]."No.");
                      PlanningComponent."Variant Code" := AsmBOMComp[Level]."Variant Code";
                      PlanningComponent."Location Code" := SKU."Components at Location";
                      PlanningComponent.Description := CopyStr(AsmBOMComp[Level].Description,1,MaxStrLen(PlanningComponent.Description));
                      PlanningComponent."Planning Line Origin" := ReqLine."Planning Line Origin";
                      PlanningComponent.Validate("Unit of Measure Code",AsmBOMComp[Level]."Unit of Measure Code");
                      PlanningComponent."Quantity per" := Quantity * AsmBOMComp[Level]."Quantity per";
                      PlanningComponent.GetDefaultBin;
                      PlanningComponent.Quantity := AsmBOMComp[Level]."Quantity per";
                      PlanningComponent.Position := AsmBOMComp[Level].Position;
                      PlanningComponent."Position 2" := AsmBOMComp[Level]."Position 2";
                      PlanningComponent."Position 3" := AsmBOMComp[Level]."Position 3";
                      PlanningComponent."Lead-Time Offset" := AsmBOMComp[Level]."Lead-Time Offset";
                      PlanningComponent.Validate("Routing Link Code");
                      PlanningComponent.Validate("Scrap %",0);
                      PlanningComponent.Validate("Calculation Formula",PlanningComponent."Calculation Formula"::" ");

                      GetPlanningParameters.AtSKU(
                        CompSKU,
                        PlanningComponent."Item No.",
                        PlanningComponent."Variant Code",
                        PlanningComponent."Location Code");
                      if Item2.Get(PlanningComponent."Item No.") then
                        PlanningComponent.Critical := Item2.Critical;

                      PlanningComponent."Flushing Method" := CompSKU."Flushing Method";
                      PlanningComponent."Ref. Order Type" := ReqLine."Ref. Order Type";
                      PlanningComponent."Ref. Order Status" := ReqLine."Ref. Order Status";
                      PlanningComponent."Ref. Order No." := ReqLine."Ref. Order No.";
                      OnBeforeInsertAsmPlanningComponent(ReqLine,AsmBOMComp[Level],PlanningComponent);
                      PlanningComponent.Insert;
                    end else begin
                      PlanningComponent.Reset;
                      PlanningComponent.BlockDynamicTracking(Blocked);
                      PlanningComponent.Validate(
                        "Quantity per",
                        PlanningComponent."Quantity per" +
                        Quantity *
                        AsmBOMComp[Level]."Quantity per");
                      PlanningComponent.Validate("Routing Link Code",'');
                      PlanningComponent.Modify;
                    end;

                    // A temporary list of Planning Components handled is sustained:
                    TempPlanningComponent := PlanningComponent;
                    if not TempPlanningComponent.Insert then
                      TempPlanningComponent.Modify;
                  end;
                end;
            end;
          until AsmBOMComp[Level].Next = 0;
    end;

    local procedure CalculateComponents()
    var
        PlanningAssignment: Record "Planning Assignment";
    begin
        PlanningComponent.SetRange("Worksheet Template Name",ReqLine."Worksheet Template Name");
        PlanningComponent.SetRange("Worksheet Batch Name",ReqLine."Journal Batch Name");
        PlanningComponent.SetRange("Worksheet Line No.",ReqLine."Line No.");

        if PlanningComponent.Find('-') then
          repeat
            PlanningComponent.BlockDynamicTracking(Blocked);
            PlanningComponent.Validate("Routing Link Code");
            PlanningComponent.Modify;
            with PlanningComponent do
              PlanningAssignment.ChkAssignOne("Item No.","Variant Code","Location Code","Due Date");
          until PlanningComponent.Next = 0;
    end;

    [Scope('Personalization')]
    procedure CalculateRoutingFromActual(PlanningRtngLine: Record "Planning Routing Line";Direction: Option Forward,Backward;CalcStartEndDate: Boolean)
    begin
        if (ReqLine."Worksheet Template Name" <> PlanningRtngLine."Worksheet Template Name") or
           (ReqLine."Journal Batch Name" <> PlanningRtngLine."Worksheet Batch Name") or
           (ReqLine."Line No." <> PlanningRtngLine."Worksheet Line No.")
        then
          ReqLine.Get(
            PlanningRtngLine."Worksheet Template Name",
            PlanningRtngLine."Worksheet Batch Name",PlanningRtngLine."Worksheet Line No.");

        if  PlanningRoutingMgt.NeedsCalculation(
             PlanningRtngLine."Worksheet Template Name",
             PlanningRtngLine."Worksheet Batch Name",
             PlanningRtngLine."Worksheet Line No.")
        then begin
          PlanningRoutingMgt.Calculate(ReqLine);
          PlanningRtngLine.Get(
            PlanningRtngLine."Worksheet Template Name",
            PlanningRtngLine."Worksheet Batch Name",
            PlanningRtngLine."Worksheet Line No.",PlanningRtngLine."Operation No.");
        end;
        if Direction = Direction::Forward then
          PlanningRtngLine.SetCurrentKey(
            "Worksheet Template Name",
            "Worksheet Batch Name",
            "Worksheet Line No.",
            "Sequence No.(Forward)")
        else
          PlanningRtngLine.SetCurrentKey(
            "Worksheet Template Name",
            "Worksheet Batch Name",
            "Worksheet Line No.",
            "Sequence No.(Backward)");

        PlanningRtngLine.SetRange("Worksheet Template Name",PlanningRtngLine."Worksheet Template Name");
        PlanningRtngLine.SetRange("Worksheet Batch Name",PlanningRtngLine."Worksheet Batch Name");
        PlanningRtngLine.SetRange("Worksheet Line No.",PlanningRtngLine."Worksheet Line No.");

        repeat
          if CalcStartEndDate then begin
            if ((Direction = Direction::Forward) and (PlanningRtngLine."Previous Operation No." <> '')) or
               ((Direction = Direction::Backward) and (PlanningRtngLine."Next Operation No." <> ''))
            then begin
              PlanningRtngLine."Starting Time" := 0T;
              PlanningRtngLine."Starting Date" := 0D;
              PlanningRtngLine."Ending Time" := 235959T;
              PlanningRtngLine."Ending Date" := CalendarMgt.GetMaxDate;
            end;
          end;
          Clear(CalcPlanningRtngLine);
          if PlanningResiliency then
            CalcPlanningRtngLine.SetResiliencyOn(
              ReqLine."Worksheet Template Name",ReqLine."Journal Batch Name",ReqLine."No.");
          CalcPlanningRtngLine.CalculateRouteLine(PlanningRtngLine,Direction,CalcStartEndDate,ReqLine);
          CalcStartEndDate := true;
        until PlanningRtngLine.Next = 0;
    end;

    local procedure CalculateRouting(Direction: Option Forward,Backward)
    var
        PlanningRtngLine: Record "Planning Routing Line";
    begin
        if PlanningRoutingMgt.NeedsCalculation(
             ReqLine."Worksheet Template Name",
             ReqLine."Journal Batch Name",
             ReqLine."Line No.")
        then
          PlanningRoutingMgt.Calculate(ReqLine);

        if Direction = Direction::Forward then
          PlanningRtngLine.SetCurrentKey(
            "Worksheet Template Name",
            "Worksheet Batch Name",
            "Worksheet Line No.",
            "Sequence No.(Forward)")
        else
          PlanningRtngLine.SetCurrentKey(
            "Worksheet Template Name",
            "Worksheet Batch Name",
            "Worksheet Line No.",
            "Sequence No.(Backward)");

        PlanningRtngLine.SetRange("Worksheet Template Name",ReqLine."Worksheet Template Name");
        PlanningRtngLine.SetRange("Worksheet Batch Name",ReqLine."Journal Batch Name");
        PlanningRtngLine.SetRange("Worksheet Line No.",ReqLine."Line No.");
        if not PlanningRtngLine.FindFirst then begin
          if Direction = Direction::Forward then
            ReqLine.CalcEndingDate('')
          else
            ReqLine.CalcStartingDate('');
          ReqLine.UpdateDatetime;
          exit;
        end;

        if Direction = Direction::Forward then begin
          PlanningRtngLine."Starting Date" := ReqLine."Starting Date";
          PlanningRtngLine."Starting Time" := ReqLine."Starting Time";
        end else begin
          PlanningRtngLine."Ending Date" := ReqLine."Ending Date";
          PlanningRtngLine."Ending Time" := ReqLine."Ending Time";
        end;
        CalculateRoutingFromActual(PlanningRtngLine,Direction,false);

        CalculatePlanningLineDates(ReqLine);
    end;

    [Scope('Personalization')]
    procedure CalculatePlanningLineDates(var ReqLine2: Record "Requisition Line")
    var
        PlanningRtngLine: Record "Planning Routing Line";
        IsLineModified: Boolean;
    begin
        PlanningRtngLine.SetRange("Worksheet Template Name",ReqLine2."Worksheet Template Name");
        PlanningRtngLine.SetRange("Worksheet Batch Name",ReqLine2."Journal Batch Name");
        PlanningRtngLine.SetRange("Worksheet Line No.",ReqLine2."Line No.");
        PlanningRtngLine.SetFilter("Next Operation No.",'%1','');

        if PlanningRtngLine.FindFirst then begin
          ReqLine2."Ending Date" := PlanningRtngLine."Ending Date";
          ReqLine2."Ending Time" := PlanningRtngLine."Ending Time";
          IsLineModified := true;
        end;

        PlanningRtngLine.SetRange("Next Operation No.");
        PlanningRtngLine.SetFilter("Previous Operation No.",'%1','');
        if PlanningRtngLine.FindFirst then begin
          ReqLine2."Starting Date" := PlanningRtngLine."Starting Date";
          ReqLine2."Starting Time" := PlanningRtngLine."Starting Time";
          ReqLine2."Order Date" := PlanningRtngLine."Starting Date";
          IsLineModified := true;
        end;

        if IsLineModified then begin
          ReqLine2.UpdateDatetime;
          ReqLine2.Modify;
        end;
    end;

    procedure Calculate(var ReqLine2: Record "Requisition Line";Direction: Option Forward,Backward;CalcRouting: Boolean;CalcComponents: Boolean;PlanningLevel: Integer)
    var
        PlanningRtngLine: Record "Planning Routing Line";
        ProdOrderCapNeed: Record "Prod. Order Capacity Need";
    begin
        ReqLine := ReqLine2;
        if ReqLine."Action Message" <> ReqLine."Action Message"::Cancel then
          ReqLine.TestField(Quantity);
        if Direction = Direction::Backward then
          ReqLine.TestField("Ending Date")
        else
          ReqLine.TestField("Starting Date");

        if CalcRouting then begin
          PlanningRtngLine.SetRange("Worksheet Template Name",ReqLine."Worksheet Template Name");
          PlanningRtngLine.SetRange("Worksheet Batch Name",ReqLine."Journal Batch Name");
          PlanningRtngLine.SetRange("Worksheet Line No.",ReqLine."Line No.");
          PlanningRtngLine.DeleteAll;

          ProdOrderCapNeed.SetCurrentKey(
            "Worksheet Template Name","Worksheet Batch Name","Worksheet Line No.");
          ProdOrderCapNeed.SetRange("Worksheet Template Name",ReqLine."Worksheet Template Name");
          ProdOrderCapNeed.SetRange("Worksheet Batch Name",ReqLine."Journal Batch Name");
          ProdOrderCapNeed.SetRange("Worksheet Line No.",ReqLine."Line No.");
          ProdOrderCapNeed.DeleteAll;
          TransferRouting;
        end;

        if CalcComponents then begin
          PlanningComponent.SetRange("Worksheet Template Name",ReqLine."Worksheet Template Name");
          PlanningComponent.SetRange("Worksheet Batch Name",ReqLine."Journal Batch Name");
          PlanningComponent.SetRange("Worksheet Line No.",ReqLine."Line No.");
          if PlanningComponent.Find('-') then
            repeat
              PlanningComponent.BlockDynamicTracking(Blocked);
              PlanningComponent.Delete(true);
            until PlanningComponent.Next = 0;
          if ReqLine."Planning Level" = 0 then
            ReqLine.DeleteMultiLevel;
          if (ReqLine."Replenishment System" = ReqLine."Replenishment System"::Assembly) or
             ((ReqLine."Replenishment System" = ReqLine."Replenishment System"::"Prod. Order") and (ReqLine."Production BOM No." <> ''))
          then begin
            Item.Get(ReqLine."No.");
            GetPlanningParameters.AtSKU(
              SKU,
              ReqLine."No.",
              ReqLine."Variant Code",
              ReqLine."Location Code");

            if ReqLine."Replenishment System" = ReqLine."Replenishment System"::Assembly then
              TransferAsmBOM(
                Item."No.",
                1,
                ReqLine."Qty. per Unit of Measure")
            else
              TransferBOM(
                ReqLine."Production BOM No.",
                1,
                ReqLine."Qty. per Unit of Measure",
                UOMMgt.GetQtyPerUnitOfMeasure(
                  Item,
                  VersionMgt.GetBOMUnitOfMeasure(ReqLine."Production BOM No.",ReqLine."Production BOM Version Code")));
          end;
        end;
        Recalculate(ReqLine,Direction);
        ReqLine2 := ReqLine;
        if CalcComponents and
           (SKU."Manufacturing Policy" = SKU."Manufacturing Policy"::"Make-to-Order")
        then
          CheckMultiLevelStructure(ReqLine,CalcRouting,CalcComponents,PlanningLevel);
    end;

    [Scope('Personalization')]
    procedure Recalculate(var ReqLine2: Record "Requisition Line";Direction: Option Forward,Backward)
    begin
        RecalculateWithOptionalModify(ReqLine2,Direction,true);
    end;

    [Scope('Personalization')]
    procedure RecalculateWithOptionalModify(var ReqLine2: Record "Requisition Line";Direction: Option Forward,Backward;ModifyRec: Boolean)
    begin
        ReqLine := ReqLine2;

        CalculateRouting(Direction);
        if ModifyRec then
          ReqLine.Modify(true);
        CalculateComponents;
        if ReqLine."Planning Level" > 0 then begin
          if Direction = Direction::Forward then
            ReqLine."Due Date" := ReqLine."Ending Date"
        end else
          if (ReqLine."Due Date" < ReqLine."Ending Date") or
             (Direction = Direction::Forward)
          then
            ReqLine."Due Date" :=
              LeadTimeMgt.PlannedDueDate(
                ReqLine."No.",
                ReqLine."Location Code",
                ReqLine."Variant Code",
                ReqLine."Ending Date",
                ReqLine."Vendor No.",
                ReqLine."Ref. Order Type");
        ReqLine.UpdateDatetime;
        ReqLine2 := ReqLine;
    end;

    local procedure CheckMultiLevelStructure(ReqLine2: Record "Requisition Line";CalcRouting: Boolean;CalcComponents: Boolean;PlanningLevel: Integer)
    var
        ReqLine3: Record "Requisition Line";
        Item3: Record Item;
        PlanningComp: Record "Planning Component";
        PlngComponentReserve: Codeunit "Plng. Component-Reserve";
        PlanningLineNo: Integer;
        NoOfComponents: Integer;
    begin
        if PlanningLevel < 0 then
          exit;

        if not Item3.Get(ReqLine2."No.") then
          exit;
        if Item3."Manufacturing Policy" <> Item3."Manufacturing Policy"::"Make-to-Order" then
          exit;

        PlanningLineNo := ReqLine2."Line No.";

        PlanningComp.SetRange("Worksheet Line No.",ReqLine2."Line No.");
        PlanningComp.SetFilter("Item No.",'<>%1','');
        PlanningComp.SetFilter("Expected Quantity",'<>0');
        PlanningComp.SetFilter("Planning Level Code",'>0');
        NoOfComponents := PlanningComp.Count;
        if PlanningLevel = 0 then begin
          ReqLine3.Reset;
          ReqLine3.SetRange("Worksheet Template Name",ReqLine."Worksheet Template Name");
          ReqLine3.SetRange("Journal Batch Name",ReqLine."Journal Batch Name");
          ReqLine3 := ReqLine2;
          if ReqLine3.Find('>') then
            LineSpacing[1] := (ReqLine3."Line No." - ReqLine."Line No.") div (1 + NoOfComponents)
          else
            LineSpacing[1] := 10000;
        end else
          if (PlanningLevel > 0) and (PlanningLevel < 50) then
            LineSpacing[PlanningLevel + 1] := LineSpacing[PlanningLevel] div (1 + NoOfComponents);

        if PlanningComp.Find('-') then
          repeat
            if LineSpacing[PlanningLevel + 1] = 0 then begin
              if PlanningResiliency then
                TempPlanningErrorLog.SetError(Text015,DATABASE::"Requisition Line",ReqLine.GetPosition);
              Error(Text002);
            end;
            ReqLine3.Init;
            ReqLine3.BlockDynamicTracking(Blocked);
            ReqLine3."Worksheet Template Name" := ReqLine2."Worksheet Template Name";
            ReqLine3."Journal Batch Name" := ReqLine2."Journal Batch Name";
            PlanningLineNo := PlanningLineNo + LineSpacing[PlanningLevel + 1];
            ReqLine3."Line No." := PlanningLineNo;
            ReqLine3."Ref. Order Type" := ReqLine2."Ref. Order Type";
            ReqLine3."Ref. Order Status" := ReqLine2."Ref. Order Status";
            ReqLine3."Ref. Order No." := ReqLine2."Ref. Order No.";

            ReqLine3."Planning Line Origin" := ReqLine2."Planning Line Origin";
            ReqLine3.Level := ReqLine2.Level;
            ReqLine3."Demand Type" := ReqLine2."Demand Type";
            ReqLine3."Demand Subtype" := ReqLine2."Demand Subtype";
            ReqLine3."Demand Order No." := ReqLine2."Demand Order No.";
            ReqLine3."Demand Line No." := ReqLine2."Demand Line No.";
            ReqLine3."Demand Ref. No." := ReqLine2."Demand Ref. No.";
            ReqLine3."Demand Ref. No." := ReqLine2."Demand Ref. No.";
            ReqLine3."Demand Date" := ReqLine2."Demand Date";
            ReqLine3.Status := ReqLine2.Status;
            ReqLine3."User ID" := ReqLine2."User ID";

            ReqLine3.Type := ReqLine3.Type::Item;
            ReqLine3.Validate("No.",PlanningComp."Item No.");
            ReqLine3."Action Message" := ReqLine2."Action Message";
            ReqLine3."Accept Action Message" := ReqLine2."Accept Action Message";
            ReqLine3.Description := PlanningComp.Description;
            ReqLine3."Variant Code" := PlanningComp."Variant Code";
            ReqLine3."Unit of Measure Code" := PlanningComp."Unit of Measure Code";
            ReqLine3."Location Code" := PlanningComp."Location Code";
            ReqLine3."Bin Code" := PlanningComp."Bin Code";
            ReqLine3."Ending Date" := PlanningComp."Due Date";
            ReqLine3.Validate("Ending Time",PlanningComp."Due Time");
            ReqLine3."Due Date" := PlanningComp."Due Date";
            ReqLine3."Demand Date" := PlanningComp."Due Date";
            ReqLine3.Validate(Quantity,PlanningComp."Expected Quantity");
            ReqLine3.Validate("Needed Quantity",PlanningComp."Expected Quantity");
            ReqLine3.Validate("Demand Quantity",PlanningComp."Expected Quantity");
            ReqLine3."Demand Qty. Available" := 0;

            ReqLine3."Planning Level" := PlanningLevel + 1;
            ReqLine3."Related to Planning Line" := ReqLine2."Line No.";
            ReqLine3."Order Promising ID" := ReqLine2."Order Promising ID";
            ReqLine3."Order Promising Line ID" := ReqLine2."Order Promising Line ID";
            OnCheckMultiLevelStructureOnBeforeInsertPlanningLine(ReqLine3,PlanningComp);
            InsertPlanningLine(ReqLine3);
            ReqLine3.Quantity :=
              Round(
                ReqLine3."Quantity (Base)" /
                ReqLine3."Qty. per Unit of Measure",0.00001);
            ReqLine3."Net Quantity (Base)" :=
              (ReqLine3.Quantity -
               ReqLine3."Original Quantity") *
              ReqLine3."Qty. per Unit of Measure";
            ReqLine3.Modify;
            PlngComponentReserve.BindToRequisition(
              PlanningComp,ReqLine3,PlanningComp."Expected Quantity",PlanningComp."Expected Quantity (Base)");
            PlanningComp."Supplied-by Line No." := ReqLine3."Line No.";
            PlanningComp.Modify;
            ReqLine3.Validate("Production BOM No.");
            ReqLine3.Validate("Routing No.");
            ReqLine3.Modify;
            Calculate(ReqLine3,1,CalcRouting,CalcComponents,PlanningLevel + 1);
            ReqLine3.Modify;
          until PlanningComp.Next = 0;
    end;

    local procedure InsertPlanningLine(var ReqLine: Record "Requisition Line")
    var
        ReqLine2: Record "Requisition Line";
    begin
        ReqLine2 := ReqLine;
        ReqLine2.SetCurrentKey("Worksheet Template Name","Journal Batch Name",Type,"No.");
        ReqLine2.SetRange("Worksheet Template Name",ReqLine."Worksheet Template Name");
        ReqLine2.SetRange("Journal Batch Name",ReqLine."Journal Batch Name");
        ReqLine2.SetRange(Type,ReqLine.Type::Item);
        ReqLine2.SetRange("No.",ReqLine."No.");
        ReqLine2.SetRange("Variant Code",ReqLine."Variant Code");
        ReqLine2.SetRange("Ref. Order Type",ReqLine."Ref. Order Type");
        ReqLine2.SetRange("Ref. Order Status",ReqLine."Ref. Order Status");
        ReqLine2.SetRange("Ref. Order No.",ReqLine."Ref. Order No.");
        ReqLine2.SetFilter("Planning Level",'>%1',0);

        if ReqLine2.FindFirst then begin
          ReqLine2.BlockDynamicTracking(Blocked);
          ReqLine2.Validate(Quantity,ReqLine2.Quantity + ReqLine.Quantity);

          if ReqLine2."Due Date" > ReqLine."Due Date" then
            ReqLine2."Due Date" := ReqLine."Due Date";

          if ReqLine2."Ending Date" > ReqLine."Ending Date" then begin
            ReqLine2."Ending Date" := ReqLine."Ending Date";
            ReqLine2."Ending Time" := ReqLine."Ending Time";
          end else
            if (ReqLine2."Ending Date" = ReqLine."Ending Date") and
               (ReqLine2."Ending Time" > ReqLine."Ending Time")
            then
              ReqLine2."Ending Time" := ReqLine."Ending Time";

          if ReqLine2."Planning Level" < ReqLine."Planning Level" then
            ReqLine2."Planning Level" := ReqLine."Planning Level";

          ReqLine2.Modify;
          ReqLine := ReqLine2;
        end else
          ReqLine.Insert;
    end;

    [Scope('Personalization')]
    procedure BlockDynamicTracking(SetBlock: Boolean)
    begin
        Blocked := SetBlock;
    end;

    [Scope('Personalization')]
    procedure GetPlanningCompList(var PlanningCompList: Record "Planning Component" temporary)
    begin
        // The procedure returns a list of the Planning Components handled.
        if TempPlanningComponent.Find('-') then
          repeat
            PlanningCompList := TempPlanningComponent;
            if not PlanningCompList.Insert then
              PlanningCompList.Modify;
            TempPlanningComponent.Delete;
          until TempPlanningComponent.Next = 0;
    end;

    local procedure IsPlannedComp(var PlanningComp: Record "Planning Component";ReqLine: Record "Requisition Line";ProdBOMLine: Record "Production BOM Line"): Boolean
    var
        PlanningComp2: Record "Planning Component";
    begin
        with PlanningComp do begin
          PlanningComp2 := PlanningComp;

          SetCurrentKey(
            "Worksheet Template Name","Worksheet Batch Name","Worksheet Line No.","Item No.");
          SetRange("Worksheet Template Name",ReqLine."Worksheet Template Name");
          SetRange("Worksheet Batch Name",ReqLine."Journal Batch Name");
          SetRange("Worksheet Line No.",ReqLine."Line No.");
          SetRange("Item No.",ProdBOMLine."No.");
          if Find('-') then
            repeat
              if ("Variant Code" = ProdBOMLine."Variant Code") and
                 ("Routing Link Code" = ProdBOMLine."Routing Link Code") and
                 (Position = ProdBOMLine.Position) and
                 ("Position 2" = ProdBOMLine."Position 2") and
                 ("Position 3" = ProdBOMLine."Position 3") and
                 (Length = ProdBOMLine.Length) and
                 (Width = ProdBOMLine.Width) and
                 (Weight = ProdBOMLine.Weight) and
                 (Depth = ProdBOMLine.Depth) and
                 ("Unit of Measure Code" = ProdBOMLine."Unit of Measure Code")
              then
                exit(true);
            until Next = 0;

          PlanningComp := PlanningComp2;
          exit(false);
        end;
    end;

    local procedure IsPlannedAsmComp(var PlanningComp: Record "Planning Component";ReqLine: Record "Requisition Line";AsmBOMComp: Record "BOM Component"): Boolean
    var
        PlanningComp2: Record "Planning Component";
    begin
        with PlanningComp do begin
          PlanningComp2 := PlanningComp;

          SetCurrentKey(
            "Worksheet Template Name","Worksheet Batch Name","Worksheet Line No.","Item No.");
          SetRange("Worksheet Template Name",ReqLine."Worksheet Template Name");
          SetRange("Worksheet Batch Name",ReqLine."Journal Batch Name");
          SetRange("Worksheet Line No.",ReqLine."Line No.");
          SetRange("Item No.",AsmBOMComp."No.");
          if Find('-') then
            repeat
              if ("Variant Code" = AsmBOMComp."Variant Code") and
                 (Position = AsmBOMComp.Position) and
                 ("Position 2" = AsmBOMComp."Position 2") and
                 ("Position 3" = AsmBOMComp."Position 3") and
                 ("Unit of Measure Code" = AsmBOMComp."Unit of Measure Code")
              then
                exit(true);
            until Next = 0;

          PlanningComp := PlanningComp2;
          exit(false);
        end;
    end;

    [Scope('Personalization')]
    procedure SetResiliencyOn(WkshTemplName: Code[10];JnlBatchName: Code[10];ItemNo: Code[20])
    begin
        PlanningResiliency := true;
        TempPlanningErrorLog.SetJnlBatch(WkshTemplName,JnlBatchName,ItemNo);
    end;

    [Scope('Personalization')]
    procedure GetResiliencyError(var PlanningErrorLog: Record "Planning Error Log"): Boolean
    begin
        TempPlanningComponent.DeleteAll;
        if CalcPlanningRtngLine.GetResiliencyError(PlanningErrorLog) then
          exit(true);
        exit(TempPlanningErrorLog.GetError(PlanningErrorLog));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransferRouting(var RequisitionLine: Record "Requisition Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransferRtngLine(var ReqLine: Record "Requisition Line";var RoutingLine: Record "Routing Line";var PlanningRoutingLine: Record "Planning Routing Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnTransferBOMOnBeforeGetDefaultBin(var PlanningComponent: Record "Planning Component";var ProductionBOMLine: Record "Production BOM Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPlanningComponent(var ReqLine: Record "Requisition Line";var ProductionBOMLine: Record "Production BOM Line";var PlanningComponent: Record "Planning Component")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyPlanningComponent(var ReqLine: Record "Requisition Line";var ProductionBOMLine: Record "Production BOM Line";var PlanningComponent: Record "Planning Component")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertAsmPlanningComponent(var ReqLine: Record "Requisition Line";var BOMComponent: Record "BOM Component";var PlanningComponent: Record "Planning Component")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckMultiLevelStructureOnBeforeInsertPlanningLine(var ReqLine: Record "Requisition Line";var PlanningComponent: Record "Planning Component")
    begin
    end;
}

