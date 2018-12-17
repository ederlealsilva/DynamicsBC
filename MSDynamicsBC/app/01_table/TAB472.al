table 472 "Job Queue Entry"
{
    // version NAVW113.00

    Caption = 'Job Queue Entry';
    DataCaptionFields = "Object Type to Run","Object ID to Run","Object Caption to Run";
    DrillDownPageID = "Job Queue Entries";
    LookupPageID = "Job Queue Entries";
    Permissions = TableData "Job Queue Entry"=rimd,
                  TableData "Job Queue Log Entry"=rim;
    ReplicateData = false;

    fields
    {
        field(1;ID;Guid)
        {
            Caption = 'ID';
        }
        field(2;"User ID";Text[65])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(3;XML;BLOB)
        {
            Caption = 'XML';
        }
        field(4;"Last Ready State";DateTime)
        {
            Caption = 'Last Ready State';
            Editable = false;
        }
        field(5;"Expiration Date/Time";DateTime)
        {
            Caption = 'Expiration Date/Time';

            trigger OnLookup()
            begin
                Validate("Expiration Date/Time",LookupDateTime("Expiration Date/Time","Earliest Start Date/Time",0DT));
            end;

            trigger OnValidate()
            begin
                CheckStartAndExpirationDateTime;
            end;
        }
        field(6;"Earliest Start Date/Time";DateTime)
        {
            Caption = 'Earliest Start Date/Time';

            trigger OnLookup()
            begin
                Validate("Earliest Start Date/Time",LookupDateTime("Earliest Start Date/Time",0DT,"Expiration Date/Time"));
            end;

            trigger OnValidate()
            begin
                CheckStartAndExpirationDateTime;
                if "Earliest Start Date/Time" <> xRec."Earliest Start Date/Time" then
                  Reschedule;
            end;
        }
        field(7;"Object Type to Run";Option)
        {
            Caption = 'Object Type to Run';
            InitValue = "Report";
            OptionCaption = ',,,Report,,Codeunit';
            OptionMembers = ,,,"Report",,"Codeunit";

            trigger OnValidate()
            begin
                if "Object Type to Run" <> xRec."Object Type to Run" then
                  Validate("Object ID to Run",0);
            end;
        }
        field(8;"Object ID to Run";Integer)
        {
            Caption = 'Object ID to Run';
            TableRelation = AllObjWithCaption."Object ID" WHERE ("Object Type"=FIELD("Object Type to Run"));

            trigger OnLookup()
            var
                NewObjectID: Integer;
            begin
                if LookupObjectID(NewObjectID) then
                  Validate("Object ID to Run",NewObjectID);
            end;

            trigger OnValidate()
            var
                "Object": Record "Object";
            begin
                if "Object ID to Run" <> xRec."Object ID to Run" then begin
                  Clear(XML);
                  Clear(Description);
                  Clear("Parameter String");
                  Clear("Report Request Page Options");
                end;
                if "Object ID to Run" = 0 then
                  exit;
                if Object.Get("Object Type to Run",'',"Object ID to Run") then
                  Object.TestField(Compiled);

                CalcFields("Object Caption to Run");
                if Description = '' then
                  Description := GetDefaultDescription;

                if "Object Type to Run" <> "Object Type to Run"::Report then
                  exit;
                if REPORT.DefaultLayout("Object ID to Run") = DEFAULTLAYOUT::None then // Processing-only
                  "Report Output Type" := "Report Output Type"::"None (Processing only)"
                else begin
                  "Report Output Type" := "Report Output Type"::PDF;
                  if REPORT.DefaultLayout("Object ID to Run") = DEFAULTLAYOUT::Word then
                    "Report Output Type" := "Report Output Type"::Word;
                end;
            end;
        }
        field(9;"Object Caption to Run";Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE ("Object Type"=FIELD("Object Type to Run"),
                                                                           "Object ID"=FIELD("Object ID to Run")));
            Caption = 'Object Caption to Run';
            Editable = false;
            FieldClass = FlowField;
        }
        field(10;"Report Output Type";Option)
        {
            Caption = 'Report Output Type';
            OptionCaption = 'PDF,Word,Excel,Print,None (Processing only)';
            OptionMembers = PDF,Word,Excel,Print,"None (Processing only)";

            trigger OnValidate()
            var
                ReportLayoutSelection: Record "Report Layout Selection";
                InitServerPrinterTable: Codeunit "Init. Server Printer Table";
                PermissionManager: Codeunit "Permission Manager";
            begin
                TestField("Object Type to Run","Object Type to Run"::Report);

                if REPORT.DefaultLayout("Object ID to Run") = DEFAULTLAYOUT::None then // Processing-only
                  TestField("Report Output Type","Report Output Type"::"None (Processing only)")
                else begin
                  if "Report Output Type" = "Report Output Type"::"None (Processing only)" then
                    FieldError("Report Output Type");
                  if ReportLayoutSelection.HasCustomLayout("Object ID to Run") = 2 then // Word layout
                    if not ("Report Output Type" in ["Report Output Type"::Print,"Report Output Type"::Word]) then
                      FieldError("Report Output Type");
                end;
                if "Report Output Type" = "Report Output Type"::Print then begin
                  if PermissionManager.SoftwareAsAService then begin
                    "Report Output Type" := "Report Output Type"::PDF;
                    Message(NoPrintOnSaaSMsg);
                  end else
                    "Printer Name" := InitServerPrinterTable.FindClosestMatchToClientDefaultPrinter("Object ID to Run");
                end else
                  "Printer Name" := '';
            end;
        }
        field(11;"Maximum No. of Attempts to Run";Integer)
        {
            Caption = 'Maximum No. of Attempts to Run';
        }
        field(12;"No. of Attempts to Run";Integer)
        {
            Caption = 'No. of Attempts to Run';
            Editable = false;
        }
        field(13;Status;Option)
        {
            Caption = 'Status';
            Editable = false;
            OptionCaption = 'Ready,In Process,Error,On Hold,Finished,On Hold with Inactivity Timeout';
            OptionMembers = Ready,"In Process",Error,"On Hold",Finished,"On Hold with Inactivity Timeout";
        }
        field(14;Priority;Integer)
        {
            Caption = 'Priority';
            InitValue = 1000;
        }
        field(15;"Record ID to Process";RecordID)
        {
            Caption = 'Record ID to Process';
            DataClassification = SystemMetadata;
        }
        field(16;"Parameter String";Text[250])
        {
            Caption = 'Parameter String';
        }
        field(17;"Recurring Job";Boolean)
        {
            Caption = 'Recurring Job';
        }
        field(18;"No. of Minutes between Runs";Integer)
        {
            Caption = 'No. of Minutes between Runs';

            trigger OnValidate()
            begin
                SetRecurringField;
            end;
        }
        field(19;"Run on Mondays";Boolean)
        {
            Caption = 'Run on Mondays';

            trigger OnValidate()
            begin
                SetRecurringField;
            end;
        }
        field(20;"Run on Tuesdays";Boolean)
        {
            Caption = 'Run on Tuesdays';

            trigger OnValidate()
            begin
                SetRecurringField;
            end;
        }
        field(21;"Run on Wednesdays";Boolean)
        {
            Caption = 'Run on Wednesdays';

            trigger OnValidate()
            begin
                SetRecurringField;
            end;
        }
        field(22;"Run on Thursdays";Boolean)
        {
            Caption = 'Run on Thursdays';

            trigger OnValidate()
            begin
                SetRecurringField;
            end;
        }
        field(23;"Run on Fridays";Boolean)
        {
            Caption = 'Run on Fridays';

            trigger OnValidate()
            begin
                SetRecurringField;
            end;
        }
        field(24;"Run on Saturdays";Boolean)
        {
            Caption = 'Run on Saturdays';

            trigger OnValidate()
            begin
                SetRecurringField;
            end;
        }
        field(25;"Run on Sundays";Boolean)
        {
            Caption = 'Run on Sundays';

            trigger OnValidate()
            begin
                SetRecurringField;
            end;
        }
        field(26;"Starting Time";Time)
        {
            Caption = 'Starting Time';

            trigger OnValidate()
            begin
                TestField("Recurring Job");
                if "Starting Time" = 0T then
                  "Reference Starting Time" := 0DT
                else
                  "Reference Starting Time" := CreateDateTime(DMY2Date(1,1,2000),"Starting Time");
            end;
        }
        field(27;"Ending Time";Time)
        {
            Caption = 'Ending Time';

            trigger OnValidate()
            begin
                TestField("Recurring Job");
            end;
        }
        field(28;"Reference Starting Time";DateTime)
        {
            Caption = 'Reference Starting Time';
            Editable = false;

            trigger OnValidate()
            begin
                "Starting Time" := DT2Time("Reference Starting Time");
            end;
        }
        field(30;Description;Text[250])
        {
            Caption = 'Description';
        }
        field(31;"Run in User Session";Boolean)
        {
            Caption = 'Run in User Session';
            Editable = false;
        }
        field(32;"User Session ID";Integer)
        {
            Caption = 'User Session ID';
            DataClassification = EndUserPseudonymousIdentifiers;
        }
        field(33;"Job Queue Category Code";Code[10])
        {
            Caption = 'Job Queue Category Code';
            TableRelation = "Job Queue Category";
        }
        field(34;"Error Message";Text[250])
        {
            Caption = 'Error Message';
        }
        field(35;"Error Message 2";Text[250])
        {
            Caption = 'Error Message 2';
        }
        field(36;"Error Message 3";Text[250])
        {
            Caption = 'Error Message 3';
        }
        field(37;"Error Message 4";Text[250])
        {
            Caption = 'Error Message 4';
        }
        field(40;"User Service Instance ID";Integer)
        {
            Caption = 'User Service Instance ID';
            DataClassification = EndUserPseudonymousIdentifiers;
        }
        field(41;"User Session Started";DateTime)
        {
            Caption = 'User Session Started';
            Editable = false;
        }
        field(42;"Timeout (sec.)";Integer)
        {
            Caption = 'Timeout (sec.)';
            MinValue = 0;
        }
        field(43;"Notify On Success";Boolean)
        {
            Caption = 'Notify On Success';
        }
        field(44;"User Language ID";Integer)
        {
            Caption = 'User Language ID';
        }
        field(45;"Printer Name";Text[250])
        {
            Caption = 'Printer Name';

            trigger OnLookup()
            var
                Printer: Record Printer;
                ServerPrinters: Page "Server Printers";
            begin
                ServerPrinters.SetSelectedPrinterName("Printer Name");
                if ServerPrinters.RunModal = ACTION::OK then begin
                  ServerPrinters.GetRecord(Printer);
                  "Printer Name" := Printer.ID;
                end;
            end;

            trigger OnValidate()
            var
                InitServerPrinterTable: Codeunit "Init. Server Printer Table";
            begin
                TestField("Report Output Type","Report Output Type"::Print);
                if "Printer Name" = '' then
                  exit;
                InitServerPrinterTable.ValidatePrinterName("Printer Name");
            end;
        }
        field(46;"Report Request Page Options";Boolean)
        {
            Caption = 'Report Request Page Options';

            trigger OnValidate()
            begin
                if "Report Request Page Options" then
                  RunReportRequestPage
                else begin
                  Clear(XML);
                  Message(RequestPagesOptionsDeletedMsg);
                  "User ID" := UserId;
                end;
            end;
        }
        field(47;"Rerun Delay (sec.)";Integer)
        {
            Caption = 'Rerun Delay (sec.)';
            MaxValue = 3600;
            MinValue = 0;
        }
        field(48;"System Task ID";Guid)
        {
            Caption = 'System Task ID';
        }
        field(49;Scheduled;Boolean)
        {
            CalcFormula = Exist("Scheduled Task" WHERE (ID=FIELD("System Task ID")));
            Caption = 'Scheduled';
            FieldClass = FlowField;
        }
        field(50;"Manual Recurrence";Boolean)
        {
            Caption = 'Manual Recurrence';
        }
        field(51;"On Hold Due to Inactivity";Boolean)
        {
            Caption = 'On Hold Due to Inactivity';
            ObsoleteReason = 'Functionality moved into new job queue status';
            ObsoleteState = Pending;
        }
        field(52;"Inactivity Timeout Period";Integer)
        {
            Caption = 'Inactivity Timeout Period';
        }
    }

    keys
    {
        key(Key1;ID)
        {
        }
        key(Key2;"Job Queue Category Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        if Status = Status::"In Process" then
          Error(CannotDeleteEntryErr,Status);
        CancelTask;
    end;

    trigger OnInsert()
    begin
        if IsNullGuid(ID) then
          ID := CreateGuid;
        SetDefaultValues(true);
    end;

    trigger OnModify()
    var
        RunParametersChanged: Boolean;
    begin
        RunParametersChanged := AreRunParametersChanged;
        if RunParametersChanged then
          Reschedule;
        SetDefaultValues(RunParametersChanged);
    end;

    var
        NoErrMsg: Label 'There is no error message.';
        CannotDeleteEntryErr: Label 'You cannot delete an entry that has status %1.', Comment='%1 is a status value, such as Success or Error.';
        DeletedEntryErr: Label 'The job queue entry has been deleted.';
        ScheduledForPostingMsg: Label 'Scheduled for posting on %1 by %2.', Comment='%1=a date, %2 = a user.';
        NoRecordErr: Label 'No record is associated with the job queue entry.';
        RequestPagesOptionsDeletedMsg: Label 'You have cleared the report parameters. Select the check box in the field to show the report request page again.';
        ExpiresBeforeStartErr: Label '%1 must be later than %2.', Comment='%1 = Expiration Date, %2=Start date';
        UserSessionJobsCannotBeRecurringErr: Label 'You cannot set up recurring user session job queue entries.';
        NoPrintOnSaaSMsg: Label 'You cannot select a printer from this online product. Instead, save as PDF, or another format, which you can print later.\\The output type has been set to PDF.';
        LastJobQueueLogEntryNo: Integer;

    [Scope('Personalization')]
    procedure DoesExistLocked(): Boolean
    begin
        LockTable;
        exit(Get(ID));
    end;

    [Scope('Personalization')]
    procedure RefreshLocked()
    begin
        LockTable;
        Get(ID);
    end;

    [Scope('Personalization')]
    procedure IsExpired(AtDateTime: DateTime): Boolean
    begin
        exit((AtDateTime <> 0DT) and ("Expiration Date/Time" <> 0DT) and ("Expiration Date/Time" < AtDateTime));
    end;

    [Scope('Personalization')]
    procedure IsReadyToStart(): Boolean
    begin
        exit(Status in [Status::Ready,Status::"In Process",Status::"On Hold with Inactivity Timeout"]);
    end;

    [Scope('Personalization')]
    procedure GetErrorMessage(): Text
    var
        TextMgt: Codeunit TextManagement;
    begin
        exit(TextMgt.GetRecordErrorMessage("Error Message","Error Message 2","Error Message 3","Error Message 4"));
    end;

    [Scope('Personalization')]
    procedure SetErrorMessage(ErrorText: Text)
    var
        TextMgt: Codeunit TextManagement;
    begin
        TextMgt.SetRecordErrorMessage("Error Message","Error Message 2","Error Message 3","Error Message 4",ErrorText);
    end;

    [Scope('Personalization')]
    procedure ShowErrorMessage()
    var
        e: Text;
    begin
        e := GetErrorMessage;
        if e = '' then
          e := NoErrMsg;
        Message('%1',e);
    end;

    [Scope('Personalization')]
    procedure SetError(ErrorText: Text)
    begin
        RefreshLocked;
        SetErrorMessage(ErrorText);
        ClearServiceValues;
        SetStatusValue(Status::Error);
    end;

    procedure SetResult(IsSuccess: Boolean;PrevStatus: Option)
    begin
        if (Status = Status::"On Hold") or "Manual Recurrence" then
          exit;
        if IsSuccess then
          if "Recurring Job" and (PrevStatus in [Status::"On Hold",Status::"On Hold with Inactivity Timeout"]) then
            Status := PrevStatus
          else
            Status := Status::Finished
        else begin
          Status := Status::Error;
          SetErrorMessage(GetLastErrorText);
        end;
        Modify;
    end;

    [Scope('Personalization')]
    procedure SetResultDeletedEntry()
    begin
        Status := Status::Error;
        SetErrorMessage(DeletedEntryErr);
        Modify;
    end;

    [Scope('Personalization')]
    procedure FinalizeRun()
    begin
        case Status of
          Status::Finished,Status::"On Hold with Inactivity Timeout":
            CleanupAfterExecution;
          Status::Error:
            HandleExecutionError;
        end;

        if (Status = Status::Finished) or ("Maximum No. of Attempts to Run" = "No. of Attempts to Run") then
          UpdateDocumentSentHistory;
    end;

    procedure GetLastLogEntryNo(): Integer
    begin
        exit(LastJobQueueLogEntryNo);
    end;

    [Scope('Personalization')]
    procedure InsertLogEntry(var JobQueueLogEntry: Record "Job Queue Log Entry")
    begin
        JobQueueLogEntry."Entry No." := 0;
        JobQueueLogEntry.Init;
        JobQueueLogEntry.ID := ID;
        JobQueueLogEntry."User ID" := "User ID";
        JobQueueLogEntry."Start Date/Time" := "User Session Started";
        JobQueueLogEntry."Object Type to Run" := "Object Type to Run";
        JobQueueLogEntry."Object ID to Run" := "Object ID to Run";
        JobQueueLogEntry.Description := Description;
        JobQueueLogEntry.Status := JobQueueLogEntry.Status::"In Process";
        JobQueueLogEntry."Processed by User ID" := UserId;
        JobQueueLogEntry."Job Queue Category Code" := "Job Queue Category Code";
        OnBeforeInsertLogEntry(JobQueueLogEntry,Rec);
        JobQueueLogEntry.Insert(true);
        LastJobQueueLogEntryNo := JobQueueLogEntry."Entry No.";
    end;

    [Scope('Personalization')]
    procedure FinalizeLogEntry(JobQueueLogEntry: Record "Job Queue Log Entry")
    begin
        if Status = Status::Error then begin
          JobQueueLogEntry.Status := JobQueueLogEntry.Status::Error;
          JobQueueLogEntry.SetErrorMessage(GetErrorMessage);
          JobQueueLogEntry.SetErrorCallStack(GetLastErrorCallstack);
        end else
          JobQueueLogEntry.Status := JobQueueLogEntry.Status::Success;
        JobQueueLogEntry."End Date/Time" := CurrentDateTime;
        OnBeforeModifyLogEntry(JobQueueLogEntry,Rec);
        JobQueueLogEntry.Modify(true);
    end;

    [Scope('Personalization')]
    procedure SetStatus(NewStatus: Option)
    begin
        if NewStatus = Status then
          exit;
        RefreshLocked;
        ClearServiceValues;
        SetStatusValue(NewStatus);
    end;

    [Scope('Personalization')]
    procedure Cancel()
    begin
        if DoesExistLocked then
          DeleteTask;
    end;

    [Scope('Personalization')]
    procedure DeleteTask()
    begin
        Status := Status::Finished;
        Delete(true);
    end;

    [Scope('Personalization')]
    procedure DeleteTasks()
    begin
        if FindSet then
          repeat
            DeleteTask;
          until Next = 0;
    end;

    [Scope('Personalization')]
    procedure Restart()
    begin
        RefreshLocked;
        ClearServiceValues;
        if (Status = Status::"On Hold with Inactivity Timeout") and ("Inactivity Timeout Period" > 0) then
          "Earliest Start Date/Time" := CurrentDateTime;
        Status := Status::"On Hold";
        SetStatusValue(Status::Ready);
    end;

    local procedure EnqueueTask()
    begin
        CODEUNIT.Run(CODEUNIT::"Job Queue - Enqueue",Rec);
    end;

    [Scope('Personalization')]
    procedure CancelTask()
    var
        ScheduledTask: Record "Scheduled Task";
    begin
        if not IsNullGuid("System Task ID") then begin
          if ScheduledTask.Get("System Task ID") then
            TASKSCHEDULER.CancelTask("System Task ID");
          Clear("System Task ID");
        end;
    end;

    [Scope('Personalization')]
    procedure ScheduleTask(): Guid
    var
        TaskGUID: Guid;
    begin
        OnBeforeScheduleTask(Rec,TaskGUID);
        if not IsNullGuid(TaskGUID) then
          exit(TaskGUID);

        exit(
          TASKSCHEDULER.CreateTask(
            CODEUNIT::"Job Queue Dispatcher",
            CODEUNIT::"Job Queue Error Handler",
            true,CompanyName,"Earliest Start Date/Time",RecordId));
    end;

    local procedure Reschedule()
    begin
        CancelTask;
        if Status in [Status::Ready,Status::"On Hold with Inactivity Timeout"] then begin
          SetDefaultValues(false);
          EnqueueTask;
        end;

        OnAfterReschedule(Rec);
    end;

    [Scope('Personalization')]
    procedure ReuseExistingJobFromID(JobID: Guid;ExecutionDateTime: DateTime): Boolean
    begin
        if Get(JobID) then begin
          if not (Status in [Status::Ready,Status::"In Process"]) then begin
            "Earliest Start Date/Time" := ExecutionDateTime;
            SetStatus(Status::Ready);
          end;
          exit(true);
        end;

        exit(false);
    end;

    [Scope('Personalization')]
    procedure ReuseExistingJobFromCatagory(JobQueueCatagoryCode: Code[10];ExecutionDateTime: DateTime): Boolean
    begin
        SetRange("Job Queue Category Code",JobQueueCatagoryCode);
        if FindFirst then
          exit(ReuseExistingJobFromID(ID,ExecutionDateTime));

        exit(false);
    end;

    local procedure AreRunParametersChanged(): Boolean
    begin
        exit(
          ("User ID" = '') or
          ("Object Type to Run" <> xRec."Object Type to Run") or
          ("Object ID to Run" <> xRec."Object ID to Run") or
          ("Parameter String" <> xRec."Parameter String"));
    end;

    local procedure SetDefaultValues(SetupUserId: Boolean)
    var
        Language: Record Language;
        IdentityManagement: Codeunit "Identity Management";
    begin
        "Last Ready State" := CurrentDateTime;
        if IdentityManagement.IsInvAppId then
          "User Language ID" := Language.GetLanguageID(Language.GetUserLanguage)
        else
          "User Language ID" := GlobalLanguage;
        if SetupUserId then
          "User ID" := UserId;
        "No. of Attempts to Run" := 0;
    end;

    local procedure ClearServiceValues()
    begin
        OnBeforeClearServiceValues(Rec);

        "User Session Started" := 0DT;
        "User Service Instance ID" := 0;
        "User Session ID" := 0;
    end;

    local procedure CleanupAfterExecution()
    var
        JobQueueDispatcher: Codeunit "Job Queue Dispatcher";
    begin
        if "Notify On Success" then
          CODEUNIT.Run(CODEUNIT::"Job Queue - Send Notification",Rec);

        if "Recurring Job" then begin
          ClearServiceValues;
          if Status = Status::"On Hold with Inactivity Timeout" then
            "Earliest Start Date/Time" := JobQueueDispatcher.CalcNextRunTimeHoldDuetoInactivityJob(Rec,CurrentDateTime)
          else
            "Earliest Start Date/Time" := JobQueueDispatcher.CalcNextRunTimeForRecurringJob(Rec,CurrentDateTime);
          EnqueueTask;
        end else
          Delete;
    end;

    local procedure HandleExecutionError()
    begin
        if "Maximum No. of Attempts to Run" > "No. of Attempts to Run" then begin
          "No. of Attempts to Run" += 1;
          "Earliest Start Date/Time" := CurrentDateTime + 1000 * "Rerun Delay (sec.)";
          EnqueueTask;
        end else begin
          SetStatusValue(Status::Error);
          Commit;
          if CODEUNIT.Run(CODEUNIT::"Job Queue - Send Notification",Rec) then;
        end;
    end;

    [Scope('Personalization')]
    procedure GetTimeout(): Integer
    begin
        if "Timeout (sec.)" > 0 then
          exit("Timeout (sec.)");
        exit(1000000000);
    end;

    local procedure SetRecurringField()
    begin
        "Recurring Job" :=
          "Run on Mondays" or
          "Run on Tuesdays" or "Run on Wednesdays" or "Run on Thursdays" or "Run on Fridays" or "Run on Saturdays" or "Run on Sundays";

        if "Recurring Job" and "Run in User Session" then
          Error(UserSessionJobsCannotBeRecurringErr);
    end;

    local procedure SetStatusValue(NewStatus: Option)
    var
        JobQueueDispatcher: Codeunit "Job Queue Dispatcher";
    begin
        OnBeforeSetStatusValue(Rec,xRec,NewStatus);

        if NewStatus = Status then
          exit;
        case NewStatus of
          Status::Ready:
            begin
              SetDefaultValues(false);
              "Earliest Start Date/Time" := JobQueueDispatcher.CalcInitialRunTime(Rec,CurrentDateTime);
              EnqueueTask;
            end;
          Status::"On Hold":
            CancelTask;
          Status::"On Hold with Inactivity Timeout":
            if "Inactivity Timeout Period" > 0 then begin
              SetDefaultValues(false);
              "Earliest Start Date/Time" := JobQueueDispatcher.CalcNextRunTimeHoldDuetoInactivityJob(Rec,CurrentDateTime);
              EnqueueTask;
            end;
        end;
        Status := NewStatus;
        Modify;
    end;

    [Scope('Personalization')]
    procedure ShowStatusMsg(JQID: Guid)
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if JobQueueEntry.Get(JQID) then
          case JobQueueEntry.Status of
            JobQueueEntry.Status::Error:
              Message(JobQueueEntry.GetErrorMessage);
            JobQueueEntry.Status::"In Process":
              Message(Format(JobQueueEntry.Status::"In Process"));
            else
              Message(ScheduledForPostingMsg,JobQueueEntry."User Session Started",JobQueueEntry."User ID");
          end;
    end;

    [Scope('Personalization')]
    procedure LookupRecordToProcess()
    var
        RecRef: RecordRef;
        RecVariant: Variant;
    begin
        if IsNullGuid(ID) then
          exit;
        if Format("Record ID to Process") = '' then
          Error(NoRecordErr);
        RecRef.Get("Record ID to Process");
        RecRef.SetRecFilter;
        RecVariant := RecRef;
        PAGE.Run(0,RecVariant);
    end;

    [Scope('Personalization')]
    procedure LookupObjectID(var NewObjectID: Integer): Boolean
    var
        AllObjWithCaption: Record AllObjWithCaption;
        Objects: Page Objects;
    begin
        if AllObjWithCaption.Get("Object Type to Run","Object ID to Run") then;
        AllObjWithCaption.FilterGroup(2);
        AllObjWithCaption.SetRange("Object Type","Object Type to Run");
        AllObjWithCaption.FilterGroup(0);
        Objects.SetRecord(AllObjWithCaption);
        Objects.SetTableView(AllObjWithCaption);
        Objects.LookupMode := true;
        if Objects.RunModal = ACTION::LookupOK then begin
          Objects.GetRecord(AllObjWithCaption);
          NewObjectID := AllObjWithCaption."Object ID";
          exit(true);
        end;
        exit(false);
    end;

    local procedure LookupDateTime(InitDateTime: DateTime;EarliestDateTime: DateTime;LatestDateTime: DateTime): DateTime
    var
        DateTimeDialog: Page "Date-Time Dialog";
        NewDateTime: DateTime;
    begin
        NewDateTime := InitDateTime;
        if InitDateTime < EarliestDateTime then
          InitDateTime := EarliestDateTime;
        if (LatestDateTime <> 0DT) and (InitDateTime > LatestDateTime) then
          InitDateTime := LatestDateTime;

        DateTimeDialog.SetDateTime(RoundDateTime(InitDateTime,1000));

        if DateTimeDialog.RunModal = ACTION::OK then
          NewDateTime := DateTimeDialog.GetDateTime;
        exit(NewDateTime);
    end;

    local procedure CheckStartAndExpirationDateTime()
    begin
        if IsExpired("Earliest Start Date/Time") then
          Error(ExpiresBeforeStartErr,FieldCaption("Expiration Date/Time"),FieldCaption("Earliest Start Date/Time"));
    end;

    [Scope('Personalization')]
    procedure GetReportParameters(): Text
    var
        InStr: InStream;
        Params: Text;
    begin
        TestField("Object Type to Run","Object Type to Run"::Report);
        TestField("Object ID to Run");

        CalcFields(XML);
        if XML.HasValue then begin
          XML.CreateInStream(InStr,TEXTENCODING::UTF8);
          InStr.Read(Params);
        end;

        exit(Params);
    end;

    procedure SetReportParameters(Params: Text)
    var
        OutStr: OutStream;
    begin
        TestField("Object Type to Run","Object Type to Run"::Report);
        TestField("Object ID to Run");
        Clear(XML);
        if Params <> '' then begin
          "Report Request Page Options" := true;
          XML.CreateOutStream(OutStr,TEXTENCODING::UTF8);
          OutStr.Write(Params);
        end;
        Modify; // Necessary because the following function does a CALCFIELDS(XML)
        Description := GetDefaultDescriptionFromReportRequestPage(Description);
        Modify;
    end;

    procedure RunReportRequestPage()
    var
        Params: Text;
        OldParams: Text;
    begin
        if "Object Type to Run" <> "Object Type to Run"::Report then
          exit;
        if "Object ID to Run" = 0 then
          exit;

        OldParams := GetReportParameters;
        Params := REPORT.RunRequestPage("Object ID to Run",OldParams);

        if (Params <> '') and (Params <> OldParams) then begin
          "User ID" := UserId;
          SetReportParameters(Params);
        end;
    end;

    [Scope('Personalization')]
    procedure ScheduleJobQueueEntry(CodeunitID: Integer;RecordIDToProcess: RecordID)
    begin
        ScheduleJobQueueEntryWithParameters(CodeunitID,RecordIDToProcess,'');
    end;

    [Scope('Personalization')]
    procedure ScheduleJobQueueEntryWithParameters(CodeunitID: Integer;RecordIDToProcess: RecordID;JobParameter: Text[250])
    begin
        Init;
        "Earliest Start Date/Time" := CreateDateTime(Today,Time);
        "Object Type to Run" := "Object Type to Run"::Codeunit;
        "Object ID to Run" := CodeunitID;
        "Record ID to Process" := RecordIDToProcess;
        "Run in User Session" := false;
        Priority := 1000;
        "Parameter String" := JobParameter;
        EnqueueTask;
    end;

    [Scope('Personalization')]
    procedure ScheduleJobQueueEntryForLater(CodeunitID: Integer;StartDateTime: DateTime;JobQueueCategoryCode: Code[10];JobParameter: Text)
    begin
        Init;
        "Earliest Start Date/Time" := StartDateTime;
        "Object Type to Run" := "Object Type to Run"::Codeunit;
        "Object ID to Run" := CodeunitID;
        "Run in User Session" := false;
        Priority := 1000;
        "Job Queue Category Code" := JobQueueCategoryCode;
        "Maximum No. of Attempts to Run" := 3;
        "Rerun Delay (sec.)" := 60;
        "Parameter String" := CopyStr(JobParameter,1,MaxStrLen("Parameter String"));
        EnqueueTask;
    end;

    [Scope('Personalization')]
    procedure GetStartingDateTime(Date: DateTime): DateTime
    begin
        if "Reference Starting Time" = 0DT then
          Validate("Starting Time");
        exit(CreateDateTime(DT2Date(Date),DT2Time("Reference Starting Time")));
    end;

    [Scope('Personalization')]
    procedure GetEndingDateTime(Date: DateTime): DateTime
    begin
        if "Reference Starting Time" = 0DT then
          Validate("Starting Time");
        if "Ending Time" = 0T then
          exit(CreateDateTime(DT2Date(Date),0T));
        if "Starting Time" = 0T then
          exit(CreateDateTime(DT2Date(Date),"Ending Time"));
        if "Starting Time" < "Ending Time" then
          exit(CreateDateTime(DT2Date(Date),"Ending Time"));
        exit(CreateDateTime(DT2Date(Date) + 1,"Ending Time"));
    end;

    [Scope('Personalization')]
    procedure ScheduleRecurrentJobQueueEntry(ObjType: Option;ObjID: Integer;RecId: RecordID)
    begin
        Reset;
        SetRange("Object Type to Run",ObjType);
        SetRange("Object ID to Run",ObjID);
        if Format(RecId) <> '' then
          SetFilter("Record ID to Process",Format(RecId));
        LockTable;

        if not FindFirst then begin
          InitRecurringJob(5);
          "Object Type to Run" := ObjType;
          "Object ID to Run" := ObjID;
          "Record ID to Process" := RecId;
          "Starting Time" := 080000T;
          "Maximum No. of Attempts to Run" := 3;
          EnqueueTask;
        end;
    end;

    [Scope('Personalization')]
    procedure InitRecurringJob(NoofMinutesbetweenRuns: Integer)
    begin
        Init;
        Clear(ID); // "Job Queue - Enqueue" is to define new ID
        "Recurring Job" := true;
        "Run on Mondays" := true;
        "Run on Tuesdays" := true;
        "Run on Wednesdays" := true;
        "Run on Thursdays" := true;
        "Run on Fridays" := true;
        "Run on Saturdays" := true;
        "Run on Sundays" := true;
        "No. of Minutes between Runs" := NoofMinutesbetweenRuns;
        "Earliest Start Date/Time" := CurrentDateTime;
    end;

    [Scope('Personalization')]
    procedure FindJobQueueEntry(ObjType: Option;ObjID: Integer): Boolean
    begin
        Reset;
        SetRange("Object Type to Run",ObjType);
        SetRange("Object ID to Run",ObjID);
        exit(FindFirst);
    end;

    procedure GetDefaultDescription(): Text[250]
    var
        DefaultDescription: Text[250];
    begin
        CalcFields("Object Caption to Run");
        DefaultDescription := CopyStr("Object Caption to Run",1,MaxStrLen(DefaultDescription));
        if "Object Type to Run" <> "Object Type to Run"::Report then
          exit(DefaultDescription);
        exit(GetDefaultDescriptionFromReportRequestPage(DefaultDescription));
    end;

    local procedure GetDefaultDescriptionFromReportRequestPage(DefaultDescription: Text[250]): Text[250]
    var
        AccScheduleName: Record "Acc. Schedule Name";
        XMLDOMManagement: Codeunit "XML DOM Management";
        InStr: InStream;
        XMLRootNode: DotNet XmlNode;
        XMLNode: DotNet XmlNode;
    begin
        if not ("Object ID to Run" in [REPORT::"Account Schedule"]) then
          exit(DefaultDescription);

        CalcFields(XML); // Requestpage data
        if not XML.HasValue then
          exit(DefaultDescription);
        XML.CreateInStream(InStr);
        if not XMLDOMManagement.LoadXMLNodeFromInStream(InStr,XMLRootNode) then
          exit(DefaultDescription);
        if IsNull(XMLRootNode) then
          exit(DefaultDescription);

        // Specific for report 25 Account Schedule
        XMLNode := XMLRootNode.SelectSingleNode('//Field[@name="AccSchedName"]');
        if IsNull(XMLNode) then
          exit(DefaultDescription);
        if not AccScheduleName.Get(CopyStr(XMLNode.InnerText,1,MaxStrLen(AccScheduleName.Name))) then
          exit(DefaultDescription);
        exit(AccScheduleName.Description);
    end;

    [Scope('Personalization')]
    procedure IsToReportInbox(): Boolean
    begin
        exit(
          ("Object Type to Run" = "Object Type to Run"::Report) and
          ("Report Output Type" in ["Report Output Type"::PDF,"Report Output Type"::Word,
                                    "Report Output Type"::Excel]));
    end;

    local procedure UpdateDocumentSentHistory()
    var
        O365DocumentSentHistory: Record "O365 Document Sent History";
    begin
        if ("Object Type to Run" = "Object Type to Run"::Codeunit) and ("Object ID to Run" = CODEUNIT::"Document-Mailing") then
          if (Status = Status::Error) or (Status = Status::Finished) then begin
            O365DocumentSentHistory.SetRange("Job Queue Entry ID",ID);
            if not O365DocumentSentHistory.FindFirst then
              exit;

            if Status = Status::Error then
              O365DocumentSentHistory.SetStatusAsFailed
            else
              O365DocumentSentHistory.SetStatusAsSuccessfullyFinished;
          end;
    end;

    [Scope('Personalization')]
    procedure FilterInactiveOnHoldEntries()
    begin
        Reset;
        SetRange(Status,Status::"On Hold with Inactivity Timeout");
    end;

    [Scope('Personalization')]
    procedure DoesJobNeedToBeRun() Result: Boolean
    begin
        OnFindingIfJobNeedsToBeRun(Result);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReschedule(var JobQueueEntry: Record "Job Queue Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeClearServiceValues(var JobQueueEntry: Record "Job Queue Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertLogEntry(var JobQueueLogEntry: Record "Job Queue Log Entry";var JobQueueEntry: Record "Job Queue Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyLogEntry(var JobQueueLogEntry: Record "Job Queue Log Entry";var JobQueueEntry: Record "Job Queue Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeScheduleTask(var JobQueueEntry: Record "Job Queue Entry";var TaskGUID: Guid)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetStatusValue(var JobQueueEntry: Record "Job Queue Entry";var xJobQueueEntry: Record "Job Queue Entry";var NewStatus: Option)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnFindingIfJobNeedsToBeRun(var Result: Boolean)
    begin
    end;
}

