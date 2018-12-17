table 5742 "Transfer Route"
{
    // version NAVW111.00

    Caption = 'Transfer Route';
    DataCaptionFields = "Transfer-from Code","Transfer-to Code";

    fields
    {
        field(1;"Transfer-from Code";Code[10])
        {
            Caption = 'Transfer-from Code';
            TableRelation = Location WHERE ("Use As In-Transit"=CONST(false));
        }
        field(2;"Transfer-to Code";Code[10])
        {
            Caption = 'Transfer-to Code';
            TableRelation = Location WHERE ("Use As In-Transit"=CONST(false));
        }
        field(4;"In-Transit Code";Code[10])
        {
            Caption = 'In-Transit Code';
            TableRelation = Location WHERE ("Use As In-Transit"=CONST(true));
        }
        field(5;"Shipping Agent Code";Code[10])
        {
            AccessByPermission = TableData "Shipping Agent Services"=R;
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";

            trigger OnValidate()
            begin
                if "Shipping Agent Code" <> xRec."Shipping Agent Code" then
                  Validate("Shipping Agent Service Code",'');
            end;
        }
        field(6;"Shipping Agent Service Code";Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services".Code WHERE ("Shipping Agent Code"=FIELD("Shipping Agent Code"));
        }
    }

    keys
    {
        key(Key1;"Transfer-from Code","Transfer-to Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Text003: Label 'The receipt date must be greater or equal to the shipment date.';
        CalChange: Record "Customized Calendar Change";
        ShippingAgentServices: Record "Shipping Agent Services";
        CalendarMgmt: Codeunit "Calendar Management";
        HasTransferRoute: Boolean;
        HasShippingAgentService: Boolean;

    [Scope('Personalization')]
    procedure GetTransferRoute(TransferFromCode: Code[10];TransferToCode: Code[10];var InTransitCode: Code[10];var ShippingAgentCode: Code[10];var ShippingAgentServiceCode: Code[10])
    var
        HasGotRecord: Boolean;
    begin
        if ("Transfer-from Code" <> TransferFromCode) or
           ("Transfer-to Code" <> TransferToCode)
        then
          if Get(TransferFromCode,TransferToCode) then
            HasGotRecord := true;

        if HasGotRecord then begin
          InTransitCode := "In-Transit Code";
          ShippingAgentCode := "Shipping Agent Code";
          ShippingAgentServiceCode := "Shipping Agent Service Code";
        end else begin
          InTransitCode := '';
          ShippingAgentCode := '';
          ShippingAgentServiceCode := '';
        end;
    end;

    [Scope('Personalization')]
    procedure CalcReceiptDate(ShipmentDate: Date;var ReceiptDate: Date;ShippingTime: DateFormula;OutboundWhseTime: DateFormula;InboundWhseTime: DateFormula;TransferFromCode: Code[10];TransferToCode: Code[10];ShippingAgentCode: Code[10];ShippingAgentServiceCode: Code[10])
    var
        PlannedReceiptDate: Date;
        PlannedShipmentDate: Date;
    begin
        if ShipmentDate <> 0D then begin
          // The calculation will run through the following steps:
          // ShipmentDate -> PlannedShipmentDate -> PlannedReceiptDate -> ReceiptDate

          // Calc Planned Shipment Date forward from Shipment Date
          CalcPlanShipmentDateForward(
            ShipmentDate,PlannedShipmentDate,OutboundWhseTime,
            TransferFromCode,ShippingAgentCode,ShippingAgentServiceCode);

          // Calc Planned Receipt Date forward from Planned Shipment Date
          CalcPlannedReceiptDateForward(
            PlannedShipmentDate,PlannedReceiptDate,ShippingTime,
            TransferToCode,ShippingAgentCode,ShippingAgentServiceCode);

          // Calc Receipt Date forward from Planned Receipt Date
          CalcReceiptDateForward(PlannedReceiptDate,ReceiptDate,InboundWhseTime,TransferToCode);

          if ShipmentDate > ReceiptDate then
            Error(Text003);
        end else
          ReceiptDate := 0D;
    end;

    local procedure CalcPlanShipmentDateForward(ShipmentDate: Date;var PlannedShipmentDate: Date;OutboundWhseTime: DateFormula;TransferFromCode: Code[10];ShippingAgentCode: Code[10];ShippingAgentServiceCode: Code[10])
    begin
        // Calc Planned Shipment Date forward from Shipment Date

        if ShipmentDate <> 0D then begin
          if Format(OutboundWhseTime) = '' then
            Evaluate(OutboundWhseTime,'<0D>');

          PlannedShipmentDate :=
            CalendarMgmt.CalcDateBOC(
              Format(OutboundWhseTime),
              ShipmentDate,
              CalChange."Source Type"::Location,
              TransferFromCode,
              '',
              CalChange."Source Type"::"Shipping Agent",
              ShippingAgentCode,
              ShippingAgentServiceCode,
              true);
        end else
          PlannedShipmentDate := 0D;
    end;

    [Scope('Personalization')]
    procedure CalcPlannedReceiptDateForward(PlannedShipmentDate: Date;var PlannedReceiptDate: Date;ShippingTime: DateFormula;TransferToCode: Code[10];ShippingAgentCode: Code[10];ShippingAgentServiceCode: Code[10])
    begin
        // Calc Planned Receipt Date forward from Planned Shipment Date

        if PlannedShipmentDate <> 0D then begin
          if Format(ShippingTime) = '' then
            Evaluate(ShippingTime,'<0D>');

          PlannedReceiptDate :=
            CalendarMgmt.CalcDateBOC(
              Format(ShippingTime),
              PlannedShipmentDate,
              CalChange."Source Type"::"Shipping Agent",
              ShippingAgentCode,
              ShippingAgentServiceCode,
              CalChange."Source Type"::Location,
              TransferToCode,
              '',
              true);
        end else
          PlannedReceiptDate := 0D;
    end;

    [Scope('Personalization')]
    procedure CalcReceiptDateForward(PlannedReceiptDate: Date;var ReceiptDate: Date;InboundWhseTime: DateFormula;TransferToCode: Code[10])
    begin
        // Calc Receipt Date forward from Planned Receipt Date

        if PlannedReceiptDate <> 0D then begin
          if Format(InboundWhseTime) = '' then
            Evaluate(InboundWhseTime,'<0D>');

          ReceiptDate :=
            CalendarMgmt.CalcDateBOC(
              Format(InboundWhseTime),
              PlannedReceiptDate,
              CalChange."Source Type"::Location,
              TransferToCode,
              '',
              CalChange."Source Type"::Location,
              TransferToCode,
              '',
              false);
        end else
          ReceiptDate := 0D;
    end;

    [Scope('Personalization')]
    procedure CalcShipmentDate(var ShipmentDate: Date;ReceiptDate: Date;ShippingTime: DateFormula;OutboundWhseTime: DateFormula;InboundWhseTime: DateFormula;TransferFromCode: Code[10];TransferToCode: Code[10];ShippingAgentCode: Code[10];ShippingAgentServiceCode: Code[10])
    var
        PlannedReceiptDate: Date;
        PlannedShipmentDate: Date;
    begin
        if ReceiptDate <> 0D then begin
          // The calculation will run through the following steps:
          // ShipmentDate <- PlannedShipmentDate <- PlannedReceiptDate <- ReceiptDate

          // Calc Planned Receipt Date backward from ReceiptDate
          CalcPlanReceiptDateBackward(
            PlannedReceiptDate,ReceiptDate,InboundWhseTime,
            TransferToCode,ShippingAgentCode,ShippingAgentServiceCode);

          // Calc Planned Shipment Date backward from Planned ReceiptDate
          CalcPlanShipmentDateBackward(
            PlannedShipmentDate,PlannedReceiptDate,ShippingTime,
            TransferFromCode,ShippingAgentCode,ShippingAgentServiceCode);

          // Calc Shipment Date backward from Planned Shipment Date
          CalcShipmentDateBackward(
            ShipmentDate,PlannedShipmentDate,OutboundWhseTime,TransferFromCode);
        end else
          ShipmentDate := 0D;
    end;

    [Scope('Personalization')]
    procedure CalcPlanReceiptDateBackward(var PlannedReceiptDate: Date;ReceiptDate: Date;InboundWhseTime: DateFormula;TransferToCode: Code[10];ShippingAgentCode: Code[10];ShippingAgentServiceCode: Code[10])
    begin
        // Calc Planned Receipt Date backward from ReceiptDate

        if ReceiptDate <> 0D then begin
          if Format(InboundWhseTime) = '' then
            Evaluate(InboundWhseTime,'<0D>');

          PlannedReceiptDate :=
            CalendarMgmt.CalcDateBOC2(
              Format(InboundWhseTime),
              ReceiptDate,
              CalChange."Source Type"::Location,
              TransferToCode,
              '',
              CalChange."Source Type"::"Shipping Agent",
              ShippingAgentCode,
              ShippingAgentServiceCode,
              true);
        end else
          PlannedReceiptDate := 0D;
    end;

    [Scope('Personalization')]
    procedure CalcPlanShipmentDateBackward(var PlannedShipmentDate: Date;PlannedReceiptDate: Date;ShippingTime: DateFormula;TransferFromCode: Code[10];ShippingAgentCode: Code[10];ShippingAgentServiceCode: Code[10])
    begin
        // Calc Planned Shipment Date backward from Planned ReceiptDate

        if PlannedReceiptDate <> 0D then begin
          if Format(ShippingTime) = '' then
            Evaluate(ShippingTime,'<0D>');

          PlannedShipmentDate :=
            CalendarMgmt.CalcDateBOC2(
              Format(ShippingTime),
              PlannedReceiptDate,
              CalChange."Source Type"::"Shipping Agent",
              ShippingAgentCode,
              ShippingAgentServiceCode,
              CalChange."Source Type"::Location,
              TransferFromCode,
              '',
              true);
        end else
          PlannedShipmentDate := 0D;
    end;

    [Scope('Personalization')]
    procedure CalcShipmentDateBackward(var ShipmentDate: Date;PlannedShipmentDate: Date;OutboundWhseTime: DateFormula;TransferFromCode: Code[10])
    begin
        // Calc Shipment Date backward from Planned Shipment Date

        if PlannedShipmentDate <> 0D then begin
          if Format(OutboundWhseTime) = '' then
            Evaluate(OutboundWhseTime,'<0D>');

          ShipmentDate :=
            CalendarMgmt.CalcDateBOC2(
              Format(OutboundWhseTime),
              PlannedShipmentDate,
              CalChange."Source Type"::Location,
              TransferFromCode,
              '',
              CalChange."Source Type"::Location,
              TransferFromCode,
              '',
              false);
        end else
          ShipmentDate := 0D;
    end;

    [Scope('Personalization')]
    procedure GetShippingTime(TransferFromCode: Code[10];TransferToCode: Code[10];ShippingAgentCode: Code[10];ShippingAgentServiceCode: Code[10];var ShippingTime: DateFormula)
    begin
        if (ShippingAgentServices."Shipping Agent Code" <> ShippingAgentCode) or
           (ShippingAgentServices.Code <> ShippingAgentServiceCode)
        then begin
          if ShippingAgentServices.Get(ShippingAgentCode,ShippingAgentServiceCode) then
            HasShippingAgentService := true;
        end else
          HasShippingAgentService := true;

        if HasShippingAgentService then
          ShippingTime := ShippingAgentServices."Shipping Time"
        else begin
          if ("Transfer-from Code" <> TransferFromCode) or
             ("Transfer-to Code" <> TransferToCode)
          then begin
            if Get(TransferFromCode,TransferToCode) then
              HasTransferRoute := true;
          end else
            HasTransferRoute := true;
          if HasTransferRoute and
             ShippingAgentServices.Get("Shipping Agent Code","Shipping Agent Service Code")
          then
            ShippingTime := ShippingAgentServices."Shipping Time"
          else
            Evaluate(ShippingTime,'');
        end;
    end;
}

