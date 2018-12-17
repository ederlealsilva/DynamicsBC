codeunit 7171 "Sales Info-Pane Management"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        SalesPriceCalcMgt: Codeunit "Sales Price Calc. Mgt.";
        AvailableToPromise: Codeunit "Available to Promise";

    [Scope('Personalization')]
    procedure CalcAvailability(var SalesLine: Record "Sales Line"): Decimal
    var
        GrossRequirement: Decimal;
        ScheduledReceipt: Decimal;
        PeriodType: Option Day,Week,Month,Quarter,Year;
        LookaheadDateformula: DateFormula;
    begin
        if GetItem(SalesLine) then begin
          SetItemFilter(Item,SalesLine);

          Evaluate(LookaheadDateformula,'<0D>');
          exit(
            ConvertQty(
              AvailableToPromise.QtyAvailabletoPromise(
                Item,
                GrossRequirement,
                ScheduledReceipt,
                CalcAvailabilityDate(SalesLine),
                PeriodType,
                LookaheadDateformula),
              SalesLine."Qty. per Unit of Measure"));
        end;
    end;

    [Scope('Personalization')]
    procedure CalcAvailabilityDate(SalesLine: Record "Sales Line"): Date
    begin
        if SalesLine."Shipment Date" <> 0D then
          exit(SalesLine."Shipment Date");

        exit(WorkDate);
    end;

    [Scope('Personalization')]
    procedure CalcAvailableInventory(SalesLine: Record "Sales Line"): Decimal
    begin
        if GetItem(SalesLine) then begin
          SetItemFilter(Item,SalesLine);

          exit(
            ConvertQty(
              AvailableToPromise.CalcAvailableInventory(Item),
              SalesLine."Qty. per Unit of Measure"));
        end;
    end;

    [Scope('Personalization')]
    procedure CalcScheduledReceipt(SalesLine: Record "Sales Line"): Decimal
    begin
        if GetItem(SalesLine) then begin
          SetItemFilter(Item,SalesLine);

          exit(
            ConvertQty(
              AvailableToPromise.CalcScheduledReceipt(Item),
              SalesLine."Qty. per Unit of Measure"));
        end;
    end;

    [Scope('Personalization')]
    procedure CalcGrossRequirements(SalesLine: Record "Sales Line"): Decimal
    begin
        if GetItem(SalesLine) then begin
          SetItemFilter(Item,SalesLine);

          exit(
            ConvertQty(
              AvailableToPromise.CalcGrossRequirement(Item),
              SalesLine."Qty. per Unit of Measure"));
        end;
    end;

    [Scope('Personalization')]
    procedure CalcReservedRequirements(SalesLine: Record "Sales Line"): Decimal
    begin
        if GetItem(SalesLine) then begin
          SetItemFilter(Item,SalesLine);

          exit(
            ConvertQty(
              AvailableToPromise.CalcReservedReceipt(Item),
              SalesLine."Qty. per Unit of Measure"));
        end;
    end;

    [Scope('Personalization')]
    procedure CalcReservedDemand(SalesLine: Record "Sales Line"): Decimal
    begin
        if GetItem(SalesLine) then begin
          SetItemFilter(Item,SalesLine);

          exit(
            ConvertQty(
              AvailableToPromise.CalcReservedRequirement(Item),
              SalesLine."Qty. per Unit of Measure"));
        end;
    end;

    [Scope('Personalization')]
    procedure CalcNoOfSubstitutions(SalesLine: Record "Sales Line"): Integer
    begin
        if GetItem(SalesLine) then begin
          Item.CalcFields("No. of Substitutes");
          exit(Item."No. of Substitutes");
        end;
    end;

    [Scope('Personalization')]
    procedure CalcNoOfSalesPrices(SalesLine: Record "Sales Line"): Integer
    begin
        if GetItem(SalesLine) then begin
          GetSalesHeader(SalesLine);
          exit(SalesPriceCalcMgt.NoOfSalesLinePrice(SalesHeader,SalesLine,true));
        end;
    end;

    [Scope('Personalization')]
    procedure CalcNoOfSalesLineDisc(SalesLine: Record "Sales Line"): Integer
    begin
        if GetItem(SalesLine) then begin
          GetSalesHeader(SalesLine);
          exit(SalesPriceCalcMgt.NoOfSalesLineLineDisc(SalesHeader,SalesLine,true));
        end;
    end;

    local procedure ConvertQty(Qty: Decimal;PerUoMQty: Decimal): Decimal
    begin
        if PerUoMQty = 0 then
          PerUoMQty := 1;
        exit(Round(Qty / PerUoMQty,0.00001));
    end;

    [Scope('Personalization')]
    procedure LookupItem(SalesLine: Record "Sales Line")
    begin
        SalesLine.TestField(Type,SalesLine.Type::Item);
        SalesLine.TestField("No.");
        GetItem(SalesLine);
        PAGE.RunModal(PAGE::"Item Card",Item);
    end;

    local procedure GetItem(var SalesLine: Record "Sales Line"): Boolean
    begin
        with Item do begin
          if (SalesLine.Type <> SalesLine.Type::Item) or (SalesLine."No." = '') then
            exit(false);

          if SalesLine."No." <> "No." then
            Get(SalesLine."No.");
          exit(true);
        end;
    end;

    local procedure GetSalesHeader(SalesLine: Record "Sales Line")
    begin
        if (SalesLine."Document Type" <> SalesHeader."Document Type") or
           (SalesLine."Document No." <> SalesHeader."No.")
        then
          SalesHeader.Get(SalesLine."Document Type",SalesLine."Document No.");
    end;

    local procedure SetItemFilter(var Item: Record Item;SalesLine: Record "Sales Line")
    begin
        Item.Reset;
        Item.SetRange("Date Filter",0D,CalcAvailabilityDate(SalesLine));
        Item.SetRange("Variant Filter",SalesLine."Variant Code");
        Item.SetRange("Location Filter",SalesLine."Location Code");
        Item.SetRange("Drop Shipment Filter",false);
        OnAfterSetItemFilter(Item,SalesLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetItemFilter(var Item: Record Item;SalesLine: Record "Sales Line")
    begin
    end;
}

