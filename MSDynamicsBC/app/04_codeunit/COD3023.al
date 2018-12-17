codeunit 3023 DotNet_ActionableMessage
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        DotNetActionableMessage: DotNet ActionableMessage;

    [Scope('Personalization')]
    procedure Create(MessageCardContext: Text;SenderEmail: Text;OpayCardOriginatorForNav: Text;OpayCardPrivateKey: Text): Text
    begin
        exit(DotNetActionableMessage.Create(MessageCardContext,SenderEmail,OpayCardOriginatorForNav,OpayCardPrivateKey))
    end;

    procedure GetActionableMessage(var DotNetActionableMessage2: DotNet ActionableMessage)
    begin
        DotNetActionableMessage2 := DotNetActionableMessage
    end;

    procedure SetActionableMessage(DotNetActionableMessage2: DotNet ActionableMessage)
    begin
        DotNetActionableMessage := DotNetActionableMessage2
    end;
}

