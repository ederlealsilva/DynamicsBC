codeunit 400 "SMTP Mail"
{
    // version NAVW113.00

    Permissions = TableData "SMTP Mail Setup"=r;

    trigger OnRun()
    begin
    end;

    var
        SMTPMailSetup: Record "SMTP Mail Setup";
        Mail: DotNet SmtpMessage;
        Text002: Label 'Attachment %1 does not exist or can not be accessed from the program.', Comment='%1=file name';
        SendResult: Text;
        Text003: Label 'The mail system returned the following error: "%1".', Comment='%1=an error message';
        SendErr: Label 'The email couldn''t be sent.';
        RecipientErr: Label 'Could not add recipient %1.', Comment='%1 = email address';
        BodyErr: Label 'Could not add text to email body.';
        AttachErr: Label 'Could not add an attachment to the email.';

    [Scope('Personalization')]
    procedure CreateMessage(SenderName: Text;SenderAddress: Text;Recipients: Text;Subject: Text;Body: Text;HtmlFormatted: Boolean)
    begin
        OnBeforeCreateMessage(SenderName,SenderAddress,Recipients,Subject,Body,HtmlFormatted);

        if Recipients <> '' then
          CheckValidEmailAddresses(Recipients);
        CheckValidEmailAddresses(SenderAddress);
        SMTPMailSetup.GetSetup;
        SMTPMailSetup.TestField("SMTP Server");
        if not IsNull(Mail) then begin
          Mail.Dispose;
          Clear(Mail);
        end;
        SendResult := '';
        Mail := Mail.SmtpMessage;
        Mail.FromName := SenderName;
        Mail.FromAddress := SenderAddress;
        Mail."To" := Recipients;
        Mail.Subject := Subject;
        Mail.Body := Body;
        Mail.HtmlFormatted := HtmlFormatted;

        if HtmlFormatted then
          Mail.ConvertBase64ImagesToContentId;
    end;

    [Scope('Personalization')]
    procedure TrySend(): Boolean
    var
        Password: Text;
    begin
        OnBeforeTrySend;
        SendResult := '';
        Password := SMTPMailSetup.GetPassword;
        with SMTPMailSetup do
          SendResult :=
            Mail.Send(
              "SMTP Server",
              "SMTP Server Port",
              Authentication <> Authentication::Anonymous,
              "User ID",
              Password,
              "Secure Connection");
        Mail.Dispose;
        Clear(Mail);

        exit(SendResult = '');
    end;

    [Scope('Personalization')]
    procedure Send()
    begin
        if not TrySend then
          ShowErrorNotification(SendErr,SendResult);
    end;

    [Scope('Personalization')]
    procedure AddRecipients(Recipients: Text)
    var
        Result: Text;
    begin
        OnBeforeAddRecipients(Recipients);

        CheckValidEmailAddresses(Recipients);
        Result := Mail.AddRecipients(Recipients);
        if Result <> '' then
          ShowErrorNotification(StrSubstNo(RecipientErr,Recipients),Result);
    end;

    [Scope('Personalization')]
    procedure AddCC(Recipients: Text)
    var
        Result: Text;
    begin
        OnBeforeAddCC(Recipients);

        CheckValidEmailAddresses(Recipients);
        Result := Mail.AddCC(Recipients);
        if Result <> '' then
          ShowErrorNotification(StrSubstNo(RecipientErr,Recipients),Result);
    end;

    [Scope('Personalization')]
    procedure AddBCC(Recipients: Text)
    var
        Result: Text;
    begin
        OnBeforeAddBCC(Recipients);

        CheckValidEmailAddresses(Recipients);
        Result := Mail.AddBCC(Recipients);
        if Result <> '' then
          ShowErrorNotification(StrSubstNo(RecipientErr,Recipients),Result);
    end;

    [Scope('Personalization')]
    procedure AppendBody(BodyPart: Text)
    var
        Result: Text;
    begin
        Result := Mail.AppendBody(BodyPart);
        if Result <> '' then
          ShowErrorNotification(BodyErr,Result);
    end;

    procedure AddAttachment(Attachment: Text;FileName: Text)
    var
        FileManagement: Codeunit "File Management";
        Result: Text;
    begin
        if Attachment = '' then
          exit;
        if not Exists(Attachment) then
          Error(Text002,Attachment);

        FileName := FileManagement.StripNotsupportChrInFileName(FileName);
        FileName := DelChr(FileName,'=',';'); // Used for splitting multiple file names in Mail .NET component

        FileManagement.IsAllowedPath(Attachment,false);
        Result := Mail.AddAttachmentWithName(Attachment,FileName);

        if Result <> '' then
          ShowErrorNotification(AttachErr,Result);
    end;

    [Scope('Personalization')]
    procedure AddAttachmentStream(AttachmentStream: InStream;AttachmentName: Text)
    var
        FileManagement: Codeunit "File Management";
    begin
        AttachmentName := FileManagement.StripNotsupportChrInFileName(AttachmentName);

        Mail.AddAttachment(AttachmentStream,AttachmentName);
    end;

    [Scope('Personalization')]
    procedure CheckValidEmailAddresses(Recipients: Text)
    var
        MailManagement: Codeunit "Mail Management";
    begin
        MailManagement.CheckValidEmailAddresses(Recipients);
    end;

    [Scope('Personalization')]
    procedure GetLastSendMailErrorText(): Text
    begin
        exit(SendResult);
    end;

    [Scope('Personalization')]
    procedure GetSMTPMessage(var SMTPMessage: DotNet SmtpMessage)
    begin
        SMTPMessage := Mail;
    end;

    [Scope('Personalization')]
    procedure IsEnabled(): Boolean
    begin
        SMTPMailSetup.GetSetup;
        exit(not (SMTPMailSetup."SMTP Server" = ''));
    end;

    [EventSubscriber(ObjectType::Table, 1400, 'OnRegisterServiceConnection', '', false, false)]
    [Scope('Personalization')]
    procedure HandleSMTPRegisterServiceConnection(var ServiceConnection: Record "Service Connection")
    var
        RecRef: RecordRef;
    begin
        SMTPMailSetup.GetSetup;
        RecRef.GetTable(SMTPMailSetup);

        ServiceConnection.Status := ServiceConnection.Status::Enabled;
        if SMTPMailSetup."SMTP Server" = '' then
          ServiceConnection.Status := ServiceConnection.Status::Disabled;

        with SMTPMailSetup do
          ServiceConnection.InsertServiceConnection(
            ServiceConnection,RecRef.RecordId,TableCaption,'',PAGE::"SMTP Mail Setup");
    end;

    [Scope('Personalization')]
    procedure GetBody(): Text
    begin
        exit(Mail.Body);
    end;

    [IntegrationEvent(TRUE, false)]
    procedure OnBeforeTrySend()
    begin
    end;

    local procedure ShowErrorNotification(ErrorMessage: Text;SmtpResult: Text)
    var
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        Notification: Notification;
    begin
        if GuiAllowed then begin
          Notification.Message := ErrorMessage;
          Notification.Scope := NOTIFICATIONSCOPE::LocalScope;
          Notification.AddAction('Details',CODEUNIT::"SMTP Mail",'ShowNotificationDetail');
          Notification.SetData('Details',StrSubstNo(Text003,SmtpResult));
          NotificationLifecycleMgt.SendNotification(Notification,SMTPMailSetup.RecordId);
          Error('');
        end;
        Error(Text003,SmtpResult);
    end;

    procedure ShowNotificationDetail(Notification: Notification)
    begin
        Message(Notification.GetData('Details'));
    end;

    [Scope('Personalization')]
    procedure GetO365SmtpServer(): Text[250]
    begin
        exit('smtp.office365.com')
    end;

    [Scope('Personalization')]
    procedure GetOutlookSmtpServer(): Text[250]
    begin
        exit('smtp-mail.outlook.com')
    end;

    [Scope('Personalization')]
    procedure GetGmailSmtpServer(): Text[250]
    begin
        exit('smtp.gmail.com')
    end;

    [Scope('Personalization')]
    procedure GetYahooSmtpServer(): Text[250]
    begin
        exit('smtp.mail.yahoo.com')
    end;

    [Scope('Personalization')]
    procedure GetDefaultSmtpPort(): Integer
    begin
        exit(587);
    end;

    [Scope('Personalization')]
    procedure GetYahooSmtpPort(): Integer
    begin
        exit(465);
    end;

    [Scope('Personalization')]
    procedure GetDefaultSmtpAuthType(): Integer
    var
        SMTPMailSetup: Record "SMTP Mail Setup";
    begin
        exit(SMTPMailSetup.Authentication::Basic);
    end;

    local procedure ApplyDefaultSmtpConnectionSettings(var SMTPMailSetupConfig: Record "SMTP Mail Setup")
    begin
        SMTPMailSetupConfig.Authentication := GetDefaultSmtpAuthType;
        SMTPMailSetupConfig."Secure Connection" := true;
    end;

    [Scope('Personalization')]
    procedure ApplyOffice365Smtp(var SMTPMailSetupConfig: Record "SMTP Mail Setup")
    begin
        // This might be changed by the Microsoft Office 365 team.
        // Current source: http://technet.microsoft.com/library/dn554323.aspx
        SMTPMailSetupConfig."SMTP Server" := GetO365SmtpServer;
        SMTPMailSetupConfig."SMTP Server Port" := GetDefaultSmtpPort;
        ApplyDefaultSmtpConnectionSettings(SMTPMailSetupConfig);
    end;

    [Scope('Personalization')]
    procedure ApplyOutlookSmtp(var SMTPMailSetupConfig: Record "SMTP Mail Setup")
    begin
        // This might be changed.
        SMTPMailSetupConfig."SMTP Server" := GetOutlookSmtpServer;
        SMTPMailSetupConfig."SMTP Server Port" := GetDefaultSmtpPort;
        ApplyDefaultSmtpConnectionSettings(SMTPMailSetupConfig);
    end;

    [Scope('Personalization')]
    procedure ApplyGmailSmtp(var SMTPMailSetupConfig: Record "SMTP Mail Setup")
    begin
        // This might be changed.
        SMTPMailSetupConfig."SMTP Server" := GetGmailSmtpServer;
        SMTPMailSetupConfig."SMTP Server Port" := GetDefaultSmtpPort;
        ApplyDefaultSmtpConnectionSettings(SMTPMailSetupConfig);
    end;

    [Scope('Personalization')]
    procedure ApplyYahooSmtp(var SMTPMailSetupConfig: Record "SMTP Mail Setup")
    begin
        // This might be changed.
        SMTPMailSetupConfig."SMTP Server" := GetYahooSmtpServer;
        SMTPMailSetupConfig."SMTP Server Port" := GetYahooSmtpPort;
        ApplyDefaultSmtpConnectionSettings(SMTPMailSetupConfig);
    end;

    [Scope('Personalization')]
    procedure IsOffice365Setup(var SMTPMailSetupConfig: Record "SMTP Mail Setup"): Boolean
    begin
        if SMTPMailSetupConfig."SMTP Server" <> GetO365SmtpServer then
          exit(false);

        if SMTPMailSetupConfig."SMTP Server Port" <> GetDefaultSmtpPort then
          exit(false);

        exit(IsSmtpConnectionSetup(SMTPMailSetupConfig));
    end;

    [Scope('Personalization')]
    procedure IsOutlookSetup(var SMTPMailSetupConfig: Record "SMTP Mail Setup"): Boolean
    begin
        if SMTPMailSetupConfig."SMTP Server" <> GetOutlookSmtpServer then
          exit(false);

        if SMTPMailSetupConfig."SMTP Server Port" <> GetDefaultSmtpPort then
          exit(false);

        exit(IsSmtpConnectionSetup(SMTPMailSetupConfig));
    end;

    [Scope('Personalization')]
    procedure IsGmailSetup(var SMTPMailSetupConfig: Record "SMTP Mail Setup"): Boolean
    begin
        if SMTPMailSetupConfig."SMTP Server" <> GetGmailSmtpServer then
          exit(false);

        if SMTPMailSetupConfig."SMTP Server Port" <> GetDefaultSmtpPort then
          exit(false);

        exit(IsSmtpConnectionSetup(SMTPMailSetupConfig));
    end;

    [Scope('Personalization')]
    procedure IsYahooSetup(var SMTPMailSetupConfig: Record "SMTP Mail Setup"): Boolean
    begin
        if SMTPMailSetupConfig."SMTP Server" <> GetYahooSmtpServer then
          exit(false);

        if SMTPMailSetupConfig."SMTP Server Port" <> GetYahooSmtpPort then
          exit(false);

        exit(IsSmtpConnectionSetup(SMTPMailSetupConfig));
    end;

    local procedure IsSmtpConnectionSetup(var SMTPMailSetupConfig: Record "SMTP Mail Setup"): Boolean
    begin
        if SMTPMailSetupConfig.Authentication <> GetDefaultSmtpAuthType then
          exit(false);

        if SMTPMailSetupConfig."Secure Connection" <> true then
          exit(false);

        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateMessage(var SenderName: Text;var SenderAddress: Text;var Recipients: Text;var Subject: Text;var Body: Text;HtmlFormatted: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddRecipients(var Recipients: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddCC(var Recipients: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddBCC(var Recipients: Text)
    begin
    end;
}

