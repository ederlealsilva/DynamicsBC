table 1803 "Assisted Setup"
{
    // version NAVW113.00

    Caption = 'Assisted Setup';
    ReplicateData = false;

    fields
    {
        field(1;"Page ID";Integer)
        {
            Caption = 'Page ID';
        }
        field(2;Name;Text[250])
        {
            Caption = 'Name';
        }
        field(3;"Order";Integer)
        {
            Caption = 'Order';
        }
        field(4;Status;Option)
        {
            Caption = 'Status';
            OptionCaption = 'Not Completed,Completed,Not Started,Seen,Watched,Read, ';
            OptionMembers = "Not Completed",Completed,"Not Started",Seen,Watched,Read," ";
        }
        field(5;Visible;Boolean)
        {
            Caption = 'Visible';
        }
        field(6;Parent;Integer)
        {
            Caption = 'Parent';
        }
        field(7;"Video Url";Text[250])
        {
            Caption = 'Video Url';
        }
        field(8;Icon;Media)
        {
            Caption = 'Icon';
        }
        field(9;"Item Type";Option)
        {
            Caption = 'Item Type';
            InitValue = "Setup and Help";
            OptionCaption = ' ,Group,Setup and Help';
            OptionMembers = " ",Group,"Setup and Help";
        }
        field(10;Featured;Boolean)
        {
            Caption = 'Featured';
        }
        field(11;"Help Url";Text[250])
        {
            Caption = 'Help Url';
        }
        field(12;"Assisted Setup Page ID";Integer)
        {
            Caption = 'Assisted Setup Page ID';
        }
        field(13;"Tour Id";Integer)
        {
            Caption = 'Tour Id';
        }
        field(14;"Video Status";Boolean)
        {
            Caption = 'Video Status';
        }
        field(15;"Help Status";Boolean)
        {
            Caption = 'Help Status';
        }
        field(16;"Tour Status";Boolean)
        {
            Caption = 'Tour Status';
        }
    }

    keys
    {
        key(Key1;"Page ID")
        {
        }
        key(Key2;"Order",Visible)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ProductVideoCategory: Record "Product Video Category";
    begin
        ProductVideoCategory.SetRange("Assisted Setup ID","Page ID");
        ProductVideoCategory.DeleteAll(true);
    end;

    var
        RunSetupAgainQst: Label 'You have already completed the %1 assisted setup guide. Do you want to run it again?', Comment='%1 = Assisted Setup Name';
        InitialCompanySetupTxt: Label 'Set up my company';
        ApprovalWorkflowSetupTxt: Label 'Set up approval workflows';
        SMTPSetupTxt: Label 'Set up email';
        OfficeAddinSetupTxt: Label 'Set up your Business Inbox in Outlook';
        ODataWizardTxt: Label 'Set up reporting data';
        DataMigrationTxt: Label 'Migrate business data';
        SetupEmailLoggingTxt: Label 'Set up email logging';
        CustomerAppWorkflowTxt: Label 'Set up a customer approval workflow';
        ItemAppWorkflowTxt: Label 'Set up an item approval workflow';
        PmtJnlAppWorkflowTxt: Label 'Set up a payment approval workflow';
        VATSetupWizardTxt: Label 'Set up VAT';
        VATSetupWizardLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=850305', Locked=true;
        CashFlowForecastTxt: Label 'Set up cash flow forecast';
        CompanyAlreadySetUpQst: Label 'This company is already set up. To change settings for it, go to the Company Information window.\\Go there now?';
        CRMConnectionSetupTxt: Label 'Set up %1 connection', Comment='%1 = CRM product name';
        AzureAdSetupTxt: Label 'Set up Azure Active Directory';
        GenralLedgerGroupTxt: Label 'Work with journals';
        ReportingAndForecastingGroupTxt: Label 'Get the most out of reports and forecasting';
        ExtensionsGroupTxt: Label 'Install extensions to add features and integrations';
        SettingGroupTxt: Label 'Customize settings to fit your needs';
        GettingStartedGroupTxt: Label 'Get started with Dynamics 365';
        HelpWorkwithextensionsTxt: Label 'https://go.microsoft.com/fwlink/?linkid=828706', Locked=true;
        HelpWorkwithExcelTxt: Label 'https://go.microsoft.com/fwlink/?linkid=828705', Locked=true;
        HelpWorkwithPowerBITxt: Label 'https://go.microsoft.com/fwlink/?linkid=828704', Locked=true;
        HelpIntroductiontoFinancialsTxt: Label 'https://go.microsoft.com/fwlink/?linkid=828702', Locked=true;
        HelpWorkwithgeneraljournalsTxt: Label 'https://go.microsoft.com/fwlink/?linkid=828701', Locked=true;
        HelpCortanaIntelligenceforFinancialsTxt: Label 'https://go.microsoft.com/fwlink/?linkid=828700', Locked=true;
        HelpBankintegrationTxt: Label 'https://go.microsoft.com/fwlink/?linkid=828698', Locked=true;
        HelpCreateasalesinvoiceTxt: Label 'https://go.microsoft.com/fwlink/?linkid=828697', Locked=true;
        HelpAddacustomerTxt: Label 'https://go.microsoft.com/fwlink/?linkid=828696', Locked=true;
        HelpAddanitemTxt: Label 'https://go.microsoft.com/fwlink/?linkid=828695', Locked=true;
        HelpSetupCashFlowForecastTxt: Label 'https://go.microsoft.com/fwlink/?linkid=828693', Locked=true;
        HelpSetupReportingTxt: Label 'https://go.microsoft.com/fwlink/?linkid=828692', Locked=true;
        HelpSetupemailTxt: Label 'https://go.microsoft.com/fwlink/?linkid=828689', Locked=true;
        HelpImportbusinessdataTxt: Label 'https://go.microsoft.com/fwlink/?linkid=828687', Locked=true;
        VideoWorkwithextensionsTxt: Label 'https://go.microsoft.com/fwlink/?linkid=828686', Locked=true;
        VideoWorkwithExcelTxt: Label 'https://go.microsoft.com/fwlink/?linkid=828685', Locked=true;
        VideoWorkwithPowerBITxt: Label 'https://go.microsoft.com/fwlink/?linkid=828684', Locked=true;
        VideoRunyourbusinesswithOffice365Txt: Label 'https://go.microsoft.com/fwlink/?linkid=828683', Locked=true;
        VideoWorkwithgeneraljournalsTxt: Label 'https://go.microsoft.com/fwlink/?linkid=828682', Locked=true;
        VideoIntrotoDynamics365forFinancialsTxt: Label 'https://go.microsoft.com/fwlink/?linkid=828681', Locked=true;
        VideoCortanaIntelligenceforFinancialsTxt: Label 'https://go.microsoft.com/fwlink/?linkid=828680', Locked=true;
        VideoBankintegrationTxt: Label 'https://go.microsoft.com/fwlink/?linkid=828679', Locked=true;
        VideoImportbusinessdataTxt: Label 'https://go.microsoft.com/fwlink/?linkid=828660', Locked=true;
        HelpSetuptheOfficeaddinTxt: Label 'https://go.microsoft.com/fwlink/?linkid=828690', Locked=true;
        HelpWorkwithPowerBINameTxt: Label 'Work with PowerBI';
        HelpCreateasalesinvoiceNameTxt: Label 'Create a sales invoice';
        HelpAddacustomerNameTxt: Label 'Add a customer';
        HelpAddanitemNameTxt: Label 'Add an item';
        HelpSetupReportingNameTxt: Label 'Set up reporting';
        VideoWorkwithextensionsNameTxt: Label 'Install extensions to add features and integrations';
        VideoWorkwithExcelNameTxt: Label 'Work with Excel';
        VideoWorkwithgeneraljournalsNameTxt: Label 'Work with general journals';
        VideoIntrotoDynamics365forFinancialsNameTxt: Label 'Learn about Dynamics 365';
        VideoCortanaIntelligenceforFinancialsNameTxt: Label 'Cortana with Dynamics 365';
        VideoBankintegrationNameTxt: Label 'Set up bank integration';
        BankIntegrationAltTitleTxt: Label 'Connecting to your bank (Yodlee Envestnet)';
        VideoUrlSetupEmailTxt: Label 'https://go.microsoft.com/fwlink/?linkid=843243', Locked=true;
        VideoUrlSetupCRMConnectionTxt: Label 'https://go.microsoft.com/fwlink/?linkid=843244', Locked=true;
        VideoUrlSetupApprovalsTxt: Label 'https://go.microsoft.com/fwlink/?linkid=843246', Locked=true;
        VideoUrlSetupEmailLoggingTxt: Label 'https://go.microsoft.com/fwlink/?linkid=843360', Locked=true;
        YearEndClosingTxt: Label 'Year-end closing';
        VideoUrlYearEndClosingTxt: Label 'https://go.microsoft.com/fwlink/?linkid=843361', Locked=true;
        SetupDimensionsTxt: Label 'Set up dimensions';
        VideoUrlSetupDimensionsTxt: Label 'https://go.microsoft.com/fwlink/?linkid=843362', Locked=true;
        CreateJobTxt: Label 'Create a job';
        VideoUrlCreateJobTxt: Label 'https://go.microsoft.com/fwlink/?linkid=843363', Locked=true;
        InviteExternalAccountantTxt: Label 'Invite External Accountant';
        SetupConsolidationReportingTxt: Label 'Set up consolidation reporting';
        AccessAllFeaturesTxt: Label 'Access all features';
        VideoAccessAllFeaturesTxt: Label 'https://go.microsoft.com/fwlink/?linkid=857610', Locked=true;
        AnalyzeDataUsingAccSchedulesTxt: Label 'Analyze data using account schedules';
        VideoAnalyzeDataUsingAccSchedulesTxt: Label 'https://go.microsoft.com/fwlink/?linkid=857611', Locked=true;
        WarehouseManagementTxt: Label 'Warehouse Management';
        WorkWithLocAndTransfOrdTxt: Label 'Work with locations and transfer orders';
        VideoWorkWithLocAndTransfOrdTxt: Label 'https://go.microsoft.com/fwlink/?linkid=857612', Locked=true;
        WorkWithPostingGroupsTxt: Label 'Work with posting groups';
        VideoWorkWithPostingGroupsTxt: Label 'https://go.microsoft.com/fwlink/?linkid=857613', Locked=true;
        WorkWithVatTxt: Label 'Work with VAT';
        VideoWorkWithVatTxt: Label 'https://go.microsoft.com/fwlink/?linkid=857614', Locked=true;
        IntroductionTxt: Label 'Introduction';
        VideoUrlIntroductionTxt: Label 'https://go.microsoft.com/fwlink/?linkid=867632', Locked=true;
        GettingStartedTxt: Label 'Getting Started';
        VideoUrlGettingStartedTxt: Label 'https://go.microsoft.com/fwlink/?linkid=867634', Locked=true;
        AdditionalReourcesTxt: Label 'Additional Resources';
        VideoUrlAdditionalReourcesTxt: Label 'https://go.microsoft.com/fwlink/?linkid=867635', Locked=true;

    [Scope('Personalization')]
    procedure SetStatus(EnteryId: Integer;ItemStatus: Option)
    var
        AssistedSetup: Record "Assisted Setup";
    begin
        AssistedSetup.Get(EnteryId);
        AssistedSetup.Status := ItemStatus;
        AssistedSetup.Modify;

        if
           (AssistedSetup.Status = AssistedSetup.Status::Completed) and
           (AssistedSetup."Assisted Setup Page ID" <> 0)
        then
          OnAssistedSetupCompleted(EnteryId);
    end;

    [Scope('Personalization')]
    procedure GetStatus(WizardPageID: Integer): Integer
    var
        AssistedSetup: Record "Assisted Setup";
    begin
        AssistedSetup.SetRange("Assisted Setup Page ID",WizardPageID);
        AssistedSetup.FindFirst;
        exit(AssistedSetup.Status);
    end;

    procedure Initialize()
    var
        ProductVideoCategory: Record "Product Video Category";
        O365GettingStartedMgt: Codeunit "O365 Getting Started Mgt.";
        PermissionManager: Codeunit "Permission Manager";
        CRMProductName: Codeunit "CRM Product Name";
        SettingGroupId: Integer;
        ExtensionsGroupId: Integer;
        LastId: Integer;
        ReportingAndForecastingGroupId: Integer;
        GettingStartedGroupId: Integer;
        GenralLedgerGroupId: Integer;
        WarehouseGroupId: Integer;
        GroupId: Integer;
        SortingOption: Option ,,CompanySetup,AboutFinancials,MigrateBData,SetUpSalesTax,SetUpBankIntegration,AddCustomer,AddItem,CreateSalesInvoice,CreateJob,Introduction,GettingStarted,AdditionalResources;
        SortingOrder: Integer;
        InviteExternalAccountantEntryNumber: Integer;
        EntryNumber: Integer;
        IsYodleeInstalled: Boolean;
    begin
        SortingOrder := 1;
        LastId := 200000;
        SettingGroupId := 100000;
        ExtensionsGroupId := 100001;
        ReportingAndForecastingGroupId := 100003;
        GettingStartedGroupId := 100004;
        GenralLedgerGroupId := 100005;
        WarehouseGroupId := 100006;

        // Getting Started
        GroupId := GettingStartedGroupId;
        AddSetupAssistant(GroupId,GettingStartedGroupTxt,SortingOrder,true,0,true,"Item Type"::Group);
        AddSetupAssistantResources(GroupId,VideoIntrotoDynamics365forFinancialsTxt,'',0,0,'learn01_overview_240px');

        AddSetupAssistant(PAGE::"Data Migration Wizard",DataMigrationTxt,SortingOption::MigrateBData,true,
          GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(PAGE::"Data Migration Wizard",VideoImportbusinessdataTxt,
          HelpImportbusinessdataTxt,0,PAGE::"Data Migration Wizard",'');
        LastId += 1;

        AddSetupAssistant(LastId,VideoIntrotoDynamics365forFinancialsNameTxt,SortingOption::AboutFinancials,true,
          GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(LastId,VideoIntrotoDynamics365forFinancialsTxt,HelpIntroductiontoFinancialsTxt,0,0,'');
        LastId += 1;

        AddSetupAssistant(PAGE::"Assisted Company Setup Wizard",InitialCompanySetupTxt,SortingOption::CompanySetup,
          AssistedCompanySetupIsVisible,GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(PAGE::"Assisted Company Setup Wizard",'','',0,PAGE::"Assisted Company Setup Wizard",'');
        LastId += 1;

        AddSetupAssistant(LastId,IntroductionTxt,SortingOption::Introduction,true,
          GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(LastId,VideoUrlIntroductionTxt,'',0,0,'');
        AddAssistedSetupVideoCategory(LastId,ProductVideoCategory.Category::"Getting Started",'');
        LastId += 1;

        AddSetupAssistant(LastId,GettingStartedTxt,SortingOption::GettingStarted,true,
          GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(LastId,VideoUrlGettingStartedTxt,'',0,0,'');
        AddAssistedSetupVideoCategory(LastId,ProductVideoCategory.Category::"Getting Started",'');
        LastId += 1;

        AddSetupAssistant(LastId,AdditionalReourcesTxt,SortingOption::AdditionalResources,true,
          GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(LastId,VideoUrlAdditionalReourcesTxt,'',0,0,'');
        AddAssistedSetupVideoCategory(LastId,ProductVideoCategory.Category::"Getting Started",'');
        LastId += 1;

        VerifyYodleeIsInstalled(IsYodleeInstalled);
        if IsYodleeInstalled then begin
          AddSetupAssistant(LastId,VideoBankintegrationNameTxt,SortingOption::SetUpBankIntegration,true,GroupId,false,
            "Item Type"::"Setup and Help");
          AddSetupAssistantResources(LastId,VideoBankintegrationTxt,HelpBankintegrationTxt,0,0,'');
          AddAssistedSetupVideoCategory(LastId,ProductVideoCategory.Category::"Getting Started",
            BankIntegrationAltTitleTxt);
        end;
        LastId += 1;
        AddSetupAssistant(LastId,AccessAllFeaturesTxt,SortingOption::AboutFinancials,true,
          GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(LastId,VideoAccessAllFeaturesTxt,'',0,0,'');
        LastId += 1;

        AddSetupAssistant(LastId,HelpAddacustomerNameTxt,SortingOption::AddCustomer,PermissionManager.SoftwareAsAService,GroupId,
          false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(LastId,'',HelpAddacustomerTxt,O365GettingStartedMgt.GetAddCustomerTourID,0,'');
        LastId += 1;

        AddSetupAssistant(LastId,HelpAddanitemNameTxt,SortingOption::AddItem,PermissionManager.SoftwareAsAService,
          GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(LastId,'',HelpAddanitemTxt,O365GettingStartedMgt.GetAddItemTourID,0,'');
        LastId += 1;

        AddSetupAssistant(LastId,CreateJobTxt,SortingOption::CreateJob,PermissionManager.SoftwareAsAService,
          GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(LastId,VideoUrlCreateJobTxt,'',0,0,'');
        LastId += 1;

        // Warehouse Management
        GroupId := WarehouseGroupId;
        AddSetupAssistant(GroupId,WarehouseManagementTxt,SortingOrder,true,0,true,"Item Type"::Group);
        AddSetupAssistantResources(GroupId,VideoWorkWithLocAndTransfOrdTxt,'',0,0,'setup06_forecast_240px');
        SortingOrder += 1;

        AddSetupAssistant(LastId,WorkWithLocAndTransfOrdTxt,SortingOrder,true,GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(LastId,VideoWorkWithLocAndTransfOrdTxt,'',0,0,'');
        LastId += 1;

        AddSetupAssistant(LastId,HelpCreateasalesinvoiceNameTxt,SortingOption::CreateSalesInvoice,PermissionManager.SoftwareAsAService,
          GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(LastId,'',HelpCreateasalesinvoiceTxt,O365GettingStartedMgt.GetCreateSalesInvoiceTourID,0,'');
        LastId += 1;
        SortingOrder := SortingOption::CreateSalesInvoice + 1;

        // Genral Ledger
        GroupId := GenralLedgerGroupId;
        AddSetupAssistant(GroupId,GenralLedgerGroupTxt,SortingOrder,true,0,true,"Item Type"::Group);
        AddSetupAssistantResources(GroupId,VideoWorkwithgeneraljournalsTxt,'',0,0,'learn07_journal_240px');
        SortingOrder += 1;

        AddSetupAssistant(
          LastId,VideoWorkwithgeneraljournalsNameTxt,SortingOrder,true,GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(LastId,VideoWorkwithgeneraljournalsTxt,HelpWorkwithgeneraljournalsTxt,0,0,'');
        LastId += 1;
        LastId += 1;
        SortingOrder += 1;

        AddSetupAssistant(
          LastId,YearEndClosingTxt,SortingOrder,true,GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(LastId,VideoUrlYearEndClosingTxt,'',0,0,'');
        LastId += 1;
        LastId += 1;
        SortingOrder += 1;

        AddSetupAssistant(
          LastId,WorkWithPostingGroupsTxt,SortingOrder,true,GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(LastId,VideoWorkWithPostingGroupsTxt,'',0,0,'');
        LastId += 1;
        LastId += 1;
        SortingOrder += 1;

        AddSetupAssistant(
          LastId,WorkWithVatTxt,SortingOrder,true,GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(LastId,VideoWorkWithVatTxt,'',0,0,'');
        LastId += 1;
        LastId += 1;
        SortingOrder += 1;

        // Reporting And Forecasting
        GroupId := ReportingAndForecastingGroupId;
        AddSetupAssistant(GroupId,ReportingAndForecastingGroupTxt,SortingOrder,true,0,true,"Item Type"::Group);
        SortingOrder += 1;

        AddSetupAssistant(LastId,VideoCortanaIntelligenceforFinancialsNameTxt,SortingOrder,true,
          GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(LastId,VideoCortanaIntelligenceforFinancialsTxt,
          HelpCortanaIntelligenceforFinancialsTxt,0,0,'');
        LastId += 1;
        SortingOrder += 1;

        AddSetupAssistant(
          LastId,VideoWorkwithExcelNameTxt,SortingOrder,true,GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(LastId,VideoWorkwithExcelTxt,HelpWorkwithExcelTxt,0,0,'');
        LastId += 1;
        SortingOrder += 1;

        AddSetupAssistant(
          LastId,HelpWorkwithPowerBINameTxt,SortingOrder,true,GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(LastId,VideoWorkwithPowerBITxt,HelpWorkwithPowerBITxt,0,0,'');
        LastId += 1;
        SortingOrder += 1;

        AddSetupAssistant(
          LastId,AnalyzeDataUsingAccSchedulesTxt,SortingOrder,true,GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(LastId,VideoAnalyzeDataUsingAccSchedulesTxt,'',0,0,'');
        LastId += 1;
        SortingOrder += 1;

        AddSetupAssistant(PAGE::"Cash Flow Forecast Wizard",CashFlowForecastTxt,SortingOrder,true,
          GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(PAGE::"Cash Flow Forecast Wizard",'',HelpSetupCashFlowForecastTxt,0,
          PAGE::"Cash Flow Forecast Wizard",'');
        SortingOrder += 1;

        AddSetupAssistant(
          LastId,HelpSetupReportingNameTxt,SortingOrder,true,GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(LastId,'',HelpSetupReportingTxt,0,0,'');
        LastId += 1;
        SortingOrder += 1;

        // Extensions
        GroupId := ExtensionsGroupId;
        AddSetupAssistant(GroupId,ExtensionsGroupTxt,SortingOrder,true,0,true,"Item Type"::Group);
        AddSetupAssistantResources(GroupId,VideoWorkwithextensionsTxt,'',0,0,'learn02_item_240px');
        SortingOrder += 1;

        AddSetupAssistant(
          LastId,VideoWorkwithextensionsNameTxt,SortingOrder,true,GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(LastId,VideoWorkwithextensionsTxt,HelpWorkwithextensionsTxt,0,0,'');
        LastId += 1;
        SortingOrder += 1;

        // Customize for your need
        GroupId := SettingGroupId;
        AddSetupAssistant(GroupId,SettingGroupTxt,SortingOrder,true,0,true,"Item Type"::Group);
        AddSetupAssistantResources(GroupId,VideoRunyourbusinesswithOffice365Txt,'',0,0,'learn12_extension_240px');
        SortingOrder += 1;

        AddSetupAssistant(PAGE::"Approval Workflow Setup Wizard",ApprovalWorkflowSetupTxt,SortingOrder,true,
          GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(PAGE::"Approval Workflow Setup Wizard",VideoUrlSetupApprovalsTxt,'',0,
          PAGE::"Approval Workflow Setup Wizard",'');
        SortingOrder += 1;

        AddSetupAssistant(PAGE::"Cust. Approval WF Setup Wizard",CustomerAppWorkflowTxt,SortingOrder,true,
          GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(PAGE::"Cust. Approval WF Setup Wizard",'','',0,PAGE::"Cust. Approval WF Setup Wizard",'');
        SortingOrder += 1;

        AddSetupAssistant(
          PAGE::"Email Setup Wizard",SMTPSetupTxt,SortingOrder,true,GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(PAGE::"Email Setup Wizard",VideoUrlSetupEmailTxt,HelpSetupemailTxt,0,PAGE::"Email Setup Wizard",'');
        SortingOrder += 1;

        AddSetupAssistant(PAGE::"Setup Email Logging",SetupEmailLoggingTxt,SortingOrder,true,
          GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(PAGE::"Setup Email Logging",VideoUrlSetupEmailLoggingTxt,'',0,PAGE::"Setup Email Logging",'');
        LastId += 1;
        SortingOrder += 1;

        AddSetupAssistant(PAGE::"Exchange Setup Wizard",OfficeAddinSetupTxt,SortingOrder,true,
          GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(PAGE::"Exchange Setup Wizard",VideoRunyourbusinesswithOffice365Txt,HelpSetuptheOfficeaddinTxt,
          0,PAGE::"Exchange Setup Wizard",'');
        SortingOrder += 1;

        AddSetupAssistant(PAGE::Dimensions,SetupDimensionsTxt,SortingOrder,false,
          GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(PAGE::Dimensions,VideoUrlSetupDimensionsTxt,'',
          0,PAGE::Dimensions,'');
        SortingOrder += 1;

        // Setup Group
        AddSetupAssistant(
          PAGE::"OData Setup Wizard",ODataWizardTxt,SortingOrder,true,GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(PAGE::"OData Setup Wizard",'','',0,PAGE::"OData Setup Wizard",'');
        SortingOrder += 1;

        AddSetupAssistant(PAGE::"Item Approval WF Setup Wizard",ItemAppWorkflowTxt,SortingOrder,true,
          GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(PAGE::"Item Approval WF Setup Wizard",'','',0,PAGE::"Item Approval WF Setup Wizard",'');
        SortingOrder += 1;

        AddSetupAssistant(PAGE::"Azure AD App Setup Wizard",AzureAdSetupTxt,SortingOrder,not PermissionManager.SoftwareAsAService,
          GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(PAGE::"Azure AD App Setup Wizard",'','',0,PAGE::"Azure AD App Setup Wizard",'');
        LastId += 1;
        SortingOrder += 1;

        AddSetupAssistant(PAGE::"Pmt. App. Workflow Setup Wzrd.",PmtJnlAppWorkflowTxt,SortingOrder,true,
          GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(PAGE::"Pmt. App. Workflow Setup Wzrd.",'','',0,PAGE::"Pmt. App. Workflow Setup Wzrd.",'');
        SortingOrder += 1;

        AddSetupAssistant(
          PAGE::"CRM Connection Setup Wizard",CopyStr(StrSubstNo(CRMConnectionSetupTxt,CRMProductName.SHORT),1,MaxStrLen(Name)),
          SortingOrder,true,GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(PAGE::"CRM Connection Setup Wizard",VideoUrlSetupCRMConnectionTxt,'',0,
          PAGE::"CRM Connection Setup Wizard",'');
        SortingOrder += 1;

        AddSetupAssistant(
          PAGE::"VAT Setup Wizard",VATSetupWizardTxt,SortingOrder,true,GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(PAGE::"VAT Setup Wizard",'',VATSetupWizardLinkTxt,0,PAGE::"VAT Setup Wizard",'');
        SortingOrder += 1;

        InviteExternalAccountantEntryNumber := PAGE::"Invite External Accountant";
        AddSetupAssistant(InviteExternalAccountantEntryNumber,InviteExternalAccountantTxt,SortingOrder,
          PermissionManager.SoftwareAsAService,GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(PAGE::"Invite External Accountant",'','',0,PAGE::"Invite External Accountant",'');
        SortingOrder += 1;

        EntryNumber := PAGE::"Company Consolidation Wizard";
        AddSetupAssistant(EntryNumber,SetupConsolidationReportingTxt,SortingOrder,true,GroupId,false,"Item Type"::"Setup and Help");
        AddSetupAssistantResources(EntryNumber,'','',0,EntryNumber,'');
        SortingOrder += 1;

        // Update Statuses and Visibilities
        UpdateStatus;
    end;

    local procedure AssistedCompanySetupIsVisible(): Boolean
    var
        AssistedCompanySetupStatus: Record "Assisted Company Setup Status";
    begin
        if AssistedCompanySetupStatus.Get(CompanyName) then
          exit(AssistedCompanySetupStatus.Enabled);
        exit(false);
    end;

    [Scope('Personalization')]
    procedure Run()
    begin
        if "Item Type" <> "Item Type"::"Setup and Help" then
          exit;

        if Status = Status::Completed then
          case "Page ID" of
            PAGE::"Assisted Company Setup Wizard":
              HandleOpenCompletedAssistedCompanySetupWizard;
            else
              if not Confirm(RunSetupAgainQst,false,Name) then
                exit;
          end;

        PAGE.RunModal("Assisted Setup Page ID");
    end;

    procedure HandleOpenCompletedAssistedCompanySetupWizard()
    begin
        if Confirm(CompanyAlreadySetUpQst,true) then
          PAGE.Run(PAGE::"Company Information");
        Error('');
    end;

    local procedure AddSetupAssistant(EnteryNo: Integer;AssistantName: Text[250];SortingOrder: Integer;AssistantVisible: Boolean;ParentId: Integer;IsFeatured: Boolean;EnteryType: Option)
    begin
        if not Get(EnteryNo) then begin
          Init;
          "Page ID" := EnteryNo;
          Visible := AssistantVisible;
          if EnteryType = "Item Type"::Group then
            Status := Status::" ";
          Insert(true);
        end;

        "Page ID" := EnteryNo;
        Name := AssistantName;
        Order := SortingOrder;
        "Item Type" := EnteryType;
        Featured := IsFeatured;
        Parent := ParentId;
        Modify(true);
    end;

    local procedure UpdateStatus()
    begin
        UpdateSetUpEmail;
        UpdateSetUpApprovalWorkflow;
        UpdateSetUpPageVisibility(PAGE::"CRM Connection Setup Wizard");
        UpdateSetUpPageVisibility(PAGE::"Setup Email Logging");
        UpdateSetUpPageVisibility(PAGE::"Approval Workflow Setup Wizard");
        UpdateSetUpPageVisibility(PAGE::"Cust. Approval WF Setup Wizard");
        UpdateSetUpPageVisibility(PAGE::"Item Approval WF Setup Wizard");
        UpdateSetUpPageVisibility(PAGE::"Pmt. App. Workflow Setup Wzrd.");
        UpdateSetUpPageVisibility(PAGE::"Company Consolidation Wizard");
        UpdateAzureAdSaasVisibility;
        UpdateInviteWizardVisibility;
        UpdateToursVisibility;
    end;

    local procedure UpdateSetUpEmail()
    var
        SMTPMailSetup: Record "SMTP Mail Setup";
        AssistedSetup: Record "Assisted Setup";
    begin
        if AssistedSetup.Get(PAGE::"Email Setup Wizard") and (AssistedSetup.Status <> Status::Completed) then
          if SMTPMailSetup.GetSetup then begin
            AssistedSetup.Status := Status::Completed;
            AssistedSetup.Modify;
          end;
    end;

    local procedure UpdateSetUpApprovalWorkflow()
    var
        AssistedSetup: Record "Assisted Setup";
        ApprovalUserSetup: Record "User Setup";
    begin
        if not AssistedSetup.Get(PAGE::"Approval Workflow Setup Wizard") then
          exit;

        if AssistedSetup.Status = Status::Completed then
          exit;

        ApprovalUserSetup.SetFilter("Approver ID",'<>%1','');
        if ApprovalUserSetup.IsEmpty then
          exit;

        AssistedSetup.Status := Status::Completed;
        AssistedSetup.Modify;
    end;

    local procedure UpdateSetUpPageVisibility(PageId: Integer)
    var
        AssistedSetup: Record "Assisted Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if AssistedSetup.Get(PageId) then begin
          AssistedSetup.Visible := not ApplicationAreaMgmtFacade.IsBasicOnlyEnabled;
          AssistedSetup.Modify;
        end;
    end;

    local procedure UpdateToursVisibility()
    var
        AssistedSetup: Record "Assisted Setup";
        PermissionManager: Codeunit "Permission Manager";
    begin
        if not PermissionManager.SoftwareAsAService then
          exit;
        AssistedSetup.SetFilter("Tour Id",'>0');
        AssistedSetup.ModifyAll(Visible,PermissionManager.SoftwareAsAService);
    end;

    local procedure UpdateAzureAdSaasVisibility()
    var
        AssistedSetup: Record "Assisted Setup";
        PermissionManager: Codeunit "Permission Manager";
    begin
        if AssistedSetup.Get(PAGE::"Azure AD App Setup Wizard") then begin
          AssistedSetup.Visible := not PermissionManager.SoftwareAsAService;
          AssistedSetup.Modify;
        end;
    end;

    local procedure UpdateInviteWizardVisibility()
    var
        AssistedSetup: Record "Assisted Setup";
        PermissionManager: Codeunit "Permission Manager";
    begin
        if AssistedSetup.Get(PAGE::"Invite External Accountant") then begin
          AssistedSetup.Visible := PermissionManager.SoftwareAsAService;
          AssistedSetup.Modify;
        end;
    end;

    [IntegrationEvent(false, false)]
    [Scope('Personalization')]
    procedure OnAssistedSetupCompleted(PageId: Integer)
    begin
    end;

    [Scope('Personalization')]
    procedure Navigate()
    var
        SetupAndHelpResourceCard: Page "Setup and Help Resource Card";
    begin
        if "Item Type" <> "Item Type"::Group then
          exit;
        SetStatus("Page ID",Status::Seen);
        SetupAndHelpResourceCard.SetGroup("Page ID");
        SetupAndHelpResourceCard.Run;
    end;

    [TryFunction]
    local procedure ImportIcon(IconCode: Code[50])
    var
        AssistedSetupIcons: Record "Assisted Setup Icons";
        MediaResources: Record "Media Resources";
    begin
        if not AssistedSetupIcons.Get(IconCode) then
          exit;

        if not MediaResources.Get(AssistedSetupIcons."Media Resources Ref") then
          exit;

        if not MediaResources."Media Reference".HasValue then
          exit;

        Icon := MediaResources."Media Reference";
        Modify(true);
    end;

    [Scope('Personalization')]
    procedure NavigateHelpPage()
    var
        AssistedSetupLog: Record "Assisted Setup Log";
    begin
        if "Help Url" = '' then
          exit;

        HyperLink("Help Url");

        Validate("Help Status",true);
        Modify(true);
        AssistedSetupLog.Log("Page ID",AssistedSetupLog."Invoked Action"::Help);
    end;

    [Scope('Personalization')]
    procedure NavigateVideo()
    var
        AssistedSetupLog: Record "Assisted Setup Log";
        VideoLink: Page "Video link";
    begin
        if "Video Url" = '' then
          exit;

        VideoLink.SetURL("Video Url");
        VideoLink.RunModal;

        AssistedSetupLog.Log("Page ID",AssistedSetupLog."Invoked Action"::Video);
        Validate("Video Status",true);
        Modify(true);
    end;

    local procedure AddSetupAssistantResources(EnteryNo: Integer;videoLink: Text[250];HelpLink: Text[250];TourId: Integer;AssistedPageId: Integer;IconCode: Code[50])
    begin
        if not Get(EnteryNo) then
          exit;

        "Video Url" := videoLink;
        "Help Url" := HelpLink;
        "Tour Id" := TourId;
        "Assisted Setup Page ID" := AssistedPageId;
        Modify(true);
        if not Icon.HasValue then
          ImportIcon(IconCode);
    end;

    local procedure AddAssistedSetupVideoCategory(AssistedSetupID: Integer;VideoCategory: Option;AlternateTitle: Text[250])
    var
        ProductVideoCategory: Record "Product Video Category";
    begin
        if not ProductVideoCategory.WritePermission then
          exit;

        if not ProductVideoCategory.Get(AssistedSetupID,VideoCategory) then begin
          Clear(ProductVideoCategory);
          ProductVideoCategory."Assisted Setup ID" := AssistedSetupID;
          ProductVideoCategory.Category := VideoCategory;
          ProductVideoCategory."Alternate Title" := AlternateTitle;
          ProductVideoCategory.Insert;
          exit;
        end;

        if ProductVideoCategory."Alternate Title" <> AlternateTitle then begin
          ProductVideoCategory."Alternate Title" := AlternateTitle;
          ProductVideoCategory.Modify;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure VerifyYodleeIsInstalled(var IsYodleeInstalled: Boolean)
    begin
    end;
}

