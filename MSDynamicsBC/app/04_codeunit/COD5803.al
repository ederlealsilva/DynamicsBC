codeunit 5803 "Show Avg. Calc. - Item"
{
    // version NAVW111.00

    TableNo = Item;

    trigger OnRun()
    var
        ValueEntry: Record "Value Entry";
    begin
        with ValueEntry do begin
          SetCurrentKey("Item No.","Valuation Date","Location Code","Variant Code");
          SetRange("Item No.",Rec."No.");
          SetFilter("Valuation Date",Rec.GetFilter("Date Filter"));
          SetFilter("Location Code",Rec.GetFilter("Location Filter"));
          SetFilter("Variant Code",Rec.GetFilter("Variant Filter"));
        end;
        PAGE.RunModal(PAGE::"Value Entries",ValueEntry,ValueEntry."Cost Amount (Actual)");
    end;

    [Scope('Personalization')]
    procedure DrillDownAvgCostAdjmtPoint(var Item: Record Item)
    var
        AvgCostCalcOverview: Page "Average Cost Calc. Overview";
    begin
        AvgCostCalcOverview.SetItem(Item);
        AvgCostCalcOverview.RunModal;
    end;
}

