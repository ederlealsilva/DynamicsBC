codeunit 4 ClientTypeManagement
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    [Scope('Personalization')]
    procedure GetCurrentClientType() CurrClientType: ClientType
    begin
        CurrClientType := CurrentClientType;
        OnAfterGetCurrentClientType(CurrClientType);
    end;

    [Scope('Personalization')]
    procedure IsClientType(ExpectedClientType: ClientType): Boolean
    begin
        exit(ExpectedClientType = GetCurrentClientType);
    end;

    [Scope('Personalization')]
    procedure IsCommonWebClientType(): Boolean
    begin
        exit(GetCurrentClientType in [CLIENTTYPE::Web,CLIENTTYPE::Tablet,CLIENTTYPE::Phone,CLIENTTYPE::Desktop]);
    end;

    [Scope('Personalization')]
    procedure IsWindowsClientType(): Boolean
    begin
        exit(IsClientType(CLIENTTYPE::Windows));
    end;

    [Scope('Personalization')]
    procedure IsDeviceClientType(): Boolean
    begin
        exit(GetCurrentClientType in [CLIENTTYPE::Tablet,CLIENTTYPE::Phone]);
    end;

    [Scope('Personalization')]
    procedure IsPhoneClientType(): Boolean
    begin
        exit(IsClientType(CLIENTTYPE::Phone));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetCurrentClientType(var CurrClientType: ClientType)
    begin
    end;
}

