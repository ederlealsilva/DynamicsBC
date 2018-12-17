codeunit 9178 "Application Area Mgmt."
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        OnlyBasicAppAreaMsg: Label 'You do not have access to this page, because your experience is set to Basic.';
        ValuesNotAllowedErr: Label 'The selected experience is not supported.\\In the Application Area window, you define what is shown in the user interface.';
        InvoicingExpTierErr: Label 'The Invoicing application area must be the only enabled area.';
        HideApplicationAreaError: Boolean;
        PremiumSubscriptionNeededMsg: Label 'To use the Premium experience, you must first buy the Premium plan.';

    local procedure GetApplicationAreaSetupRec(var ApplicationAreaSetup: Record "Application Area Setup"): Boolean
    var
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
    begin
        if not ApplicationAreaSetup.Get('','',UserId) then
          if not ApplicationAreaSetup.Get('',ConfPersonalizationMgt.GetCurrentProfileIDNoError) then
            if not GetApplicationAreaSetupRecFromCompany(ApplicationAreaSetup,CompanyName) then
              exit(ApplicationAreaSetup.Get);
        exit(true);
    end;

    procedure GetApplicationAreaSetupRecFromCompany(var ApplicationAreaSetup: Record "Application Area Setup";CompanyName: Text): Boolean
    begin
        exit(ApplicationAreaSetup.Get(CompanyName));
    end;

    procedure GetApplicationAreaSetup() ApplicationAreas: Text
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        FieldIndex: Integer;
    begin
        if not GetApplicationAreaSetupRec(ApplicationAreaSetup) then
          exit(ApplicationAreas);

        RecRef.GetTable(ApplicationAreaSetup);

        for FieldIndex := 1 to RecRef.FieldCount do begin
          FieldRef := RecRef.FieldIndex(FieldIndex);
          if not IsInPrimaryKey(FieldRef) then
            if FieldRef.Value then
              if ApplicationAreas = '' then
                ApplicationAreas := '#' + DelChr(FieldRef.Name)
              else
                ApplicationAreas := ApplicationAreas + ',#' + DelChr(FieldRef.Name);
        end;
    end;

    procedure GetApplicationAreaBuffer(var TempApplicationAreaBuffer: Record "Application Area Buffer" temporary)
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        FieldIndex: Integer;
    begin
        GetApplicationAreaSetupRec(ApplicationAreaSetup);
        RecRef.GetTable(ApplicationAreaSetup);

        for FieldIndex := GetFirstPublicAppAreaFieldIndex to RecRef.FieldCount do begin
          FieldRef := RecRef.FieldIndex(FieldIndex);
          if not IsInPrimaryKey(FieldRef) then begin
            TempApplicationAreaBuffer."Field No." := FieldRef.Number;
            TempApplicationAreaBuffer."Application Area" := FieldRef.Caption;
            TempApplicationAreaBuffer.Selected := FieldRef.Value;
            TempApplicationAreaBuffer.Insert(true);
          end;
        end;
    end;

    local procedure SaveApplicationArea(var TempApplicationAreaBuffer: Record "Application Area Buffer" temporary;ApplicationAreaSetup: Record "Application Area Setup";NoApplicationAreasExist: Boolean)
    var
        ExistingTempApplicationAreaBuffer: Record "Application Area Buffer" temporary;
        UserPreference: Record "User Preference";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        ApplicationAreasChanged: Boolean;
    begin
        GetApplicationAreaBuffer(ExistingTempApplicationAreaBuffer);
        RecRef.GetTable(ApplicationAreaSetup);

        TempApplicationAreaBuffer.FindFirst;
        ExistingTempApplicationAreaBuffer.FindFirst;
        repeat
          FieldRef := RecRef.Field(TempApplicationAreaBuffer."Field No.");
          FieldRef.Value := TempApplicationAreaBuffer.Selected;
          if TempApplicationAreaBuffer.Selected <> ExistingTempApplicationAreaBuffer.Selected then
            ApplicationAreasChanged := true;
        until (TempApplicationAreaBuffer.Next = 0) and (ExistingTempApplicationAreaBuffer.Next = 0);

        if NoApplicationAreasExist then begin
          if ApplicationAreasChanged then
            RecRef.Insert(true);
        end else
          RecRef.Modify(true);

        UserPreference.SetFilter("User ID",UserId);
        UserPreference.DeleteAll;

        SetupApplicationArea;
    end;

    local procedure TrySaveApplicationArea(var TempApplicationAreaBuffer: Record "Application Area Buffer" temporary;ApplicationAreaSetup: Record "Application Area Setup";NoApplicationAreaExist: Boolean) IsApplicationAreaChanged: Boolean
    var
        OldApplicationArea: Text;
    begin
        OldApplicationArea := ApplicationArea;
        SaveApplicationArea(TempApplicationAreaBuffer,ApplicationAreaSetup,NoApplicationAreaExist);
        IsApplicationAreaChanged := OldApplicationArea <> ApplicationArea;
    end;

    procedure TrySaveApplicationAreaCurrentCompany(var TempApplicationAreaBuffer: Record "Application Area Buffer" temporary) IsApplicationAreaChanged: Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        NoCompanyApplicationAreasExist: Boolean;
    begin
        if not ApplicationAreaSetup.Get(CompanyName) then begin
          ApplicationAreaSetup."Company Name" := CompanyName;
          NoCompanyApplicationAreasExist := true;
        end;

        IsApplicationAreaChanged :=
          TrySaveApplicationArea(TempApplicationAreaBuffer,ApplicationAreaSetup,NoCompanyApplicationAreasExist);
    end;

    procedure TrySaveApplicationAreaCurrentUser(var TempApplicationAreaBuffer: Record "Application Area Buffer" temporary) IsApplicationAreaChanged: Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        NoUserApplicationAreasExist: Boolean;
    begin
        if not ApplicationAreaSetup.Get('','',UserId) then begin
          ApplicationAreaSetup."User ID" := UserId;
          NoUserApplicationAreasExist := true;
        end;

        IsApplicationAreaChanged :=
          TrySaveApplicationArea(TempApplicationAreaBuffer,ApplicationAreaSetup,NoUserApplicationAreasExist);
    end;

    procedure SetupApplicationArea()
    begin
        ApplicationArea(GetApplicationAreaSetup);
    end;

    procedure IsFoundationEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        if not GetApplicationAreaSetupRec(ApplicationAreaSetup) then
          exit(false);

        exit(ApplicationAreaSetup.Basic or ApplicationAreaSetup.Suite);
    end;

    procedure IsBasicOnlyEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        if not GetApplicationAreaSetupRec(ApplicationAreaSetup) then
          exit(false);

        exit(ApplicationAreaSetup.Basic and not ApplicationAreaSetup.Suite and not ApplicationAreaSetup.Advanced);
    end;

    procedure IsAdvancedEnabled(): Boolean
    begin
        exit(not IsFoundationEnabled);
    end;

    procedure IsFixedAssetEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        if not GetApplicationAreaSetupRec(ApplicationAreaSetup) then
          exit(false);

        exit(ApplicationAreaSetup."Fixed Assets");
    end;

    procedure IsJobsEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        if not GetApplicationAreaSetupRec(ApplicationAreaSetup) then
          exit(false);

        exit(ApplicationAreaSetup.Jobs);
    end;

    procedure IsBasicHREnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        if not GetApplicationAreaSetupRec(ApplicationAreaSetup) then
          exit(false);

        exit(ApplicationAreaSetup.BasicHR);
    end;

    procedure IsDimensionEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        if not GetApplicationAreaSetupRec(ApplicationAreaSetup) then
          exit(false);

        exit(ApplicationAreaSetup.Dimensions);
    end;

    procedure IsLocationEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        if not GetApplicationAreaSetupRec(ApplicationAreaSetup) then
          exit(false);

        exit(ApplicationAreaSetup.Location);
    end;

    procedure IsAssemblyEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        if not GetApplicationAreaSetupRec(ApplicationAreaSetup) then
          exit(false);

        exit(ApplicationAreaSetup.Assembly);
    end;

    procedure IsItemChargesEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        if not GetApplicationAreaSetupRec(ApplicationAreaSetup) then
          exit(false);

        exit(ApplicationAreaSetup."Item Charges");
    end;

    procedure IsItemTrackingEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        if not GetApplicationAreaSetupRec(ApplicationAreaSetup) then
          exit(false);

        exit(ApplicationAreaSetup."Item Tracking");
    end;

    procedure IsIntercompanyEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        if not GetApplicationAreaSetupRec(ApplicationAreaSetup) then
          exit(false);

        exit(ApplicationAreaSetup.Intercompany);
    end;

    procedure IsSalesReturnOrderEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        if not GetApplicationAreaSetupRec(ApplicationAreaSetup) then
          exit(false);

        exit(ApplicationAreaSetup."Sales Return Order");
    end;

    procedure IsPurchaseReturnOrderEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        if not GetApplicationAreaSetupRec(ApplicationAreaSetup) then
          exit(false);

        exit(ApplicationAreaSetup."Purch Return Order");
    end;

    procedure IsCostAccountingEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        if not GetApplicationAreaSetupRec(ApplicationAreaSetup) then
          exit(false);

        exit(ApplicationAreaSetup."Cost Accounting");
    end;

    procedure IsSalesBudgetEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        if not GetApplicationAreaSetupRec(ApplicationAreaSetup) then
          exit(false);

        exit(ApplicationAreaSetup."Sales Budget");
    end;

    procedure IsPurchaseBudgetEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        if not GetApplicationAreaSetupRec(ApplicationAreaSetup) then
          exit(false);

        exit(ApplicationAreaSetup."Purchase Budget");
    end;

    procedure IsItemBudgetEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        if not GetApplicationAreaSetupRec(ApplicationAreaSetup) then
          exit(false);

        exit(ApplicationAreaSetup."Item Budget");
    end;

    procedure IsSalesAnalysisEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        if not GetApplicationAreaSetupRec(ApplicationAreaSetup) then
          exit(false);

        exit(ApplicationAreaSetup."Sales Analysis");
    end;

    procedure IsPurchaseAnalysisEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        if not GetApplicationAreaSetupRec(ApplicationAreaSetup) then
          exit(false);

        exit(ApplicationAreaSetup."Purchase Analysis");
    end;

    procedure IsInventoryAnalysisEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        if not GetApplicationAreaSetupRec(ApplicationAreaSetup) then
          exit(false);

        exit(ApplicationAreaSetup."Inventory Analysis");
    end;

    procedure IsReservationEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        if not GetApplicationAreaSetupRec(ApplicationAreaSetup) then
          exit(false);

        exit(ApplicationAreaSetup.Reservation);
    end;

    procedure IsInvoicingOnlyEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        if not GetApplicationAreaSetupRec(ApplicationAreaSetup) then
          exit(false);

        if not ApplicationAreaSetup.Invoicing then
          exit(false);

        exit(SelectedAppAreaCount(ApplicationAreaSetup) = 0);
    end;

    procedure IsManufacturingEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        if not GetApplicationAreaSetupRec(ApplicationAreaSetup) then
          exit(false);

        exit(ApplicationAreaSetup.Manufacturing);
    end;

    procedure IsPlanningEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        if not GetApplicationAreaSetupRec(ApplicationAreaSetup) then
          exit(false);

        exit(ApplicationAreaSetup.Planning);
    end;

    procedure IsRelationshipMgmtEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        if not GetApplicationAreaSetupRec(ApplicationAreaSetup) then
          exit(false);

        exit(ApplicationAreaSetup."Relationship Mgmt");
    end;

    procedure IsServiceEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        if not GetApplicationAreaSetupRec(ApplicationAreaSetup) then
          exit(false);

        exit(ApplicationAreaSetup.Service);
    end;

    procedure IsWarehouseEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        if not GetApplicationAreaSetupRec(ApplicationAreaSetup) then
          exit(false);

        exit(ApplicationAreaSetup.Warehouse);
    end;

    procedure IsOrderPromisingEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        if not GetApplicationAreaSetupRec(ApplicationAreaSetup) then
          exit(false);

        exit(ApplicationAreaSetup."Order Promising");
    end;

    procedure IsCommentsEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        if not GetApplicationAreaSetupRec(ApplicationAreaSetup) then
          exit(false);

        exit(ApplicationAreaSetup.Comments);
    end;

    procedure IsSuiteEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        if not GetApplicationAreaSetupRec(ApplicationAreaSetup) then
          exit(false);

        exit(ApplicationAreaSetup.Suite);
    end;

    procedure IsAllDisabled(): Boolean
    begin
        exit(not IsAnyEnabled);
    end;

    local procedure IsAnyEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        if not GetApplicationAreaSetupRec(ApplicationAreaSetup) then
          exit(false);
        exit(SelectedAppAreaCount(ApplicationAreaSetup) > 0);
    end;

    procedure IsPlanAssignedToCurrentUser(PlanGUID: Guid): Boolean
    var
        UserPlan: Record "User Plan";
    begin
        UserPlan.SetRange("User Security ID",UserSecurityId);
        UserPlan.SetRange("Plan ID",PlanGUID);
        exit(not UserPlan.IsEmpty);
    end;

    procedure IsPremiumEnabled(): Boolean
    var
        Plan: Record Plan;
    begin
        if IsPlanAssignedToCurrentUser(Plan.GetPremiumPlanId) then
          exit(true);

        if IsPlanAssignedToCurrentUser(Plan.GetViralSignupPlanId) then
          exit(true);
    end;

    procedure IsAdvancedSaaSEnabled(): Boolean
    var
        PermissionManager: Codeunit "Permission Manager";
    begin
        exit(PermissionManager.IsSandboxConfiguration);
    end;

    procedure CheckAppAreaOnlyBasic()
    begin
        if IsBasicOnlyEnabled then begin
          Message(OnlyBasicAppAreaMsg);
          Error('');
        end;
    end;

    procedure IsValidExperienceTierSelected(SelectedExperienceTier: Text): Boolean
    var
        ExperienceTierSetup: Record "Experience Tier Setup";
    begin
        if (SelectedExperienceTier <> ExperienceTierSetup.FieldName(Premium)) or IsPremiumEnabled then
          exit(true);

        Message(PremiumSubscriptionNeededMsg);
        exit(false);
    end;

    local procedure SelectedAppAreaCount(ApplicationAreaSetup: Record "Application Area Setup"): Integer
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        FieldIndex: Integer;
        "Count": Integer;
    begin
        RecRef.GetTable(ApplicationAreaSetup);

        for FieldIndex := GetFirstPublicAppAreaFieldIndex to RecRef.FieldCount do begin
          FieldRef := RecRef.FieldIndex(FieldIndex);
          if not IsInPrimaryKey(FieldRef) then
            if FieldRef.Value then
              Count += 1;
        end;
        exit(Count);
    end;

    local procedure IsInPrimaryKey(FieldRef: FieldRef): Boolean
    var
        RecRef: RecordRef;
        KeyRef: KeyRef;
        FieldIndex: Integer;
    begin
        RecRef := FieldRef.Record;

        KeyRef := RecRef.KeyIndex(1);
        for FieldIndex := 1 to KeyRef.FieldCount do
          if KeyRef.FieldIndex(FieldIndex).Number = FieldRef.Number then
            exit(true);

        exit(false);
    end;

    procedure GetFirstPublicAppAreaFieldIndex(): Integer
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        RecRef: RecordRef;
        FirstPublicAppAreaFieldRef: FieldRef;
        i: Integer;
    begin
        RecRef.GetTable(ApplicationAreaSetup);
        FirstPublicAppAreaFieldRef := RecRef.Field(ApplicationAreaSetup.FieldNo(Basic));
        for i := 1 to RecRef.FieldCount do
          if RecRef.FieldIndex(i).Number = FirstPublicAppAreaFieldRef.Number then
            exit(i);
    end;

    local procedure GetExperienceTierRec(var ExperienceTierSetup: Record "Experience Tier Setup"): Boolean
    begin
        exit(ExperienceTierSetup.Get(CompanyName));
    end;

    procedure GetExperienceTierBuffer(var TempExperienceTierBuffer: Record "Experience Tier Buffer" temporary)
    var
        ExperienceTierSetup: Record "Experience Tier Setup";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        FieldIndex: Integer;
    begin
        GetExperienceTierRec(ExperienceTierSetup);
        RecRef.GetTable(ExperienceTierSetup);

        for FieldIndex := 1 to RecRef.FieldCount do begin
          FieldRef := RecRef.FieldIndex(FieldIndex);
          if not IsInPrimaryKey(FieldRef) then begin
            TempExperienceTierBuffer."Field No." := FieldRef.Number;
            TempExperienceTierBuffer."Experience Tier" := FieldRef.Caption;
            TempExperienceTierBuffer.Selected := FieldRef.Value;
            TempExperienceTierBuffer.Insert(true);
          end;
        end;
    end;

    procedure LookupExperienceTier(var NewExperienceTier: Text): Boolean
    var
        TempExperienceTierBuffer: Record "Experience Tier Buffer" temporary;
        ExperienceTierSetup: Record "Experience Tier Setup";
    begin
        GetExperienceTierBuffer(TempExperienceTierBuffer);
        if NewExperienceTier <> '' then begin
          TempExperienceTierBuffer.SetRange("Experience Tier",NewExperienceTier);
          if TempExperienceTierBuffer.FindFirst then;
          TempExperienceTierBuffer.SetRange("Experience Tier");
        end;

        // Always remove Preview from ExpTier options, because Preview features have gradated to premium
        if TempExperienceTierBuffer.Get(ExperienceTierSetup.FieldNo(Preview)) then
          TempExperienceTierBuffer.Delete;

        // Always remove Advanced from ExpTier options
        if TempExperienceTierBuffer.Get(ExperienceTierSetup.FieldNo(Advanced)) then
          TempExperienceTierBuffer.Delete;

        if TempExperienceTierBuffer.Get(ExperienceTierSetup.FieldNo(Basic)) then
          TempExperienceTierBuffer.Delete;

        GetExperienceTierRec(ExperienceTierSetup);
        if not ExperienceTierSetup.Custom then
          if TempExperienceTierBuffer.Get(ExperienceTierSetup.FieldNo(Custom)) then
            TempExperienceTierBuffer.Delete;

        if not ExperienceTierSetup.Invoicing then
          if TempExperienceTierBuffer.Get(ExperienceTierSetup.FieldNo(Invoicing)) then
            TempExperienceTierBuffer.Delete;

        OnBeforeLookupExperienceTier(TempExperienceTierBuffer);
        if PAGE.RunModal(0,TempExperienceTierBuffer,TempExperienceTierBuffer."Experience Tier") = ACTION::LookupOK then begin
          NewExperienceTier := TempExperienceTierBuffer."Experience Tier";
          exit(true);
        end;
    end;

    procedure SaveExperienceTierCurrentCompany(NewExperienceTier: Text) ExperienceTierChanged: Boolean
    var
        TempExperienceTierBuffer: Record "Experience Tier Buffer" temporary;
        ExperienceTierSetup: Record "Experience Tier Setup";
        Company: Record Company;
        RecRef: RecordRef;
        FieldRef: FieldRef;
        CurrentExperienceTier: Text;
        SelectedAlreadySaved: Boolean;
    begin
        GetExperienceTierCurrentCompany(CurrentExperienceTier);
        ExperienceTierChanged := CurrentExperienceTier <> NewExperienceTier;

        GetExperienceTierBuffer(TempExperienceTierBuffer);
        TempExperienceTierBuffer.SetRange("Experience Tier",NewExperienceTier);
        if not TempExperienceTierBuffer.FindFirst then
          exit(false);

        if not GetExperienceTierRec(ExperienceTierSetup) then begin
          ExperienceTierSetup."Company Name" := CompanyName;
          ExperienceTierSetup.Insert;
        end else
          if not ExperienceTierChanged then begin
            Company.Get(CompanyName);
            if (NewExperienceTier = ExperienceTierSetup.FieldCaption(Custom)) or Company."Evaluation Company" then
              exit(false);
          end;

        RecRef.GetTable(ExperienceTierSetup);
        FieldRef := RecRef.Field(TempExperienceTierBuffer."Field No.");
        SelectedAlreadySaved := FieldRef.Value;
        if not SelectedAlreadySaved then begin
          RecRef.Init;
          FieldRef.Value := true;
          RecRef.SetTable(ExperienceTierSetup);
          ExperienceTierSetup.Modify;
        end;

        SetExperienceTierCurrentCompany(ExperienceTierSetup);
    end;

    procedure GetExperienceTierCurrentCompany(var ExperienceTier: Text): Boolean
    var
        TempExperienceTierBuffer: Record "Experience Tier Buffer" temporary;
    begin
        Clear(ExperienceTier);
        GetExperienceTierBuffer(TempExperienceTierBuffer);
        TempExperienceTierBuffer.SetRange(Selected,true);
        if TempExperienceTierBuffer.FindFirst then
          ExperienceTier := TempExperienceTierBuffer."Experience Tier";
        exit(ExperienceTier <> '');
    end;

    local procedure SetExperienceTier(CompanyName: Text;ExperienceTierSetup: Record "Experience Tier Setup")
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        TempApplicationAreaSetup: Record "Application Area Setup" temporary;
        ApplicationAreasSet: Boolean;
    begin
        if ExperienceTierSetup.Custom then
          Error(ValuesNotAllowedErr);

        if not GetApplicationAreaSetupRecFromCompany(ApplicationAreaSetup,CompanyName) then begin
          ApplicationAreaSetup."Company Name" := CopyStr(CompanyName,1,StrLen(CompanyName));
          ApplicationAreaSetup.Insert;
        end;

        case true of
          ExperienceTierSetup.Basic:
            GetBasicExperienceAppAreas(TempApplicationAreaSetup);
          ExperienceTierSetup.Essential:
            GetEssentialExperienceAppAreas(TempApplicationAreaSetup);
          ExperienceTierSetup.Premium:
            GetPremiumExperienceAppAreas(TempApplicationAreaSetup);
          ExperienceTierSetup.Invoicing:
            begin
              TempApplicationAreaSetup.Init;
              TempApplicationAreaSetup.Invoicing := true;
            end;
          else begin
            OnSetExperienceTier(ExperienceTierSetup,TempApplicationAreaSetup,ApplicationAreasSet);
            if not ApplicationAreasSet then
              exit;
          end;
        end;

        if not ValidateApplicationAreasSet(ExperienceTierSetup,TempApplicationAreaSetup) then begin
          if HideApplicationAreaError then
            exit;
          Error(GetLastErrorText);
        end;

        ApplicationAreaSetup.TransferFields(TempApplicationAreaSetup,false);
        ApplicationAreaSetup.Modify;
        SetupApplicationArea;
    end;

    procedure SetExperienceTierCurrentCompany(ExperienceTierSetup: Record "Experience Tier Setup")
    begin
        SetExperienceTier(CompanyName,ExperienceTierSetup);
    end;

    procedure SetExperienceTierOtherCompany(ExperienceTierSetup: Record "Experience Tier Setup";CompanyName: Text)
    begin
        SetExperienceTier(CompanyName,ExperienceTierSetup);
    end;

    local procedure ApplicationAreaSetupsMatch(ApplicationAreaSetup: Record "Application Area Setup";TempApplicationAreaSetup: Record "Application Area Setup" temporary;CheckBaseOnly: Boolean): Boolean
    var
        RecRef: RecordRef;
        RecRef2: RecordRef;
        FieldRef: FieldRef;
        FieldRef2: FieldRef;
        FieldIndex: Integer;
    begin
        RecRef.GetTable(ApplicationAreaSetup);
        RecRef2.GetTable(TempApplicationAreaSetup);

        for FieldIndex := 1 to RecRef.FieldCount do begin
          FieldRef := RecRef.FieldIndex(FieldIndex);
          if CheckBaseOnly and (FieldRef.Number >= 49999) then
            exit(true);
          FieldRef2 := RecRef2.FieldIndex(FieldIndex);
          if not IsInPrimaryKey(FieldRef) then
            if not (FieldRef.Value = FieldRef2.Value) then
              exit(false);
        end;
        exit(true);
    end;

    procedure IsBasicExperienceEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        TempApplicationAreaSetup: Record "Application Area Setup" temporary;
    begin
        if not GetApplicationAreaSetupRecFromCompany(ApplicationAreaSetup,CompanyName) then
          exit(false);

        GetBasicExperienceAppAreas(TempApplicationAreaSetup);

        exit(ApplicationAreaSetupsMatch(ApplicationAreaSetup,TempApplicationAreaSetup,false));
    end;

    procedure IsEssentialExperienceEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        TempApplicationAreaSetup: Record "Application Area Setup" temporary;
    begin
        if not GetApplicationAreaSetupRecFromCompany(ApplicationAreaSetup,CompanyName) then
          exit(false);

        GetEssentialExperienceAppAreas(TempApplicationAreaSetup);

        exit(ApplicationAreaSetupsMatch(ApplicationAreaSetup,TempApplicationAreaSetup,false));
    end;

    procedure IsPremiumExperienceEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        TempApplicationAreaSetup: Record "Application Area Setup" temporary;
    begin
        if not GetApplicationAreaSetupRecFromCompany(ApplicationAreaSetup,CompanyName) then
          exit(false);

        GetPremiumExperienceAppAreas(TempApplicationAreaSetup);

        exit(ApplicationAreaSetupsMatch(ApplicationAreaSetup,TempApplicationAreaSetup,false));
    end;

    procedure IsCustomExperienceEnabled(): Boolean
    var
        IsPreDefinedExperience: Boolean;
    begin
        IsPreDefinedExperience :=
          IsBasicExperienceEnabled or IsEssentialExperienceEnabled or IsPremiumExperienceEnabled or
          IsAdvancedExperienceEnabled or IsInvoicingOnlyEnabled;

        exit(not IsPreDefinedExperience);
    end;

    procedure IsAdvancedExperienceEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        TempApplicationAreaSetup: Record "Application Area Setup" temporary;
    begin
        if IsAdvancedSaaSEnabled then
          exit(true);

        if not GetApplicationAreaSetupRecFromCompany(ApplicationAreaSetup,CompanyName) then
          exit(true);

        exit(ApplicationAreaSetupsMatch(ApplicationAreaSetup,TempApplicationAreaSetup,false));
    end;

    local procedure GetBasicExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        TempApplicationAreaSetup.Basic := true;
        TempApplicationAreaSetup."Relationship Mgmt" := true;

        OnGetBasicExperienceAppAreas(TempApplicationAreaSetup);
    end;

    local procedure GetEssentialExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        GetBasicExperienceAppAreas(TempApplicationAreaSetup);
        TempApplicationAreaSetup.Suite := true;
        TempApplicationAreaSetup.Jobs := true;
        TempApplicationAreaSetup."Fixed Assets" := true;
        TempApplicationAreaSetup.Location := true;
        TempApplicationAreaSetup.BasicHR := true;
        TempApplicationAreaSetup.Assembly := true;
        TempApplicationAreaSetup."Item Charges" := true;
        TempApplicationAreaSetup.Intercompany := true;
        TempApplicationAreaSetup."Sales Return Order" := true;
        TempApplicationAreaSetup."Purch Return Order" := true;
        TempApplicationAreaSetup.Prepayments := true;
        TempApplicationAreaSetup."Cost Accounting" := true;
        TempApplicationAreaSetup."Sales Budget" := true;
        TempApplicationAreaSetup."Purchase Budget" := true;
        TempApplicationAreaSetup."Item Budget" := true;
        TempApplicationAreaSetup."Sales Analysis" := true;
        TempApplicationAreaSetup."Purchase Analysis" := true;
        TempApplicationAreaSetup."Inventory Analysis" := true;
        TempApplicationAreaSetup."Item Tracking" := true;
        TempApplicationAreaSetup.Warehouse := true;
        TempApplicationAreaSetup.XBRL := true;
        TempApplicationAreaSetup."Order Promising" := true;
        TempApplicationAreaSetup.Reservation := true;
        TempApplicationAreaSetup.Dimensions := true;
        TempApplicationAreaSetup.ADCS := true;
        TempApplicationAreaSetup.Planning := true;
        TempApplicationAreaSetup.Comments := true;

        OnGetEssentialExperienceAppAreas(TempApplicationAreaSetup);
    end;

    local procedure GetPremiumExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        GetEssentialExperienceAppAreas(TempApplicationAreaSetup);
        TempApplicationAreaSetup.Service := true;
        TempApplicationAreaSetup.Manufacturing := true;
        OnGetPremiumExperienceAppAreas(TempApplicationAreaSetup);
    end;

    [TryFunction]
    local procedure ValidateApplicationAreasSet(ExperienceTierSetup: Record "Experience Tier Setup";TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    var
        TempApplicationAreaSetup2: Record "Application Area Setup" temporary;
    begin
        if TempApplicationAreaSetup.Invoicing then begin
          TempApplicationAreaSetup2.Invoicing := true;
          if not ApplicationAreaSetupsMatch(TempApplicationAreaSetup,TempApplicationAreaSetup2,false) then
            Error(InvoicingExpTierErr);
        end else
          TempApplicationAreaSetup.TestField(Basic,true);

        OnValidateApplicationAreas(ExperienceTierSetup,TempApplicationAreaSetup);
    end;

    [IntegrationEvent(FALSE, FALSE)]
    local procedure OnGetBasicExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
    end;

    [IntegrationEvent(FALSE, FALSE)]
    local procedure OnGetEssentialExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
    end;

    [IntegrationEvent(FALSE, FALSE)]
    local procedure OnGetPremiumExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeLookupExperienceTier(var TempExperienceTierBuffer: Record "Experience Tier Buffer" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetExperienceTier(ExperienceTierSetup: Record "Experience Tier Setup";var TempApplicationAreaSetup: Record "Application Area Setup" temporary;var ApplicationAreasSet: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateApplicationAreas(ExperienceTierSetup: Record "Experience Tier Setup";TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
    end;

    procedure SetHideApplicationAreaError(NewHideApplicationAreaError: Boolean)
    begin
        HideApplicationAreaError := NewHideApplicationAreaError;
    end;
}

