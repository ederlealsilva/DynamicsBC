codeunit 1632 "Office Error Engine"
{
    // version NAVW111.00

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        ErrorMessage: Text;

    [Scope('Personalization')]
    procedure ShowError(Message: Text)
    begin
        ErrorMessage := Message;
        PAGE.Run(PAGE::"Office Error Dlg");
    end;

    [Scope('Personalization')]
    procedure GetError(): Text
    begin
        exit(ErrorMessage);
    end;
}

