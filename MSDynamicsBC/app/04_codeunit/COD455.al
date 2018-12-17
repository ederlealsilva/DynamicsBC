codeunit 455 "Job Queue User Handler"
{
    // version NAVW113.00


    trigger OnRun()
    begin
        RescheduleJobQueueEntries;
    end;

    local procedure RescheduleJobQueueEntries()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetFilter(
          Status,'<>%1&<>%2&<>%3',
          JobQueueEntry.Status::"On Hold",JobQueueEntry.Status::Finished,JobQueueEntry.Status::"On Hold with Inactivity Timeout");
        JobQueueEntry.SetRange("Recurring Job",true);
        if JobQueueEntry.FindSet(true) then
          repeat
            if JobShouldBeRescheduled(JobQueueEntry) then
              JobQueueEntry.Restart;
          until JobQueueEntry.Next = 0;

        JobQueueEntry.FilterInactiveOnHoldEntries;
        if JobQueueEntry.FindSet(true) then
          repeat
            if JobQueueEntry.DoesJobNeedToBeRun then
              JobQueueEntry.Restart;
          until JobQueueEntry.Next = 0;
    end;

    local procedure JobShouldBeRescheduled(JobQueueEntry: Record "Job Queue Entry"): Boolean
    var
        User: Record User;
    begin
        if JobQueueEntry."User ID" = UserId then begin
          JobQueueEntry.CalcFields(Scheduled);
          exit(not JobQueueEntry.Scheduled);
        end;
        User.SetRange("User Name",JobQueueEntry."User ID");
        exit(User.IsEmpty);
    end;

    [EventSubscriber(ObjectType::Codeunit, 40, 'OnAfterCompanyOpen', '', true, true)]
    local procedure RescheduleJobQueueEntriesOnCompanyOpen()
    var
        JobQueueEntry: Record "Job Queue Entry";
        User: Record User;
    begin
        if not GuiAllowed then
          exit;
        if not (JobQueueEntry.WritePermission and JobQueueEntry.ReadPermission) then
          exit;
        if not TASKSCHEDULER.CanCreateTask then
          exit;
        if not User.Get(UserSecurityId) then
          exit;
        if User."License Type" = User."License Type"::"Limited User" then
          exit;

        TASKSCHEDULER.CreateTask(CODEUNIT::"Job Queue User Handler",0,true,CompanyName,CurrentDateTime + 15000); // Add 15s
    end;
}

