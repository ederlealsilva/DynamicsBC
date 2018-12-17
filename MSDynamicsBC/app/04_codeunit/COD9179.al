codeunit 9179 "Application Area Mgmt. Facade"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    [Scope('Personalization')]
    procedure GetApplicationAreaSetupRecFromCompany(var ApplicationAreaSetup: Record "Application Area Setup";CompanyName: Text): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.GetApplicationAreaSetupRecFromCompany(ApplicationAreaSetup,CompanyName))
    end;

    [Scope('Personalization')]
    procedure GetApplicationAreaSetup(): Text
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.GetApplicationAreaSetup)
    end;

    [Scope('Personalization')]
    procedure SetupApplicationArea()
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        ApplicationAreaMgmt.SetupApplicationArea
    end;

    [Scope('Personalization')]
    procedure IsFoundationEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsFoundationEnabled)
    end;

    [Scope('Personalization')]
    procedure IsBasicOnlyEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsBasicOnlyEnabled)
    end;

    [Scope('Personalization')]
    procedure IsAdvancedEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsAdvancedEnabled)
    end;

    [Scope('Personalization')]
    procedure IsFixedAssetEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsFixedAssetEnabled)
    end;

    [Scope('Personalization')]
    procedure IsJobsEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsJobsEnabled)
    end;

    [Scope('Personalization')]
    procedure IsBasicHREnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsBasicHREnabled)
    end;

    [Scope('Personalization')]
    procedure IsDimensionEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsDimensionEnabled)
    end;

    [Scope('Personalization')]
    procedure IsLocationEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsLocationEnabled)
    end;

    [Scope('Personalization')]
    procedure IsAssemblyEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsAssemblyEnabled)
    end;

    [Scope('Personalization')]
    procedure IsItemChargesEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsItemChargesEnabled)
    end;

    [Scope('Personalization')]
    procedure IsItemTrackingEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsItemTrackingEnabled)
    end;

    [Scope('Personalization')]
    procedure IsIntercompanyEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsIntercompanyEnabled)
    end;

    [Scope('Personalization')]
    procedure IsSalesReturnOrderEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsSalesReturnOrderEnabled)
    end;

    [Scope('Personalization')]
    procedure IsPurchaseReturnOrderEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsPurchaseReturnOrderEnabled)
    end;

    [Scope('Personalization')]
    procedure IsCostAccountingEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsCostAccountingEnabled)
    end;

    [Scope('Personalization')]
    procedure IsSalesBudgetEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsSalesBudgetEnabled)
    end;

    [Scope('Personalization')]
    procedure IsPurchaseBudgetEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsPurchaseBudgetEnabled)
    end;

    [Scope('Personalization')]
    procedure IsItemBudgetEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsItemBudgetEnabled)
    end;

    [Scope('Personalization')]
    procedure IsSalesAnalysisEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsSalesAnalysisEnabled)
    end;

    [Scope('Personalization')]
    procedure IsPurchaseAnalysisEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsPurchaseAnalysisEnabled)
    end;

    [Scope('Personalization')]
    procedure IsInventoryAnalysisEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsInventoryAnalysisEnabled)
    end;

    [Scope('Personalization')]
    procedure IsInvoicingOnlyEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsInvoicingOnlyEnabled)
    end;

    [Scope('Personalization')]
    procedure IsManufacturingEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsManufacturingEnabled)
    end;

    [Scope('Personalization')]
    procedure IsPlanningEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsPlanningEnabled)
    end;

    [Scope('Personalization')]
    procedure IsRelationshipMgmtEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsRelationshipMgmtEnabled)
    end;

    [Scope('Personalization')]
    procedure IsServiceEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsServiceEnabled)
    end;

    [Scope('Personalization')]
    procedure IsWarehouseEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsWarehouseEnabled)
    end;

    [Scope('Personalization')]
    procedure IsReservationEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsReservationEnabled)
    end;

    [Scope('Personalization')]
    procedure IsOrderPromisingEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsOrderPromisingEnabled)
    end;

    [Scope('Personalization')]
    procedure IsCommentsEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsCommentsEnabled)
    end;

    [Scope('Personalization')]
    procedure IsSuiteEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsSuiteEnabled)
    end;

    [Scope('Personalization')]
    procedure IsAllDisabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsAllDisabled)
    end;

    [Scope('Personalization')]
    procedure IsPremiumEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsPremiumEnabled)
    end;

    [Scope('Personalization')]
    procedure CheckAppAreaOnlyBasic()
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        ApplicationAreaMgmt.CheckAppAreaOnlyBasic
    end;

    [Scope('Personalization')]
    procedure IsValidExperienceTierSelected(SelectedExperienceTier: Text): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsValidExperienceTierSelected(SelectedExperienceTier))
    end;

    [Scope('Personalization')]
    procedure LookupExperienceTier(var NewExperienceTier: Text): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.LookupExperienceTier(NewExperienceTier))
    end;

    [Scope('Personalization')]
    procedure SaveExperienceTierCurrentCompany(NewExperienceTier: Text): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.SaveExperienceTierCurrentCompany(NewExperienceTier))
    end;

    [Scope('Personalization')]
    procedure GetExperienceTierCurrentCompany(var ExperienceTier: Text): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.GetExperienceTierCurrentCompany(ExperienceTier))
    end;

    [Scope('Personalization')]
    procedure IsBasicExperienceEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsBasicExperienceEnabled)
    end;

    [Scope('Personalization')]
    procedure IsEssentialExperienceEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsEssentialExperienceEnabled)
    end;

    [Scope('Personalization')]
    procedure IsPremiumExperienceEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsPremiumExperienceEnabled)
    end;

    [Scope('Personalization')]
    procedure IsCustomExperienceEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsCustomExperienceEnabled)
    end;

    [Scope('Personalization')]
    procedure IsAdvancedExperienceEnabled(): Boolean
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        exit(ApplicationAreaMgmt.IsAdvancedExperienceEnabled)
    end;

    [EventSubscriber(ObjectType::Codeunit, 9178, 'OnGetBasicExperienceAppAreas', '', false, false)]
    local procedure RaiseOnGetBasicExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        OnGetBasicExperienceAppAreas(TempApplicationAreaSetup)
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetBasicExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 9178, 'OnGetEssentialExperienceAppAreas', '', false, false)]
    local procedure RaiseOnGetEssentialExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        OnGetEssentialExperienceAppAreas(TempApplicationAreaSetup);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetEssentialExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 9178, 'OnGetEssentialExperienceAppAreas', '', false, false)]
    local procedure RaiseOnGetPremiumExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        OnGetPremiumExperienceAppAreas(TempApplicationAreaSetup);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetPremiumExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 9178, 'OnBeforeLookupExperienceTier', '', false, false)]
    local procedure RaiseOnBeforeLookupExperienceTier(var TempExperienceTierBuffer: Record "Experience Tier Buffer" temporary)
    begin
        OnBeforeLookupExperienceTier(TempExperienceTierBuffer)
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeLookupExperienceTier(var TempExperienceTierBuffer: Record "Experience Tier Buffer" temporary)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 9178, 'OnSetExperienceTier', '', false, false)]
    local procedure RaiseOnSetExperienceTier(ExperienceTierSetup: Record "Experience Tier Setup";var TempApplicationAreaSetup: Record "Application Area Setup" temporary;var ApplicationAreasSet: Boolean)
    begin
        OnSetExperienceTier(ExperienceTierSetup,TempApplicationAreaSetup,ApplicationAreasSet);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetExperienceTier(ExperienceTierSetup: Record "Experience Tier Setup";var TempApplicationAreaSetup: Record "Application Area Setup" temporary;var ApplicationAreasSet: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 9178, 'OnValidateApplicationAreas', '', false, false)]
    local procedure RaiseOnValidateApplicationAreas(ExperienceTierSetup: Record "Experience Tier Setup";TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        OnValidateApplicationAreas(ExperienceTierSetup,TempApplicationAreaSetup)
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateApplicationAreas(ExperienceTierSetup: Record "Experience Tier Setup";TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
    end;

    [Scope('Personalization')]
    procedure SetHideApplicationAreaError(NewHideApplicationAreaError: Boolean)
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        ApplicationAreaMgmt.SetHideApplicationAreaError(NewHideApplicationAreaError)
    end;

    procedure DeprecatedGetExperienceTierCurrentCompany(var ExperienceTier: Option ,,,,,Basic,,,,,,,,,,Essential,,,,,Custom,,,,,Advanced)
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
        ExperienceTierTxt: Text;
        SaveGlobalLanguage: Integer;
    begin
        GetExperienceTierCurrentCompany(ExperienceTierTxt);
        if (ExperienceTierTxt = '') and ApplicationAreaMgmt.IsAdvancedSaaSEnabled then
          ExperienceTier := ExperienceTier::Advanced
        else begin
          SaveGlobalLanguage := GlobalLanguage;
          GlobalLanguage := 1033;
          Evaluate(ExperienceTier,ExperienceTierTxt);
          GlobalLanguage := SaveGlobalLanguage;
        end;
    end;

    procedure DeprecatedSetExperienceTierCurrentCompany(ExperienceTier: Option ,,,,,Basic,,,,,,,,,,Essential,,,,,Custom,,,,,Advanced)
    var
        SaveGlobalLanguage: Integer;
    begin
        SaveGlobalLanguage := GlobalLanguage;
        GlobalLanguage := 1033;
        SaveExperienceTierCurrentCompany(Format(ExperienceTier));
        GlobalLanguage := SaveGlobalLanguage;
    end;
}

