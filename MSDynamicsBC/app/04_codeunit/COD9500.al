codeunit 9500 "Debugger Management"
{
    // version NAVW113.00

    SingleInstance = true;

    trigger OnRun()
    var
        Uri: DotNet Uri;
        UriPartial: DotNet UriPartial;
        UrlString: Text;
    begin
        // Generates a URL like dynamicsnav://host:port/instance//debug<?tenant=tenantId>
        UrlString := GetUrl(CLIENTTYPE::Windows);
        Uri := Uri.Uri(UrlString);
        UrlString := Uri.GetLeftPart(UriPartial.Path) + DebuggerUrlTok + Uri.Query;

        HyperLink(UrlString);
    end;

    var
        ClientAddin: Record "Add-in";
        DebuggedSession: Record "Active Session";
        DebuggerTaskPage: Page Debugger;
        Text000Err: Label 'Cannot process debugger break. The debugger is not active.';
        LastErrorMesssageIsNew: Boolean;
        LastErrorMessage: Text;
        CodeViewerControlRegistered: Boolean;
        ActionState: Option "None",RunningCodeAction,CodeTrackingAction,BreakAfterRunningCodeAction,BreakAfterCodeTrackingAction;
        DebuggerUrlTok: Label 'debug', Locked=true;
        ClientAddinDescriptionTxt: Label '%1 Code Viewer control add-in', Comment='%1 - product name';

    procedure OpenDebuggerTaskPage()
    begin
        if not CodeViewerControlRegistered then begin
          ClientAddin.Init;
          ClientAddin."Add-in Name" := 'Microsoft.Dynamics.Nav.Client.CodeViewer';
          ClientAddin."Public Key Token" := '31bf3856ad364e35';
          ClientAddin.Description := StrSubstNo(ClientAddinDescriptionTxt,PRODUCTNAME.Full);
          if ClientAddin.Insert then;
          CodeViewerControlRegistered := true;
        end;

        if not DEBUGGER.IsActive then
          DebuggerTaskPage.Run
        else
          DebuggerTaskPage.Close;
    end;

    [EventSubscriber(ObjectType::Codeunit, 2000000009, 'OnDebuggerBreak', '', false, false)]
    local procedure ProcessOnDebuggerBreak(ErrorMessage: Text)
    begin
        LastErrorMessage := ErrorMessage;
        LastErrorMesssageIsNew := true;

        if DEBUGGER.IsActive then begin
          if ActionState = ActionState::CodeTrackingAction then
            ActionState := ActionState::BreakAfterCodeTrackingAction
          else
            if ActionState = ActionState::RunningCodeAction then
              ActionState := ActionState::BreakAfterRunningCodeAction;

          RefreshDebuggerTaskPage;
        end else
          Error(Text000Err);
    end;

    [Scope('Personalization')]
    procedure GetLastErrorMessage(var IsNew: Boolean) Message: Text
    begin
        Message := LastErrorMessage;
        IsNew := LastErrorMesssageIsNew;
        LastErrorMesssageIsNew := false;
    end;

    [Scope('Personalization')]
    procedure RefreshDebuggerTaskPage()
    begin
        DebuggerTaskPage.Activate(true);
    end;

    [Scope('Personalization')]
    procedure AddWatch(Path: Text[1024];Refresh: Boolean)
    var
        DebuggerWatch: Record "Debugger Watch";
    begin
        if Path <> '' then begin
          DebuggerWatch.SetRange(Path,Path);
          if DebuggerWatch.IsEmpty then begin
            DebuggerWatch.Init;
            DebuggerWatch.Path := Path;
            DebuggerWatch.Insert(true);

            if Refresh then
              RefreshDebuggerTaskPage;
          end;
        end;
    end;

    local procedure LastIndexOf(Path: Text[1024];Character: Char;Index: Integer): Integer
    var
        CharPos: Integer;
    begin
        if Path = '' then
          exit(0);

        if Index <= 0 then
          exit(0);

        if Index > StrLen(Path) then
          Index := StrLen(Path);

        CharPos := Index;

        if Path[CharPos] = Character then
          exit(CharPos);
        if CharPos = 1 then
          exit(0);

        repeat
          CharPos := CharPos - 1
        until (CharPos = 1) or (Path[CharPos] = Character);

        if Path[CharPos] = Character then
          exit(CharPos);

        exit(0);
    end;

    [Scope('Personalization')]
    procedure RemoveQuotes(Variable: Text[1024]) VarWithoutQuotes: Text[1024]
    begin
        if Variable = '' then
          exit(Variable);

        if (StrLen(Variable) >= 2) and (Variable[1] = '"') and (Variable[StrLen(Variable)] = '"') then
          VarWithoutQuotes := CopyStr(Variable,2,StrLen(Variable) - 2)
        else
          VarWithoutQuotes := Variable;
    end;

    local procedure IsInRecordContext(Path: Text[1024];"Record": Text): Boolean
    var
        Index: Integer;
        Position: Integer;
        CurrentContext: Text[250];
    begin
        if Path = '' then
          exit(false);

        if Record = '' then // Empty record name means all paths match
          exit(true);

        Index := StrLen(Path);

        if Path[Index] = '"' then begin
          Position := LastIndexOf(Path,'"',Index - 1);
          if Position <= 1 then
            exit(false);
          if Path[Position - 1] <> '.' then
            exit(false);
          Index := Position - 1; // set index on first '.' from the end
        end else begin
          Position := LastIndexOf(Path,'.',Index);
          if Position <= 1 then
            exit(false);
          Index := Position; // set index on first '.' from the end
        end;

        Index := Index - 1;
        Position := LastIndexOf(Path,'.',Index);

        if Position <= 1 then  // second '.' not found - context not found
          exit(false);

        Index := Position - 1;
        Position := LastIndexOf(Path,'.',Index);

        CurrentContext := CopyStr(Path,Position + 1,Index - Position);
        exit(LowerCase(CurrentContext) = LowerCase(Record));
    end;

    [Scope('Personalization')]
    procedure ShouldBeInTooltip(Path: Text[1024];LeftContext: Text): Boolean
    begin
        exit((StrPos(Path,'."<Globals>"') = 0) and (StrPos(Path,'.Keys.') = 0) and
          ((StrPos(Path,'."<Global Text Constants>".') = 0) or (StrPos(Path,'"<Globals>"."<Global Text Constants>".') > 0)) and
          IsInRecordContext(Path,LeftContext));
    end;

    procedure GetDebuggedSession(var DebuggedSessionRec: Record "Active Session")
    begin
        DebuggedSessionRec := DebuggedSession;
    end;

    [Scope('Personalization')]
    procedure SetDebuggedSession(DebuggedSessionRec: Record "Active Session")
    begin
        DebuggedSession := DebuggedSessionRec;
    end;

    [Scope('Personalization')]
    procedure SetRunningCodeAction()
    begin
        ActionState := ActionState::RunningCodeAction;
    end;

    [Scope('Personalization')]
    procedure SetCodeTrackingAction()
    begin
        ActionState := ActionState::CodeTrackingAction;
    end;

    [Scope('Personalization')]
    procedure IsBreakAfterRunningCodeAction(): Boolean
    begin
        exit(ActionState = ActionState::BreakAfterRunningCodeAction);
    end;

    [Scope('Personalization')]
    procedure IsBreakAfterCodeTrackingAction(): Boolean
    begin
        exit(ActionState = ActionState::BreakAfterCodeTrackingAction);
    end;

    [Scope('Personalization')]
    procedure ResetActionState()
    begin
        ActionState := ActionState::None;
    end;

    [EventSubscriber(ObjectType::Codeunit, 2000000006, 'OpenDebugger', '', false, false)]
    local procedure OpenDebugger()
    begin
        PAGE.Run(PAGE::"Session List");
    end;
}

