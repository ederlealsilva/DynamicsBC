codeunit 842 "Cash Flow Forecast Update"
{
    // version NAVW113.00


    trigger OnRun()
    var
        CashFlowSetup: Record "Cash Flow Setup";
        CashFlowWorksheetLine: Record "Cash Flow Worksheet Line";
        CashFlowForecast: Record "Cash Flow Forecast";
        CashFlowManagement: Codeunit "Cash Flow Management";
        OriginalWorkDate: Date;
    begin
        if (not CashFlowForecast.WritePermission) or
           (not CashFlowWorksheetLine.WritePermission)
        then
          exit;

        RemoveScheduledTaskIfUserInactive;

        OriginalWorkDate := WorkDate;
        WorkDate := LogInManagement.GetDefaultWorkDate;
        if CashFlowSetup.Get then
          CashFlowManagement.UpdateCashFlowForecast(CashFlowSetup."Cortana Intelligence Enabled");
        WorkDate := OriginalWorkDate;
    end;

    var
        LogInManagement: Codeunit LogInManagement;

    local procedure RemoveScheduledTaskIfUserInactive()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueManagement: Codeunit "Job Queue Management";
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period";
    begin
        if not LogInManagement.AnyUserLoginExistsWithinPeriod(PeriodType::Week,2) then
          JobQueueManagement.DeleteJobQueueEntries(JobQueueEntry."Object Type to Run"::Codeunit,CODEUNIT::"Cash Flow Forecast Update");
    end;
}

