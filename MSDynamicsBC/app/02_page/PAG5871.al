page 5871 "Item Availability by BOM Level"
{
    // version NAVW113.00

    Caption = 'Item Availability by BOM Level';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    SourceTable = "BOM Buffer";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(Option)
            {
                Caption = 'Option';
                field(ItemFilter;ItemFilter)
                {
                    ApplicationArea = Assembly;
                    Caption = 'Item Filter';
                    ToolTip = 'Specifies the item you want to show availability information for.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Item: Record Item;
                        ItemList: Page "Item List";
                    begin
                        ItemList.SetTableView(Item);
                        ItemList.LookupMode := true;
                        if ItemList.RunModal = ACTION::LookupOK then begin
                          ItemList.GetRecord(Item);
                          Text := Item."No.";
                          exit(true);
                        end;
                        exit(false);
                    end;

                    trigger OnValidate()
                    begin
                        IsCalculated := false;
                        RefreshPage;
                    end;
                }
                field(LocationFilter;LocationFilter)
                {
                    ApplicationArea = Assembly;
                    Caption = 'Location Filter';
                    ToolTip = 'Specifies the location that you want to show item availability for.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Location: Record Location;
                        LocationList: Page "Location List";
                    begin
                        LocationList.SetTableView(Location);
                        LocationList.LookupMode := true;
                        if LocationList.RunModal = ACTION::LookupOK then begin
                          LocationList.GetRecord(Location);
                          Text := Location.Code;
                          exit(true);
                        end;
                        exit(false);
                    end;

                    trigger OnValidate()
                    begin
                        IsCalculated := false;
                        RefreshPage;
                    end;
                }
                field(VariantFilter;VariantFilter)
                {
                    ApplicationArea = Planning;
                    Caption = 'Variant Filter';
                    ToolTip = 'Specifies the item variant you want to show availability for.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ItemVariant: Record "Item Variant";
                        ItemVariants: Page "Item Variants";
                    begin
                        ItemVariant.SetFilter("Item No.",ItemFilter);
                        ItemVariants.SetTableView(ItemVariant);
                        ItemVariants.LookupMode := true;
                        if ItemVariants.RunModal = ACTION::LookupOK then begin
                          ItemVariants.GetRecord(ItemVariant);
                          Text := ItemVariant.Code;
                          exit(true);
                        end;
                        exit(false);
                    end;

                    trigger OnValidate()
                    begin
                        IsCalculated := false;
                        RefreshPage;
                    end;
                }
                field(DemandDate;DemandDate)
                {
                    ApplicationArea = Assembly;
                    Caption = 'Demand Date';
                    ToolTip = 'Specifies the date when you want to potentially make the parents, or top items, shown in the Item Availability by BOM Level window.';

                    trigger OnValidate()
                    begin
                        IsCalculated := false;
                        RefreshPage;
                    end;
                }
                field(IsCalculated;IsCalculated)
                {
                    ApplicationArea = Assembly;
                    Caption = 'Calculated';
                    Editable = false;
                    ToolTip = 'Specifies that the low-level code of the item on the line has been calculated.';
                }
                field(ShowTotalAvailability;ShowTotalAvailability)
                {
                    ApplicationArea = Assembly;
                    Caption = 'Show Total Availability';
                    ToolTip = 'Specifies whether the Item Availability by BOM Level window shows availability of all items, including the potential availability of parents.';

                    trigger OnValidate()
                    begin
                        IsCalculated := false;
                        RefreshPage;
                    end;
                }
            }
            repeater(Group)
            {
                Caption = 'Lines';
                IndentationColumn = Indentation;
                ShowAsTree = true;
                field("No.";"No.")
                {
                    ApplicationArea = Assembly;
                    Editable = false;
                    Style = Strong;
                    StyleExpr = IsParentExpr;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Assembly;
                    Editable = false;
                    ToolTip = 'Specifies the item''s description.';
                }
                field(HasWarning;HasWarning)
                {
                    ApplicationArea = Assembly;
                    BlankZero = true;
                    Caption = 'Warning';
                    Editable = false;
                    Style = Attention;
                    StyleExpr = HasWarning;
                    ToolTip = 'Specifies if the BOM line has setup or data issues. Choose the field to open the BOM Warning Log window to see a description of the issue.';

                    trigger OnDrillDown()
                    begin
                        if HasWarning then
                          ShowWarnings;
                    end;
                }
                field(Bottleneck;Bottleneck)
                {
                    ApplicationArea = Assembly;
                    Editable = false;
                    Style = Strong;
                    StyleExpr = TRUE;
                    ToolTip = 'Specifies which item in the BOM structure restricts you from making a larger quantity than what is shown in the Able to Make Top Item field.';
                }
                field("Variant Code";"Variant Code")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant code that you entered in the Variant Filter field in the Item Availability by BOM Level window.';
                    Visible = false;
                }
                field("Qty. per Parent";"Qty. per Parent")
                {
                    ApplicationArea = Assembly;
                    DecimalPlaces = 0:5;
                    Editable = false;
                    ToolTip = 'Specifies how many units of the component are required to assemble or produce one unit of the parent.';
                }
                field("Qty. per Top Item";"Qty. per Top Item")
                {
                    ApplicationArea = Assembly;
                    DecimalPlaces = 0:5;
                    Editable = false;
                    ToolTip = 'Specifies how many units of the component are required to assemble or produce one unit of the top item.';
                    Visible = false;
                }
                field("Unit of Measure Code";"Unit of Measure Code")
                {
                    ApplicationArea = Assembly;
                    Editable = false;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                field("Replenishment System";"Replenishment System")
                {
                    ApplicationArea = Assembly;
                    Editable = false;
                    ToolTip = 'Specifies the item''s replenishment system.';
                }
                field("Available Quantity";"Available Quantity")
                {
                    ApplicationArea = Assembly;
                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies how many units of the item on the line are available, regardless of how many parents you can make with the item.';
                }
                field("Unused Quantity";"Unused Quantity")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the part of the item''s total availability that is not required to make the quantities that are shown in the fields.';
                    Visible = false;
                }
                field("Needed by Date";"Needed by Date")
                {
                    ApplicationArea = Assembly;
                    Editable = false;
                    ToolTip = 'Specifies when the item must be available to make the parent or top item.';
                }
                field("Able to Make Parent";"Able to Make Parent")
                {
                    ApplicationArea = Assembly;
                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies how many units of the BOM item on the collapsible line above it can be assembled or produced.';
                }
                field("Able to Make Top Item";"Able to Make Top Item")
                {
                    ApplicationArea = Assembly;
                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies how many units of the BOM item on the top line can be assembled or produced.';
                }
                field("Gross Requirement";"Gross Requirement")
                {
                    ApplicationArea = Basic,Suite;
                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies the total demand for the item.';
                    Visible = false;
                }
                field("Scheduled Receipts";"Scheduled Receipts")
                {
                    ApplicationArea = Basic,Suite;
                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies how many units of the item are inbound on orders.';
                    Visible = false;
                }
                field("Safety Lead Time";"Safety Lead Time")
                {
                    ApplicationArea = Planning;
                    Editable = false;
                    ToolTip = 'Specifies any safety lead time that is defined for the item.';
                    Visible = false;
                }
                field("Rolled-up Lead-Time Offset";"Rolled-up Lead-Time Offset")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the cumulative lead time of components under a parent item.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Item")
            {
                Caption = '&Item';
                Image = Item;
                group("&Item Availability by")
                {
                    Caption = '&Item Availability by';
                    Image = ItemAvailability;
                    action("Event")
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Event';
                        Image = "Event";
                        ToolTip = 'View how the actual and the projected available balance of an item will develop over time according to supply and demand events.';

                        trigger OnAction()
                        begin
                            ItemAvail(ItemAvailFormsMgt.ByEvent);
                        end;
                    }
                    action(Period)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Period';
                        Image = Period;
                        ToolTip = 'View the projected quantity of the item over time according to time periods, such as day, week, or month.';

                        trigger OnAction()
                        begin
                            ItemAvail(ItemAvailFormsMgt.ByPeriod);
                        end;
                    }
                    action(Variant)
                    {
                        ApplicationArea = Planning;
                        Caption = 'Variant';
                        Image = ItemVariant;
                        ToolTip = 'View or edit the item''s variants. Instead of setting up each color of an item as a separate item, you can set up the various colors as variants of the item.';

                        trigger OnAction()
                        begin
                            ItemAvail(ItemAvailFormsMgt.ByVariant);
                        end;
                    }
                    action(Location)
                    {
                        AccessByPermission = TableData Location=R;
                        ApplicationArea = Basic,Suite;
                        Caption = 'Location';
                        Image = Warehouse;
                        ToolTip = 'View the actual and projected quantity of the item per location.';

                        trigger OnAction()
                        begin
                            ItemAvail(ItemAvailFormsMgt.ByLocation);
                        end;
                    }
                }
            }
        }
        area(processing)
        {
            action("Previous Period")
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Previous Period';
                Image = PreviousRecord;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Show the information based on the previous period. If you set the View by field to Day, the date filter changes to the day before.';

                trigger OnAction()
                begin
                    DemandDate := CalcDate('<-1D>',DemandDate);
                    RefreshPage;
                end;
            }
            action("Next Period")
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Next Period';
                Image = NextRecord;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Show the information based on the next period. If you set the View by field to Day, the date filter changes to the day before.';

                trigger OnAction()
                begin
                    DemandDate := CalcDate('<+1D>',DemandDate);
                    RefreshPage;
                end;
            }
            action("Show Warnings")
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Show Warnings';
                Image = ErrorLog;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'View details about bottlenecks.';

                trigger OnAction()
                begin
                    ShowWarningsForAllLines;
                end;
            }
        }
        area(reporting)
        {
            action("Item - Able to Make (Timeline)")
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Item - Able to Make (Timeline)';
                Image = Trendscape;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'View five key availability figures over time for the selected parent item. The figures change according to expected supply and demand events and to supply that is based on available components that can be assembled or produced. You can use the report to see whether you can fulfill a sales order for an item on a specified date by looking at its current availability in combination with the potential quantities that its components can supply if an assembly order were started.';

                trigger OnAction()
                begin
                    ShowAbleToMakeTimeline;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        DummyBOMWarningLog: Record "BOM Warning Log";
    begin
        IsParentExpr := not "Is Leaf";

        HasWarning := not IsLineOk(false,DummyBOMWarningLog);
    end;

    trigger OnOpenPage()
    begin
        ShowTotalAvailability := true;
        if DemandDate = 0D then
          DemandDate := WorkDate;
        RefreshPage;
    end;

    var
        Item: Record Item;
        AsmHeader: Record "Assembly Header";
        ProdOrderLine: Record "Prod. Order Line";
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        [InDataSet]
        IsParentExpr: Boolean;
        ItemFilter: Code[250];
        LocationFilter: Code[250];
        VariantFilter: Code[250];
        DemandDate: Date;
        IsCalculated: Boolean;
        ShowTotalAvailability: Boolean;
        ShowBy: Option Item,Assembly,Production;
        Text000: Label 'Could not find items with BOM levels.';
        Text001: Label 'There are no warnings.';
        [InDataSet]
        HasWarning: Boolean;

    [Scope('Personalization')]
    procedure InitItem(var NewItem: Record Item)
    begin
        Item.Copy(NewItem);
        ItemFilter := Item."No.";
        VariantFilter := Item.GetFilter("Variant Filter");
        LocationFilter := Item.GetFilter("Location Filter");
        ShowBy := ShowBy::Item;
    end;

    [Scope('Personalization')]
    procedure InitAsmOrder(NewAsmHeader: Record "Assembly Header")
    begin
        AsmHeader := NewAsmHeader;
        ShowBy := ShowBy::Assembly;
    end;

    [Scope('Personalization')]
    procedure InitProdOrder(NewProdOrderLine: Record "Prod. Order Line")
    begin
        ProdOrderLine := NewProdOrderLine;
        ShowBy := ShowBy::Production;
    end;

    [Scope('Personalization')]
    procedure InitDate(NewDemandDate: Date)
    begin
        DemandDate := NewDemandDate;
    end;

    local procedure RefreshPage()
    var
        CalcBOMTree: Codeunit "Calculate BOM Tree";
    begin
        Item.SetRange("Date Filter",0D,DemandDate);
        Item.SetFilter("Location Filter",LocationFilter);
        Item.SetFilter("Variant Filter",VariantFilter);
        Item.SetFilter("No.",ItemFilter);
        CalcBOMTree.SetItemFilter(Item);

        CalcBOMTree.SetShowTotalAvailability(ShowTotalAvailability);
        case ShowBy of
          ShowBy::Item:
            begin
              Item.FindFirst;
              if not Item.HasBOM then
                Error(Text000);
              CalcBOMTree.GenerateTreeForItems(Item,Rec,1);
            end;
          ShowBy::Production:
            begin
              ProdOrderLine."Due Date" := DemandDate;
              CalcBOMTree.GenerateTreeForProdLine(ProdOrderLine,Rec,1);
            end;
          ShowBy::Assembly:
            begin
              AsmHeader."Due Date" := DemandDate;
              CalcBOMTree.GenerateTreeForAsm(AsmHeader,Rec,1);
            end;
        end;

        CurrPage.Update(false);
        IsCalculated := true;
    end;

    [Scope('Personalization')]
    procedure GetSelectedDate(): Date
    begin
        exit(DemandDate);
    end;

    local procedure ItemAvail(AvailType: Option)
    var
        Item: Record Item;
    begin
        TestField(Type,Type::Item);

        Item.Get("No.");
        Item.SetFilter("No.","No.");
        Item.SetRange("Date Filter",0D,"Needed by Date");
        Item.SetFilter("Location Filter",LocationFilter);
        Item.SetFilter("Variant Filter","Variant Code");
        if ShowBy <> ShowBy::Item then
          Item.SetFilter("Location Filter","Location Code");
        if Indentation = 0 then
          Item.SetFilter("Variant Filter",VariantFilter);

        ItemAvailFormsMgt.ShowItemAvailFromItem(Item,AvailType);
    end;

    local procedure ShowAbleToMakeTimeline()
    var
        Item: Record Item;
        ItemAbleToMakeTimeline: Report "Item - Able to Make (Timeline)";
    begin
        TestField(Type,Type::Item);

        Item.Get("No.");
        Item.SetFilter("No.","No.");

        with ItemAbleToMakeTimeline do begin
          if Indentation = 0 then begin
            case ShowBy of
              ShowBy::Item:
                begin
                  Item.SetFilter("Location Filter",LocationFilter);
                  Item.SetFilter("Variant Filter",VariantFilter);
                end;
              ShowBy::Assembly:
                InitAsmOrder(AsmHeader);
              ShowBy::Production:
                InitProdOrder(ProdOrderLine);
            end;
          end else begin
            Item.SetFilter("Location Filter",LocationFilter);
            Item.SetFilter("Variant Filter",VariantFilter);
          end;

          SetTableView(Item);
          Initialize("Needed by Date",0,7,true);
          Run;
        end;
    end;

    local procedure ShowWarnings()
    var
        TempBOMWarningLog: Record "BOM Warning Log" temporary;
    begin
        if IsLineOk(true,TempBOMWarningLog) then
          Message(Text001)
        else
          PAGE.RunModal(PAGE::"BOM Warning Log",TempBOMWarningLog);
    end;

    local procedure ShowWarningsForAllLines()
    var
        TempBOMWarningLog: Record "BOM Warning Log" temporary;
    begin
        if AreAllLinesOk(TempBOMWarningLog) then
          Message(Text001)
        else
          PAGE.RunModal(PAGE::"BOM Warning Log",TempBOMWarningLog);
    end;
}

