codeunit 9015 "Application System Constants"
{
    // version NAVW113.00

    // Be careful when updating this file that all labels are marked something like "!Build ...!"
    // We populate these during the build process and they should not be exported containing actual details.


    trigger OnRun()
    begin
    end;

    [Scope('Personalization')]
    procedure ApplicationVersion() ApplicationVersion: Text[248]
    begin
        // Should be 'Build Version' with ! on both sides.
        ApplicationVersion := 'W1 13.0';
        OnAfterGetApplicationVersion(ApplicationVersion);
    end;

    [Scope('Personalization')]
    procedure ReleaseVersion(): Text[50]
    begin
        // Should be 'Build Release Version' with ! on both sides.
        exit('2.0.0');
    end;

    [Scope('Personalization')]
    procedure ApplicationBuild(): Text[80]
    begin
        // Should be 'Build Number' with ! on both sides.
        exit('24630');
    end;

    procedure BuildBranch(): Text[250]
    begin
        // Should be 'Build branch' with ! on both sides.
        exit('D365F019');
    end;

    [EventSubscriber(ObjectType::Codeunit, 2000000001, 'GetApplicationVersion', '', false, false)]
    local procedure GetApplicationVersion(var Version: Text[248])
    begin
        Version := ApplicationVersion;
    end;

    [EventSubscriber(ObjectType::Codeunit, 2000000001, 'GetReleaseVersion', '', false, false)]
    local procedure GetReleaseVersion(var Version: Text[50])
    begin
        Version := ReleaseVersion
    end;

    [EventSubscriber(ObjectType::Codeunit, 2000000001, 'GetApplicationBuild', '', false, false)]
    local procedure GetApplicationBuild(var Build: Text[80])
    begin
        // Must ever only be the build number of the server building the app.
        Build := ApplicationBuild
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetApplicationVersion(var ApplicationVersion: Text[248])
    begin
    end;
}

