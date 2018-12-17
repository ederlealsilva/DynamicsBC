codeunit 1800 "Assisted Company Setup"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        EnableWizardErr: Label 'You cannot enable the assisted company setup for an already active company.';
        NoConfigPackageFileMsg: Label 'There are no configuration package files defined in your system. Assisted company setup will not be fully functional. Please contact your system administrator.';
        CompanyIsBeingSetUpMsg: Label 'The Company is being set up. Please wait...';
        StandardTxt: Label 'Standard', Locked=true;
        EvaluationTxt: Label 'Evaluation', Locked=true;
        ExtendedTxt: Label 'Extended', Locked=true;
        CreatingCompanyMsg: Label 'Creating company...';
        NoPermissionsErr: Label 'You do not have permissions to create a new company. Contact your system administrator.';

    [Scope('Personalization')]
    procedure EnableAssistedCompanySetup(SetupCompanyName: Text[30];AssistedSetupEnabled: Boolean)
    var
        GLEntry: Record "G/L Entry";
        ConfigurationPackageFile: Record "Configuration Package File";
    begin
        if AssistedSetupEnabled then begin
          GLEntry.ChangeCompany(SetupCompanyName);
          if not GLEntry.IsEmpty then
            Error(EnableWizardErr);
          if ConfigurationPackageFile.IsEmpty then
            Message(NoConfigPackageFileMsg);
        end;
        SetAssistedCompanySetupVisibility(SetupCompanyName,AssistedSetupEnabled);
    end;

    local procedure RunAssistedCompanySetup()
    var
        AssistedSetup: Record "Assisted Setup";
        IdentityManagement: Codeunit "Identity Management";
    begin
        if not GuiAllowed then
          exit;

        if IdentityManagement.IsInvAppId then
          exit; // Invoicing handles company setup silently

        if not AssistedSetup.ReadPermission then
          exit;

        if CompanyActive then
          exit;

        if not AssistedSetupEnabled then
          exit;

        if not AssistedSetup.Get(PAGE::"Assisted Company Setup Wizard") then
          exit;

        if AssistedSetup.Status = AssistedSetup.Status::Completed then
          exit;

        Commit; // Make sure all data is committed before we run the wizard

        AssistedSetup.Run;
    end;

    [Scope('Personalization')]
    procedure ApplyUserInput(var TempConfigSetup: Record "Config. Setup" temporary;var BankAccount: Record "Bank Account";AccountingPeriodStartDate: Date;SkipSetupCompanyInfo: Boolean)
    begin
        if not SkipSetupCompanyInfo then
          TempConfigSetup.CopyCompInfo;
        CreateAccountingPeriod(AccountingPeriodStartDate);
        SetupCompanyBankAccount(BankAccount);
    end;

    procedure GetConfigurationPackageFile(ConfigurationPackageFile: Record "Configuration Package File") ServerTempFileName: Text
    var
        FileManagement: Codeunit "File Management";
        TempFile: File;
        OutStream: OutStream;
        InStream: InStream;
    begin
        ServerTempFileName := FileManagement.ServerTempFileName('rapidstart');
        TempFile.Create(ServerTempFileName);
        TempFile.CreateOutStream(OutStream);
        ConfigurationPackageFile.CalcFields(Package);
        ConfigurationPackageFile.Package.CreateInStream(InStream);
        CopyStream(OutStream,InStream);
        TempFile.Close;
    end;

    procedure CreateAccountingPeriod(StartDate: Date)
    var
        AccountingPeriod: Record "Accounting Period";
        CreateFiscalYear: Report "Create Fiscal Year";
        DateFormulaVariable: DateFormula;
    begin
        // The wizard should only setup accounting periods, if non exist.
        if (not AccountingPeriod.IsEmpty) or (StartDate = 0D) then
          exit;

        Evaluate(DateFormulaVariable,'<1M>');
        CreateFiscalYear.InitializeRequest(12,DateFormulaVariable,StartDate);
        CreateFiscalYear.UseRequestPage(false);
        CreateFiscalYear.HideConfirmationDialog(true);
        CreateFiscalYear.RunModal;
    end;

    local procedure SetupCompanyBankAccount(var BankAccount: Record "Bank Account")
    var
        CompanyInformation: Record "Company Information";
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
    begin
        CompanyInformation.Get;
        CompanyInformationMgt.UpdateCompanyBankAccount(CompanyInformation,'',BankAccount);
    end;

    local procedure AssistedSetupEnabled(): Boolean
    var
        AssistedCompanySetupStatus: Record "Assisted Company Setup Status";
    begin
        exit(AssistedCompanySetupStatus.Get(CompanyName) and AssistedCompanySetupStatus.Enabled);
    end;

    local procedure CompanyActive(): Boolean
    var
        GLEntry: Record "G/L Entry";
    begin
        if not GLEntry.ReadPermission then
          exit(true);

        exit(not GLEntry.IsEmpty);
    end;

    [Scope('Personalization')]
    procedure SetAssistedCompanySetupVisibility(SetupCompanyName: Text[30];IsVisible: Boolean)
    var
        AssistedSetup: Record "Assisted Setup";
    begin
        AssistedSetup.ChangeCompany(SetupCompanyName);
        if AssistedSetup.Get(PAGE::"Assisted Company Setup Wizard") then begin
          AssistedSetup.Visible := IsVisible;
          AssistedSetup.Modify;
        end;
    end;

    local procedure FindJobQueueLogEntries(Name: Text[30];var JobQueueLogEntry: Record "Job Queue Log Entry"): Boolean
    var
        AssistedCompanySetupStatus: Record "Assisted Company Setup Status";
    begin
        if not AssistedCompanySetupStatus.Get(Name) then
          exit(false);
        JobQueueLogEntry.SetRange(ID,AssistedCompanySetupStatus."Task ID");
        exit(JobQueueLogEntry.FindLast);
    end;

    local procedure GetCompanySetupStatus(Name: Text[30]): Integer
    var
        JobQueueLogEntry: Record "Job Queue Log Entry";
        SetupStatus: Option " ",Completed,"In Progress",Error,"Missing Permission";
    begin
        if not JobQueueLogEntry.ChangeCompany(Name) then
          exit(SetupStatus::"Missing Permission");

        if not JobQueueLogEntry.ReadPermission then
          exit(SetupStatus::"Missing Permission");

        if FindJobQueueLogEntries(Name,JobQueueLogEntry) then
          exit(JobQueueLogEntry.Status + 1);
        if IsCompanySetupInProgress(Name) then
          exit(SetupStatus::"In Progress");
        exit(SetupStatus::" ");
    end;

    [Scope('Personalization')]
    procedure IsCompanySetupInProgress(NewCompanyName: Text): Boolean
    var
        ActiveSession: Record "Active Session";
        AssistedCompanySetupStatus: Record "Assisted Company Setup Status";
    begin
        with AssistedCompanySetupStatus do
          if Get(NewCompanyName) then
            if "Company Setup Session ID" <> 0 then
              exit(ActiveSession.Get("Server Instance ID","Company Setup Session ID"));
    end;

    [Scope('Personalization')]
    procedure WaitForPackageImportToComplete()
    var
        Window: Dialog;
    begin
        if IsCompanySetupInProgress(CompanyName) then begin
          Window.Open(CompanyIsBeingSetUpMsg);
          while IsCompanySetupInProgress(CompanyName) do
            Sleep(1000);
          Window.Close;
        end;
    end;

    procedure FillCompanyData(NewCompanyName: Text[30];NewCompanyData: Option "Evaluation Data","Standard Data","None","Extended Data","Full No Data")
    var
        Company: Record Company;
        ConfigurationPackageFile: Record "Configuration Package File";
        UserPersonalization: Record "User Personalization";
        DataClassificationEvalData: Codeunit "Data Classification Eval. Data";
    begin
        if NewCompanyData = NewCompanyData::"Evaluation Data" then begin
          Company.Get(NewCompanyName);
          Company."Evaluation Company" := true;
          Company.Modify;
          DataClassificationEvalData.CreateEvaluationData;
        end;

        UserPersonalization.Get(UserSecurityId);
        if FindConfigurationPackageFile(ConfigurationPackageFile,NewCompanyData) then
          ScheduleConfigPackageImport(ConfigurationPackageFile,NewCompanyName);
    end;

    local procedure FilterConfigurationPackageFile(var ConfigurationPackageFile: Record "Configuration Package File";CompanyData: Option "Evaluation Data","Standard Data","None","Extended Data","Full No Data"): Boolean
    begin
        case CompanyData of
          CompanyData::"Evaluation Data":
            ConfigurationPackageFile.SetFilter(Code,'*' + EvaluationTxt + '*');
          CompanyData::"Standard Data":
            ConfigurationPackageFile.SetFilter(Code,'*' + StandardTxt + '*');
          CompanyData::"Extended Data":
            ConfigurationPackageFile.SetFilter(Code,'*' + ExtendedTxt + '*');
          else
            exit(false);
        end;
        ConfigurationPackageFile.SetRange("Setup Type",ConfigurationPackageFile."Setup Type"::Company);
        ConfigurationPackageFile.SetRange("Language ID",GlobalLanguage);
        if ConfigurationPackageFile.IsEmpty then
          ConfigurationPackageFile.SetRange("Language ID");
        exit(true);
    end;

    [Scope('Personalization')]
    procedure ExistsConfigurationPackageFile(CompanyData: Option): Boolean
    var
        ConfigurationPackageFile: Record "Configuration Package File";
    begin
        if FilterConfigurationPackageFile(ConfigurationPackageFile,CompanyData) then
          exit(not ConfigurationPackageFile.IsEmpty);
        exit(false);
    end;

    [Scope('Personalization')]
    procedure FindConfigurationPackageFile(var ConfigurationPackageFile: Record "Configuration Package File";CompanyData: Option): Boolean
    begin
        if FilterConfigurationPackageFile(ConfigurationPackageFile,CompanyData) then
          exit(ConfigurationPackageFile.FindFirst);
        exit(false);
    end;

    [Scope('Personalization')]
    procedure ScheduleConfigPackageImport(ConfigurationPackageFile: Record "Configuration Package File";Name: Text)
    var
        AssistedCompanySetupStatus: Record "Assisted Company Setup Status";
        DoNotScheduleTask: Boolean;
        TaskID: Guid;
        ImportSessionID: Integer;
    begin
        with AssistedCompanySetupStatus do begin
          LockTable;
          Get(Name);
          OnBeforeScheduleTask(DoNotScheduleTask,TaskID);
          if DoNotScheduleTask then
            "Task ID" := TaskID
          else
            if TASKSCHEDULER.CanCreateTask then
              "Task ID" :=
                TASKSCHEDULER.CreateTask(
                  CODEUNIT::"Import Config. Package File",0,true,"Company Name",CurrentDateTime,ConfigurationPackageFile.RecordId)
            else begin
              Commit;
              ImportSessionID := 0;
              StartSession(ImportSessionID,CODEUNIT::"Import Config. Package File","Company Name",ConfigurationPackageFile);
              exit;
            end;
          Modify;
          Commit;
        end;
    end;

    local procedure SetApplicationArea(NewCompanyName: Text[30])
    var
        ExperienceTierSetup: Record "Experience Tier Setup";
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        ExperienceTierSetup."Company Name" := NewCompanyName;
        ExperienceTierSetup.Essential := true;
        ExperienceTierSetup.Insert;

        ApplicationAreaMgmt.SetExperienceTierOtherCompany(ExperienceTierSetup,NewCompanyName);
    end;

    procedure SetUpNewCompany(NewCompanyName: Text[30];NewCompanyData: Option "Evaluation Data","Standard Data","None","Extended Data","Full No Data")
    var
        AssistedCompanySetupStatus: Record "Assisted Company Setup Status";
    begin
        SetApplicationArea(NewCompanyName);
        if not (NewCompanyData in [NewCompanyData::None,NewCompanyData::"Full No Data"]) then begin
          AssistedCompanySetupStatus.SetEnabled(NewCompanyName,NewCompanyData = NewCompanyData::"Standard Data",false);
          FillCompanyData(NewCompanyName,NewCompanyData);
        end;
    end;

    procedure CreateNewCompany(NewCompanyName: Text[30])
    var
        Company: Record Company;
        GeneralLedgerSetup: Record "General Ledger Setup";
        Window: Dialog;
    begin
        Window.Open(CreatingCompanyMsg);

        Company.Init;
        Company.Name := NewCompanyName;
        Company."Display Name" := NewCompanyName;
        Company.Insert;

        if not GeneralLedgerSetup.ChangeCompany(NewCompanyName) then
          Error(NoPermissionsErr);
        if not GeneralLedgerSetup.WritePermission then
          Error(NoPermissionsErr);

        Commit;

        Window.Close;
    end;

    procedure GetAllowedCompaniesForCurrnetUser(var TempCompany: Record Company temporary)
    var
        Company: Record Company;
        UserAccountHelper: DotNet NavUserAccountHelper;
        CompanyName: Text[30];
    begin
        TempCompany.DeleteAll;
        foreach CompanyName in UserAccountHelper.GetAllowedCompanies() do
          if Company.Get(CompanyName) then begin
            TempCompany := Company;
            TempCompany.Insert;
          end;
    end;

    procedure HasCurrentUserAccessToCompany(CompanyName: Text[30]): Boolean
    var
        TempCompany: Record Company temporary;
    begin
        GetAllowedCompaniesForCurrnetUser(TempCompany);
        TempCompany.SetRange(Name,CompanyName);
        exit(not TempCompany.IsEmpty);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeScheduleTask(var DoNotScheduleTask: Boolean;var TaskID: Guid)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 2, 'OnCompanyInitialize', '', false, false)]
    local procedure OnCompanyInitialize()
    var
        AssistedSetup: Record "Assisted Setup";
    begin
        AssistedSetup.Initialize;
    end;

    [EventSubscriber(ObjectType::Table, 1802, 'OnEnabled', '', false, false)]
    local procedure OnEnableAssistedCompanySetup(SetupCompanyName: Text[30];AssistedSetupEnabled: Boolean)
    begin
        EnableAssistedCompanySetup(SetupCompanyName,AssistedSetupEnabled);
    end;

    [EventSubscriber(ObjectType::Codeunit, 40, 'OnAfterCompanyOpen', '', false, false)]
    local procedure OnAfterCompanyOpenRunAssistedCompanySetup()
    begin
        RunAssistedCompanySetup;
    end;

    [EventSubscriber(ObjectType::Page, 9177, 'OnBeforeActionEvent', 'Create New Company', false, false)]
    local procedure OnBeforeCreateNewCompanyActionOpenCompanyCreationWizard(var Rec: Record Company)
    begin
        PAGE.RunModal(PAGE::"Company Creation Wizard");
    end;

    [EventSubscriber(ObjectType::Page, 357, 'OnBeforeActionEvent', 'Create New Company', false, false)]
    local procedure OnBeforeCreateNewCompanyActionOnCompanyPageOpenCompanyCreationWizard(var Rec: Record Company)
    begin
        PAGE.RunModal(PAGE::"Company Creation Wizard");
    end;

    [EventSubscriber(ObjectType::Table, 1802, 'OnAfterValidateEvent', 'Package Imported', false, false)]
    local procedure OnAfterPackageImportedValidate(var Rec: Record "Assisted Company Setup Status";var xRec: Record "Assisted Company Setup Status";CurrFieldNo: Integer)
    begin
        // Send global notification that the new company is ready for use
    end;

    [EventSubscriber(ObjectType::Table, 1802, 'OnAfterValidateEvent', 'Import Failed', false, false)]
    local procedure OnAfterImportFailedValidate(var Rec: Record "Assisted Company Setup Status";var xRec: Record "Assisted Company Setup Status";CurrFieldNo: Integer)
    begin
        // Send global notification that the company set up failed
    end;

    [EventSubscriber(ObjectType::Page, 9176, 'OnCompanyChange', '', false, false)]
    local procedure OnCompanyChangeCheckForSetupCompletion(NewCompanyName: Text;var IsSetupInProgress: Boolean)
    begin
        IsSetupInProgress := IsCompanySetupInProgress(NewCompanyName);
    end;

    [EventSubscriber(ObjectType::Table, 1802, 'OnGetCompanySetupStatus', '', false, false)]
    local procedure OnGetIsCompanySetupInProgress(Name: Text[30];var SetupStatus: Integer)
    begin
        SetupStatus := GetCompanySetupStatus(Name);
    end;

    [EventSubscriber(ObjectType::Table, 1802, 'OnSetupStatusDrillDown', '', false, false)]
    local procedure OnSetupStatusDrillDown(Name: Text[30])
    var
        JobQueueLogEntry: Record "Job Queue Log Entry";
    begin
        if not JobQueueLogEntry.ChangeCompany(Name) then
          exit;
        if FindJobQueueLogEntries(Name,JobQueueLogEntry) then
          PAGE.RunModal(PAGE::"Job Queue Log Entries",JobQueueLogEntry);
    end;
}

