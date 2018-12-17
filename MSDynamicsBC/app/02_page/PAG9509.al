page 9509 "Debugger Break Rules"
{
    // version NAVW113.00

    Caption = 'Debugger Break Rules';
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(BreakOnError;BreakOnError)
                {
                    ApplicationArea = All;
                    Caption = 'Break On Error';
                }
                field(BreakOnRecordChanges;BreakOnRecordChanges)
                {
                    ApplicationArea = All;
                    Caption = 'Break On Record Changes';
                }
                field(SkipSystemTriggers;SkipSystemTriggers)
                {
                    ApplicationArea = All;
                    Caption = 'Skip System Triggers';
                }
            }
        }
    }

    actions
    {
    }

    var
        BreakOnError: Boolean;
        BreakOnRecordChanges: Boolean;
        SkipSystemTriggers: Boolean;

    [Scope('Personalization')]
    procedure SetBreakOnError(Value: Boolean)
    begin
        BreakOnError := Value;
    end;

    [Scope('Personalization')]
    procedure GetBreakOnError(): Boolean
    begin
        exit(BreakOnError);
    end;

    [Scope('Personalization')]
    procedure SetBreakOnRecordChanges(Value: Boolean)
    begin
        BreakOnRecordChanges := Value;
    end;

    [Scope('Personalization')]
    procedure GetBreakOnRecordChanges(): Boolean
    begin
        exit(BreakOnRecordChanges);
    end;

    [Scope('Personalization')]
    procedure SetSkipSystemTriggers(Value: Boolean)
    begin
        SkipSystemTriggers := Value;
    end;

    [Scope('Personalization')]
    procedure GetSkipSystemTriggers(): Boolean
    begin
        exit(SkipSystemTriggers);
    end;
}

