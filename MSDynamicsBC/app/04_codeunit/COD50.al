codeunit 50 "SaaS Log In Management"
{
    // version NAVW113.00


    trigger OnRun()
    begin
        ShowTermsAndConditionsOnOpenCompany;
    end;

    var
        NoPermissionToEnterTrialErr: Label 'In order to open %1, your company must start a trial. You must be an administrator to enter the trial period.', Comment='%1 = Company Name';
        RequireUserApprovalForTrialErr: Label 'Preview versions are no longer available. To continue using %1, use a web client to open the company and accept the terms and conditions.', Comment='%1 = Company Name';
        MissingEvaluationCompanyErr: Label 'You do not have an evaluation company. To continue with the trial version, you must accept the terms and conditions.';
        AbortTrialQst: Label 'Are you sure that you want to cancel?', Comment='Use same string as in page 9193 textconst AbortTrialQst';
        CanNotOpenCompanyFromDevicelMsg: Label 'Sorry, you can''t create a %1 from this device.', Comment='%1 = Company Name';

    local procedure ChangeToEvaluationCompany()
    var
        SelectedCompany: Record Company;
        SessionSetting: SessionSettings;
    begin
        SessionSetting.Init;

        SelectedCompany.SetRange("Evaluation Company",true);
        if SelectedCompany.FindFirst then
          SessionSetting.Company(SelectedCompany.Name)
        else
          Error(MissingEvaluationCompanyErr);

        SessionSetting.RequestSessionUpdate(true);

        // Commit needed as SessionSetting is saving to the Personalization
        Commit;

        // Confirm needed to force the session update
        if Confirm(AbortTrialQst) then;
    end;

    local procedure ShowTermsAndConditionsOnOpenCompany()
    var
        TenantLicenseState: Record "Tenant License State";
        Company: Record Company;
        PermissionManager: Codeunit "Permission Manager";
        RoleCenterNotificationMgt: Codeunit "Role Center Notification Mgt.";
        ClientTypeManagement: Codeunit ClientTypeManagement;
        IdentityManagement: Codeunit "Identity Management";
        ThirtyDayTrialDialog: Page "Thirty Day Trial Dialog";
        SuppressApprovalForTrial: Boolean;
    begin
        if IdentityManagement.IsInvAppId then
          exit;

        if not Company.Get(CompanyName) then
          exit;

        if PermissionManager.IsPreview then
          exit;

        if not PermissionManager.SoftwareAsAService then
          exit;

        if PermissionManager.IsSandboxConfiguration then
          exit;

        if Company."Evaluation Company" then
          exit;

        if TenantLicenseState.FindLast then
          if TenantLicenseState.State <> TenantLicenseState.State::Evaluation then
            exit;

        if not GuiAllowed then begin
          if CurrentClientType in [CLIENTTYPE::OData,CLIENTTYPE::ODataV4] then begin
            SuppressApprovalForTrial := false;
            OnSuppressApprovalForTrial(SuppressApprovalForTrial);
            if not SuppressApprovalForTrial then
              Error(RequireUserApprovalForTrialErr,Company.Name);
          end;
          exit;
        end;

        if ClientTypeManagement.IsDeviceClientType then begin
          Message(CanNotOpenCompanyFromDevicelMsg,Company.Name);
          ChangeToEvaluationCompany;
          // Just to be sure that we do not save the Trial License State on the server side
          Error('');
        end;

        if not Company.WritePermission then
          Error(NoPermissionToEnterTrialErr,Company.Name);

        Commit;

        ThirtyDayTrialDialog.RunModal;

        if not ThirtyDayTrialDialog.Confirmed then begin
          if RoleCenterNotificationMgt.IsEvaluationNotificationClicked then
            RoleCenterNotificationMgt.ShowEvaluationNotification;
          ChangeToEvaluationCompany;
          // Just to be sure that we do not save the Trial License State on the server side
          Error('');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 2000000006, 'OpenContactMSSales', '', false, false)]
    local procedure OpenContactMSSales()
    begin
        PAGE.Run(PAGE::"Contact MS Sales")
    end;

    [IntegrationEvent(false, false)]
    procedure OnSuppressApprovalForTrial(var GetSuppressApprovalForTrial: Boolean)
    begin
    end;
}

