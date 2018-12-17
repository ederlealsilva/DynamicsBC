codeunit 1430 "Role Center Notification Mgt."
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        EvaluationNotificationIdTxt: Label 'cb28c63d-4daf-453a-b41b-a8de9963d563', Locked=true;
        TrialNotificationIdTxt: Label '2751b488-ca52-42ef-b6d7-d7b4ba841e80', Locked=true;
        TrialSuspendedNotificationIdTxt: Label '2751b488-ca52-42ef-b6d7-d7b4ba841e80', Locked=true;
        PaidWarningNotificationIdTxt: Label '2751b488-ca52-42ef-b6d7-d7b4ba841e80', Locked=true;
        PaidSuspendedNotificationIdTxt: Label '2751b488-ca52-42ef-b6d7-d7b4ba841e80', Locked=true;
        SandboxNotificationIdTxt: Label 'd82835d9-a005-451a-972b-0d6532de2071', Locked=true;
        ChangeToPremiumExpNotificationIdTxt: Label '58982418-e1d1-4879-bda2-6033ca151b83', Locked=true;
        TrialNotificationDaysSinceStartTxt: Label '1', Locked=true;
        EvaluationNotificationLinkTxt: Label 'Start trial...';
        TrialNotificationLinkTxt: Label 'Buy subscription...';
        TrialSuspendedNotificationLinkTxt: Label 'Subscribe now...';
        PaidWarningNotificationLinkTxt: Label 'Renew subscription...';
        PaidSuspendedNotificationLinkTxt: Label 'Renew subscription...';
        EvaluationNotificationMsg: Label 'Want more? Start a free, %1-day trial to unlock advanced features and use your own company data.', Comment='%1=Trial duration in days';
        TrialNotificationMsg: Label 'Your trial period expires in %1 days. Do you want to get a subscription?', Comment='%1=Count of days until trial expires';
        TrialSuspendedNotificationMsg: Label 'Your trial period has expired. Subscribe within %1 days and keep your company data.', Comment='%1=Count of days until block of access';
        PaidWarningNotificationMsg: Label 'Your subscription expires in %1 days. Renew soon to keep your work.', Comment='%1=Count of days until block of access';
        PaidSuspendedNotificationMsg: Label 'Your subscription has expired. Unless you renew, we will delete your data in %1 days.', Comment='%1=Count of days until data deletion';
        ChooseCompanyMsg: Label 'Choose a non-evaluation company to start your trial.';
        SandboxNotificationMsg: Label 'This is a sandbox environment (preview) for test, demo, or development purposes only.';
        SandboxNotificationNameTok: Label 'Notify user of sandbox environment (preview).';
        DontShowThisAgainMsg: Label 'Don''t show this again.';
        SandboxNotificationDescTok: Label 'Show a notification informing the user that they are working in a sandbox environment (preview).';
        ChangeToPremiumExpNotificationMsg: Label 'This Role Center contains functionality that may not be visible because of your experience setting or assigned plan. For more information, see Changing Which Features are Displayed';
        ChangeToPremiumExpURLTxt: Label 'https://go.microsoft.com/fwlink/?linkid=873395', Comment='Locked';
        ChangeToPremiumExpNotificationDescTok: Label 'Show a notification suggesting the user to change to Premium experience.';
        ChangeToPremiumExpNotificationNameTok: Label 'Suggest to change the Experience setting.';
        NoAccessToCompanyErr: Label 'Cannot start trial company %1 because you do not have access to the company.', Comment='%1 = Company name';

    local procedure CreateAndSendEvaluationNotification()
    var
        EvaluationNotification: Notification;
        TrialTotalDays: Integer;
    begin
        TrialTotalDays := GetTrialTotalDays;
        EvaluationNotification.Id := GetEvaluationNotificationId;
        EvaluationNotification.Message := StrSubstNo(EvaluationNotificationMsg,TrialTotalDays);
        EvaluationNotification.Scope := NOTIFICATIONSCOPE::LocalScope;
        EvaluationNotification.AddAction(
          EvaluationNotificationLinkTxt,CODEUNIT::"Role Center Notification Mgt.",'EvaluationNotificationAction');
        EvaluationNotification.Send;
    end;

    local procedure CreateAndSendTrialNotification()
    var
        TrialNotification: Notification;
        RemainingDays: Integer;
    begin
        RemainingDays := GetLicenseRemainingDays;
        TrialNotification.Id := GetTrialNotificationId;
        TrialNotification.Message := StrSubstNo(TrialNotificationMsg,RemainingDays);
        TrialNotification.Scope := NOTIFICATIONSCOPE::LocalScope;
        TrialNotification.AddAction(
          TrialNotificationLinkTxt,CODEUNIT::"Role Center Notification Mgt.",'TrialNotificationAction');
        TrialNotification.Send;
    end;

    local procedure CreateAndSendTrialSuspendedNotification()
    var
        TrialSuspendedNotification: Notification;
        RemainingDays: Integer;
    begin
        RemainingDays := GetLicenseRemainingDays;
        TrialSuspendedNotification.Id := GetTrialSuspendedNotificationId;
        TrialSuspendedNotification.Message := StrSubstNo(TrialSuspendedNotificationMsg,RemainingDays);
        TrialSuspendedNotification.Scope := NOTIFICATIONSCOPE::LocalScope;
        TrialSuspendedNotification.AddAction(
          TrialSuspendedNotificationLinkTxt,CODEUNIT::"Role Center Notification Mgt.",'TrialSuspendedNotificationAction');
        TrialSuspendedNotification.Send;
    end;

    local procedure CreateAndSendPaidWarningNotification()
    var
        PaidWarningNotification: Notification;
        RemainingDays: Integer;
    begin
        RemainingDays := GetLicenseRemainingDays;
        PaidWarningNotification.Id := GetPaidWarningNotificationId;
        PaidWarningNotification.Message := StrSubstNo(PaidWarningNotificationMsg,RemainingDays);
        PaidWarningNotification.Scope := NOTIFICATIONSCOPE::LocalScope;
        PaidWarningNotification.AddAction(
          PaidWarningNotificationLinkTxt,CODEUNIT::"Role Center Notification Mgt.",'PaidWarningNotificationAction');
        PaidWarningNotification.Send;
    end;

    local procedure CreateAndSendPaidSuspendedNotification()
    var
        PaidSuspendedNotification: Notification;
        RemainingDays: Integer;
    begin
        RemainingDays := GetLicenseRemainingDays;
        PaidSuspendedNotification.Id := GetPaidSuspendedNotificationId;
        PaidSuspendedNotification.Message := StrSubstNo(PaidSuspendedNotificationMsg,RemainingDays);
        PaidSuspendedNotification.Scope := NOTIFICATIONSCOPE::LocalScope;
        PaidSuspendedNotification.AddAction(
          PaidSuspendedNotificationLinkTxt,CODEUNIT::"Role Center Notification Mgt.",'PaidSuspendedNotificationAction');
        PaidSuspendedNotification.Send;
    end;

    local procedure CreateAndSendSandboxNotification()
    var
        SandboxNotification: Notification;
    begin
        SandboxNotification.Id := GetSandboxNotificationId;
        SandboxNotification.Message := SandboxNotificationMsg;
        SandboxNotification.Scope := NOTIFICATIONSCOPE::LocalScope;
        SandboxNotification.AddAction(DontShowThisAgainMsg,CODEUNIT::"Role Center Notification Mgt.",'DisableSandboxNotification');
        SandboxNotification.Send;
    end;

    local procedure CreateAndSendChangeToPremiumExpNotification()
    var
        ChangeToPremiumExpNotification: Notification;
    begin
        ChangeToPremiumExpNotification.Id := GetChangeToPremiumExpNotificationId;
        ChangeToPremiumExpNotification.Message := ChangeToPremiumExpNotificationMsg;
        ChangeToPremiumExpNotification.Scope := NOTIFICATIONSCOPE::LocalScope;
        ChangeToPremiumExpNotification.AddAction(
          ChangeToPremiumExpURLTxt,CODEUNIT::"Role Center Notification Mgt.",'ChangeToPremiumExpURL');
        ChangeToPremiumExpNotification.AddAction(
          DontShowThisAgainMsg,CODEUNIT::"Role Center Notification Mgt.",'DisableChangeToPremiumExpNotification');
        ChangeToPremiumExpNotification.Send;
    end;

    [Scope('Personalization')]
    procedure HideEvaluationNotificationAfterStartingTrial()
    var
        TenantLicenseState: Codeunit "Tenant License State";
        EvaluationNotification: Notification;
    begin
        if not TenantLicenseState.IsTrialMode then
          exit;
        if not AreNotificationsSupported then
          exit;
        EvaluationNotification.Id := GetEvaluationNotificationId;
        EvaluationNotification.Recall;
    end;

    procedure GetEvaluationNotificationId(): Guid
    var
        EvaluationNotificationId: Guid;
    begin
        Evaluate(EvaluationNotificationId,EvaluationNotificationIdTxt);
        exit(EvaluationNotificationId);
    end;

    procedure GetTrialNotificationId(): Guid
    var
        TrialNotificationId: Guid;
    begin
        Evaluate(TrialNotificationId,TrialNotificationIdTxt);
        exit(TrialNotificationId);
    end;

    procedure GetTrialSuspendedNotificationId(): Guid
    var
        TrialSuspendedNotificationId: Guid;
    begin
        Evaluate(TrialSuspendedNotificationId,TrialSuspendedNotificationIdTxt);
        exit(TrialSuspendedNotificationId);
    end;

    procedure GetPaidWarningNotificationId(): Guid
    var
        PaidWarningNotificationId: Guid;
    begin
        Evaluate(PaidWarningNotificationId,PaidWarningNotificationIdTxt);
        exit(PaidWarningNotificationId);
    end;

    procedure GetPaidSuspendedNotificationId(): Guid
    var
        PaidSuspendedNotificationId: Guid;
    begin
        Evaluate(PaidSuspendedNotificationId,PaidSuspendedNotificationIdTxt);
        exit(PaidSuspendedNotificationId);
    end;

    procedure GetSandboxNotificationId(): Guid
    var
        SandboxNotificationId: Guid;
    begin
        Evaluate(SandboxNotificationId,SandboxNotificationIdTxt);
        exit(SandboxNotificationId);
    end;

    procedure GetChangeToPremiumExpNotificationId(): Guid
    var
        ChangeToPremiumExpNotificationId: Guid;
    begin
        Evaluate(ChangeToPremiumExpNotificationId,ChangeToPremiumExpNotificationIdTxt);
        exit(ChangeToPremiumExpNotificationId);
    end;

    local procedure AreNotificationsSupported(): Boolean
    var
        PermissionManager: Codeunit "Permission Manager";
        IdentityManagement: Codeunit "Identity Management";
    begin
        if not GuiAllowed then
          exit(false);

        if IdentityManagement.IsInvAppId then
          exit(false);

        if not PermissionManager.SoftwareAsAService then
          exit(false);

        if PermissionManager.IsSandboxConfiguration then
          exit(false);

        if PermissionManager.IsPreview then
          exit(false);

        exit(true);
    end;

    local procedure AreSandboxNotificationsSupported(): Boolean
    var
        PermissionManager: Codeunit "Permission Manager";
        IdentityManagement: Codeunit "Identity Management";
    begin
        if not GuiAllowed then
          exit(false);

        if IdentityManagement.IsInvAppId then
          exit(false);

        if not PermissionManager.SoftwareAsAService then
          exit(false);

        if not PermissionManager.IsSandboxConfiguration then
          exit(false);

        exit(true);
    end;

    local procedure IsEvaluationNotificationEnabled(): Boolean
    var
        RoleCenterNotifications: Record "Role Center Notifications";
        ClientTypeManagement: Codeunit ClientTypeManagement;
        TenantLicenseState: Codeunit "Tenant License State";
    begin
        if not TenantLicenseState.IsEvaluationMode then
          exit(false);

        if not AreNotificationsSupported then
          exit(false);

        if ClientTypeManagement.IsDeviceClientType then
          exit(false);

        RoleCenterNotifications.Initialize;

        if RoleCenterNotifications.GetEvaluationNotificationState =
           RoleCenterNotifications."Evaluation Notification State"::Disabled
        then
          exit(false);

        exit(true);
    end;

    local procedure IsTrialNotificationEnabled(): Boolean
    var
        RoleCenterNotifications: Record "Role Center Notifications";
        ClientTypeManagement: Codeunit ClientTypeManagement;
        TenantLicenseState: Codeunit "Tenant License State";
    begin
        if not TenantLicenseState.IsTrialMode then
          exit(false);

        if not AreNotificationsSupported then
          exit(false);

        if ClientTypeManagement.IsDeviceClientType then
          exit(false);

        if RoleCenterNotifications.IsFirstLogon then
          exit(false);

        if GetLicenseFullyUsedDays < GetTrialNotificationDaysSinceStart then
          exit(false);

        exit(IsBuyNotificationEnabled);
    end;

    local procedure IsTrialSuspendedNotificationEnabled(): Boolean
    var
        RoleCenterNotifications: Record "Role Center Notifications";
        ClientTypeManagement: Codeunit ClientTypeManagement;
        TenantLicenseState: Codeunit "Tenant License State";
    begin
        if not TenantLicenseState.IsTrialSuspendedMode then
          exit(false);

        if not AreNotificationsSupported then
          exit(false);

        if ClientTypeManagement.IsDeviceClientType then
          exit(false);

        if RoleCenterNotifications.IsFirstLogon then
          exit(false);

        exit(IsBuyNotificationEnabled);
    end;

    local procedure IsPaidWarningNotificationEnabled(): Boolean
    var
        RoleCenterNotifications: Record "Role Center Notifications";
        TenantLicenseState: Codeunit "Tenant License State";
    begin
        if not TenantLicenseState.IsPaidWarningMode then
          exit(false);

        if not AreNotificationsSupported then
          exit(false);

        if RoleCenterNotifications.IsFirstLogon then
          exit(false);

        exit(IsBuyNotificationEnabled);
    end;

    local procedure IsPaidSuspendedNotificationEnabled(): Boolean
    var
        RoleCenterNotifications: Record "Role Center Notifications";
        TenantLicenseState: Codeunit "Tenant License State";
    begin
        if not TenantLicenseState.IsPaidSuspendedMode then
          exit(false);

        if not AreNotificationsSupported then
          exit(false);

        if RoleCenterNotifications.IsFirstLogon then
          exit(false);

        exit(IsBuyNotificationEnabled);
    end;

    [Scope('Personalization')]
    procedure ShowNotifications(): Boolean
    var
        DataMigrationMgt: Codeunit "Data Migration Mgt.";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
        ResultEvaluation: Boolean;
        ResultTrial: Boolean;
        ResultTrialSuspended: Boolean;
        ResultPaidWarning: Boolean;
        ResultPaidSuspended: Boolean;
        ResultSandbox: Boolean;
    begin
        OnBeforeShowNotifications;

        ResultEvaluation := ShowEvaluationNotification;
        ResultTrial := ShowTrialNotification;
        ResultTrialSuspended := ShowTrialSuspendedNotification;
        ResultPaidWarning := ShowPaidWarningNotification;
        ResultPaidSuspended := ShowPaidSuspendedNotification;
        ResultSandbox := ShowSandboxNotification;

        DataMigrationMgt.ShowDataMigrationRelatedGlobalNotifications;
        DataClassificationMgt.ShowNotifications;

        Commit;
        exit(
          ResultEvaluation or
          ResultTrial or ResultTrialSuspended or
          ResultPaidWarning or ResultPaidSuspended or
          ResultSandbox);
    end;

    [Scope('Personalization')]
    procedure ShowEvaluationNotification(): Boolean
    var
        Company: Record Company;
    begin
        if not IsEvaluationNotificationEnabled then
          exit(false);

        // Verify, that the user has company setup rights
        if not Company.WritePermission then
          exit(false);

        CreateAndSendEvaluationNotification;
        exit(true);
    end;

    [Scope('Personalization')]
    procedure ShowTrialNotification(): Boolean
    begin
        if not IsTrialNotificationEnabled then
          exit(false);

        CreateAndSendTrialNotification;
        exit(true);
    end;

    [Scope('Personalization')]
    procedure ShowTrialSuspendedNotification(): Boolean
    begin
        if not IsTrialSuspendedNotificationEnabled then
          exit(false);

        CreateAndSendTrialSuspendedNotification;
        exit(true);
    end;

    [Scope('Personalization')]
    procedure ShowPaidWarningNotification(): Boolean
    begin
        if not IsPaidWarningNotificationEnabled then
          exit(false);

        CreateAndSendPaidWarningNotification;
        exit(true);
    end;

    [Scope('Personalization')]
    procedure ShowPaidSuspendedNotification(): Boolean
    begin
        if not IsPaidSuspendedNotificationEnabled then
          exit(false);

        CreateAndSendPaidSuspendedNotification;
        exit(true);
    end;

    [Scope('Personalization')]
    procedure ShowSandboxNotification(): Boolean
    var
        MyNotifications: Record "My Notifications";
    begin
        if not AreSandboxNotificationsSupported then
          exit(false);

        if not MyNotifications.IsEnabled(GetSandboxNotificationId) then
          exit(false);

        CreateAndSendSandboxNotification;
        exit(true);
    end;

    [Scope('Personalization')]
    procedure ShowChangeToPremiumExpNotification(): Boolean
    var
        MyNotifications: Record "My Notifications";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if ApplicationAreaMgmtFacade.IsPremiumExperienceEnabled then
          exit(false);

        if not MyNotifications.IsEnabled(GetChangeToPremiumExpNotificationId) then
          exit(false);

        CreateAndSendChangeToPremiumExpNotification;
        exit(true);
    end;

    [Scope('Personalization')]
    procedure EvaluationNotificationAction(EvaluationNotification: Notification)
    begin
        StartTrial;
    end;

    [Scope('Personalization')]
    procedure TrialNotificationAction(TrialNotification: Notification)
    begin
        BuySubscription;
    end;

    [Scope('Personalization')]
    procedure TrialSuspendedNotificationAction(TrialSuspendedNotification: Notification)
    begin
        BuySubscription;
    end;

    [Scope('Personalization')]
    procedure PaidWarningNotificationAction(PaidWarningNotification: Notification)
    begin
        BuySubscription;
    end;

    [Scope('Personalization')]
    procedure PaidSuspendedNotificationAction(PaidSuspendedNotification: Notification)
    begin
        BuySubscription;
    end;

    [Scope('Personalization')]
    procedure GetLicenseRemainingDays(): Integer
    var
        DateFilterCalc: Codeunit "DateFilter-Calc";
        TenantLicenseState: Codeunit "Tenant License State";
        Now: DateTime;
        EndDate: DateTime;
        TimeDuration: Decimal;
        MillisecondsPerDay: BigInteger;
        RemainingDays: Integer;
    begin
        Now := DateFilterCalc.ConvertToUtcDateTime(CurrentDateTime);
        TenantLicenseState.GetEndDate(EndDate);
        if EndDate > Now then begin
          TimeDuration := EndDate - Now;
          MillisecondsPerDay := 86400000;
          RemainingDays := Round(TimeDuration / MillisecondsPerDay,1,'=');
          exit(RemainingDays);
        end;
        exit(0);
    end;

    local procedure GetLicenseFullyUsedDays(): Integer
    var
        TenantLicenseState: Codeunit "Tenant License State";
        DateFilterCalc: Codeunit "DateFilter-Calc";
        StartDate: DateTime;
        Now: DateTime;
        TimeDuration: Decimal;
        MillisecondsPerDay: BigInteger;
        FullyUsedDays: Integer;
    begin
        Now := DateFilterCalc.ConvertToUtcDateTime(CurrentDateTime);
        TenantLicenseState.GetStartDate(StartDate);
        if StartDate <> 0DT then
          if Now > StartDate then begin
            TimeDuration := Now - StartDate;
            MillisecondsPerDay := 86400000;
            FullyUsedDays := Round(TimeDuration / MillisecondsPerDay,1,'<');
            exit(FullyUsedDays);
          end;
        exit(0);
    end;

    [Scope('Personalization')]
    procedure GetTrialTotalDays(): Integer
    var
        TenantLicenseState: Record "Tenant License State";
        TenantLicenseStateMgt: Codeunit "Tenant License State";
        TrialTotalDays: Integer;
    begin
        TrialTotalDays := TenantLicenseStateMgt.GetPeriod(TenantLicenseState.State::Trial);
        exit(TrialTotalDays);
    end;

    local procedure GetTrialNotificationDaysSinceStart(): Integer
    var
        DaysSinceStart: Integer;
    begin
        Evaluate(DaysSinceStart,TrialNotificationDaysSinceStartTxt);
        exit(DaysSinceStart);
    end;

    local procedure StartTrial()
    var
        AssistedCompanySetup: Codeunit "Assisted Company Setup";
        SessionSetting: SessionSettings;
        NewCompany: Text[30];
    begin
        if not GetMyCompany(NewCompany) then begin
          Message(ChooseCompanyMsg);
          CreateAndSendEvaluationNotification;
          exit;
        end;

        if not AssistedCompanySetup.HasCurrentUserAccessToCompany(NewCompany) then
          Error(NoAccessToCompanyErr,NewCompany);

        ClickEvaluationNotification;
        Commit;

        DisableEvaluationNotification;

        SessionSetting.Init;
        SessionSetting.Company(NewCompany);
        SessionSetting.RequestSessionUpdate(true)
    end;

    local procedure BuySubscription()
    begin
        DisableBuyNotification;
        PAGE.Run(PAGE::"Buy Subscription");
    end;

    local procedure ClickEvaluationNotification()
    var
        RoleCenterNotifications: Record "Role Center Notifications";
    begin
        RoleCenterNotifications.SetEvaluationNotificationState(RoleCenterNotifications."Evaluation Notification State"::Clicked);
    end;

    procedure DisableEvaluationNotification()
    var
        RoleCenterNotifications: Record "Role Center Notifications";
    begin
        RoleCenterNotifications.SetEvaluationNotificationState(RoleCenterNotifications."Evaluation Notification State"::Disabled);
    end;

    procedure EnableEvaluationNotification()
    var
        RoleCenterNotifications: Record "Role Center Notifications";
    begin
        RoleCenterNotifications.SetEvaluationNotificationState(RoleCenterNotifications."Evaluation Notification State"::Enabled);
    end;

    procedure IsEvaluationNotificationClicked(): Boolean
    var
        RoleCenterNotifications: Record "Role Center Notifications";
    begin
        exit(RoleCenterNotifications.GetEvaluationNotificationState = RoleCenterNotifications."Evaluation Notification State"::Clicked);
    end;

    procedure DisableBuyNotification()
    var
        RoleCenterNotifications: Record "Role Center Notifications";
    begin
        RoleCenterNotifications.SetBuyNotificationState(RoleCenterNotifications."Buy Notification State"::Disabled);
    end;

    procedure EnableBuyNotification()
    var
        RoleCenterNotifications: Record "Role Center Notifications";
    begin
        RoleCenterNotifications.SetBuyNotificationState(RoleCenterNotifications."Buy Notification State"::Enabled);
    end;

    local procedure IsBuyNotificationEnabled(): Boolean
    var
        RoleCenterNotifications: Record "Role Center Notifications";
    begin
        exit(RoleCenterNotifications.GetBuyNotificationState <> RoleCenterNotifications."Buy Notification State"::Disabled);
    end;

    procedure DisableSandboxNotification(Notification: Notification)
    var
        MyNotifications: Record "My Notifications";
    begin
        if not MyNotifications.Disable(GetSandboxNotificationId) then
          MyNotifications.InsertDefault(GetSandboxNotificationId,SandboxNotificationNameTok,SandboxNotificationDescTok,false);
    end;

    procedure DisableChangeToPremiumExpNotification(Notification: Notification)
    var
        MyNotifications: Record "My Notifications";
    begin
        if not MyNotifications.Disable(GetChangeToPremiumExpNotificationId) then
          MyNotifications.InsertDefault(
            GetChangeToPremiumExpNotificationId,ChangeToPremiumExpNotificationNameTok,ChangeToPremiumExpNotificationDescTok,false);
    end;

    procedure CompanyNotSelectedMessage(): Text
    begin
        exit('');
    end;

    procedure EvaluationNotificationMessage(): Text
    begin
        exit(EvaluationNotificationMsg);
    end;

    procedure TrialNotificationMessage(): Text
    begin
        exit(TrialNotificationMsg);
    end;

    procedure TrialSuspendedNotificationMessage(): Text
    begin
        exit(TrialSuspendedNotificationMsg);
    end;

    procedure PaidWarningNotificationMessage(): Text
    begin
        exit(PaidWarningNotificationMsg);
    end;

    procedure PaidSuspendedNotificationMessage(): Text
    begin
        exit(PaidSuspendedNotificationMsg);
    end;

    procedure SandboxNotificationMessage(): Text
    begin
        exit(SandboxNotificationMsg);
    end;

    procedure ChangeToPremiumExpNotificationMessage(): Text
    begin
        exit(ChangeToPremiumExpNotificationMsg);
    end;

    procedure ChangeToPremiumExpURL(Notification: Notification)
    begin
        HyperLink(ChangeToPremiumExpURLTxt);
    end;

    local procedure GetMyCompany(var MyCompany: Text[30]): Boolean
    var
        SelectedCompany: Record Company;
        AllowedCompanies: Page "Allowed Companies";
    begin
        SelectedCompany.SetRange("Evaluation Company",false);
        SelectedCompany.FindFirst;
        if SelectedCompany.Count = 1 then begin
          MyCompany := SelectedCompany.Name;
          exit(true);
        end;

        AllowedCompanies.Initialize;

        if SelectedCompany.Get(CompanyName) then
          AllowedCompanies.SetRecord(SelectedCompany);

        AllowedCompanies.LookupMode(true);

        if AllowedCompanies.RunModal = ACTION::LookupOK then begin
          AllowedCompanies.GetRecord(SelectedCompany);
          if SelectedCompany."Evaluation Company" then
            exit(false);
          MyCompany := SelectedCompany.Name;
          exit(true);
        end;

        exit(false);
    end;

    [EventSubscriber(ObjectType::Page, 1518, 'OnInitializingNotificationWithDefaultState', '', false, false)]
    procedure OnInitializingNotificationWithDefaultState()
    var
        MyNotifications: Record "My Notifications";
    begin
        if AreSandboxNotificationsSupported then
          MyNotifications.InsertDefault(GetSandboxNotificationId,SandboxNotificationNameTok,SandboxNotificationDescTok,true);
        if AreNotificationsSupported then
          MyNotifications.InsertDefault(
            GetChangeToPremiumExpNotificationId,ChangeToPremiumExpNotificationNameTok,ChangeToPremiumExpNotificationDescTok,true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowNotifications()
    begin
    end;
}

