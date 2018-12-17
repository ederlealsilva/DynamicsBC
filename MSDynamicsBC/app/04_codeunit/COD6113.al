codeunit 6113 "Item Data Migration Facade"
{
    // version NAVW113.00

    TableNo = "Data Migration Parameters";

    trigger OnRun()
    var
        DataMigrationStatusFacade: Codeunit "Data Migration Status Facade";
        ChartOfAccountsMigrated: Boolean;
    begin
        FindSet;
        ChartOfAccountsMigrated := DataMigrationStatusFacade.HasMigratedChartOfAccounts(Rec);
        repeat
          OnMigrateItem("Staging Table RecId To Process");
          OnMigrateItemTrackingCode("Staging Table RecId To Process");
          OnMigrateCostingMethod("Staging Table RecId To Process"); // needs to be set after item tracking code because of onvalidate trigger check
          OnMigrateItemUnitOfMeasure("Staging Table RecId To Process");
          OnMigrateItemDiscountGroup("Staging Table RecId To Process");
          OnMigrateItemSalesLineDiscount("Staging Table RecId To Process");
          OnMigrateItemPrice("Staging Table RecId To Process");
          OnMigrateItemTariffNo("Staging Table RecId To Process");
          OnMigrateItemDimensions("Staging Table RecId To Process");

          // migrate transactions for this item as long as it is an inventory item
          if GlobalItem.Type = GlobalItem.Type::Inventory then begin
            OnMigrateItemPostingGroups("Staging Table RecId To Process",ChartOfAccountsMigrated);
            OnMigrateInventoryTransactions("Staging Table RecId To Process",ChartOfAccountsMigrated);
            ItemJournalLineIsSet := false;
          end;
          ItemIsSet := false;
        until Next = 0;
    end;

    var
        GlobalItem: Record Item;
        GlobalItemJournalLine: Record "Item Journal Line";
        DataMigrationFacadeHelper: Codeunit "Data Migration Facade Helper";
        ItemIsSet: Boolean;
        InternalItemNotSetErr: Label 'Internal item is not set. Create it first.';
        ItemJournalLineIsSet: Boolean;
        InternalItemJnlLIneNotSetErr: Label 'Internal item journal line is not set. Create it first.';

    [Scope('Personalization')]
    procedure CreateItemIfNeeded(ItemNoToSet: Code[20];ItemDescriptionToSet: Text[50];ItemDescription2ToSet: Text[50];ItemTypeToSet: Option Inventory,Service): Boolean
    var
        Item: Record Item;
    begin
        if Item.Get(ItemNoToSet) then begin
          GlobalItem := Item;
          ItemIsSet := true;
          exit(false);
        end;

        Item.Init;

        Item.Validate("No.",ItemNoToSet);
        Item.Validate(Description,ItemDescriptionToSet);
        Item.Validate("Description 2",ItemDescription2ToSet);
        Item.Validate(Type,ItemTypeToSet);
        Item.Insert(true);

        GlobalItem := Item;
        ItemIsSet := true;
        exit(true);
    end;

    [Scope('Personalization')]
    procedure CreateLocationIfNeeded(LocationCode: Code[10];LocationName: Text[50]): Boolean
    var
        Location: Record Location;
    begin
        if Location.Get(LocationCode) then
          exit(false);

        Location.Init;
        Location.Validate(Code,LocationCode);
        Location.Validate(Name,LocationName);
        Location.Insert(true);

        exit(true);
    end;

    [Scope('Personalization')]
    procedure DoesItemExist(ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
    begin
        exit(Item.Get(ItemNo));
    end;

    [Scope('Personalization')]
    procedure SetGlobalItem(ItemNo: Code[20]): Boolean
    begin
        ItemIsSet := GlobalItem.Get(ItemNo);
        exit(ItemIsSet);
    end;

    [Scope('Personalization')]
    procedure ModifyItem(RunTrigger: Boolean)
    begin
        if not ItemIsSet then
          Error(InternalItemNotSetErr);

        GlobalItem.Modify(RunTrigger);
    end;

    [Scope('Personalization')]
    procedure CreateSalesLineDiscountIfNeeded(SalesTypeToSet: Option Customer,"Customer Disc. Group","All Customers",Campaign;SalesCodeToSet: Code[10];TypeToSet: Option Item,"Item Disc. Group";CodeToSet: Code[10];LineDiscountPercentToSet: Decimal): Boolean
    var
        SalesLineDiscount: Record "Sales Line Discount";
    begin
        SalesLineDiscount.SetRange("Sales Type",SalesTypeToSet);
        SalesLineDiscount.SetRange("Sales Code",SalesCodeToSet);
        SalesLineDiscount.SetRange(Type,TypeToSet);
        SalesLineDiscount.SetRange(Code,CodeToSet);
        SalesLineDiscount.SetRange("Line Discount %",LineDiscountPercentToSet);

        if SalesLineDiscount.FindFirst then
          exit(false);

        SalesLineDiscount.Init;
        SalesLineDiscount.Validate("Sales Type",SalesTypeToSet);
        SalesLineDiscount.Validate("Sales Code",SalesCodeToSet);
        SalesLineDiscount.Validate(Type,TypeToSet);
        SalesLineDiscount.Validate(Code,CodeToSet);
        SalesLineDiscount.Validate("Line Discount %",LineDiscountPercentToSet);
        SalesLineDiscount.Insert(true);
        exit(true);
    end;

    [Scope('Personalization')]
    procedure CreateCustDiscGroupIfNeeded(CustDiscGroupCodeToSet: Code[20];DescriptionToSet: Text[50]): Boolean
    var
        CustomerDiscountGroup: Record "Customer Discount Group";
    begin
        if CustomerDiscountGroup.Get(CustDiscGroupCodeToSet) then
          exit(false);

        CustomerDiscountGroup.Init;
        CustomerDiscountGroup.Validate(Code,CustDiscGroupCodeToSet);
        CustomerDiscountGroup.Validate(Description,DescriptionToSet);
        CustomerDiscountGroup.Insert(true);
        exit(true);
    end;

    [Scope('Personalization')]
    procedure CreateItemDiscGroupIfNeeded(DiscGroupCodeToSet: Code[20];DescriptionToSet: Text[50]): Boolean
    var
        ItemDiscountGroup: Record "Item Discount Group";
    begin
        if ItemDiscountGroup.Get(DiscGroupCodeToSet) then
          exit(false);

        ItemDiscountGroup.Init;
        ItemDiscountGroup.Validate(Code,DiscGroupCodeToSet);
        ItemDiscountGroup.Validate(Description,DescriptionToSet);
        ItemDiscountGroup.Insert(true);
        exit(true);
    end;

    [Scope('Personalization')]
    procedure CreateSalesPriceIfNeeded(SalesTypeToSet: Option Customer,"Customer Price Group","All Customers",Campaign;SalesCodeToSet: Code[20];ItemNoToSet: Code[20];UnitPriceToSet: Decimal;CurrencyCodeToSet: Code[10];StartingDateToSet: Date;UnitOfMeasureToSet: Code[10];MinimumQuantityToSet: Decimal;VariantCodeToSet: Code[10]): Boolean
    var
        SalesPrice: Record "Sales Price";
    begin
        if SalesPrice.Get(ItemNoToSet,SalesTypeToSet,SalesCodeToSet,StartingDateToSet,CurrencyCodeToSet,
             VariantCodeToSet,UnitOfMeasureToSet,MinimumQuantityToSet)
        then
          exit(false);
        SalesPrice.Init;

        SalesPrice.Validate("Sales Type",SalesTypeToSet);
        SalesPrice.Validate("Sales Code",SalesCodeToSet);
        SalesPrice.Validate("Item No.",ItemNoToSet);
        SalesPrice.Validate("Starting Date",StartingDateToSet);
        SalesPrice.Validate("Currency Code",DataMigrationFacadeHelper.FixIfLcyCode(CurrencyCodeToSet));
        SalesPrice.Validate("Variant Code",VariantCodeToSet);
        SalesPrice.Validate("Unit of Measure Code",UnitOfMeasureToSet);
        SalesPrice.Validate("Minimum Quantity",MinimumQuantityToSet);
        SalesPrice.Validate("Unit Price",UnitPriceToSet);

        SalesPrice.Insert(true);
        exit(true);
    end;

    [Scope('Personalization')]
    procedure CreateTariffNumberIfNeeded(NoToSet: Code[20];DescriptionToSet: Text[50];SupplementaryUnitToSet: Boolean): Boolean
    var
        TariffNumber: Record "Tariff Number";
    begin
        if TariffNumber.Get(NoToSet) then
          exit(false);

        TariffNumber.Init;
        TariffNumber.Validate("No.",NoToSet);
        TariffNumber.Validate(Description,DescriptionToSet);
        TariffNumber.Validate("Supplementary Units",SupplementaryUnitToSet);
        TariffNumber.Insert(true);
        exit(true);
    end;

    [Scope('Personalization')]
    procedure CreateUnitOfMeasureIfNeeded(CodeToSet: Code[10];DescriptionToSet: Text[10]): Boolean
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        if UnitOfMeasure.Get(CodeToSet) then
          exit(false);

        UnitOfMeasure.Init;
        UnitOfMeasure.Validate(Code,CodeToSet);
        UnitOfMeasure.Validate(Description,DescriptionToSet);
        UnitOfMeasure.Insert(true);
        exit(true);
    end;

    [Scope('Personalization')]
    procedure CreateItemTrackingCodeIfNeeded(CodeToSet: Code[10];DescriptionToSet: Text[50];LotSpecificTrackingToSet: Boolean;SNSpecificTrackingToSet: Boolean): Boolean
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        if ItemTrackingCode.Get(CodeToSet) then
          exit(false);

        ItemTrackingCode.Init;
        ItemTrackingCode.Validate(Code,CodeToSet);
        ItemTrackingCode.Validate(Description,DescriptionToSet);
        ItemTrackingCode.Validate("Lot Specific Tracking",LotSpecificTrackingToSet);
        ItemTrackingCode.Validate("SN Specific Tracking",SNSpecificTrackingToSet);
        ItemTrackingCode.Insert(true);
        exit(true);
    end;

    [Scope('Personalization')]
    procedure CreateInventoryPostingSetupIfNeeded(InventoryPostingGroupCode: Code[20];InventoryPostingGroupDescription: Text[50];LocationCode: Code[10]) Created: Boolean
    var
        InventoryPostingGroup: Record "Inventory Posting Group";
        InventoryPostingSetup: Record "Inventory Posting Setup";
    begin
        if not InventoryPostingGroup.Get(InventoryPostingGroupCode) then begin
          InventoryPostingGroup.Init;
          InventoryPostingGroup.Validate(Code,InventoryPostingGroupCode);
          InventoryPostingGroup.Validate(Description,InventoryPostingGroupDescription);
          InventoryPostingGroup.Insert(true);
          Created := true;
        end;

        if not InventoryPostingSetup.Get(LocationCode,InventoryPostingGroupCode) then begin
          InventoryPostingSetup.Init;
          InventoryPostingSetup.Validate("Location Code",LocationCode);
          InventoryPostingSetup.Validate("Invt. Posting Group Code",InventoryPostingGroup.Code);
          InventoryPostingSetup.Insert(true);
          Created := true;
        end;
    end;

    [Scope('Personalization')]
    procedure CreateGeneralProductPostingSetupIfNeeded(GeneralProdPostingGroupCode: Code[20];GeneralProdPostingGroupDescription: Text[50];GeneralBusPostingGroupCode: Code[20]) Created: Boolean
    var
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        if not GenProductPostingGroup.Get(GeneralProdPostingGroupCode) then begin
          GenProductPostingGroup.Init;
          GenProductPostingGroup.Validate(Code,GeneralProdPostingGroupCode);
          GenProductPostingGroup.Validate(Description,GeneralProdPostingGroupDescription);
          GenProductPostingGroup.Insert(true);
          Created := true;
        end;

        if not GeneralPostingSetup.Get(GeneralBusPostingGroupCode,GeneralProdPostingGroupCode) then begin
          GeneralPostingSetup.Init;
          GeneralPostingSetup.Validate("Gen. Bus. Posting Group",GeneralBusPostingGroupCode);
          GeneralPostingSetup.Validate("Gen. Prod. Posting Group",GenProductPostingGroup.Code);
          GeneralPostingSetup.Insert(true);
          Created := true;
        end;
    end;

    [Scope('Personalization')]
    procedure CreateItemJournalBatchIfNeeded(ItemJournalBatchCode: Code[10];NoSeriesCode: Code[20];PostingNoSeriesCode: Code[20])
    var
        ItemJournalBatch: Record "Item Journal Batch";
        TemplateName: Code[10];
    begin
        TemplateName := CreateItemJournalTemplateIfNeeded(ItemJournalBatchCode);
        ItemJournalBatch.SetRange("Journal Template Name",TemplateName);
        ItemJournalBatch.SetRange(Name,ItemJournalBatchCode);
        ItemJournalBatch.SetRange("No. Series",NoSeriesCode);
        ItemJournalBatch.SetRange("Posting No. Series",PostingNoSeriesCode);
        if not ItemJournalBatch.FindFirst then begin
          ItemJournalBatch.Init;
          ItemJournalBatch.Validate("Journal Template Name",TemplateName);
          ItemJournalBatch.SetupNewBatch;
          ItemJournalBatch.Validate(Name,ItemJournalBatchCode);
          ItemJournalBatch.Validate(Description,ItemJournalBatchCode);
          ItemJournalBatch."No. Series" := NoSeriesCode;
          ItemJournalBatch."Posting No. Series" := PostingNoSeriesCode;
          ItemJournalBatch.Insert(true);
        end;
    end;

    local procedure CreateItemJournalTemplateIfNeeded(ItemJournalBatchCode: Code[10]): Code[10]
    var
        ItemJournalTemplate: Record "Item Journal Template";
    begin
        ItemJournalTemplate.SetRange(Type,ItemJournalTemplate.Type::Item);
        ItemJournalTemplate.SetRange(Recurring,false);
        if not ItemJournalTemplate.FindFirst then begin
          ItemJournalTemplate.Init;
          ItemJournalTemplate.Validate(Name,ItemJournalBatchCode);
          ItemJournalTemplate.Validate(Type,ItemJournalTemplate.Type::Item);
          ItemJournalTemplate.Validate(Recurring,false);
          ItemJournalTemplate.Insert(true);
        end;
        exit(ItemJournalTemplate.Name);
    end;

    [Scope('Personalization')]
    procedure CreateItemJournalLine(ItemJournalBatchCode: Code[10];DocumentNo: Code[20];Description: Text[50];PostingDate: Date;Qty: Decimal;Amount: Decimal;LocationCode: Code[10];GenProdPostingGroupGode: Code[20])
    var
        ItemJournalLineCurrent: Record "Item Journal Line";
        ItemJournalLine: Record "Item Journal Line";
        ItemJournalBatch: Record "Item Journal Batch";
        LineNum: Integer;
    begin
        ItemJournalBatch.Get(CreateItemJournalTemplateIfNeeded(ItemJournalBatchCode),ItemJournalBatchCode);

        ItemJournalLineCurrent.SetRange("Journal Template Name",ItemJournalBatch."Journal Template Name");
        ItemJournalLineCurrent.SetRange("Journal Batch Name",ItemJournalBatch.Name);
        if ItemJournalLineCurrent.FindLast then
          LineNum := ItemJournalLineCurrent."Line No." + 10000
        else
          LineNum := 10000;

        ItemJournalLine.Init;

        ItemJournalLine.Validate("Journal Template Name",ItemJournalBatch."Journal Template Name");
        ItemJournalLine.Validate("Journal Batch Name",ItemJournalBatch.Name);
        ItemJournalLine.Validate("Line No.",LineNum);
        ItemJournalLine.Validate("Entry Type",ItemJournalLine."Entry Type"::"Positive Adjmt.");
        ItemJournalLine.Validate("Document No.",DocumentNo);
        ItemJournalLine.Validate("Item No.",GlobalItem."No.");
        ItemJournalLine.Validate("Location Code",LocationCode);
        ItemJournalLine.Validate(Description,Description);
        ItemJournalLine.Validate("Document Date",PostingDate);
        ItemJournalLine.Validate("Posting Date",PostingDate);
        ItemJournalLine.Validate(Quantity,Qty);
        ItemJournalLine.Validate(Amount,Amount);
        ItemJournalLine.Validate("Gen. Bus. Posting Group",'');
        ItemJournalLine.Validate("Gen. Prod. Posting Group",GenProdPostingGroupGode);
        ItemJournalLine.Insert(true);

        GlobalItemJournalLine := ItemJournalLine;
        ItemJournalLineIsSet := true;
    end;

    [Scope('Personalization')]
    procedure SetItemJournalLineItemTracking(SerialNumber: Code[20];LotNumber: Code[20])
    begin
        if not ItemJournalLineIsSet then
          Error(InternalItemJnlLIneNotSetErr);

        if (SerialNumber <> '') or (LotNumber <> '') then
          CreateItemTracking(GlobalItemJournalLine,SerialNumber,LotNumber);
    end;

    local procedure CreateItemTracking(ItemJournalLine: Record "Item Journal Line";SerialNumber: Code[20];LotNumber: Code[20])
    var
        ReservationEntry: Record "Reservation Entry";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
    begin
        CreateReservEntry.CreateReservEntryFor(
          DATABASE::"Item Journal Line",
          ItemJournalLine."Entry Type",
          ItemJournalLine."Journal Template Name",
          ItemJournalLine."Journal Batch Name",
          0,
          ItemJournalLine."Line No.",
          ItemJournalLine."Qty. per Unit of Measure",
          Abs(ItemJournalLine.Quantity),
          Abs(ItemJournalLine."Quantity (Base)"),
          SerialNumber,LotNumber);
        CreateReservEntry.CreateEntry(
          ItemJournalLine."Item No.",
          ItemJournalLine."Variant Code",
          ItemJournalLine."Location Code",
          '',
          0D,
          0D,
          0,
          ReservationEntry."Reservation Status"::Prospect);
    end;

    [Scope('Personalization')]
    procedure SetItemJournalLineDimension(DimensionCode: Code[20];DimensionDescription: Text[50];DimensionValueCode: Code[20];DimensionValueName: Text[50])
    var
        DataMigrationFacadeHelper: Codeunit "Data Migration Facade Helper";
    begin
        if not ItemJournalLineIsSet then
          Error(InternalItemJnlLIneNotSetErr);

        GlobalItemJournalLine.Validate("Dimension Set ID",
          DataMigrationFacadeHelper.CreateDimensionSetId(GlobalItemJournalLine."Dimension Set ID",
            DimensionCode,DimensionDescription,
            DimensionValueCode,DimensionValueName));
        GlobalItemJournalLine.Modify(true);
    end;

    [Scope('Personalization')]
    procedure CreateDefaultDimensionAndRequirementsIfNeeded(DimensionCode: Text[20];DimensionDescription: Text[50];DimensionValueCode: Code[20];DimensionValueName: Text[30])
    var
        Dimension: Record Dimension;
        DimensionValue: Record "Dimension Value";
    begin
        if not ItemIsSet then
          Error(InternalItemNotSetErr);

        DataMigrationFacadeHelper.GetOrCreateDimension(DimensionCode,DimensionDescription,Dimension);
        DataMigrationFacadeHelper.GetOrCreateDimensionValue(Dimension.Code,DimensionValueCode,DimensionValueName,DimensionValue);
        DataMigrationFacadeHelper.CreateOnlyDefaultDimensionIfNeeded(Dimension.Code,DimensionValue.Code,DATABASE::Item,GlobalItem."No.");
    end;

    [Scope('Personalization')]
    procedure CreateBOMComponent(ComponentItemNo: Code[20];Quantity: Decimal;Position: Code[10];BOMType: Option)
    var
        BOMComponent: Record "BOM Component";
        LineNo: Integer;
    begin
        if not ItemIsSet then
          Error(InternalItemNotSetErr);

        BOMComponent.SetRange("Parent Item No.",GlobalItem."No.");
        if BOMComponent.FindLast then
          LineNo := BOMComponent."Line No." + 1000
        else
          LineNo := 1000;

        BOMComponent.Init;
        BOMComponent.Validate("Parent Item No.",GlobalItem."No.");
        BOMComponent.Validate("Line No.",LineNo);
        BOMComponent.Validate(Type,BOMType);
        BOMComponent.Validate("No.",ComponentItemNo);
        BOMComponent.Validate("Quantity per",Quantity);
        BOMComponent.Validate(Position,Position);
        BOMComponent.Insert(true);
    end;

    [Scope('Personalization')]
    procedure SetItemTrackingCode(TrackingCodeToSet: Code[10])
    begin
        if not ItemIsSet then
          Error(InternalItemNotSetErr);

        GlobalItem.Validate("Item Tracking Code",TrackingCodeToSet);
    end;

    [Scope('Personalization')]
    procedure SetBaseUnitOfMeasure(BaseUnitOfMeasureToSet: Code[10])
    begin
        if not ItemIsSet then
          Error(InternalItemNotSetErr);

        GlobalItem.Validate("Base Unit of Measure",BaseUnitOfMeasureToSet);
    end;

    [Scope('Personalization')]
    procedure SetPurchUnitOfMeasure(PurchUnitOfMeasureToSet: Code[10])
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        if not ItemIsSet then
          Error(InternalItemNotSetErr);

        if not ItemUnitOfMeasure.Get(GlobalItem."No.",PurchUnitOfMeasureToSet) then begin
          ItemUnitOfMeasure.Init;
          ItemUnitOfMeasure.Validate("Item No.",GlobalItem."No.");
          ItemUnitOfMeasure.Validate(Code,PurchUnitOfMeasureToSet);
          ItemUnitOfMeasure.Validate("Qty. per Unit of Measure",1);
          ItemUnitOfMeasure.Insert;
        end;

        GlobalItem.Validate("Purch. Unit of Measure",PurchUnitOfMeasureToSet);
    end;

    [Scope('Personalization')]
    procedure SetItemDiscGroup(ItemDiscGroupToSet: Code[20])
    begin
        if not ItemIsSet then
          Error(InternalItemNotSetErr);

        GlobalItem.Validate("Item Disc. Group",ItemDiscGroupToSet);
    end;

    [Scope('Personalization')]
    procedure SetTariffNo(TariffNoToSet: Code[20])
    begin
        if not ItemIsSet then
          Error(InternalItemNotSetErr);

        GlobalItem.Validate("Tariff No.",TariffNoToSet);
    end;

    [Scope('Personalization')]
    procedure SetCostingMethod(CostingMethodToSet: Option FIFO,LIFO,Specific,"Average",Standard)
    begin
        if not ItemIsSet then
          Error(InternalItemNotSetErr);

        GlobalItem.Validate("Costing Method",CostingMethodToSet);
    end;

    [Scope('Personalization')]
    procedure SetUnitCost(UnitCostToSet: Decimal)
    begin
        if not ItemIsSet then
          Error(InternalItemNotSetErr);

        GlobalItem.Validate("Unit Cost",UnitCostToSet);
    end;

    [Scope('Personalization')]
    procedure SetStandardCost(StandardCostToSet: Decimal)
    begin
        if not ItemIsSet then
          Error(InternalItemNotSetErr);

        GlobalItem.Validate("Standard Cost",StandardCostToSet);
    end;

    [Scope('Personalization')]
    procedure SetVendorItemNo(VendorItemNoToSet: Text[20])
    begin
        if not ItemIsSet then
          Error(InternalItemNotSetErr);

        GlobalItem.Validate("Vendor Item No.",VendorItemNoToSet);
    end;

    [Scope('Personalization')]
    procedure SetNetWeight(NetWeightToSet: Decimal)
    begin
        if not ItemIsSet then
          Error(InternalItemNotSetErr);

        GlobalItem.Validate("Net Weight",NetWeightToSet);
    end;

    [Scope('Personalization')]
    procedure SetUnitVolume(UnitVolumeToSet: Decimal)
    begin
        if not ItemIsSet then
          Error(InternalItemNotSetErr);

        GlobalItem.Validate("Unit Volume",UnitVolumeToSet);
    end;

    [Scope('Personalization')]
    procedure SetBlocked(BlockedToSet: Boolean)
    begin
        if not ItemIsSet then
          Error(InternalItemNotSetErr);

        GlobalItem.Validate(Blocked,BlockedToSet);
    end;

    [Scope('Personalization')]
    procedure SetStockoutWarning(IsStockoutWarning: Boolean)
    begin
        if not ItemIsSet then
          Error(InternalItemNotSetErr);

        if IsStockoutWarning then
          GlobalItem.Validate("Stockout Warning",GlobalItem."Stockout Warning"::Yes)
        else
          GlobalItem.Validate("Stockout Warning",GlobalItem."Stockout Warning"::No);
    end;

    [Scope('Personalization')]
    procedure SetPreventNegativeInventory(IsPreventNegativeInventory: Boolean)
    begin
        if not ItemIsSet then
          Error(InternalItemNotSetErr);

        if IsPreventNegativeInventory then
          GlobalItem.Validate("Prevent Negative Inventory",GlobalItem."Prevent Negative Inventory"::Yes)
        else
          GlobalItem.Validate("Prevent Negative Inventory",GlobalItem."Prevent Negative Inventory"::No);
    end;

    [Scope('Personalization')]
    procedure SetReorderQuantity(ReorderQuantityToSet: Decimal)
    begin
        if not ItemIsSet then
          Error(InternalItemNotSetErr);

        GlobalItem.Validate("Reorder Quantity",ReorderQuantityToSet);
    end;

    [Scope('Personalization')]
    procedure SetAlternativeItemNo(AlternativeItemNoToSet: Code[20])
    begin
        if not ItemIsSet then
          Error(InternalItemNotSetErr);

        GlobalItem.Validate("Alternative Item No.",AlternativeItemNoToSet);
    end;

    [Scope('Personalization')]
    procedure SetVendorNo(VendorNoToSet: Code[20]): Boolean
    var
        Vendor: Record Vendor;
    begin
        if not ItemIsSet then
          Error(InternalItemNotSetErr);

        if not Vendor.Get(VendorNoToSet) then
          exit;

        GlobalItem.Validate("Vendor No.",VendorNoToSet);

        exit(true);
    end;

    [Scope('Personalization')]
    procedure SetUnitPrice(UnitPriceToSet: Decimal)
    begin
        if not ItemIsSet then
          Error(InternalItemNotSetErr);

        GlobalItem.Validate("Unit Price",UnitPriceToSet);
    end;

    [Scope('Personalization')]
    procedure SetUnitListPrice(UnitListPriceToSet: Decimal)
    begin
        if not ItemIsSet then
          Error(InternalItemNotSetErr);

        GlobalItem.Validate("Unit List Price",UnitListPriceToSet);
    end;

    [Scope('Personalization')]
    procedure SetLastDateModified(LastDateModifiedToSet: Date)
    begin
        if not ItemIsSet then
          Error(InternalItemNotSetErr);

        GlobalItem.Validate("Last Date Modified",LastDateModifiedToSet);
    end;

    [Scope('Personalization')]
    procedure SetLastModifiedDateTime(LastModifiedDateTimeToSet: DateTime)
    begin
        if not ItemIsSet then
          Error(InternalItemNotSetErr);

        GlobalItem.Validate("Last DateTime Modified",LastModifiedDateTimeToSet);
    end;

    [Scope('Personalization')]
    procedure CreateCustomerPriceGroupIfNeeded(CodeToSet: Code[10];DescriptionToSet: Text[50];PriceIncludesVatToSet: Boolean): Code[10]
    begin
        exit(DataMigrationFacadeHelper.CreateCustomerPriceGroupIfNeeded(CodeToSet,DescriptionToSet,PriceIncludesVatToSet));
    end;

    [Scope('Personalization')]
    procedure SetInventoryPostingSetupInventoryAccount(InventoryPostingGroupCode: Code[20];LocationCode: Code[10];InventoryAccountCode: Code[20])
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
    begin
        InventoryPostingSetup.Get(LocationCode,InventoryPostingGroupCode);
        InventoryPostingSetup.Validate("Inventory Account",InventoryAccountCode);
        InventoryPostingSetup.Modify(true);
    end;

    [Scope('Personalization')]
    procedure SetGeneralPostingSetupInventoryAdjmntAccount(GeneralProdPostingGroupCode: Code[20];GeneralBusPostingGroupCode: Code[10];InventoryAdjmntAccountCode: Code[20])
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        GeneralPostingSetup.Get(GeneralBusPostingGroupCode,GeneralProdPostingGroupCode);
        GeneralPostingSetup.Validate("Inventory Adjmt. Account",InventoryAdjmntAccountCode);
        GeneralPostingSetup.Modify(true);
    end;

    [Scope('Personalization')]
    procedure SetInventoryPostingGroup(InventoryPostingGroupCode: Code[20]): Boolean
    var
        InventoryPostingGroup: Record "Inventory Posting Group";
    begin
        if not ItemIsSet then
          Error(InternalItemNotSetErr);

        if not InventoryPostingGroup.Get(InventoryPostingGroupCode) then
          exit;

        GlobalItem.Validate("Inventory Posting Group",InventoryPostingGroupCode);

        exit(true);
    end;

    [Scope('Personalization')]
    procedure SetGeneralProductPostingGroup(GenProductPostingGroupCode: Code[20]): Boolean
    var
        GenProductPostingGroup: Record "Gen. Product Posting Group";
    begin
        if not ItemIsSet then
          Error(InternalItemNotSetErr);

        if not GenProductPostingGroup.Get(GenProductPostingGroupCode) then
          exit;

        GlobalItem.Validate("Gen. Prod. Posting Group",GenProductPostingGroupCode);

        exit(true);
    end;

    [Scope('Personalization')]
    procedure SetSearchDescription(SearchDescriptionToSet: Code[50])
    begin
        if not ItemIsSet then
          Error(InternalItemNotSetErr);

        GlobalItem.Validate("Search Description",SearchDescriptionToSet);
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnMigrateItem(RecordIdToMigrate: RecordID)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnMigrateItemPrice(RecordIdToMigrate: RecordID)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnMigrateItemSalesLineDiscount(RecordIdToMigrate: RecordID)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnMigrateItemTrackingCode(RecordIdToMigrate: RecordID)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnMigrateCostingMethod(RecordIdToMigrate: RecordID)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnMigrateItemUnitOfMeasure(RecordIdToMigrate: RecordID)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnMigrateItemDiscountGroup(RecordIdToMigrate: RecordID)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnMigrateItemTariffNo(RecordIdToMigrate: RecordID)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnMigrateItemDimensions(RecordIdToMigrate: RecordID)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnMigrateItemPostingGroups(RecordIdToMigrate: RecordID;ChartOfAccountsMigrated: Boolean)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnMigrateInventoryTransactions(RecordIdToMigrate: RecordID;ChartOfAccountsMigrated: Boolean)
    begin
    end;
}

