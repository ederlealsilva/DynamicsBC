codeunit 3031 DotNet_SmtpMessage
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        DotNetSmtpMessage: DotNet SmtpMessage;

    [Scope('Personalization')]
    procedure CreateMessage()
    begin
        DotNetSmtpMessage := DotNetSmtpMessage.SmtpMessage;
    end;

    [Scope('Personalization')]
    procedure SetFromAddress(FromAddress: Text)
    begin
        DotNetSmtpMessage.FromAddress := FromAddress;
    end;

    [Scope('Personalization')]
    procedure SetFromName(FromName: Text)
    begin
        DotNetSmtpMessage.FromAddress := FromName;
    end;

    [Scope('Personalization')]
    procedure SetToAddress(ToAddress: Text)
    begin
        DotNetSmtpMessage."To" := ToAddress;
    end;

    [Scope('Personalization')]
    procedure SetSubject(Subject: Text)
    begin
        DotNetSmtpMessage.Subject := Subject;
    end;

    [Scope('Personalization')]
    procedure SetAsHtmlFormatted(HtmlFormatted: Boolean)
    begin
        DotNetSmtpMessage.HtmlFormatted := HtmlFormatted;
    end;

    [Scope('Personalization')]
    procedure SetTimeout(Timeout: Integer)
    begin
        DotNetSmtpMessage.Timeout := Timeout;
    end;

    [Scope('Personalization')]
    procedure ClearBody()
    begin
        DotNetSmtpMessage.Body := '';
    end;

    [Scope('Personalization')]
    procedure AppendToBody(Text: Text)
    begin
        DotNetSmtpMessage.AppendBody(Text);
    end;

    [Scope('Personalization')]
    procedure AddRecipients(AddressToAdd: Text)
    begin
        DotNetSmtpMessage.AddRecipients(AddressToAdd);
    end;

    [Scope('Personalization')]
    procedure AddCC(AddressToAdd: Text)
    begin
        DotNetSmtpMessage.AddCC(AddressToAdd);
    end;

    [Scope('Personalization')]
    procedure AddBCC(AddressToAdd: Text)
    begin
        DotNetSmtpMessage.AddBCC(AddressToAdd);
    end;

    [Scope('Personalization')]
    procedure AddAttachment(AttachmentStream: InStream;AttachmentName: Text)
    begin
        DotNetSmtpMessage.AddAttachment(AttachmentStream,AttachmentName);
    end;

    [Scope('Personalization')]
    procedure SendMail(ServerName: Text;ServerPort: Integer;UseAuthentication: Boolean;Username: Text;Password: Text;UseSSL: Boolean): Text
    begin
        exit(DotNetSmtpMessage.Send(ServerName,ServerPort,UseAuthentication,Username,Password,UseSSL));
    end;

    [Scope('Personalization')]
    procedure ConvertBase64ImagesToContentId(): Boolean
    begin
        exit(DotNetSmtpMessage.ConvertBase64ImagesToContentId());
    end;

    procedure GetSmtpMessage(var DotNetSmtpMessage2: DotNet SmtpMessage)
    begin
        DotNetSmtpMessage2 := DotNetSmtpMessage;
    end;

    procedure SetSmtpMessage(DotNetSmtpMessage2: DotNet SmtpMessage)
    begin
        DotNetSmtpMessage := DotNetSmtpMessage2;
    end;
}

