codeunit 1442 "Headline RC Accountant"
{
    // version NAVW113.00


    trigger OnRun()
    var
        HeadlineRCAccountant: Record "Headline RC Accountant";
    begin
        HeadlineRCAccountant.Get;
        WorkDate := HeadlineRCAccountant."Workdate for computations";
        OnComputeHeadlines;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnComputeHeadlines()
    begin
    end;
}

