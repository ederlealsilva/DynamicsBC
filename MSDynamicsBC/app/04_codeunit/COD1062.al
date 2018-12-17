codeunit 1062 "QBD Sync Proxy"
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure GetQBDSyncSettings(var Title: Text;var Description: Text;var Enabled: Boolean;var SendToEmail: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure SetQBDSyncEnabled(Enabled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure SetQBDSyncSendToEmail(SendToEmail: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure SendEmailInBackground(var Handled: Boolean)
    begin
    end;
}

