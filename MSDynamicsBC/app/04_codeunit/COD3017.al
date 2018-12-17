codeunit 3017 DotNet_ExtLicInfoProvider
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        DotNetExtensionLicenseInformationProvider: DotNet ExtensionLicenseInformationProvider;

    procedure ALLicenseCount(ProductId: Text;SkuId: Text;IsvPrefix: Text): Integer
    begin
        // do not make external
        exit(DotNetExtensionLicenseInformationProvider.ALLicenseCount(ProductId,SkuId,IsvPrefix))
    end;

    procedure GetExtensionLicenseInformationProvider(var DotNetExtensionLicenseInformationProvider2: DotNet ExtensionLicenseInformationProvider)
    begin
        DotNetExtensionLicenseInformationProvider2 := DotNetExtensionLicenseInformationProvider
    end;

    procedure SetExtensionLicenseInformationProvider(DotNetExtensionLicenseInformationProvider2: DotNet ExtensionLicenseInformationProvider)
    begin
        DotNetExtensionLicenseInformationProvider := DotNetExtensionLicenseInformationProvider2
    end;
}

