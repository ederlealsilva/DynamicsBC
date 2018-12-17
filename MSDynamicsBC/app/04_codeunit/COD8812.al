codeunit 8812 "Custom Layout - Sales Order"
{
    // version NAVW110.0


    trigger OnRun()
    var
        ReportSelections: Record "Report Selections";
    begin
        ReportSelections.PrintForUsage(ReportSelections.Usage::"S.Order");
    end;
}

