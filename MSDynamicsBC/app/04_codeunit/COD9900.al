codeunit 9900 "Data Upgrade Mgt."
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        DataUpgradeInProgress: Codeunit "Data Upgrade In Progress";

    [Scope('Personalization')]
    procedure SetTableSyncSetup(TableId: Integer;UpgradeTableId: Integer;TableUpgradeMode: Option Check,Copy,Move,Force)
    var
        TableSynchSetup: Record "Table Synch. Setup";
    begin
        if TableSynchSetup.Get(TableId) then begin
          TableSynchSetup."Upgrade Table ID" := UpgradeTableId;
          TableSynchSetup.Mode := TableUpgradeMode;
          TableSynchSetup.Modify;
        end;
    end;

    [Scope('Personalization')]
    procedure SetUpgradeInProgress()
    begin
        BindSubscription(DataUpgradeInProgress);
    end;

    [Scope('Personalization')]
    procedure IsUpgradeInProgress() UpgradeIsInProgress: Boolean
    begin
        OnIsUpgradeInProgress(UpgradeIsInProgress);
    end;

    [EventSubscriber(ObjectType::Codeunit, 2000000008, 'OnCheckPreconditionsPerCompany', '', false, false)]
    local procedure RaiseOnCheckPreconditionsPerCompany()
    begin
        OnCheckPreconditionsPerCompany
    end;

    [EventSubscriber(ObjectType::Codeunit, 2000000008, 'OnCheckPreconditionsPerDatabase', '', false, false)]
    local procedure RaiseOnCheckPreconditionsPerDatabase()
    begin
        OnCheckPreconditionsPerDatabase
    end;

    [EventSubscriber(ObjectType::Codeunit, 2000000008, 'OnUpgradePerCompany', '', false, false)]
    local procedure RaiseOnUpgradePerCompany()
    begin
        OnUpgradePerCompany
    end;

    [EventSubscriber(ObjectType::Codeunit, 2000000008, 'OnUpgradePerDatabase', '', false, false)]
    local procedure RaiseOnUpgradePerDatabase()
    begin
        OnUpgradePerDatabase
    end;

    [EventSubscriber(ObjectType::Codeunit, 2000000008, 'OnValidateUpgradePerCompany', '', false, false)]
    local procedure RaiseOnValidateUpgradePerCompany()
    begin
        OnValidateUpgradePerCompany
    end;

    [EventSubscriber(ObjectType::Codeunit, 2000000008, 'OnValidateUpgradePerDatabase', '', false, false)]
    local procedure RaiseOnValidateUpgradePerDatabase()
    begin
        OnValidateUpgradePerDatabase
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckPreconditionsPerCompany()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckPreconditionsPerDatabase()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpgradePerDatabase()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpgradePerCompany()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateUpgradePerDatabase()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateUpgradePerCompany()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsUpgradeInProgress(var UpgradeIsInProgress: Boolean)
    begin
    end;
}

