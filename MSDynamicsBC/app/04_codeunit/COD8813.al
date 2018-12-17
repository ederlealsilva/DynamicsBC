codeunit 8813 "Custom Layout - Sales Invoice"
{
    // version NAVW110.0


    trigger OnRun()
    var
        ReportSelections: Record "Report Selections";
    begin
        ReportSelections.PrintForUsage(ReportSelections.Usage::"S.Invoice");
    end;
}

