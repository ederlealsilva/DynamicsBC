codeunit 1443 "Headline RC Project Manager"
{
    // version NAVW113.00


    trigger OnRun()
    var
        HeadlineRCProjectManager: Record "Headline RC Project Manager";
    begin
        HeadlineRCProjectManager.Get;
        WorkDate := HeadlineRCProjectManager."Workdate for computations";
        OnComputeHeadlines;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnComputeHeadlines()
    begin
    end;
}

