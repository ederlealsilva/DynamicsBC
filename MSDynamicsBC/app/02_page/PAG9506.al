page 9506 "Session List"
{
    // version NAVW113.00

    Caption = 'Session List';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Session,SQL Trace,Events';
    RefreshOnActivate = true;
    SourceTable = "Active Session";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(SessionIdText;SessionIdText)
                {
                    ApplicationArea = All;
                    Caption = 'Session ID';
                    Editable = false;
                    ToolTip = 'Specifies the session in the list.';
                }
                field("User ID";"User ID")
                {
                    ApplicationArea = All;
                    Caption = 'User ID';
                    Editable = false;
                    ToolTip = 'Specifies the user name of the user who is logged on to the active session.';
                }
                field(IsSQLTracing;IsSQLTracing)
                {
                    ApplicationArea = All;
                    Caption = 'SQL Tracing';
                    Editable = IsRowSessionActive;
                    ToolTip = 'Specifies if SQL tracing is enabled.';

                    trigger OnValidate()
                    begin
                        IsSQLTracing := DEBUGGER.EnableSqlTrace("Session ID",IsSQLTracing);
                    end;
                }
                field("Client Type";ClientTypeText)
                {
                    ApplicationArea = All;
                    Caption = 'Client Type';
                    Editable = false;
                    ToolTip = 'Specifies the client type on which the session event occurred, such as Web Service and Client Service . ';
                }
                field("Login Datetime";"Login Datetime")
                {
                    ApplicationArea = All;
                    Caption = 'Login Date';
                    Editable = false;
                    ToolTip = 'Specifies the date and time that the session started on the Business Central Server instance.';
                }
                field("Server Computer Name";"Server Computer Name")
                {
                    ApplicationArea = All;
                    Caption = 'Server Computer Name';
                    Editable = false;
                    ToolTip = 'Specifies the fully qualified domain name (FQDN) of the computer on which the Business Central Server instance runs.';
                }
                field("Server Instance Name";"Server Instance Name")
                {
                    ApplicationArea = All;
                    Caption = 'Server Instance Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of the Business Central Server instance to which the session is connected. The server instance name comes from the Session Event table.';
                }
                field(IsDebugging;IsDebugging)
                {
                    ApplicationArea = All;
                    Caption = 'Debugging';
                    Editable = false;
                    ToolTip = 'Specifies sessions that are being debugged.';
                }
                field(IsDebugged;IsDebugged)
                {
                    ApplicationArea = All;
                    Caption = 'Debugged';
                    Editable = false;
                    ToolTip = 'Specifies debugged sessions.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            separator(Separator8)
            {
            }
            group(Session)
            {
                Caption = 'Session';
                action("Debug Selected Session")
                {
                    ApplicationArea = All;
                    Caption = 'Debug';
                    Enabled = CanDebugSelectedSession;
                    Image = Debug;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+Ctrl+S';
                    ToolTip = 'Debug the selected session';

                    trigger OnAction()
                    begin
                        DebuggerManagement.SetDebuggedSession(Rec);
                        DebuggerManagement.OpenDebuggerTaskPage;
                    end;
                }
                action("Debug Next Session")
                {
                    ApplicationArea = All;
                    Caption = 'Debug Next';
                    Enabled = CanDebugNextSession;
                    Image = DebugNext;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+Ctrl+N';
                    ToolTip = 'Debug the next session that breaks code execution.';

                    trigger OnAction()
                    var
                        DebuggedSessionTemp: Record "Active Session";
                    begin
                        DebuggedSessionTemp."Session ID" := 0;
                        DebuggerManagement.SetDebuggedSession(DebuggedSessionTemp);
                        DebuggerManagement.OpenDebuggerTaskPage;
                    end;
                }
            }
            group("SQL Trace")
            {
                Caption = 'SQL Trace';
                action("Start Full SQL Tracing")
                {
                    ApplicationArea = All;
                    Caption = 'Start Full SQL Tracing';
                    Enabled = NOT FullSQLTracingStarted;
                    Image = Continue;
                    Promoted = true;
                    PromotedCategory = Category5;
                    ToolTip = 'Start SQL tracing.';

                    trigger OnAction()
                    begin
                        DEBUGGER.EnableSqlTrace(0,true);
                        FullSQLTracingStarted := true;
                    end;
                }
                action("Stop Full SQL Tracing")
                {
                    ApplicationArea = All;
                    Caption = 'Stop Full SQL Tracing';
                    Enabled = FullSQLTracingStarted;
                    Image = Stop;
                    Promoted = true;
                    PromotedCategory = Category5;
                    ToolTip = 'Stop the current SQL tracing.';

                    trigger OnAction()
                    begin
                        DEBUGGER.EnableSqlTrace(0,false);
                        FullSQLTracingStarted := false;
                    end;
                }
            }
            group("Event")
            {
                Caption = 'Event';
                action(Subscriptions)
                {
                    ApplicationArea = All;
                    Caption = 'Subscriptions';
                    Image = "Event";
                    Promoted = true;
                    PromotedCategory = Category6;
                    RunObject = Page "Event Subscriptions";
                    ToolTip = 'Show event subscriptions.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        IsDebugging := DEBUGGER.IsActive and ("Session ID" = DEBUGGER.DebuggingSessionId);
        IsDebugged := DEBUGGER.IsAttached and ("Session ID" = DEBUGGER.DebuggedSessionId);
        IsSQLTracing := DEBUGGER.EnableSqlTrace("Session ID");
        IsRowSessionActive := IsSessionActive("Session ID");

        // If this is the empty row, clear the Session ID and Client Type
        if "Session ID" = 0 then begin
          SessionIdText := '';
          ClientTypeText := '';
        end else begin
          SessionIdText := Format("Session ID");
          ClientTypeText := Format("Client Type");
        end;
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        CanDebugNextSession := not DEBUGGER.IsActive;
        CanDebugSelectedSession := not DEBUGGER.IsAttached and not IsEmpty;

        // If the session list is empty, insert an empty row to carry the button state to the client
        if not Find(Which) then begin
          Init;
          "Session ID" := 0;
        end;

        exit(true);
    end;

    trigger OnOpenPage()
    begin
        FilterGroup(2);
        SetFilter("Server Instance ID",'=%1',ServiceInstanceId);
        SetFilter("Session ID",'<>%1',SessionId);
        FilterGroup(0);

        FullSQLTracingStarted := DEBUGGER.EnableSqlTrace(0);
    end;

    var
        DebuggerManagement: Codeunit "Debugger Management";
        [InDataSet]
        CanDebugNextSession: Boolean;
        [InDataSet]
        CanDebugSelectedSession: Boolean;
        [InDataSet]
        FullSQLTracingStarted: Boolean;
        IsDebugging: Boolean;
        IsDebugged: Boolean;
        IsSQLTracing: Boolean;
        IsRowSessionActive: Boolean;
        SessionIdText: Text;
        ClientTypeText: Text;
}

