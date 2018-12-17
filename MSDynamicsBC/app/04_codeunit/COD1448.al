codeunit 1448 "Headline RC Serv. Dispatcher"
{
    // version NAVW113.00


    trigger OnRun()
    var
        HeadlineRCServDispatcher: Record "Headline RC Serv. Dispatcher";
    begin
        HeadlineRCServDispatcher.Get;
        WorkDate := HeadlineRCServDispatcher."Workdate for computations";
        OnComputeHeadlines;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnComputeHeadlines()
    begin
    end;
}

