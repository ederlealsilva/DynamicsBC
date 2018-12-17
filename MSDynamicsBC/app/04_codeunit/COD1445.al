codeunit 1445 "Headline RC Administrator"
{
    // version NAVW113.00


    trigger OnRun()
    var
        HeadlineRCAdministrator: Record "Headline RC Administrator";
    begin
        HeadlineRCAdministrator.Get;
        WorkDate := HeadlineRCAdministrator."Workdate for computations";
        OnComputeHeadlines;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnComputeHeadlines()
    begin
    end;
}

