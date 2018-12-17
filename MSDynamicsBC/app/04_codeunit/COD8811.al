codeunit 8811 "Custom Layout - Sales Quote"
{
    // version NAVW110.0


    trigger OnRun()
    var
        ReportSelections: Record "Report Selections";
    begin
        ReportSelections.PrintForUsage(ReportSelections.Usage::"S.Quote");
    end;
}

