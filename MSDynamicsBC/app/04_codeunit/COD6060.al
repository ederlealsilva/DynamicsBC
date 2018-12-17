codeunit 6060 "Hybrid Deployment"
{
    // version NAVW113.00

    Permissions = TableData "Hybrid Deployment Setup"=rimd,
                  TableData "Intelligent Cloud"=rimd,
                  TableData "Intelligent Cloud Status"=rimd,
                  TableData "Webhook Subscription"=rimd;

    trigger OnRun()
    begin
    end;

    var
        SourceProduct: Text;
        FailedCreatingIRErr: Label 'Failed to create your integration runtime.';
        FailedDisableReplicationErr: Label 'Failed to disable replication.';
        FailedEnableReplicationErr: Label 'Failed to enable your replication.\\Make sure your integration runtime is successfully connected and try again.';
        FailedGettingErrorsErr: Label 'Failed to retrieve the replication run errors.';
        FailedGettingIRKeyErr: Label 'Failed to get your integration runtime key. Please try again.';
        FailedRegeneratingIRKeyErr: Label 'Failed to regenerate your integration runtime key. Please try again.';
        FailedRunReplicationErr: Label 'Failed to trigger replication. Please try again.';
        FailedSetRepScheduleErr: Label 'Failed to set the replication schedule. Please try again.';
        CompletedTxt: Label 'Completed', Locked=true;
        FailedTxt: Label 'Failed', Locked=true;

    procedure Initialize(SourceProductId: Text)
    begin
        SourceProduct := SourceProductId;
        OnInitialize(SourceProductId);
    end;

    procedure CreateIntegrationRuntime(var RuntimeName: Text;var PrimaryKey: Text)
    var
        JSONManagement: Codeunit "JSON Management";
        InstanceId: Text;
        JsonOutput: Text;
    begin
        if not TryCreateIntegrationRuntime(InstanceId) then
          Error(FailedCreatingIRErr);

        if RetryGetStatus(InstanceId,JsonOutput) = FailedTxt then
          Error(FailedCreatingIRErr);

        JSONManagement.InitializeObject(JsonOutput);
        JSONManagement.GetStringPropertyValueByName('Name',RuntimeName);
        JSONManagement.GetStringPropertyValueByName('PrimaryKey',PrimaryKey);
    end;

    procedure DisableReplication()
    var
        InstanceId: Text;
        Output: Text;
    begin
        if not TryDisableReplication(InstanceId) then
          Error(FailedDisableReplicationErr);

        if RetryGetStatus(InstanceId,Output) = FailedTxt then
          Error(FailedDisableReplicationErr);

        EnableIntelligentCloud(false);
    end;

    procedure EnableReplication(OnPremConnectionString: Text;DatabaseConfiguration: Text;IntegrationRuntimeName: Text)
    var
        PermissionManager: Codeunit "Permission Manager";
        NotificationUrl: Text;
        SubscriptionId: Text[150];
        ClientState: Text[50];
        InstanceId: Text;
        Output: Text;
    begin
        OnBeforeEnableReplication(SourceProduct,NotificationUrl,SubscriptionId,ClientState);

        if not TryEnableReplication(
             InstanceId,OnPremConnectionString,DatabaseConfiguration,IntegrationRuntimeName,NotificationUrl,ClientState,SubscriptionId)
        then
          Error(FailedEnableReplicationErr);

        if RetryGetStatus(InstanceId,Output) = FailedTxt then
          Error(FailedEnableReplicationErr);

        EnableIntelligentCloud(true);
        PermissionManager.ResetUsersToIntelligentCloudUserGroup;
    end;

    procedure GetIntegrationRuntimeKeys(var PrimaryKey: Text;var SecondaryKey: Text)
    var
        JSONManagement: Codeunit "JSON Management";
        InstanceId: Text;
        JsonOutput: Text;
    begin
        if not TryGetIntegrationRuntimeKeys(InstanceId) then
          Error(FailedGettingIRKeyErr);

        if RetryGetStatus(InstanceId,JsonOutput) = FailedTxt then
          Error(FailedGettingIRKeyErr);

        JSONManagement.InitializeObject(JsonOutput);
        JSONManagement.GetStringPropertyValueByName('PrimaryKey',PrimaryKey);
        JSONManagement.GetStringPropertyValueByName('SecondaryKey',SecondaryKey);
    end;

    procedure GetReplicationRunErrors(RunId: Text;var Errors: Text)
    var
        JSONManagement: Codeunit "JSON Management";
        InstanceId: Text;
        JsonOutput: Text;
    begin
        if not TryGetReplicationRunErrors(InstanceId,RunId) then
          Error(FailedGettingErrorsErr);

        if RetryGetStatus(InstanceId,JsonOutput) = FailedTxt then
          Error(FailedGettingErrorsErr);

        JSONManagement.InitializeObject(JsonOutput);
        JSONManagement.GetStringPropertyValueByName('Errors',Errors);
        JSONManagement.InitializeObject(Errors);
        JSONManagement.GetArrayPropertyValueAsStringByName('$values',Errors);
        JSONManagement.InitializeCollection(Errors);
        if JSONManagement.GetCollectionCount = 1 then
          JSONManagement.GetObjectFromCollectionByIndex(Errors,0)
    end;

    procedure GetRequestStatus(RequestTrackingId: Text;var JsonOutput: Text) Status: Text
    begin
        OnGetRequestStatus(RequestTrackingId,JsonOutput,Status);
    end;

    procedure RegenerateIntegrationRuntimeKeys(var PrimaryKey: Text;var SecondaryKey: Text)
    var
        JSONManagement: Codeunit "JSON Management";
        InstanceId: Text;
        JsonOutput: Text;
    begin
        if not TryRegenerateIntegrationRuntimeKeys(InstanceId) then
          Error(FailedRegeneratingIRKeyErr);

        if RetryGetStatus(InstanceId,JsonOutput) = FailedTxt then
          Error(FailedRegeneratingIRKeyErr);

        JSONManagement.InitializeObject(JsonOutput);
        JSONManagement.GetStringPropertyValueByName('PrimaryKey',PrimaryKey);
        JSONManagement.GetStringPropertyValueByName('SecondaryKey',SecondaryKey);
    end;

    procedure ResetCloudData()
    var
        IntelligentCloudStatus: Record "Intelligent Cloud Status";
    begin
        IntelligentCloudStatus.ModifyAll("Synced Version",0);
        Commit;
    end;

    procedure RunReplication(var RunId: Text)
    var
        JSONManagement: Codeunit "JSON Management";
        InstanceId: Text;
        JsonOutput: Text;
    begin
        if not TryRunReplication(InstanceId) then
          Error(FailedRunReplicationErr);

        if RetryGetStatus(InstanceId,JsonOutput) = FailedTxt then
          Error(FailedRunReplicationErr);

        JSONManagement.InitializeObject(JsonOutput);
        JSONManagement.GetStringPropertyValueByName('RunId',RunId);
    end;

    procedure SetReplicationSchedule(ReplicationFrequency: Text;DaysToRun: Text;TimeToRun: Time;Activate: Boolean)
    var
        InstanceId: Text;
        Output: Text;
    begin
        if not TrySetReplicationSchedule(InstanceId,ReplicationFrequency,DaysToRun,TimeToRun,Activate) then
          Error(FailedSetRepScheduleErr);

        if RetryGetStatus(InstanceId,Output) = FailedTxt then
          Error(FailedSetRepScheduleErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, 2, 'OnCompanyInitialize', '', false, false)]
    local procedure HandleCompanyInit()
    var
        HybridDeploymentSetup: Record "Hybrid Deployment Setup";
    begin
        if not HybridDeploymentSetup.IsEmpty then
          exit;

        HybridDeploymentSetup.Init;
        HybridDeploymentSetup.Insert;
    end;

    local procedure EnableIntelligentCloud(Enabled: Boolean)
    var
        IntelligentCloud: Record "Intelligent Cloud";
    begin
        if not IntelligentCloud.Get then begin
          IntelligentCloud.Init;
          IntelligentCloud.Enabled := Enabled;
          IntelligentCloud.Insert;
        end else begin
          IntelligentCloud.Enabled := Enabled;
          IntelligentCloud.Modify;
        end;
    end;

    local procedure RetryGetStatus(InstanceId: Text;var JsonOutput: Text) Status: Text
    begin
        if InstanceId = '' then
          exit;

        repeat
          Sleep(1000);
          Status := GetRequestStatus(InstanceId,JsonOutput);
        until ((Status = CompletedTxt) or (Status = FailedTxt));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateIntegrationRuntime(var InstanceId: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDisableReplication(var InstanceId: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeEnableReplication(ProductId: Text;var NotificationUrl: Text;var SubscriptionId: Text[150];var ClientState: Text[50])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnEnableReplication(OnPremiseConnectionString: Text;DatabaseType: Text;IntegrationRuntimeName: Text;NotificationUrl: Text;ClientState: Text;SubscriptionId: Text;var InstanceId: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetIntegrationRuntimeKeys(var InstanceId: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetReplicationRunErrors(var InstanceId: Text;RunId: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetRequestStatus(InstanceId: Text;var JsonOutput: Text;var Status: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitialize(SourceProductId: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRegenerateIntegrationRuntimeKeys(var InstanceId: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunReplication(var InstanceId: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetReplicationSchedule(ReplicationFrequency: Text;DaysToRun: Text;TimeToRun: Time;Activate: Boolean;var InstanceId: Text)
    begin
    end;

    [TryFunction]
    local procedure TryCreateIntegrationRuntime(var InstanceId: Text)
    begin
        OnCreateIntegrationRuntime(InstanceId);
    end;

    [TryFunction]
    local procedure TryDisableReplication(var InstanceId: Text)
    begin
        OnDisableReplication(InstanceId);
    end;

    [TryFunction]
    local procedure TryEnableReplication(var InstanceId: Text;OnPremConnectionString: Text;DatabaseConfiguration: Text;IntegrationRuntimeName: Text;NotificationUrl: Text;ClientState: Text;SubscriptionId: Text)
    begin
        OnEnableReplication(
          OnPremConnectionString,DatabaseConfiguration,IntegrationRuntimeName,NotificationUrl,ClientState,SubscriptionId,InstanceId);
    end;

    [TryFunction]
    local procedure TryGetIntegrationRuntimeKeys(var InstanceId: Text)
    begin
        OnGetIntegrationRuntimeKeys(InstanceId);
    end;

    [TryFunction]
    local procedure TryGetReplicationRunErrors(var InstanceId: Text;RunId: Text)
    begin
        OnGetReplicationRunErrors(InstanceId,RunId);
    end;

    [TryFunction]
    local procedure TryRegenerateIntegrationRuntimeKeys(var InstanceId: Text)
    begin
        OnRegenerateIntegrationRuntimeKeys(InstanceId);
    end;

    [TryFunction]
    local procedure TryRunReplication(var InstanceId: Text)
    begin
        OnRunReplication(InstanceId);
    end;

    [TryFunction]
    local procedure TrySetReplicationSchedule(var InstanceId: Text;ReplicationFrequency: Text;DaysToRun: Text;TimeToRun: Time;Activate: Boolean)
    begin
        OnSetReplicationSchedule(ReplicationFrequency,DaysToRun,TimeToRun,Activate,InstanceId);
    end;
}

