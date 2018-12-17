codeunit 6061 "Hybrid Deployment Handler"
{
    // version NAVW113.00

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        DotNet_HybridDeployment: Codeunit DotNet_HybridDeployment;
        SourceProduct: Text;

    local procedure CanHandle(): Boolean
    var
        HybridDeploymentSetup: Record "Hybrid Deployment Setup";
    begin
        if HybridDeploymentSetup.Get then
          exit(HybridDeploymentSetup."Handler Codeunit ID" = CODEUNIT::"Hybrid Deployment Handler");

        exit(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060, 'OnCreateIntegrationRuntime', '', false, false)]
    local procedure HandleCreateIntegrationRuntime(var InstanceId: Text)
    begin
        if not CanHandle then
          exit;

        InstanceId := DotNet_HybridDeployment.CreateIntegrationRuntime(SourceProduct);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060, 'OnDisableReplication', '', false, false)]
    local procedure HandleDisableReplication(var InstanceId: Text)
    begin
        if not CanHandle then
          exit;

        InstanceId := DotNet_HybridDeployment.DisableReplication(SourceProduct);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060, 'OnEnableReplication', '', false, false)]
    local procedure HandleEnableReplication(OnPremiseConnectionString: Text;DatabaseType: Text;IntegrationRuntimeName: Text;NotificationUrl: Text;ClientState: Text;SubscriptionId: Text;var InstanceId: Text)
    begin
        if not CanHandle then
          exit;

        InstanceId :=
          DotNet_HybridDeployment.EnableReplication(
            SourceProduct,OnPremiseConnectionString,DatabaseType,IntegrationRuntimeName,NotificationUrl,ClientState,SubscriptionId);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060, 'OnGetIntegrationRuntimeKeys', '', false, false)]
    local procedure HandleGetIntegrationRuntimeKeys(var InstanceId: Text)
    begin
        if not CanHandle then
          exit;

        InstanceId := DotNet_HybridDeployment.GetIntegrationRuntimeKey(SourceProduct);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060, 'OnGetReplicationRunErrors', '', false, false)]
    local procedure HandleGetReplicationRunErrors(var InstanceId: Text;RunId: Text)
    begin
        if not CanHandle then
          exit;

        InstanceId := DotNet_HybridDeployment.GetReplicationRunErrors(SourceProduct,RunId);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060, 'OnGetRequestStatus', '', false, false)]
    local procedure HandleGetRequestStatus(InstanceId: Text;var JsonOutput: Text;var Status: Text)
    begin
        if not CanHandle then
          exit;

        Status := DotNet_HybridDeployment.GetRequestStatus(InstanceId,JsonOutput);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060, 'OnInitialize', '', false, false)]
    local procedure HandleInitialize(SourceProductId: Text)
    begin
        if not CanHandle then
          exit;

        SourceProduct := SourceProductId;
        DotNet_HybridDeployment.Initialize;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060, 'OnRegenerateIntegrationRuntimeKeys', '', false, false)]
    local procedure HandleRegenerateIntegrationRuntimeKeys(var InstanceId: Text)
    begin
        if not CanHandle then
          exit;

        InstanceId := DotNet_HybridDeployment.RegenerateIntegrationRuntimeKey(SourceProduct);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060, 'OnRunReplication', '', false, false)]
    local procedure HandleRunReplication(var InstanceId: Text)
    begin
        if not CanHandle then
          exit;

        InstanceId := DotNet_HybridDeployment.RunReplication(SourceProduct)
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060, 'OnSetReplicationSchedule', '', false, false)]
    local procedure HandleSetReplicationSchedule(ReplicationFrequency: Text;DaysToRun: Text;TimeToRun: Time;Activate: Boolean;var InstanceId: Text)
    begin
        if not CanHandle then
          exit;

        InstanceId := DotNet_HybridDeployment.SetReplicationSchedule(SourceProduct,ReplicationFrequency,DaysToRun,TimeToRun,Activate);
    end;
}

