page 361 "Res. Availability Lines"
{
    // version NAVW113.00

    Caption = 'Lines';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = ListPart;
    SaveValues = true;
    SourceTable = Date;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Period Start";"Period Start")
                {
                    ApplicationArea = Jobs;
                    Caption = 'Period Start';
                    ToolTip = 'Specifies a series of dates according to the selected time interval.';
                }
                field("Period Name";"Period Name")
                {
                    ApplicationArea = Jobs;
                    Caption = 'Period Name';
                    ToolTip = 'Specifies the name of the period shown in the line.';
                }
                field(Capacity;Res.Capacity)
                {
                    ApplicationArea = Jobs;
                    Caption = 'Capacity';
                    DecimalPlaces = 0:5;
                    ToolTip = 'Specifies the total capacity for the corresponding time period.';
                }
                field("Res.""Qty. on Order (Job)""";Res."Qty. on Order (Job)")
                {
                    ApplicationArea = Jobs;
                    Caption = 'Qty. on Order (Job)';
                    DecimalPlaces = 0:5;
                    ToolTip = 'Specifies the amount of measuring units allocated to jobs with the status order.';
                }
                field(CapacityAfterOrders;CapacityAfterOrders)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Availability After Orders';
                    DecimalPlaces = 0:5;
                    ToolTip = 'Specifies capacity minus the quantity on order.';
                }
                field("Res.""Qty. Quoted (Job)""";Res."Qty. Quoted (Job)")
                {
                    ApplicationArea = Jobs;
                    Caption = 'Job Quotes Allocation';
                    DecimalPlaces = 0:5;
                    ToolTip = 'Specifies the amount of measuring units allocated to jobs with the status quote.';
                }
                field(CapacityAfterQuotes;CapacityAfterQuotes)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Availability After Quotes';
                    DecimalPlaces = 0:5;
                    ToolTip = 'Specifies capacity, minus quantity on order (Job), minus quantity on service order, minus job quotes allocation. ';
                }
                field("Res.""Qty. on Service Order""";Res."Qty. on Service Order")
                {
                    ApplicationArea = Service;
                    Caption = 'Qty. on Service Order';
                    ToolTip = 'Specifies how many units of the item are allocated to service orders, meaning listed on outstanding service order lines.';
                }
                field(QtyOnAssemblyOrder;Res."Qty. on Assembly Order")
                {
                    ApplicationArea = Assembly;
                    Caption = 'Qty. on Assembly Order';
                    ToolTip = 'Specifies how many units of the item are allocated to assembly orders, which is how many are listed on outstanding assembly order headers.';
                }
                field(NetAvailability;NetAvailability)
                {
                    ApplicationArea = Jobs;
                    AutoFormatType = 1;
                    Caption = 'Net Availability';
                    ToolTip = 'Specifies capacity, minus the quantity on order, minus the jobs quotes allocation.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        SetDateFilter;
        Res.CalcFields(Capacity,"Qty. on Order (Job)","Qty. Quoted (Job)","Qty. on Service Order","Qty. on Assembly Order");
        CapacityAfterOrders := Res.Capacity - Res."Qty. on Order (Job)";
        CapacityAfterQuotes := CapacityAfterOrders - Res."Qty. Quoted (Job)";
        NetAvailability := CapacityAfterQuotes - Res."Qty. on Service Order" - Res."Qty. on Assembly Order";
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        exit(PeriodFormMgt.FindDate(Which,Rec,PeriodType));
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin
        exit(PeriodFormMgt.NextDate(Steps,Rec,PeriodType));
    end;

    trigger OnOpenPage()
    begin
        Reset;
    end;

    var
        Res: Record Resource;
        PeriodFormMgt: Codeunit PeriodFormManagement;
        CapacityAfterOrders: Decimal;
        CapacityAfterQuotes: Decimal;
        NetAvailability: Decimal;
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period";
        AmountType: Option "Net Change","Balance at Date";

    [Scope('Personalization')]
    procedure Set(var NewRes: Record Resource;NewPeriodType: Integer;NewAmountType: Option "Net Change","Balance at Date")
    begin
        Res.Copy(NewRes);
        PeriodType := NewPeriodType;
        AmountType := NewAmountType;
        CurrPage.Update(false);
    end;

    local procedure SetDateFilter()
    begin
        if AmountType = AmountType::"Net Change" then
          Res.SetRange("Date Filter","Period Start","Period End")
        else
          Res.SetRange("Date Filter",0D,"Period End");
    end;
}

