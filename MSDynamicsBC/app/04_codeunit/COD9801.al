codeunit 9801 "Identity Management"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        TenantManagementHelper: Codeunit "Tenant Management";
        UserAccountHelper: DotNet NavUserAccountHelper;
        NavTok: Label 'NAV', Locked=true;
        InvoiceTok: Label 'INV', Locked=true;
        FinancialsTok: Label 'FIN', Locked=true;
        C5Tok: Label 'C5', Locked=true;

    procedure SetAuthenticationKey(UserSecurityID: Guid;"Key": Text[80])
    begin
        if not UserAccountHelper.TrySetAuthenticationKey(UserSecurityID,Key) then
          Error(GetLastErrorText);
    end;

    procedure GetAuthenticationKey(UserSecurityID: Guid) "Key": Text[80]
    begin
        if not UserAccountHelper.TryGetAuthenticationKey(UserSecurityID,Key) then
          Key := Format(GetLastErrorText,80);
    end;

    procedure GetNameIdentifier(UserSecurityID: Guid) NameID: Text[250]
    begin
        if not UserAccountHelper.TryGetNameIdentifier(UserSecurityID,NameID) then
          NameID := Format(GetLastErrorText,250);
    end;

    procedure GetObjectId(UserSecurityID: Guid) ObjectID: Text[250]
    begin
        if not UserAccountHelper.TryGetAuthenticationObjectId(UserSecurityID,ObjectID) then
          ObjectID := Format(GetLastErrorText,250);
    end;

    procedure CreateWebServicesKey(UserSecurityID: Guid;ExpiryDate: DateTime) "Key": Text[80]
    begin
        if not UserAccountHelper.TryCreateWebServicesKey(UserSecurityID,ExpiryDate,Key) then
          Error(GetLastErrorText);
    end;

    procedure GetPuid(): Text
    begin
        exit(UserAccountHelper.GetPuid);
    end;

    procedure CreateWebServicesKeyNoExpiry(UserSecurityID: Guid) "Key": Text[80]
    var
        ExpiryDate: DateTime;
    begin
        if not UserAccountHelper.TryCreateWebServicesKey(UserSecurityID,ExpiryDate,Key) then
          Error(GetLastErrorText);
    end;

    procedure ClearWebServicesKey(UserSecurityID: Guid)
    begin
        if not UserAccountHelper.TryClearWebServicesKey(UserSecurityID) then
          Error(GetLastErrorText);
    end;

    procedure GetWebServicesKey(UserSecurityID: Guid) "Key": Text[80]
    var
        ExpiryDate: DateTime;
    begin
        if not UserAccountHelper.TryGetWebServicesKey(UserSecurityID,Key,ExpiryDate) then
          Key := Format(GetLastErrorText,80);
    end;

    procedure IsAzure() Ok: Boolean
    begin
        Ok := UserAccountHelper.IsAzure;
    end;

    procedure GetWebServiceExpiryDate(UserSecurityID: Guid) ExpiryDate: DateTime
    var
        "Key": Text[80];
    begin
        if not UserAccountHelper.TryGetWebServicesKey(UserSecurityID,Key,ExpiryDate) then
          ExpiryDate := CurrentDateTime;
    end;

    procedure GetACSStatus(UserSecurityID: Guid) ACSStatus: Integer
    var
        ACSStatusOption: Option Disabled,Pending,Registered,Unknown;
        "Key": Text[80];
        NameID: Text[250];
    begin
        // Determines the status as follows:
        // If neither Nameidentifier, nor authentication key then Disabled
        // If authentiation key then Pending
        // If NameIdentifier then Registered
        // If no permission: Unknown

        if not UserAccountHelper.TryGetAuthenticationKey(UserSecurityID,Key) then begin
          ACSStatusOption := ACSStatusOption::Unknown;
          ACSStatus := ACSStatusOption;
          exit;
        end;

        if not UserAccountHelper.TryGetNameIdentifier(UserSecurityID,NameID) then begin
          ACSStatusOption := ACSStatusOption::Unknown;
          ACSStatus := ACSStatusOption;
          exit;
        end;

        if NameID = '' then begin
          if Key = '' then
            ACSStatusOption := ACSStatusOption::Disabled
          else
            ACSStatusOption := ACSStatusOption::Pending;
        end else
          ACSStatusOption := ACSStatusOption::Registered;

        ACSStatus := ACSStatusOption;
    end;

    local procedure ValidateKeyStrength("Key": Text[250]): Boolean
    var
        i: Integer;
        KeyLen: Integer;
        HasUpper: Boolean;
        HasLower: Boolean;
        HasNumeric: Boolean;
    begin
        KeyLen := StrLen(Key);

        if KeyLen < 8 then
          exit(false);

        for i := 1 to StrLen(Key) do begin
          case Key[i] of
            'A'..'Z':
              HasUpper := true;
            'a'..'z':
              HasLower := true;
            '0'..'9':
              HasNumeric := true;
          end;

          if HasUpper and HasLower and HasNumeric then
            exit(true);
        end;

        exit(false);
    end;

    [Scope('Personalization')]
    procedure ValidatePasswordStrength(Password: Text[250]) IsValid: Boolean
    begin
        IsValid := ValidateKeyStrength(Password);
    end;

    [Scope('Personalization')]
    procedure ValidateAuthKeyStrength(AuthKey: Text[250]) IsValid: Boolean
    begin
        IsValid := ValidateKeyStrength(AuthKey);
    end;

    procedure GetMaskedNavPassword(UserSecurityID: Guid) MaskedPassword: Text[80]
    begin
        if UserAccountHelper.IsPasswordSet(UserSecurityID) then
          MaskedPassword := '********'
        else
          MaskedPassword := '';
    end;

    procedure IsWindowsAuthentication() Ok: Boolean
    begin
        Ok := UserAccountHelper.IsWindowsAuthentication;
    end;

    procedure IsUserNamePasswordAuthentication() Ok: Boolean
    begin
        Ok := UserAccountHelper.IsUserNamePasswordAuthentication;
    end;

    procedure IsAccessControlServiceAuthentication() Ok: Boolean
    begin
        Ok := UserAccountHelper.IsAccessControlServiceAuthentication;
    end;

    procedure UserName(Sid: Text): Text[208]
    begin
        if Sid = '' then
          exit('');

        exit(UserAccountHelper.UserName(Sid));
    end;

    procedure SetAuthenticationEmail(UserSecurityId: Guid;AuthenticationEmail: Text[250])
    begin
        ClearLastError;
        if not UserAccountHelper.TrySetAuthenticationEmail(UserSecurityId,AuthenticationEmail) then
          Error(GetLastErrorText);
    end;

    procedure GetAuthenticationStatus(UserSecurityId: Guid) O365AuthStatus: Integer
    begin
        O365AuthStatus := UserAccountHelper.GetAuthenticationStatus(UserSecurityId);
    end;

    [Scope('Personalization')]
    procedure GetAadTenantId(): Text
    begin
        exit(TenantManagementHelper.GetAadTenantId);
    end;

    [Scope('Personalization')]
    procedure IsInvAppId(): Boolean
    var
        AppId: Text;
    begin
        AppId := ApplicationIdentifier;
        OnBeforeGetApplicationIdentifier(AppId);
        exit(AppId = InvoiceTok);
    end;

    [Scope('Personalization')]
    procedure IsFinAppId(): Boolean
    var
        AppId: Text;
    begin
        AppId := ApplicationIdentifier;
        OnBeforeGetApplicationIdentifier(AppId);
        exit(AppId = FinancialsTok);
    end;

    [Scope('Personalization')]
    procedure IsNavAppId(): Boolean
    var
        AppId: Text;
    begin
        AppId := ApplicationIdentifier;
        OnBeforeGetApplicationIdentifier(AppId);
        exit(AppId = NavTok);
    end;

    [Scope('Personalization')]
    procedure IsC5AppId(): Boolean
    var
        AppId: Text;
    begin
        AppId := ApplicationIdentifier;
        OnBeforeGetApplicationIdentifier(AppId);
        exit(AppId = C5Tok);
    end;

    [IntegrationEvent(false, false)]
    [Scope('Personalization')]
    procedure OnBeforeGetApplicationIdentifier(var AppId: Text)
    begin
    end;
}

