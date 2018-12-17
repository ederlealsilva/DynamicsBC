codeunit 2500 NavExtensionInstallationMgmt
{
    // version NAVW113.00

    Permissions = TableData "NAV App Installed App"=rimd,
                  TableData "NAV App"=rimd;
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        DotNet_NavAppALInstaller: Codeunit DotNet_NavAppALInstaller;
        InstallerHasBeenCreated: Boolean;
        InstalledTxt: Label 'Installed';
        NotInstalledTxt: Label 'Not Installed';
        FullVersionStringTxt: Label '%1.%2.%3.%4', Comment='%1=Version Major, %2=Version Minor, %3=Version build, %4=Version revision';
        NoRevisionVersionStringTxt: Label '%1.%2.%3', Comment='%1=Version Major, %2=Version Minor, %3=Version build';
        NoBuildVersionStringTxt: Label '%1.%2', Comment='%1=Version Major, %2=Version Minor';
        NullGuidTok: Label '00000000-0000-0000-0000-000000000000', Locked=true;
        PermissionErr: Label 'You do not have the required permissions to install the selected app. Contact your Partner or system administrator to install the app or assign you permissions.';

    [Scope('Personalization')]
    procedure IsInstalled(PackageID: Guid): Boolean
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
    begin
        // Check if the user is entitled to make extension changes.
        if (not NAVAppInstalledApp.ReadPermission) or (not NAVAppInstalledApp.WritePermission) then
          Error(PermissionErr);

        NAVAppInstalledApp.SetFilter("Package ID",'%1',PackageID);
        exit(NAVAppInstalledApp.FindFirst);
    end;

    [Scope('Personalization')]
    procedure IsInstalledByAppId(AppID: Guid): Boolean
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
    begin
        // Check if the user is entitled to make extension changes.
        if (not NAVAppInstalledApp.ReadPermission) or (not NAVAppInstalledApp.WritePermission) then
          Error(PermissionErr);

        NAVAppInstalledApp.SetFilter("App ID",'%1',AppID);
        exit(NAVAppInstalledApp.FindFirst);
    end;

    procedure InstallNavExtension(PackageID: Guid;Lcid: Integer)
    begin
        AssertIsInitialized;
        DotNet_NavAppALInstaller.ALInstallNavApp(PackageID,Lcid);
    end;

    [Scope('Personalization')]
    procedure GetExtensionInstalledDisplayString(PackageId: Guid): Text[15]
    begin
        if IsInstalled(PackageId) then
          exit(InstalledTxt);

        exit(NotInstalledTxt);
    end;

    procedure GetDependenciesForExtensionToInstall(PackageID: Guid): Text
    begin
        AssertIsInitialized;
        exit(DotNet_NavAppALInstaller.ALGetAppDependenciesToInstallString(PackageID));
    end;

    procedure GetDependentForExtensionToUninstall(PackageID: Guid): Text
    begin
        AssertIsInitialized;
        exit(DotNet_NavAppALInstaller.ALGetDependentAppsToUninstallString(PackageID));
    end;

    local procedure AssertIsInitialized()
    begin
        if not InstallerHasBeenCreated then begin
          DotNet_NavAppALInstaller.NavAppALInstaller;
          InstallerHasBeenCreated := true;
        end;
    end;

    procedure UninstallNavExtension(PackageID: Guid)
    begin
        AssertIsInitialized;
        DotNet_NavAppALInstaller.ALUninstallNavApp(PackageID);
    end;

    [Scope('Personalization')]
    procedure GetVersionDisplayString(Major: Integer;Minor: Integer;Build: Integer;Revision: Integer): Text
    begin
        if Build <= -1 then
          exit(StrSubstNo(NoBuildVersionStringTxt,Major,Minor));

        if Revision <= -1 then
          exit(StrSubstNo(NoRevisionVersionStringTxt,Major,Minor,Build));

        exit(StrSubstNo(FullVersionStringTxt,Major,Minor,Build,Revision));
    end;

    [Scope('Personalization')]
    procedure GetLatestVersionPackageId(AppId: Guid): Guid
    var
        NavAppTable: Record "NAV App";
        Result: Guid;
    begin
        NavAppTable.SetFilter(ID,'%1',AppId);
        NavAppTable.SetCurrentKey(Name,"Version Major","Version Minor","Version Build","Version Revision");
        NavAppTable.Ascending(false);
        Result := NullGuidTok;
        if NavAppTable.FindFirst then
          Result := NavAppTable."Package ID";

        exit(Result);
    end;

    [Scope('Personalization')]
    procedure IsInstalledNoPermissionCheck(ExtensionName: Text[250]): Boolean
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
    begin
        NAVAppInstalledApp.SetFilter(Name,'%1',ExtensionName);
        exit(NAVAppInstalledApp.FindFirst);
    end;

    procedure UnpublishNavTenantExtension(PackageID: Guid)
    begin
        AssertIsInitialized;
        DotNet_NavAppALInstaller.ALUnpublishNavTenantApp(PackageID);
    end;
}

