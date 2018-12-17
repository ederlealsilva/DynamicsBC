codeunit 417 "Tenant Management"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        NavTenantSettingsHelper: DotNet NavTenantSettingsHelper;
        DISPLAYNAMEKEYTxt: Label 'DISPLAYNAME', Locked=true;
        AADTENANTIDKEYTxt: Label 'AADTENANTID', Locked=true;
        TENANTIDKEYTxt: Label 'TENANTID', Locked=true;
        ENVIRONMENTNAMESANDBOXTxt: Label 'Sandbox', Locked=true;
        ENVIRONMENTNAMEPRODUCTIONTxt: Label 'Production', Locked=true;
        AAD_TENANT_DOMAIN_NAME_FAILUTRE_Err: Label 'Failed to retrieve the Azure Active Directory tenant domain name.';

    [Scope('Personalization')]
    procedure GetTenantId() TenatIdValue: Text
    begin
        NavTenantSettingsHelper.TryGetStringTenantSetting(TENANTIDKEYTxt,TenatIdValue);
    end;

    [Scope('Personalization')]
    procedure GetAadTenantId() TenantAadIdValue: Text
    begin
        NavTenantSettingsHelper.TryGetStringTenantSetting(AADTENANTIDKEYTxt,TenantAadIdValue);
    end;

    [Scope('Personalization')]
    procedure GetTenantDisplayName() TenantNameValue: Text
    begin
        NavTenantSettingsHelper.TryGetStringTenantSetting(DISPLAYNAMEKEYTxt,TenantNameValue);
    end;

    [Scope('Personalization')]
    procedure IsSandbox(): Boolean
    begin
        exit(NavTenantSettingsHelper.IsSandbox())
    end;

    [Scope('Personalization')]
    procedure IsProduction(): Boolean
    begin
        exit(NavTenantSettingsHelper.IsProduction())
    end;

    [Scope('Personalization')]
    procedure GetPlatformVersion(): Text
    begin
        exit(NavTenantSettingsHelper.GetPlatformVersion().ToString())
    end;

    [Scope('Personalization')]
    procedure GetApplicationFamily(): Text
    begin
        exit(NavTenantSettingsHelper.GetApplicationFamily())
    end;

    [Scope('Personalization')]
    procedure GetApplicationVersion(): Text
    begin
        exit(NavTenantSettingsHelper.GetApplicationVersion())
    end;

    [Scope('Personalization')]
    procedure GetEnvironmentName(): Text
    begin
        if IsProduction then
          exit(ENVIRONMENTNAMEPRODUCTIONTxt);
        exit(ENVIRONMENTNAMESANDBOXTxt);
    end;

    [Scope('Personalization')]
    procedure GetAadTenantDomainName(): Text
    var
        AzureADUserManagement: Codeunit "Azure AD User Management";
        TenantInfo: DotNet TenantInfo;
    begin
        if AzureADUserManagement.GetTenantDetail(TenantInfo) then
          exit(TenantInfo.InitialDomain);
        Error(AAD_TENANT_DOMAIN_NAME_FAILUTRE_Err);
    end;
}

