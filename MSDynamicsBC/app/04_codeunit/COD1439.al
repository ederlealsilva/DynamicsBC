codeunit 1439 "Headline Management"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        MorningGreetingTxt: Label 'Good morning, %1!', Comment='%1 is the user name. This is displayed between 00:00 and 10:59.';
        LateMorningGreetingTxt: Label 'Hi, %1!', Comment='%1 is the user name.  This is displayed between 11:00 and 11:59.';
        NoonGreetingTxt: Label 'Hi, %1!', Comment='%1 is the user name.  This is displayed between 12:00 and 13:59.';
        AfternoonGreetingTxt: Label 'Good afternoon, %1!', Comment='%1 is the user name.  This is displayed between 14:00 and 18:59.';
        EveningGreetingTxt: Label 'Good evening, %1!', Comment='%1 is the user name.  This is displayed between 19:00 and 23:59.';
        TimeOfDay: Option Morning,LateMorning,Noon,Afternoon,Evening;
        SimpleMorningGreetingTxt: Label 'Good morning!', Comment=' This is displayed between 00:00 and 10:59.';
        SimpleLateMorningGreetingTxt: Label 'Hi!', Comment=' This is displayed between 11:00 and 11:59.';
        SimpleNoonGreetingTxt: Label 'Hi!', Comment=' This is displayed between 12:00 and 13:59.';
        SimpleAfternoonGreetingTxt: Label 'Good afternoon!', Comment=' This is displayed between 14:00 and 18:59.';
        SimpleEveningGreetingTxt: Label 'Good evening!', Comment=' This is displayed between 19:00 and 23:59.';

    [Scope('Personalization')]
    procedure Truncate(TextToTruncate: Text;MaxLength: Integer): Text
    begin
        if StrLen(TextToTruncate) <= MaxLength then
          exit(TextToTruncate);

        if MaxLength <= 0 then
          exit('');

        if MaxLength <= 3 then
          exit(CopyStr(TextToTruncate,1,MaxLength));

        exit(CopyStr(TextToTruncate,1,MaxLength - 3) + '...');
    end;

    [Scope('Personalization')]
    procedure Emphasize(TextToEmphasize: Text): Text
    begin
        if TextToEmphasize <> '' then
          exit(StrSubstNo('<emphasize>%1</emphasize>',TextToEmphasize));
    end;

    [Scope('Personalization')]
    procedure GetHeadlineText(Qualifier: Text;Payload: Text;var ResultText: Text): Boolean
    var
        TextManagement: Codeunit TextManagement;
        PayloadWithoutEmphasize: Text[158];
        PayloadTagsLength: Integer;
        QualifierTagsLength: Integer;
    begin
        QualifierTagsLength := 23;
        PayloadTagsLength := 19;

        if StrLen(Qualifier) + StrLen(Payload) > 250 - QualifierTagsLength - PayloadTagsLength then
          exit(false); // this won't fit

        if Payload = '' then
          exit(false); // payload should not be empty

        if StrLen(Qualifier) > GetMaxQualifierLength then
          exit(false); // qualifier is too long to be a qualifier

        TextManagement.ReplaceRegex(Payload,'<emphasize>|</emphasize>','',PayloadWithoutEmphasize);
        if StrLen(PayloadWithoutEmphasize) > GetMaxPayloadLength then
          exit(false); // payload is too long for being a headline

        ResultText := GetQualifierText(Qualifier) + GetPayloadText(Payload);
        exit(true);
    end;

    local procedure GetPayloadText(PayloadText: Text): Text
    begin
        if PayloadText <> '' then
          exit(StrSubstNo('<payload>%1</payload>',PayloadText));
    end;

    local procedure GetQualifierText(QualifierText: Text): Text
    begin
        if QualifierText <> '' then
          exit(StrSubstNo('<qualifier>%1</qualifier>',QualifierText));
    end;

    [Scope('Personalization')]
    procedure GetUserGreetingText(var GreetingText: Text[250])
    var
        User: Record User;
    begin
        if User.Get(UserSecurityId) then;
        GetUserGreetingTextInternal(User."Full Name",GetTimeOfDay,GreetingText);
    end;

    procedure GetUserGreetingTextInternal(UserName: Text[80];CurrentTimeOfDay: Option;var GreetingText: Text[250])
    var
        TextManagement: Codeunit TextManagement;
        UserNameFound: Boolean;
        CleanUserName: Text;
    begin
        if UserName <> '' then
          if TextManagement.ReplaceRegex(UserName,'\s','',CleanUserName) then
            UserNameFound := CleanUserName <> '';

        case CurrentTimeOfDay of
          TimeOfDay::Morning:
            if UserNameFound then
              GreetingText := StrSubstNo(MorningGreetingTxt,UserName)
            else
              GreetingText := SimpleMorningGreetingTxt;
          TimeOfDay::LateMorning:
            if UserNameFound then
              GreetingText := StrSubstNo(LateMorningGreetingTxt,UserName)
            else
              GreetingText := SimpleLateMorningGreetingTxt;
          TimeOfDay::Noon:
            if UserNameFound then
              GreetingText := StrSubstNo(NoonGreetingTxt,UserName)
            else
              GreetingText := SimpleNoonGreetingTxt;
          TimeOfDay::Afternoon:
            if UserNameFound then
              GreetingText := StrSubstNo(AfternoonGreetingTxt,UserName)
            else
              GreetingText := SimpleAfternoonGreetingTxt;
          TimeOfDay::Evening:
            if UserNameFound then
              GreetingText := StrSubstNo(EveningGreetingTxt,UserName)
            else
              GreetingText := SimpleEveningGreetingTxt;
        end
    end;

    local procedure GetTimeOfDay(): Integer
    var
        TypeHelper: Codeunit "Type Helper";
        TimezoneOffset: Duration;
        Hour: Integer;
    begin
        if not TypeHelper.GetUserTimezoneOffset(TimezoneOffset) then
          TimezoneOffset := 0;

        Evaluate(Hour,TypeHelper.FormatUtcDateTime(TypeHelper.GetCurrUTCDateTime,'HH',''));
        Hour += TimezoneOffset div (60 * 60 * 1000);

        case Hour of
          0..10:
            exit(TimeOfDay::Morning);
          11:
            exit(TimeOfDay::LateMorning);
          12..13:
            exit(TimeOfDay::Noon);
          14..18:
            exit(TimeOfDay::Afternoon);
          19..23:
            exit(TimeOfDay::Evening);
        end;
    end;

    [Scope('Personalization')]
    procedure ShouldUserGreetingBeVisible(): Boolean
    var
        LogInManagement: Codeunit LogInManagement;
        LimitDateTime: DateTime;
    begin
        LimitDateTime := CreateDateTime(Today,Time - (10 * 60 * 1000)); // greet if login is in the last 10 minutes, then stop greeting
        exit(LogInManagement.UserLoggedInAtOrAfterDateTime(LimitDateTime));
    end;

    [Scope('Personalization')]
    procedure GetMaxQualifierLength(): Integer
    begin
        exit(50);
    end;

    [Scope('Personalization')]
    procedure GetMaxPayloadLength(): Integer
    begin
        exit(75);
    end;

    [Scope('Personalization')]
    procedure ScheduleTask(CodeunitId: Integer)
    var
        JobQueueEntry: Record "Job Queue Entry";
        DummyRecordId: RecordID;
    begin
        OnBeforeScheduleTask(CodeunitId);
        if not TASKSCHEDULER.CanCreateTask then
          exit;

        JobQueueEntry.SetRange("Object Type to Run",JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run",CodeunitId);
        JobQueueEntry.SetRange(Status,JobQueueEntry.Status::"In Process");
        if not JobQueueEntry.IsEmpty then
          exit;

        JobQueueEntry.ScheduleJobQueueEntry(CodeunitId,DummyRecordId);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeScheduleTask(CodeunitId: Integer)
    begin
    end;

    [EventSubscriber(ObjectType::Page, 9176, 'OnBeforeLanguageChange', '', true, true)]
    local procedure OnBeforeUpdateLanguage(OldLanguageId: Integer;NewLanguageId: Integer)
    begin
        OnInvalidateHeadlines;
    end;

    [EventSubscriber(ObjectType::Page, 9176, 'OnBeforeWorkdateChange', '', true, true)]
    local procedure OnBeforeUpdateWorkdate(OldWorkdate: Date;NewWorkdate: Date)
    begin
        OnInvalidateHeadlines;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInvalidateHeadlines()
    begin
    end;
}

