codeunit 8814 "Custom Layout - Sales CrMemo"
{
    // version NAVW110.0


    trigger OnRun()
    var
        ReportSelections: Record "Report Selections";
    begin
        ReportSelections.PrintForUsage(ReportSelections.Usage::"S.Cr.Memo");
    end;
}

