codeunit 5370 "Excel Buffer Dialog Management"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        Window: Dialog;
        Progress: Integer;
        WindowOpen: Boolean;

    [Scope('Personalization')]
    procedure Open(Text: Text)
    begin
        if not GuiAllowed then
          exit;

        Window.Open(Text + '@1@@@@@@@@@@@@@@@@@@@@@@@@@\');
        Window.Update(1,0);
        WindowOpen := true;
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure SetProgress(pProgress: Integer)
    begin
        Progress := pProgress;
        if WindowOpen then
          Window.Update(1,Progress);
    end;

    [Scope('Personalization')]
    procedure Close()
    begin
        if WindowOpen then begin
          Window.Close;
          WindowOpen := false;
        end;
    end;
}

