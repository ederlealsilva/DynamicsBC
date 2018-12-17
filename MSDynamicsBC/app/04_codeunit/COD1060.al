codeunit 1060 "Paypal Account Proxy"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure GetPaypalAccount(var Account: Text[250])
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure SetPaypalAccount(Account: Text[250];Silent: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure SetAlwaysIncludePaypalOnDocuments(NewAlwaysIncludeOnDocuments: Boolean;HideDialogs: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure SetAlwaysIncludeMsPayOnDocuments(NewAlwaysIncludeOnDocuments: Boolean;HideDialogs: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure GetPaypalSetupOptions(var Enabled: Boolean;var IncludeInAllDocuments: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure GetMsPayIsEnabled(var Enabled: Boolean)
    begin
    end;
}

