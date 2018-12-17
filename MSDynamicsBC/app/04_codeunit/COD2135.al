codeunit 2135 "O365 Setup Email"
{
    // version NAVW113.00


    trigger OnRun()
    begin
        SetupEmail(false);
    end;

    var
        MailNotConfiguredErr: Label 'An email account must be configured to send emails.';
        ClientTypeManagement: Codeunit ClientTypeManagement;

    [Scope('Personalization')]
    procedure SilentSetup()
    var
        GraphMail: Codeunit "Graph Mail";
    begin
        if GraphMail.IsEnabled or SMTPEmailIsSetUp then
          exit;

        if not GraphMail.HasConfiguration then
          Error(MailNotConfiguredErr);

        GraphMail.SetupGraph(false);

        if not GraphMail.IsEnabled then
          Error(MailNotConfiguredErr);
    end;

    [Scope('Personalization')]
    procedure SetupEmail(ForceSetup: Boolean)
    var
        GraphMail: Codeunit "Graph Mail";
    begin
        if (not GraphMail.IsEnabled) and SMTPEmailIsSetUp then begin
          SetupSmtpEmail(ForceSetup);
          exit;
        end;

        if GraphMail.HasConfiguration then begin
          SetupGraphEmail(ForceSetup);
          exit;
        end;

        SetupSmtpEmail(ForceSetup);
    end;

    local procedure SetupGraphEmail(ForceSetup: Boolean)
    var
        GraphMail: Codeunit "Graph Mail";
        RunSetup: Boolean;
    begin
        RunSetup := ForceSetup;
        if not RunSetup then begin
          if not GraphMail.IsEnabled then
            if not SMTPEmailIsSetUp then
              RunSetup := true;
        end;

        if RunSetup then
          if not GraphMail.SetupGraph(ForceSetup) then // Returns if graph mail was setup
            if not SMTPEmailIsSetUp then begin // If it wasn't maybe smtp was configured instead
              if not ClientTypeManagement.IsPhoneClientType then
                Error('');
              Error(MailNotConfiguredErr);
            end;
    end;

    local procedure SetupSmtpEmail(ForceSetup: Boolean)
    begin
        if ForceSetup or (not SMTPEmailIsSetUp) then begin
          if not GuiAllowed then
            Error(MailNotConfiguredErr);

          if not ClientTypeManagement.IsPhoneClientType then begin
            if PAGE.RunModal(PAGE::"BC O365 Email Setup Wizard") <> ACTION::LookupOK then
              Error('');
          end else
            PAGE.RunModal(PAGE::"O365 Email Setup Wizard");
          if not SMTPEmailIsSetUp then
            Error(MailNotConfiguredErr);
        end;
    end;

    procedure SMTPEmailIsSetUp(): Boolean
    var
        SMTPMailSetup: Record "SMTP Mail Setup";
        MailManagement: Codeunit "Mail Management";
    begin
        if not MailManagement.IsSMTPEnabled then
          exit(false);

        if SMTPMailSetup.GetSetup then
          exit((SMTPMailSetup."User ID" <> '') and (SMTPMailSetup.GetPassword <> ''));
    end;
}

