codeunit 2503 NavExtensionOperationMgmt
{
    // version NAVW113.00

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        DotNet_ALAppOperationInvoker: Codeunit DotNet_ALAppOperationInvoker;
        OperationInvokerHasBeenCreated: Boolean;

    procedure DeployNavExtension(AppId: Guid;Lcid: Integer)
    begin
        OperationInvokerIsInitialized;
        DotNet_ALAppOperationInvoker.DeployTarget(AppId,Format(Lcid));
    end;

    procedure UploadNavExtension(PackageStream: InStream;DotNet_ALPacDeploymentSchedule: Codeunit DotNet_ALPacDeploymentSchedule;Lcid: Integer)
    begin
        OperationInvokerIsInitialized;
        DotNet_ALAppOperationInvoker.UploadPackage(PackageStream,DotNet_ALPacDeploymentSchedule,Format(Lcid));
    end;

    procedure RefreshStatus(OperationID: Guid)
    begin
        OperationInvokerIsInitialized;
        DotNet_ALAppOperationInvoker.RefreshOperationStatus(OperationID);
    end;

    local procedure OperationInvokerIsInitialized()
    begin
        if not OperationInvokerHasBeenCreated then begin
          DotNet_ALAppOperationInvoker.ALNavAppOperationInvoker;
          OperationInvokerHasBeenCreated := true;
        end;
    end;

    procedure GetDeploymentDetailedStatusMessageAsStream(OperationId: Guid;OutStream: OutStream)
    begin
        OperationInvokerIsInitialized;
        DotNet_ALAppOperationInvoker.GetOperationDetailedStatusMessageAsStream(OperationId,OutStream);
    end;

    procedure GetDeploymentDetailedStatusMessage(OperationId: Guid): Text
    begin
        OperationInvokerIsInitialized;
        exit(DotNet_ALAppOperationInvoker.GetOperationDetailedStatusMessage(OperationId));
    end;

    procedure GetDeployOperationAppName(OperationId: Guid): Text
    begin
        OperationInvokerIsInitialized;
        exit(DotNet_ALAppOperationInvoker.GetDeployOperationAppName(OperationId));
    end;

    procedure GetDeployOperationAppPublisher(OperationId: Guid): Text
    begin
        OperationInvokerIsInitialized;
        exit(DotNet_ALAppOperationInvoker.GetDeployOperationAppPublisher(OperationId));
    end;

    procedure GetDeployOperationAppVersion(OperationId: Guid): Text
    begin
        OperationInvokerIsInitialized;
        exit(DotNet_ALAppOperationInvoker.GetDeployOperationAppVersion(OperationId));
    end;

    procedure GetDeployOperationSchedule(OperationId: Guid): Text
    begin
        OperationInvokerIsInitialized;
        exit(DotNet_ALAppOperationInvoker.GetDeployOperationSchedule(OperationId));
    end;

    procedure GetDeployOperationJobId(OperationId: Guid): Text
    begin
        OperationInvokerIsInitialized;
        exit(DotNet_ALAppOperationInvoker.GetDeployOperationJobId(OperationId));
    end;
}

