codeunit 1061 "QBO Sync Proxy"
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure GetQBOSyncSettings(var Title: Text;var Description: Text;var Enabled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure GetQBOAuthURL(var AuthURL: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure SetQBOSyncEnabled(Enabled: Boolean)
    begin
    end;
}

