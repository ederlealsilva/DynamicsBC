table 5330 "CRM Connection Setup"
{
    // version NAVW113.00

    Caption = 'Microsoft Dynamics 365 Connection Setup';
    Permissions = TableData "Service Password"=rimd;

    fields
    {
        field(1;"Primary Key";Code[20])
        {
            Caption = 'Primary Key';
        }
        field(2;"Server Address";Text[250])
        {
            Caption = 'Dynamics 365 for Sales URL';

            trigger OnValidate()
            begin
                CRMIntegrationManagement.CheckModifyCRMConnectionURL("Server Address");

                if StrPos("Server Address",'.dynamics.com') > 0 then
                  "Authentication Type" := "Authentication Type"::Office365
                else
                  "Authentication Type" := "Authentication Type"::AD;
                if "User Name" <> '' then
                  UpdateConnectionString;
            end;
        }
        field(3;"User Name";Text[250])
        {
            Caption = 'User Name';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                "User Name" := DelChr("User Name",'<>');
                CheckUserName;
                UpdateDomainName;
                UpdateConnectionString;
            end;
        }
        field(4;"User Password Key";Guid)
        {
            Caption = 'User Password Key';
            DataClassification = EndUserPseudonymousIdentifiers;
        }
        field(5;"Last Update Invoice Entry No.";Integer)
        {
            Caption = 'Last Update Invoice Entry No.';
            Editable = false;
        }
        field(59;"Restore Connection";Boolean)
        {
            Caption = 'Restore Connection';
        }
        field(60;"Is Enabled";Boolean)
        {
            Caption = 'Is Enabled';

            trigger OnValidate()
            begin
                EnableCRMConnection;
                UpdateIsEnabledState;
                RefreshDataFromCRM;
            end;
        }
        field(61;"Is User Mapping Required";Boolean)
        {
            Caption = 'Business Central Users Must Map to Dynamics 365 for Sales Users';

            trigger OnValidate()
            begin
                UpdateAllConnectionRegistrations;
                UpdateIsEnabledState;
            end;
        }
        field(62;"Is User Mapped To CRM User";Boolean)
        {
            Caption = 'Is User Mapped To CRM User';
        }
        field(63;"CRM Version";Text[30])
        {
            Caption = 'CRM Version';
        }
        field(66;"Is S.Order Integration Enabled";Boolean)
        {
            Caption = 'Is S.Order Integration Enabled';

            trigger OnValidate()
            begin
                if "Is S.Order Integration Enabled" then
                  if Confirm(StrSubstNo(SetCRMSOPEnableQst,PRODUCTNAME.Short)) then
                    SetCRMSOPEnabled
                  else
                    Error('')
                else
                  SetCRMSOPDisabled;
                RefreshDataFromCRM;

                if "Is S.Order Integration Enabled" then
                  Message(SetCRMSOPEnableConfirmMsg,CRMProductName.SHORT)
                else
                  Message(SetCRMSOPDisableConfirmMsg,CRMProductName.SHORT);
            end;
        }
        field(67;"Is CRM Solution Installed";Boolean)
        {
            Caption = 'Is CRM Solution Installed';
        }
        field(68;"Is Enabled For User";Boolean)
        {
            Caption = 'Is Enabled For User';
        }
        field(69;"Dynamics NAV URL";Text[250])
        {
            Caption = 'Dynamics NAV URL';

            trigger OnValidate()
            begin
                CRMIntegrationManagement.SetCRMNAVConnectionUrl("Dynamics NAV URL");
            end;
        }
        field(70;"Dynamics NAV OData URL";Text[250])
        {
            Caption = 'Dynamics NAV OData URL';

            trigger OnValidate()
            begin
                CRMIntegrationManagement.SetCRMNAVODataUrlCredentials(
                  "Dynamics NAV OData URL","Dynamics NAV OData Username","Dynamics NAV OData Accesskey");
            end;
        }
        field(71;"Dynamics NAV OData Username";Text[250])
        {
            Caption = 'Dynamics NAV OData Username';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnLookup()
            var
                User: Record User;
            begin
                if PAGE.RunModal(PAGE::Users,User) = ACTION::LookupOK then
                  UpdateODataUsernameAccesskey(User);
            end;

            trigger OnValidate()
            var
                User: Record User;
            begin
                User.SetRange("User Name","Dynamics NAV OData Username");
                if User.FindFirst then
                  UpdateODataUsernameAccesskey(User)
                else begin
                  "Dynamics NAV OData Username" := '';
                  "Dynamics NAV OData Accesskey" := '';
                end;
            end;
        }
        field(72;"Dynamics NAV OData Accesskey";Text[250])
        {
            Caption = 'Dynamics NAV OData Accesskey';
        }
        field(75;"Default CRM Price List ID";Guid)
        {
            Caption = 'Default CRM Price List ID';
        }
        field(76;"Proxy Version";Integer)
        {
            Caption = 'Proxy Version';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                UpdateConnectionString;
            end;
        }
        field(80;"Auto Create Sales Orders";Boolean)
        {
            Caption = 'Automatically Create Sales Orders';

            trigger OnValidate()
            var
                CRMSetupDefaults: Codeunit "CRM Setup Defaults";
            begin
                if "Auto Create Sales Orders" then
                  CRMSetupDefaults.RecreateAutoCreateSalesOrdersJobQueueEntry(DoReadCRMData)
                else
                  CRMSetupDefaults.DeleteAutoCreateSalesOrdersJobQueueEntry;
            end;
        }
        field(118;CurrencyDecimalPrecision;Integer)
        {
            Caption = 'Currency Decimal Precision';
            Description = 'Number of decimal places that can be used for currency.';
        }
        field(124;BaseCurrencyId;Guid)
        {
            Caption = 'Currency';
            Description = 'Unique identifier of the base currency of the organization.';
            ExternalAccess = Insert;
            TableRelation = "CRM Transactioncurrency".TransactionCurrencyId;
        }
        field(133;BaseCurrencyPrecision;Integer)
        {
            Caption = 'Base Currency Precision';
            Description = 'Number of decimal places that can be used for the base currency.';
            ExternalAccess = Read;
            MaxValue = 4;
            MinValue = 0;
        }
        field(134;BaseCurrencySymbol;Text[5])
        {
            Caption = 'Base Currency Symbol';
            Description = 'Symbol used for the base currency.';
            ExternalAccess = Read;
        }
        field(135;"Authentication Type";Option)
        {
            Caption = 'Authentication Type';
            OptionCaption = 'Office365,AD,IFD,OAuth';
            OptionMembers = Office365,AD,IFD,OAuth;

            trigger OnValidate()
            begin
                if xRec."Authentication Type" <> "Authentication Type" then
                  Validate("Is User Mapping Required",false);
                case "Authentication Type" of
                  "Authentication Type"::Office365:
                    Domain := '';
                  "Authentication Type"::AD:
                    UpdateDomainName;
                end;
                UpdateConnectionString;
            end;
        }
        field(136;"Connection String";Text[250])
        {
            Caption = 'Connection String';
        }
        field(137;Domain;Text[250])
        {
            Caption = 'Domain';
            DataClassification = OrganizationIdentifiableInformation;
            Editable = false;
        }
        field(138;"Server Connection String";BLOB)
        {
            Caption = 'Server Connection String';
        }
        field(139;"Disable Reason";Text[250])
        {
            Caption = 'Disable Reason';
        }
    }

    keys
    {
        key(Key1;"Primary Key")
        {
        }
    }

    fieldgroups
    {
    }

    var
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
        CantRegisterDisabledConnectionErr: Label 'A disabled connection cannot be registered.';
        ConnectionErr: Label 'The connection setup cannot be validated. Verify the settings and try again.\Detailed error description: %1.', Comment='%1 Error message from the provider (.NET exception message)';
        ConnectionStringFormatTok: Label 'Url=%1; UserName=%2; Password=%3; ProxyVersion=%4; %5', Locked=true;
        ConnectionSuccessMsg: Label 'The connection test was successful. The settings are valid.';
        ConnectionSuccessNotEnabledForCurrentUserMsg: Label 'The connection test was successful. The settings are valid.\\However, because the %2 Users Must Map to %3 Users field is set, %3 integration is not enabled for %1.', Comment='%1 = Current User ID, %2 - product name, %3 = CRM product name';
        CannotResolveUserFromConnectionSetupErr: Label 'The %1 user that is specified in the CRM connection setup does not exist.', Comment='%1 = CRM product name';
        DetailsMissingErr: Label 'A %1 URL, user name and password are required to enable a connection.', Comment='%1 = CRM product name';
        MissingUsernameTok: Label '{USER}', Locked=true;
        MissingPasswordTok: Label '{PASSWORD}', Locked=true;
        ProcessDialogMapTitleMsg: Label 'Synchronizing @1', Comment='@1 Progress dialog map no.';
        UserCRMSetupTxt: Label 'User CRM Setup';
        CannotConnectCRMErr: Label 'The system is unable to connect to %2, and the connection has been disabled. Verify the credentials of the user account %1, and then enable the connection again in the Microsoft Dynamics 365 Connection Setup window.', Comment='%1 - email of the user, %2 = CRM product name';
        LCYMustMatchBaseCurrencyErr: Label 'LCY Code %1 does not match ISO Currency Code %2 of the CRM base currency.', Comment='%1,%2 - ISO currency codes';
        UserNameMustIncludeDomainErr: Label 'The user name must include the domain when the authentication type is set to Active Directory.';
        UserNameMustBeEmailErr: Label 'The user name must be a valid email address when the authentication type is set to Office 365.';
        ConnectionStringPwdPlaceHolderMissingErr: Label 'The connection string must include the password placeholder {PASSWORD}.';
        CannotDisableSalesOrderIntErr: Label 'You cannot disable CRM sales order integration when a CRM sales order has the Submitted status.';
        SetCRMSOPEnableQst: Label 'Enabling Sales Order Integration will allow you to create %1 Sales Orders from Dynamics CRM.\\To enable this setting, you must provide Dynamics CRM administrator credentials (user name and password).\\Do you want to continue?', Comment='%1 - product name';
        SetCRMSOPEnableConfirmMsg: Label 'Sales Order Integration with %1 is enabled.', Comment='%1 = CRM product name';
        SetCRMSOPDisableConfirmMsg: Label 'Sales Order Integration with %1 is disabled.', Comment='%1 = CRM product name';
        CRMProductName: Codeunit "CRM Product Name";

    [Scope('Personalization')]
    procedure CountCRMJobQueueEntries(var ActiveJobs: Integer;var TotalJobs: Integer)
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if not "Is Enabled" then begin
          TotalJobs := 0;
          ActiveJobs := 0;
        end else begin
          if "Is CRM Solution Installed" then
            JobQueueEntry.SetFilter("Object ID to Run",GetJobQueueEntriesObjectIDToRunFilter)
          else
            JobQueueEntry.SetRange("Object ID to Run",CODEUNIT::"Integration Synch. Job Runner");
          TotalJobs := JobQueueEntry.Count;

          JobQueueEntry.SetFilter(Status,'%1|%2',JobQueueEntry.Status::Ready,JobQueueEntry.Status::"In Process");
          ActiveJobs := JobQueueEntry.Count;
        end;
    end;

    [Scope('Personalization')]
    procedure HasPassword(): Boolean
    begin
        exit(GetPassword <> '');
    end;

    [Scope('Personalization')]
    procedure SetPassword(PasswordText: Text)
    var
        ServicePassword: Record "Service Password";
    begin
        if IsNullGuid("User Password Key") or not ServicePassword.Get("User Password Key") then begin
          ServicePassword.SavePassword(PasswordText);
          ServicePassword.Insert(true);
          "User Password Key" := ServicePassword.Key;
        end else begin
          ServicePassword.SavePassword(PasswordText);
          ServicePassword.Modify;
        end;
    end;

    procedure UpdateAllConnectionRegistrations()
    begin
        UnregisterTableConnection(TABLECONNECTIONTYPE::CRM,GetDefaultTableConnection(TABLECONNECTIONTYPE::CRM));

        UnregisterConnection;
        if "Is Enabled" then
          RegisterUserConnection;
    end;

    [Scope('Personalization')]
    procedure UpdateIsEnabledState()
    begin
        "Is User Mapped To CRM User" := IsCurrentUserMappedToCrmSystemUser;
        "Is Enabled For User" :=
          "Is Enabled" and
          ((not "Is User Mapping Required") or ("Is User Mapping Required" and "Is User Mapped To CRM User"));
    end;

    local procedure UpdateODataUsernameAccesskey(User: Record User)
    var
        IdentityManagement: Codeunit "Identity Management";
    begin
        "Dynamics NAV OData Username" := User."User Name";
        "Dynamics NAV OData Accesskey" := IdentityManagement.GetWebServicesKey(User."User Security ID");

        CRMIntegrationManagement.SetCRMNAVODataUrlCredentials(
          "Dynamics NAV OData URL","Dynamics NAV OData Username","Dynamics NAV OData Accesskey");
    end;

    [Scope('Personalization')]
    procedure RegisterConnection()
    begin
        if not HasTableConnection(TABLECONNECTIONTYPE::CRM,"Primary Key") then
          RegisterConnectionWithName("Primary Key");
    end;

    [Scope('Personalization')]
    procedure RegisterConnectionWithName(ConnectionName: Text)
    begin
        RegisterTableConnection(TABLECONNECTIONTYPE::CRM,ConnectionName,GetConnectionStringWithPassword);
        SetDefaultTableConnection(TABLECONNECTIONTYPE::CRM,GetDefaultCRMConnection(ConnectionName));
    end;

    [Scope('Personalization')]
    procedure UnregisterConnection(): Boolean
    begin
        exit(UnregisterConnectionWithName("Primary Key"));
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure UnregisterConnectionWithName(ConnectionName: Text)
    begin
        UnregisterTableConnection(TABLECONNECTIONTYPE::CRM,ConnectionName);
    end;

    local procedure ConstructConnectionStringWithCalledID(CallerID: Text): Text
    begin
        exit(GetConnectionStringWithPassword + 'CallerID=' + CallerID);
    end;

    procedure GetConnectionStringWithPassword() ConnectionString: Text
    var
        PasswordPlaceHolderPos: Integer;
    begin
        ConnectionString := GetConnectionString;
        if ConnectionString = '' then
          ConnectionString := UpdateConnectionString;
        if "User Name" = '' then
          exit(ConnectionString);
        PasswordPlaceHolderPos := StrPos(ConnectionString,MissingPasswordTok);
        ConnectionString :=
          CopyStr(ConnectionString,1,PasswordPlaceHolderPos - 1) + GetPassword +
          CopyStr(ConnectionString,PasswordPlaceHolderPos + StrLen(MissingPasswordTok));
    end;

    procedure RegisterUserConnection() ConnectionName: Text
    var
        SyncUser: Record User;
        CallerID: Guid;
    begin
        RegisterConnection;
        SyncUser."User Name" := CopyStr("User Name",1,MaxStrLen(SyncUser."User Name"));
        SyncUser."Authentication Email" := "User Name";
        if not TryGetSystemUserId(SyncUser,CallerID) then begin
          UnregisterConnection;
          Validate("Is Enabled",false);
          Validate("Is User Mapping Required",false);
          Modify;
          ShowError(UserCRMSetupTxt,StrSubstNo(CannotConnectCRMErr,"User Name",CRMProductName.SHORT));
        end else
          ConnectionName := RegisterAuthUserConnection;
    end;

    local procedure RegisterAuthUserConnection() ConnectionName: Text
    var
        User: Record User;
        CallerID: Guid;
    begin
        if GetUser(User) then
          if not TryGetSystemUserId(User,CallerID) then begin
            UnregisterConnection;
            ShowError(UserCRMSetupTxt,StrSubstNo(CannotConnectCRMErr,User."Authentication Email"));
          end else
            if not IsNullGuid(CallerID) then begin
              UnregisterConnection;
              ConnectionName := RegisterConnectionWithCallerID(CallerID);
            end;
    end;

    local procedure RegisterConnectionWithCallerID(CallerID: Text) ConnectionName: Text
    begin
        if "Is Enabled" then begin
          RegisterTableConnection(TABLECONNECTIONTYPE::CRM,"Primary Key",ConstructConnectionStringWithCalledID(CallerID));
          ConnectionName := "Primary Key";
          if "Primary Key" = '' then begin
            ConnectionName := GetDefaultCRMConnection("Primary Key");
            SetDefaultTableConnection(TABLECONNECTIONTYPE::CRM,ConnectionName);
          end;
        end else
          ShowError(UserCRMSetupTxt,CantRegisterDisabledConnectionErr);
    end;

    [Scope('Personalization')]
    procedure GetIntegrationUserID() IntegrationUserID: Guid
    var
        CRMSystemuser: Record "CRM Systemuser";
    begin
        Get;
        TestField("Is Enabled");
        FilterCRMSystemUser(CRMSystemuser);
        if CRMSystemuser.FindFirst then
          IntegrationUserID := CRMSystemuser.SystemUserId;
        if IsNullGuid(IntegrationUserID) then
          ShowError(UserCRMSetupTxt,StrSubstNo(CannotResolveUserFromConnectionSetupErr,CRMProductName.SHORT));
    end;

    local procedure GetPassword(): Text
    var
        ServicePassword: Record "Service Password";
    begin
        if not IsNullGuid("User Password Key") then
          if ServicePassword.Get("User Password Key") then
            exit(ServicePassword.GetPassword);
    end;

    local procedure GetUser(var User: Record User): Boolean
    begin
        if User.Get(DATABASE.UserSecurityId) then
          exit(true);
        User.Reset;
        User.SetRange("Windows Security ID",Sid);
        exit(User.FindFirst);
    end;

    local procedure GetUserName() UserName: Text
    begin
        if "User Name" = '' then
          UserName := MissingUsernameTok
        else
          UserName := CopyStr("User Name",StrPos("User Name",'\') + 1);
    end;

    procedure GetJobQueueEntriesObjectIDToRunFilter(): Text
    begin
        exit(
          StrSubstNo(
            '%1|%2|%3',
            CODEUNIT::"Integration Synch. Job Runner",
            CODEUNIT::"CRM Statistics Job",
            CODEUNIT::"Auto Create Sales Orders"));
    end;

    procedure PerformTestConnection()
    begin
        VerifyTestConnection;

        if "Is User Mapping Required" and "Is Enabled" then
          if not IsCurrentUserMappedToCrmSystemUser then begin
            Message(ConnectionSuccessNotEnabledForCurrentUserMsg,UserId,PRODUCTNAME.Short,CRMProductName.SHORT);
            exit;
          end;

        Message(ConnectionSuccessMsg);
    end;

    procedure VerifyTestConnection(): Boolean
    begin
        if ("Server Address" = '') or ("User Name" = '') or not HasPassword then
          Error(DetailsMissingErr,CRMProductName.SHORT);

        CRMIntegrationManagement.ClearState;

        if not TestConnection then
          Error(ConnectionErr,CRMIntegrationManagement.GetLastErrorMessage);

        exit(true);
    end;

    [Scope('Personalization')]
    procedure TestConnection() Success: Boolean
    var
        TestConnectionName: Text;
    begin
        TestConnectionName := Format(CreateGuid);
        UnregisterConnectionWithName(TestConnectionName);
        RegisterConnectionWithName(TestConnectionName);
        SetDefaultTableConnection(
          TABLECONNECTIONTYPE::CRM,GetDefaultCRMConnection(TestConnectionName),true);
        Success := TryReadSystemUsers;

        UnregisterConnectionWithName(TestConnectionName);
    end;

    [TryFunction]
    procedure TryReadSystemUsers()
    var
        CRMSystemuser: Record "CRM Systemuser";
    begin
        CRMSystemuser.FindFirst;
    end;

    local procedure CreateOrganizationService(var CRMHelper: DotNet CrmHelper)
    begin
        CRMHelper := CRMHelper.CrmHelper(GetConnectionStringWithPassword);
    end;

    [TryFunction]
    local procedure GetCrmVersion(var Version: Text)
    var
        CRMHelper: DotNet CrmHelper;
    begin
        if not DoReadCRMData then
          exit;

        Version := '';
        CreateOrganizationService(CRMHelper);
        Version := CRMHelper.GetConnectedCrmVersion;
    end;

    [Scope('Personalization')]
    procedure IsVersionValid(): Boolean
    var
        Version: DotNet Version;
    begin
        if "CRM Version" <> '' then
          if Version.TryParse("CRM Version",Version) then
            exit((Version.Major > 6) and not ((Version.Major = 7) and (Version.Minor = 1)));
        exit(false);
    end;

    procedure IsCurrentUserMappedToCrmSystemUser(): Boolean
    var
        User: Record User;
        CRMSystemUserId: Guid;
    begin
        if GetUser(User) then
          if TryGetSystemUserId(User,CRMSystemUserId) then
            exit(not IsNullGuid(CRMSystemUserId));
    end;

    [TryFunction]
    local procedure TryGetSystemUserId(User: Record User;var SystemUserId: Guid)
    var
        CRMSystemuser: Record "CRM Systemuser";
    begin
        // Returns FALSE if CRMSystemuser.FINDFIRST throws an exception, e.g. due to wrong credentials;
        // Returns TRUE regardless of CRMSystemuser.FINDFIRST result,
        // further check of ISNULLGUID(SystemUserId) is required to identify if the user exists
        Clear(SystemUserId);
        if "Is Enabled" then
          if "Is User Mapping Required" then begin
            CRMSystemuser.SetRange(IsDisabled,false);
            case "Authentication Type" of
              "Authentication Type"::AD,"Authentication Type"::IFD:
                CRMSystemuser.SetRange(DomainName,User."User Name");
              "Authentication Type"::Office365,"Authentication Type"::OAuth:
                CRMSystemuser.SetRange(InternalEMailAddress,User."Authentication Email");
            end;
            if CRMSystemuser.FindFirst then
              SystemUserId := CRMSystemuser.SystemUserId;
          end;
    end;

    [Scope('Personalization')]
    procedure UpdateFromWizard(var SourceCRMConnectionSetup: Record "CRM Connection Setup";PasswordText: Text)
    begin
        if not Get then begin
          Init;
          Insert;
        end;
        Validate("Server Address",SourceCRMConnectionSetup."Server Address");
        Validate("Authentication Type","Authentication Type"::Office365);
        Validate("User Name",SourceCRMConnectionSetup."User Name");
        SetPassword(PasswordText);
        Validate("Proxy Version",SourceCRMConnectionSetup."Proxy Version");
        Modify(true);
    end;

    local procedure EnableCRMConnection()
    begin
        if "Is Enabled" = xRec."Is Enabled" then
          exit;

        if not UnregisterConnection then
          ClearLastError;

        if "Is Enabled" then begin
          VerifyTestConnection;
          RegisterUserConnection;
          VerifyBaseCurrencyMatchesLCY;
          EnableIntegrationTables;
          if "Disable Reason" <> '' then
            CRMIntegrationManagement.ClearConnectionDisableReason(Rec);
        end else begin
          "CRM Version" := '';
          "Is S.Order Integration Enabled" := false;
          "Is CRM Solution Installed" := false;
          CurrencyDecimalPrecision := 0;
          Clear(BaseCurrencyId);
          BaseCurrencyPrecision := 0;
          BaseCurrencySymbol := '';
          UpdateCRMJobQueueEntriesStatus;
          CRMIntegrationManagement.ClearState;
        end;
    end;

    local procedure EnableIntegrationTables()
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationRecord: Record "Integration Record";
        IntegrationManagement: Codeunit "Integration Management";
        CRMSetupDefaults: Codeunit "CRM Setup Defaults";
    begin
        if IntegrationRecord.IsEmpty then
          IntegrationManagement.SetupIntegrationTables;
        IntegrationManagement.SetConnectorIsEnabledForSession(true);
        if IntegrationTableMapping.IsEmpty then begin
          Modify; // Job Queue to read "Is Enabled"
          Commit;
          CRMSetupDefaults.ResetConfiguration(Rec);
        end else
          UpdateCRMJobQueueEntriesStatus;
    end;

    [Scope('Personalization')]
    procedure EnableCRMConnectionFromWizard()
    var
        CRMSystemuser: Record "CRM Systemuser";
    begin
        Get;
        "Is User Mapping Required" := false;
        Validate("Is Enabled",true);
        Modify(true);

        FilterCRMSystemUser(CRMSystemuser);
        CRMSystemuser.FindFirst;
        if (CRMSystemuser.InviteStatusCode <> CRMSystemuser.InviteStatusCode::InvitationAccepted) or
           (not CRMSystemuser.IsIntegrationUser)
        then begin
          CRMSystemuser.InviteStatusCode := CRMSystemuser.InviteStatusCode::InvitationAccepted;
          CRMSystemuser.IsIntegrationUser := true;
          CRMSystemuser.Modify(true);
        end;
    end;

    procedure RestoreConnection()
    begin
        // This function should be called from OnAfterUpgradeComplete trigger (when introduced)
        if "Restore Connection" then begin
          "Restore Connection" := false;
          Modify;
          Commit;
          if TestConnection then
            Validate("Is Enabled",true);
          Modify;
        end;
    end;

    [Scope('Personalization')]
    procedure SetCRMSOPEnabled()
    begin
        TestField("Is CRM Solution Installed",true);
        SetCRMSOPEnabledWithCredentials('',CreateGuid,true);
    end;

    procedure SetCRMSOPDisabled()
    var
        CRMSalesorder: Record "CRM Salesorder";
    begin
        CRMSalesorder.SetRange(StateCode,CRMSalesorder.StateCode::Submitted);
        if not CRMSalesorder.IsEmpty then
          Error(CannotDisableSalesOrderIntErr);
        SetCRMSOPEnabledWithCredentials('',CreateGuid,false);
        Validate("Auto Create Sales Orders",false);
    end;

    [Scope('Personalization')]
    procedure SetCRMSOPEnabledWithCredentials(AdminEmail: Text[250];AdminPassKey: Guid;SOPIntegrationEnable: Boolean)
    var
        CRMOrganization: Record "CRM Organization";
        TempCRMConnectionSetup: Record "CRM Connection Setup" temporary;
        ServicePassword: Record "Service Password";
        ConnectionName: Text;
    begin
        CreateTempAdminConnection(TempCRMConnectionSetup);
        if (AdminEmail <> '') and (not IsNullGuid(AdminPassKey)) then begin
          ServicePassword.Get(AdminPassKey);
          TempCRMConnectionSetup.SetPassword(ServicePassword.GetPassword);
          TempCRMConnectionSetup.Validate("User Name",AdminEmail);
        end;
        ConnectionName := Format(CreateGuid);
        TempCRMConnectionSetup.RegisterConnectionWithName(ConnectionName);
        SetDefaultTableConnection(
          TABLECONNECTIONTYPE::CRM,GetDefaultCRMConnection(ConnectionName),true);

        CRMOrganization.FindFirst;
        if CRMOrganization.IsSOPIntegrationEnabled <> SOPIntegrationEnable then begin
          CRMOrganization.IsSOPIntegrationEnabled := SOPIntegrationEnable;
          CRMOrganization.Modify(true);
        end;

        TempCRMConnectionSetup.UnregisterConnectionWithName(ConnectionName);
    end;

    [Scope('Personalization')]
    procedure SetUserAsIntegrationUser()
    var
        CRMSystemuser: Record "CRM Systemuser";
        TempCRMConnectionSetup: Record "CRM Connection Setup" temporary;
        ConnectionName: Text;
    begin
        CreateTempAdminConnection(TempCRMConnectionSetup);
        ConnectionName := Format(CreateGuid);
        TempCRMConnectionSetup.RegisterConnectionWithName(ConnectionName);
        SetDefaultTableConnection(
          TABLECONNECTIONTYPE::CRM,GetDefaultCRMConnection(ConnectionName),true);
        FilterCRMSystemUser(CRMSystemuser);
        CRMSystemuser.FindFirst;

        if (CRMSystemuser.InviteStatusCode <> CRMSystemuser.InviteStatusCode::InvitationAccepted) or
           (not CRMSystemuser.IsIntegrationUser)
        then begin
          CRMSystemuser.InviteStatusCode := CRMSystemuser.InviteStatusCode::InvitationAccepted;
          CRMSystemuser.IsIntegrationUser := true;
          CRMSystemuser.Modify(true);
        end;

        TempCRMConnectionSetup.UnregisterConnectionWithName(ConnectionName);
    end;

    local procedure CreateTempAdminConnection(var CRMConnectionSetup: Record "CRM Connection Setup")
    begin
        CreateTempNoDelegateConnection(CRMConnectionSetup);
        Clear(CRMConnectionSetup."User Password Key");
        CRMConnectionSetup.Validate("User Name",'');
    end;

    local procedure CreateTempNoDelegateConnection(var CRMConnectionSetup: Record "CRM Connection Setup")
    begin
        CRMConnectionSetup.Init;
        CalcFields("Server Connection String");
        CRMConnectionSetup.TransferFields(Rec);
        CRMConnectionSetup."Primary Key" := CopyStr('TEMP' + "Primary Key",1,MaxStrLen(CRMConnectionSetup."Primary Key"));
        CRMConnectionSetup."Is Enabled" := true;
        CRMConnectionSetup."Is User Mapping Required" := false;
    end;

    procedure RefreshDataFromCRM()
    var
        TempCRMConnectionSetup: Record "CRM Connection Setup" temporary;
        ConnectionName: Text;
    begin
        if "Is Enabled" then begin
          if "Is User Mapping Required" then begin
            CreateTempNoDelegateConnection(TempCRMConnectionSetup);
            ConnectionName := Format(CreateGuid);
            TempCRMConnectionSetup.RegisterConnectionWithName(ConnectionName);
            "Is User Mapped To CRM User" := IsCurrentUserMappedToCrmSystemUser;
          end;

          "Is CRM Solution Installed" := CRMIntegrationManagement.IsCRMSolutionInstalled;
          RefreshFromCRMConnectionInformation;
          if TryRefreshCRMSettings then;

          if ConnectionName <> '' then
            TempCRMConnectionSetup.UnregisterConnectionWithName(ConnectionName);
        end;
    end;

    local procedure RefreshFromCRMConnectionInformation()
    var
        CRMNAVConnection: Record "CRM NAV Connection";
    begin
        if "Is CRM Solution Installed" then
          if CRMNAVConnection.FindFirst then begin
            "Dynamics NAV URL" := CRMNAVConnection."Dynamics NAV URL";
            "Dynamics NAV OData URL" := CRMNAVConnection."Dynamics NAV OData URL";
            "Dynamics NAV OData Username" := CRMNAVConnection."Dynamics NAV OData Username";
            "Dynamics NAV OData Accesskey" := CRMNAVConnection."Dynamics NAV OData Accesskey";
          end;
    end;

    [TryFunction]
    local procedure TryRefreshCRMSettings()
    var
        CRMOrganization: Record "CRM Organization";
    begin
        GetCrmVersion("CRM Version");
        Validate("CRM Version");

        if CRMOrganization.FindFirst then begin
          "Is S.Order Integration Enabled" := CRMOrganization.IsSOPIntegrationEnabled;
          CurrencyDecimalPrecision := CRMOrganization.CurrencyDecimalPrecision;
          BaseCurrencyId := CRMOrganization.BaseCurrencyId;
          BaseCurrencyPrecision := CRMOrganization.BaseCurrencyPrecision;
          BaseCurrencySymbol := CRMOrganization.BaseCurrencySymbol;
        end else
          "Is S.Order Integration Enabled" := false;
    end;

    local procedure VerifyBaseCurrencyMatchesLCY()
    var
        CRMOrganization: Record "CRM Organization";
        CRMTransactioncurrency: Record "CRM Transactioncurrency";
        GLSetup: Record "General Ledger Setup";
    begin
        CRMOrganization.FindFirst;
        CRMTransactioncurrency.Get(CRMOrganization.BaseCurrencyId);
        GLSetup.Get;
        if DelChr(CRMTransactioncurrency.ISOCurrencyCode) <> DelChr(GLSetup."LCY Code") then
          Error(LCYMustMatchBaseCurrencyErr,GLSetup."LCY Code",CRMTransactioncurrency.ISOCurrencyCode);
    end;

    procedure PerformWebClientUrlReset()
    var
        TempCRMConnectionSetup: Record "CRM Connection Setup" temporary;
        CRMSetupDefaults: Codeunit "CRM Setup Defaults";
        ConnectionName: Text;
    begin
        CreateTempNoDelegateConnection(TempCRMConnectionSetup);
        ConnectionName := Format(CreateGuid);
        TempCRMConnectionSetup.RegisterConnectionWithName(ConnectionName);
        SetDefaultTableConnection(
          TABLECONNECTIONTYPE::CRM,GetDefaultCRMConnection(ConnectionName),true);

        CRMSetupDefaults.ResetCRMNAVConnectionData;

        TempCRMConnectionSetup.UnregisterConnectionWithName(ConnectionName);

        RefreshDataFromCRM;
    end;

    [Scope('Personalization')]
    procedure SynchronizeNow(DoFullSynch: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        CRMSetupDefaults: Codeunit "CRM Setup Defaults";
        ProgressWindow: Dialog;
        MappingCount: Integer;
        CurrentMappingIndex: Integer;
    begin
        CRMSetupDefaults.GetPrioritizedMappingList(TempNameValueBuffer);
        TempNameValueBuffer.Ascending(true);
        TempNameValueBuffer.FindSet;

        CurrentMappingIndex := 0;
        MappingCount := TempNameValueBuffer.Count;
        ProgressWindow.Open(ProcessDialogMapTitleMsg,CurrentMappingIndex);
        repeat
          CurrentMappingIndex := CurrentMappingIndex + 1;
          ProgressWindow.Update(1,Round(CurrentMappingIndex / MappingCount * 10000,1));
          if IntegrationTableMapping.Get(TempNameValueBuffer.Value) then
            IntegrationTableMapping.SynchronizeNow(DoFullSynch);
        until TempNameValueBuffer.Next = 0;
        ProgressWindow.Close;
    end;

    local procedure ShowError(ActivityDescription: Text[128];ErrorMessage: Text)
    var
        MyNotifications: Record "My Notifications";
        LogonManagement: Codeunit "Logon Management";
    begin
        if not LogonManagement.IsLogonInProgress then
          Error(ErrorMessage);

        MyNotifications.InsertDefault(GetCRMNotificationId,ActivityDescription,ErrorMessage,true);
    end;

    local procedure GetCRMNotificationId(): Guid
    begin
        exit('692A2701-4BBB-4C5B-B4C0-629D96B60644');
    end;

    procedure DoReadCRMData(): Boolean
    var
        SkipReading: Boolean;
    begin
        OnReadingCRMData(SkipReading);
        exit(not SkipReading);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReadingCRMData(var SkipReading: Boolean)
    begin
    end;

    procedure GetDefaultCRMConnection(ConnectionName: Text): Text
    begin
        OnGetDefaultCRMConnection(ConnectionName);
        exit(ConnectionName);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetDefaultCRMConnection(var ConnectionName: Text)
    begin
    end;

    local procedure CrmAuthenticationType(): Text
    begin
        case "Authentication Type" of
          "Authentication Type"::Office365:
            exit('AuthType=Office365;');
          "Authentication Type"::AD:
            exit('AuthType=AD;' + GetDomain);
          "Authentication Type"::IFD:
            exit('AuthType=IFD;' + GetDomain + 'HomeRealmUri= ;');
          "Authentication Type"::OAuth:
            exit('AuthType=OAuth;' + 'AppId= ;' + 'RedirectUri= ;' + 'TokenCacheStorePath= ;' + 'LoginPrompt=Auto;');
        end;
    end;

    procedure UpdateConnectionString() ConnectionString: Text
    begin
        ConnectionString :=
          StrSubstNo(
            ConnectionStringFormatTok,"Server Address",GetUserName,MissingPasswordTok,"Proxy Version",CrmAuthenticationType);
        SetConnectionString(ConnectionString);
    end;

    local procedure UpdateDomainName()
    begin
        if "User Name" <> '' then
          if StrPos("User Name",'\') > 0 then
            Validate(Domain,CopyStr("User Name",1,StrPos("User Name",'\') - 1))
          else
            Domain := '';
    end;

    local procedure CheckUserName()
    begin
        if "User Name" <> '' then
          case "Authentication Type" of
            "Authentication Type"::AD:
              if StrPos("User Name",'\') = 0 then
                Error(UserNameMustIncludeDomainErr);
            "Authentication Type"::Office365:
              if StrPos("User Name",'@') = 0 then
                Error(UserNameMustBeEmailErr);
          end;
    end;

    local procedure GetDomain(): Text
    begin
        if Domain <> '' then
          exit(StrSubstNo('Domain=%1;',Domain));
    end;

    local procedure FilterCRMSystemUser(var CRMSystemuser: Record "CRM Systemuser")
    begin
        case "Authentication Type" of
          "Authentication Type"::Office365,"Authentication Type"::OAuth:
            CRMSystemuser.SetRange(InternalEMailAddress,"User Name");
          "Authentication Type"::AD,"Authentication Type"::IFD:
            CRMSystemuser.SetRange(DomainName,"User Name");
        end;
    end;

    procedure UpdateCRMJobQueueEntriesStatus()
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        JobQueueEntry: Record "Job Queue Entry";
        NewStatus: Option;
    begin
        if "Is Enabled" then
          NewStatus := JobQueueEntry.Status::Ready
        else
          NewStatus := JobQueueEntry.Status::"On Hold";
        IntegrationTableMapping.SetRange("Synch. Codeunit ID",CODEUNIT::"CRM Integration Table Synch.");
        IntegrationTableMapping.SetRange("Delete After Synchronization",false);
        if IntegrationTableMapping.FindSet then
          repeat
            JobQueueEntry.SetRange("Record ID to Process",IntegrationTableMapping.RecordId);
            if JobQueueEntry.FindSet then
              repeat
                JobQueueEntry.SetStatus(NewStatus);
              until JobQueueEntry.Next = 0;
          until IntegrationTableMapping.Next = 0;
    end;

    procedure UpdateLastUpdateInvoiceEntryNo(): Boolean
    var
        DtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
    begin
        Get;
        DtldCustLedgEntry.Reset;
        if DtldCustLedgEntry.FindLast then
          if "Last Update Invoice Entry No." <> DtldCustLedgEntry."Entry No." then begin
            "Last Update Invoice Entry No." := DtldCustLedgEntry."Entry No.";
            exit(Modify);
          end;
    end;

    procedure GetConnectionString() ConnectionString: Text
    var
        CRMConnectionSetup: Record "CRM Connection Setup";
        InStream: InStream;
    begin
        if CRMConnectionSetup.Get("Primary Key") then
          CalcFields("Server Connection String");
        "Server Connection String".CreateInStream(InStream);
        InStream.ReadText(ConnectionString);
    end;

    procedure SetConnectionString(ConnectionString: Text)
    var
        OutStream: OutStream;
    begin
        if ConnectionString = '' then
          Clear("Server Connection String")
        else begin
          if StrPos(ConnectionString,MissingPasswordTok) = 0 then
            Error(ConnectionStringPwdPlaceHolderMissingErr);
          Clear("Server Connection String");
          "Server Connection String".CreateOutStream(OutStream);
          OutStream.WriteText(ConnectionString);
        end;
        if not Modify then ;
    end;
}

