codeunit 448 "Job Queue Dispatcher"
{
    // version NAVW113.00

    Permissions = TableData "Job Queue Entry"=rimd;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        SelectLatestVersion;
        Get(ID);
        if not IsReadyToStart then
          exit;

        if IsExpired(CurrentDateTime) then
          DeleteTask
        else
          if WaitForOthersWithSameCategory(Rec) then
            Reschedule(Rec)
          else
            HandleRequest(Rec);
        Commit;
    end;

    var
        TypeHelper: Codeunit "Type Helper";

    local procedure HandleRequest(var JobQueueEntry: Record "Job Queue Entry")
    var
        JobQueueLogEntry: Record "Job Queue Log Entry";
        WasSuccess: Boolean;
        PrevStatus: Option;
    begin
        JobQueueEntry.RefreshLocked;
        if not JobQueueEntry.IsReadyToStart then
          exit;

        OnBeforeHandleRequest(JobQueueEntry);

        with JobQueueEntry do begin
          if Status in [Status::Ready,Status::"On Hold with Inactivity Timeout"] then begin
            Status := Status::"In Process";
            "User Session Started" := CurrentDateTime;
            Modify;
          end;
          InsertLogEntry(JobQueueLogEntry);

          // Codeunit.Run is limited during write transactions because one or more tables will be locked.
          // To avoid NavCSideException we have either to add the COMMIT before the call or do not use a returned value.
          Commit;
          WasSuccess := CODEUNIT.Run(CODEUNIT::"Job Queue Start Codeunit",JobQueueEntry);
          PrevStatus := Status;

          // user may have deleted it in the meantime
          if DoesExistLocked then
            SetResult(WasSuccess,PrevStatus)
          else
            SetResultDeletedEntry;
          Commit;
          FinalizeLogEntry(JobQueueLogEntry);

          if DoesExistLocked then
            FinalizeRun;
        end;

        OnAfterHandleRequest(JobQueueEntry,WasSuccess);
    end;

    local procedure WaitForOthersWithSameCategory(var CurrJobQueueEntry: Record "Job Queue Entry"): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueCategory: Record "Job Queue Category";
    begin
        OnBeforeWaitForOthersWithSameCategory(CurrJobQueueEntry,JobQueueEntry);

        if CurrJobQueueEntry."Job Queue Category Code" = '' then
          exit(false);

        // Use the Job Queue Category as a semaphore so only one checks at the time.
        JobQueueCategory.LockTable;
        if not JobQueueCategory.Get(CurrJobQueueEntry."Job Queue Category Code") then
          exit(false);

        with JobQueueEntry do begin
          SetFilter(ID,'<>%1',CurrJobQueueEntry.ID);
          SetRange("Job Queue Category Code",CurrJobQueueEntry."Job Queue Category Code");
          SetRange(Status,Status::"In Process");
          exit(not IsEmpty);
        end;
    end;

    local procedure Reschedule(var JobQueueEntry: Record "Job Queue Entry")
    begin
        with JobQueueEntry do begin
          RefreshLocked;
          Randomize;
          Clear("System Task ID"); // to avoid canceling this task, which has already been executed
          "Earliest Start Date/Time" := CurrentDateTime + 2000 + Random(5000);
          CODEUNIT.Run(CODEUNIT::"Job Queue - Enqueue",JobQueueEntry);
        end;
    end;

    [Scope('Personalization')]
    procedure CalcNextRunTimeForRecurringJob(var JobQueueEntry: Record "Job Queue Entry";StartingDateTime: DateTime): DateTime
    var
        NewRunDateTime: DateTime;
    begin
        if JobQueueEntry."No. of Minutes between Runs" > 0 then
          NewRunDateTime := TypeHelper.AddMinutesToDateTime(StartingDateTime,JobQueueEntry."No. of Minutes between Runs")
        else begin
          if JobQueueEntry."Earliest Start Date/Time" <> 0DT then
            StartingDateTime := JobQueueEntry."Earliest Start Date/Time";
          NewRunDateTime := CreateDateTime(DT2Date(StartingDateTime) + 1,0T);
        end;

        exit(CalcRunTimeForRecurringJob(JobQueueEntry,NewRunDateTime));
    end;

    [Scope('Personalization')]
    procedure CalcNextRunTimeHoldDuetoInactivityJob(var JobQueueEntry: Record "Job Queue Entry";StartingDateTime: DateTime): DateTime
    var
        NewRunDateTime: DateTime;
    begin
        NewRunDateTime := TypeHelper.AddMinutesToDateTime(StartingDateTime,JobQueueEntry."Inactivity Timeout Period");
        exit(CalcRunTimeForRecurringJob(JobQueueEntry,NewRunDateTime));
    end;

    [Scope('Personalization')]
    procedure CalcInitialRunTime(var JobQueueEntry: Record "Job Queue Entry";StartingDateTime: DateTime): DateTime
    var
        EarliestPossibleRunTime: DateTime;
    begin
        if (JobQueueEntry."Earliest Start Date/Time" <> 0DT) and (JobQueueEntry."Earliest Start Date/Time" > StartingDateTime) then
          EarliestPossibleRunTime := JobQueueEntry."Earliest Start Date/Time"
        else
          EarliestPossibleRunTime := StartingDateTime;

        if JobQueueEntry."Recurring Job" then
          exit(CalcRunTimeForRecurringJob(JobQueueEntry,EarliestPossibleRunTime));

        exit(EarliestPossibleRunTime);
    end;

    local procedure CalcRunTimeForRecurringJob(var JobQueueEntry: Record "Job Queue Entry";StartingDateTime: DateTime): DateTime
    var
        NewRunDateTime: DateTime;
        RunOnDate: array [7] of Boolean;
        StartingWeekDay: Integer;
        NoOfExtraDays: Integer;
        NoOfDays: Integer;
        Found: Boolean;
    begin
        with JobQueueEntry do begin
          TestField("Recurring Job");
          RunOnDate[1] := "Run on Mondays";
          RunOnDate[2] := "Run on Tuesdays";
          RunOnDate[3] := "Run on Wednesdays";
          RunOnDate[4] := "Run on Thursdays";
          RunOnDate[5] := "Run on Fridays";
          RunOnDate[6] := "Run on Saturdays";
          RunOnDate[7] := "Run on Sundays";

          NewRunDateTime := StartingDateTime;
          NoOfDays := 0;
          if ("Ending Time" <> 0T) and (NewRunDateTime > GetEndingDateTime(NewRunDateTime)) then begin
            NewRunDateTime := GetStartingDateTime(NewRunDateTime);
            NoOfDays := NoOfDays + 1;
          end;

          StartingWeekDay := Date2DWY(DT2Date(StartingDateTime),1);
          Found := RunOnDate[(StartingWeekDay - 1 + NoOfDays) mod 7 + 1];
          while not Found and (NoOfExtraDays < 7) do begin
            NoOfExtraDays := NoOfExtraDays + 1;
            NoOfDays := NoOfDays + 1;
            Found := RunOnDate[(StartingWeekDay - 1 + NoOfDays) mod 7 + 1];
          end;

          if ("Starting Time" <> 0T) and (NewRunDateTime < GetStartingDateTime(NewRunDateTime)) then
            NewRunDateTime := GetStartingDateTime(NewRunDateTime);

          if (NoOfDays > 0) and (NewRunDateTime > GetStartingDateTime(NewRunDateTime)) then
            NewRunDateTime := GetStartingDateTime(NewRunDateTime);

          if ("Starting Time" = 0T) and (NoOfExtraDays > 0) and ("No. of Minutes between Runs" <> 0) then
            NewRunDateTime := CreateDateTime(DT2Date(NewRunDateTime),0T);

          if Found then
            NewRunDateTime := CreateDateTime(DT2Date(NewRunDateTime) + NoOfDays,DT2Time(NewRunDateTime));
        end;
        exit(NewRunDateTime);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterHandleRequest(var JobQueueEntry: Record "Job Queue Entry";WasSuccess: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeHandleRequest(var JobQueueEntry: Record "Job Queue Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeWaitForOthersWithSameCategory(var CurrJobQueueEntry: Record "Job Queue Entry";var JobQueueEntry: Record "Job Queue Entry")
    begin
    end;
}

