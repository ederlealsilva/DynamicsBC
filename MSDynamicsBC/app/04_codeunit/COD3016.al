codeunit 3016 DotNet_NavAppALInstaller
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        DotNetNavAppALInstaller: DotNet NavAppALInstaller;

    procedure NavAppALInstaller()
    begin
        // do not make external
        DotNetNavAppALInstaller := DotNetNavAppALInstaller.NavAppALInstaller
    end;

    procedure ALInstallNavApp(PackageID: Guid;Lcid: Integer)
    begin
        // do not make external
        DotNetNavAppALInstaller.ALInstallNavApp(PackageID,Lcid)
    end;

    procedure ALGetAppDependenciesToInstallString(PackageID: Text): Text
    begin
        // do not make external
        exit(DotNetNavAppALInstaller.ALGetAppDependenciesToInstallString(PackageID))
    end;

    procedure ALGetDependentAppsToUninstallString(PackageID: Guid): Text
    begin
        // do not make external
        exit(DotNetNavAppALInstaller.ALGetDependentAppsToUninstallString(PackageID))
    end;

    procedure ALUninstallNavApp(PackageID: Guid)
    begin
        // do not make external
        DotNetNavAppALInstaller.ALUninstallNavApp(PackageID)
    end;

    procedure ALUnpublishNavTenantApp(PackageID: Guid)
    begin
        // do not make external
        DotNetNavAppALInstaller.ALUnpublishNavTenantApp(PackageID)
    end;

    procedure GetNavAppALInstaller(var DotNetNavAppALInstaller2: DotNet NavAppALInstaller)
    begin
        DotNetNavAppALInstaller2 := DotNetNavAppALInstaller;
    end;

    procedure SetNavAppALInstaller(DotNetNavAppALInstaller2: DotNet NavAppALInstaller)
    begin
        DotNetNavAppALInstaller := DotNetNavAppALInstaller2
    end;
}

