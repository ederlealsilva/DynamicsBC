codeunit 46 SelectionFilterManagement
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    [Scope('Personalization')]
    procedure GetSelectionFilter(var TempRecRef: RecordRef;SelectionFieldID: Integer): Text
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        FirstRecRef: Text;
        LastRecRef: Text;
        SelectionFilter: Text;
        SavePos: Text;
        TempRecRefCount: Integer;
        More: Boolean;
    begin
        if TempRecRef.IsTemporary then begin
          RecRef := TempRecRef.Duplicate;
          RecRef.Reset;
        end else
          RecRef.Open(TempRecRef.Number);

        TempRecRefCount := TempRecRef.Count;
        if TempRecRefCount > 0 then begin
          TempRecRef.Ascending(true);
          TempRecRef.Find('-');
          while TempRecRefCount > 0 do begin
            TempRecRefCount := TempRecRefCount - 1;
            RecRef.SetPosition(TempRecRef.GetPosition);
            RecRef.Find;
            FieldRef := RecRef.Field(SelectionFieldID);
            FirstRecRef := Format(FieldRef.Value);
            LastRecRef := FirstRecRef;
            More := TempRecRefCount > 0;
            while More do
              if RecRef.Next = 0 then
                More := false
              else begin
                SavePos := TempRecRef.GetPosition;
                TempRecRef.SetPosition(RecRef.GetPosition);
                if not TempRecRef.Find then begin
                  More := false;
                  TempRecRef.SetPosition(SavePos);
                end else begin
                  FieldRef := RecRef.Field(SelectionFieldID);
                  LastRecRef := Format(FieldRef.Value);
                  TempRecRefCount := TempRecRefCount - 1;
                  if TempRecRefCount = 0 then
                    More := false;
                end;
              end;
            if SelectionFilter <> '' then
              SelectionFilter := SelectionFilter + '|';
            if FirstRecRef = LastRecRef then
              SelectionFilter := SelectionFilter + AddQuotes(FirstRecRef)
            else
              SelectionFilter := SelectionFilter + AddQuotes(FirstRecRef) + '..' + AddQuotes(LastRecRef);
            if TempRecRefCount > 0 then
              TempRecRef.Next;
          end;
          exit(SelectionFilter);
        end;
    end;

    [Scope('Personalization')]
    procedure AddQuotes(inString: Text[1024]): Text
    begin
        if DelChr(inString,'=',' &|()*') = inString then
          exit(inString);
        exit('''' + inString + '''');
    end;

    [Scope('Personalization')]
    procedure GetSelectionFilterForItem(var Item: Record Item): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Item);
        exit(GetSelectionFilter(RecRef,Item.FieldNo("No.")));
    end;

    [Scope('Personalization')]
    procedure GetSelectionFilterForDimensionValue(var DimVal: Record "Dimension Value"): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(DimVal);
        exit(GetSelectionFilter(RecRef,DimVal.FieldNo(Code)));
    end;

    [Scope('Personalization')]
    procedure GetSelectionFilterForCurrency(var Currency: Record Currency): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Currency);
        exit(GetSelectionFilter(RecRef,Currency.FieldNo(Code)));
    end;

    [Scope('Personalization')]
    procedure GetSelectionFilterForCustomerPriceGroup(var CustomerPriceGroup: Record "Customer Price Group"): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(CustomerPriceGroup);
        exit(GetSelectionFilter(RecRef,CustomerPriceGroup.FieldNo(Code)));
    end;

    [Scope('Personalization')]
    procedure GetSelectionFilterForLocation(var Location: Record Location): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Location);
        exit(GetSelectionFilter(RecRef,Location.FieldNo(Code)));
    end;

    [Scope('Personalization')]
    procedure GetSelectionFilterForGLAccount(var GLAccount: Record "G/L Account"): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(GLAccount);
        exit(GetSelectionFilter(RecRef,GLAccount.FieldNo("No.")));
    end;

    [Scope('Personalization')]
    procedure GetSelectionFilterForCustomer(var Customer: Record Customer): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Customer);
        exit(GetSelectionFilter(RecRef,Customer.FieldNo("No.")));
    end;

    [Scope('Personalization')]
    procedure GetSelectionFilterForContact(var Contact: Record Contact): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Contact);
        exit(GetSelectionFilter(RecRef,Contact.FieldNo("No.")));
    end;

    [Scope('Personalization')]
    procedure GetSelectionFilterForVendor(var Vendor: Record Vendor): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Vendor);
        exit(GetSelectionFilter(RecRef,Vendor.FieldNo("No.")));
    end;

    [Scope('Personalization')]
    procedure GetSelectionFilterForResource(var Resource: Record Resource): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Resource);
        exit(GetSelectionFilter(RecRef,Resource.FieldNo("No.")));
    end;

    [Scope('Personalization')]
    procedure GetSelectionFilterForInventoryPostingGroup(var InventoryPostingGroup: Record "Inventory Posting Group"): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(InventoryPostingGroup);
        exit(GetSelectionFilter(RecRef,InventoryPostingGroup.FieldNo(Code)));
    end;

    [Scope('Personalization')]
    procedure GetSelectionFilterForGLBudgetName(var GLBudgetName: Record "G/L Budget Name"): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(GLBudgetName);
        exit(GetSelectionFilter(RecRef,GLBudgetName.FieldNo(Name)));
    end;

    [Scope('Personalization')]
    procedure GetSelectionFilterForBusinessUnit(var BusinessUnit: Record "Business Unit"): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(BusinessUnit);
        exit(GetSelectionFilter(RecRef,BusinessUnit.FieldNo(Code)));
    end;

    [Scope('Personalization')]
    procedure GetSelectionFilterForICPartner(var ICPartner: Record "IC Partner"): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(ICPartner);
        exit(GetSelectionFilter(RecRef,ICPartner.FieldNo(Code)));
    end;

    [Scope('Personalization')]
    procedure GetSelectionFilterForCashFlow(var CashFlowForecast: Record "Cash Flow Forecast"): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(CashFlowForecast);
        exit(GetSelectionFilter(RecRef,CashFlowForecast.FieldNo("No.")));
    end;

    [Scope('Personalization')]
    procedure GetSelectionFilterForCashFlowAccount(var CashFlowAccount: Record "Cash Flow Account"): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(CashFlowAccount);
        exit(GetSelectionFilter(RecRef,CashFlowAccount.FieldNo("No.")));
    end;

    [Scope('Personalization')]
    procedure GetSelectionFilterForCostBudgetName(var CostBudgetName: Record "Cost Budget Name"): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(CostBudgetName);
        exit(GetSelectionFilter(RecRef,CostBudgetName.FieldNo(Name)));
    end;

    [Scope('Personalization')]
    procedure GetSelectionFilterForCostCenter(var CostCenter: Record "Cost Center"): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(CostCenter);
        exit(GetSelectionFilter(RecRef,CostCenter.FieldNo(Code)));
    end;

    [Scope('Personalization')]
    procedure GetSelectionFilterForCostObject(var CostObject: Record "Cost Object"): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(CostObject);
        exit(GetSelectionFilter(RecRef,CostObject.FieldNo(Code)));
    end;

    [Scope('Personalization')]
    procedure GetSelectionFilterForCostType(var CostType: Record "Cost Type"): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(CostType);
        exit(GetSelectionFilter(RecRef,CostType.FieldNo("No.")));
    end;

    [Scope('Personalization')]
    procedure GetSelectionFilterForCampaign(var Campaign: Record Campaign): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Campaign);
        exit(GetSelectionFilter(RecRef,Campaign.FieldNo("No.")));
    end;

    [Scope('Personalization')]
    procedure GetSelectionFilterForLotNoInformation(var LotNoInformation: Record "Lot No. Information"): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(LotNoInformation);
        exit(GetSelectionFilter(RecRef,LotNoInformation.FieldNo("Lot No.")));
    end;

    [Scope('Personalization')]
    procedure GetSelectionFilterForSerialNoInformation(var SerialNoInformation: Record "Serial No. Information"): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(SerialNoInformation);
        exit(GetSelectionFilter(RecRef,SerialNoInformation.FieldNo("Serial No.")));
    end;

    [Scope('Personalization')]
    procedure GetSelectionFilterForCustomerDiscountGroup(var CustomerDiscountGroup: Record "Customer Discount Group"): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(CustomerDiscountGroup);
        exit(GetSelectionFilter(RecRef,CustomerDiscountGroup.FieldNo(Code)));
    end;

    [Scope('Personalization')]
    procedure GetSelectionFilterForItemDiscountGroup(var ItemDiscountGroup: Record "Item Discount Group"): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(ItemDiscountGroup);
        exit(GetSelectionFilter(RecRef,ItemDiscountGroup.FieldNo(Code)));
    end;

    [Scope('Personalization')]
    procedure GetSelectionFilterForItemCategory(var ItemCategory: Record "Item Category"): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(ItemCategory);
        exit(GetSelectionFilter(RecRef,ItemCategory.FieldNo(Code)));
    end;

    [Scope('Personalization')]
    procedure GetSelectionFilterForIssueReminder(var ReminderHeader: Record "Reminder Header"): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(ReminderHeader);
        exit(GetSelectionFilter(RecRef,ReminderHeader.FieldNo("No.")));
    end;

    [Scope('Personalization')]
    procedure GetSelectionFilterForWorkflowStepInstance(var WorkflowStepInstance: Record "Workflow Step Instance"): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(WorkflowStepInstance);
        exit(GetSelectionFilter(RecRef,WorkflowStepInstance.FieldNo("Original Workflow Step ID")));
    end;

    [Scope('Personalization')]
    procedure GetSelectionFilterForWorkflowBuffer(var TempWorkflowBuffer: Record "Workflow Buffer" temporary): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(TempWorkflowBuffer);
        exit(GetSelectionFilter(RecRef,TempWorkflowBuffer.FieldNo("Workflow Code")));
    end;
}

