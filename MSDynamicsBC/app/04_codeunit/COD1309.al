codeunit 1309 "O365 Getting Started Mgt."
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        IdentityManagement: Codeunit "Identity Management";
        ClientTypeManagement: Codeunit ClientTypeManagement;

    [Scope('Personalization')]
    procedure LaunchWizard(UserInitiated: Boolean;TourCompleted: Boolean): Boolean
    begin
        exit(CheckOrLaunchWizard(UserInitiated,TourCompleted,true));
    end;

    [Scope('Personalization')]
    procedure WizardHasToBeLaunched(UserInitiated: Boolean): Boolean
    begin
        exit(CheckOrLaunchWizard(UserInitiated,false,false));
    end;

    local procedure CheckOrLaunchWizard(UserInitiated: Boolean;TourCompleted: Boolean;Launch: Boolean): Boolean
    var
        O365GettingStarted: Record "O365 Getting Started";
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
        PermissionManager: Codeunit "Permission Manager";
        WizardHasBeenShownToUser: Boolean;
        PageToStart: Integer;
    begin
        if not UserHasPermissionsToRunGettingStarted then
          exit(false);

        if not IdentityManagement.IsInvAppId then
          if not CompanyInformationMgt.IsDemoCompany then
            exit(false);

        PageToStart := GetPageToStart;
        if PageToStart <= 0 then
          exit(false);

        WizardHasBeenShownToUser := O365GettingStarted.Get(UserId,ClientTypeManagement.GetCurrentClientType);

        if not WizardHasBeenShownToUser then begin
          if not IdentityManagement.IsInvAppId then
            O365GettingStarted.OnO365DemoCompanyInitialize;
          if Launch then begin
            Commit;
            PAGE.RunModal(PageToStart);
          end;
          exit(true);
        end;

        if (not O365GettingStarted."Tour in Progress") and (not UserInitiated) then
          exit(false);

        if UserInitiated then begin
          if Launch then begin
            Commit;
            PAGE.RunModal(PageToStart);
          end;
          exit(true);
        end;

        if O365GettingStarted."Tour in Progress" then begin
          if ClientTypeManagement.GetCurrentClientType in [CLIENTTYPE::Phone,CLIENTTYPE::Tablet,CLIENTTYPE::Desktop] then
            exit(false);

          if Launch then begin
            Commit;
            if TourCompleted and not PermissionManager.IsSandboxConfiguration then
              PAGE.RunModal(PAGE::"O365 Tour Complete")
            else
              PAGE.RunModal(PageToStart);
          end;
          exit(true);
        end;

        exit(false);
    end;

    [Scope('Personalization')]
    procedure UpdateGettingStartedVisible(var TileGettingStartedVisible: Boolean;var TileRestartGettingStartedVisible: Boolean)
    var
        O365GettingStarted: Record "O365 Getting Started";
        PermissionManager: Codeunit "Permission Manager";
    begin
        TileGettingStartedVisible := false;
        TileRestartGettingStartedVisible := false;

        if not UserHasPermissionsToRunGettingStarted then
          exit;

        if not IsGettingStartedSupported then
          exit;

        if PermissionManager.IsSandboxConfiguration then
          exit;

        TileRestartGettingStartedVisible := true;

        if not O365GettingStarted.Get(UserId,ClientTypeManagement.GetCurrentClientType) then
          exit;

        TileGettingStartedVisible := O365GettingStarted."Tour in Progress";
        TileRestartGettingStartedVisible := not TileGettingStartedVisible;
    end;

    [Scope('Personalization')]
    procedure IsGettingStartedSupported(): Boolean
    var
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
    begin
        if not (ClientTypeManagement.GetCurrentClientType in [CLIENTTYPE::Web,CLIENTTYPE::Phone,CLIENTTYPE::Tablet,CLIENTTYPE::Desktop]) then
          exit(false);

        if not IdentityManagement.IsInvAppId then
          if not CompanyInformationMgt.IsDemoCompany then
            exit(false);

        exit(true);
    end;

    [Scope('Personalization')]
    procedure AreUserToursEnabled(): Boolean
    begin
        exit(ClientTypeManagement.GetCurrentClientType = CLIENTTYPE::Web);
    end;

    [Scope('Personalization')]
    procedure GetGettingStartedTourID(): Integer
    begin
        exit(173706);
    end;

    [Scope('Personalization')]
    procedure GetInvoicingTourID(): Integer
    begin
        exit(174204);
    end;

    [Scope('Personalization')]
    procedure GetReportingTourID(): Integer
    begin
        exit(174207);
    end;

    [Scope('Personalization')]
    procedure GetChangeCompanyTourID(): Integer
    begin
        exit(174206);
    end;

    [Scope('Personalization')]
    procedure GetWizardDoneTourID(): Integer
    begin
        exit(176849);
    end;

    [Scope('Personalization')]
    procedure GetReturnToGettingStartedTourID(): Integer
    begin
        exit(176291);
    end;

    [Scope('Personalization')]
    procedure GetDevJourneyTourID(): Integer
    begin
        exit(195457);
    end;

    [Scope('Personalization')]
    procedure GetWhatIsNewTourID(): Integer
    begin
        exit(199410);
    end;

    [Scope('Personalization')]
    procedure GetAddItemTourID(): Integer
    begin
        exit(237373);
    end;

    [Scope('Personalization')]
    procedure GetAddCustomerTourID(): Integer
    begin
        exit(239510);
    end;

    [Scope('Personalization')]
    procedure GetCreateSalesOrderTourID(): Integer
    begin
        exit(240566);
    end;

    [Scope('Personalization')]
    procedure GetCreateSalesInvoiceTourID(): Integer
    begin
        exit(240561);
    end;

    [Scope('Personalization')]
    procedure WizardShouldBeOpenedForDevices(): Boolean
    var
        O365GettingStarted: Record "O365 Getting Started";
        PermissionManager: Codeunit "Permission Manager";
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
    begin
        if not (ClientTypeManagement.GetCurrentClientType in [CLIENTTYPE::Tablet,CLIENTTYPE::Phone,CLIENTTYPE::Desktop]) then
          exit(false);

        if not UserHasPermissionsToRunGettingStarted then
          exit(false);

        if not PermissionManager.SoftwareAsAService then
          exit(false);

        if not CompanyInformationMgt.IsDemoCompany then
          exit(false);

        exit(not O365GettingStarted.Get(UserId,ClientTypeManagement.GetCurrentClientType));
    end;

    [Scope('Personalization')]
    procedure GetAccountantTourID(): Integer
    begin
        exit(363941);
    end;

    local procedure GetPageToStart(): Integer
    var
        PermissionManager: Codeunit "Permission Manager";
    begin
        if IdentityManagement.IsInvAppId then begin
          if ClientTypeManagement.GetCurrentClientType = CLIENTTYPE::Web then
            exit(PAGE::"BC O365 Getting Started");
          exit(-1)
        end;

        if PermissionManager.IsSandboxConfiguration then begin
          if ClientTypeManagement.GetCurrentClientType = CLIENTTYPE::Web then
            exit(PAGE::"O365 Developer Welcome");
          exit(-1)
        end;

        if ClientTypeManagement.GetCurrentClientType in [CLIENTTYPE::Phone,CLIENTTYPE::Tablet,CLIENTTYPE::Desktop] then begin
          if PermissionManager.SoftwareAsAService then
            exit(PAGE::"O365 Getting Started Device");
          exit(-1);
        end;
        exit(PAGE::"O365 Getting Started");
    end;

    local procedure UserHasPermissionsToRunGettingStarted(): Boolean
    var
        DummyO365GettingStarted: Record "O365 Getting Started";
    begin
        if not DummyO365GettingStarted.ReadPermission then
          exit(false);

        if not DummyO365GettingStarted.WritePermission then
          exit(false);

        exit(true);
    end;
}

