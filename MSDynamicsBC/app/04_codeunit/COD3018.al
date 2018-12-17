codeunit 3018 DotNet_ALAppOperationInvoker
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        DotNetALNavAppOperationInvoker: DotNet ALNavAppOperationInvoker;

    procedure ALNavAppOperationInvoker()
    begin
        // do not make external
        DotNetALNavAppOperationInvoker := DotNetALNavAppOperationInvoker.ALNavAppOperationInvoker
    end;

    procedure DeployTarget(AppId: Guid;Lcid: Text)
    begin
        // do not make external
        DotNetALNavAppOperationInvoker.DeployTarget(AppId,Lcid)
    end;

    procedure UploadPackage(PackageStream: InStream;DotNet_ALPacDeploymentSchedule: Codeunit DotNet_ALPacDeploymentSchedule;Lcid: Text)
    var
        DotNetALPackageDeploymentSchedule: DotNet ALPackageDeploymentSchedule;
    begin
        // do not make external
        DotNet_ALPacDeploymentSchedule.GetALPackageDeploymentSchedule(DotNetALPackageDeploymentSchedule);
        DotNetALNavAppOperationInvoker.UploadPackage(PackageStream,DotNetALPackageDeploymentSchedule,Lcid)
    end;

    procedure RefreshOperationStatus(OperationID: Guid)
    begin
        // do not make external
        DotNetALNavAppOperationInvoker.RefreshOperationStatus(OperationID)
    end;

    procedure GetOperationDetailedStatusMessageAsStream(operationId: Guid;var OutStream: OutStream)
    begin
        // do not make external
        DotNetALNavAppOperationInvoker.GetOperationDetailedStatusMessageAsStream(operationId,OutStream)
    end;

    procedure GetOperationDetailedStatusMessage(operationId: Guid): Text
    begin
        // do not make external
        exit(DotNetALNavAppOperationInvoker.GetOperationDetailedStatusMessage(operationId))
    end;

    procedure GetDeployOperationAppName(OperationId: Guid): Text
    begin
        // do not make external
        exit(DotNetALNavAppOperationInvoker.GetDeployOperationAppName(OperationId));
    end;

    procedure GetDeployOperationAppPublisher(OperationId: Guid): Text
    begin
        // do not make external
        exit(DotNetALNavAppOperationInvoker.GetDeployOperationAppPublisher(OperationId));
    end;

    procedure GetDeployOperationAppVersion(OperationId: Guid): Text
    begin
        // do not make external
        exit(DotNetALNavAppOperationInvoker.GetDeployOperationAppVersion(OperationId));
    end;

    procedure GetDeployOperationSchedule(OperationId: Guid): Text
    begin
        // do not make external
        exit(DotNetALNavAppOperationInvoker.GetDeployOperationSchedule(OperationId));
    end;

    procedure GetDeployOperationJobId(OperationId: Guid): Text
    begin
        // do not make external
        exit(DotNetALNavAppOperationInvoker.GetDeployOperationJobId(OperationId));
    end;

    procedure GetALNavAppOperationInvoker(var DotNetALNavAppOperationInvoker2: DotNet ALNavAppOperationInvoker)
    begin
        DotNetALNavAppOperationInvoker2 := DotNetALNavAppOperationInvoker
    end;

    procedure SetALNavAppOperationInvoker(DotNetALNavAppOperationInvoker2: DotNet ALNavAppOperationInvoker)
    begin
        DotNetALNavAppOperationInvoker := DotNetALNavAppOperationInvoker2
    end;
}

