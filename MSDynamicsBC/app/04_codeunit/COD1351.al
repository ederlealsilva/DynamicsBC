codeunit 1351 "Telemetry Subscribers"
{
    // version NAVW113.00

    Permissions = TableData "Permission Set Link"=r;

    trigger OnRun()
    begin
    end;

    var
        ProfileChangedTelemetryMsg: Label 'Profile changed from %1 to %2.', Comment='%1=Previous profile id, %2=New profile id';
        ProfileChangedTelemetryCategoryTxt: Label 'AL User Profile';
        NoSeriesCategoryTxt: Label 'AL NoSeries', Comment='{LOCKED}';
        NoSeriesEditedTelemetryTxt: Label 'The number series was changed by the user.', Comment='{LOCKED}';
        PermissionSetCategoryTxt: Label 'AL PermissionSet', Comment='{LOCKED}';
        PermissionSetLinkAddedTelemetryTxt: Label 'A Permission Set Link was added between Source Permission Set %1 and Permission Set %2. Total count of Permission Set Links are %3.', Comment='{LOCKED}';
        PermissionSetAddedTelemetryTxt: Label 'Permission Set %1 was added. Total count of user defined Permission Sets is %2.', Comment='{LOCKED}';
        PermissionSetAssignedToUserTelemetryTxt: Label 'Permission Set %1 was added to a user.', Comment='{LOCKED}';
        PermissionSetAssignedToUserGroupTelemetryTxt: Label 'Permission Set %1 was added to a user group %2.', Comment='{LOCKED}';
        EffectivePermsCalculatedTxt: Label 'Effective permissions were calculated for user %1, company %2, object type %3, object ID %4.', Comment='{LOCKED} %1 = user security ID, %2 = company name, %3 = object type, %4 = object Id';
        TenantPermissionsChangedFromEffectivePermissionsPageTxt: Label 'Tenant permission set %1 was changed.', Comment='{LOCKED} %1 = permission set id';
        AnonymizedTagsTxt: Label '<pi>%1</pi>', Comment='{LOCKED} %1 = text to anonimyze';

    [EventSubscriber(ObjectType::Codeunit, 40, 'OnAfterCompanyOpen', '', true, true)]
    local procedure ScheduleMasterdataTelemetryAfterCompanyOpen()
    var
        CodeUnitMetadata: Record "CodeUnit Metadata";
        TelemetryManagement: Codeunit "Telemetry Management";
    begin
        if not IsSaaS then
          exit;

        CodeUnitMetadata.ID := CODEUNIT::"Generate Master Data Telemetry";
        TelemetryManagement.ScheduleCalEventsForTelemetryAsync(CodeUnitMetadata.RecordId,CODEUNIT::"Create Telemetry Cal. Events",20);
    end;

    [EventSubscriber(ObjectType::Codeunit, 40, 'OnAfterCompanyOpen', '', true, true)]
    local procedure ScheduleActivityTelemetryAfterCompanyOpen()
    var
        CodeUnitMetadata: Record "CodeUnit Metadata";
        TelemetryManagement: Codeunit "Telemetry Management";
    begin
        if not IsSaaS then
          exit;

        CodeUnitMetadata.ID := CODEUNIT::"Generate Activity Telemetry";
        TelemetryManagement.ScheduleCalEventsForTelemetryAsync(CodeUnitMetadata.RecordId,CODEUNIT::"Create Telemetry Cal. Events",21);
    end;

    [EventSubscriber(ObjectType::Codeunit, 9170, 'OnProfileChanged', '', true, true)]
    local procedure SendTraceOnProfileChanged(PrevProfileID: Code[30];ProfileID: Code[30])
    begin
        if not IsSaaS then
          exit;

        SendTraceTag(
          '00001O5',ProfileChangedTelemetryCategoryTxt,VERBOSITY::Normal,StrSubstNo(ProfileChangedTelemetryMsg,PrevProfileID,ProfileID),
          DATACLASSIFICATION::SystemMetadata);
    end;

    [EventSubscriber(ObjectType::Page, 2340, 'OnAfterNoSeriesModified', '', true, true)]
    local procedure LogNoSeriesModifiedInvoicing()
    begin
        if not IsSaaS then
          exit;

        SendTraceTag('00001PI',NoSeriesCategoryTxt,VERBOSITY::Normal,NoSeriesEditedTelemetryTxt,DATACLASSIFICATION::SystemMetadata);
    end;

    [EventSubscriber(ObjectType::Table, 9802, 'OnAfterInsertEvent', '', true, true)]
    local procedure SendTraceOnPermissionSetLinkAdded(var Rec: Record "Permission Set Link";RunTrigger: Boolean)
    var
        PermissionSetLink: Record "Permission Set Link";
    begin
        if not IsSaaS then
          exit;

        SendTraceTag(
          '0000250',PermissionSetCategoryTxt,VERBOSITY::Normal,
          StrSubstNo(PermissionSetLinkAddedTelemetryTxt,Rec."Permission Set ID",Rec."Linked Permission Set ID",PermissionSetLink.Count),
          DATACLASSIFICATION::SystemMetadata);
    end;

    [EventSubscriber(ObjectType::Table, 2000000165, 'OnAfterInsertEvent', '', true, true)]
    local procedure SendTraceOnUserDefinedPermissionSetIsAdded(var Rec: Record "Tenant Permission Set";RunTrigger: Boolean)
    var
        TenantPermissionSet: Record "Tenant Permission Set";
    begin
        if not IsSaaS then
          exit;

        if not IsNullGuid(Rec."App ID") then
          exit;

        TenantPermissionSet.SetRange("App ID",Rec."App ID");
        SendTraceTag(
          '0000251',PermissionSetCategoryTxt,VERBOSITY::Normal,
          StrSubstNo(PermissionSetAddedTelemetryTxt,Rec."Role ID",TenantPermissionSet.Count),DATACLASSIFICATION::SystemMetadata);
    end;

    [EventSubscriber(ObjectType::Table, 2000000053, 'OnAfterInsertEvent', '', true, true)]
    local procedure SendTraceOnUserDefinedPermissionSetIsAssignedToAUser(var Rec: Record "Access Control";RunTrigger: Boolean)
    var
        TenantPermissionSet: Record "Tenant Permission Set";
    begin
        if not IsSaaS then
          exit;

        if not IsNullGuid(Rec."App ID") then
          exit;

        if not TenantPermissionSet.Get(Rec."App ID",Rec."Role ID") then
          exit;

        SendTraceTag(
          '0000252',PermissionSetCategoryTxt,VERBOSITY::Normal,StrSubstNo(PermissionSetAssignedToUserTelemetryTxt,Rec."Role ID"),
          DATACLASSIFICATION::SystemMetadata);
    end;

    [EventSubscriber(ObjectType::Table, 9003, 'OnAfterInsertEvent', '', true, true)]
    local procedure SendTraceOnUserDefinedPermissionSetIsAssignedToAUserGroup(var Rec: Record "User Group Permission Set";RunTrigger: Boolean)
    var
        TenantPermissionSet: Record "Tenant Permission Set";
    begin
        if not IsSaaS then
          exit;

        if not IsNullGuid(Rec."App ID") then
          exit;

        if not TenantPermissionSet.Get(Rec."App ID",Rec."Role ID") then
          exit;

        SendTraceTag(
          '0000253',PermissionSetCategoryTxt,VERBOSITY::Normal,
          StrSubstNo(PermissionSetAssignedToUserGroupTelemetryTxt,Rec."Role ID",Rec."User Group Code"),
          DATACLASSIFICATION::SystemMetadata);
    end;

    [EventSubscriber(ObjectType::Page, 9852, 'OnEffectivePermissionsPopulated', '', true, true)]
    local procedure EffectivePermissionsFetchedInPage(CurrUserId: Guid;CurrCompanyName: Text[30];CurrObjectType: Integer;CurrObjectId: Integer)
    begin
        if not IsSaaS then
          exit;

        SendTraceTag(
          '000027E',PermissionSetCategoryTxt,VERBOSITY::Normal,
          StrSubstNo(EffectivePermsCalculatedTxt,StrSubstNo(AnonymizedTagsTxt,CurrUserId),
            StrSubstNo(AnonymizedTagsTxt,CurrCompanyName),CurrObjectType,CurrObjectId),
          DATACLASSIFICATION::SystemMetadata);
    end;

    [EventSubscriber(ObjectType::Codeunit, 9852, 'OnTenantPermissionModified', '', true, true)]
    local procedure EffectivePermissionsChangeInPage(PermissionSetId: Code[20])
    begin
        if not IsSaaS then
          exit;

        SendTraceTag(
          '000027G',PermissionSetCategoryTxt,VERBOSITY::Normal,
          StrSubstNo(TenantPermissionsChangedFromEffectivePermissionsPageTxt,PermissionSetId),
          DATACLASSIFICATION::SystemMetadata);
    end;

    local procedure IsSaaS(): Boolean
    var
        PermissionManager: Codeunit "Permission Manager";
    begin
        exit(PermissionManager.SoftwareAsAService);
    end;
}

