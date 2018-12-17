codeunit 1875 "Business Setup Management"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        CompanyNameTxt: Label 'Company';
        CompanyDescriptionTxt: Label 'Make general company settings.';
        CompanyKeywordsTxt: Label 'Company';
        CountriesRegionsNameTxt: Label 'Countries/Regions';
        CountriesRegionsDescriptionTxt: Label 'Define which countries/regions you trade in.';
        CountriesRegionsKeywordsTxt: Label 'Reference data, Country, Region, System';
        CurrenciesNameTxt: Label 'Currencies';
        CurrenciesDescriptionTxt: Label 'Define how you trade in foreign currencies.';
        CurrenciesKeywordsTxt: Label 'Finance, Currency, Money';
        GeneralLedgerSetupNameTxt: Label 'General Ledger Setup';
        GeneralLedgerSetupDescriptionTxt: Label 'Define how to manage your company finances.';
        GeneralLedgerSetupKeywordsTxt: Label 'Ledger, Finance';
        JobsSetupNameTxt: Label 'Jobs Setup';
        JobsSetupDescriptionTxt: Label 'Set up policies for project management (jobs).';
        JobsSetupKeywordsTxt: Label 'Jobs, Project Management';
        FixedAssetSetupNameTxt: Label 'Fixed Assets Setup';
        FixedAssetSetupDescriptionTxt: Label 'Set up accounting policies for fixed assets.';
        FixedAssetSetupKeywordsTxt: Label 'Fixed Assets';
        HumanResourcesSetupNameTxt: Label 'Human Resources Setup';
        HumanResourcesSetupDescriptionTxt: Label 'Define how you manage employee data.';
        HumanResourcesSetupKeywordsTxt: Label 'Human Resources, HR';
        InventorySetupNameTxt: Label 'Inventory Setup';
        InventorySetupDescriptionTxt: Label 'Set up policies for inventory items.';
        InventorySetupKeywordsTxt: Label 'Inventory, Number Series, Product';
        LocationsNameTxt: Label 'Locations';
        LocationsDescriptionTxt: Label 'Set up locations';
        LocationsKeywordsTxt: Label 'Inventory, Location';
        TransferRoutesNameTxt: Label 'Transfer Routes';
        TransferRoutesDescriptionTxt: Label 'Set up transfer routes';
        TransferRoutesKeywordsTxt: Label 'Inventory, Location, Transfer';
        ItemChargesNameTxt: Label 'Item Charges';
        ItemChargesDescriptionTxt: Label 'Set up Item Charges';
        ItemChargesKeywordsTxt: Label 'Inventory, Item Charges';
        LanguagesNameTxt: Label 'Languages';
        LanguagesDescriptionTxt: Label 'Install and update languages that appear in the user interface.';
        LanguagesKeywordsTxt: Label 'System, User Interface, Text, Language';
        NoSeriesNameTxt: Label 'Number Series';
        NoSeriesDescriptionTxt: Label 'Manage number series for master data, documents, and transaction records.';
        NoSeriesKeywordsTxt: Label 'Finance, Number Series';
        PostCodesNameTxt: Label 'Post Codes';
        PostCodesDescriptionTxt: Label 'Set up or update post codes.';
        PostCodesKeywordsTxt: Label 'Mail, System, Code';
        ReasonCodesNameTxt: Label 'Reason Codes';
        ReasonCodesDescriptionTxt: Label 'Set up reasons to assign to transactions, such as returns.';
        ReasonCodesKeywordsTxt: Label 'Reference data, Reason, Code';
        SourceCodesNameTxt: Label 'Source Codes';
        SourceCodesDescriptionTxt: Label 'Set up sources to assign to transactions for identification.';
        SourceCodesKeywordsTxt: Label 'Reference data, Source, Code';
        PurchasePayablesSetupNameTxt: Label 'Purchase & Payables Setup';
        PurchasePayablesSetupDescriptionTxt: Label 'Define how you process purchases and outgoing payments.';
        PurchasePayablesSetupKeywordsTxt: Label 'Purchase, Payables, Finance, Payment';
        SalesReceivablesSetupNameTxt: Label 'Sales & Receivables Setup';
        SalesReceivablesSetupDescriptionTxt: Label 'Define how you process sales and incoming payments.';
        SalesReceivablesSetupKeywordsTxt: Label 'Sales, Receivables, Finance, Payment';
        PermissionSetsNameTxt: Label 'Permission Sets';
        PermissionSetsDescriptionTxt: Label 'Define which database permissions can be granted to users.';
        PermissionSetsKeywordsTxt: Label 'User, Permission, System';
        ReportLayoutsNameTxt: Label 'Report Layout Selection';
        ReportLayoutsDescriptionTxt: Label 'Define the appearance for PDF or printed documents and reports.';
        ReportLayoutsKeywordsTxt: Label 'Report, Layout, Design';
        SMTPMailSetupNameTxt: Label 'SMTP Mail Setup';
        SMTPMailSetupDescriptionTxt: Label 'Set up your email server.';
        SMTPMailSetupKeywordsTxt: Label 'System, SMTP, Mail';
        UsersNameTxt: Label 'Users';
        UsersDescriptionTxt: Label 'Set up users and assign permissions sets.';
        UsersKeywordsTxt: Label 'System, User, Permission, Authentication, Password';
        ResponsibilityCentersNameTxt: Label 'Responsibility Centers';
        ResponsibilityCentersDescriptionTxt: Label 'Set up additional company locations, such as sales offices or warehouses.';
        ResponsibilityCentersKeywordsTxt: Label 'Location, Distributed, Office';
        OnlineMapSetupNameTxt: Label 'Online Map Setup';
        OnlineMapSetupDescriptionTxt: Label 'Define which online map service to use.';
        OnlineMapSetupKeywordsTxt: Label 'Map, Geo, Reference data';
        DefaultIconFileNameTxt: Label 'Default';
        AccountingPeriodsNameTxt: Label 'Accounting Periods';
        AccountingPeriodsDescriptionTxt: Label 'Set up the number of accounting periods, such as 12 monthly periods, within the fiscal year and specify which period is the start of the new fiscal year.';
        AccountingPeriodsKeywordsTxt: Label 'Accounting, Periods';
        DimensionsNameTxt: Label 'Dimensions';
        DimensionsDescriptionTxt: Label 'Set up dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';
        DimensionsKeywordsTxt: Label 'Dimensions';
        CashFlowSetupNameTxt: Label 'Cash Flow Setup';
        CashFlowSetupDescriptionTxt: Label 'Set up the accounts where cash flow figures for sales, purchase, and fixed-asset transactions are stored.';
        CashFlowSetupKeywordsTxt: Label 'Cash Flow';
        BankExportImportSetupNameTxt: Label 'Bank Export/Import Setup';
        BankExportImportSetupDescriptionTxt: Label 'Set up file formats for exporting vendor payments and for importing bank statements.';
        BankExportImportSetupKeywordsTxt: Label 'Bank, Statement, Export, Import';
        GeneralPostingSetupNameTxt: Label 'General Posting Setup';
        GeneralPostingSetupDescriptionTxt: Label 'Set up combinations of general business and general product posting groups by specifying account numbers for posting of sales and purchase transactions.';
        GeneralPostingSetupKeywordsTxt: Label 'Posting, General';
        GenBusinessPostingGroupsNameTxt: Label 'Gen. Business Posting Groups';
        GenBusinessPostingGroupsDescriptionTxt: Label 'Set up the trade-type posting groups that you assign to customer and vendor cards to link transactions with the appropriate general ledger account.';
        GenBusinessPostingGroupsKeywordsTxt: Label 'Posting, General';
        GenProductPostingGroupsNameTxt: Label 'Gen. Product Posting Groups';
        GenProductPostingGroupsDescriptionTxt: Label 'Set up the item-type posting groups that you assign to customer and vendor cards to link transactions with the appropriate general ledger account.';
        GenProductPostingGroupsKeywordsTxt: Label 'Posting, Product';
        VATPostingSetupNameTxt: Label 'VAT Posting Setup';
        VATPostingSetupDescriptionTxt: Label 'Define how tax is posted to the general ledger.';
        VATPostingSetupKeywordsTxt: Label 'VAT, Posting';
        VATBusinessPostingGroupsNameTxt: Label 'VAT Business Posting Groups';
        VATBusinessPostingGroupsDescriptionTxt: Label 'Set up the trade-type posting groups that you assign to customer and vendor cards to link VAT amounts with the appropriate general ledger account.';
        VATBusinessPostingGroupsKeywordsTxt: Label 'VAT, Posting, Business';
        VATProductPostingGroupsNameTxt: Label 'VAT Product Posting Groups';
        VATProductPostingGroupsDescriptionTxt: Label 'Set up the item-type posting groups that you assign to customer and vendor cards to link VAT amounts with the appropriate general ledger account.';
        VATProductPostingGroupsKeywordsTxt: Label 'VAT, Posting';
        VATReportSetupNameTxt: Label 'VAT Report Setup';
        VATReportSetupDescriptionTxt: Label 'Set up number series and options for the report that you periodically send to the authorities to declare your VAT.';
        VATReportSetupKeywordsTxt: Label 'VAT, Report';
        BankAccountPostingGroupsNameTxt: Label 'Bank Account Posting Groups';
        BankAccountPostingGroupsDescriptionTxt: Label 'Set up posting groups, so that payments in and out of each bank account are posted to the specified general ledger account.';
        BankAccountPostingGroupsKeywordsTxt: Label 'Bank Account, Posting';
        GeneralJournalTemplatesNameTxt: Label 'General Journal Templates';
        GeneralJournalTemplatesDescriptionTxt: Label 'Set up templates for the journals that you use for bookkeeping tasks. Templates allow you to work in a journal window that is designed for a specific purpose.';
        GeneralJournalTemplatesKeywordsTxt: Label 'Journal, Templates';
        VATStatementTemplatesNameTxt: Label 'VAT Statement Templates';
        VATStatementTemplatesDescriptionTxt: Label 'Set up the reports that you use to settle VAT and report to the customs and tax authorities.';
        VATStatementTemplatesKeywordsTxt: Label 'VAT, Statement, Templates';
        IntrastatTemplatesNameTxt: Label 'Intrastat Templates';
        IntrastatTemplatesDescriptionTxt: Label 'Define how you want to set up and keep track of journals to report Intrastat.';
        IntrastatTemplatesKeywordsTxt: Label 'Intrastat';
        BusinessRelationsNameTxt: Label 'Business Relations';
        BusinessRelationsDescriptionTxt: Label 'Set up or update Business Relations.';
        BusinessRelationsKeywordsTxt: Label 'Business Relations.';
        IndustryGroupsNameTxt: Label 'Industry Groups';
        IndustryGroupsDescriptionTxt: Label 'Set up or update Industry Groups.';
        IndustryGroupsKeywordsTxt: Label 'Industry Groups.';
        WebSourcesNameTxt: Label 'Web Sources';
        WebSourcesDescriptionTxt: Label 'Set up or update Web Sources.';
        WebSourcesKeywordsTxt: Label 'Web Sources.';
        JobResponsibilitiesNameTxt: Label 'Job Responsibilities';
        JobResponsibilitiesDescriptionTxt: Label 'Set up or update Job Responsibilities.';
        JobResponsibilitiesKeywordsTxt: Label 'Job Responsibilities.';
        OrganizationalLevelsNameTxt: Label 'Organizational Levels';
        OrganizationalLevelsDescriptionTxt: Label 'Set up or update Organizational Levels.';
        OrganizationalLevelsKeywordsTxt: Label 'Organizational Levels.';
        InteractionGroupsNameTxt: Label 'Interaction Groups';
        InteractionGroupsDescriptionTxt: Label 'Set up or update Interaction Groups.';
        InteractionGroupsKeywordsTxt: Label 'Interaction Groups.';
        InteractionTemplatesNameTxt: Label 'Interaction Templates';
        InteractionTemplatesDescriptionTxt: Label 'Set up or update Interaction Templates.';
        InteractionTemplatesKeywordsTxt: Label 'Interaction Templates.';
        SalutationsNameTxt: Label 'Salutations';
        SalutationsDescriptionTxt: Label 'Set up or update Salutations.';
        SalutationsKeywordsTxt: Label 'Salutations.';
        MailingGroupsNameTxt: Label 'Mailing Groups';
        MailingGroupsDescriptionTxt: Label 'Set up or update Mailing Groups.';
        MailingGroupsKeywordsTxt: Label 'Mailing Groups.';
        SalesCyclesNameTxt: Label 'Sales Cycles';
        SalesCyclesDescriptionTxt: Label 'Set up or update Sales Cycles.';
        SalesCyclesKeywordsTxt: Label 'Sales Cycles.';
        CloseOpportunityCodesNameTxt: Label 'Close Opportunity Codes';
        CloseOpportunityCodesDescriptionTxt: Label 'Set up or update Close Opportunity Codes.';
        CloseOpportunityCodesKeywordsTxt: Label 'Close Opportunity Codes.';
        QuestionnaireSetupNameTxt: Label 'Questionnaire Setup';
        QuestionnaireSetupDescriptionTxt: Label 'Set up or update Questionnaire Setup.';
        QuestionnaireSetupKeywordsTxt: Label 'Questionnaire Setup.';
        ActivitiesNameTxt: Label 'Activities';
        ActivitiesDescriptionTxt: Label 'Set up or update Activities.';
        ActivitiesKeywordsTxt: Label 'Activities.';
        MarketingSetupNameTxt: Label 'Marketing Setup';
        MarketingSetupDescriptionTxt: Label 'Set up or update Marketing Setup.';
        MarketingSetupKeywordsTxt: Label 'Marketing Setup.';
        InteractionTemplateSetupNameTxt: Label 'Interaction Template Setup';
        InteractionTemplateSetupDescriptionTxt: Label 'Set up or update Interaction Template Setup.';
        InteractionTemplateSetupKeywordsTxt: Label 'Interaction Template Setup.';
        VATClausesNameTxt: Label 'VAT Clauses';
        VATClausesDescriptionTxt: Label 'Set up descriptions (VAT Act references) that will be printed on invoices when non standard VAT rate is used on invoice.';
        VATClausesKeywordsTxt: Label 'VAT, Invoice, Clause';
        AnalysisViewsTxt: Label 'Analysis by Dimensions';
        AnalysisViewsDescriptionTxt: Label 'Set up which dimension values and filters are used when you use analysis views to analyze amounts in your general ledger by dimensions.';
        AnalysisViewsKeywordsTxt: Label 'Dimensions,Reporting,Analysis Views';
        VATReportConfigTxt: Label 'VAT Report Configuration';
        VATReportConfigDescriptionTxt: Label 'Set up configuration for VAT reports.';
        VATReportConfigKeywordsTxt: Label 'VAT Report, Return, EC Sales List';
        VATReportTxt: Label 'VAT Report Setup';
        VATReportDescriptionTxt: Label 'Set up VAT reports.';
        VATReportKeywordsTxt: Label 'VAT Report, Suggest, Validate, Submission,VAT Return, EC Sales List';
        EnvironmentTxt: Label 'Environments';
        EnvironmentDescriptionTxt: Label 'Set up sandbox environment.';
        EnvironmentKeywordsTxt: Label 'System, Environment, Sandbox';
        ICSetupTxt: Label 'Intercompany Setup';
        ICSetupDescriptionTxt: Label 'View or edit the intercompany setup for the current company.';
        ICSetupKeywordsTxt: Label 'Intercompany';
        ICPartnersTxt: Label 'Intercompany Partners';
        ICPartnersDescriptionTxt: Label 'Set up intercompany partners.';
        ICPartnersKeywordsTxt: Label 'Intercompany, Partners';
        ICChartOfAccountsTxt: Label 'Intercompany Chart of Accounts';
        ICChartOfAccountsDescriptionTxt: Label 'Set up how you want your company''s chart of accounts to correspond to the charts of accounts of your partners.';
        ICChartOfAccountsKeywordsTxt: Label 'Intercompany, Ledger, Finance';
        ICDimensionsTxt: Label 'Intercompany Dimensions';
        ICDimensionsDescriptionTxt: Label 'Set up how your company''s dimension codes correspond to the dimension codes of your intercompany partners.';
        ICDimensionsKeywordsTxt: Label 'Intercompany, Dimensions';
        CostAccountingSetupNameTxt: Label 'Cost Accounting Setup';
        CostAccountingSetupDescriptionTxt: Label 'Set up general ledger transfers to cost accounting, dimension links to cost centers and objects, and how to handle allocation document numbers and IDs.';
        CostAccountingSetupKeywordsTxt: Label 'Cost, Accounting';

    [EventSubscriber(ObjectType::Table, 1875, 'OnRegisterBusinessSetup', '', false, false)]
    local procedure InsertBusinessSetupOnRegisterBusinessSetup(var TempBusinessSetup: Record "Business Setup" temporary)
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        PermissionManager: Codeunit "Permission Manager";
    begin
        // General
        if ApplicationAreaMgmtFacade.IsFoundationEnabled or ApplicationAreaMgmtFacade.IsAllDisabled then begin
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,CompanyNameTxt,CompanyDescriptionTxt,
            CompanyKeywordsTxt,TempBusinessSetup.Area::General,PAGE::"Company Information",DefaultIconFileNameTxt);
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,CountriesRegionsNameTxt,CountriesRegionsDescriptionTxt,
            CountriesRegionsKeywordsTxt,TempBusinessSetup.Area::General,PAGE::"Countries/Regions",DefaultIconFileNameTxt);
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,NoSeriesNameTxt,NoSeriesDescriptionTxt,
            NoSeriesKeywordsTxt,TempBusinessSetup.Area::General,PAGE::"No. Series",DefaultIconFileNameTxt);
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,PostCodesNameTxt,PostCodesDescriptionTxt,
            PostCodesKeywordsTxt,TempBusinessSetup.Area::General,PAGE::"Post Codes",DefaultIconFileNameTxt);
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,ReasonCodesNameTxt,ReasonCodesDescriptionTxt,
            ReasonCodesKeywordsTxt,TempBusinessSetup.Area::General,PAGE::"Reason Codes",DefaultIconFileNameTxt);
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,SourceCodesNameTxt,SourceCodesDescriptionTxt,
            SourceCodesKeywordsTxt,TempBusinessSetup.Area::General,PAGE::"Source Codes",DefaultIconFileNameTxt);
        end;

        if ApplicationAreaMgmtFacade.IsSuiteEnabled or ApplicationAreaMgmtFacade.IsAllDisabled then begin
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,CurrenciesNameTxt,CurrenciesDescriptionTxt,
            CurrenciesKeywordsTxt,TempBusinessSetup.Area::General,PAGE::Currencies,DefaultIconFileNameTxt);
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,LanguagesNameTxt,LanguagesDescriptionTxt,
            LanguagesKeywordsTxt,TempBusinessSetup.Area::General,PAGE::Languages,DefaultIconFileNameTxt);
        end;

        // Finance
        if ApplicationAreaMgmtFacade.IsFoundationEnabled or ApplicationAreaMgmtFacade.IsAllDisabled then begin
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,GeneralLedgerSetupNameTxt,GeneralLedgerSetupDescriptionTxt,
            GeneralLedgerSetupKeywordsTxt,TempBusinessSetup.Area::Finance,PAGE::"General Ledger Setup",
            DefaultIconFileNameTxt);
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,AccountingPeriodsNameTxt,AccountingPeriodsDescriptionTxt,
            AccountingPeriodsKeywordsTxt,TempBusinessSetup.Area::Finance,PAGE::"Accounting Periods",
            DefaultIconFileNameTxt);
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,BankExportImportSetupNameTxt,BankExportImportSetupDescriptionTxt,
            BankExportImportSetupKeywordsTxt,TempBusinessSetup.Area::Finance,PAGE::"Bank Export/Import Setup",
            DefaultIconFileNameTxt);
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,GeneralPostingSetupNameTxt,GeneralPostingSetupDescriptionTxt,
            GeneralPostingSetupKeywordsTxt,TempBusinessSetup.Area::Finance,PAGE::"General Posting Setup",
            DefaultIconFileNameTxt);
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,GenBusinessPostingGroupsNameTxt,GenBusinessPostingGroupsDescriptionTxt,
            GenBusinessPostingGroupsKeywordsTxt,TempBusinessSetup.Area::Finance,PAGE::"Gen. Business Posting Groups",
            DefaultIconFileNameTxt);
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,GenProductPostingGroupsNameTxt,GenProductPostingGroupsDescriptionTxt,
            GenProductPostingGroupsKeywordsTxt,TempBusinessSetup.Area::Finance,PAGE::"Gen. Product Posting Groups",
            DefaultIconFileNameTxt);
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,VATPostingSetupNameTxt,VATPostingSetupDescriptionTxt,
            VATPostingSetupKeywordsTxt,TempBusinessSetup.Area::Finance,PAGE::"VAT Posting Setup",
            DefaultIconFileNameTxt);
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,VATBusinessPostingGroupsNameTxt,VATBusinessPostingGroupsDescriptionTxt,
            VATBusinessPostingGroupsKeywordsTxt,TempBusinessSetup.Area::Finance,PAGE::"VAT Business Posting Groups",
            DefaultIconFileNameTxt);
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,VATProductPostingGroupsNameTxt,VATProductPostingGroupsDescriptionTxt,
            VATProductPostingGroupsKeywordsTxt,TempBusinessSetup.Area::Finance,PAGE::"VAT Product Posting Groups",
            DefaultIconFileNameTxt);
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,VATReportSetupNameTxt,VATReportSetupDescriptionTxt,
            VATReportSetupKeywordsTxt,TempBusinessSetup.Area::Finance,PAGE::"VAT Report Setup",
            DefaultIconFileNameTxt);
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,BankAccountPostingGroupsNameTxt,BankAccountPostingGroupsDescriptionTxt,
            BankAccountPostingGroupsKeywordsTxt,TempBusinessSetup.Area::Finance,PAGE::"Bank Account Posting Groups",
            DefaultIconFileNameTxt);
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,GeneralJournalTemplatesNameTxt,GeneralJournalTemplatesDescriptionTxt,
            GeneralJournalTemplatesKeywordsTxt,TempBusinessSetup.Area::Finance,PAGE::"General Journal Templates",
            DefaultIconFileNameTxt);
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,VATStatementTemplatesNameTxt,VATStatementTemplatesDescriptionTxt,
            VATStatementTemplatesKeywordsTxt,TempBusinessSetup.Area::Finance,PAGE::"VAT Statement Templates",
            DefaultIconFileNameTxt);
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,VATClausesNameTxt,VATClausesDescriptionTxt,
            VATClausesKeywordsTxt,TempBusinessSetup.Area::Finance,PAGE::"VAT Clauses",
            DefaultIconFileNameTxt);
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,VATReportConfigTxt,VATReportConfigDescriptionTxt,
            VATReportConfigKeywordsTxt,TempBusinessSetup.Area::Finance,PAGE::"VAT Reports Configuration",
            DefaultIconFileNameTxt);
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,VATReportTxt,VATReportDescriptionTxt,
            VATReportKeywordsTxt,TempBusinessSetup.Area::Finance,PAGE::"VAT Report Setup",
            DefaultIconFileNameTxt);
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,CashFlowSetupNameTxt,CashFlowSetupDescriptionTxt,
            CashFlowSetupKeywordsTxt,TempBusinessSetup.Area::Finance,PAGE::"Cash Flow Setup",
            DefaultIconFileNameTxt);
        end;

        if ApplicationAreaMgmtFacade.IsSuiteEnabled or ApplicationAreaMgmtFacade.IsAllDisabled then begin
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,DimensionsNameTxt,DimensionsDescriptionTxt,
            DimensionsKeywordsTxt,TempBusinessSetup.Area::Finance,PAGE::Dimensions,
            DefaultIconFileNameTxt);
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,AnalysisViewsTxt,AnalysisViewsDescriptionTxt,
            AnalysisViewsKeywordsTxt,TempBusinessSetup.Area::Finance,PAGE::"Analysis View List",
            DefaultIconFileNameTxt);
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,CostAccountingSetupNameTxt,CostAccountingSetupDescriptionTxt,
            CostAccountingSetupKeywordsTxt,TempBusinessSetup.Area::Finance,PAGE::"Cost Accounting Setup",
            DefaultIconFileNameTxt);
        end;

        if ApplicationAreaMgmtFacade.IsAllDisabled then begin
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,ResponsibilityCentersNameTxt,ResponsibilityCentersDescriptionTxt,
            ResponsibilityCentersKeywordsTxt,TempBusinessSetup.Area::Finance,PAGE::"Responsibility Center List",
            DefaultIconFileNameTxt);
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,IntrastatTemplatesNameTxt,IntrastatTemplatesDescriptionTxt,
            IntrastatTemplatesKeywordsTxt,TempBusinessSetup.Area::Finance,PAGE::"Intrastat Journal Templates",
            DefaultIconFileNameTxt);
        end;

        // System
        if ApplicationAreaMgmtFacade.IsAllDisabled then
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,PermissionSetsNameTxt,PermissionSetsDescriptionTxt,
            PermissionSetsKeywordsTxt,TempBusinessSetup.Area::System,PAGE::"Permission Sets",DefaultIconFileNameTxt);

        if ApplicationAreaMgmtFacade.IsFoundationEnabled or ApplicationAreaMgmtFacade.IsAllDisabled then begin
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,ReportLayoutsNameTxt,ReportLayoutsDescriptionTxt,
            ReportLayoutsKeywordsTxt,TempBusinessSetup.Area::System,PAGE::"Report Layout Selection",DefaultIconFileNameTxt);
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,SMTPMailSetupNameTxt,SMTPMailSetupDescriptionTxt,
            SMTPMailSetupKeywordsTxt,TempBusinessSetup.Area::System,PAGE::"SMTP Mail Setup",DefaultIconFileNameTxt);
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,UsersNameTxt,UsersDescriptionTxt,
            UsersKeywordsTxt,TempBusinessSetup.Area::System,PAGE::Users,DefaultIconFileNameTxt);
          if PermissionManager.SoftwareAsAService then
            TempBusinessSetup.InsertBusinessSetup(
              TempBusinessSetup,EnvironmentTxt,EnvironmentDescriptionTxt,EnvironmentKeywordsTxt,
              TempBusinessSetup.Area::System,PAGE::"Sandbox Environment",DefaultIconFileNameTxt);
        end;

        // Jobs
        if ApplicationAreaMgmtFacade.IsJobsEnabled or ApplicationAreaMgmtFacade.IsAllDisabled then
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,JobsSetupNameTxt,JobsSetupDescriptionTxt,
            JobsSetupKeywordsTxt,TempBusinessSetup.Area::Jobs,PAGE::"Jobs Setup",DefaultIconFileNameTxt);

        // Fixed Assets
        if ApplicationAreaMgmtFacade.IsFixedAssetEnabled or ApplicationAreaMgmtFacade.IsAllDisabled then
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,FixedAssetSetupNameTxt,FixedAssetSetupDescriptionTxt,
            FixedAssetSetupKeywordsTxt,TempBusinessSetup.Area::"Fixed Assets",PAGE::"Fixed Asset Setup",DefaultIconFileNameTxt);

        // HR
        if ApplicationAreaMgmtFacade.IsBasicHREnabled or ApplicationAreaMgmtFacade.IsAllDisabled then
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,HumanResourcesSetupNameTxt,HumanResourcesSetupDescriptionTxt,
            HumanResourcesSetupKeywordsTxt,TempBusinessSetup.Area::HR,PAGE::"Human Resources Setup",
            DefaultIconFileNameTxt);

        // Inventory
        if ApplicationAreaMgmtFacade.IsFoundationEnabled or ApplicationAreaMgmtFacade.IsAllDisabled then
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,InventorySetupNameTxt,InventorySetupDescriptionTxt,
            InventorySetupKeywordsTxt,TempBusinessSetup.Area::Inventory,PAGE::"Inventory Setup",DefaultIconFileNameTxt);

        // Location
        if ApplicationAreaMgmtFacade.IsLocationEnabled or ApplicationAreaMgmtFacade.IsAllDisabled then begin
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,LocationsNameTxt,LocationsDescriptionTxt,
            LocationsKeywordsTxt,TempBusinessSetup.Area::Inventory,PAGE::"Location List",DefaultIconFileNameTxt);

          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,TransferRoutesNameTxt,TransferRoutesDescriptionTxt,
            TransferRoutesKeywordsTxt,TempBusinessSetup.Area::Inventory,PAGE::"Transfer Routes",DefaultIconFileNameTxt);
        end;

        // Item Charges
        if ApplicationAreaMgmtFacade.IsItemChargesEnabled or ApplicationAreaMgmtFacade.IsAllDisabled then
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,ItemChargesNameTxt,ItemChargesDescriptionTxt,
            ItemChargesKeywordsTxt,TempBusinessSetup.Area::Inventory,PAGE::"Item Charges",DefaultIconFileNameTxt);

        // Relationship Management
        if ApplicationAreaMgmtFacade.IsSuiteEnabled or ApplicationAreaMgmtFacade.IsAllDisabled then begin
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,BusinessRelationsNameTxt,BusinessRelationsDescriptionTxt,
            BusinessRelationsKeywordsTxt,TempBusinessSetup.Area::"Relationship Mngt",PAGE::"Business Relations",DefaultIconFileNameTxt);

          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,IndustryGroupsNameTxt,IndustryGroupsDescriptionTxt,
            IndustryGroupsKeywordsTxt,TempBusinessSetup.Area::"Relationship Mngt",PAGE::"Industry Groups",DefaultIconFileNameTxt);

          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,WebSourcesNameTxt,WebSourcesDescriptionTxt,
            WebSourcesKeywordsTxt,TempBusinessSetup.Area::"Relationship Mngt",PAGE::"Web Sources",DefaultIconFileNameTxt);

          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,JobResponsibilitiesNameTxt,JobResponsibilitiesDescriptionTxt,
            JobResponsibilitiesKeywordsTxt,TempBusinessSetup.Area::"Relationship Mngt",PAGE::"Job Responsibilities",
            DefaultIconFileNameTxt);

          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,OrganizationalLevelsNameTxt,OrganizationalLevelsDescriptionTxt,
            OrganizationalLevelsKeywordsTxt,TempBusinessSetup.Area::"Relationship Mngt",PAGE::"Organizational Levels",
            DefaultIconFileNameTxt);

          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,InteractionGroupsNameTxt,InteractionGroupsDescriptionTxt,
            InteractionGroupsKeywordsTxt,TempBusinessSetup.Area::"Relationship Mngt",PAGE::"Interaction Groups",DefaultIconFileNameTxt);

          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,InteractionTemplatesNameTxt,InteractionTemplatesDescriptionTxt,
            InteractionTemplatesKeywordsTxt,TempBusinessSetup.Area::"Relationship Mngt",PAGE::"Interaction Templates",
            DefaultIconFileNameTxt);

          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,SalutationsNameTxt,SalutationsDescriptionTxt,
            SalutationsKeywordsTxt,TempBusinessSetup.Area::"Relationship Mngt",PAGE::Salutations,DefaultIconFileNameTxt);

          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,MailingGroupsNameTxt,MailingGroupsDescriptionTxt,
            MailingGroupsKeywordsTxt,TempBusinessSetup.Area::"Relationship Mngt",PAGE::"Mailing Groups",DefaultIconFileNameTxt);

          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,SalesCyclesNameTxt,SalesCyclesDescriptionTxt,
            SalesCyclesKeywordsTxt,TempBusinessSetup.Area::"Relationship Mngt",PAGE::"Sales Cycles",DefaultIconFileNameTxt);

          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,CloseOpportunityCodesNameTxt,CloseOpportunityCodesDescriptionTxt,
            CloseOpportunityCodesKeywordsTxt,TempBusinessSetup.Area::"Relationship Mngt",PAGE::"Close Opportunity Codes",
            DefaultIconFileNameTxt);

          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,QuestionnaireSetupNameTxt,QuestionnaireSetupDescriptionTxt,
            QuestionnaireSetupKeywordsTxt,TempBusinessSetup.Area::"Relationship Mngt",PAGE::"Profile Questionnaires",
            DefaultIconFileNameTxt);

          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,ActivitiesNameTxt,ActivitiesDescriptionTxt,
            ActivitiesKeywordsTxt,TempBusinessSetup.Area::"Relationship Mngt",PAGE::"Activity List",DefaultIconFileNameTxt);

          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,MarketingSetupNameTxt,MarketingSetupDescriptionTxt,
            MarketingSetupKeywordsTxt,TempBusinessSetup.Area::"Relationship Mngt",PAGE::"Marketing Setup",DefaultIconFileNameTxt);

          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,InteractionTemplateSetupNameTxt,InteractionTemplateSetupDescriptionTxt,
            InteractionTemplateSetupKeywordsTxt,TempBusinessSetup.Area::"Relationship Mngt",PAGE::"Interaction Template Setup",
            DefaultIconFileNameTxt);
        end;

        // Service
        if ApplicationAreaMgmtFacade.IsFoundationEnabled or ApplicationAreaMgmtFacade.IsAllDisabled then
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,OnlineMapSetupNameTxt,OnlineMapSetupDescriptionTxt,
            OnlineMapSetupKeywordsTxt,TempBusinessSetup.Area::Service,PAGE::"Online Map Setup",DefaultIconFileNameTxt);

        // Sales
        if ApplicationAreaMgmtFacade.IsFoundationEnabled or ApplicationAreaMgmtFacade.IsAllDisabled then
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,SalesReceivablesSetupNameTxt,SalesReceivablesSetupDescriptionTxt,
            SalesReceivablesSetupKeywordsTxt,TempBusinessSetup.Area::Sales,PAGE::"Sales & Receivables Setup",
            DefaultIconFileNameTxt);

        // Purchasing
        if ApplicationAreaMgmtFacade.IsFoundationEnabled or ApplicationAreaMgmtFacade.IsAllDisabled then
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,PurchasePayablesSetupNameTxt,PurchasePayablesSetupDescriptionTxt,
            PurchasePayablesSetupKeywordsTxt,TempBusinessSetup.Area::Purchasing,PAGE::"Purchases & Payables Setup",
            DefaultIconFileNameTxt);

        // Intercompany
        if ApplicationAreaMgmtFacade.IsIntercompanyEnabled or ApplicationAreaMgmtFacade.IsAllDisabled then begin
          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,ICSetupTxt,ICSetupDescriptionTxt,
            ICSetupKeywordsTxt,TempBusinessSetup.Area::Intercompany,PAGE::"IC Setup",DefaultIconFileNameTxt);

          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,ICPartnersTxt,ICPartnersDescriptionTxt,
            ICPartnersKeywordsTxt,TempBusinessSetup.Area::Intercompany,PAGE::"IC Partner List",DefaultIconFileNameTxt);

          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,ICChartOfAccountsTxt,ICChartOfAccountsDescriptionTxt,
            ICChartOfAccountsKeywordsTxt,TempBusinessSetup.Area::Intercompany,PAGE::"IC Chart of Accounts",DefaultIconFileNameTxt);

          TempBusinessSetup.InsertBusinessSetup(TempBusinessSetup,ICDimensionsTxt,ICDimensionsDescriptionTxt,
            ICDimensionsKeywordsTxt,TempBusinessSetup.Area::Intercompany,PAGE::"IC Dimension List",DefaultIconFileNameTxt);
        end;
    end;
}

