page 7605 "Customized Cal. Entries Subfm"
{
    // version NAVW113.00

    Caption = 'Lines';
    DeleteAllowed = false;
    Editable = true;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = Date;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(CurrentSourceType;CurrentSourceType)
                {
                    ApplicationArea = Suite;
                    Caption = 'Current Source Type';
                    OptionCaption = 'Company,Customer,Vendor,Location,Shipping Agent';
                    ToolTip = 'Specifies the source type for the calendar entry.';
                    Visible = false;
                }
                field(CurrentSourceCode;CurrentSourceCode)
                {
                    ApplicationArea = Suite;
                    Caption = 'Current Source Code';
                    ToolTip = 'Specifies the source code for the calendar entry.';
                    Visible = false;
                }
                field(CurrentAdditionalSourceCode;CurrentAdditionalSourceCode)
                {
                    ApplicationArea = Suite;
                    Caption = 'Current Additional Source Code';
                    ToolTip = 'Specifies the calendar entry.';
                    Visible = false;
                }
                field(CurrentCalendarCode;CurrentCalendarCode)
                {
                    ApplicationArea = Suite;
                    Caption = 'Current Calendar Code';
                    Editable = false;
                    ToolTip = 'Specifies the calendar code.';
                    Visible = false;
                }
                field("Period Start";"Period Start")
                {
                    ApplicationArea = Suite;
                    Caption = 'Date';
                    Editable = false;
                    ToolTip = 'Specifies the date.';
                }
                field("Period Name";"Period Name")
                {
                    ApplicationArea = Suite;
                    Caption = 'Day';
                    Editable = false;
                    ToolTip = 'Specifies the day of the week.';
                }
                field(WeekNo;WeekNo)
                {
                    ApplicationArea = Suite;
                    Caption = 'Week No.';
                    Editable = false;
                    ToolTip = 'Specifies the week number for the calendar entries.';
                    Visible = false;
                }
                field(Nonworking;Nonworking)
                {
                    ApplicationArea = Suite;
                    Caption = 'Nonworking';
                    Editable = true;
                    ToolTip = 'Specifies the date entry as a nonworking day. You can also remove the check mark to return the status to working day.';

                    trigger OnValidate()
                    begin
                        UpdateBaseCalendarChanges;
                    end;
                }
                field(Description;Description)
                {
                    ApplicationArea = Suite;
                    Caption = 'Description';
                    ToolTip = 'Specifies the description of the entry to be applied.';

                    trigger OnValidate()
                    begin
                        UpdateBaseCalendarChanges;
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        Nonworking :=
          CalendarMgmt.CheckCustomizedDateStatus(
            CurrentSourceType,CurrentSourceCode,CurrentAdditionalSourceCode,CurrentCalendarCode,"Period Start",Description);
        WeekNo := Date2DWY("Period Start",2);
        CurrentCalendarCodeOnFormat;
        PeriodStartOnFormat;
        PeriodNameOnFormat;
        DescriptionOnFormat;
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        exit(PeriodFormMgt.FindDate(Which,Rec,PeriodType));
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin
        exit(PeriodFormMgt.NextDate(Steps,Rec,PeriodType));
    end;

    trigger OnOpenPage()
    begin
        Reset;
    end;

    var
        CustomizedCalendarChange: Record "Customized Calendar Change";
        CalendarMgmt: Codeunit "Calendar Management";
        PeriodFormMgt: Codeunit PeriodFormManagement;
        CurrentCalendarCode: Code[10];
        CurrentSourceCode: Code[20];
        Description: Text[50];
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period";
        CurrentSourceType: Option Company,Customer,Vendor,Location,"Shipping Agent",Service;
        CurrentAdditionalSourceCode: Code[20];
        Nonworking: Boolean;
        WeekNo: Integer;

    [Scope('Personalization')]
    procedure SetCalendarCode(SourceType: Option Company,Customer,Vendor,Location,"Shipping Agent";SourceCode: Code[20];AdditionalSourceCode: Code[20];CalendarCode: Code[10])
    begin
        CurrentSourceType := SourceType;
        CurrentSourceCode := SourceCode;
        CurrentAdditionalSourceCode := AdditionalSourceCode;
        CurrentCalendarCode := CalendarCode;

        CurrPage.Update;
    end;

    local procedure UpdateBaseCalendarChanges()
    begin
        CustomizedCalendarChange.Reset;
        CustomizedCalendarChange.SetRange("Source Type",CurrentSourceType);
        CustomizedCalendarChange.SetRange("Source Code",CurrentSourceCode);
        CustomizedCalendarChange.SetRange("Base Calendar Code",CurrentCalendarCode);
        CustomizedCalendarChange.SetRange(Date,"Period Start");
        if CustomizedCalendarChange.FindFirst then
          CustomizedCalendarChange.Delete;

        if not IsInBaseCalendar then begin
          CustomizedCalendarChange.Init;
          CustomizedCalendarChange."Source Type" := CurrentSourceType;
          CustomizedCalendarChange."Source Code" := CurrentSourceCode;
          CustomizedCalendarChange."Additional Source Code" := CurrentAdditionalSourceCode;
          CustomizedCalendarChange."Base Calendar Code" := CurrentCalendarCode;
          CustomizedCalendarChange.Date := "Period Start";
          CustomizedCalendarChange.Day := "Period No.";
          CustomizedCalendarChange.Description := Description;
          CustomizedCalendarChange.Nonworking := Nonworking;
          CustomizedCalendarChange.Insert;
        end;
    end;

    local procedure IsInBaseCalendar(): Boolean
    var
        BaseCalendarChange: Record "Base Calendar Change";
    begin
        BaseCalendarChange.SetRange("Base Calendar Code",CurrentCalendarCode);

        BaseCalendarChange.SetRange(Date,"Period Start");
        BaseCalendarChange.SetRange(Day,"Period No.");
        BaseCalendarChange.SetRange("Recurring System",BaseCalendarChange."Recurring System"::" ");
        if BaseCalendarChange.Find('-') then
          exit(BaseCalendarChange.Nonworking = Nonworking);

        BaseCalendarChange.SetRange(Date,0D);
        BaseCalendarChange.SetRange(Day,"Period No.");
        BaseCalendarChange.SetRange("Recurring System",BaseCalendarChange."Recurring System"::"Weekly Recurring");
        if BaseCalendarChange.Find('-') then
          exit(BaseCalendarChange.Nonworking = Nonworking);

        BaseCalendarChange.SetRange(Date);
        BaseCalendarChange.SetRange(Day,BaseCalendarChange.Day::" ");
        BaseCalendarChange.SetRange("Recurring System",BaseCalendarChange."Recurring System"::"Annual Recurring");
        if BaseCalendarChange.Find('-') then
          repeat
            if (Date2DMY(BaseCalendarChange.Date,2) = Date2DMY("Period Start",2)) and
               (Date2DMY(BaseCalendarChange.Date,1) = Date2DMY("Period Start",1))
            then
              exit(BaseCalendarChange.Nonworking = Nonworking);
          until BaseCalendarChange.Next = 0;

        exit(not Nonworking);
    end;

    local procedure CurrentCalendarCodeOnFormat()
    begin
        if Nonworking then;
    end;

    local procedure PeriodStartOnFormat()
    begin
        if Nonworking then;
    end;

    local procedure PeriodNameOnFormat()
    begin
        if Nonworking then;
    end;

    local procedure DescriptionOnFormat()
    begin
        if Nonworking then;
    end;
}

