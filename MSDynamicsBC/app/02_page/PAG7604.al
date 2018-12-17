page 7604 "Base Calendar Entries Subform"
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
                field(CurrentCalendarCode;CurrentCalendarCode)
                {
                    ApplicationArea = Suite;
                    Caption = 'Base Calendar Code';
                    Editable = false;
                    ToolTip = 'Specifies which base calendar was used as the basis.';
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
        Nonworking := CalendarMgmt.CheckDateStatus(CurrentCalendarCode,"Period Start",Description);
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
        SetFilter("Period Start",'>=%1',00000101D);
    end;

    var
        BaseCalendarChange: Record "Base Calendar Change";
        PeriodFormMgt: Codeunit PeriodFormManagement;
        CalendarMgmt: Codeunit "Calendar Management";
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period";
        Nonworking: Boolean;
        WeekNo: Integer;
        Description: Text[30];
        CurrentCalendarCode: Code[10];

    [Scope('Personalization')]
    procedure SetCalendarCode(CalendarCode: Code[10])
    begin
        CurrentCalendarCode := CalendarCode;
        CurrPage.Update;
    end;

    local procedure UpdateBaseCalendarChanges()
    begin
        BaseCalendarChange.Reset;
        BaseCalendarChange.SetRange("Base Calendar Code",CurrentCalendarCode);
        BaseCalendarChange.SetRange(Date,"Period Start");
        if BaseCalendarChange.FindFirst then
          BaseCalendarChange.Delete;
        BaseCalendarChange.Init;
        BaseCalendarChange."Base Calendar Code" := CurrentCalendarCode;
        BaseCalendarChange.Date := "Period Start";
        BaseCalendarChange.Description := Description;
        BaseCalendarChange.Nonworking := Nonworking;
        BaseCalendarChange.Day := "Period No.";
        BaseCalendarChange.Insert;
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

