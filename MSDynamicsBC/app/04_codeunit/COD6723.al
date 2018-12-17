codeunit 6723 "Server Config. Setting Handler"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        ALConfigSettings: DotNet ALConfigSettings;

    local procedure InitializeConfigSettings()
    begin
        ALConfigSettings := ALConfigSettings.Instance;
    end;

    procedure GetEnableSaaSExtensionInstallSetting(): Boolean
    var
        EnableSaaSExtensionInstall: Boolean;
    begin
        InitializeConfigSettings;
        EnableSaaSExtensionInstall := ALConfigSettings.EnableSaasExtensionInstallConfigSetting;
        exit(EnableSaaSExtensionInstall);
    end;

    procedure GetIsSaasExcelAddinEnabled(): Boolean
    var
        SaasExcelAddinEnabled: Boolean;
    begin
        InitializeConfigSettings;
        SaasExcelAddinEnabled := ALConfigSettings.IsSaasExcelAddinEnabled;
        exit(SaasExcelAddinEnabled);
    end;

    procedure GetApiServicesEnabled() ApiEnabled: Boolean
    begin
        InitializeConfigSettings;
        ApiEnabled := ALConfigSettings.ApiServicesEnabled;
        exit(ApiEnabled);
    end;
}

