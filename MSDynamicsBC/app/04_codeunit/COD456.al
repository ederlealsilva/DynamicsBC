codeunit 456 "Job Queue Management"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    [Scope('Personalization')]
    procedure CreateJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry")
    var
        EarliestStartDateTime: DateTime;
        ReportOutputType: Option;
        ObjectTypeToRun: Option;
        ObjectIdToRun: Integer;
        NoOfMinutesBetweenRuns: Integer;
        RecurringJob: Boolean;
    begin
        NoOfMinutesBetweenRuns := JobQueueEntry."No. of Minutes between Runs";
        EarliestStartDateTime := JobQueueEntry."Earliest Start Date/Time";
        ReportOutputType := JobQueueEntry."Report Output Type";
        ObjectTypeToRun := JobQueueEntry."Object Type to Run";
        ObjectIdToRun := JobQueueEntry."Object ID to Run";

        with JobQueueEntry do begin
          SetRange("Object Type to Run",ObjectTypeToRun);
          SetRange("Object ID to Run",ObjectIdToRun);
          if NoOfMinutesBetweenRuns <> 0 then
            RecurringJob := true
          else
            RecurringJob := false;
          SetRange("Recurring Job",RecurringJob);
          if not IsEmpty then
            exit;

          Init;
          Validate("Object Type to Run",ObjectTypeToRun);
          Validate("Object ID to Run",ObjectIdToRun);
          "Earliest Start Date/Time" := CurrentDateTime;
          if NoOfMinutesBetweenRuns <> 0 then begin
            Validate("Run on Mondays",true);
            Validate("Run on Tuesdays",true);
            Validate("Run on Wednesdays",true);
            Validate("Run on Thursdays",true);
            Validate("Run on Fridays",true);
            Validate("Run on Saturdays",true);
            Validate("Run on Sundays",true);
            Validate("Recurring Job",RecurringJob);
            "No. of Minutes between Runs" := NoOfMinutesBetweenRuns;
          end;
          "Maximum No. of Attempts to Run" := 3;
          Priority := 1000;
          "Notify On Success" := true;
          Status := Status::"On Hold";
          "Earliest Start Date/Time" := EarliestStartDateTime;
          "Report Output Type" := ReportOutputType;
          Insert(true);
        end;
    end;

    [Scope('Personalization')]
    procedure DeleteJobQueueEntries(ObjectTypeToDelete: Option;ObjectIdToDelete: Integer)
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        with JobQueueEntry do begin
          SetRange("Object Type to Run",ObjectTypeToDelete);
          SetRange("Object ID to Run",ObjectIdToDelete);
          if FindSet then
            repeat
              if Status = Status::"In Process" then begin
                // Non-recurring jobs will be auto-deleted after execution has completed.
                "Recurring Job" := false;
                Modify;
              end else
                Delete;
            until Next = 0;
        end;
    end;

    [Scope('Personalization')]
    procedure StartInactiveJobQueueEntries(ObjectTypeToStart: Option;ObjectIdToStart: Integer)
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        with JobQueueEntry do begin
          SetRange("Object Type to Run",ObjectTypeToStart);
          SetRange("Object ID to Run",ObjectIdToStart);
          SetRange(Status,Status::"On Hold");
          if FindSet then
            repeat
              SetStatus(Status::Ready);
            until Next = 0;
        end;
    end;

    [Scope('Personalization')]
    procedure SetJobQueueEntriesOnHold(ObjectTypeToSetOnHold: Option;ObjectIdToSetOnHold: Integer)
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        with JobQueueEntry do begin
          SetRange("Object Type to Run",ObjectTypeToSetOnHold);
          SetRange("Object ID to Run",ObjectIdToSetOnHold);
          if FindSet then
            repeat
              SetStatus(Status::"On Hold");
            until Next = 0;
        end;
    end;

    [Scope('Personalization')]
    procedure SetStatusToOnHoldIfInstanceInactiveFor(PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period";NoOfPeriods: Integer;ObjectTypeToSetOnHold: Option;ObjectIdToSetOnHold: Integer): Boolean
    var
        LogInManagement: Codeunit LogInManagement;
    begin
        if not LogInManagement.AnyUserLoginExistsWithinPeriod(PeriodType,NoOfPeriods) then begin
          SetJobQueueEntriesOnHold(ObjectTypeToSetOnHold,ObjectIdToSetOnHold);
          exit(true);
        end;
        exit(false);
    end;
}

