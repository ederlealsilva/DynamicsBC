codeunit 8815 "Custom Layout - Purchase Order"
{
    // version NAVW110.0


    trigger OnRun()
    var
        ReportSelections: Record "Report Selections";
    begin
        ReportSelections.PrintForUsage(ReportSelections.Usage::"P.Order");
    end;
}

