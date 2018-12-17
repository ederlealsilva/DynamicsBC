codeunit 5456 "Graph Connection Setup"
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    var
        PwdConnectionStringTxt: Label '{ENTITYLISTENDPOINT}=%1;{ENTITYENDPOINT}=%2', Locked=true;
        S2SConnectionStringTxt: Label '{ENTITYLISTENDPOINT}=%1;{ENTITYENDPOINT}=%2;{EXORESOURCEURI}=%3;{EXORESOURCEROLE}=%4;', Locked=true;
        AzureSecretNameTxt: Label 'ExchangeAuthMethod', Locked=true;
        GraphResourceUrlTxt: Label 'https://outlook.office365.com/', Locked=true;

    [Scope('Personalization')]
    procedure CanRunSync(): Boolean
    var
        ForceSync: Boolean;
    begin
        OnCheckForceSync(ForceSync);
        if ForceSync then
          exit(true);

        if GetDefaultTableConnection(TABLECONNECTIONTYPE::MicrosoftGraph) <> '' then
          exit(false);

        exit(true);
    end;

    [Scope('Personalization')]
    procedure ConstructConnectionString(EntityEndpoint: Text;EntityListEndpoint: Text;ResourceUri: Text;ResourceRoles: Text) ConnectionString: Text
    begin
        if IsS2SAuthenticationEnabled then
          ConnectionString := S2SConnectionStringTxt
        else
          ConnectionString := PwdConnectionStringTxt;

        if ResourceUri = '' then
          ResourceUri := GraphResourceUrlTxt;

        ConnectionString := StrSubstNo(ConnectionString,EntityListEndpoint,EntityEndpoint,ResourceUri,ResourceRoles);
    end;

    [Scope('Personalization')]
    procedure GetGraphNotificationUrl(): Text[250]
    var
        WebhookManagement: Codeunit "Webhook Management";
    begin
        exit(WebhookManagement.GetNotificationUrl);
    end;

    [Scope('Personalization')]
    procedure GetInboundConnectionName(TableID: Integer) ConnectionName: Text
    begin
        OnGetInboundConnectionName(TableID,ConnectionName);
    end;

    [Scope('Personalization')]
    procedure GetInboundConnectionString(TableID: Integer) ConnectionString: Text
    begin
        OnGetInboundConnectionString(TableID,ConnectionString);
    end;

    [Scope('Personalization')]
    procedure GetSubscriptionConnectionName(TableID: Integer) ConnectionName: Text
    begin
        OnGetSubscriptionConnectionName(TableID,ConnectionName);
    end;

    [Scope('Personalization')]
    procedure GetSubscriptionConnectionString(TableID: Integer) ConnectionString: Text
    begin
        OnGetSubscriptionConnectionString(TableID,ConnectionString);
    end;

    [Scope('Personalization')]
    procedure GetSynchronizeConnectionName(TableID: Integer) ConnectionName: Text
    begin
        OnGetSynchronizeConnectionName(TableID,ConnectionName);
    end;

    [Scope('Personalization')]
    procedure GetSynchronizeConnectionString(TableID: Integer) ConnectionString: Text
    begin
        OnGetSynchronizeConnectionString(TableID,ConnectionString);
    end;

    [Scope('Personalization')]
    procedure RegisterConnectionForEntity(InboundConnectionName: Text;InboundConnectionString: Text;SubscriptionConnectionName: Text;SubscriptionConnectionString: Text;SynchronizeConnectionName: Text;SynchronizeConnectionString: Text)
    begin
        RegisterConnectionWithName(InboundConnectionName,InboundConnectionString);
        RegisterConnectionWithName(SubscriptionConnectionName,SubscriptionConnectionString);
        RegisterConnectionWithName(SynchronizeConnectionName,SynchronizeConnectionString);
    end;

    [Scope('Personalization')]
    procedure RegisterConnections()
    begin
        OnRegisterConnections;
    end;

    procedure IsS2SAuthenticationEnabled(): Boolean
    var
        AzureKeyVaultManagement: Codeunit "Azure Key Vault Management";
        AzureSecret: Text;
    begin
        if not AzureKeyVaultManagement.IsEnable then
          exit(false);

        AzureKeyVaultManagement.GetAzureKeyVaultSecret(AzureSecret,AzureSecretNameTxt);
        case UpperCase(AzureSecret) of
          'S2SAUTH':
            exit(true);
          'PASSWORDAUTH':
            exit(false);
        end;
    end;

    local procedure RegisterConnectionWithName(ConnectionName: Text;ConnectionString: Text)
    begin
        if '' in [ConnectionName,ConnectionString] then
          exit;

        if not HasTableConnection(TABLECONNECTIONTYPE::MicrosoftGraph,ConnectionName) then
          RegisterTableConnection(TABLECONNECTIONTYPE::MicrosoftGraph,ConnectionName,ConnectionString);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckForceSync(var Force: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetInboundConnectionName(TableID: Integer;var ConnectionName: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetInboundConnectionString(TableID: Integer;var ConnectionString: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetSubscriptionConnectionName(TableID: Integer;var ConnectionName: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetSubscriptionConnectionString(TableID: Integer;var ConnectionString: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetSynchronizeConnectionName(TableID: Integer;var ConnectionName: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetSynchronizeConnectionString(TableID: Integer;var ConnectionString: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRegisterConnections()
    begin
    end;
}

