codeunit 3019 DotNet_ALPacDeploymentSchedule
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        DotNetALPackageDeploymentSchedule: DotNet ALPackageDeploymentSchedule;

    procedure Immediate()
    begin
        // do not make external
        DotNetALPackageDeploymentSchedule := DotNetALPackageDeploymentSchedule.Immediate
    end;

    procedure StageForNextMajorUpdate()
    begin
        // do not make external
        DotNetALPackageDeploymentSchedule := DotNetALPackageDeploymentSchedule.StageForNextUpdate
    end;

    procedure StageForNextMinorUpdate()
    begin
        // do not make external
        DotNetALPackageDeploymentSchedule := DotNetALPackageDeploymentSchedule.StageForNextMinorUpdate
    end;

    procedure GetALPackageDeploymentSchedule(var DotNetALPackageDeploymentSchedule2: DotNet ALPackageDeploymentSchedule)
    begin
        DotNetALPackageDeploymentSchedule2 := DotNetALPackageDeploymentSchedule
    end;

    procedure SetALPackageDeploymentSchedule(DotNetALPackageDeploymentSchedule2: DotNet ALPackageDeploymentSchedule)
    begin
        DotNetALPackageDeploymentSchedule := DotNetALPackageDeploymentSchedule2
    end;
}

