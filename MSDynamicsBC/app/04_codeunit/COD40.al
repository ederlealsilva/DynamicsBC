codeunit 40 LogInManagement
{
    // version NAVW113.00

    Permissions = TableData "G/L Entry"=r,
                  TableData Customer=r,
                  TableData Vendor=r,
                  TableData Item=r,
                  TableData "User Time Register"=rimd,
                  TableData "My Customer"=rimd,
                  TableData "My Vendor"=rimd,
                  TableData "My Item"=rimd,
                  TableData "My Account"=rimd;
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        PartnerAgreementNotAcceptedErr: Label 'Partner Agreement has not been accepted.';
        PasswordChangeNeededErr: Label 'You must change the password before you can continue.';
        GLSetup: Record "General Ledger Setup";
        [SecurityFiltering(SecurityFilter::Filtered)]User: Record User;
        LogInWorkDate: Date;
        LogInDate: Date;
        LogInTime: Time;
        GLSetupRead: Boolean;

    procedure CompanyOpen()
    var
        LogonManagement: Codeunit "Logon Management";
    begin
        LogonManagement.SetLogonInProgress(true);

        // This needs to be the very first thing to run before company open
        CODEUNIT.Run(CODEUNIT::"Azure AD User Management");
        CODEUNIT.Run(CODEUNIT::"SaaS Log In Management");

        OnBeforeCompanyOpen;

        if GuiAllowed then
          LogInStart;

        OnAfterCompanyOpen;

        LogonManagement.SetLogonInProgress(false);
    end;

    procedure CompanyClose()
    begin
        OnBeforeCompanyClose;
        if GuiAllowed or (CurrentClientType = CLIENTTYPE::Web) then
          LogInEnd;
        OnAfterCompanyClose;
    end;

    local procedure LogInStart()
    var
        Language: Record "Windows Language";
        LicenseAgreement: Record "License Agreement";
        UserLogin: Record "User Login";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        IdentityManagement: Codeunit "Identity Management";
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
        LanguageManagement: Codeunit LanguageManagement;
    begin
        if not CompanyInformationMgt.IsDemoCompany then
          if LicenseAgreement.Get then
            if LicenseAgreement.GetActive and not LicenseAgreement.Accepted then begin
              PAGE.RunModal(PAGE::"Additional Customer Terms");
              LicenseAgreement.Get;
              if not LicenseAgreement.Accepted then
                Error(PartnerAgreementNotAcceptedErr)
            end;

        Language.SetRange("Localization Exist",true);
        Language.SetRange("Globally Enabled",true);
        Language."Language ID" := GlobalLanguage;
        if not Language.Find then begin
          Language."Language ID" := WindowsLanguage;
          if not Language.Find then
            Language."Language ID" := LanguageManagement.ApplicationLanguage;
        end;
        GlobalLanguage := Language."Language ID";

        // Check if the logged in user must change login before allowing access.
        if not User.IsEmpty then begin
          if IdentityManagement.IsUserNamePasswordAuthentication then begin
            User.SetRange("User Security ID",UserSecurityId);
            User.FindFirst;
            if User."Change Password" then begin
              PAGE.RunModal(PAGE::"Change Password");
              SelectLatestVersion;
              User.FindFirst;
              if User."Change Password" then
                Error(PasswordChangeNeededErr);
            end;
          end;

          User.SetRange("User Security ID");
        end;

        OnBeforeLogInStart;

        InitializeCompany;
        UpdateUserPersonalization;
        CreateProfiles;

        LogInDate := Today;
        LogInTime := Time;
        LogInWorkDate := 0D;
        UserLogin.UpdateLastLoginInfo;

        WorkDate := GetDefaultWorkDate;

        SetupMyRecords;

        ApplicationAreaMgmtFacade.SetupApplicationArea;

        OnAfterLogInStart;
    end;

    local procedure LogInEnd()
    var
        UserSetup: Record "User Setup";
        UserTimeRegister: Record "User Time Register";
        LogOutDate: Date;
        LogOutTime: Time;
        Minutes: Integer;
        UserSetupFound: Boolean;
        RegisterTime: Boolean;
    begin
        if LogInDate = 0D then
          exit;

        if LogInWorkDate <> 0D then
          if LogInWorkDate = LogInDate then
            WorkDate := Today
          else
            WorkDate := LogInWorkDate;

        if UserId <> '' then begin
          if UserSetup.Get(UserId) then begin
            UserSetupFound := true;
            RegisterTime := UserSetup."Register Time";
          end;
          if not UserSetupFound then
            if GetGLSetup then
              RegisterTime := GLSetup."Register Time";
          if RegisterTime then begin
            LogOutDate := Today;
            LogOutTime := Time;
            if (LogOutDate > LogInDate) or (LogOutDate = LogInDate) and (LogOutTime > LogInTime) then
              Minutes := Round((1440 * (LogOutDate - LogInDate)) + ((LogOutTime - LogInTime) / 60000),1);
            if Minutes = 0 then
              Minutes := 1;
            UserTimeRegister.Init;
            UserTimeRegister."User ID" := UserId;
            UserTimeRegister.Date := LogInDate;
            if UserTimeRegister.Find then begin
              UserTimeRegister.Minutes := UserTimeRegister.Minutes + Minutes;
              UserTimeRegister.Modify;
            end else begin
              UserTimeRegister.Minutes := Minutes;
              UserTimeRegister.Insert;
            end;
          end;
        end;

        OnAfterLogInEnd;
    end;

    [Scope('Personalization')]
    procedure InitializeCompany()
    begin
        if not GLSetup.Get then
          CODEUNIT.Run(CODEUNIT::"Company-Initialize");
    end;

    [Scope('Personalization')]
    procedure CreateProfiles()
    var
        "Profile": Record "Profile";
    begin
        if Profile.IsEmpty then begin
          CODEUNIT.Run(CODEUNIT::"Conf./Personalization Mgt.");
          Commit;
        end;
    end;

    local procedure GetGLSetup(): Boolean
    begin
        if not GLSetupRead then
          GLSetupRead := GLSetup.Get;
        exit(GLSetupRead);
    end;

    [Scope('Personalization')]
    procedure GetDefaultWorkDate(): Date
    var
        GLEntry: Record "G/L Entry";
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
    begin
        if CompanyInformationMgt.IsDemoCompany then
          if GLEntry.ReadPermission then begin
            GLEntry.SetCurrentKey("Posting Date");
            if GLEntry.FindLast then begin
              LogInWorkDate := NormalDate(GLEntry."Posting Date");
              exit(NormalDate(GLEntry."Posting Date"));
            end;
          end;

        exit(WorkDate);
    end;

    local procedure SetupMyRecords()
    var
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
    begin
        if not CompanyInformationMgt.IsDemoCompany then
          exit;

        if SetupMyCustomer then
          exit;

        if SetupMyItem then
          exit;

        if SetupMyVendor then
          exit;

        SetupMyAccount;
    end;

    local procedure SetupMyCustomer(): Boolean
    var
        Customer: Record Customer;
        MyCustomer: Record "My Customer";
        MaxCustomersToAdd: Integer;
        I: Integer;
    begin
        if not Customer.ReadPermission then
          exit;

        MyCustomer.SetRange("User ID",UserId);
        if not MyCustomer.IsEmpty then
          exit(true);

        I := 0;
        MaxCustomersToAdd := 5;
        Customer.SetFilter(Balance,'<>0');
        if Customer.FindSet then
          repeat
            I += 1;
            MyCustomer."User ID" := UserId;
            MyCustomer.Validate("Customer No.",Customer."No.");
            if MyCustomer.Insert then;
          until (Customer.Next = 0) or (I >= MaxCustomersToAdd);
    end;

    local procedure SetupMyItem(): Boolean
    var
        Item: Record Item;
        MyItem: Record "My Item";
        MaxItemsToAdd: Integer;
        I: Integer;
    begin
        if not Item.ReadPermission then
          exit;

        MyItem.SetRange("User ID",UserId);
        if not MyItem.IsEmpty then
          exit(true);

        I := 0;
        MaxItemsToAdd := 5;

        Item.SetFilter("Unit Price",'<>0');
        if Item.FindSet then
          repeat
            I += 1;
            MyItem."User ID" := UserId;
            MyItem.Validate("Item No.",Item."No.");
            if MyItem.Insert then;
          until (Item.Next = 0) or (I >= MaxItemsToAdd);
    end;

    local procedure SetupMyVendor(): Boolean
    var
        Vendor: Record Vendor;
        MyVendor: Record "My Vendor";
        MaxVendorsToAdd: Integer;
        I: Integer;
    begin
        if not Vendor.ReadPermission then
          exit;

        MyVendor.SetRange("User ID",UserId);
        if not MyVendor.IsEmpty then
          exit(true);

        I := 0;
        MaxVendorsToAdd := 5;
        Vendor.SetFilter(Balance,'<>0');
        if Vendor.FindSet then
          repeat
            I += 1;
            MyVendor."User ID" := UserId;
            MyVendor.Validate("Vendor No.",Vendor."No.");
            if MyVendor.Insert then;
          until (Vendor.Next = 0) or (I >= MaxVendorsToAdd);
    end;

    local procedure SetupMyAccount(): Boolean
    var
        GLAccount: Record "G/L Account";
        MyAccount: Record "My Account";
        MaxAccountsToAdd: Integer;
        I: Integer;
    begin
        if not GLAccount.ReadPermission then
          exit;

        MyAccount.SetRange("User ID",UserId);
        if not MyAccount.IsEmpty then
          exit(true);

        I := 0;
        MaxAccountsToAdd := 5;
        GLAccount.SetRange("Reconciliation Account",true);
        if GLAccount.FindSet then
          repeat
            I += 1;
            MyAccount."User ID" := UserId;
            MyAccount.Validate("Account No.",GLAccount."No.");
            if MyAccount.Insert then;
          until (GLAccount.Next = 0) or (I >= MaxAccountsToAdd);
    end;

    [Scope('Personalization')]
    procedure AnyUserLoginExistsWithinPeriod(PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period";NoOfPeriods: Integer): Boolean
    var
        UserLogin: Record "User Login";
        PeriodFormManagement: Codeunit PeriodFormManagement;
        FromEventDateTime: DateTime;
    begin
        FromEventDateTime := CreateDateTime(PeriodFormManagement.MoveDateByPeriod(Today,PeriodType,-NoOfPeriods),Time);
        UserLogin.SetFilter("Last Login Date",'>=%1',FromEventDateTime);
        exit(not UserLogin.IsEmpty);
    end;

    [Scope('Personalization')]
    procedure UserLoggedInAtOrAfterDateTime(FromEventDateTime: DateTime): Boolean
    var
        UserLogin: Record "User Login";
    begin
        exit(UserLogin.UserLoggedInAtOrAfter(FromEventDateTime));
    end;

    [EventSubscriber(ObjectType::Codeunit, 2000000004, 'GetSystemIndicator', '', false, false)]
    local procedure GetSystemIndicator(var Text: Text[250];var Style: Option Standard,Accent1,Accent2,Accent3,Accent4,Accent5,Accent6,Accent7,Accent8,Accent9)
    var
        CompanyInformation: Record "Company Information";
    begin
        if CompanyInformation.Get then;
        CompanyInformation.GetSystemIndicator(Text,Style);
    end;

    local procedure UpdateUserPersonalization()
    var
        UserPersonalization: Record "User Personalization";
        "Profile": Record "All Profile";
        AllObjWithCaption: Record AllObjWithCaption;
        PermissionManager: Codeunit "Permission Manager";
        ProfileScope: Option System,Tenant;
        AppID: Guid;
    begin
        if not UserPersonalization.Get(UserSecurityId) then
          exit;

        if Profile.Get(UserPersonalization.Scope,UserPersonalization."App ID",UserPersonalization."Profile ID") then begin
          AllObjWithCaption.SetRange("Object Type",AllObjWithCaption."Object Type"::Page);
          AllObjWithCaption.SetRange("Object Subtype",'RoleCenter');
          AllObjWithCaption.SetRange("Object ID",Profile."Role Center ID");
          if AllObjWithCaption.IsEmpty then begin
            UserPersonalization."Profile ID" := '';
            UserPersonalization.Modify;
            Commit;
          end;
        end else
          if PermissionManager.SoftwareAsAService then begin
            Profile.Reset;
            PermissionManager.GetDefaultProfileID(UserSecurityId,Profile);

            if not Profile.IsEmpty then begin
              UserPersonalization."Profile ID" := Profile."Profile ID";
              UserPersonalization.Scope := Profile.Scope;
              UserPersonalization."App ID" := Profile."App ID";
              UserPersonalization.Modify;
            end else begin
              UserPersonalization."Profile ID" := '';
              UserPersonalization.Scope := ProfileScope::System;
              UserPersonalization."App ID" := AppID;
              UserPersonalization.Modify;
            end;
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 2000000003, 'OnCompanyOpen', '', false, false)]
    local procedure OnCompanyOpen()
    begin
        CompanyOpen;
    end;

    [EventSubscriber(ObjectType::Codeunit, 2000000003, 'OnCompanyClose', '', false, false)]
    local procedure OnCompanyClose()
    begin
        CompanyClose;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterLogInStart()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterLogInEnd()
    begin
    end;

    local procedure OnBeforeLogInStart()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCompanyOpen()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCompanyOpen()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCompanyClose()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCompanyClose()
    begin
    end;
}

