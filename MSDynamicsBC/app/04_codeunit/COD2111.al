codeunit 2111 "O365 Sales Background Setup"
{
    // version NAVW113.00

    Permissions = TableData "Marketing Setup"=rimd;

    trigger OnRun()
    begin
        InitializeGraphSync(true,true);
    end;

    var
        GraphSyncCategoryTxt: Label 'AL Graph Sync', Comment='{LOCKED}';
        GraphSyncModifiedTelemetryTxt: Label 'Graph sync has been modified to %1; delta sync triggered: %2.', Comment='{LOCKED}';

    procedure InitializeGraphSync(EnableGraphSync: Boolean;TriggerDeltaSync: Boolean)
    var
        MarketingSetup: Record "Marketing Setup";
        CompanyInformation: Record "Company Information";
        AzureADUserManagement: Codeunit "Azure AD User Management";
        WebhookManagement: Codeunit "Webhook Management";
        GraphSyncRunner: Codeunit "Graph Sync. Runner";
        TenantDetail: DotNet TenantInfo;
    begin
        MarketingSetup.LockTable;
        if not MarketingSetup.Get then
          MarketingSetup.Insert(true);

        if MarketingSetup."Sync with Microsoft Graph" <> EnableGraphSync then begin
          MarketingSetup.Validate("Sync with Microsoft Graph",EnableGraphSync);
          MarketingSetup.Modify(true);
          OnAfterGraphSyncModified(EnableGraphSync,TriggerDeltaSync);
        end;

        if not EnableGraphSync then
          exit;

        if not WebhookManagement.IsCurrentClientTypeAllowed then
          exit;

        if not WebhookManagement.IsSyncAllowed then
          exit;

        if not GraphSyncRunner.IsGraphSyncEnabled then
          exit;

        if TriggerDeltaSync then
          TASKSCHEDULER.CreateTask(CODEUNIT::"Graph Subscription Management",CODEUNIT::"Graph Delta Sync",
            true,CompanyName,CurrentDateTime + 200); // Add 200 ms

        CompanyInformation.Get;
        if CompanyInformation."Sync with O365 Bus. profile" then
          TASKSCHEDULER.CreateTask(CODEUNIT::"Business Profile Sync. Runner",0,true,CompanyName,0DT)
        else
          if AzureADUserManagement.GetTenantDetail(TenantDetail) then begin
            CompanyInformation.LockTable;
            CompanyInformation.Get;

            CompanyInformation.Name := CopyStr(TenantDetail.DisplayName,1,MaxStrLen(CompanyInformation.Name));
            CompanyInformation.Address := CopyStr(TenantDetail.Street,1,MaxStrLen(CompanyInformation.Address));
            CompanyInformation.City := CopyStr(TenantDetail.City,1,MaxStrLen(CompanyInformation.City));
            CompanyInformation."Post Code" := CopyStr(TenantDetail.PostalCode,1,MaxStrLen(CompanyInformation."Post Code"));
            CompanyInformation.County := CopyStr(TenantDetail.State,1,MaxStrLen(CompanyInformation.County));
            CompanyInformation."Country/Region Code" :=
              CopyStr(TenantDetail.CountryLetterCode,1,MaxStrLen(CompanyInformation."Country/Region Code"));
            CompanyInformation.Modify(false);
          end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGraphSyncModified(NewGraphSyncValue: Boolean;TriggerDeltaSync: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 2111, 'OnAfterGraphSyncModified', '', true, true)]
    local procedure LogGraphSyncSubscriber(NewGraphSyncValue: Boolean;TriggerDeltaSync: Boolean)
    begin
        SendTraceTag('00001IJ',GraphSyncCategoryTxt,VERBOSITY::Normal,
          StrSubstNo(GraphSyncModifiedTelemetryTxt,NewGraphSyncValue,TriggerDeltaSync),DATACLASSIFICATION::SystemMetadata);
    end;
}

