table 37 "Sales Line"
{
    // version NAVW113.00

    Caption = 'Sales Line';
    DrillDownPageID = "Sales Lines";
    LookupPageID = "Sales Lines";

    fields
    {
        field(1;"Document Type";Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        }
        field(2;"Sell-to Customer No.";Code[20])
        {
            Caption = 'Sell-to Customer No.';
            Editable = false;
            TableRelation = Customer;
        }
        field(3;"Document No.";Code[20])
        {
            Caption = 'Document No.';
            TableRelation = "Sales Header"."No." WHERE ("Document Type"=FIELD("Document Type"));
        }
        field(4;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(5;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = ' ,G/L Account,Item,Resource,Fixed Asset,Charge (Item)';
            OptionMembers = " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)";

            trigger OnValidate()
            var
                TempSalesLine: Record "Sales Line" temporary;
            begin
                TestJobPlanningLine;
                TestStatusOpen;
                GetSalesHeader;

                TestField("Qty. Shipped Not Invoiced",0);
                TestField("Quantity Shipped",0);
                TestField("Shipment No.",'');

                TestField("Return Qty. Rcd. Not Invd.",0);
                TestField("Return Qty. Received",0);
                TestField("Return Receipt No.",'');

                TestField("Prepmt. Amt. Inv.",0);

                CheckAssocPurchOrder(FieldCaption(Type));

                if Type <> xRec.Type then begin
                  case xRec.Type of
                    Type::Item:
                      begin
                        ATOLink.DeleteAsmFromSalesLine(Rec);
                        if Quantity <> 0 then begin
                          SalesHeader.TestField(Status,SalesHeader.Status::Open);
                          CalcFields("Reserved Qty. (Base)");
                          TestField("Reserved Qty. (Base)",0);
                          ReserveSalesLine.VerifyChange(Rec,xRec);
                          WhseValidateSourceLine.SalesLineVerifyChange(Rec,xRec);
                        end;
                      end;
                    Type::"Fixed Asset":
                      if Quantity <> 0 then
                        SalesHeader.TestField(Status,SalesHeader.Status::Open);
                    Type::"Charge (Item)":
                      DeleteChargeChargeAssgnt("Document Type","Document No.","Line No.");
                  end;
                  if xRec."Deferral Code" <> '' then
                    DeferralUtilities.RemoveOrSetDeferralSchedule('',
                      DeferralUtilities.GetSalesDeferralDocType,'','',
                      xRec."Document Type",xRec."Document No.",xRec."Line No.",
                      xRec.GetDeferralAmount,xRec."Posting Date",'',xRec."Currency Code",true);
                end;
                AddOnIntegrMgt.CheckReceiptOrderStatus(Rec);
                TempSalesLine := Rec;
                Init;
                if xRec."Line Amount" <> 0 then
                  "Recalculate Invoice Disc." := true;

                Type := TempSalesLine.Type;
                "System-Created Entry" := TempSalesLine."System-Created Entry";
                "Currency Code" := SalesHeader."Currency Code";

                OnValidateTypeOnCopyFromTempSalesLine(Rec,TempSalesLine);

                if Type = Type::Item then
                  "Allow Item Charge Assignment" := true
                else
                  "Allow Item Charge Assignment" := false;
                if Type = Type::Item then begin
                  if SalesHeader.InventoryPickConflict("Document Type","Document No.",SalesHeader."Shipping Advice") then
                    Error(Text056,SalesHeader."Shipping Advice");
                  if SalesHeader.WhseShpmntConflict("Document Type","Document No.",SalesHeader."Shipping Advice") then
                    Error(Text052,SalesHeader."Shipping Advice");
                end;
            end;
        }
        field(6;"No.";Code[20])
        {
            CaptionClass = GetCaptionClass(FieldNo("No."));
            Caption = 'No.';
            TableRelation = IF (Type=CONST(" ")) "Standard Text"
                            ELSE IF (Type=CONST("G/L Account"),
                                     "System-Created Entry"=CONST(false)) "G/L Account" WHERE ("Direct Posting"=CONST(true),
                                                                                               "Account Type"=CONST(Posting),
                                                                                               Blocked=CONST(false))
                                                                                               ELSE IF (Type=CONST("G/L Account"),
                                                                                                        "System-Created Entry"=CONST(true)) "G/L Account"
                                                                                                        ELSE IF (Type=CONST(Resource)) Resource
                                                                                                        ELSE IF (Type=CONST("Fixed Asset")) "Fixed Asset"
                                                                                                        ELSE IF (Type=CONST("Charge (Item)")) "Item Charge"
                                                                                                        ELSE IF (Type=CONST(Item)) Item WHERE (Blocked=CONST(false));
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                TempSalesLine: Record "Sales Line" temporary;
                FindRecordMgt: Codeunit "Find Record Management";
            begin
                "No." := FindRecordMgt.FindNoFromTypedValue(Type,"No.",not "System-Created Entry");

                TestJobPlanningLine;
                TestStatusOpen;
                CheckItemAvailable(FieldNo("No."));

                if (xRec."No." <> "No.") and (Quantity <> 0) then begin
                  TestField("Qty. to Asm. to Order (Base)",0);
                  CalcFields("Reserved Qty. (Base)");
                  TestField("Reserved Qty. (Base)",0);
                  if Type = Type::Item then
                    WhseValidateSourceLine.SalesLineVerifyChange(Rec,xRec);
                end;

                TestField("Qty. Shipped Not Invoiced",0);
                TestField("Quantity Shipped",0);
                TestField("Shipment No.",'');

                TestField("Prepmt. Amt. Inv.",0);

                TestField("Return Qty. Rcd. Not Invd.",0);
                TestField("Return Qty. Received",0);
                TestField("Return Receipt No.",'');

                if "No." = '' then
                  ATOLink.DeleteAsmFromSalesLine(Rec);
                CheckAssocPurchOrder(FieldCaption("No."));
                AddOnIntegrMgt.CheckReceiptOrderStatus(Rec);

                TempSalesLine := Rec;
                Init;
                if xRec."Line Amount" <> 0 then
                  "Recalculate Invoice Disc." := true;
                Type := TempSalesLine.Type;
                "No." := TempSalesLine."No.";
                OnValidateNoOnCopyFromTempSalesLine(Rec,TempSalesLine);
                if "No." = '' then
                  exit;

                if HasTypeToFillMandatoryFields then
                  Quantity := TempSalesLine.Quantity;

                "System-Created Entry" := TempSalesLine."System-Created Entry";
                GetSalesHeader;
                InitHeaderDefaults(SalesHeader);
                CalcFields("Substitution Available");

                "Promised Delivery Date" := SalesHeader."Promised Delivery Date";
                "Requested Delivery Date" := SalesHeader."Requested Delivery Date";
                "Shipment Date" :=
                  CalendarMgmt.CalcDateBOC(
                    '',SalesHeader."Shipment Date",CalChange."Source Type"::Location,"Location Code",'',
                    CalChange."Source Type"::"Shipping Agent","Shipping Agent Code","Shipping Agent Service Code",false);
                UpdateDates;

                OnAfterAssignHeaderValues(Rec,SalesHeader);

                case Type of
                  Type::" ":
                    CopyFromStandardText;
                  Type::"G/L Account":
                    CopyFromGLAccount;
                  Type::Item:
                    CopyFromItem;
                  Type::Resource:
                    CopyFromResource;
                  Type::"Fixed Asset":
                    CopyFromFixedAsset;
                  Type::"Charge (Item)":
                    CopyFromItemCharge;
                end;

                OnAfterAssignFieldsForNo(Rec,xRec,SalesHeader);

                if HasTypeToFillMandatoryFields and (Type <> Type::"Fixed Asset") then
                  Validate("VAT Prod. Posting Group");

                UpdatePrepmtSetupFields;

                if HasTypeToFillMandatoryFields then begin
                  Validate("Unit of Measure Code");
                  if Quantity <> 0 then begin
                    InitOutstanding;
                    if "Document Type" in ["Document Type"::"Return Order","Document Type"::"Credit Memo"] then
                      InitQtyToReceive
                    else
                      InitQtyToShip;
                    InitQtyToAsm;
                    UpdateWithWarehouseShip;
                  end;
                  UpdateUnitPrice(FieldNo("No."));
                end;

                if not IsTemporary then
                  CreateDim(
                    DimMgt.TypeToTableID3(Type),"No.",
                    DATABASE::Job,"Job No.",
                    DATABASE::"Responsibility Center","Responsibility Center");

                if "No." <> xRec."No." then begin
                  if Type = Type::Item then
                    if (Quantity <> 0) and ItemExists(xRec."No.") then begin
                      ReserveSalesLine.VerifyChange(Rec,xRec);
                      WhseValidateSourceLine.SalesLineVerifyChange(Rec,xRec);
                    end;
                  GetDefaultBin;
                  AutoAsmToOrder;
                  DeleteItemChargeAssgnt("Document Type","Document No.","Line No.");
                  if Type = Type::"Charge (Item)" then
                    DeleteChargeChargeAssgnt("Document Type","Document No.","Line No.");
                end;

                UpdateItemCrossRef;

                PostingSetupMgt.CheckGenPostingSetupSalesAccount("Gen. Bus. Posting Group","Gen. Prod. Posting Group");
                PostingSetupMgt.CheckGenPostingSetupCOGSAccount("Gen. Bus. Posting Group","Gen. Prod. Posting Group");
                PostingSetupMgt.CheckVATPostingSetupSalesAccount("VAT Bus. Posting Group","VAT Prod. Posting Group");
            end;
        }
        field(7;"Location Code";Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location WHERE ("Use As In-Transit"=CONST(false));

            trigger OnValidate()
            begin
                TestJobPlanningLine;
                TestStatusOpen;
                CheckAssocPurchOrder(FieldCaption("Location Code"));
                if "Location Code" <> '' then
                  if IsNonInventoriableItem then
                    Item.TestField(Type,Item.Type::Inventory);
                if xRec."Location Code" <> "Location Code" then begin
                  if not FullQtyIsForAsmToOrder then begin
                    CalcFields("Reserved Qty. (Base)");
                    TestField("Reserved Qty. (Base)","Qty. to Asm. to Order (Base)");
                  end;
                  TestField("Qty. Shipped Not Invoiced",0);
                  TestField("Shipment No.",'');
                  TestField("Return Qty. Rcd. Not Invd.",0);
                  TestField("Return Receipt No.",'');
                end;

                GetSalesHeader;
                "Shipment Date" :=
                  CalendarMgmt.CalcDateBOC(
                    '',
                    SalesHeader."Shipment Date",
                    CalChange."Source Type"::Location,
                    "Location Code",
                    '',
                    CalChange."Source Type"::"Shipping Agent",
                    "Shipping Agent Code",
                    "Shipping Agent Service Code",
                    false);

                CheckItemAvailable(FieldNo("Location Code"));

                if not "Drop Shipment" then begin
                  if "Location Code" = '' then begin
                    if InvtSetup.Get then
                      "Outbound Whse. Handling Time" := InvtSetup."Outbound Whse. Handling Time";
                  end else
                    if Location.Get("Location Code") then
                      "Outbound Whse. Handling Time" := Location."Outbound Whse. Handling Time";
                end else
                  Evaluate("Outbound Whse. Handling Time",'<0D>');

                if "Location Code" <> xRec."Location Code" then begin
                  InitItemAppl(true);
                  GetDefaultBin;
                  InitQtyToAsm;
                  AutoAsmToOrder;
                  if Quantity <> 0 then begin
                    if not "Drop Shipment" then
                      UpdateWithWarehouseShip;
                    if not FullReservedQtyIsForAsmToOrder then
                      ReserveSalesLine.VerifyChange(Rec,xRec);
                    WhseValidateSourceLine.SalesLineVerifyChange(Rec,xRec);
                  end;
                  PostingSetupMgt.CheckInvtPostingSetupInventoryAccount("Location Code","Posting Group");
                end;

                UpdateDates;

                if (Type = Type::Item) and ("No." <> '') then
                  GetUnitCost;

                CheckWMS;

                if "Document Type" = "Document Type"::"Return Order" then
                  ValidateReturnReasonCode(FieldNo("Location Code"));
            end;
        }
        field(8;"Posting Group";Code[20])
        {
            Caption = 'Posting Group';
            Editable = false;
            TableRelation = IF (Type=CONST(Item)) "Inventory Posting Group"
                            ELSE IF (Type=CONST("Fixed Asset")) "FA Posting Group";
        }
        field(10;"Shipment Date";Date)
        {
            AccessByPermission = TableData "Sales Shipment Header"=R;
            Caption = 'Shipment Date';

            trigger OnValidate()
            var
                CheckDateConflict: Codeunit "Reservation-Check Date Confl.";
            begin
                TestStatusOpen;
                WhseValidateSourceLine.SalesLineVerifyChange(Rec,xRec);
                if CurrFieldNo <> 0 then
                  AddOnIntegrMgt.CheckReceiptOrderStatus(Rec);

                if "Shipment Date" <> 0D then begin
                  if CurrFieldNo in [
                                     FieldNo("Planned Shipment Date"),
                                     FieldNo("Planned Delivery Date"),
                                     FieldNo("Shipment Date"),
                                     FieldNo("Shipping Time"),
                                     FieldNo("Outbound Whse. Handling Time"),
                                     FieldNo("Requested Delivery Date")]
                  then
                    CheckItemAvailable(FieldNo("Shipment Date"));

                  if ("Shipment Date" < WorkDate) and HasTypeToFillMandatoryFields then
                    if not (GetHideValidationDialog or HasBeenShown) and GuiAllowed then begin
                      Message(
                        Text014,
                        FieldCaption("Shipment Date"),"Shipment Date",WorkDate);
                      HasBeenShown := true;
                    end;
                end;

                AutoAsmToOrder;
                if (xRec."Shipment Date" <> "Shipment Date") and
                   (Quantity <> 0) and
                   not StatusCheckSuspended
                then
                  CheckDateConflict.SalesLineCheck(Rec,CurrFieldNo <> 0);

                if not PlannedShipmentDateCalculated then
                  "Planned Shipment Date" := CalcPlannedShptDate(FieldNo("Shipment Date"));
                if not PlannedDeliveryDateCalculated then
                  "Planned Delivery Date" := CalcPlannedDeliveryDate(FieldNo("Shipment Date"));
            end;
        }
        field(11;Description;Text[50])
        {
            Caption = 'Description';
            TableRelation = IF (Type=CONST("G/L Account"),
                                "System-Created Entry"=CONST(false)) "G/L Account".Name WHERE ("Direct Posting"=CONST(true),
                                                                                               "Account Type"=CONST(Posting),
                                                                                               Blocked=CONST(false))
                                                                                               ELSE IF (Type=CONST("G/L Account"),
                                                                                                        "System-Created Entry"=CONST(true)) "G/L Account".Name
                                                                                                        ELSE IF (Type=CONST(Item)) Item.Description WHERE (Blocked=CONST(false))
                                                                                                        ELSE IF (Type=CONST(Resource)) Resource.Name
                                                                                                        ELSE IF (Type=CONST("Fixed Asset")) "Fixed Asset".Description
                                                                                                        ELSE IF (Type=CONST("Charge (Item)")) "Item Charge".Description;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                Item: Record Item;
                ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
                FindRecordMgt: Codeunit "Find Record Management";
                IdentityManagement: Codeunit "Identity Management";
                ReturnValue: Text[50];
                DescriptionIsNo: Boolean;
                DefaultCreate: Boolean;
                Confirmed: Boolean;
            begin
                if Type = Type::" " then
                  exit;

                case Type of
                  Type::Item:
                    begin
                      if (StrLen(Description) <= MaxStrLen(Item."No.")) and ("No." <> '') then
                        DescriptionIsNo := Item.Get(Description)
                      else
                        DescriptionIsNo := false;
                      if ("No." <> '') and (not DescriptionIsNo) and (Description <> '') then begin
                        Item.SetRange(Description,Description);
                        if Item.FindFirst then
                          Confirmed := IdentityManagement.IsInvAppId
                        else begin
                          Item.SetFilter(Description,'''@' + ConvertStr(Description,'''','?') + '''');
                          if not Item.FindFirst then
                            exit;
                        end;
                        if Item."No." = "No." then
                          exit;
                        if GuiAllowed then
                          if not IdentityManagement.IsInvAppId then
                            Confirmed := Confirm(AnotherItemWithSameDescrQst,false,Item."No.",Item.Description);
                        if IdentityManagement.IsInvAppId or Confirmed then
                          Validate("No.",Item."No.");
                        exit;
                      end;

                      GetSalesSetup;
                      DefaultCreate := ("No." = '') and SalesSetup."Create Item from Description";
                      if Item.TryGetItemNoOpenCard(
                           ReturnValue,Description,DefaultCreate,not GetHideValidationDialog,not IdentityManagement.IsInvAppId)
                      then
                        case ReturnValue of
                          '':
                            begin
                              LookupRequested := true;
                              Description := xRec.Description;
                            end;
                          "No.":
                            Description := xRec.Description;
                          else begin
                            CurrFieldNo := FieldNo("No.");
                            Validate("No.",CopyStr(ReturnValue,1,MaxStrLen(Item."No.")));
                          end;
                        end;
                    end;
                  else
                    if ("No." = '') or (CurrFieldNo = FieldNo(Description)) then
                      if FindRecordMgt.FindRecordByDescription(ReturnValue,Type,Description) = 1 then begin
                        CurrFieldNo := FieldNo("No.");
                        Validate("No.",CopyStr(ReturnValue,1,MaxStrLen("No.")));
                      end;
                end;
                if ("No." = '') and GuiAllowed and ApplicationAreaMgmtFacade.IsFoundationEnabled then
                  if "Document Type" in
                     ["Document Type"::Order,"Document Type"::Invoice,"Document Type"::Quote,"Document Type"::"Credit Memo"]
                  then
                    Error(CannotFindDescErr,Type,Description);
            end;
        }
        field(12;"Description 2";Text[50])
        {
            Caption = 'Description 2';
        }
        field(13;"Unit of Measure";Text[10])
        {
            Caption = 'Unit of Measure';
            TableRelation = IF (Type=FILTER(<>" ")) "Unit of Measure".Description;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(15;Quantity;Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0:5;

            trigger OnValidate()
            var
                ItemLedgEntry: Record "Item Ledger Entry";
            begin
                TestJobPlanningLine;
                TestStatusOpen;

                CheckAssocPurchOrder(FieldCaption(Quantity));

                if "Shipment No." <> '' then
                  CheckShipmentRelation
                else
                  if "Return Receipt No." <> '' then
                    CheckRetRcptRelation;

                "Quantity (Base)" := CalcBaseQty(Quantity);

                if "Document Type" in ["Document Type"::"Return Order","Document Type"::"Credit Memo"] then begin
                  if (Quantity * "Return Qty. Received" < 0) or
                     ((Abs(Quantity) < Abs("Return Qty. Received")) and ("Return Receipt No." = ''))
                  then
                    FieldError(Quantity,StrSubstNo(Text003,FieldCaption("Return Qty. Received")));
                  if ("Quantity (Base)" * "Return Qty. Received (Base)" < 0) or
                     ((Abs("Quantity (Base)") < Abs("Return Qty. Received (Base)")) and ("Return Receipt No." = ''))
                  then
                    FieldError("Quantity (Base)",StrSubstNo(Text003,FieldCaption("Return Qty. Received (Base)")));
                end else begin
                  if (Quantity * "Quantity Shipped" < 0) or
                     ((Abs(Quantity) < Abs("Quantity Shipped")) and ("Shipment No." = ''))
                  then
                    FieldError(Quantity,StrSubstNo(Text003,FieldCaption("Quantity Shipped")));
                  if ("Quantity (Base)" * "Qty. Shipped (Base)" < 0) or
                     ((Abs("Quantity (Base)") < Abs("Qty. Shipped (Base)")) and ("Shipment No." = ''))
                  then
                    FieldError("Quantity (Base)",StrSubstNo(Text003,FieldCaption("Qty. Shipped (Base)")));
                end;

                if (Type = Type::"Charge (Item)") and (CurrFieldNo <> 0) then begin
                  if (Quantity = 0) and ("Qty. to Assign" <> 0) then
                    FieldError("Qty. to Assign",StrSubstNo(Text009,FieldCaption(Quantity),Quantity));
                  if (Quantity * "Qty. Assigned" < 0) or (Abs(Quantity) < Abs("Qty. Assigned")) then
                    FieldError(Quantity,StrSubstNo(Text003,FieldCaption("Qty. Assigned")));
                end;

                AddOnIntegrMgt.CheckReceiptOrderStatus(Rec);
                if (xRec.Quantity <> Quantity) or (xRec."Quantity (Base)" <> "Quantity (Base)") then begin
                  InitOutstanding;
                  if "Document Type" in ["Document Type"::"Return Order","Document Type"::"Credit Memo"] then
                    InitQtyToReceive
                  else
                    InitQtyToShip;
                  InitQtyToAsm;
                  SetDefaultQuantity;
                end;

                CheckItemAvailable(FieldNo(Quantity));

                if (Quantity * xRec.Quantity < 0) or (Quantity = 0) then
                  InitItemAppl(false);

                if Type = Type::Item then begin
                  UpdateUnitPrice(FieldNo(Quantity));
                  if (xRec.Quantity <> Quantity) or (xRec."Quantity (Base)" <> "Quantity (Base)") then begin
                    OnBeforeVerifyReservedQty(Rec,xRec,FieldNo(Quantity));
                    ReserveSalesLine.VerifyQuantity(Rec,xRec);
                    if not "Drop Shipment" then
                      UpdateWithWarehouseShip;
                    WhseValidateSourceLine.SalesLineVerifyChange(Rec,xRec);
                    if ("Quantity (Base)" * xRec."Quantity (Base)" <= 0) and ("No." <> '') then begin
                      GetItem;
                      if (Item."Costing Method" = Item."Costing Method"::Standard) and not IsShipment then
                        GetUnitCost;
                    end;
                  end;
                  Validate("Qty. to Assemble to Order");
                  if (Quantity = "Quantity Invoiced") and (CurrFieldNo <> 0) then
                    CheckItemChargeAssgnt;
                  CheckApplFromItemLedgEntry(ItemLedgEntry);
                end else
                  Validate("Line Discount %");

                if (xRec.Quantity <> Quantity) and (Quantity = 0) and
                   ((Amount <> 0) or ("Amount Including VAT" <> 0) or ("VAT Base Amount" <> 0))
                then begin
                  Amount := 0;
                  "Amount Including VAT" := 0;
                  "VAT Base Amount" := 0;
                end;

                UpdatePrePaymentAmounts;

                CheckWMS;

                UpdatePlanned;
                if "Document Type" = "Document Type"::"Return Order" then
                  ValidateReturnReasonCode(FieldNo(Quantity));
            end;
        }
        field(16;"Outstanding Quantity";Decimal)
        {
            Caption = 'Outstanding Quantity';
            DecimalPlaces = 0:5;
            Editable = false;
        }
        field(17;"Qty. to Invoice";Decimal)
        {
            Caption = 'Qty. to Invoice';
            DecimalPlaces = 0:5;

            trigger OnValidate()
            begin
                if "Qty. to Invoice" = MaxQtyToInvoice then
                  InitQtyToInvoice
                else
                  "Qty. to Invoice (Base)" := CalcBaseQty("Qty. to Invoice");
                if ("Qty. to Invoice" * Quantity < 0) or
                   (Abs("Qty. to Invoice") > Abs(MaxQtyToInvoice))
                then
                  Error(
                    Text005,
                    MaxQtyToInvoice);
                if ("Qty. to Invoice (Base)" * "Quantity (Base)" < 0) or
                   (Abs("Qty. to Invoice (Base)") > Abs(MaxQtyToInvoiceBase))
                then
                  Error(
                    Text006,
                    MaxQtyToInvoiceBase);
                "VAT Difference" := 0;
                CalcInvDiscToInvoice;
                CalcPrepaymentToDeduct;
            end;
        }
        field(18;"Qty. to Ship";Decimal)
        {
            AccessByPermission = TableData "Sales Shipment Header"=R;
            Caption = 'Qty. to Ship';
            DecimalPlaces = 0:5;

            trigger OnValidate()
            var
                ItemLedgEntry: Record "Item Ledger Entry";
            begin
                GetLocation("Location Code");
                if (CurrFieldNo <> 0) and
                   (Type = Type::Item) and
                   (not "Drop Shipment")
                then begin
                  if Location."Require Shipment" and
                     ("Qty. to Ship" <> 0)
                  then
                    CheckWarehouse;
                  WhseValidateSourceLine.SalesLineVerifyChange(Rec,xRec);
                end;

                if "Qty. to Ship" = "Outstanding Quantity" then
                  InitQtyToShip
                else begin
                  "Qty. to Ship (Base)" := CalcBaseQty("Qty. to Ship");
                  CheckServItemCreation;
                  InitQtyToInvoice;
                end;
                if ((("Qty. to Ship" < 0) xor (Quantity < 0)) and (Quantity <> 0) and ("Qty. to Ship" <> 0)) or
                   (Abs("Qty. to Ship") > Abs("Outstanding Quantity")) or
                   (((Quantity < 0) xor ("Outstanding Quantity" < 0)) and (Quantity <> 0) and ("Outstanding Quantity" <> 0))
                then
                  Error(
                    Text007,
                    "Outstanding Quantity");
                if ((("Qty. to Ship (Base)" < 0) xor ("Quantity (Base)" < 0)) and ("Qty. to Ship (Base)" <> 0) and ("Quantity (Base)" <> 0)) or
                   (Abs("Qty. to Ship (Base)") > Abs("Outstanding Qty. (Base)")) or
                   ((("Quantity (Base)" < 0) xor ("Outstanding Qty. (Base)" < 0)) and ("Quantity (Base)" <> 0) and ("Outstanding Qty. (Base)" <> 0))
                then
                  Error(
                    Text008,
                    "Outstanding Qty. (Base)");

                if (CurrFieldNo <> 0) and (Type = Type::Item) and ("Qty. to Ship" < 0) then
                  CheckApplFromItemLedgEntry(ItemLedgEntry);

                ATOLink.UpdateQtyToAsmFromSalesLine(Rec);
            end;
        }
        field(22;"Unit Price";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            CaptionClass = GetCaptionClass(FieldNo("Unit Price"));
            Caption = 'Unit Price';

            trigger OnValidate()
            begin
                TestJobPlanningLine;
                TestStatusOpen;
                Validate("Line Discount %");
            end;
        }
        field(23;"Unit Cost (LCY)";Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost (LCY)';

            trigger OnValidate()
            begin
                if (CurrFieldNo = FieldNo("Unit Cost (LCY)")) and
                   ("Unit Cost (LCY)" <> xRec."Unit Cost (LCY)")
                then
                  CheckAssocPurchOrder(FieldCaption("Unit Cost (LCY)"));

                if (CurrFieldNo = FieldNo("Unit Cost (LCY)")) and
                   (Type = Type::Item) and ("No." <> '') and ("Quantity (Base)" <> 0)
                then begin
                  TestJobPlanningLine;
                  GetItem;
                  if (Item."Costing Method" = Item."Costing Method"::Standard) and not IsShipment then begin
                    if "Document Type" in ["Document Type"::"Return Order","Document Type"::"Credit Memo"] then
                      Error(
                        Text037,
                        FieldCaption("Unit Cost (LCY)"),Item.FieldCaption("Costing Method"),
                        Item."Costing Method",FieldCaption(Quantity));
                    Error(
                      Text038,
                      FieldCaption("Unit Cost (LCY)"),Item.FieldCaption("Costing Method"),
                      Item."Costing Method",FieldCaption(Quantity));
                  end;
                end;

                GetSalesHeader;
                if SalesHeader."Currency Code" <> '' then begin
                  Currency.TestField("Unit-Amount Rounding Precision");
                  "Unit Cost" :=
                    Round(
                      CurrExchRate.ExchangeAmtLCYToFCY(
                        GetDate,SalesHeader."Currency Code",
                        "Unit Cost (LCY)",SalesHeader."Currency Factor"),
                      Currency."Unit-Amount Rounding Precision")
                end else
                  "Unit Cost" := "Unit Cost (LCY)";
            end;
        }
        field(25;"VAT %";Decimal)
        {
            Caption = 'VAT %';
            DecimalPlaces = 0:5;
            Editable = false;
        }
        field(27;"Line Discount %";Decimal)
        {
            Caption = 'Line Discount %';
            DecimalPlaces = 0:5;
            MaxValue = 100;
            MinValue = 0;

            trigger OnValidate()
            begin
                TestJobPlanningLine;
                TestStatusOpen;
                "Line Discount Amount" :=
                  Round(
                    Round(Quantity * "Unit Price",Currency."Amount Rounding Precision") *
                    "Line Discount %" / 100,Currency."Amount Rounding Precision");
                "Inv. Discount Amount" := 0;
                "Inv. Disc. Amount to Invoice" := 0;
                UpdateAmounts;
            end;
        }
        field(28;"Line Discount Amount";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Line Discount Amount';

            trigger OnValidate()
            begin
                GetSalesHeader;
                "Line Discount Amount" := Round("Line Discount Amount",Currency."Amount Rounding Precision");
                TestJobPlanningLine;
                TestStatusOpen;
                TestField(Quantity);
                if xRec."Line Discount Amount" <> "Line Discount Amount" then
                  UpdateLineDiscPct;
                "Inv. Discount Amount" := 0;
                "Inv. Disc. Amount to Invoice" := 0;
                UpdateAmounts;
            end;
        }
        field(29;Amount;Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount';
            Editable = false;

            trigger OnValidate()
            begin
                Amount := Round(Amount,Currency."Amount Rounding Precision");
                case "VAT Calculation Type" of
                  "VAT Calculation Type"::"Normal VAT",
                  "VAT Calculation Type"::"Reverse Charge VAT":
                    begin
                      "VAT Base Amount" :=
                        Round(Amount * (1 - SalesHeader."VAT Base Discount %" / 100),Currency."Amount Rounding Precision");
                      "Amount Including VAT" :=
                        Round(Amount + "VAT Base Amount" * "VAT %" / 100,Currency."Amount Rounding Precision");
                    end;
                  "VAT Calculation Type"::"Full VAT":
                    if Amount <> 0 then
                      FieldError(Amount,
                        StrSubstNo(
                          Text009,FieldCaption("VAT Calculation Type"),
                          "VAT Calculation Type"));
                  "VAT Calculation Type"::"Sales Tax":
                    begin
                      SalesHeader.TestField("VAT Base Discount %",0);
                      "VAT Base Amount" := Round(Amount,Currency."Amount Rounding Precision");
                      "Amount Including VAT" :=
                        Amount +
                        SalesTaxCalculate.CalculateTax(
                          "Tax Area Code","Tax Group Code","Tax Liable",SalesHeader."Posting Date",
                          "VAT Base Amount","Quantity (Base)",SalesHeader."Currency Factor");
                      if "VAT Base Amount" <> 0 then
                        "VAT %" :=
                          Round(100 * ("Amount Including VAT" - "VAT Base Amount") / "VAT Base Amount",0.00001)
                      else
                        "VAT %" := 0;
                      "Amount Including VAT" := Round("Amount Including VAT",Currency."Amount Rounding Precision");
                    end;
                end;

                InitOutstandingAmount;
            end;
        }
        field(30;"Amount Including VAT";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount Including VAT';
            Editable = false;

            trigger OnValidate()
            begin
                "Amount Including VAT" := Round("Amount Including VAT",Currency."Amount Rounding Precision");
                case "VAT Calculation Type" of
                  "VAT Calculation Type"::"Normal VAT",
                  "VAT Calculation Type"::"Reverse Charge VAT":
                    begin
                      Amount :=
                        Round(
                          "Amount Including VAT" /
                          (1 + (1 - SalesHeader."VAT Base Discount %" / 100) * "VAT %" / 100),
                          Currency."Amount Rounding Precision");
                      "VAT Base Amount" :=
                        Round(Amount * (1 - SalesHeader."VAT Base Discount %" / 100),Currency."Amount Rounding Precision");
                    end;
                  "VAT Calculation Type"::"Full VAT":
                    begin
                      Amount := 0;
                      "VAT Base Amount" := 0;
                    end;
                  "VAT Calculation Type"::"Sales Tax":
                    begin
                      SalesHeader.TestField("VAT Base Discount %",0);
                      Amount :=
                        SalesTaxCalculate.ReverseCalculateTax(
                          "Tax Area Code","Tax Group Code","Tax Liable",SalesHeader."Posting Date",
                          "Amount Including VAT","Quantity (Base)",SalesHeader."Currency Factor");
                      if Amount <> 0 then
                        "VAT %" :=
                          Round(100 * ("Amount Including VAT" - Amount) / Amount,0.00001)
                      else
                        "VAT %" := 0;
                      Amount := Round(Amount,Currency."Amount Rounding Precision");
                      "VAT Base Amount" := Amount;
                    end;
                end;

                InitOutstandingAmount;
            end;
        }
        field(32;"Allow Invoice Disc.";Boolean)
        {
            Caption = 'Allow Invoice Disc.';
            InitValue = true;

            trigger OnValidate()
            begin
                TestStatusOpen;
                if ("Allow Invoice Disc." <> xRec."Allow Invoice Disc.") and
                   (not "Allow Invoice Disc.")
                then begin
                  "Inv. Discount Amount" := 0;
                  "Inv. Disc. Amount to Invoice" := 0;
                  UpdateAmounts;
                end;
            end;
        }
        field(34;"Gross Weight";Decimal)
        {
            Caption = 'Gross Weight';
            DecimalPlaces = 0:5;
        }
        field(35;"Net Weight";Decimal)
        {
            Caption = 'Net Weight';
            DecimalPlaces = 0:5;
        }
        field(36;"Units per Parcel";Decimal)
        {
            Caption = 'Units per Parcel';
            DecimalPlaces = 0:5;
        }
        field(37;"Unit Volume";Decimal)
        {
            Caption = 'Unit Volume';
            DecimalPlaces = 0:5;
        }
        field(38;"Appl.-to Item Entry";Integer)
        {
            AccessByPermission = TableData Item=R;
            Caption = 'Appl.-to Item Entry';

            trigger OnLookup()
            begin
                SelectItemEntry(FieldNo("Appl.-to Item Entry"));
            end;

            trigger OnValidate()
            var
                ItemLedgEntry: Record "Item Ledger Entry";
                ItemTrackingLines: Page "Item Tracking Lines";
            begin
                if "Appl.-to Item Entry" <> 0 then begin
                  AddOnIntegrMgt.CheckReceiptOrderStatus(Rec);

                  TestField(Type,Type::Item);
                  TestField(Quantity);
                  if "Document Type" in ["Document Type"::"Return Order","Document Type"::"Credit Memo"] then begin
                    if Quantity > 0 then
                      FieldError(Quantity,Text030);
                  end else begin
                    if Quantity < 0 then
                      FieldError(Quantity,Text029);
                  end;
                  ItemLedgEntry.Get("Appl.-to Item Entry");
                  ItemLedgEntry.TestField(Positive,true);
                  if ItemLedgEntry.TrackingExists then
                    Error(Text040,ItemTrackingLines.Caption,FieldCaption("Appl.-to Item Entry"));
                  if Abs("Qty. to Ship (Base)") > ItemLedgEntry.Quantity then
                    Error(ShippingMoreUnitsThanReceivedErr,ItemLedgEntry.Quantity,ItemLedgEntry."Document No.");

                  Validate("Unit Cost (LCY)",CalcUnitCost(ItemLedgEntry));

                  "Location Code" := ItemLedgEntry."Location Code";
                  if not ItemLedgEntry.Open then
                    Message(Text042,"Appl.-to Item Entry");
                end;
            end;
        }
        field(40;"Shortcut Dimension 1 Code";Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(1),
                                                          Blocked=CONST(false));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1,"Shortcut Dimension 1 Code");
                ATOLink.UpdateAsmDimFromSalesLine(Rec);
            end;
        }
        field(41;"Shortcut Dimension 2 Code";Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(2),
                                                          Blocked=CONST(false));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2,"Shortcut Dimension 2 Code");
                ATOLink.UpdateAsmDimFromSalesLine(Rec);
            end;
        }
        field(42;"Customer Price Group";Code[10])
        {
            Caption = 'Customer Price Group';
            Editable = false;
            TableRelation = "Customer Price Group";

            trigger OnValidate()
            begin
                if Type = Type::Item then
                  UpdateUnitPrice(FieldNo("Customer Price Group"));
            end;
        }
        field(45;"Job No.";Code[20])
        {
            Caption = 'Job No.';
            Editable = false;
            TableRelation = Job;
        }
        field(52;"Work Type Code";Code[10])
        {
            Caption = 'Work Type Code';
            TableRelation = "Work Type";

            trigger OnValidate()
            var
                WorkType: Record "Work Type";
            begin
                if Type = Type::Resource then begin
                  TestStatusOpen;
                  if WorkType.Get("Work Type Code") then
                    Validate("Unit of Measure Code",WorkType."Unit of Measure Code");
                  UpdateUnitPrice(FieldNo("Work Type Code"));
                  Validate("Unit Price");
                  FindResUnitCost;
                end;
            end;
        }
        field(56;"Recalculate Invoice Disc.";Boolean)
        {
            Caption = 'Recalculate Invoice Disc.';
            Editable = false;
        }
        field(57;"Outstanding Amount";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Outstanding Amount';
            Editable = false;

            trigger OnValidate()
            var
                Currency2: Record Currency;
            begin
                GetSalesHeader;
                Currency2.InitRoundingPrecision;
                if SalesHeader."Currency Code" <> '' then
                  "Outstanding Amount (LCY)" :=
                    Round(
                      CurrExchRate.ExchangeAmtFCYToLCY(
                        GetDate,"Currency Code",
                        "Outstanding Amount",SalesHeader."Currency Factor"),
                      Currency2."Amount Rounding Precision")
                else
                  "Outstanding Amount (LCY)" :=
                    Round("Outstanding Amount",Currency2."Amount Rounding Precision");
            end;
        }
        field(58;"Qty. Shipped Not Invoiced";Decimal)
        {
            Caption = 'Qty. Shipped Not Invoiced';
            DecimalPlaces = 0:5;
            Editable = false;
        }
        field(59;"Shipped Not Invoiced";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Shipped Not Invoiced';
            Editable = false;

            trigger OnValidate()
            var
                Currency2: Record Currency;
            begin
                GetSalesHeader;
                Currency2.InitRoundingPrecision;
                if SalesHeader."Currency Code" <> '' then
                  "Shipped Not Invoiced (LCY)" :=
                    Round(
                      CurrExchRate.ExchangeAmtFCYToLCY(
                        GetDate,"Currency Code",
                        "Shipped Not Invoiced",SalesHeader."Currency Factor"),
                      Currency2."Amount Rounding Precision")
                else
                  "Shipped Not Invoiced (LCY)" :=
                    Round("Shipped Not Invoiced",Currency2."Amount Rounding Precision");

                CalculateNotShippedInvExlcVatLCY;
            end;
        }
        field(60;"Quantity Shipped";Decimal)
        {
            AccessByPermission = TableData "Sales Shipment Header"=R;
            Caption = 'Quantity Shipped';
            DecimalPlaces = 0:5;
            Editable = false;
        }
        field(61;"Quantity Invoiced";Decimal)
        {
            Caption = 'Quantity Invoiced';
            DecimalPlaces = 0:5;
            Editable = false;
        }
        field(63;"Shipment No.";Code[20])
        {
            Caption = 'Shipment No.';
            Editable = false;
        }
        field(64;"Shipment Line No.";Integer)
        {
            Caption = 'Shipment Line No.';
            Editable = false;
        }
        field(67;"Profit %";Decimal)
        {
            Caption = 'Profit %';
            DecimalPlaces = 0:5;
            Editable = false;
        }
        field(68;"Bill-to Customer No.";Code[20])
        {
            Caption = 'Bill-to Customer No.';
            Editable = false;
            TableRelation = Customer;
        }
        field(69;"Inv. Discount Amount";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CaptionClass = GetCaptionClass(FieldNo("Inv. Discount Amount"));
            Caption = 'Inv. Discount Amount';
            Editable = false;

            trigger OnValidate()
            begin
                CalcInvDiscToInvoice;
                UpdateAmounts;
            end;
        }
        field(71;"Purchase Order No.";Code[20])
        {
            AccessByPermission = TableData "Sales Shipment Header"=R;
            Caption = 'Purchase Order No.';
            Editable = false;
            TableRelation = IF ("Drop Shipment"=CONST(true)) "Purchase Header"."No." WHERE ("Document Type"=CONST(Order));

            trigger OnValidate()
            begin
                if (xRec."Purchase Order No." <> "Purchase Order No.") and (Quantity <> 0) then begin
                  ReserveSalesLine.VerifyChange(Rec,xRec);
                  WhseValidateSourceLine.SalesLineVerifyChange(Rec,xRec);
                end;
            end;
        }
        field(72;"Purch. Order Line No.";Integer)
        {
            AccessByPermission = TableData "Sales Shipment Header"=R;
            Caption = 'Purch. Order Line No.';
            Editable = false;
            TableRelation = IF ("Drop Shipment"=CONST(true)) "Purchase Line"."Line No." WHERE ("Document Type"=CONST(Order),
                                                                                               "Document No."=FIELD("Purchase Order No."));

            trigger OnValidate()
            begin
                if (xRec."Purch. Order Line No." <> "Purch. Order Line No.") and (Quantity <> 0) then begin
                  ReserveSalesLine.VerifyChange(Rec,xRec);
                  WhseValidateSourceLine.SalesLineVerifyChange(Rec,xRec);
                end;
            end;
        }
        field(73;"Drop Shipment";Boolean)
        {
            AccessByPermission = TableData "Drop Shpt. Post. Buffer"=R;
            Caption = 'Drop Shipment';
            Editable = true;

            trigger OnValidate()
            begin
                TestField("Document Type","Document Type"::Order);
                TestField(Type,Type::Item);
                TestField("Quantity Shipped",0);
                TestField("Job No.",'');
                TestField("Qty. to Asm. to Order (Base)",0);

                if "Drop Shipment" then
                  TestField("Special Order",false);

                CheckAssocPurchOrder(FieldCaption("Drop Shipment"));

                if "Special Order" then
                  Reserve := Reserve::Never
                else
                  if "Drop Shipment" then begin
                    Reserve := Reserve::Never;
                    Evaluate("Outbound Whse. Handling Time",'<0D>');
                    Evaluate("Shipping Time",'<0D>');
                    UpdateDates;
                    "Bin Code" := '';
                  end else
                    SetReserveWithoutPurchasingCode;

                CheckItemAvailable(FieldNo("Drop Shipment"));

                AddOnIntegrMgt.CheckReceiptOrderStatus(Rec);
                if (xRec."Drop Shipment" <> "Drop Shipment") and (Quantity <> 0) then begin
                  if not "Drop Shipment" then begin
                    InitQtyToAsm;
                    AutoAsmToOrder;
                    UpdateWithWarehouseShip
                  end else
                    InitQtyToShip;
                  WhseValidateSourceLine.SalesLineVerifyChange(Rec,xRec);
                  if not FullReservedQtyIsForAsmToOrder then
                    ReserveSalesLine.VerifyChange(Rec,xRec);
                end;
            end;
        }
        field(74;"Gen. Bus. Posting Group";Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";

            trigger OnValidate()
            begin
                if xRec."Gen. Bus. Posting Group" <> "Gen. Bus. Posting Group" then
                  if GenBusPostingGrp.ValidateVatBusPostingGroup(GenBusPostingGrp,"Gen. Bus. Posting Group") then
                    Validate("VAT Bus. Posting Group",GenBusPostingGrp."Def. VAT Bus. Posting Group");
            end;
        }
        field(75;"Gen. Prod. Posting Group";Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";

            trigger OnValidate()
            begin
                TestJobPlanningLine;
                TestStatusOpen;
                if xRec."Gen. Prod. Posting Group" <> "Gen. Prod. Posting Group" then
                  if GenProdPostingGrp.ValidateVatProdPostingGroup(GenProdPostingGrp,"Gen. Prod. Posting Group") then
                    Validate("VAT Prod. Posting Group",GenProdPostingGrp."Def. VAT Prod. Posting Group");
            end;
        }
        field(77;"VAT Calculation Type";Option)
        {
            Caption = 'VAT Calculation Type';
            Editable = false;
            OptionCaption = 'Normal VAT,Reverse Charge VAT,Full VAT,Sales Tax';
            OptionMembers = "Normal VAT","Reverse Charge VAT","Full VAT","Sales Tax";
        }
        field(78;"Transaction Type";Code[10])
        {
            Caption = 'Transaction Type';
            TableRelation = "Transaction Type";
        }
        field(79;"Transport Method";Code[10])
        {
            Caption = 'Transport Method';
            TableRelation = "Transport Method";
        }
        field(80;"Attached to Line No.";Integer)
        {
            Caption = 'Attached to Line No.';
            Editable = false;
            TableRelation = "Sales Line"."Line No." WHERE ("Document Type"=FIELD("Document Type"),
                                                           "Document No."=FIELD("Document No."));
        }
        field(81;"Exit Point";Code[10])
        {
            Caption = 'Exit Point';
            TableRelation = "Entry/Exit Point";
        }
        field(82;"Area";Code[10])
        {
            Caption = 'Area';
            TableRelation = Area;
        }
        field(83;"Transaction Specification";Code[10])
        {
            Caption = 'Transaction Specification';
            TableRelation = "Transaction Specification";
        }
        field(84;"Tax Category";Code[10])
        {
            Caption = 'Tax Category';
        }
        field(85;"Tax Area Code";Code[20])
        {
            Caption = 'Tax Area Code';
            TableRelation = "Tax Area";

            trigger OnValidate()
            begin
                UpdateAmounts;
            end;
        }
        field(86;"Tax Liable";Boolean)
        {
            Caption = 'Tax Liable';

            trigger OnValidate()
            begin
                UpdateAmounts;
            end;
        }
        field(87;"Tax Group Code";Code[20])
        {
            Caption = 'Tax Group Code';
            TableRelation = "Tax Group";

            trigger OnValidate()
            begin
                TestStatusOpen;
                ValidateTaxGroupCode;
                UpdateAmounts;
            end;
        }
        field(88;"VAT Clause Code";Code[20])
        {
            Caption = 'VAT Clause Code';
            TableRelation = "VAT Clause";
        }
        field(89;"VAT Bus. Posting Group";Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";

            trigger OnValidate()
            begin
                Validate("VAT Prod. Posting Group");
            end;
        }
        field(90;"VAT Prod. Posting Group";Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";

            trigger OnValidate()
            begin
                TestStatusOpen;
                VATPostingSetup.Get("VAT Bus. Posting Group","VAT Prod. Posting Group");
                "VAT Difference" := 0;

                GetSalesHeader;
                "VAT %" := VATPostingSetup."VAT %";
                "VAT Calculation Type" := VATPostingSetup."VAT Calculation Type";
                "VAT Identifier" := VATPostingSetup."VAT Identifier";
                "VAT Clause Code" := VATPostingSetup."VAT Clause Code";
                case "VAT Calculation Type" of
                  "VAT Calculation Type"::"Reverse Charge VAT",
                  "VAT Calculation Type"::"Sales Tax":
                    "VAT %" := 0;
                  "VAT Calculation Type"::"Full VAT":
                    begin
                      TestField(Type,Type::"G/L Account");
                      TestField("No.",VATPostingSetup.GetSalesAccount(false));
                    end;
                end;
                if SalesHeader."Prices Including VAT" and (Type in [Type::Item,Type::Resource]) then
                  "Unit Price" :=
                    Round(
                      "Unit Price" * (100 + "VAT %") / (100 + xRec."VAT %"),
                      Currency."Unit-Amount Rounding Precision");
                UpdateAmounts;
            end;
        }
        field(91;"Currency Code";Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
            TableRelation = Currency;
        }
        field(92;"Outstanding Amount (LCY)";Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Outstanding Amount (LCY)';
            Editable = false;
        }
        field(93;"Shipped Not Invoiced (LCY)";Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Shipped Not Invoiced (LCY) Incl. VAT';
            Editable = false;
        }
        field(94;"Shipped Not Inv. (LCY) No VAT";Decimal)
        {
            Caption = 'Shipped Not Invoiced (LCY)';
            Editable = false;
            FieldClass = Normal;
        }
        field(95;"Reserved Quantity";Decimal)
        {
            AccessByPermission = TableData "Sales Shipment Header"=R;
            CalcFormula = -Sum("Reservation Entry".Quantity WHERE ("Source ID"=FIELD("Document No."),
                                                                   "Source Ref. No."=FIELD("Line No."),
                                                                   "Source Type"=CONST(37),
                                                                   "Source Subtype"=FIELD("Document Type"),
                                                                   "Reservation Status"=CONST(Reservation)));
            Caption = 'Reserved Quantity';
            DecimalPlaces = 0:5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(96;Reserve;Option)
        {
            AccessByPermission = TableData Item=R;
            Caption = 'Reserve';
            OptionCaption = 'Never,Optional,Always';
            OptionMembers = Never,Optional,Always;

            trigger OnValidate()
            begin
                if Reserve <> Reserve::Never then begin
                  TestField(Type,Type::Item);
                  TestField("No.");
                end;
                CalcFields("Reserved Qty. (Base)");
                if (Reserve = Reserve::Never) and ("Reserved Qty. (Base)" > 0) then
                  TestField("Reserved Qty. (Base)",0);

                if "Drop Shipment" or "Special Order" then
                  TestField(Reserve,Reserve::Never);
                if xRec.Reserve = Reserve::Always then begin
                  GetItem;
                  if Item.Reserve = Item.Reserve::Always then
                    TestField(Reserve,Reserve::Always);
                end;
            end;
        }
        field(97;"Blanket Order No.";Code[20])
        {
            AccessByPermission = TableData "Sales Shipment Header"=R;
            Caption = 'Blanket Order No.';
            TableRelation = "Sales Header"."No." WHERE ("Document Type"=CONST("Blanket Order"));
            //This property is currently not supported
            //TestTableRelation = false;

            trigger OnLookup()
            begin
                BlanketOrderLookup;
            end;

            trigger OnValidate()
            begin
                TestField("Quantity Shipped",0);
                if "Blanket Order No." = '' then
                  "Blanket Order Line No." := 0
                else
                  Validate("Blanket Order Line No.");
            end;
        }
        field(98;"Blanket Order Line No.";Integer)
        {
            AccessByPermission = TableData "Sales Shipment Header"=R;
            Caption = 'Blanket Order Line No.';
            TableRelation = "Sales Line"."Line No." WHERE ("Document Type"=CONST("Blanket Order"),
                                                           "Document No."=FIELD("Blanket Order No."));
            //This property is currently not supported
            //TestTableRelation = false;

            trigger OnLookup()
            begin
                BlanketOrderLookup;
            end;

            trigger OnValidate()
            begin
                TestField("Quantity Shipped",0);
                if "Blanket Order Line No." <> 0 then begin
                  SalesLine2.Get("Document Type"::"Blanket Order","Blanket Order No.","Blanket Order Line No.");
                  SalesLine2.TestField(Type,Type);
                  SalesLine2.TestField("No.","No.");
                  SalesLine2.TestField("Bill-to Customer No.","Bill-to Customer No.");
                  SalesLine2.TestField("Sell-to Customer No.","Sell-to Customer No.");
                  if "Drop Shipment" then begin
                    SalesLine2.TestField("Variant Code","Variant Code");
                    SalesLine2.TestField("Location Code","Location Code");
                    SalesLine2.TestField("Unit of Measure Code","Unit of Measure Code");
                  end else begin
                    Validate("Variant Code",SalesLine2."Variant Code");
                    Validate("Location Code",SalesLine2."Location Code");
                    Validate("Unit of Measure Code",SalesLine2."Unit of Measure Code");
                  end;
                  Validate("Unit Price",SalesLine2."Unit Price");
                  Validate("Line Discount %",SalesLine2."Line Discount %");
                end;
            end;
        }
        field(99;"VAT Base Amount";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'VAT Base Amount';
            Editable = false;
        }
        field(100;"Unit Cost";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Cost';
            Editable = false;
        }
        field(101;"System-Created Entry";Boolean)
        {
            Caption = 'System-Created Entry';
            Editable = false;
        }
        field(103;"Line Amount";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CaptionClass = GetCaptionClass(FieldNo("Line Amount"));
            Caption = 'Line Amount';

            trigger OnValidate()
            var
                MaxLineAmount: Decimal;
            begin
                TestField(Type);
                TestField(Quantity);
                TestField("Unit Price");
                GetSalesHeader;

                "Line Amount" := Round("Line Amount",Currency."Amount Rounding Precision");
                MaxLineAmount := Round(Quantity * "Unit Price",Currency."Amount Rounding Precision");

                if "Line Amount" < 0 then
                  if "Line Amount" < MaxLineAmount then
                    Error(LineAmountInvalidErr);

                if "Line Amount" > 0 then
                  if "Line Amount" > MaxLineAmount then
                    Error(LineAmountInvalidErr);

                Validate("Line Discount Amount",MaxLineAmount - "Line Amount");
            end;
        }
        field(104;"VAT Difference";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'VAT Difference';
            Editable = false;
        }
        field(105;"Inv. Disc. Amount to Invoice";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Inv. Disc. Amount to Invoice';
            Editable = false;
        }
        field(106;"VAT Identifier";Code[20])
        {
            Caption = 'VAT Identifier';
            Editable = false;
        }
        field(107;"IC Partner Ref. Type";Option)
        {
            AccessByPermission = TableData "IC G/L Account"=R;
            Caption = 'IC Partner Ref. Type';
            OptionCaption = ' ,G/L Account,Item,,,Charge (Item),Cross Reference,Common Item No.';
            OptionMembers = " ","G/L Account",Item,,,"Charge (Item)","Cross Reference","Common Item No.";

            trigger OnValidate()
            begin
                if "IC Partner Code" <> '' then
                  "IC Partner Ref. Type" := "IC Partner Ref. Type"::"G/L Account";
                if "IC Partner Ref. Type" <> xRec."IC Partner Ref. Type" then
                  "IC Partner Reference" := '';
                if "IC Partner Ref. Type" = "IC Partner Ref. Type"::"Common Item No." then begin
                  if Item."No." <> "No." then
                    Item.Get("No.");
                  Item.TestField("Common Item No.");
                  "IC Partner Reference" := Item."Common Item No.";
                end;
            end;
        }
        field(108;"IC Partner Reference";Code[20])
        {
            AccessByPermission = TableData "IC G/L Account"=R;
            Caption = 'IC Partner Reference';

            trigger OnLookup()
            var
                ICGLAccount: Record "IC G/L Account";
                ItemCrossReference: Record "Item Cross Reference";
            begin
                if "No." <> '' then
                  case "IC Partner Ref. Type" of
                    "IC Partner Ref. Type"::"G/L Account":
                      begin
                        if ICGLAccount.Get("IC Partner Reference") then;
                        if PAGE.RunModal(PAGE::"IC G/L Account List",ICGLAccount) = ACTION::LookupOK then
                          Validate("IC Partner Reference",ICGLAccount."No.");
                      end;
                    "IC Partner Ref. Type"::Item:
                      begin
                        if Item.Get("IC Partner Reference") then;
                        if PAGE.RunModal(PAGE::"Item List",Item) = ACTION::LookupOK then
                          Validate("IC Partner Reference",Item."No.");
                      end;
                    "IC Partner Ref. Type"::"Cross Reference":
                      begin
                        ItemCrossReference.Reset;
                        ItemCrossReference.SetCurrentKey("Cross-Reference Type","Cross-Reference Type No.");
                        ItemCrossReference.SetFilter(
                          "Cross-Reference Type",'%1|%2',
                          ItemCrossReference."Cross-Reference Type"::Customer,
                          ItemCrossReference."Cross-Reference Type"::" ");
                        ItemCrossReference.SetFilter("Cross-Reference Type No.",'%1|%2',"Sell-to Customer No.",'');
                        if PAGE.RunModal(PAGE::"Cross Reference List",ItemCrossReference) = ACTION::LookupOK then
                          Validate("IC Partner Reference",ItemCrossReference."Cross-Reference No.");
                      end;
                  end;
            end;
        }
        field(109;"Prepayment %";Decimal)
        {
            Caption = 'Prepayment %';
            DecimalPlaces = 0:5;
            MaxValue = 100;
            MinValue = 0;

            trigger OnValidate()
            begin
                TestStatusOpen;
                UpdatePrepmtSetupFields;

                if HasTypeToFillMandatoryFields then
                  UpdateAmounts;
            end;
        }
        field(110;"Prepmt. Line Amount";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CaptionClass = GetCaptionClass(FieldNo("Prepmt. Line Amount"));
            Caption = 'Prepmt. Line Amount';
            MinValue = 0;

            trigger OnValidate()
            begin
                TestStatusOpen;
                PrePaymentLineAmountEntered := true;
                TestField("Line Amount");
                if "Prepmt. Line Amount" < "Prepmt. Amt. Inv." then
                  FieldError("Prepmt. Line Amount",StrSubstNo(Text044,"Prepmt. Amt. Inv."));
                if "Prepmt. Line Amount" > "Line Amount" then
                  FieldError("Prepmt. Line Amount",StrSubstNo(Text045,"Line Amount"));
                if "System-Created Entry" and not IsServiceCharge then
                  FieldError("Prepmt. Line Amount",StrSubstNo(Text045,0));
                Validate("Prepayment %",Round("Prepmt. Line Amount" * 100 / "Line Amount",0.00001));
            end;
        }
        field(111;"Prepmt. Amt. Inv.";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CaptionClass = GetCaptionClass(FieldNo("Prepmt. Amt. Inv."));
            Caption = 'Prepmt. Amt. Inv.';
            Editable = false;
        }
        field(112;"Prepmt. Amt. Incl. VAT";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Prepmt. Amt. Incl. VAT';
            Editable = false;
        }
        field(113;"Prepayment Amount";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Prepayment Amount';
            Editable = false;
        }
        field(114;"Prepmt. VAT Base Amt.";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Prepmt. VAT Base Amt.';
            Editable = false;
        }
        field(115;"Prepayment VAT %";Decimal)
        {
            Caption = 'Prepayment VAT %';
            DecimalPlaces = 0:5;
            Editable = false;
            MinValue = 0;
        }
        field(116;"Prepmt. VAT Calc. Type";Option)
        {
            Caption = 'Prepmt. VAT Calc. Type';
            Editable = false;
            OptionCaption = 'Normal VAT,Reverse Charge VAT,Full VAT,Sales Tax';
            OptionMembers = "Normal VAT","Reverse Charge VAT","Full VAT","Sales Tax";
        }
        field(117;"Prepayment VAT Identifier";Code[20])
        {
            Caption = 'Prepayment VAT Identifier';
            Editable = false;
        }
        field(118;"Prepayment Tax Area Code";Code[20])
        {
            Caption = 'Prepayment Tax Area Code';
            TableRelation = "Tax Area";

            trigger OnValidate()
            begin
                UpdateAmounts;
            end;
        }
        field(119;"Prepayment Tax Liable";Boolean)
        {
            Caption = 'Prepayment Tax Liable';

            trigger OnValidate()
            begin
                UpdateAmounts;
            end;
        }
        field(120;"Prepayment Tax Group Code";Code[20])
        {
            Caption = 'Prepayment Tax Group Code';
            TableRelation = "Tax Group";

            trigger OnValidate()
            begin
                TestStatusOpen;
                UpdateAmounts;
            end;
        }
        field(121;"Prepmt Amt to Deduct";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CaptionClass = GetCaptionClass(FieldNo("Prepmt Amt to Deduct"));
            Caption = 'Prepmt Amt to Deduct';
            MinValue = 0;

            trigger OnValidate()
            begin
                if "Prepmt Amt to Deduct" > "Prepmt. Amt. Inv." - "Prepmt Amt Deducted" then
                  FieldError(
                    "Prepmt Amt to Deduct",
                    StrSubstNo(Text045,"Prepmt. Amt. Inv." - "Prepmt Amt Deducted"));

                if "Prepmt Amt to Deduct" > "Qty. to Invoice" * "Unit Price" then
                  FieldError(
                    "Prepmt Amt to Deduct",
                    StrSubstNo(Text045,"Qty. to Invoice" * "Unit Price"));

                if ("Prepmt. Amt. Inv." - "Prepmt Amt to Deduct" - "Prepmt Amt Deducted") >
                   (Quantity - "Qty. to Invoice" - "Quantity Invoiced") * "Unit Price"
                then
                  FieldError(
                    "Prepmt Amt to Deduct",
                    StrSubstNo(Text044,
                      "Prepmt. Amt. Inv." - "Prepmt Amt Deducted" - (Quantity - "Qty. to Invoice" - "Quantity Invoiced") * "Unit Price"));
            end;
        }
        field(122;"Prepmt Amt Deducted";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CaptionClass = GetCaptionClass(FieldNo("Prepmt Amt Deducted"));
            Caption = 'Prepmt Amt Deducted';
            Editable = false;
        }
        field(123;"Prepayment Line";Boolean)
        {
            Caption = 'Prepayment Line';
            Editable = false;
        }
        field(124;"Prepmt. Amount Inv. Incl. VAT";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Prepmt. Amount Inv. Incl. VAT';
            Editable = false;
        }
        field(129;"Prepmt. Amount Inv. (LCY)";Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Prepmt. Amount Inv. (LCY)';
            Editable = false;
        }
        field(130;"IC Partner Code";Code[20])
        {
            Caption = 'IC Partner Code';
            TableRelation = "IC Partner";

            trigger OnValidate()
            begin
                if "IC Partner Code" <> '' then begin
                  TestField(Type,Type::"G/L Account");
                  GetSalesHeader;
                  SalesHeader.TestField("Sell-to IC Partner Code",'');
                  SalesHeader.TestField("Bill-to IC Partner Code",'');
                  Validate("IC Partner Ref. Type","IC Partner Ref. Type"::"G/L Account");
                end;
            end;
        }
        field(132;"Prepmt. VAT Amount Inv. (LCY)";Decimal)
        {
            Caption = 'Prepmt. VAT Amount Inv. (LCY)';
            Editable = false;
        }
        field(135;"Prepayment VAT Difference";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Prepayment VAT Difference';
            Editable = false;
        }
        field(136;"Prepmt VAT Diff. to Deduct";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Prepmt VAT Diff. to Deduct';
            Editable = false;
        }
        field(137;"Prepmt VAT Diff. Deducted";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Prepmt VAT Diff. Deducted';
            Editable = false;
        }
        field(145;"Pmt. Discount Amount";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Pmt. Discount Amount';

            trigger OnValidate()
            begin
                TestField(Quantity);
                UpdateAmounts;
            end;
        }
        field(180;"Line Discount Calculation";Option)
        {
            Caption = 'Line Discount Calculation';
            OptionCaption = 'None,%,Amount';
            OptionMembers = "None","%",Amount;
        }
        field(480;"Dimension Set ID";Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDimensions;
            end;

            trigger OnValidate()
            begin
                DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID","Shortcut Dimension 1 Code","Shortcut Dimension 2 Code");
            end;
        }
        field(900;"Qty. to Assemble to Order";Decimal)
        {
            AccessByPermission = TableData "BOM Component"=R;
            Caption = 'Qty. to Assemble to Order';
            DecimalPlaces = 0:5;

            trigger OnValidate()
            var
                SalesLineReserve: Codeunit "Sales Line-Reserve";
            begin
                WhseValidateSourceLine.SalesLineVerifyChange(Rec,xRec);

                "Qty. to Asm. to Order (Base)" := CalcBaseQty("Qty. to Assemble to Order");

                if "Qty. to Asm. to Order (Base)" <> 0 then begin
                  TestField("Drop Shipment",false);
                  TestField("Special Order",false);
                  if "Qty. to Asm. to Order (Base)" < 0 then
                    FieldError("Qty. to Assemble to Order",StrSubstNo(Text009,FieldCaption("Quantity (Base)"),"Quantity (Base)"));
                  TestField("Appl.-to Item Entry",0);

                  case "Document Type" of
                    "Document Type"::"Blanket Order",
                    "Document Type"::Quote:
                      if ("Quantity (Base)" = 0) or ("Qty. to Asm. to Order (Base)" <= 0) or SalesLineReserve.ReservEntryExist(Rec) then
                        TestField("Qty. to Asm. to Order (Base)",0)
                      else
                        if "Quantity (Base)" <> "Qty. to Asm. to Order (Base)" then
                          FieldError("Qty. to Assemble to Order",StrSubstNo(Text031,0,"Quantity (Base)"));
                    "Document Type"::Order:
                      ;
                    else
                      TestField("Qty. to Asm. to Order (Base)",0);
                  end;
                end;

                CheckItemAvailable(FieldNo("Qty. to Assemble to Order"));
                if not (CurrFieldNo in [FieldNo(Quantity),FieldNo("Qty. to Assemble to Order")]) then
                  GetDefaultBin;
                AutoAsmToOrder;
            end;
        }
        field(901;"Qty. to Asm. to Order (Base)";Decimal)
        {
            Caption = 'Qty. to Asm. to Order (Base)';
            DecimalPlaces = 0:5;

            trigger OnValidate()
            begin
                TestField("Qty. per Unit of Measure",1);
                Validate("Qty. to Assemble to Order","Qty. to Asm. to Order (Base)");
            end;
        }
        field(902;"ATO Whse. Outstanding Qty.";Decimal)
        {
            AccessByPermission = TableData "BOM Component"=R;
            BlankZero = true;
            CalcFormula = Sum("Warehouse Shipment Line"."Qty. Outstanding" WHERE ("Source Type"=CONST(37),
                                                                                  "Source Subtype"=FIELD("Document Type"),
                                                                                  "Source No."=FIELD("Document No."),
                                                                                  "Source Line No."=FIELD("Line No."),
                                                                                  "Assemble to Order"=FILTER(true)));
            Caption = 'ATO Whse. Outstanding Qty.';
            DecimalPlaces = 0:5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(903;"ATO Whse. Outstd. Qty. (Base)";Decimal)
        {
            AccessByPermission = TableData "BOM Component"=R;
            BlankZero = true;
            CalcFormula = Sum("Warehouse Shipment Line"."Qty. Outstanding (Base)" WHERE ("Source Type"=CONST(37),
                                                                                         "Source Subtype"=FIELD("Document Type"),
                                                                                         "Source No."=FIELD("Document No."),
                                                                                         "Source Line No."=FIELD("Line No."),
                                                                                         "Assemble to Order"=FILTER(true)));
            Caption = 'ATO Whse. Outstd. Qty. (Base)';
            DecimalPlaces = 0:5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(1001;"Job Task No.";Code[20])
        {
            Caption = 'Job Task No.';
            Editable = false;
            TableRelation = "Job Task"."Job Task No." WHERE ("Job No."=FIELD("Job No."));
        }
        field(1002;"Job Contract Entry No.";Integer)
        {
            AccessByPermission = TableData Job=R;
            Caption = 'Job Contract Entry No.';
            Editable = false;

            trigger OnValidate()
            var
                JobPlanningLine: Record "Job Planning Line";
            begin
                JobPlanningLine.SetCurrentKey("Job Contract Entry No.");
                JobPlanningLine.SetRange("Job Contract Entry No.","Job Contract Entry No.");
                JobPlanningLine.FindFirst;
                CreateDim(
                  DimMgt.TypeToTableID3(Type),"No.",
                  DATABASE::Job,JobPlanningLine."Job No.",
                  DATABASE::"Responsibility Center","Responsibility Center");
            end;
        }
        field(1300;"Posting Date";Date)
        {
            CalcFormula = Lookup("Sales Header"."Posting Date" WHERE ("Document Type"=FIELD("Document Type"),
                                                                      "No."=FIELD("Document No.")));
            Caption = 'Posting Date';
            FieldClass = FlowField;
        }
        field(1700;"Deferral Code";Code[10])
        {
            Caption = 'Deferral Code';
            TableRelation = "Deferral Template"."Deferral Code";

            trigger OnValidate()
            var
                DeferralPostDate: Date;
            begin
                GetSalesHeader;
                OnGetDeferralPostDate(SalesHeader,DeferralPostDate);
                if DeferralPostDate = 0D then
                  DeferralPostDate := SalesHeader."Posting Date";

                DeferralUtilities.DeferralCodeOnValidate(
                  "Deferral Code",DeferralUtilities.GetSalesDeferralDocType,'','',
                  "Document Type","Document No.","Line No.",
                  GetDeferralAmount,DeferralPostDate,
                  Description,SalesHeader."Currency Code");

                if "Document Type" = "Document Type"::"Return Order" then
                  "Returns Deferral Start Date" :=
                    DeferralUtilities.GetDeferralStartDate(DeferralUtilities.GetSalesDeferralDocType,
                      "Document Type","Document No.","Line No.","Deferral Code",SalesHeader."Posting Date");
            end;
        }
        field(1702;"Returns Deferral Start Date";Date)
        {
            Caption = 'Returns Deferral Start Date';

            trigger OnValidate()
            var
                DeferralHeader: Record "Deferral Header";
            begin
                GetSalesHeader;
                if DeferralHeader.Get(DeferralUtilities.GetSalesDeferralDocType,'','',"Document Type","Document No.","Line No.") then
                  DeferralUtilities.CreateDeferralSchedule("Deferral Code",DeferralUtilities.GetSalesDeferralDocType,'','',
                    "Document Type","Document No.","Line No.",GetDeferralAmount,
                    DeferralHeader."Calc. Method","Returns Deferral Start Date",
                    DeferralHeader."No. of Periods",true,
                    DeferralHeader."Schedule Description",false,
                    SalesHeader."Currency Code");
            end;
        }
        field(5402;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = IF (Type=CONST(Item)) "Item Variant".Code WHERE ("Item No."=FIELD("No."));

            trigger OnValidate()
            begin
                TestJobPlanningLine;
                if "Variant Code" <> '' then
                  TestField(Type,Type::Item);
                TestStatusOpen;
                CheckAssocPurchOrder(FieldCaption("Variant Code"));

                if xRec."Variant Code" <> "Variant Code" then begin
                  TestField("Qty. Shipped Not Invoiced",0);
                  TestField("Shipment No.",'');

                  TestField("Return Qty. Rcd. Not Invd.",0);
                  TestField("Return Receipt No.",'');
                  InitItemAppl(false);
                end;

                CheckItemAvailable(FieldNo("Variant Code"));

                if Type = Type::Item then begin
                  GetUnitCost;
                  UpdateUnitPrice(FieldNo("Variant Code"));
                end;

                GetDefaultBin;
                InitQtyToAsm;
                AutoAsmToOrder;
                if (xRec."Variant Code" <> "Variant Code") and (Quantity <> 0) then begin
                  if not FullReservedQtyIsForAsmToOrder then
                    ReserveSalesLine.VerifyChange(Rec,xRec);
                  WhseValidateSourceLine.SalesLineVerifyChange(Rec,xRec);
                end;

                UpdateItemCrossRef;
            end;
        }
        field(5403;"Bin Code";Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = IF ("Document Type"=FILTER(Order|Invoice),
                                Quantity=FILTER(>=0),
                                "Qty. to Asm. to Order (Base)"=CONST(0)) "Bin Content"."Bin Code" WHERE ("Location Code"=FIELD("Location Code"),
                                                                                                         "Item No."=FIELD("No."),
                                                                                                         "Variant Code"=FIELD("Variant Code"))
                                                                                                         ELSE IF ("Document Type"=FILTER("Return Order"|"Credit Memo"),
                                                                                                                  Quantity=FILTER(<0)) "Bin Content"."Bin Code" WHERE ("Location Code"=FIELD("Location Code"),
                                                                                                                                                                       "Item No."=FIELD("No."),
                                                                                                                                                                       "Variant Code"=FIELD("Variant Code"))
                                                                                                                                                                       ELSE Bin.Code WHERE ("Location Code"=FIELD("Location Code"));

            trigger OnLookup()
            var
                WMSManagement: Codeunit "WMS Management";
                BinCode: Code[20];
            begin
                if not IsInbound and ("Quantity (Base)" <> 0) then
                  BinCode := WMSManagement.BinContentLookUp("Location Code","No.","Variant Code",'',"Bin Code")
                else
                  BinCode := WMSManagement.BinLookUp("Location Code","No.","Variant Code",'');

                if BinCode <> '' then
                  Validate("Bin Code",BinCode);
            end;

            trigger OnValidate()
            var
                WMSManagement: Codeunit "WMS Management";
            begin
                if "Bin Code" <> '' then begin
                  if not IsInbound and ("Quantity (Base)" <> 0) and ("Qty. to Asm. to Order (Base)" = 0) then
                    WMSManagement.FindBinContent("Location Code","Bin Code","No.","Variant Code",'')
                  else
                    WMSManagement.FindBin("Location Code","Bin Code",'');
                end;

                if "Drop Shipment" then
                  CheckAssocPurchOrder(FieldCaption("Bin Code"));

                TestField(Type,Type::Item);
                TestField("Location Code");

                if (Type = Type::Item) and ("Bin Code" <> '') then begin
                  TestField("Drop Shipment",false);
                  GetLocation("Location Code");
                  Location.TestField("Bin Mandatory");
                  CheckWarehouse;
                end;
                ATOLink.UpdateAsmBinCodeFromSalesLine(Rec);
            end;
        }
        field(5404;"Qty. per Unit of Measure";Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0:5;
            Editable = false;
            InitValue = 1;
        }
        field(5405;Planned;Boolean)
        {
            Caption = 'Planned';
            Editable = false;
        }
        field(5407;"Unit of Measure Code";Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = IF (Type=CONST(Item),
                                "No."=FILTER(<>'')) "Item Unit of Measure".Code WHERE ("Item No."=FIELD("No."))
                                ELSE IF (Type=CONST(Resource),
                                         "No."=FILTER(<>'')) "Resource Unit of Measure".Code WHERE ("Resource No."=FIELD("No."))
                                         ELSE "Unit of Measure";

            trigger OnValidate()
            var
                UnitOfMeasureTranslation: Record "Unit of Measure Translation";
                ResUnitofMeasure: Record "Resource Unit of Measure";
                IdentityManagement: Codeunit "Identity Management";
            begin
                TestJobPlanningLine;
                TestStatusOpen;
                TestField("Quantity Shipped",0);
                TestField("Qty. Shipped (Base)",0);
                TestField("Return Qty. Received",0);
                TestField("Return Qty. Received (Base)",0);
                if "Unit of Measure Code" <> xRec."Unit of Measure Code" then begin
                  TestField("Shipment No.",'');
                  TestField("Return Receipt No.",'');
                end;

                CheckAssocPurchOrder(FieldCaption("Unit of Measure Code"));

                if "Unit of Measure Code" = '' then
                  "Unit of Measure" := ''
                else begin
                  if not UnitOfMeasure.Get("Unit of Measure Code") then
                    UnitOfMeasure.Init;
                  "Unit of Measure" := UnitOfMeasure.Description;
                  GetSalesHeader;
                  if SalesHeader."Language Code" <> '' then begin
                    UnitOfMeasureTranslation.SetRange(Code,"Unit of Measure Code");
                    UnitOfMeasureTranslation.SetRange("Language Code",SalesHeader."Language Code");
                    if UnitOfMeasureTranslation.FindFirst then
                      "Unit of Measure" := UnitOfMeasureTranslation.Description;
                  end else
                    if IdentityManagement.IsInvAppId then
                      "Unit of Measure" := UnitOfMeasure.GetDescriptionInCurrentLanguage;
                end;
                DistIntegration.EnterSalesItemCrossRef(Rec);
                case Type of
                  Type::Item:
                    begin
                      GetItem;
                      GetUnitCost;
                      UpdateUnitPrice(FieldNo("Unit of Measure Code"));
                      CheckItemAvailable(FieldNo("Unit of Measure Code"));
                      "Gross Weight" := Item."Gross Weight" * "Qty. per Unit of Measure";
                      "Net Weight" := Item."Net Weight" * "Qty. per Unit of Measure";
                      "Unit Volume" := Item."Unit Volume" * "Qty. per Unit of Measure";
                      "Units per Parcel" := Round(Item."Units per Parcel" / "Qty. per Unit of Measure",0.00001);
                      OnAfterAssignItemUOM(Rec,Item);
                      if (xRec."Unit of Measure Code" <> "Unit of Measure Code") and (Quantity <> 0) then
                        WhseValidateSourceLine.SalesLineVerifyChange(Rec,xRec);
                      if "Qty. per Unit of Measure" > xRec."Qty. per Unit of Measure" then
                        InitItemAppl(false);
                    end;
                  Type::Resource:
                    begin
                      if "Unit of Measure Code" = '' then begin
                        GetResource;
                        "Unit of Measure Code" := Resource."Base Unit of Measure";
                      end;
                      ResUnitofMeasure.Get("No.","Unit of Measure Code");
                      "Qty. per Unit of Measure" := ResUnitofMeasure."Qty. per Unit of Measure";
                      OnAfterAssignResourceUOM(Rec,Resource,ResUnitofMeasure);
                      UpdateUnitPrice(FieldNo("Unit of Measure Code"));
                      FindResUnitCost;
                    end;
                  Type::"G/L Account",Type::"Fixed Asset",
                  Type::"Charge (Item)",Type::" ":
                    "Qty. per Unit of Measure" := 1;
                end;
                Validate(Quantity);
            end;
        }
        field(5415;"Quantity (Base)";Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0:5;

            trigger OnValidate()
            begin
                TestJobPlanningLine;
                TestField("Qty. per Unit of Measure",1);
                Validate(Quantity,"Quantity (Base)");
                UpdateUnitPrice(FieldNo("Quantity (Base)"));
            end;
        }
        field(5416;"Outstanding Qty. (Base)";Decimal)
        {
            Caption = 'Outstanding Qty. (Base)';
            DecimalPlaces = 0:5;
            Editable = false;
        }
        field(5417;"Qty. to Invoice (Base)";Decimal)
        {
            Caption = 'Qty. to Invoice (Base)';
            DecimalPlaces = 0:5;

            trigger OnValidate()
            begin
                TestField("Qty. per Unit of Measure",1);
                Validate("Qty. to Invoice","Qty. to Invoice (Base)");
            end;
        }
        field(5418;"Qty. to Ship (Base)";Decimal)
        {
            Caption = 'Qty. to Ship (Base)';
            DecimalPlaces = 0:5;

            trigger OnValidate()
            begin
                TestField("Qty. per Unit of Measure",1);
                Validate("Qty. to Ship","Qty. to Ship (Base)");
            end;
        }
        field(5458;"Qty. Shipped Not Invd. (Base)";Decimal)
        {
            Caption = 'Qty. Shipped Not Invd. (Base)';
            DecimalPlaces = 0:5;
            Editable = false;
        }
        field(5460;"Qty. Shipped (Base)";Decimal)
        {
            Caption = 'Qty. Shipped (Base)';
            DecimalPlaces = 0:5;
            Editable = false;
        }
        field(5461;"Qty. Invoiced (Base)";Decimal)
        {
            Caption = 'Qty. Invoiced (Base)';
            DecimalPlaces = 0:5;
            Editable = false;
        }
        field(5495;"Reserved Qty. (Base)";Decimal)
        {
            AccessByPermission = TableData "Sales Shipment Header"=R;
            CalcFormula = -Sum("Reservation Entry"."Quantity (Base)" WHERE ("Source ID"=FIELD("Document No."),
                                                                            "Source Ref. No."=FIELD("Line No."),
                                                                            "Source Type"=CONST(37),
                                                                            "Source Subtype"=FIELD("Document Type"),
                                                                            "Reservation Status"=CONST(Reservation)));
            Caption = 'Reserved Qty. (Base)';
            DecimalPlaces = 0:5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5600;"FA Posting Date";Date)
        {
            AccessByPermission = TableData "Fixed Asset"=R;
            Caption = 'FA Posting Date';
        }
        field(5602;"Depreciation Book Code";Code[10])
        {
            Caption = 'Depreciation Book Code';
            TableRelation = "Depreciation Book";

            trigger OnValidate()
            begin
                GetFAPostingGroup;
            end;
        }
        field(5605;"Depr. until FA Posting Date";Boolean)
        {
            AccessByPermission = TableData "Fixed Asset"=R;
            Caption = 'Depr. until FA Posting Date';
        }
        field(5612;"Duplicate in Depreciation Book";Code[10])
        {
            Caption = 'Duplicate in Depreciation Book';
            TableRelation = "Depreciation Book";

            trigger OnValidate()
            begin
                "Use Duplication List" := false;
            end;
        }
        field(5613;"Use Duplication List";Boolean)
        {
            AccessByPermission = TableData "Fixed Asset"=R;
            Caption = 'Use Duplication List';

            trigger OnValidate()
            begin
                "Duplicate in Depreciation Book" := '';
            end;
        }
        field(5700;"Responsibility Center";Code[10])
        {
            Caption = 'Responsibility Center';
            Editable = false;
            TableRelation = "Responsibility Center";

            trigger OnValidate()
            begin
                CreateDim(
                  DATABASE::"Responsibility Center","Responsibility Center",
                  DimMgt.TypeToTableID3(Type),"No.",
                  DATABASE::Job,"Job No.");
            end;
        }
        field(5701;"Out-of-Stock Substitution";Boolean)
        {
            Caption = 'Out-of-Stock Substitution';
            Editable = false;
        }
        field(5702;"Substitution Available";Boolean)
        {
            CalcFormula = Exist("Item Substitution" WHERE (Type=CONST(Item),
                                                           "No."=FIELD("No."),
                                                           "Substitute Type"=CONST(Item)));
            Caption = 'Substitution Available';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5703;"Originally Ordered No.";Code[20])
        {
            AccessByPermission = TableData "Item Substitution"=R;
            Caption = 'Originally Ordered No.';
            TableRelation = IF (Type=CONST(Item)) Item;
        }
        field(5704;"Originally Ordered Var. Code";Code[10])
        {
            AccessByPermission = TableData "Item Substitution"=R;
            Caption = 'Originally Ordered Var. Code';
            TableRelation = IF (Type=CONST(Item)) "Item Variant".Code WHERE ("Item No."=FIELD("Originally Ordered No."));
        }
        field(5705;"Cross-Reference No.";Code[20])
        {
            AccessByPermission = TableData "Item Cross Reference"=R;
            Caption = 'Cross-Reference No.';

            trigger OnLookup()
            begin
                CrossReferenceNoLookUp;
            end;

            trigger OnValidate()
            var
                ReturnedCrossRef: Record "Item Cross Reference";
            begin
                GetSalesHeader;
                "Sell-to Customer No." := SalesHeader."Sell-to Customer No.";
                ReturnedCrossRef.Init;
                if "Cross-Reference No." <> '' then begin
                  DistIntegration.ICRLookupSalesItem(Rec,ReturnedCrossRef,CurrFieldNo <> 0);
                  if "No." <> ReturnedCrossRef."Item No." then
                    Validate("No.",ReturnedCrossRef."Item No.");
                  if ReturnedCrossRef."Variant Code" <> '' then
                    Validate("Variant Code",ReturnedCrossRef."Variant Code");

                  if ReturnedCrossRef."Unit of Measure" <> '' then
                    Validate("Unit of Measure Code",ReturnedCrossRef."Unit of Measure");
                end;

                "Unit of Measure (Cross Ref.)" := ReturnedCrossRef."Unit of Measure";
                "Cross-Reference Type" := ReturnedCrossRef."Cross-Reference Type";
                "Cross-Reference Type No." := ReturnedCrossRef."Cross-Reference Type No.";
                "Cross-Reference No." := ReturnedCrossRef."Cross-Reference No.";

                if (ReturnedCrossRef.Description <> '') or (ReturnedCrossRef."Description 2" <> '') then begin
                  Description := ReturnedCrossRef.Description;
                  "Description 2" := ReturnedCrossRef."Description 2";
                end;

                UpdateUnitPrice(FieldNo("Cross-Reference No."));
                UpdateICPartner;
            end;
        }
        field(5706;"Unit of Measure (Cross Ref.)";Code[10])
        {
            AccessByPermission = TableData "Item Cross Reference"=R;
            Caption = 'Unit of Measure (Cross Ref.)';
            TableRelation = IF (Type=CONST(Item)) "Item Unit of Measure".Code WHERE ("Item No."=FIELD("No."));
        }
        field(5707;"Cross-Reference Type";Option)
        {
            Caption = 'Cross-Reference Type';
            OptionCaption = ' ,Customer,Vendor,Bar Code';
            OptionMembers = " ",Customer,Vendor,"Bar Code";
        }
        field(5708;"Cross-Reference Type No.";Code[30])
        {
            Caption = 'Cross-Reference Type No.';
        }
        field(5709;"Item Category Code";Code[20])
        {
            Caption = 'Item Category Code';
            TableRelation = "Item Category";
        }
        field(5710;Nonstock;Boolean)
        {
            AccessByPermission = TableData "Nonstock Item"=R;
            Caption = 'Catalog';
            Editable = false;
        }
        field(5711;"Purchasing Code";Code[10])
        {
            AccessByPermission = TableData "Drop Shpt. Post. Buffer"=R;
            Caption = 'Purchasing Code';
            TableRelation = Purchasing;

            trigger OnValidate()
            var
                PurchasingCode: Record Purchasing;
                ShippingAgentServices: Record "Shipping Agent Services";
            begin
                TestStatusOpen;
                TestField(Type,Type::Item);
                CheckAssocPurchOrder(FieldCaption(Type));

                if PurchasingCode.Get("Purchasing Code") then begin
                  "Drop Shipment" := PurchasingCode."Drop Shipment";
                  "Special Order" := PurchasingCode."Special Order";
                  if "Drop Shipment" or "Special Order" then begin
                    TestField("Qty. to Asm. to Order (Base)",0);
                    CalcFields("Reserved Qty. (Base)");
                    TestField("Reserved Qty. (Base)",0);
                    ReserveSalesLine.VerifyChange(Rec,xRec);

                    if (Quantity <> 0) and (Quantity = "Quantity Shipped") then
                      Error(SalesLineCompletelyShippedErr);
                    Reserve := Reserve::Never;
                    if "Drop Shipment" then begin
                      Evaluate("Outbound Whse. Handling Time",'<0D>');
                      Evaluate("Shipping Time",'<0D>');
                      UpdateDates;
                      "Bin Code" := '';
                    end;
                  end else
                    SetReserveWithoutPurchasingCode;
                end else begin
                  "Drop Shipment" := false;
                  "Special Order" := false;
                  SetReserveWithoutPurchasingCode;
                end;

                if ("Purchasing Code" <> xRec."Purchasing Code") and
                   (not "Drop Shipment") and
                   ("Drop Shipment" <> xRec."Drop Shipment")
                then begin
                  if "Location Code" = '' then begin
                    if InvtSetup.Get then
                      "Outbound Whse. Handling Time" := InvtSetup."Outbound Whse. Handling Time";
                  end else
                    if Location.Get("Location Code") then
                      "Outbound Whse. Handling Time" := Location."Outbound Whse. Handling Time";
                  if ShippingAgentServices.Get("Shipping Agent Code","Shipping Agent Service Code") then
                    "Shipping Time" := ShippingAgentServices."Shipping Time"
                  else begin
                    GetSalesHeader;
                    "Shipping Time" := SalesHeader."Shipping Time";
                  end;
                  UpdateDates;
                end;
            end;
        }
        field(5712;"Product Group Code";Code[10])
        {
            Caption = 'Product Group Code';
            ObsoleteReason = 'Product Groups became first level children of Item Categories.';
            ObsoleteState = Removed;
            TableRelation = "Product Group".Code WHERE ("Item Category Code"=FIELD("Item Category Code"));
            ValidateTableRelation = false;
        }
        field(5713;"Special Order";Boolean)
        {
            AccessByPermission = TableData "Drop Shpt. Post. Buffer"=R;
            Caption = 'Special Order';
            Editable = false;
        }
        field(5714;"Special Order Purchase No.";Code[20])
        {
            AccessByPermission = TableData "Drop Shpt. Post. Buffer"=R;
            Caption = 'Special Order Purchase No.';
            TableRelation = IF ("Special Order"=CONST(true)) "Purchase Header"."No." WHERE ("Document Type"=CONST(Order));
        }
        field(5715;"Special Order Purch. Line No.";Integer)
        {
            AccessByPermission = TableData "Drop Shpt. Post. Buffer"=R;
            Caption = 'Special Order Purch. Line No.';
            TableRelation = IF ("Special Order"=CONST(true)) "Purchase Line"."Line No." WHERE ("Document Type"=CONST(Order),
                                                                                               "Document No."=FIELD("Special Order Purchase No."));
        }
        field(5749;"Whse. Outstanding Qty.";Decimal)
        {
            AccessByPermission = TableData Location=R;
            BlankZero = true;
            CalcFormula = Sum("Warehouse Shipment Line"."Qty. Outstanding" WHERE ("Source Type"=CONST(37),
                                                                                  "Source Subtype"=FIELD("Document Type"),
                                                                                  "Source No."=FIELD("Document No."),
                                                                                  "Source Line No."=FIELD("Line No.")));
            Caption = 'Whse. Outstanding Qty.';
            DecimalPlaces = 0:5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5750;"Whse. Outstanding Qty. (Base)";Decimal)
        {
            AccessByPermission = TableData Location=R;
            BlankZero = true;
            CalcFormula = Sum("Warehouse Shipment Line"."Qty. Outstanding (Base)" WHERE ("Source Type"=CONST(37),
                                                                                         "Source Subtype"=FIELD("Document Type"),
                                                                                         "Source No."=FIELD("Document No."),
                                                                                         "Source Line No."=FIELD("Line No.")));
            Caption = 'Whse. Outstanding Qty. (Base)';
            DecimalPlaces = 0:5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5752;"Completely Shipped";Boolean)
        {
            Caption = 'Completely Shipped';
            Editable = false;
        }
        field(5790;"Requested Delivery Date";Date)
        {
            AccessByPermission = TableData "Order Promising Line"=R;
            Caption = 'Requested Delivery Date';

            trigger OnValidate()
            begin
                TestStatusOpen;
                if ("Requested Delivery Date" <> xRec."Requested Delivery Date") and
                   ("Promised Delivery Date" <> 0D)
                then
                  Error(
                    Text028,
                    FieldCaption("Requested Delivery Date"),
                    FieldCaption("Promised Delivery Date"));

                if "Requested Delivery Date" <> 0D then
                  Validate("Planned Delivery Date","Requested Delivery Date")
                else begin
                  GetSalesHeader;
                  Validate("Shipment Date",SalesHeader."Shipment Date");
                end;
            end;
        }
        field(5791;"Promised Delivery Date";Date)
        {
            AccessByPermission = TableData "Order Promising Line"=R;
            Caption = 'Promised Delivery Date';

            trigger OnValidate()
            begin
                TestStatusOpen;
                if "Promised Delivery Date" <> 0D then
                  Validate("Planned Delivery Date","Promised Delivery Date")
                else
                  Validate("Requested Delivery Date");
            end;
        }
        field(5792;"Shipping Time";DateFormula)
        {
            AccessByPermission = TableData "Order Promising Line"=R;
            Caption = 'Shipping Time';

            trigger OnValidate()
            begin
                TestStatusOpen;
                if "Drop Shipment" then
                  DateFormularZero("Shipping Time",FieldNo("Shipping Time"),FieldCaption("Shipping Time"));
                UpdateDates;
            end;
        }
        field(5793;"Outbound Whse. Handling Time";DateFormula)
        {
            AccessByPermission = TableData Location=R;
            Caption = 'Outbound Whse. Handling Time';

            trigger OnValidate()
            begin
                TestStatusOpen;
                if "Drop Shipment" then
                  DateFormularZero("Outbound Whse. Handling Time",
                    FieldNo("Outbound Whse. Handling Time"),FieldCaption("Outbound Whse. Handling Time"));
                UpdateDates;
            end;
        }
        field(5794;"Planned Delivery Date";Date)
        {
            AccessByPermission = TableData "Order Promising Line"=R;
            Caption = 'Planned Delivery Date';

            trigger OnValidate()
            begin
                TestStatusOpen;
                if "Planned Delivery Date" <> 0D then begin
                  PlannedDeliveryDateCalculated := true;

                  Validate("Planned Shipment Date",CalcPlannedDate);

                  if "Planned Shipment Date" > "Planned Delivery Date" then
                    "Planned Delivery Date" := "Planned Shipment Date";
                end;
            end;
        }
        field(5795;"Planned Shipment Date";Date)
        {
            AccessByPermission = TableData "Order Promising Line"=R;
            Caption = 'Planned Shipment Date';

            trigger OnValidate()
            begin
                TestStatusOpen;
                if "Planned Shipment Date" <> 0D then begin
                  PlannedShipmentDateCalculated := true;

                  Validate("Shipment Date",CalcShipmentDate);
                end;
            end;
        }
        field(5796;"Shipping Agent Code";Code[10])
        {
            AccessByPermission = TableData "Shipping Agent Services"=R;
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";

            trigger OnValidate()
            begin
                TestStatusOpen;
                if "Shipping Agent Code" <> xRec."Shipping Agent Code" then
                  Validate("Shipping Agent Service Code",'');
            end;
        }
        field(5797;"Shipping Agent Service Code";Code[10])
        {
            AccessByPermission = TableData "Shipping Agent Services"=R;
            Caption = 'Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services".Code WHERE ("Shipping Agent Code"=FIELD("Shipping Agent Code"));

            trigger OnValidate()
            var
                ShippingAgentServices: Record "Shipping Agent Services";
            begin
                TestStatusOpen;
                if "Shipping Agent Service Code" <> xRec."Shipping Agent Service Code" then
                  Evaluate("Shipping Time",'<>');

                if "Drop Shipment" then begin
                  Evaluate("Shipping Time",'<0D>');
                  UpdateDates;
                end else
                  if ShippingAgentServices.Get("Shipping Agent Code","Shipping Agent Service Code") then
                    "Shipping Time" := ShippingAgentServices."Shipping Time"
                  else begin
                    GetSalesHeader;
                    "Shipping Time" := SalesHeader."Shipping Time";
                  end;

                if ShippingAgentServices."Shipping Time" <> xRec."Shipping Time" then
                  Validate("Shipping Time","Shipping Time");
            end;
        }
        field(5800;"Allow Item Charge Assignment";Boolean)
        {
            AccessByPermission = TableData "Item Charge"=R;
            Caption = 'Allow Item Charge Assignment';
            InitValue = true;

            trigger OnValidate()
            begin
                CheckItemChargeAssgnt;
            end;
        }
        field(5801;"Qty. to Assign";Decimal)
        {
            CalcFormula = Sum("Item Charge Assignment (Sales)"."Qty. to Assign" WHERE ("Document Type"=FIELD("Document Type"),
                                                                                       "Document No."=FIELD("Document No."),
                                                                                       "Document Line No."=FIELD("Line No.")));
            Caption = 'Qty. to Assign';
            DecimalPlaces = 0:5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5802;"Qty. Assigned";Decimal)
        {
            CalcFormula = Sum("Item Charge Assignment (Sales)"."Qty. Assigned" WHERE ("Document Type"=FIELD("Document Type"),
                                                                                      "Document No."=FIELD("Document No."),
                                                                                      "Document Line No."=FIELD("Line No.")));
            Caption = 'Qty. Assigned';
            DecimalPlaces = 0:5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5803;"Return Qty. to Receive";Decimal)
        {
            AccessByPermission = TableData "Return Receipt Header"=R;
            Caption = 'Return Qty. to Receive';
            DecimalPlaces = 0:5;

            trigger OnValidate()
            var
                ItemLedgEntry: Record "Item Ledger Entry";
            begin
                if (CurrFieldNo <> 0) and
                   (Type = Type::Item) and
                   ("Return Qty. to Receive" <> 0) and
                   (not "Drop Shipment")
                then
                  CheckWarehouse;

                if "Return Qty. to Receive" = Quantity - "Return Qty. Received" then
                  InitQtyToReceive
                else begin
                  "Return Qty. to Receive (Base)" := CalcBaseQty("Return Qty. to Receive");
                  InitQtyToInvoice;
                end;
                if ("Return Qty. to Receive" * Quantity < 0) or
                   (Abs("Return Qty. to Receive") > Abs("Outstanding Quantity")) or
                   (Quantity * "Outstanding Quantity" < 0)
                then
                  Error(
                    Text020,
                    "Outstanding Quantity");
                if ("Return Qty. to Receive (Base)" * "Quantity (Base)" < 0) or
                   (Abs("Return Qty. to Receive (Base)") > Abs("Outstanding Qty. (Base)")) or
                   ("Quantity (Base)" * "Outstanding Qty. (Base)" < 0)
                then
                  Error(
                    Text021,
                    "Outstanding Qty. (Base)");

                if (CurrFieldNo <> 0) and (Type = Type::Item) and ("Return Qty. to Receive" > 0) then
                  CheckApplFromItemLedgEntry(ItemLedgEntry);
            end;
        }
        field(5804;"Return Qty. to Receive (Base)";Decimal)
        {
            Caption = 'Return Qty. to Receive (Base)';
            DecimalPlaces = 0:5;

            trigger OnValidate()
            begin
                TestField("Qty. per Unit of Measure",1);
                Validate("Return Qty. to Receive","Return Qty. to Receive (Base)");
            end;
        }
        field(5805;"Return Qty. Rcd. Not Invd.";Decimal)
        {
            Caption = 'Return Qty. Rcd. Not Invd.';
            DecimalPlaces = 0:5;
            Editable = false;
        }
        field(5806;"Ret. Qty. Rcd. Not Invd.(Base)";Decimal)
        {
            Caption = 'Ret. Qty. Rcd. Not Invd.(Base)';
            DecimalPlaces = 0:5;
            Editable = false;
        }
        field(5807;"Return Rcd. Not Invd.";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Return Rcd. Not Invd.';
            Editable = false;

            trigger OnValidate()
            var
                Currency2: Record Currency;
            begin
                GetSalesHeader;
                Currency2.InitRoundingPrecision;
                if SalesHeader."Currency Code" <> '' then
                  "Return Rcd. Not Invd. (LCY)" :=
                    Round(
                      CurrExchRate.ExchangeAmtFCYToLCY(
                        GetDate,"Currency Code",
                        "Return Rcd. Not Invd.",SalesHeader."Currency Factor"),
                      Currency2."Amount Rounding Precision")
                else
                  "Return Rcd. Not Invd. (LCY)" :=
                    Round("Return Rcd. Not Invd.",Currency2."Amount Rounding Precision");
            end;
        }
        field(5808;"Return Rcd. Not Invd. (LCY)";Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Return Rcd. Not Invd. (LCY)';
            Editable = false;
        }
        field(5809;"Return Qty. Received";Decimal)
        {
            AccessByPermission = TableData "Return Receipt Header"=R;
            Caption = 'Return Qty. Received';
            DecimalPlaces = 0:5;
            Editable = false;
        }
        field(5810;"Return Qty. Received (Base)";Decimal)
        {
            Caption = 'Return Qty. Received (Base)';
            DecimalPlaces = 0:5;
            Editable = false;
        }
        field(5811;"Appl.-from Item Entry";Integer)
        {
            AccessByPermission = TableData Item=R;
            Caption = 'Appl.-from Item Entry';
            MinValue = 0;

            trigger OnLookup()
            begin
                SelectItemEntry(FieldNo("Appl.-from Item Entry"));
            end;

            trigger OnValidate()
            var
                ItemLedgEntry: Record "Item Ledger Entry";
            begin
                if "Appl.-from Item Entry" <> 0 then begin
                  CheckApplFromItemLedgEntry(ItemLedgEntry);
                  Validate("Unit Cost (LCY)",CalcUnitCost(ItemLedgEntry));
                end;
            end;
        }
        field(5909;"BOM Item No.";Code[20])
        {
            Caption = 'BOM Item No.';
            TableRelation = Item;
        }
        field(6600;"Return Receipt No.";Code[20])
        {
            Caption = 'Return Receipt No.';
            Editable = false;
        }
        field(6601;"Return Receipt Line No.";Integer)
        {
            Caption = 'Return Receipt Line No.';
            Editable = false;
        }
        field(6608;"Return Reason Code";Code[10])
        {
            Caption = 'Return Reason Code';
            TableRelation = "Return Reason";

            trigger OnValidate()
            begin
                ValidateReturnReasonCode(FieldNo("Return Reason Code"));
            end;
        }
        field(6610;"Copied From Posted Doc.";Boolean)
        {
            Caption = 'Copied From Posted Doc.';
            DataClassification = SystemMetadata;
        }
        field(7001;"Allow Line Disc.";Boolean)
        {
            Caption = 'Allow Line Disc.';
            InitValue = true;
        }
        field(7002;"Customer Disc. Group";Code[20])
        {
            Caption = 'Customer Disc. Group';
            TableRelation = "Customer Discount Group";

            trigger OnValidate()
            begin
                if Type = Type::Item then
                  UpdateUnitPrice(FieldNo("Customer Disc. Group"))
            end;
        }
        field(7003;Subtype;Option)
        {
            Caption = 'Subtype';
            OptionCaption = ' ,Item - Inventory,Item - Service,Comment';
            OptionMembers = " ","Item - Inventory","Item - Service",Comment;
        }
        field(7004;"Price description";Text[80])
        {
            Caption = 'Price description';
        }
        field(7010;"Attached Doc Count";Integer)
        {
            BlankNumbers = DontBlank;
            CalcFormula = Count("Document Attachment" WHERE ("Table ID"=CONST(37),
                                                             "No."=FIELD("Document No."),
                                                             "Document Type"=FIELD("Document Type"),
                                                             "Line No."=FIELD("Line No.")));
            Caption = 'Attached Doc Count';
            FieldClass = FlowField;
            InitValue = 0;
        }
    }

    keys
    {
        key(Key1;"Document Type","Document No.","Line No.")
        {
        }
        key(Key2;"Document No.","Line No.","Document Type")
        {
            Enabled = false;
        }
        key(Key3;"Document Type",Type,"No.","Variant Code","Drop Shipment","Location Code","Shipment Date")
        {
            SumIndexFields = "Outstanding Qty. (Base)";
        }
        key(Key4;"Document Type","Bill-to Customer No.","Currency Code")
        {
            SumIndexFields = "Outstanding Amount","Shipped Not Invoiced","Outstanding Amount (LCY)","Shipped Not Invoiced (LCY)","Return Rcd. Not Invd. (LCY)";
        }
        key(Key5;"Document Type",Type,"No.","Variant Code","Drop Shipment","Shortcut Dimension 1 Code","Shortcut Dimension 2 Code","Location Code","Shipment Date")
        {
            Enabled = false;
            SumIndexFields = "Outstanding Qty. (Base)";
        }
        key(Key6;"Document Type","Bill-to Customer No.","Shortcut Dimension 1 Code","Shortcut Dimension 2 Code","Currency Code")
        {
            Enabled = false;
            SumIndexFields = "Outstanding Amount","Shipped Not Invoiced","Outstanding Amount (LCY)","Shipped Not Invoiced (LCY)";
        }
        key(Key7;"Document Type","Blanket Order No.","Blanket Order Line No.")
        {
        }
        key(Key8;"Document Type","Document No.","Location Code")
        {
            MaintainSQLIndex = false;
            SumIndexFields = Amount,"Amount Including VAT","Outstanding Amount","Shipped Not Invoiced","Outstanding Amount (LCY)","Shipped Not Invoiced (LCY)";
        }
        key(Key9;"Document Type","Shipment No.","Shipment Line No.")
        {
        }
        key(Key10;Type,"No.","Variant Code","Drop Shipment","Location Code","Document Type","Shipment Date")
        {
            MaintainSQLIndex = false;
        }
        key(Key11;"Document Type","Sell-to Customer No.","Shipment No.")
        {
            SumIndexFields = "Outstanding Amount (LCY)";
        }
        key(Key12;"Job Contract Entry No.")
        {
        }
        key(Key13;"Document Type","Document No.","Qty. Shipped Not Invoiced")
        {
            Enabled = false;
        }
        key(Key14;"Document Type","Document No.",Type,"No.")
        {
            Enabled = false;
        }
    }

    fieldgroups
    {
        fieldgroup(Brick;"No.",Description,"Line Amount",Quantity,"Unit of Measure Code","Price description")
        {
        }
    }

    trigger OnDelete()
    var
        SalesCommentLine: Record "Sales Comment Line";
        CapableToPromise: Codeunit "Capable to Promise";
        JobCreateInvoice: Codeunit "Job Create-Invoice";
    begin
        TestStatusOpen;
        if not StatusCheckSuspended and (SalesHeader.Status = SalesHeader.Status::Released) and
           (Type in [Type::"G/L Account",Type::"Charge (Item)",Type::Resource])
        then
          Validate(Quantity,0);

        if (Quantity <> 0) and ItemExists("No.") then begin
          ReserveSalesLine.DeleteLine(Rec);
          CalcFields("Reserved Qty. (Base)");
          TestField("Reserved Qty. (Base)",0);
          if "Shipment No." = '' then
            TestField("Qty. Shipped Not Invoiced",0);
          if "Return Receipt No." = '' then
            TestField("Return Qty. Rcd. Not Invd.",0);
          WhseValidateSourceLine.SalesLineDelete(Rec);
        end;

        if ("Document Type" = "Document Type"::Order) and (Quantity <> "Quantity Invoiced") then
          TestField("Prepmt. Amt. Inv.","Prepmt Amt Deducted");

        CleanDropShipmentFields;
        CleanSpecialOrderFieldsAndCheckAssocPurchOrder;
        CatalogItemMgt.DelNonStockSales(Rec);

        if "Document Type" = "Document Type"::"Blanket Order" then begin
          SalesLine2.Reset;
          SalesLine2.SetCurrentKey("Document Type","Blanket Order No.","Blanket Order Line No.");
          SalesLine2.SetRange("Blanket Order No.","Document No.");
          SalesLine2.SetRange("Blanket Order Line No.","Line No.");
          if SalesLine2.FindFirst then
            SalesLine2.TestField("Blanket Order Line No.",0);
        end;

        if Type = Type::Item then begin
          ATOLink.DeleteAsmFromSalesLine(Rec);
          DeleteItemChargeAssgnt("Document Type","Document No.","Line No.");
        end;

        if Type = Type::"Charge (Item)" then
          DeleteChargeChargeAssgnt("Document Type","Document No.","Line No.");

        CapableToPromise.RemoveReqLines("Document No.","Line No.",0,false);

        if "Line No." <> 0 then begin
          SalesLine2.Reset;
          SalesLine2.SetRange("Document Type","Document Type");
          SalesLine2.SetRange("Document No.","Document No.");
          SalesLine2.SetRange("Attached to Line No.","Line No.");
          SalesLine2.SetFilter("Line No.",'<>%1',"Line No.");
          SalesLine2.DeleteAll(true);
        end;

        if "Job Contract Entry No." <> 0 then
          JobCreateInvoice.DeleteSalesLine(Rec);

        SalesCommentLine.SetRange("Document Type","Document Type");
        SalesCommentLine.SetRange("No.","Document No.");
        SalesCommentLine.SetRange("Document Line No.","Line No.");
        if not SalesCommentLine.IsEmpty then
          SalesCommentLine.DeleteAll;

        if ("Line No." <> 0) and ("Attached to Line No." = 0) then begin
          SalesLine2.Copy(Rec);
          SalesLine2.SetRange("Document No.",SalesLine2."Document No.");
          SalesLine2.SetRange("Document Type",SalesLine2."Document Type");
          if SalesLine2.Find('<>') then begin
            SalesLine2.Validate("Recalculate Invoice Disc.",true);
            SalesLine2.Modify;
          end;
        end;

        if "Deferral Code" <> '' then
          DeferralUtilities.DeferralCodeOnDelete(
            DeferralUtilities.GetSalesDeferralDocType,'','',
            "Document Type","Document No.","Line No.");
    end;

    trigger OnInsert()
    begin
        TestStatusOpen;
        if Quantity <> 0 then begin
          OnBeforeVerifyReservedQty(Rec,xRec,0);
          ReserveSalesLine.VerifyQuantity(Rec,xRec);
        end;
        LockTable;
        SalesHeader."No." := '';
        if Type = Type::Item then
          if SalesHeader.InventoryPickConflict("Document Type","Document No.",SalesHeader."Shipping Advice") then
            Error(Text056,SalesHeader."Shipping Advice");
        if ("Deferral Code" <> '') and (GetDeferralAmount <> 0) then
          UpdateDeferralAmounts;
    end;

    trigger OnModify()
    begin
        if ("Document Type" = "Document Type"::"Blanket Order") and
           ((Type <> xRec.Type) or ("No." <> xRec."No."))
        then begin
          SalesLine2.Reset;
          SalesLine2.SetCurrentKey("Document Type","Blanket Order No.","Blanket Order Line No.");
          SalesLine2.SetRange("Blanket Order No.","Document No.");
          SalesLine2.SetRange("Blanket Order Line No.","Line No.");
          if SalesLine2.FindSet then
            repeat
              SalesLine2.TestField(Type,Type);
              SalesLine2.TestField("No.","No.");
            until SalesLine2.Next = 0;
        end;

        if ((Quantity <> 0) or (xRec.Quantity <> 0)) and ItemExists(xRec."No.") and not FullReservedQtyIsForAsmToOrder then
          ReserveSalesLine.VerifyChange(Rec,xRec);
    end;

    trigger OnRename()
    begin
        Error(Text001,TableCaption);
    end;

    var
        Text000: Label 'You cannot delete the order line because it is associated with purchase order %1 line %2.';
        Text001: Label 'You cannot rename a %1.';
        Text002: Label 'You cannot change %1 because the order line is associated with purchase order %2 line %3.';
        Text003: Label 'must not be less than %1';
        Text005: Label 'You cannot invoice more than %1 units.';
        Text006: Label 'You cannot invoice more than %1 base units.';
        Text007: Label 'You cannot ship more than %1 units.';
        Text008: Label 'You cannot ship more than %1 base units.';
        Text009: Label ' must be 0 when %1 is %2';
        ManualReserveQst: Label 'Automatic reservation is not possible.\Do you want to reserve items manually?';
        Text014: Label '%1 %2 is before work date %3';
        Text016: Label '%1 is required for %2 = %3.';
        Text017: Label '\The entered information may be disregarded by warehouse operations.';
        Text020: Label 'You cannot return more than %1 units.';
        Text021: Label 'You cannot return more than %1 base units.';
        Text026: Label 'You cannot change %1 if the item charge has already been posted.';
        CurrExchRate: Record "Currency Exchange Rate";
        SalesHeader: Record "Sales Header";
        SalesLine2: Record "Sales Line";
        GLAcc: Record "G/L Account";
        Item: Record Item;
        Resource: Record Resource;
        Currency: Record Currency;
        Res: Record Resource;
        ResCost: Record "Resource Cost";
        VATPostingSetup: Record "VAT Posting Setup";
        GenBusPostingGrp: Record "Gen. Business Posting Group";
        GenProdPostingGrp: Record "Gen. Product Posting Group";
        UnitOfMeasure: Record "Unit of Measure";
        NonstockItem: Record "Nonstock Item";
        SKU: Record "Stockkeeping Unit";
        ItemCharge: Record "Item Charge";
        InvtSetup: Record "Inventory Setup";
        Location: Record Location;
        ATOLink: Record "Assemble-to-Order Link";
        SalesSetup: Record "Sales & Receivables Setup";
        TempItemTemplate: Record "Item Template" temporary;
        CalChange: Record "Customized Calendar Change";
        ConfigTemplateHeader: Record "Config. Template Header";
        PriceCalcMgt: Codeunit "Sales Price Calc. Mgt.";
        CustCheckCreditLimit: Codeunit "Cust-Check Cr. Limit";
        ItemCheckAvail: Codeunit "Item-Check Avail.";
        SalesTaxCalculate: Codeunit "Sales Tax Calculate";
        ReserveSalesLine: Codeunit "Sales Line-Reserve";
        UOMMgt: Codeunit "Unit of Measure Management";
        AddOnIntegrMgt: Codeunit AddOnIntegrManagement;
        DimMgt: Codeunit DimensionManagement;
        ItemSubstitutionMgt: Codeunit "Item Subst.";
        DistIntegration: Codeunit "Dist. Integration";
        CatalogItemMgt: Codeunit "Catalog Item Management";
        WhseValidateSourceLine: Codeunit "Whse. Validate Source Line";
        TransferExtendedText: Codeunit "Transfer Extended Text";
        DeferralUtilities: Codeunit "Deferral Utilities";
        CalendarMgmt: Codeunit "Calendar Management";
        PostingSetupMgt: Codeunit PostingSetupManagement;
        FullAutoReservation: Boolean;
        StatusCheckSuspended: Boolean;
        HasBeenShown: Boolean;
        PlannedShipmentDateCalculated: Boolean;
        PlannedDeliveryDateCalculated: Boolean;
        Text028: Label 'You cannot change the %1 when the %2 has been filled in.';
        Text029: Label 'must be positive';
        Text030: Label 'must be negative';
        Text031: Label 'You must either specify %1 or %2.';
        Text034: Label 'The value of %1 field must be a whole number for the item included in the service item group if the %2 field in the Service Item Groups window contains a check mark.';
        Text035: Label 'Warehouse ';
        Text036: Label 'Inventory ';
        HideValidationDialog: Boolean;
        Text037: Label 'You cannot change %1 when %2 is %3 and %4 is positive.';
        Text038: Label 'You cannot change %1 when %2 is %3 and %4 is negative.';
        Text039: Label '%1 units for %2 %3 have already been returned. Therefore, only %4 units can be returned.';
        Text040: Label 'You must use form %1 to enter %2, if item tracking is used.';
        Text042: Label 'When posting the Applied to Ledger Entry %1 will be opened first';
        ShippingMoreUnitsThanReceivedErr: Label 'You cannot ship more than the %1 units that you have received for document no. %2.';
        Text044: Label 'cannot be less than %1';
        Text045: Label 'cannot be more than %1';
        Text046: Label 'You cannot return more than the %1 units that you have shipped for %2 %3.';
        Text047: Label 'must be positive when %1 is not 0.';
        Text048: Label 'You cannot use item tracking on a %1 created from a %2.';
        Text049: Label 'cannot be %1.';
        Text051: Label 'You cannot use %1 in a %2.';
        PrePaymentLineAmountEntered: Boolean;
        Text052: Label 'You cannot add an item line because an open warehouse shipment exists for the sales header and Shipping Advice is %1.\\You must add items as new lines to the existing warehouse shipment or change Shipping Advice to Partial.';
        Text053: Label 'You have changed one or more dimensions on the %1, which is already shipped. When you post the line with the changed dimension to General Ledger, amounts on the Inventory Interim account will be out of balance when reported per dimension.\\Do you want to keep the changed dimension?';
        Text054: Label 'Cancelled.';
        Text055: Label '%1 must not be greater than the sum of %2 and %3.', Comment='Quantity Invoiced must not be greater than the sum of Qty. Assigned and Qty. to Assign.';
        Text056: Label 'You cannot add an item line because an open inventory pick exists for the Sales Header and because Shipping Advice is %1.\\You must first post or delete the inventory pick or change Shipping Advice to Partial.';
        Text057: Label 'must have the same sign as the shipment';
        Text058: Label 'The quantity that you are trying to invoice is greater than the quantity in shipment %1.';
        Text059: Label 'must have the same sign as the return receipt';
        Text060: Label 'The quantity that you are trying to invoice is greater than the quantity in return receipt %1.';
        ItemChargeAssignmentErr: Label 'You can only assign Item Charges for Line Types of Charge (Item).';
        AnotherItemWithSameDescrQst: Label 'We found an item with the description "%2" (No. %1).\Did you mean to change the current item to %1?', Comment='%1=Item no., %2=item description';
        SalesLineCompletelyShippedErr: Label 'You cannot change the purchasing code for a sales line that has been completely shipped.';
        SalesSetupRead: Boolean;
        LookupRequested: Boolean;
        FreightLineDescriptionTxt: Label 'Freight Amount';
        CannotFindDescErr: Label 'Cannot find %1 with Description %2.\\Make sure to use the correct type.', Comment='%1 = Type caption %2 = Description';
        PriceDescriptionTxt: Label 'x%1 (%2%3/%4)', Locked=true;
        PriceDescriptionWithLineDiscountTxt: Label 'x%1 (%2%3/%4) - %5%', Locked=true;
        SelectNonstockItemErr: Label 'You can only select a catalog item for an empty line.';
        EstimateLbl: Label 'Estimate';
        CommentLbl: Label 'Comment';
        LineDiscountPctErr: Label 'The value in the Line Discount % field must be between 0 and 100.';
        SalesBlockedErr: Label 'You cannot sell this item because the Sales Blocked check box is selected on the item card.';
        CannotChangePrepaidServiceChargeErr: Label 'You cannot change the line because it will affect service charges that are already invoiced as part of a prepayment.';
        LineAmountInvalidErr: Label 'You have set the line amount to a value that results in a discount that is not valid. Consider increasing the unit price instead.';

    [Scope('Personalization')]
    procedure InitOutstanding()
    begin
        if "Document Type" in ["Document Type"::"Return Order","Document Type"::"Credit Memo"] then begin
          "Outstanding Quantity" := Quantity - "Return Qty. Received";
          "Outstanding Qty. (Base)" := "Quantity (Base)" - "Return Qty. Received (Base)";
          "Return Qty. Rcd. Not Invd." := "Return Qty. Received" - "Quantity Invoiced";
          "Ret. Qty. Rcd. Not Invd.(Base)" := "Return Qty. Received (Base)" - "Qty. Invoiced (Base)";
        end else begin
          "Outstanding Quantity" := Quantity - "Quantity Shipped";
          "Outstanding Qty. (Base)" := "Quantity (Base)" - "Qty. Shipped (Base)";
          "Qty. Shipped Not Invoiced" := "Quantity Shipped" - "Quantity Invoiced";
          "Qty. Shipped Not Invd. (Base)" := "Qty. Shipped (Base)" - "Qty. Invoiced (Base)";
        end;
        UpdatePlanned;
        "Completely Shipped" := (Quantity <> 0) and ("Outstanding Quantity" = 0);
        InitOutstandingAmount;
    end;

    [Scope('Personalization')]
    procedure InitOutstandingAmount()
    var
        AmountInclVAT: Decimal;
    begin
        if Quantity = 0 then begin
          "Outstanding Amount" := 0;
          "Outstanding Amount (LCY)" := 0;
          "Shipped Not Invoiced" := 0;
          "Shipped Not Invoiced (LCY)" := 0;
          "Return Rcd. Not Invd." := 0;
          "Return Rcd. Not Invd. (LCY)" := 0;
        end else begin
          GetSalesHeader;
          AmountInclVAT := "Amount Including VAT";
          Validate(
            "Outstanding Amount",
            Round(
              AmountInclVAT * "Outstanding Quantity" / Quantity,
              Currency."Amount Rounding Precision"));
          if "Document Type" in ["Document Type"::"Return Order","Document Type"::"Credit Memo"] then
            Validate(
              "Return Rcd. Not Invd.",
              Round(
                AmountInclVAT * "Return Qty. Rcd. Not Invd." / Quantity,
                Currency."Amount Rounding Precision"))
          else
            Validate(
              "Shipped Not Invoiced",
              Round(
                AmountInclVAT * "Qty. Shipped Not Invoiced" / Quantity,
                Currency."Amount Rounding Precision"));
        end;

        OnAfterInitOutstandingAmount(Rec,SalesHeader,Currency);
    end;

    [Scope('Personalization')]
    procedure InitQtyToShip()
    begin
        GetSalesSetup;
        if (SalesSetup."Default Quantity to Ship" = SalesSetup."Default Quantity to Ship"::Remainder) or
           ("Document Type" = "Document Type"::Invoice)
        then begin
          "Qty. to Ship" := "Outstanding Quantity";
          "Qty. to Ship (Base)" := "Outstanding Qty. (Base)";
        end else
          if "Qty. to Ship" <> 0 then
            "Qty. to Ship (Base)" := CalcBaseQty("Qty. to Ship");

        CheckServItemCreation;

        OnAfterInitQtyToShip(Rec,CurrFieldNo);

        InitQtyToInvoice;
    end;

    [Scope('Personalization')]
    procedure InitQtyToReceive()
    begin
        GetSalesSetup;
        if (SalesSetup."Default Quantity to Ship" = SalesSetup."Default Quantity to Ship"::Remainder) or
           ("Document Type" = "Document Type"::"Credit Memo")
        then begin
          "Return Qty. to Receive" := "Outstanding Quantity";
          "Return Qty. to Receive (Base)" := "Outstanding Qty. (Base)";
        end else
          if "Return Qty. to Receive" <> 0 then
            "Return Qty. to Receive (Base)" := CalcBaseQty("Return Qty. to Receive");

        OnAfterInitQtyToReceive(Rec,CurrFieldNo);

        InitQtyToInvoice;
    end;

    [Scope('Personalization')]
    procedure InitQtyToInvoice()
    begin
        "Qty. to Invoice" := MaxQtyToInvoice;
        "Qty. to Invoice (Base)" := MaxQtyToInvoiceBase;
        "VAT Difference" := 0;
        CalcInvDiscToInvoice;
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Invoice then
          CalcPrepaymentToDeduct;

        OnAfterInitQtyToInvoice(Rec,CurrFieldNo);
    end;

    local procedure InitItemAppl(OnlyApplTo: Boolean)
    begin
        "Appl.-to Item Entry" := 0;
        if not OnlyApplTo then
          "Appl.-from Item Entry" := 0;
    end;

    [Scope('Personalization')]
    procedure MaxQtyToInvoice(): Decimal
    begin
        if "Prepayment Line" then
          exit(1);
        if "Document Type" in ["Document Type"::"Return Order","Document Type"::"Credit Memo"] then
          exit("Return Qty. Received" + "Return Qty. to Receive" - "Quantity Invoiced");

        exit("Quantity Shipped" + "Qty. to Ship" - "Quantity Invoiced");
    end;

    [Scope('Personalization')]
    procedure MaxQtyToInvoiceBase(): Decimal
    begin
        if "Document Type" in ["Document Type"::"Return Order","Document Type"::"Credit Memo"] then
          exit("Return Qty. Received (Base)" + "Return Qty. to Receive (Base)" - "Qty. Invoiced (Base)");

        exit("Qty. Shipped (Base)" + "Qty. to Ship (Base)" - "Qty. Invoiced (Base)");
    end;

    local procedure CalcBaseQty(Qty: Decimal): Decimal
    begin
        TestField("Qty. per Unit of Measure");
        exit(Round(Qty * "Qty. per Unit of Measure",0.00001));
    end;

    procedure CalcLineAmount(): Decimal
    begin
        exit("Line Amount" - "Inv. Discount Amount");
    end;

    local procedure CopyFromStandardText()
    var
        StandardText: Record "Standard Text";
    begin
        StandardText.Get("No.");
        Description := StandardText.Description;
        "Allow Item Charge Assignment" := false;
        OnAfterAssignStdTxtValues(Rec,StandardText);
    end;

    local procedure CopyFromGLAccount()
    begin
        GLAcc.Get("No.");
        GLAcc.CheckGLAcc;
        if not "System-Created Entry" then
          GLAcc.TestField("Direct Posting",true);
        Description := GLAcc.Name;
        "Gen. Prod. Posting Group" := GLAcc."Gen. Prod. Posting Group";
        "VAT Prod. Posting Group" := GLAcc."VAT Prod. Posting Group";
        "Tax Group Code" := GLAcc."Tax Group Code";
        "Allow Invoice Disc." := false;
        "Allow Item Charge Assignment" := false;
        InitDeferralCode;
        OnAfterAssignGLAccountValues(Rec,GLAcc);
    end;

    local procedure CopyFromItem()
    var
        PrepaymentMgt: Codeunit "Prepayment Mgt.";
    begin
        GetItem;
        Item.TestField(Blocked,false);
        Item.TestField("Gen. Prod. Posting Group");
        if Item."Sales Blocked" then
          Error(SalesBlockedErr);
        if Item.Type = Item.Type::Inventory then begin
          Item.TestField("Inventory Posting Group");
          "Posting Group" := Item."Inventory Posting Group";
        end;
        Description := Item.Description;
        "Description 2" := Item."Description 2";
        GetUnitCost;
        "Allow Invoice Disc." := Item."Allow Invoice Disc.";
        "Units per Parcel" := Item."Units per Parcel";
        "Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
        "VAT Prod. Posting Group" := Item."VAT Prod. Posting Group";
        "Tax Group Code" := Item."Tax Group Code";
        "Item Category Code" := Item."Item Category Code";
        Nonstock := Item."Created From Nonstock Item";
        "Profit %" := Item."Profit %";
        "Allow Item Charge Assignment" := true;
        PrepaymentMgt.SetSalesPrepaymentPct(Rec,SalesHeader."Posting Date");
        if Item.Type = Item.Type::Inventory then
          PostingSetupMgt.CheckInvtPostingSetupInventoryAccount("Location Code","Posting Group");

        if SalesHeader."Language Code" <> '' then
          GetItemTranslation;

        if Item.Reserve = Item.Reserve::Optional then
          Reserve := SalesHeader.Reserve
        else
          Reserve := Item.Reserve;

        "Unit of Measure Code" := Item."Sales Unit of Measure";
        InitDeferralCode;
        SetDefaultItemQuantity;
        OnAfterAssignItemValues(Rec,Item);
    end;

    local procedure CopyFromResource()
    begin
        Res.Get("No.");
        Res.CheckResourcePrivacyBlocked(false);
        Res.TestField(Blocked,false);
        Res.TestField("Gen. Prod. Posting Group");
        Description := Res.Name;
        "Description 2" := Res."Name 2";
        "Unit of Measure Code" := Res."Base Unit of Measure";
        "Unit Cost (LCY)" := Res."Unit Cost";
        "Gen. Prod. Posting Group" := Res."Gen. Prod. Posting Group";
        "VAT Prod. Posting Group" := Res."VAT Prod. Posting Group";
        "Tax Group Code" := Res."Tax Group Code";
        "Allow Item Charge Assignment" := false;
        FindResUnitCost;
        InitDeferralCode;
        OnAfterAssignResourceValues(Rec,Res);
    end;

    local procedure CopyFromFixedAsset()
    var
        FixedAsset: Record "Fixed Asset";
    begin
        FixedAsset.Get("No.");
        FixedAsset.TestField(Inactive,false);
        FixedAsset.TestField(Blocked,false);
        GetFAPostingGroup;
        Description := FixedAsset.Description;
        "Description 2" := FixedAsset."Description 2";
        "Allow Invoice Disc." := false;
        "Allow Item Charge Assignment" := false;
        OnAfterAssignFixedAssetValues(Rec,FixedAsset);
    end;

    local procedure CopyFromItemCharge()
    begin
        ItemCharge.Get("No.");
        Description := ItemCharge.Description;
        "Gen. Prod. Posting Group" := ItemCharge."Gen. Prod. Posting Group";
        "VAT Prod. Posting Group" := ItemCharge."VAT Prod. Posting Group";
        "Tax Group Code" := ItemCharge."Tax Group Code";
        "Allow Invoice Disc." := false;
        "Allow Item Charge Assignment" := false;
        OnAfterAssignItemChargeValues(Rec,ItemCharge);
    end;

    local procedure SelectItemEntry(CurrentFieldNo: Integer)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        SalesLine3: Record "Sales Line";
    begin
        ItemLedgEntry.SetRange("Item No.","No.");
        if "Location Code" <> '' then
          ItemLedgEntry.SetRange("Location Code","Location Code");
        ItemLedgEntry.SetRange("Variant Code","Variant Code");

        if CurrentFieldNo = FieldNo("Appl.-to Item Entry") then begin
          ItemLedgEntry.SetCurrentKey("Item No.",Open);
          ItemLedgEntry.SetRange(Positive,true);
          ItemLedgEntry.SetRange(Open,true);
        end else begin
          ItemLedgEntry.SetCurrentKey("Item No.",Positive);
          ItemLedgEntry.SetRange(Positive,false);
          ItemLedgEntry.SetFilter("Shipped Qty. Not Returned",'<0');
        end;
        if PAGE.RunModal(PAGE::"Item Ledger Entries",ItemLedgEntry) = ACTION::LookupOK then begin
          SalesLine3 := Rec;
          if CurrentFieldNo = FieldNo("Appl.-to Item Entry") then
            SalesLine3.Validate("Appl.-to Item Entry",ItemLedgEntry."Entry No.")
          else
            SalesLine3.Validate("Appl.-from Item Entry",ItemLedgEntry."Entry No.");
          CheckItemAvailable(CurrentFieldNo);
          Rec := SalesLine3;
        end;
    end;

    [Scope('Personalization')]
    procedure SetSalesHeader(NewSalesHeader: Record "Sales Header")
    begin
        SalesHeader := NewSalesHeader;

        if SalesHeader."Currency Code" = '' then
          Currency.InitRoundingPrecision
        else begin
          SalesHeader.TestField("Currency Factor");
          Currency.Get(SalesHeader."Currency Code");
          Currency.TestField("Amount Rounding Precision");
        end;
    end;

    [Scope('Personalization')]
    procedure GetSalesHeader()
    begin
        TestField("Document No.");
        if ("Document Type" <> SalesHeader."Document Type") or ("Document No." <> SalesHeader."No.") then begin
          SalesHeader.Get("Document Type","Document No.");
          if SalesHeader."Currency Code" = '' then
            Currency.InitRoundingPrecision
          else begin
            SalesHeader.TestField("Currency Factor");
            Currency.Get(SalesHeader."Currency Code");
            Currency.TestField("Amount Rounding Precision");
          end;
        end;
    end;

    local procedure GetItem()
    begin
        TestField("No.");
        if "No." <> Item."No." then
          Item.Get("No.");
    end;

    local procedure GetResource()
    begin
        TestField("No.");
        if "No." <> Resource."No." then
          Resource.Get("No.");
    end;

    [Scope('Personalization')]
    procedure UpdateUnitPrice(CalledByFieldNo: Integer)
    var
        Handled: Boolean;
    begin
        OnBeforeUpdateUnitPrice(Rec,xRec,CalledByFieldNo,CurrFieldNo,Handled);
        if Handled then
          exit;

        GetSalesHeader;
        TestField("Qty. per Unit of Measure");

        case Type of
          Type::Item,Type::Resource:
            begin
              if not ("Copied From Posted Doc." and IsCreditDocType) then
                PriceCalcMgt.FindSalesLineLineDisc(SalesHeader,Rec);
              PriceCalcMgt.FindSalesLinePrice(SalesHeader,Rec,CalledByFieldNo);
            end;
        end;
        Validate("Unit Price");

        OnAfterUpdateUnitPrice(Rec,xRec,CalledByFieldNo,CurrFieldNo);
    end;

    local procedure FindResUnitCost()
    begin
        ResCost.Init;
        ResCost.Code := "No.";
        ResCost."Work Type Code" := "Work Type Code";
        CODEUNIT.Run(CODEUNIT::"Resource-Find Cost",ResCost);
        Validate("Unit Cost (LCY)",ResCost."Unit Cost" * "Qty. per Unit of Measure");
    end;

    [Scope('Personalization')]
    procedure UpdatePrepmtSetupFields()
    var
        GenPostingSetup: Record "General Posting Setup";
        GLAcc: Record "G/L Account";
    begin
        if ("Prepayment %" <> 0) and (Type <> Type::" ") then begin
          TestField("Document Type","Document Type"::Order);
          TestField("No.");
          if CurrFieldNo = FieldNo("Prepayment %") then
            if "System-Created Entry" and not IsServiceCharge then
              FieldError("Prepmt. Line Amount",StrSubstNo(Text045,0));
          if "System-Created Entry" and not IsServiceCharge then
            "Prepayment %" := 0;
          GenPostingSetup.Get("Gen. Bus. Posting Group","Gen. Prod. Posting Group");
          if GenPostingSetup."Sales Prepayments Account" <> '' then begin
            GLAcc.Get(GenPostingSetup."Sales Prepayments Account");
            VATPostingSetup.Get("VAT Bus. Posting Group",GLAcc."VAT Prod. Posting Group");
            VATPostingSetup.TestField("VAT Calculation Type","VAT Calculation Type");
          end else
            Clear(VATPostingSetup);
          "Prepayment VAT %" := VATPostingSetup."VAT %";
          "Prepmt. VAT Calc. Type" := VATPostingSetup."VAT Calculation Type";
          "Prepayment VAT Identifier" := VATPostingSetup."VAT Identifier";
          if "Prepmt. VAT Calc. Type" in
             ["Prepmt. VAT Calc. Type"::"Reverse Charge VAT","Prepmt. VAT Calc. Type"::"Sales Tax"]
          then
            "Prepayment VAT %" := 0;
          "Prepayment Tax Group Code" := GLAcc."Tax Group Code";
        end;
    end;

    [Scope('Personalization')]
    procedure UpdateAmounts()
    var
        RemLineAmountToInvoice: Decimal;
        VATBaseAmount: Decimal;
        LineAmountChanged: Boolean;
    begin
        if Type = Type::" " then
          exit;
        GetSalesHeader;
        VATBaseAmount := "VAT Base Amount";
        "Recalculate Invoice Disc." := true;

        if "Line Amount" <> xRec."Line Amount" then begin
          "VAT Difference" := 0;
          LineAmountChanged := true;
        end;
        if "Line Amount" <> Round(Quantity * "Unit Price",Currency."Amount Rounding Precision") - "Line Discount Amount" then begin
          "Line Amount" := Round(Quantity * "Unit Price",Currency."Amount Rounding Precision") - "Line Discount Amount";
          "VAT Difference" := 0;
          LineAmountChanged := true;
        end;

        if not "Prepayment Line" then begin
          if "Prepayment %" <> 0 then begin
            if Quantity < 0 then
              FieldError(Quantity,StrSubstNo(Text047,FieldCaption("Prepayment %")));
            if "Unit Price" < 0 then
              FieldError("Unit Price",StrSubstNo(Text047,FieldCaption("Prepayment %")));
          end;
          if SalesHeader."Document Type" <> SalesHeader."Document Type"::Invoice then begin
            "Prepayment VAT Difference" := 0;
            if not PrePaymentLineAmountEntered then
              "Prepmt. Line Amount" := Round("Line Amount" * "Prepayment %" / 100,Currency."Amount Rounding Precision");
            if "Prepmt. Line Amount" < "Prepmt. Amt. Inv." then begin
              if IsServiceCharge then
                Error(CannotChangePrepaidServiceChargeErr);
              FieldError("Prepmt. Line Amount",StrSubstNo(Text049,"Prepmt. Amt. Inv."));
            end;
            PrePaymentLineAmountEntered := false;
            if "Prepmt. Line Amount" <> 0 then begin
              RemLineAmountToInvoice :=
                Round("Line Amount" * (Quantity - "Quantity Invoiced") / Quantity,Currency."Amount Rounding Precision");
              if RemLineAmountToInvoice < ("Prepmt. Line Amount" - "Prepmt Amt Deducted") then
                FieldError("Prepmt. Line Amount",StrSubstNo(Text045,RemLineAmountToInvoice + "Prepmt Amt Deducted"));
            end;
          end else
            if (CurrFieldNo <> 0) and ("Line Amount" <> xRec."Line Amount") and
               ("Prepmt. Amt. Inv." <> 0) and ("Prepayment %" = 100)
            then begin
              if "Line Amount" < xRec."Line Amount" then
                FieldError("Line Amount",StrSubstNo(Text044,xRec."Line Amount"));
              FieldError("Line Amount",StrSubstNo(Text045,xRec."Line Amount"));
            end;
        end;

        OnAfterUpdateAmounts(Rec,xRec,CurrFieldNo);

        UpdateVATAmounts;
        InitOutstandingAmount;
        if (CurrFieldNo <> 0) and
           not ((Type = Type::Item) and (CurrFieldNo = FieldNo("No.")) and (Quantity <> 0) and
                // a write transaction may have been started
                ("Qty. per Unit of Measure" <> xRec."Qty. per Unit of Measure")) and // ...continued condition
           ("Document Type" <= "Document Type"::Invoice) and
           (("Outstanding Amount" + "Shipped Not Invoiced") > 0) and
           (CurrFieldNo <> FieldNo("Blanket Order No.")) and
           (CurrFieldNo <> FieldNo("Blanket Order Line No."))
        then
          CustCheckCreditLimit.SalesLineCheck(Rec);

        if Type = Type::"Charge (Item)" then
          UpdateItemChargeAssgnt;

        CalcPrepaymentToDeduct;
        if VATBaseAmount <> "VAT Base Amount" then
          LineAmountChanged := true;

        if LineAmountChanged then begin
          UpdateDeferralAmounts;
          LineAmountChanged := false;
        end;

        OnAfterUpdateAmountsDone(Rec,xRec,CurrFieldNo);
    end;

    local procedure UpdateVATAmounts()
    var
        SalesLine2: Record "Sales Line";
        TotalLineAmount: Decimal;
        TotalInvDiscAmount: Decimal;
        TotalAmount: Decimal;
        TotalAmountInclVAT: Decimal;
        TotalQuantityBase: Decimal;
    begin
        GetSalesHeader;
        SalesLine2.SetRange("Document Type","Document Type");
        SalesLine2.SetRange("Document No.","Document No.");
        SalesLine2.SetFilter("Line No.",'<>%1',"Line No.");
        if "Line Amount" = 0 then
          if xRec."Line Amount" >= 0 then
            SalesLine2.SetFilter(Amount,'>%1',0)
          else
            SalesLine2.SetFilter(Amount,'<%1',0)
        else
          if "Line Amount" > 0 then
            SalesLine2.SetFilter(Amount,'>%1',0)
          else
            SalesLine2.SetFilter(Amount,'<%1',0);
        SalesLine2.SetRange("VAT Identifier","VAT Identifier");
        SalesLine2.SetRange("Tax Group Code","Tax Group Code");

        if "Line Amount" = "Inv. Discount Amount" then begin
          Amount := 0;
          "VAT Base Amount" := 0;
          "Amount Including VAT" := 0;
        end else begin
          TotalLineAmount := 0;
          TotalInvDiscAmount := 0;
          TotalAmount := 0;
          TotalAmountInclVAT := 0;
          TotalQuantityBase := 0;
          if ("VAT Calculation Type" = "VAT Calculation Type"::"Sales Tax") or
             (("VAT Calculation Type" in
               ["VAT Calculation Type"::"Normal VAT","VAT Calculation Type"::"Reverse Charge VAT"]) and ("VAT %" <> 0))
          then
            if not SalesLine2.IsEmpty then begin
              SalesLine2.CalcSums("Line Amount","Inv. Discount Amount",Amount,"Amount Including VAT","Quantity (Base)");
              TotalLineAmount := SalesLine2."Line Amount";
              TotalInvDiscAmount := SalesLine2."Inv. Discount Amount";
              TotalAmount := SalesLine2.Amount;
              TotalAmountInclVAT := SalesLine2."Amount Including VAT";
              TotalQuantityBase := SalesLine2."Quantity (Base)";
              OnAfterUpdateTotalAmounts(Rec,SalesLine2,TotalAmount,TotalAmountInclVAT,TotalLineAmount,TotalInvDiscAmount);
            end;

          if SalesHeader."Prices Including VAT" then
            case "VAT Calculation Type" of
              "VAT Calculation Type"::"Normal VAT",
              "VAT Calculation Type"::"Reverse Charge VAT":
                begin
                  Amount :=
                    Round(
                      (TotalLineAmount - TotalInvDiscAmount + CalcLineAmount) / (1 + "VAT %" / 100),
                      Currency."Amount Rounding Precision") -
                    TotalAmount;
                  "VAT Base Amount" :=
                    Round(
                      Amount * (1 - SalesHeader."VAT Base Discount %" / 100),
                      Currency."Amount Rounding Precision");
                  "Amount Including VAT" :=
                    TotalLineAmount + "Line Amount" -
                    Round(
                      (TotalAmount + Amount) * (SalesHeader."VAT Base Discount %" / 100) * "VAT %" / 100,
                      Currency."Amount Rounding Precision",Currency.VATRoundingDirection) -
                    TotalAmountInclVAT - TotalInvDiscAmount - "Inv. Discount Amount";
                end;
              "VAT Calculation Type"::"Full VAT":
                begin
                  Amount := 0;
                  "VAT Base Amount" := 0;
                end;
              "VAT Calculation Type"::"Sales Tax":
                begin
                  SalesHeader.TestField("VAT Base Discount %",0);
                  Amount :=
                    SalesTaxCalculate.ReverseCalculateTax(
                      "Tax Area Code","Tax Group Code","Tax Liable",SalesHeader."Posting Date",
                      TotalAmountInclVAT + "Amount Including VAT",TotalQuantityBase + "Quantity (Base)",
                      SalesHeader."Currency Factor") -
                    TotalAmount;
                  if Amount <> 0 then
                    "VAT %" :=
                      Round(100 * ("Amount Including VAT" - Amount) / Amount,0.00001)
                  else
                    "VAT %" := 0;
                  Amount := Round(Amount,Currency."Amount Rounding Precision");
                  "VAT Base Amount" := Amount;
                end;
            end
          else
            case "VAT Calculation Type" of
              "VAT Calculation Type"::"Normal VAT",
              "VAT Calculation Type"::"Reverse Charge VAT":
                begin
                  Amount := Round(CalcLineAmount,Currency."Amount Rounding Precision");
                  "VAT Base Amount" :=
                    Round(Amount * (1 - SalesHeader."VAT Base Discount %" / 100),Currency."Amount Rounding Precision");
                  "Amount Including VAT" :=
                    TotalAmount + Amount +
                    Round(
                      (TotalAmount + Amount) * (1 - SalesHeader."VAT Base Discount %" / 100) * "VAT %" / 100,
                      Currency."Amount Rounding Precision",Currency.VATRoundingDirection) -
                    TotalAmountInclVAT;
                end;
              "VAT Calculation Type"::"Full VAT":
                begin
                  Amount := 0;
                  "VAT Base Amount" := 0;
                  "Amount Including VAT" := CalcLineAmount;
                end;
              "VAT Calculation Type"::"Sales Tax":
                begin
                  Amount := Round(CalcLineAmount,Currency."Amount Rounding Precision");
                  "VAT Base Amount" := Amount;
                  "Amount Including VAT" :=
                    TotalAmount + Amount +
                    Round(
                      SalesTaxCalculate.CalculateTax(
                        "Tax Area Code","Tax Group Code","Tax Liable",SalesHeader."Posting Date",
                        TotalAmount + Amount,TotalQuantityBase + "Quantity (Base)",
                        SalesHeader."Currency Factor"),Currency."Amount Rounding Precision") -
                    TotalAmountInclVAT;
                  if "VAT Base Amount" <> 0 then
                    "VAT %" :=
                      Round(100 * ("Amount Including VAT" - "VAT Base Amount") / "VAT Base Amount",0.00001)
                  else
                    "VAT %" := 0;
                end;
            end;
        end;
    end;

    [Scope('Personalization')]
    procedure CheckItemAvailable(CalledByFieldNo: Integer)
    begin
        if Reserve = Reserve::Always then
          exit;

        if "Shipment Date" = 0D then begin
          GetSalesHeader;
          if SalesHeader."Shipment Date" <> 0D then
            Validate("Shipment Date",SalesHeader."Shipment Date")
          else
            Validate("Shipment Date",WorkDate);
        end;

        if ((CalledByFieldNo = CurrFieldNo) or (CalledByFieldNo = FieldNo("Shipment Date"))) and GuiAllowed and
           ("Document Type" in ["Document Type"::Order,"Document Type"::Invoice]) and
           (Type = Type::Item) and ("No." <> '') and
           ("Outstanding Quantity" > 0) and
           ("Job Contract Entry No." = 0) and
           not "Special Order"
        then begin
          if ItemCheckAvail.SalesLineCheck(Rec) then
            ItemCheckAvail.RaiseUpdateInterruptedError;
        end;
    end;

    [Scope('Personalization')]
    procedure ShowReservation()
    var
        Reservation: Page Reservation;
    begin
        TestField(Type,Type::Item);
        TestField("No.");
        TestField(Reserve);
        Clear(Reservation);
        Reservation.SetSalesLine(Rec);
        Reservation.RunModal;
        UpdatePlanned;
    end;

    [Scope('Personalization')]
    procedure ShowReservationEntries(Modal: Boolean)
    var
        ReservEntry: Record "Reservation Entry";
        ReservEngineMgt: Codeunit "Reservation Engine Mgt.";
    begin
        TestField(Type,Type::Item);
        TestField("No.");
        ReservEngineMgt.InitFilterAndSortingLookupFor(ReservEntry,true);
        ReserveSalesLine.FilterReservFor(ReservEntry,Rec);
        if Modal then
          PAGE.RunModal(PAGE::"Reservation Entries",ReservEntry)
        else
          PAGE.Run(PAGE::"Reservation Entries",ReservEntry);
    end;

    [Scope('Personalization')]
    procedure AutoReserve()
    var
        SalesSetup: Record "Sales & Receivables Setup";
        ReservMgt: Codeunit "Reservation Management";
        QtyToReserve: Decimal;
        QtyToReserveBase: Decimal;
    begin
        TestField(Type,Type::Item);
        TestField("No.");

        ReserveSalesLine.ReservQuantity(Rec,QtyToReserve,QtyToReserveBase);
        if QtyToReserveBase <> 0 then begin
          ReservMgt.SetSalesLine(Rec);
          TestField("Shipment Date");
          ReservMgt.AutoReserve(FullAutoReservation,'',"Shipment Date",QtyToReserve,QtyToReserveBase);
          Find;
          SalesSetup.Get;
          if (not FullAutoReservation) and (not SalesSetup."Skip Manual Reservation") then begin
            Commit;
            if Confirm(ManualReserveQst,true) then begin
              ShowReservation;
              Find;
            end;
          end;
        end;
    end;

    [Scope('Personalization')]
    procedure AutoAsmToOrder()
    begin
        OnBeforeAutoAsmToOrder(Rec);
        ATOLink.UpdateAsmFromSalesLine(Rec);
        OnAfterAutoAsmToOrder(Rec);
    end;

    local procedure GetDate(): Date
    begin
        if SalesHeader."Posting Date" <> 0D then
          exit(SalesHeader."Posting Date");
        exit(WorkDate);
    end;

    [Scope('Personalization')]
    procedure CalcPlannedDeliveryDate(CurrFieldNo: Integer): Date
    begin
        if "Shipment Date" = 0D then
          exit("Planned Delivery Date");

        case CurrFieldNo of
          FieldNo("Shipment Date"):
            exit(CalendarMgmt.CalcDateBOC(
                Format("Shipping Time"),
                "Planned Shipment Date",
                CalChange."Source Type"::"Shipping Agent",
                "Shipping Agent Code",
                "Shipping Agent Service Code",
                CalChange."Source Type"::Customer,
                "Sell-to Customer No.",
                '',
                true));
          FieldNo("Planned Delivery Date"):
            exit(CalendarMgmt.CalcDateBOC2(
                Format("Shipping Time"),
                "Planned Delivery Date",
                CalChange."Source Type"::Customer,
                "Sell-to Customer No.",
                '',
                CalChange."Source Type"::"Shipping Agent",
                "Shipping Agent Code",
                "Shipping Agent Service Code",
                true))
        end;
    end;

    [Scope('Personalization')]
    procedure CalcPlannedShptDate(CurrFieldNo: Integer): Date
    begin
        if "Shipment Date" = 0D then
          exit("Planned Shipment Date");

        case CurrFieldNo of
          FieldNo("Shipment Date"):
            exit(CalendarMgmt.CalcDateBOC(
                Format("Outbound Whse. Handling Time"),
                "Shipment Date",
                CalChange."Source Type"::Location,
                "Location Code",
                '',
                CalChange."Source Type"::"Shipping Agent",
                "Shipping Agent Code",
                "Shipping Agent Service Code",
                true));
          FieldNo("Planned Delivery Date"):
            exit(CalendarMgmt.CalcDateBOC(
                Format(''),
                "Planned Delivery Date",
                CalChange."Source Type"::Customer,
                "Sell-to Customer No.",
                '',
                CalChange."Source Type"::"Shipping Agent",
                "Shipping Agent Code",
                "Shipping Agent Service Code",
                true));
        end;
    end;

    [Scope('Personalization')]
    procedure CalcShipmentDate(): Date
    begin
        if "Planned Shipment Date" = 0D then
          exit("Shipment Date");

        if Format("Outbound Whse. Handling Time") <> '' then
          exit(
            CalendarMgmt.CalcDateBOC2(
              Format("Outbound Whse. Handling Time"),
              "Planned Shipment Date",
              CalChange."Source Type"::Location,
              "Location Code",
              '',
              CalChange."Source Type"::"Shipping Agent",
              "Shipping Agent Code",
              "Shipping Agent Service Code",
              false));

        exit(
          CalendarMgmt.CalcDateBOC(
            Format(Format('')),
            "Planned Shipment Date",
            CalChange."Source Type"::"Shipping Agent",
            "Shipping Agent Code",
            "Shipping Agent Service Code",
            CalChange."Source Type"::Location,
            "Location Code",
            '',
            false));
    end;

    [Scope('Personalization')]
    procedure SignedXX(Value: Decimal): Decimal
    begin
        case "Document Type" of
          "Document Type"::Quote,
          "Document Type"::Order,
          "Document Type"::Invoice,
          "Document Type"::"Blanket Order":
            exit(-Value);
          "Document Type"::"Return Order",
          "Document Type"::"Credit Memo":
            exit(Value);
        end;
    end;

    local procedure BlanketOrderLookup()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeBlanketOrderLookup(Rec,IsHandled);
        if IsHandled then
          exit;

        SalesLine2.Reset;
        SalesLine2.SetCurrentKey("Document Type",Type,"No.");
        SalesLine2.SetRange("Document Type","Document Type"::"Blanket Order");
        SalesLine2.SetRange(Type,Type);
        SalesLine2.SetRange("No.","No.");
        SalesLine2.SetRange("Bill-to Customer No.","Bill-to Customer No.");
        SalesLine2.SetRange("Sell-to Customer No.","Sell-to Customer No.");
        if PAGE.RunModal(PAGE::"Sales Lines",SalesLine2) = ACTION::LookupOK then begin
          SalesLine2.TestField("Document Type","Document Type"::"Blanket Order");
          "Blanket Order No." := SalesLine2."Document No.";
          Validate("Blanket Order Line No.",SalesLine2."Line No.");
        end;

        OnAfterBlanketOrderLookup(Rec);
    end;

    [Scope('Personalization')]
    procedure ShowDimensions()
    begin
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet("Dimension Set ID",StrSubstNo('%1 %2 %3',"Document Type","Document No.","Line No."));
        VerifyItemLineDim;
        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID","Shortcut Dimension 1 Code","Shortcut Dimension 2 Code");
        ATOLink.UpdateAsmDimFromSalesLine(Rec);
    end;

    [Scope('Personalization')]
    procedure OpenItemTrackingLines()
    var
        Job: Record Job;
    begin
        TestField(Type,Type::Item);
        TestField("No.");
        TestField("Quantity (Base)");
        if "Job Contract Entry No." <> 0 then
          Error(Text048,TableCaption,Job.TableCaption);
        ReserveSalesLine.CallItemTracking(Rec);
    end;

    [Scope('Personalization')]
    procedure CreateDim(Type1: Integer;No1: Code[20];Type2: Integer;No2: Code[20];Type3: Integer;No3: Code[20])
    var
        SourceCodeSetup: Record "Source Code Setup";
        TableID: array [10] of Integer;
        No: array [10] of Code[20];
    begin
        SourceCodeSetup.Get;
        TableID[1] := Type1;
        No[1] := No1;
        TableID[2] := Type2;
        No[2] := No2;
        TableID[3] := Type3;
        No[3] := No3;
        OnAfterCreateDimTableIDs(Rec,CurrFieldNo,TableID,No);

        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        GetSalesHeader;
        "Dimension Set ID" :=
          DimMgt.GetRecDefaultDimID(
            Rec,CurrFieldNo,TableID,No,SourceCodeSetup.Sales,
            "Shortcut Dimension 1 Code","Shortcut Dimension 2 Code",SalesHeader."Dimension Set ID",DATABASE::Customer);
        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID","Shortcut Dimension 1 Code","Shortcut Dimension 2 Code");
        ATOLink.UpdateAsmDimFromSalesLine(Rec);
    end;

    [Scope('Personalization')]
    procedure ValidateShortcutDimCode(FieldNumber: Integer;var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateShortcutDimValues(FieldNumber,ShortcutDimCode,"Dimension Set ID");
        VerifyItemLineDim;
    end;

    [Scope('Personalization')]
    procedure LookupShortcutDimCode(FieldNumber: Integer;var ShortcutDimCode: Code[20])
    begin
        DimMgt.LookupDimValueCode(FieldNumber,ShortcutDimCode);
        ValidateShortcutDimCode(FieldNumber,ShortcutDimCode);
    end;

    [Scope('Personalization')]
    procedure ShowShortcutDimCode(var ShortcutDimCode: array [8] of Code[20])
    begin
        DimMgt.GetShortcutDimensions("Dimension Set ID",ShortcutDimCode);
    end;

    procedure ShowItemSub()
    begin
        Clear(SalesHeader);
        TestStatusOpen;
        ItemSubstitutionMgt.ItemSubstGet(Rec);
        if TransferExtendedText.SalesCheckIfAnyExtText(Rec,true) then
          TransferExtendedText.InsertSalesExtText(Rec);

        OnAfterShowItemSub(Rec);
    end;

    [Scope('Personalization')]
    procedure ShowNonstock()
    begin
        TestField(Type,Type::Item);
        if "No." <> '' then
          Error(SelectNonstockItemErr);
        if PAGE.RunModal(PAGE::"Catalog Item List",NonstockItem) = ACTION::LookupOK then begin
          NonstockItem.TestField("Item Template Code");
          ConfigTemplateHeader.SetRange(Code,NonstockItem."Item Template Code");
          ConfigTemplateHeader.FindFirst;
          TempItemTemplate.InitializeTempRecordFromConfigTemplate(TempItemTemplate,ConfigTemplateHeader);
          TempItemTemplate.TestField("Gen. Prod. Posting Group");
          TempItemTemplate.TestField("Inventory Posting Group");

          "No." := NonstockItem."Entry No.";
          CatalogItemMgt.NonStockSales(Rec);
          Validate("No.","No.");
          Validate("Unit Price",NonstockItem."Unit Price");
        end;
    end;

    local procedure GetSalesSetup()
    begin
        if not SalesSetupRead then
          SalesSetup.Get;
        SalesSetupRead := true;
    end;

    local procedure GetFAPostingGroup()
    var
        LocalGLAcc: Record "G/L Account";
        FASetup: Record "FA Setup";
        FAPostingGr: Record "FA Posting Group";
        FADeprBook: Record "FA Depreciation Book";
    begin
        if (Type <> Type::"Fixed Asset") or ("No." = '') then
          exit;
        if "Depreciation Book Code" = '' then begin
          FASetup.Get;
          "Depreciation Book Code" := FASetup."Default Depr. Book";
          if not FADeprBook.Get("No.","Depreciation Book Code") then
            "Depreciation Book Code" := '';
          if "Depreciation Book Code" = '' then
            exit;
        end;
        FADeprBook.Get("No.","Depreciation Book Code");
        FADeprBook.TestField("FA Posting Group");
        FAPostingGr.Get(FADeprBook."FA Posting Group");
        LocalGLAcc.Get(FAPostingGr.GetAcquisitionCostAccountOnDisposal);
        LocalGLAcc.CheckGLAcc;
        LocalGLAcc.TestField("Gen. Prod. Posting Group");
        "Posting Group" := FADeprBook."FA Posting Group";
        "Gen. Prod. Posting Group" := LocalGLAcc."Gen. Prod. Posting Group";
        "Tax Group Code" := LocalGLAcc."Tax Group Code";
        Validate("VAT Prod. Posting Group",LocalGLAcc."VAT Prod. Posting Group");
    end;

    local procedure GetFieldCaption(FieldNumber: Integer): Text[100]
    var
        "Field": Record "Field";
    begin
        Field.Get(DATABASE::"Sales Line",FieldNumber);
        exit(Field."Field Caption");
    end;

    [Scope('Personalization')]
    procedure GetCaptionClass(FieldNumber: Integer): Text[80]
    var
        SalesHeader2: Record "Sales Header";
    begin
        if SalesHeader2.Get("Document Type","Document No.") then;
        case FieldNumber of
          FieldNo("No."):
            exit(StrSubstNo('3,%1',GetFieldCaption(FieldNumber)));
          else begin
            if SalesHeader2."Prices Including VAT" then
              exit('2,1,' + GetFieldCaption(FieldNumber));
            exit('2,0,' + GetFieldCaption(FieldNumber));
          end;
        end;
    end;

    local procedure GetSKU(): Boolean
    begin
        if (SKU."Location Code" = "Location Code") and
           (SKU."Item No." = "No.") and
           (SKU."Variant Code" = "Variant Code")
        then
          exit(true);
        if SKU.Get("Location Code","No.","Variant Code") then
          exit(true);

        exit(false);
    end;

    [Scope('Personalization')]
    procedure GetUnitCost()
    begin
        TestField(Type,Type::Item);
        TestField("No.");
        GetItem;
        "Qty. per Unit of Measure" := UOMMgt.GetQtyPerUnitOfMeasure(Item,"Unit of Measure Code");
        if GetSKU then
          Validate("Unit Cost (LCY)",SKU."Unit Cost" * "Qty. per Unit of Measure")
        else
          Validate("Unit Cost (LCY)",Item."Unit Cost" * "Qty. per Unit of Measure");

        OnAfterGetUnitCost(Rec,Item);
    end;

    local procedure CalcUnitCost(ItemLedgEntry: Record "Item Ledger Entry"): Decimal
    var
        ValueEntry: Record "Value Entry";
        UnitCost: Decimal;
    begin
        with ValueEntry do begin
          SetCurrentKey("Item Ledger Entry No.");
          SetRange("Item Ledger Entry No.",ItemLedgEntry."Entry No.");
          if IsNonInventoriableItem then begin
            CalcSums("Cost Amount (Non-Invtbl.)");
            UnitCost := "Cost Amount (Non-Invtbl.)" / ItemLedgEntry.Quantity;
          end else begin
            CalcSums("Cost Amount (Actual)","Cost Amount (Expected)");
            UnitCost :=
              ("Cost Amount (Expected)" + "Cost Amount (Actual)") / ItemLedgEntry.Quantity;
          end;
        end;

        exit(Abs(UnitCost * "Qty. per Unit of Measure"));
    end;

    [Scope('Personalization')]
    procedure ShowItemChargeAssgnt()
    var
        ItemChargeAssgntSales: Record "Item Charge Assignment (Sales)";
        AssignItemChargeSales: Codeunit "Item Charge Assgnt. (Sales)";
        ItemChargeAssgnts: Page "Item Charge Assignment (Sales)";
        ItemChargeAssgntLineAmt: Decimal;
    begin
        Get("Document Type","Document No.","Line No.");
        TestField("No.");
        TestField(Quantity);

        if Type <> Type::"Charge (Item)" then
          Error(ItemChargeAssignmentErr);

        GetSalesHeader;
        if SalesHeader."Currency Code" = '' then
          Currency.InitRoundingPrecision
        else
          Currency.Get(SalesHeader."Currency Code");
        if ("Inv. Discount Amount" = 0) and
           ("Line Discount Amount" = 0) and
           (not SalesHeader."Prices Including VAT")
        then
          ItemChargeAssgntLineAmt := "Line Amount"
        else
          if SalesHeader."Prices Including VAT" then
            ItemChargeAssgntLineAmt :=
              Round(CalcLineAmount / (1 + "VAT %" / 100),Currency."Amount Rounding Precision")
          else
            ItemChargeAssgntLineAmt := CalcLineAmount;

        ItemChargeAssgntSales.Reset;
        ItemChargeAssgntSales.SetRange("Document Type","Document Type");
        ItemChargeAssgntSales.SetRange("Document No.","Document No.");
        ItemChargeAssgntSales.SetRange("Document Line No.","Line No.");
        ItemChargeAssgntSales.SetRange("Item Charge No.","No.");
        if not ItemChargeAssgntSales.FindLast then begin
          ItemChargeAssgntSales."Document Type" := "Document Type";
          ItemChargeAssgntSales."Document No." := "Document No.";
          ItemChargeAssgntSales."Document Line No." := "Line No.";
          ItemChargeAssgntSales."Item Charge No." := "No.";
          ItemChargeAssgntSales."Unit Cost" :=
            Round(ItemChargeAssgntLineAmt / Quantity,
              Currency."Unit-Amount Rounding Precision");
        end;

        ItemChargeAssgntLineAmt :=
          Round(
            ItemChargeAssgntLineAmt * ("Qty. to Invoice" / Quantity),
            Currency."Amount Rounding Precision");

        if "Document Type" in ["Document Type"::"Return Order","Document Type"::"Credit Memo"] then
          AssignItemChargeSales.CreateDocChargeAssgn(ItemChargeAssgntSales,"Return Receipt No.")
        else
          AssignItemChargeSales.CreateDocChargeAssgn(ItemChargeAssgntSales,"Shipment No.");
        Clear(AssignItemChargeSales);
        Commit;

        ItemChargeAssgnts.Initialize(Rec,ItemChargeAssgntLineAmt);
        ItemChargeAssgnts.RunModal;
        CalcFields("Qty. to Assign");
    end;

    [Scope('Personalization')]
    procedure UpdateItemChargeAssgnt()
    var
        ItemChargeAssgntSales: Record "Item Charge Assignment (Sales)";
        ShareOfVAT: Decimal;
        TotalQtyToAssign: Decimal;
        TotalAmtToAssign: Decimal;
    begin
        if "Document Type" = "Document Type"::"Blanket Order" then
          exit;

        CalcFields("Qty. Assigned","Qty. to Assign");
        if Abs("Quantity Invoiced") > Abs(("Qty. Assigned" + "Qty. to Assign")) then
          Error(Text055,FieldCaption("Quantity Invoiced"),FieldCaption("Qty. Assigned"),FieldCaption("Qty. to Assign"));

        ItemChargeAssgntSales.Reset;
        ItemChargeAssgntSales.SetRange("Document Type","Document Type");
        ItemChargeAssgntSales.SetRange("Document No.","Document No.");
        ItemChargeAssgntSales.SetRange("Document Line No.","Line No.");
        ItemChargeAssgntSales.CalcSums("Qty. to Assign");
        TotalQtyToAssign := ItemChargeAssgntSales."Qty. to Assign";
        if (CurrFieldNo <> 0) and (Amount <> xRec.Amount) and
           not ((Quantity <> xRec.Quantity) and (TotalQtyToAssign = 0))
        then begin
          ItemChargeAssgntSales.SetFilter("Qty. Assigned",'<>0');
          if not ItemChargeAssgntSales.IsEmpty then
            Error(Text026,
              FieldCaption(Amount));
          ItemChargeAssgntSales.SetRange("Qty. Assigned");
        end;

        if ItemChargeAssgntSales.FindSet(true) then begin
          GetSalesHeader;
          TotalAmtToAssign := CalcTotalAmtToAssign(TotalQtyToAssign);
          repeat
            ShareOfVAT := 1;
            if SalesHeader."Prices Including VAT" then
              ShareOfVAT := 1 + "VAT %" / 100;
            if Quantity <> 0 then
              if ItemChargeAssgntSales."Unit Cost" <>
                 Round(CalcLineAmount / Quantity / ShareOfVAT,Currency."Unit-Amount Rounding Precision")
              then
                ItemChargeAssgntSales."Unit Cost" :=
                  Round(CalcLineAmount / Quantity / ShareOfVAT,Currency."Unit-Amount Rounding Precision");
            if TotalQtyToAssign <> 0 then begin
              ItemChargeAssgntSales."Amount to Assign" :=
                Round(ItemChargeAssgntSales."Qty. to Assign" / TotalQtyToAssign * TotalAmtToAssign,
                  Currency."Amount Rounding Precision");
              TotalQtyToAssign -= ItemChargeAssgntSales."Qty. to Assign";
              TotalAmtToAssign -= ItemChargeAssgntSales."Amount to Assign";
            end;
            ItemChargeAssgntSales.Modify;
          until ItemChargeAssgntSales.Next = 0;
          CalcFields("Qty. to Assign");
        end;
    end;

    local procedure DeleteItemChargeAssgnt(DocType: Option;DocNo: Code[20];DocLineNo: Integer)
    var
        ItemChargeAssgntSales: Record "Item Charge Assignment (Sales)";
    begin
        ItemChargeAssgntSales.SetRange("Applies-to Doc. Type",DocType);
        ItemChargeAssgntSales.SetRange("Applies-to Doc. No.",DocNo);
        ItemChargeAssgntSales.SetRange("Applies-to Doc. Line No.",DocLineNo);
        if not ItemChargeAssgntSales.IsEmpty then
          ItemChargeAssgntSales.DeleteAll(true);
    end;

    local procedure DeleteChargeChargeAssgnt(DocType: Option;DocNo: Code[20];DocLineNo: Integer)
    var
        ItemChargeAssgntSales: Record "Item Charge Assignment (Sales)";
    begin
        if DocType <> "Document Type"::"Blanket Order" then
          if "Quantity Invoiced" <> 0 then begin
            CalcFields("Qty. Assigned");
            TestField("Qty. Assigned","Quantity Invoiced");
          end;

        ItemChargeAssgntSales.Reset;
        ItemChargeAssgntSales.SetRange("Document Type",DocType);
        ItemChargeAssgntSales.SetRange("Document No.",DocNo);
        ItemChargeAssgntSales.SetRange("Document Line No.",DocLineNo);
        if not ItemChargeAssgntSales.IsEmpty then
          ItemChargeAssgntSales.DeleteAll;
    end;

    local procedure CheckItemChargeAssgnt()
    var
        ItemChargeAssgntSales: Record "Item Charge Assignment (Sales)";
    begin
        ItemChargeAssgntSales.SetRange("Applies-to Doc. Type","Document Type");
        ItemChargeAssgntSales.SetRange("Applies-to Doc. No.","Document No.");
        ItemChargeAssgntSales.SetRange("Applies-to Doc. Line No.","Line No.");
        ItemChargeAssgntSales.SetRange("Document Type","Document Type");
        ItemChargeAssgntSales.SetRange("Document No.","Document No.");
        if ItemChargeAssgntSales.FindSet then begin
          TestField("Allow Item Charge Assignment");
          repeat
            ItemChargeAssgntSales.TestField("Qty. to Assign",0);
          until ItemChargeAssgntSales.Next = 0;
        end;
    end;

    [Scope('Personalization')]
    procedure TestStatusOpen()
    begin
        if StatusCheckSuspended then
          exit;
        GetSalesHeader;
        if not "System-Created Entry" then
          if HasTypeToFillMandatoryFields then
            SalesHeader.TestField(Status,SalesHeader.Status::Open);

        OnAfterTestStatusOpen(Rec,SalesHeader);
    end;

    [Scope('Personalization')]
    procedure SuspendStatusCheck(Suspend: Boolean)
    begin
        StatusCheckSuspended := Suspend;
    end;

    [Scope('Personalization')]
    procedure UpdateVATOnLines(QtyType: Option General,Invoicing,Shipping;var SalesHeader: Record "Sales Header";var SalesLine: Record "Sales Line";var VATAmountLine: Record "VAT Amount Line") LineWasModified: Boolean
    var
        TempVATAmountLineRemainder: Record "VAT Amount Line" temporary;
        Currency: Record Currency;
        NewAmount: Decimal;
        NewAmountIncludingVAT: Decimal;
        NewVATBaseAmount: Decimal;
        VATAmount: Decimal;
        VATDifference: Decimal;
        InvDiscAmount: Decimal;
        LineAmountToInvoice: Decimal;
        LineAmountToInvoiceDiscounted: Decimal;
        DeferralAmount: Decimal;
    begin
        LineWasModified := false;
        if QtyType = QtyType::Shipping then
          exit;
        if SalesHeader."Currency Code" = '' then
          Currency.InitRoundingPrecision
        else
          Currency.Get(SalesHeader."Currency Code");

        TempVATAmountLineRemainder.DeleteAll;

        with SalesLine do begin
          SetRange("Document Type",SalesHeader."Document Type");
          SetRange("Document No.",SalesHeader."No.");
          LockTable;
          if FindSet then
            repeat
              if not ZeroAmountLine(QtyType) then begin
                DeferralAmount := GetDeferralAmount;
                VATAmountLine.Get("VAT Identifier","VAT Calculation Type","Tax Group Code",false,"Line Amount" >= 0);
                if VATAmountLine.Modified then begin
                  if not TempVATAmountLineRemainder.Get(
                       "VAT Identifier","VAT Calculation Type","Tax Group Code",false,"Line Amount" >= 0)
                  then begin
                    TempVATAmountLineRemainder := VATAmountLine;
                    TempVATAmountLineRemainder.Init;
                    TempVATAmountLineRemainder.Insert;
                  end;

                  if QtyType = QtyType::General then
                    LineAmountToInvoice := "Line Amount"
                  else
                    LineAmountToInvoice :=
                      Round("Line Amount" * "Qty. to Invoice" / Quantity,Currency."Amount Rounding Precision");

                  if "Allow Invoice Disc." then begin
                    if (VATAmountLine."Inv. Disc. Base Amount" = 0) or (LineAmountToInvoice = 0) then
                      InvDiscAmount := 0
                    else begin
                      LineAmountToInvoiceDiscounted :=
                        VATAmountLine."Invoice Discount Amount" * LineAmountToInvoice /
                        VATAmountLine."Inv. Disc. Base Amount";
                      TempVATAmountLineRemainder."Invoice Discount Amount" :=
                        TempVATAmountLineRemainder."Invoice Discount Amount" + LineAmountToInvoiceDiscounted;
                      InvDiscAmount :=
                        Round(
                          TempVATAmountLineRemainder."Invoice Discount Amount",Currency."Amount Rounding Precision");
                      TempVATAmountLineRemainder."Invoice Discount Amount" :=
                        TempVATAmountLineRemainder."Invoice Discount Amount" - InvDiscAmount;
                    end;
                    if QtyType = QtyType::General then begin
                      "Inv. Discount Amount" := InvDiscAmount;
                      CalcInvDiscToInvoice;
                    end else
                      "Inv. Disc. Amount to Invoice" := InvDiscAmount;
                  end else
                    InvDiscAmount := 0;

                  if QtyType = QtyType::General then
                    if SalesHeader."Prices Including VAT" then begin
                      if (VATAmountLine.CalcLineAmount = 0) or ("Line Amount" = 0) then begin
                        VATAmount := 0;
                        NewAmountIncludingVAT := 0;
                      end else begin
                        VATAmount :=
                          TempVATAmountLineRemainder."VAT Amount" +
                          VATAmountLine."VAT Amount" * CalcLineAmount / VATAmountLine.CalcLineAmount;
                        NewAmountIncludingVAT :=
                          TempVATAmountLineRemainder."Amount Including VAT" +
                          VATAmountLine."Amount Including VAT" * CalcLineAmount / VATAmountLine.CalcLineAmount;
                      end;
                      NewAmount :=
                        Round(NewAmountIncludingVAT,Currency."Amount Rounding Precision") -
                        Round(VATAmount,Currency."Amount Rounding Precision");
                      NewVATBaseAmount :=
                        Round(
                          NewAmount * (1 - SalesHeader."VAT Base Discount %" / 100),Currency."Amount Rounding Precision");
                    end else begin
                      if "VAT Calculation Type" = "VAT Calculation Type"::"Full VAT" then begin
                        VATAmount := CalcLineAmount;
                        NewAmount := 0;
                        NewVATBaseAmount := 0;
                      end else begin
                        NewAmount := CalcLineAmount;
                        NewVATBaseAmount :=
                          Round(
                            NewAmount * (1 - SalesHeader."VAT Base Discount %" / 100),Currency."Amount Rounding Precision");
                        if VATAmountLine."VAT Base" = 0 then
                          VATAmount := 0
                        else
                          VATAmount :=
                            TempVATAmountLineRemainder."VAT Amount" +
                            VATAmountLine."VAT Amount" * NewAmount / VATAmountLine."VAT Base";
                      end;
                      NewAmountIncludingVAT := NewAmount + Round(VATAmount,Currency."Amount Rounding Precision");
                    end
                  else begin
                    if VATAmountLine.CalcLineAmount = 0 then
                      VATDifference := 0
                    else
                      VATDifference :=
                        TempVATAmountLineRemainder."VAT Difference" +
                        VATAmountLine."VAT Difference" * (LineAmountToInvoice - InvDiscAmount) / VATAmountLine.CalcLineAmount;
                    if LineAmountToInvoice = 0 then
                      "VAT Difference" := 0
                    else
                      "VAT Difference" := Round(VATDifference,Currency."Amount Rounding Precision");
                  end;
                  if QtyType = QtyType::General then
                    UpdateBaseAmounts(NewAmount,Round(NewAmountIncludingVAT,Currency."Amount Rounding Precision"),NewVATBaseAmount);
                  InitOutstanding;
                  if Type = Type::"Charge (Item)" then
                    UpdateItemChargeAssgnt;
                  Modify;
                  LineWasModified := true;

                  if ("Deferral Code" <> '') and (DeferralAmount <> GetDeferralAmount) then
                    UpdateDeferralAmounts;

                  TempVATAmountLineRemainder."Amount Including VAT" :=
                    NewAmountIncludingVAT - Round(NewAmountIncludingVAT,Currency."Amount Rounding Precision");
                  TempVATAmountLineRemainder."VAT Amount" := VATAmount - NewAmountIncludingVAT + NewAmount;
                  TempVATAmountLineRemainder."VAT Difference" := VATDifference - "VAT Difference";
                  TempVATAmountLineRemainder.Modify;
                end;
              end;
            until Next = 0;
        end;

        OnAfterUpdateVATOnLines(SalesHeader,SalesLine,VATAmountLine,QtyType);
    end;

    [Scope('Personalization')]
    procedure CalcVATAmountLines(QtyType: Option General,Invoicing,Shipping;var SalesHeader: Record "Sales Header";var SalesLine: Record "Sales Line";var VATAmountLine: Record "VAT Amount Line")
    var
        TotalVATAmount: Decimal;
        QtyToHandle: Decimal;
        AmtToHandle: Decimal;
        RoundingLineInserted: Boolean;
    begin
        Currency.Initialize(SalesHeader."Currency Code");

        VATAmountLine.DeleteAll;

        with SalesLine do begin
          SetRange("Document Type",SalesHeader."Document Type");
          SetRange("Document No.",SalesHeader."No.");
          if FindSet then
            repeat
              if not ZeroAmountLine(QtyType) then begin
                if (Type = Type::"G/L Account") and not "Prepayment Line" then
                  RoundingLineInserted := ("No." = GetCPGInvRoundAcc(SalesHeader)) or RoundingLineInserted;
                if "VAT Calculation Type" in
                   ["VAT Calculation Type"::"Reverse Charge VAT","VAT Calculation Type"::"Sales Tax"]
                then
                  "VAT %" := 0;
                if not VATAmountLine.Get(
                     "VAT Identifier","VAT Calculation Type","Tax Group Code",false,"Line Amount" >= 0)
                then
                  VATAmountLine.InsertNewLine(
                    "VAT Identifier","VAT Calculation Type","Tax Group Code",false,"VAT %","Line Amount" >= 0,false);

                case QtyType of
                  QtyType::General:
                    begin
                      VATAmountLine.Quantity += "Quantity (Base)";
                      VATAmountLine.SumLine(
                        "Line Amount","Inv. Discount Amount","VAT Difference","Allow Invoice Disc.","Prepayment Line");
                    end;
                  QtyType::Invoicing:
                    begin
                      case true of
                        ("Document Type" in ["Document Type"::Order,"Document Type"::Invoice]) and
                        (not SalesHeader.Ship) and SalesHeader.Invoice and (not "Prepayment Line"):
                          if "Shipment No." = '' then begin
                            QtyToHandle := GetAbsMin("Qty. to Invoice","Qty. Shipped Not Invoiced");
                            VATAmountLine.Quantity += GetAbsMin("Qty. to Invoice (Base)","Qty. Shipped Not Invd. (Base)");
                          end else begin
                            QtyToHandle := "Qty. to Invoice";
                            VATAmountLine.Quantity += "Qty. to Invoice (Base)";
                          end;
                        ("Document Type" in ["Document Type"::"Return Order","Document Type"::"Credit Memo"]) and
                        (not SalesHeader.Receive) and SalesHeader.Invoice:
                          if "Return Receipt No." = '' then begin
                            QtyToHandle := GetAbsMin("Qty. to Invoice","Return Qty. Rcd. Not Invd.");
                            VATAmountLine.Quantity += GetAbsMin("Qty. to Invoice (Base)","Ret. Qty. Rcd. Not Invd.(Base)");
                          end else begin
                            QtyToHandle := "Qty. to Invoice";
                            VATAmountLine.Quantity += "Qty. to Invoice (Base)";
                          end;
                        else
                          begin
                          QtyToHandle := "Qty. to Invoice";
                          VATAmountLine.Quantity += "Qty. to Invoice (Base)";
                        end;
                      end;
                      AmtToHandle := GetLineAmountToHandle(QtyToHandle);
                      if SalesHeader."Invoice Discount Calculation" <> SalesHeader."Invoice Discount Calculation"::Amount then
                        VATAmountLine.SumLine(
                          AmtToHandle,Round("Inv. Discount Amount" * QtyToHandle / Quantity,Currency."Amount Rounding Precision"),
                          "VAT Difference","Allow Invoice Disc.","Prepayment Line")
                      else
                        VATAmountLine.SumLine(
                          AmtToHandle,"Inv. Disc. Amount to Invoice","VAT Difference","Allow Invoice Disc.","Prepayment Line");
                    end;
                  QtyType::Shipping:
                    begin
                      if "Document Type" in
                         ["Document Type"::"Return Order","Document Type"::"Credit Memo"]
                      then begin
                        QtyToHandle := "Return Qty. to Receive";
                        VATAmountLine.Quantity += "Return Qty. to Receive (Base)";
                      end else begin
                        QtyToHandle := "Qty. to Ship";
                        VATAmountLine.Quantity += "Qty. to Ship (Base)";
                      end;
                      AmtToHandle := GetLineAmountToHandle(QtyToHandle);
                      VATAmountLine.SumLine(
                        AmtToHandle,Round("Inv. Discount Amount" * QtyToHandle / Quantity,Currency."Amount Rounding Precision"),
                        "VAT Difference","Allow Invoice Disc.","Prepayment Line");
                    end;
                end;
                TotalVATAmount += "Amount Including VAT" - Amount;
              end;
            until Next = 0;
        end;

        VATAmountLine.UpdateLines(
          TotalVATAmount,Currency,SalesHeader."Currency Factor",SalesHeader."Prices Including VAT",
          SalesHeader."VAT Base Discount %",SalesHeader."Tax Area Code",SalesHeader."Tax Liable",SalesHeader."Posting Date");

        if RoundingLineInserted and (TotalVATAmount <> 0) then
          if VATAmountLine.Get(SalesLine."VAT Identifier",SalesLine."VAT Calculation Type",
               SalesLine."Tax Group Code",false,SalesLine."Line Amount" >= 0)
          then begin
            VATAmountLine."VAT Amount" += TotalVATAmount;
            VATAmountLine."Amount Including VAT" += TotalVATAmount;
            VATAmountLine."Calculated VAT Amount" += TotalVATAmount;
            VATAmountLine.Modify;
          end;

        OnAfterCalcVATAmountLines(SalesHeader,SalesLine,VATAmountLine,QtyType);
    end;

    [Scope('Personalization')]
    procedure GetCPGInvRoundAcc(var SalesHeader: Record "Sales Header"): Code[20]
    var
        Cust: Record Customer;
        CustTemplate: Record "Customer Template";
        CustPostingGroup: Record "Customer Posting Group";
    begin
        GetSalesSetup;
        if SalesSetup."Invoice Rounding" then
          if Cust.Get(SalesHeader."Bill-to Customer No.") then
            CustPostingGroup.Get(Cust."Customer Posting Group")
          else
            if CustTemplate.Get(SalesHeader."Sell-to Customer Template Code") then
              CustPostingGroup.Get(CustTemplate."Customer Posting Group");

        exit(CustPostingGroup."Invoice Rounding Account");
    end;

    local procedure CalcInvDiscToInvoice()
    var
        OldInvDiscAmtToInv: Decimal;
    begin
        GetSalesHeader;
        OldInvDiscAmtToInv := "Inv. Disc. Amount to Invoice";
        if Quantity = 0 then
          Validate("Inv. Disc. Amount to Invoice",0)
        else
          Validate(
            "Inv. Disc. Amount to Invoice",
            Round(
              "Inv. Discount Amount" * "Qty. to Invoice" / Quantity,
              Currency."Amount Rounding Precision"));

        if OldInvDiscAmtToInv <> "Inv. Disc. Amount to Invoice" then begin
          "Amount Including VAT" := "Amount Including VAT" - "VAT Difference";
          "VAT Difference" := 0;
        end;
    end;

    [Scope('Personalization')]
    procedure UpdateWithWarehouseShip()
    begin
        if Type = Type::Item then
          case true of
            ("Document Type" in ["Document Type"::Quote,"Document Type"::Order]) and (Quantity >= 0):
              if Location.RequireShipment("Location Code") then
                Validate("Qty. to Ship",0)
              else
                Validate("Qty. to Ship","Outstanding Quantity");
            ("Document Type" in ["Document Type"::Quote,"Document Type"::Order]) and (Quantity < 0):
              if Location.RequireReceive("Location Code") then
                Validate("Qty. to Ship",0)
              else
                Validate("Qty. to Ship","Outstanding Quantity");
            ("Document Type" = "Document Type"::"Return Order") and (Quantity >= 0):
              if Location.RequireReceive("Location Code") then
                Validate("Return Qty. to Receive",0)
              else
                Validate("Return Qty. to Receive","Outstanding Quantity");
            ("Document Type" = "Document Type"::"Return Order") and (Quantity < 0):
              if Location.RequireShipment("Location Code") then
                Validate("Return Qty. to Receive",0)
              else
                Validate("Return Qty. to Receive","Outstanding Quantity");
          end;
        SetDefaultQuantity;
    end;

    local procedure CheckWarehouse()
    var
        Location2: Record Location;
        WhseSetup: Record "Warehouse Setup";
        ShowDialog: Option " ",Message,Error;
        DialogText: Text[50];
    begin
        GetLocation("Location Code");
        if "Location Code" = '' then begin
          WhseSetup.Get;
          Location2."Require Shipment" := WhseSetup."Require Shipment";
          Location2."Require Pick" := WhseSetup."Require Pick";
          Location2."Require Receive" := WhseSetup."Require Receive";
          Location2."Require Put-away" := WhseSetup."Require Put-away";
        end else
          Location2 := Location;

        DialogText := Text035;
        if ("Document Type" in ["Document Type"::Order,"Document Type"::"Return Order"]) and
           Location2."Directed Put-away and Pick"
        then begin
          ShowDialog := ShowDialog::Error;
          if (("Document Type" = "Document Type"::Order) and (Quantity >= 0)) or
             (("Document Type" = "Document Type"::"Return Order") and (Quantity < 0))
          then
            DialogText :=
              DialogText + Location2.GetRequirementText(Location2.FieldNo("Require Shipment"))
          else
            DialogText :=
              DialogText + Location2.GetRequirementText(Location2.FieldNo("Require Receive"));
        end else begin
          if (("Document Type" = "Document Type"::Order) and (Quantity >= 0) and
              (Location2."Require Shipment" or Location2."Require Pick")) or
             (("Document Type" = "Document Type"::"Return Order") and (Quantity < 0) and
              (Location2."Require Shipment" or Location2."Require Pick"))
          then begin
            if WhseValidateSourceLine.WhseLinesExist(
                 DATABASE::"Sales Line",
                 "Document Type",
                 "Document No.",
                 "Line No.",
                 0,
                 Quantity)
            then
              ShowDialog := ShowDialog::Error
            else
              if Location2."Require Shipment" then
                ShowDialog := ShowDialog::Message;
            if Location2."Require Shipment" then
              DialogText :=
                DialogText + Location2.GetRequirementText(Location2.FieldNo("Require Shipment"))
            else begin
              DialogText := Text036;
              DialogText :=
                DialogText + Location2.GetRequirementText(Location2.FieldNo("Require Pick"));
            end;
          end;

          if (("Document Type" = "Document Type"::Order) and (Quantity < 0) and
              (Location2."Require Receive" or Location2."Require Put-away")) or
             (("Document Type" = "Document Type"::"Return Order") and (Quantity >= 0) and
              (Location2."Require Receive" or Location2."Require Put-away"))
          then begin
            if WhseValidateSourceLine.WhseLinesExist(
                 DATABASE::"Sales Line",
                 "Document Type",
                 "Document No.",
                 "Line No.",
                 0,
                 Quantity)
            then
              ShowDialog := ShowDialog::Error
            else
              if Location2."Require Receive" then
                ShowDialog := ShowDialog::Message;
            if Location2."Require Receive" then
              DialogText :=
                DialogText + Location2.GetRequirementText(Location2.FieldNo("Require Receive"))
            else begin
              DialogText := Text036;
              DialogText :=
                DialogText + Location2.GetRequirementText(Location2.FieldNo("Require Put-away"));
            end;
          end;
        end;

        case ShowDialog of
          ShowDialog::Message:
            Message(Text016 + Text017,DialogText,FieldCaption("Line No."),"Line No.");
          ShowDialog::Error:
            Error(Text016,DialogText,FieldCaption("Line No."),"Line No.");
        end;

        HandleDedicatedBin(true);
    end;

    local procedure UpdateDates()
    begin
        if CurrFieldNo = 0 then begin
          PlannedShipmentDateCalculated := false;
          PlannedDeliveryDateCalculated := false;
        end;
        if "Promised Delivery Date" <> 0D then
          Validate("Promised Delivery Date")
        else
          if "Requested Delivery Date" <> 0D then
            Validate("Requested Delivery Date")
          else
            Validate("Shipment Date");
    end;

    [Scope('Personalization')]
    procedure GetItemTranslation()
    var
        ItemTranslation: Record "Item Translation";
    begin
        GetSalesHeader;
        if ItemTranslation.Get("No.","Variant Code",SalesHeader."Language Code") then begin
          Description := ItemTranslation.Description;
          "Description 2" := ItemTranslation."Description 2";
        end;
    end;

    local procedure GetLocation(LocationCode: Code[10])
    begin
        if LocationCode = '' then
          Clear(Location)
        else
          if Location.Code <> LocationCode then
            Location.Get(LocationCode);
    end;

    [Scope('Personalization')]
    procedure PriceExists(): Boolean
    begin
        if "Document No." <> '' then begin
          GetSalesHeader;
          exit(PriceCalcMgt.SalesLinePriceExists(SalesHeader,Rec,true));
        end;
        exit(false);
    end;

    [Scope('Personalization')]
    procedure LineDiscExists(): Boolean
    begin
        if "Document No." <> '' then begin
          GetSalesHeader;
          exit(PriceCalcMgt.SalesLineLineDiscExists(SalesHeader,Rec,true));
        end;
        exit(false);
    end;

    [Scope('Personalization')]
    procedure RowID1(): Text[250]
    var
        ItemTrackingMgt: Codeunit "Item Tracking Management";
    begin
        exit(ItemTrackingMgt.ComposeRowID(DATABASE::"Sales Line","Document Type",
            "Document No.",'',0,"Line No."));
    end;

    local procedure UpdateItemCrossRef()
    begin
        DistIntegration.EnterSalesItemCrossRef(Rec);
        UpdateICPartner;
    end;

    local procedure GetDefaultBin()
    var
        WMSManagement: Codeunit "WMS Management";
    begin
        if Type <> Type::Item then
          exit;

        "Bin Code" := '';
        if "Drop Shipment" then
          exit;

        if ("Location Code" <> '') and ("No." <> '') then begin
          GetLocation("Location Code");
          if Location."Bin Mandatory" and not Location."Directed Put-away and Pick" then begin
            if ("Qty. to Assemble to Order" > 0) or IsAsmToOrderRequired then
              if GetATOBin(Location,"Bin Code") then
                exit;

            WMSManagement.GetDefaultBin("No.","Variant Code","Location Code","Bin Code");
            HandleDedicatedBin(false);
          end;
        end;
    end;

    [Scope('Personalization')]
    procedure GetATOBin(Location: Record Location;var BinCode: Code[20]): Boolean
    var
        AsmHeader: Record "Assembly Header";
    begin
        if not Location."Require Shipment" then
          BinCode := Location."Asm.-to-Order Shpt. Bin Code";
        if BinCode <> '' then
          exit(true);

        if AsmHeader.GetFromAssemblyBin(Location,BinCode) then
          exit(true);

        exit(false);
    end;

    [Scope('Personalization')]
    procedure IsInbound(): Boolean
    begin
        case "Document Type" of
          "Document Type"::Order,"Document Type"::Invoice,"Document Type"::Quote,"Document Type"::"Blanket Order":
            exit("Quantity (Base)" < 0);
          "Document Type"::"Return Order","Document Type"::"Credit Memo":
            exit("Quantity (Base)" > 0);
        end;

        exit(false);
    end;

    local procedure HandleDedicatedBin(IssueWarning: Boolean)
    var
        WhseIntegrationMgt: Codeunit "Whse. Integration Management";
    begin
        if not IsInbound and ("Quantity (Base)" <> 0) then
          WhseIntegrationMgt.CheckIfBinDedicatedOnSrcDoc("Location Code","Bin Code",IssueWarning);
    end;

    local procedure CheckAssocPurchOrder(TheFieldCaption: Text[250])
    var
        IsHandled: Boolean;
    begin
        OnBeforeCheckAssocPurchOrder(Rec,TheFieldCaption,IsHandled);

        if TheFieldCaption = '' then begin // If sales line is being deleted
          if "Purch. Order Line No." <> 0 then
            Error(Text000,"Purchase Order No.","Purch. Order Line No.");
          if "Special Order Purch. Line No." <> 0 then
            Error(Text000,"Special Order Purchase No.","Special Order Purch. Line No.");
        end;

        if "Purch. Order Line No." <> 0 then
          Error(Text002,TheFieldCaption,"Purchase Order No.","Purch. Order Line No.");

        if "Special Order Purch. Line No." <> 0 then
          Error(Text002,TheFieldCaption,"Special Order Purchase No.","Special Order Purch. Line No.");
    end;

    procedure CrossReferenceNoLookUp()
    var
        ItemCrossReference: Record "Item Cross Reference";
        ICGLAcc: Record "IC G/L Account";
    begin
        case Type of
          Type::Item:
            begin
              GetSalesHeader;
              ItemCrossReference.Reset;
              ItemCrossReference.SetCurrentKey("Cross-Reference Type","Cross-Reference Type No.");
              ItemCrossReference.SetFilter(
                "Cross-Reference Type",'%1|%2',
                ItemCrossReference."Cross-Reference Type"::Customer,
                ItemCrossReference."Cross-Reference Type"::" ");
              ItemCrossReference.SetFilter("Cross-Reference Type No.",'%1|%2',SalesHeader."Sell-to Customer No.",'');
              if PAGE.RunModal(PAGE::"Cross Reference List",ItemCrossReference) = ACTION::LookupOK then begin
                Validate("Cross-Reference No.",ItemCrossReference."Cross-Reference No.");
                PriceCalcMgt.FindSalesLineLineDisc(SalesHeader,Rec);
                PriceCalcMgt.FindSalesLinePrice(SalesHeader,Rec,FieldNo("Cross-Reference No."));
                Validate("Unit Price");
              end;
            end;
          Type::"G/L Account",Type::Resource:
            begin
              GetSalesHeader;
              SalesHeader.TestField("Sell-to IC Partner Code");
              if PAGE.RunModal(PAGE::"IC G/L Account List",ICGLAcc) = ACTION::LookupOK then
                "Cross-Reference No." := ICGLAcc."No.";
            end;
        end;
    end;

    local procedure CheckServItemCreation()
    var
        ServItemGroup: Record "Service Item Group";
    begin
        if CurrFieldNo = 0 then
          exit;
        if Type <> Type::Item then
          exit;
        Item.Get("No.");
        if Item."Service Item Group" = '' then
          exit;
        if ServItemGroup.Get(Item."Service Item Group") then
          if ServItemGroup."Create Service Item" then
            if "Qty. to Ship (Base)" <> Round("Qty. to Ship (Base)",1) then
              Error(
                Text034,
                FieldCaption("Qty. to Ship (Base)"),
                ServItemGroup.FieldCaption("Create Service Item"));
    end;

    [Scope('Personalization')]
    procedure ItemExists(ItemNo: Code[20]): Boolean
    var
        Item2: Record Item;
    begin
        if Type = Type::Item then
          if not Item2.Get(ItemNo) then
            exit(false);
        exit(true);
    end;

    [Scope('Personalization')]
    procedure IsShipment(): Boolean
    begin
        exit(SignedXX("Quantity (Base)") < 0);
    end;

    local procedure GetAbsMin(QtyToHandle: Decimal;QtyHandled: Decimal): Decimal
    begin
        if Abs(QtyHandled) < Abs(QtyToHandle) then
          exit(QtyHandled);

        exit(QtyToHandle);
    end;

    [Scope('Personalization')]
    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    local procedure GetHideValidationDialog(): Boolean
    var
        IdentityManagement: Codeunit "Identity Management";
    begin
        exit(HideValidationDialog or IdentityManagement.IsInvAppId);
    end;

    local procedure CheckApplFromItemLedgEntry(var ItemLedgEntry: Record "Item Ledger Entry")
    var
        ItemTrackingLines: Page "Item Tracking Lines";
        QtyNotReturned: Decimal;
        QtyReturned: Decimal;
    begin
        if "Appl.-from Item Entry" = 0 then
          exit;

        if "Shipment No." <> '' then
          exit;

        TestField(Type,Type::Item);
        TestField(Quantity);
        if "Document Type" in ["Document Type"::"Return Order","Document Type"::"Credit Memo"] then begin
          if Quantity < 0 then
            FieldError(Quantity,Text029);
        end else begin
          if Quantity > 0 then
            FieldError(Quantity,Text030);
        end;

        ItemLedgEntry.Get("Appl.-from Item Entry");
        ItemLedgEntry.TestField(Positive,false);
        ItemLedgEntry.TestField("Item No.","No.");
        ItemLedgEntry.TestField("Variant Code","Variant Code");
        if ItemLedgEntry.TrackingExists then
          Error(Text040,ItemTrackingLines.Caption,FieldCaption("Appl.-from Item Entry"));

        if Abs("Quantity (Base)") > -ItemLedgEntry.Quantity then
          Error(
            Text046,
            -ItemLedgEntry.Quantity,ItemLedgEntry.FieldCaption("Document No."),
            ItemLedgEntry."Document No.");

        if "Document Type" in ["Document Type"::"Return Order","Document Type"::"Credit Memo"] then
          if Abs("Outstanding Qty. (Base)") > -ItemLedgEntry."Shipped Qty. Not Returned" then begin
            QtyNotReturned := ItemLedgEntry."Shipped Qty. Not Returned";
            QtyReturned := ItemLedgEntry.Quantity - ItemLedgEntry."Shipped Qty. Not Returned";
            if "Qty. per Unit of Measure" <> 0 then begin
              QtyNotReturned :=
                Round(ItemLedgEntry."Shipped Qty. Not Returned" / "Qty. per Unit of Measure",0.00001);
              QtyReturned :=
                Round(
                  (ItemLedgEntry.Quantity - ItemLedgEntry."Shipped Qty. Not Returned") /
                  "Qty. per Unit of Measure",0.00001);
            end;
            Error(
              Text039,
              -QtyReturned,ItemLedgEntry.FieldCaption("Document No."),
              ItemLedgEntry."Document No.",-QtyNotReturned);
          end;
    end;

    [Scope('Personalization')]
    procedure CalcPrepaymentToDeduct()
    begin
        if ("Qty. to Invoice" <> 0) and ("Prepmt. Amt. Inv." <> 0) then begin
          GetSalesHeader;
          if ("Prepayment %" = 100) and not IsFinalInvoice then
            "Prepmt Amt to Deduct" := GetLineAmountToHandle("Qty. to Invoice")
          else
            "Prepmt Amt to Deduct" :=
              Round(
                ("Prepmt. Amt. Inv." - "Prepmt Amt Deducted") *
                "Qty. to Invoice" / (Quantity - "Quantity Invoiced"),Currency."Amount Rounding Precision")
        end else
          "Prepmt Amt to Deduct" := 0
    end;

    [Scope('Personalization')]
    procedure IsFinalInvoice(): Boolean
    begin
        exit("Qty. to Invoice" = Quantity - "Quantity Invoiced");
    end;

    [Scope('Personalization')]
    procedure GetLineAmountToHandle(QtyToHandle: Decimal): Decimal
    var
        LineAmount: Decimal;
        LineDiscAmount: Decimal;
    begin
        if "Line Discount %" = 100 then
          exit(0);

        GetSalesHeader;

        if "Prepmt Amt to Deduct" = 0 then
          LineAmount := Round(QtyToHandle * "Unit Price",Currency."Amount Rounding Precision")
        else begin
          LineAmount := Round(Quantity * "Unit Price",Currency."Amount Rounding Precision");
          LineAmount := Round(QtyToHandle * LineAmount / Quantity,Currency."Amount Rounding Precision");
        end;

        if QtyToHandle <> Quantity then
          LineDiscAmount := Round(LineAmount * "Line Discount %" / 100,Currency."Amount Rounding Precision")
        else
          LineDiscAmount := "Line Discount Amount";

        OnAfterGetLineAmountToHandle(Rec,QtyToHandle,LineAmount,LineDiscAmount);
        exit(LineAmount - LineDiscAmount);
    end;

    procedure GetLineAmountExclVAT(): Decimal
    begin
        if "Document No." = '' then
          exit(0);
        GetSalesHeader;
        if not SalesHeader."Prices Including VAT" then
          exit("Line Amount");

        exit(Round("Line Amount" / (1 + "VAT %" / 100),Currency."Amount Rounding Precision"));
    end;

    procedure GetLineAmountInclVAT(): Decimal
    begin
        if "Document No." = '' then
          exit(0);
        GetSalesHeader;
        if SalesHeader."Prices Including VAT" then
          exit("Line Amount");

        exit(Round("Line Amount" * (1 + "VAT %" / 100),Currency."Amount Rounding Precision"));
    end;

    [Scope('Personalization')]
    procedure SetHasBeenShown()
    begin
        HasBeenShown := true;
    end;

    local procedure TestJobPlanningLine()
    var
        JobPostLine: Codeunit "Job Post-Line";
    begin
        if "Job Contract Entry No." = 0 then
          exit;

        JobPostLine.TestSalesLine(Rec);
    end;

    [Scope('Personalization')]
    procedure BlockDynamicTracking(SetBlock: Boolean)
    begin
        ReserveSalesLine.Block(SetBlock);
    end;

    [Scope('Personalization')]
    procedure InitQtyToShip2()
    begin
        "Qty. to Ship" := "Outstanding Quantity";
        "Qty. to Ship (Base)" := "Outstanding Qty. (Base)";

        ATOLink.UpdateQtyToAsmFromSalesLine(Rec);

        CheckServItemCreation;

        "Qty. to Invoice" := MaxQtyToInvoice;
        "Qty. to Invoice (Base)" := MaxQtyToInvoiceBase;
        "VAT Difference" := 0;

        CalcInvDiscToInvoice;

        CalcPrepaymentToDeduct;
    end;

    [Scope('Personalization')]
    procedure ShowLineComments()
    var
        SalesCommentLine: Record "Sales Comment Line";
        SalesCommentSheet: Page "Sales Comment Sheet";
    begin
        TestField("Document No.");
        TestField("Line No.");
        SalesCommentLine.SetRange("Document Type","Document Type");
        SalesCommentLine.SetRange("No.","Document No.");
        SalesCommentLine.SetRange("Document Line No.","Line No.");
        SalesCommentSheet.SetTableView(SalesCommentLine);
        SalesCommentSheet.RunModal;
    end;

    [Scope('Personalization')]
    procedure SetDefaultQuantity()
    begin
        GetSalesSetup;
        if SalesSetup."Default Quantity to Ship" = SalesSetup."Default Quantity to Ship"::Blank then begin
          if ("Document Type" = "Document Type"::Order) or ("Document Type" = "Document Type"::Quote) then begin
            "Qty. to Ship" := 0;
            "Qty. to Ship (Base)" := 0;
            "Qty. to Invoice" := 0;
            "Qty. to Invoice (Base)" := 0;
          end;
          if "Document Type" = "Document Type"::"Return Order" then begin
            "Return Qty. to Receive" := 0;
            "Return Qty. to Receive (Base)" := 0;
            "Qty. to Invoice" := 0;
            "Qty. to Invoice (Base)" := 0;
          end;
        end;

        OnAfterSetDefaultQuantity(Rec,xRec);
    end;

    local procedure SetReserveWithoutPurchasingCode()
    begin
        GetItem;
        if Item.Reserve = Item.Reserve::Optional then begin
          GetSalesHeader;
          Reserve := SalesHeader.Reserve;
        end else
          Reserve := Item.Reserve;
    end;

    local procedure SetDefaultItemQuantity()
    begin
        GetSalesSetup;
        if SalesSetup."Default Item Quantity" then begin
          Validate(Quantity,1);
          CheckItemAvailable(CurrFieldNo);
        end;
    end;

    [Scope('Personalization')]
    procedure UpdatePrePaymentAmounts()
    var
        ShipmentLine: Record "Sales Shipment Line";
        SalesOrderLine: Record "Sales Line";
        SalesOrderHeader: Record "Sales Header";
    begin
        if ("Document Type" <> "Document Type"::Invoice) or ("Prepayment %" = 0) then
          exit;

        if not ShipmentLine.Get("Shipment No.","Shipment Line No.") then begin
          "Prepmt Amt to Deduct" := 0;
          "Prepmt VAT Diff. to Deduct" := 0;
        end else
          if SalesOrderLine.Get(SalesOrderLine."Document Type"::Order,ShipmentLine."Order No.",ShipmentLine."Order Line No.") then begin
            if ("Prepayment %" = 100) and (Quantity <> SalesOrderLine.Quantity - SalesOrderLine."Quantity Invoiced") then
              "Prepmt Amt to Deduct" := "Line Amount"
            else
              "Prepmt Amt to Deduct" :=
                Round((SalesOrderLine."Prepmt. Amt. Inv." - SalesOrderLine."Prepmt Amt Deducted") *
                  Quantity / (SalesOrderLine.Quantity - SalesOrderLine."Quantity Invoiced"),Currency."Amount Rounding Precision");
            "Prepmt VAT Diff. to Deduct" := "Prepayment VAT Difference" - "Prepmt VAT Diff. Deducted";
            SalesOrderHeader.Get(SalesOrderHeader."Document Type"::Order,SalesOrderLine."Document No.");
          end else begin
            "Prepmt Amt to Deduct" := 0;
            "Prepmt VAT Diff. to Deduct" := 0;
          end;

        GetSalesHeader;
        SalesHeader.TestField("Prices Including VAT",SalesOrderHeader."Prices Including VAT");
        if SalesHeader."Prices Including VAT" then begin
          "Prepmt. Amt. Incl. VAT" := "Prepmt Amt to Deduct";
          "Prepayment Amount" :=
            Round(
              "Prepmt Amt to Deduct" / (1 + ("Prepayment VAT %" / 100)),
              Currency."Amount Rounding Precision");
        end else begin
          "Prepmt. Amt. Incl. VAT" :=
            Round(
              "Prepmt Amt to Deduct" * (1 + ("Prepayment VAT %" / 100)),
              Currency."Amount Rounding Precision");
          "Prepayment Amount" := "Prepmt Amt to Deduct";
        end;
        "Prepmt. Line Amount" := "Prepmt Amt to Deduct";
        "Prepmt. Amt. Inv." := "Prepmt. Line Amount";
        "Prepmt. VAT Base Amt." := "Prepayment Amount";
        "Prepmt. Amount Inv. Incl. VAT" := "Prepmt. Amt. Incl. VAT";
        "Prepmt Amt Deducted" := 0;
    end;

    [Scope('Personalization')]
    procedure ZeroAmountLine(QtyType: Option General,Invoicing,Shipping): Boolean
    begin
        if not HasTypeToFillMandatoryFields then
          exit(true);
        if Quantity = 0 then
          exit(true);
        if "Unit Price" = 0 then
          exit(true);
        if QtyType = QtyType::Invoicing then
          if "Qty. to Invoice" = 0 then
            exit(true);
        exit(false);
    end;

    [Scope('Personalization')]
    procedure FilterLinesWithItemToPlan(var Item: Record Item;DocumentType: Option)
    begin
        Reset;
        SetCurrentKey("Document Type",Type,"No.","Variant Code","Drop Shipment","Location Code","Shipment Date");
        SetRange("Document Type",DocumentType);
        SetRange(Type,Type::Item);
        SetRange("No.",Item."No.");
        SetFilter("Variant Code",Item.GetFilter("Variant Filter"));
        SetFilter("Location Code",Item.GetFilter("Location Filter"));
        SetFilter("Drop Shipment",Item.GetFilter("Drop Shipment Filter"));
        SetFilter("Shortcut Dimension 1 Code",Item.GetFilter("Global Dimension 1 Filter"));
        SetFilter("Shortcut Dimension 2 Code",Item.GetFilter("Global Dimension 2 Filter"));
        SetFilter("Shipment Date",Item.GetFilter("Date Filter"));
        SetFilter("Outstanding Qty. (Base)",'<>0');
    end;

    [Scope('Personalization')]
    procedure FindLinesWithItemToPlan(var Item: Record Item;DocumentType: Option): Boolean
    begin
        FilterLinesWithItemToPlan(Item,DocumentType);
        exit(Find('-'));
    end;

    [Scope('Personalization')]
    procedure LinesWithItemToPlanExist(var Item: Record Item;DocumentType: Option): Boolean
    begin
        FilterLinesWithItemToPlan(Item,DocumentType);
        exit(not IsEmpty);
    end;

    local procedure DateFormularZero(var DateFormularValue: DateFormula;CalledByFieldNo: Integer;CalledByFieldCaption: Text[250])
    var
        DateFormularZero: DateFormula;
    begin
        Evaluate(DateFormularZero,'<0D>');
        if (DateFormularValue <> DateFormularZero) and (CalledByFieldNo = CurrFieldNo) then
          Error(Text051,CalledByFieldCaption,FieldCaption("Drop Shipment"));
        Evaluate(DateFormularValue,'<0D>');
    end;

    local procedure InitQtyToAsm()
    begin
        if not IsAsmToOrderAllowed then begin
          "Qty. to Assemble to Order" := 0;
          "Qty. to Asm. to Order (Base)" := 0;
          exit;
        end;

        if ((xRec."Qty. to Asm. to Order (Base)" = 0) and IsAsmToOrderRequired and ("Qty. Shipped (Base)" = 0)) or
           ((xRec."Qty. to Asm. to Order (Base)" <> 0) and
            (xRec."Qty. to Asm. to Order (Base)" = xRec."Quantity (Base)")) or
           ("Qty. to Asm. to Order (Base)" > "Quantity (Base)")
        then begin
          "Qty. to Assemble to Order" := Quantity;
          "Qty. to Asm. to Order (Base)" := "Quantity (Base)";
        end;
    end;

    [Scope('Personalization')]
    procedure AsmToOrderExists(var AsmHeader: Record "Assembly Header"): Boolean
    var
        ATOLink: Record "Assemble-to-Order Link";
    begin
        if not ATOLink.AsmExistsForSalesLine(Rec) then
          exit(false);
        exit(AsmHeader.Get(ATOLink."Assembly Document Type",ATOLink."Assembly Document No."));
    end;

    [Scope('Personalization')]
    procedure FullQtyIsForAsmToOrder(): Boolean
    begin
        if "Qty. to Asm. to Order (Base)" = 0 then
          exit(false);
        exit("Quantity (Base)" = "Qty. to Asm. to Order (Base)");
    end;

    local procedure FullReservedQtyIsForAsmToOrder(): Boolean
    begin
        if "Qty. to Asm. to Order (Base)" = 0 then
          exit(false);
        CalcFields("Reserved Qty. (Base)");
        exit("Reserved Qty. (Base)" = "Qty. to Asm. to Order (Base)");
    end;

    [Scope('Personalization')]
    procedure QtyBaseOnATO(): Decimal
    var
        AsmHeader: Record "Assembly Header";
    begin
        if AsmToOrderExists(AsmHeader) then
          exit(AsmHeader."Quantity (Base)");
        exit(0);
    end;

    [Scope('Personalization')]
    procedure QtyAsmRemainingBaseOnATO(): Decimal
    var
        AsmHeader: Record "Assembly Header";
    begin
        if AsmToOrderExists(AsmHeader) then
          exit(AsmHeader."Remaining Quantity (Base)");
        exit(0);
    end;

    [Scope('Personalization')]
    procedure QtyToAsmBaseOnATO(): Decimal
    var
        AsmHeader: Record "Assembly Header";
    begin
        if AsmToOrderExists(AsmHeader) then
          exit(AsmHeader."Quantity to Assemble (Base)");
        exit(0);
    end;

    [Scope('Personalization')]
    procedure IsAsmToOrderAllowed(): Boolean
    begin
        if not ("Document Type" in ["Document Type"::Quote,"Document Type"::"Blanket Order","Document Type"::Order]) then
          exit(false);
        if Quantity < 0 then
          exit(false);
        if Type <> Type::Item then
          exit(false);
        if "No." = '' then
          exit(false);
        if "Drop Shipment" or "Special Order" then
          exit(false);
        exit(true)
    end;

    [Scope('Personalization')]
    procedure IsAsmToOrderRequired(): Boolean
    begin
        if (Type <> Type::Item) or ("No." = '') then
          exit(false);
        GetItem;
        if GetSKU then
          exit(SKU."Assembly Policy" = SKU."Assembly Policy"::"Assemble-to-Order");
        exit(Item."Assembly Policy" = Item."Assembly Policy"::"Assemble-to-Order");
    end;

    [Scope('Personalization')]
    procedure CheckAsmToOrder(AsmHeader: Record "Assembly Header")
    begin
        TestField("Qty. to Assemble to Order",AsmHeader.Quantity);
        TestField("Document Type",AsmHeader."Document Type");
        TestField(Type,Type::Item);
        TestField("No.",AsmHeader."Item No.");
        TestField("Location Code",AsmHeader."Location Code");
        TestField("Unit of Measure Code",AsmHeader."Unit of Measure Code");
        TestField("Variant Code",AsmHeader."Variant Code");
        TestField("Shipment Date",AsmHeader."Due Date");
        if "Document Type" = "Document Type"::Order then begin
          AsmHeader.CalcFields("Reserved Qty. (Base)");
          AsmHeader.TestField("Reserved Qty. (Base)",AsmHeader."Remaining Quantity (Base)");
        end;
        TestField("Qty. to Asm. to Order (Base)",AsmHeader."Quantity (Base)");
        if "Outstanding Qty. (Base)" < AsmHeader."Remaining Quantity (Base)" then
          AsmHeader.FieldError("Remaining Quantity (Base)",StrSubstNo(Text045,AsmHeader."Remaining Quantity (Base)"));
    end;

    [Scope('Personalization')]
    procedure ShowAsmToOrderLines()
    var
        ATOLink: Record "Assemble-to-Order Link";
    begin
        ATOLink.ShowAsmToOrderLines(Rec);
    end;

    [Scope('Personalization')]
    procedure FindOpenATOEntry(LotNo: Code[50];SerialNo: Code[50]): Integer
    var
        PostedATOLink: Record "Posted Assemble-to-Order Link";
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        TestField("Document Type","Document Type"::Order);
        if PostedATOLink.FindLinksFromSalesLine(Rec) then
          repeat
            ItemLedgEntry.SetRange("Document Type",ItemLedgEntry."Document Type"::"Posted Assembly");
            ItemLedgEntry.SetRange("Document No.",PostedATOLink."Assembly Document No.");
            ItemLedgEntry.SetRange("Document Line No.",0);
            ItemLedgEntry.SetTrackingFilter(SerialNo,LotNo);
            ItemLedgEntry.SetRange(Open,true);
            if ItemLedgEntry.FindFirst then
              exit(ItemLedgEntry."Entry No.");
          until PostedATOLink.Next = 0;
    end;

    [Scope('Personalization')]
    procedure RollUpAsmCost()
    begin
        ATOLink.RollUpCost(Rec);
    end;

    procedure RollupAsmPrice()
    begin
        GetSalesHeader;
        ATOLink.RollUpPrice(SalesHeader,Rec);
    end;

    local procedure UpdateICPartner()
    var
        ICPartner: Record "IC Partner";
        ItemCrossReference: Record "Item Cross Reference";
    begin
        if SalesHeader."Send IC Document" and
           (SalesHeader."IC Direction" = SalesHeader."IC Direction"::Outgoing) and
           (SalesHeader."Bill-to IC Partner Code" <> '')
        then
          case Type of
            Type::" ",Type::"Charge (Item)":
              begin
                "IC Partner Ref. Type" := Type;
                "IC Partner Reference" := "No.";
              end;
            Type::"G/L Account":
              begin
                "IC Partner Ref. Type" := Type;
                "IC Partner Reference" := GLAcc."Default IC Partner G/L Acc. No";
              end;
            Type::Item:
              begin
                if SalesHeader."Sell-to IC Partner Code" <> '' then
                  ICPartner.Get(SalesHeader."Sell-to IC Partner Code")
                else
                  ICPartner.Get(SalesHeader."Bill-to IC Partner Code");
                case ICPartner."Outbound Sales Item No. Type" of
                  ICPartner."Outbound Sales Item No. Type"::"Common Item No.":
                    Validate("IC Partner Ref. Type","IC Partner Ref. Type"::"Common Item No.");
                  ICPartner."Outbound Sales Item No. Type"::"Internal No.",
                  ICPartner."Outbound Sales Item No. Type"::"Cross Reference":
                    begin
                      if ICPartner."Outbound Sales Item No. Type" = ICPartner."Outbound Sales Item No. Type"::"Internal No." then
                        Validate("IC Partner Ref. Type","IC Partner Ref. Type"::Item)
                      else
                        Validate("IC Partner Ref. Type","IC Partner Ref. Type"::"Cross Reference");
                      ItemCrossReference.SetRange("Cross-Reference Type",ItemCrossReference."Cross-Reference Type"::Customer);
                      ItemCrossReference.SetRange("Cross-Reference Type No.","Sell-to Customer No.");
                      ItemCrossReference.SetRange("Item No.","No.");
                      ItemCrossReference.SetRange("Variant Code","Variant Code");
                      ItemCrossReference.SetRange("Unit of Measure","Unit of Measure Code");
                      if ItemCrossReference.FindFirst then
                        "IC Partner Reference" := ItemCrossReference."Cross-Reference No."
                      else
                        "IC Partner Reference" := "No.";
                    end;
                end;
              end;
            Type::"Fixed Asset":
              begin
                "IC Partner Ref. Type" := "IC Partner Ref. Type"::" ";
                "IC Partner Reference" := '';
              end;
            Type::Resource:
              begin
                Resource.Get("No.");
                "IC Partner Ref. Type" := "IC Partner Ref. Type"::"G/L Account";
                "IC Partner Reference" := Resource."IC Partner Purch. G/L Acc. No.";
              end;
          end;
    end;

    [Scope('Personalization')]
    procedure OutstandingInvoiceAmountFromShipment(SellToCustomerNo: Code[20]): Decimal
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetCurrentKey("Document Type","Sell-to Customer No.","Shipment No.");
        SalesLine.SetRange("Document Type",SalesLine."Document Type"::Invoice);
        SalesLine.SetRange("Sell-to Customer No.",SellToCustomerNo);
        SalesLine.SetFilter("Shipment No.",'<>%1','');
        SalesLine.CalcSums("Outstanding Amount (LCY)");
        exit(SalesLine."Outstanding Amount (LCY)");
    end;

    local procedure CheckShipmentRelation()
    var
        SalesShptLine: Record "Sales Shipment Line";
    begin
        SalesShptLine.Get("Shipment No.","Shipment Line No.");
        if (Quantity * SalesShptLine."Qty. Shipped Not Invoiced") < 0 then
          FieldError("Qty. to Invoice",Text057);
        if Abs(Quantity) > Abs(SalesShptLine."Qty. Shipped Not Invoiced") then
          Error(Text058,SalesShptLine."Document No.");
    end;

    local procedure CheckRetRcptRelation()
    var
        ReturnRcptLine: Record "Return Receipt Line";
    begin
        ReturnRcptLine.Get("Return Receipt No.","Return Receipt Line No.");
        if (Quantity * (ReturnRcptLine.Quantity - ReturnRcptLine."Quantity Invoiced")) < 0 then
          FieldError("Qty. to Invoice",Text059);
        if Abs(Quantity) > Abs(ReturnRcptLine.Quantity - ReturnRcptLine."Quantity Invoiced") then
          Error(Text060,ReturnRcptLine."Document No.");
    end;

    local procedure VerifyItemLineDim()
    begin
        if IsShippedReceivedItemDimChanged then
          ConfirmShippedReceivedItemDimChange;
    end;

    [Scope('Personalization')]
    procedure IsShippedReceivedItemDimChanged(): Boolean
    begin
        exit(("Dimension Set ID" <> xRec."Dimension Set ID") and (Type = Type::Item) and
          (("Qty. Shipped Not Invoiced" <> 0) or ("Return Rcd. Not Invd." <> 0)));
    end;

    local procedure IsServiceCharge(): Boolean
    var
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        if Type <> Type::"G/L Account" then
          exit(false);

        GetSalesHeader;
        CustomerPostingGroup.Get(SalesHeader."Customer Posting Group");
        exit(CustomerPostingGroup."Service Charge Acc." = "No.");
    end;

    [Scope('Personalization')]
    procedure ConfirmShippedReceivedItemDimChange(): Boolean
    begin
        if not Confirm(Text053,true,TableCaption) then
          Error(Text054);

        exit(true);
    end;

    [Scope('Personalization')]
    procedure InitType()
    begin
        if "Document No." <> '' then begin
          if not SalesHeader.Get("Document Type","Document No.") then
            exit;
          if (SalesHeader.Status = SalesHeader.Status::Released) and
             (xRec.Type in [xRec.Type::Item,xRec.Type::"Fixed Asset"])
          then
            Type := Type::" "
          else
            Type := xRec.Type;
        end;
    end;

    local procedure CheckWMS()
    begin
        if CurrFieldNo <> 0 then
          CheckLocationOnWMS;
    end;

    [Scope('Personalization')]
    procedure CheckLocationOnWMS()
    var
        DialogText: Text;
    begin
        if Type = Type::Item then begin
          DialogText := Text035;
          if "Quantity (Base)" <> 0 then
            case "Document Type" of
              "Document Type"::Invoice:
                if "Shipment No." = '' then
                  if Location.Get("Location Code") and Location."Directed Put-away and Pick" then begin
                    DialogText += Location.GetRequirementText(Location.FieldNo("Require Shipment"));
                    Error(Text016,DialogText,FieldCaption("Line No."),"Line No.");
                  end;
              "Document Type"::"Credit Memo":
                if "Return Receipt No." = '' then
                  if Location.Get("Location Code") and Location."Directed Put-away and Pick" then begin
                    DialogText += Location.GetRequirementText(Location.FieldNo("Require Receive"));
                    Error(Text016,DialogText,FieldCaption("Line No."),"Line No.");
                  end;
            end;
        end;
    end;

    [Scope('Personalization')]
    procedure IsNonInventoriableItem(): Boolean
    begin
        if Type <> Type::Item then
          exit(false);
        if "No." = '' then
          exit(false);
        GetItem;
        exit(Item.IsNonInventoriableType);
    end;

    [Scope('Personalization')]
    procedure IsInventoriableItem(): Boolean
    begin
        if Type <> Type::Item then
          exit(false);
        if "No." = '' then
          exit(false);
        GetItem;
        exit(Item.IsInventoriableType);
    end;

    local procedure ValidateReturnReasonCode(CallingFieldNo: Integer)
    var
        ReturnReason: Record "Return Reason";
    begin
        if CallingFieldNo = 0 then
          exit;
        if "Return Reason Code" = '' then begin
          if (Type = Type::Item) and ("No." <> '') then
            GetUnitCost;
          UpdateUnitPrice(CallingFieldNo);
        end;

        if ReturnReason.Get("Return Reason Code") then begin
          if (CallingFieldNo <> FieldNo("Location Code")) and (ReturnReason."Default Location Code" <> '') then
            Validate("Location Code",ReturnReason."Default Location Code");
          if ReturnReason."Inventory Value Zero" then
            Validate("Unit Cost (LCY)",0)
          else
            if "Unit Price" = 0 then
              UpdateUnitPrice(CallingFieldNo);
        end;

        OnAfterValidateReturnReasonCode(Rec,CallingFieldNo);
    end;

    [Scope('Personalization')]
    procedure HasTypeToFillMandatoryFields(): Boolean
    begin
        exit(Type <> Type::" ");
    end;

    [Scope('Personalization')]
    procedure GetDeferralAmount() DeferralAmount: Decimal
    begin
        if "VAT Base Amount" <> 0 then
          DeferralAmount := "VAT Base Amount"
        else
          DeferralAmount := CalcLineAmount;
    end;

    local procedure UpdateDeferralAmounts()
    var
        AdjustStartDate: Boolean;
        DeferralPostDate: Date;
    begin
        GetSalesHeader;
        OnGetDeferralPostDate(SalesHeader,DeferralPostDate);
        if DeferralPostDate = 0D then
          DeferralPostDate := SalesHeader."Posting Date";
        AdjustStartDate := true;
        if "Document Type" = "Document Type"::"Return Order" then begin
          if "Returns Deferral Start Date" = 0D then
            "Returns Deferral Start Date" := SalesHeader."Posting Date";
          DeferralPostDate := "Returns Deferral Start Date";
          AdjustStartDate := false;
        end;

        DeferralUtilities.RemoveOrSetDeferralSchedule(
          "Deferral Code",DeferralUtilities.GetSalesDeferralDocType,'','',
          "Document Type","Document No.","Line No.",
          GetDeferralAmount,DeferralPostDate,Description,SalesHeader."Currency Code",AdjustStartDate);
    end;

    procedure UpdatePriceDescription()
    var
        Currency: Record Currency;
    begin
        "Price description" := '';
        if Type in [Type::"Charge (Item)",Type::"Fixed Asset",Type::Item,Type::Resource] then begin
          if "Line Discount %" = 0 then
            "Price description" := StrSubstNo(
                PriceDescriptionTxt,Quantity,Currency.ResolveGLCurrencySymbol("Currency Code"),
                "Unit Price","Unit of Measure")
          else
            "Price description" := StrSubstNo(
                PriceDescriptionWithLineDiscountTxt,Quantity,Currency.ResolveGLCurrencySymbol("Currency Code"),
                "Unit Price","Unit of Measure","Line Discount %")
        end;
    end;

    procedure ShowDeferrals(PostingDate: Date;CurrencyCode: Code[10]): Boolean
    begin
        exit(DeferralUtilities.OpenLineScheduleEdit(
            "Deferral Code",DeferralUtilities.GetSalesDeferralDocType,'','',
            "Document Type","Document No.","Line No.",
            GetDeferralAmount,PostingDate,Description,CurrencyCode));
    end;

    local procedure InitHeaderDefaults(SalesHeader: Record "Sales Header")
    begin
        if SalesHeader."Document Type" = SalesHeader."Document Type"::Quote then begin
          if (SalesHeader."Sell-to Customer No." = '') and
             (SalesHeader."Sell-to Customer Template Code" = '')
          then
            Error(
              Text031,
              SalesHeader.FieldCaption("Sell-to Customer No."),
              SalesHeader.FieldCaption("Sell-to Customer Template Code"));
          if (SalesHeader."Bill-to Customer No." = '') and
             (SalesHeader."Bill-to Customer Template Code" = '')
          then
            Error(
              Text031,
              SalesHeader.FieldCaption("Bill-to Customer No."),
              SalesHeader.FieldCaption("Bill-to Customer Template Code"));
        end else
          SalesHeader.TestField("Sell-to Customer No.");

        "Sell-to Customer No." := SalesHeader."Sell-to Customer No.";
        "Currency Code" := SalesHeader."Currency Code";
        if not IsNonInventoriableItem then
          "Location Code" := SalesHeader."Location Code";
        "Customer Price Group" := SalesHeader."Customer Price Group";
        "Customer Disc. Group" := SalesHeader."Customer Disc. Group";
        "Allow Line Disc." := SalesHeader."Allow Line Disc.";
        "Transaction Type" := SalesHeader."Transaction Type";
        "Transport Method" := SalesHeader."Transport Method";
        "Bill-to Customer No." := SalesHeader."Bill-to Customer No.";
        "Gen. Bus. Posting Group" := SalesHeader."Gen. Bus. Posting Group";
        "VAT Bus. Posting Group" := SalesHeader."VAT Bus. Posting Group";
        "Exit Point" := SalesHeader."Exit Point";
        Area := SalesHeader.Area;
        "Transaction Specification" := SalesHeader."Transaction Specification";
        "Tax Area Code" := SalesHeader."Tax Area Code";
        "Tax Liable" := SalesHeader."Tax Liable";
        if not "System-Created Entry" and ("Document Type" = "Document Type"::Order) and HasTypeToFillMandatoryFields or
           IsServiceCharge
        then
          "Prepayment %" := SalesHeader."Prepayment %";
        "Prepayment Tax Area Code" := SalesHeader."Tax Area Code";
        "Prepayment Tax Liable" := SalesHeader."Tax Liable";
        "Responsibility Center" := SalesHeader."Responsibility Center";

        "Shipping Agent Code" := SalesHeader."Shipping Agent Code";
        "Shipping Agent Service Code" := SalesHeader."Shipping Agent Service Code";
        "Outbound Whse. Handling Time" := SalesHeader."Outbound Whse. Handling Time";
        "Shipping Time" := SalesHeader."Shipping Time";

        OnAfterInitHeaderDefaults(Rec,SalesHeader);
    end;

    local procedure InitDeferralCode()
    begin
        if "Document Type" in
           ["Document Type"::Order,"Document Type"::Invoice,"Document Type"::"Credit Memo","Document Type"::"Return Order"]
        then
          case Type of
            Type::"G/L Account":
              Validate("Deferral Code",GLAcc."Default Deferral Template Code");
            Type::Item:
              Validate("Deferral Code",Item."Default Deferral Template Code");
            Type::Resource:
              Validate("Deferral Code",Res."Default Deferral Template Code");
          end;
    end;

    [Scope('Personalization')]
    procedure DefaultDeferralCode()
    begin
        case Type of
          Type::"G/L Account":
            begin
              GLAcc.Get("No.");
              InitDeferralCode;
            end;
          Type::Item:
            begin
              GetItem;
              InitDeferralCode;
            end;
          Type::Resource:
            begin
              Res.Get("No.");
              InitDeferralCode;
            end;
        end;
    end;

    [Scope('Personalization')]
    procedure IsCreditDocType(): Boolean
    begin
        exit("Document Type" in ["Document Type"::"Return Order","Document Type"::"Credit Memo"]);
    end;

    local procedure IsFullyInvoiced(): Boolean
    begin
        exit(("Qty. Shipped Not Invd. (Base)" = 0) and ("Qty. Shipped (Base)" = "Quantity (Base)"))
    end;

    local procedure CleanDropShipmentFields()
    begin
        if ("Purch. Order Line No." <> 0) and IsFullyInvoiced then
          if CleanPurchaseLineDropShipmentFields then begin
            "Purchase Order No." := '';
            "Purch. Order Line No." := 0;
          end;
    end;

    local procedure CleanSpecialOrderFieldsAndCheckAssocPurchOrder()
    begin
        if ("Special Order Purch. Line No." <> 0) and IsFullyInvoiced then
          if CleanPurchaseLineSpecialOrderFields then begin
            "Special Order Purchase No." := '';
            "Special Order Purch. Line No." := 0;
          end;
        CheckAssocPurchOrder('');
    end;

    local procedure CleanPurchaseLineDropShipmentFields(): Boolean
    var
        PurchaseLine: Record "Purchase Line";
    begin
        if PurchaseLine.Get(PurchaseLine."Document Type"::Order,"Purchase Order No.","Purch. Order Line No.") then begin
          if PurchaseLine."Qty. Received (Base)" < "Qty. Shipped (Base)" then
            exit(false);

          PurchaseLine."Sales Order No." := '';
          PurchaseLine."Sales Order Line No." := 0;
          PurchaseLine.Modify;
        end;

        exit(true);
    end;

    local procedure CleanPurchaseLineSpecialOrderFields(): Boolean
    var
        PurchaseLine: Record "Purchase Line";
    begin
        if PurchaseLine.Get(PurchaseLine."Document Type"::Order,"Special Order Purchase No.","Special Order Purch. Line No.") then begin
          if PurchaseLine."Qty. Received (Base)" < "Qty. Shipped (Base)" then
            exit(false);

          PurchaseLine."Special Order" := false;
          PurchaseLine."Special Order Sales No." := '';
          PurchaseLine."Special Order Sales Line No." := 0;
          PurchaseLine.Modify;
        end;

        exit(true);
    end;

    [Scope('Personalization')]
    procedure CanEditUnitOfMeasureCode(): Boolean
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        if (Type = Type::Item) and ("No." <> '') then begin
          ItemUnitOfMeasure.SetRange("Item No.","No.");
          exit(ItemUnitOfMeasure.Count > 1);
        end;
        exit(true);
    end;

    local procedure ValidateTaxGroupCode()
    var
        TaxDetail: Record "Tax Detail";
    begin
        if ("Tax Area Code" <> '') and ("Tax Group Code" <> '') then
          TaxDetail.ValidateTaxSetup("Tax Area Code","Tax Group Code","Posting Date");
    end;

    [Scope('Personalization')]
    procedure InsertFreightLine(var FreightAmount: Decimal)
    var
        SalesLine: Record "Sales Line";
    begin
        if FreightAmount <= 0 then begin
          FreightAmount := 0;
          exit;
        end;

        SalesSetup.Get;
        SalesSetup.TestField("Freight G/L Acc. No.");

        TestField("Document Type");
        TestField("Document No.");

        SalesLine.SetRange("Document Type","Document Type");
        SalesLine.SetRange("Document No.","Document No.");

        SalesLine.SetRange(Type,SalesLine.Type::"G/L Account");
        SalesLine.SetRange("No.",SalesSetup."Freight G/L Acc. No.");
        if SalesLine.FindFirst then begin
          SalesLine.Validate(Quantity,1);
          SalesLine.Validate("Unit Price",FreightAmount);
          SalesLine.Modify;
        end else begin
          SalesLine.SetRange(Type);
          SalesLine.SetRange("No.");
          SalesLine.FindLast;
          SalesLine."Line No." += 10000;

          SalesLine.Init;
          SalesLine.Validate(Type,SalesLine.Type::"G/L Account");
          SalesLine.Validate("No.",SalesSetup."Freight G/L Acc. No.");
          SalesLine.Validate(Description,FreightLineDescriptionTxt);
          SalesLine.Validate(Quantity,1);
          SalesLine.Validate("Unit Price",FreightAmount);
          SalesLine.Insert;
        end;
    end;

    local procedure CalcTotalAmtToAssign(TotalQtyToAssign: Decimal) TotalAmtToAssign: Decimal
    begin
        TotalAmtToAssign := CalcLineAmount * TotalQtyToAssign / Quantity;
        if SalesHeader."Prices Including VAT" then
          TotalAmtToAssign := TotalAmtToAssign / (1 + "VAT %" / 100) - "VAT Difference";

        TotalAmtToAssign := Round(TotalAmtToAssign,Currency."Amount Rounding Precision");
    end;

    [Scope('Personalization')]
    procedure IsLookupRequested() Result: Boolean
    begin
        Result := LookupRequested;
        LookupRequested := false;
    end;

    [Scope('Personalization')]
    procedure TestItemFields(ItemNo: Code[20];VariantCode: Code[10];LocationCode: Code[10])
    begin
        TestField(Type,Type::Item);
        TestField("No.",ItemNo);
        TestField("Variant Code",VariantCode);
        TestField("Location Code",LocationCode);
    end;

    [Scope('Personalization')]
    procedure CalculateNotShippedInvExlcVatLCY()
    var
        Currency2: Record Currency;
    begin
        Currency2.InitRoundingPrecision;
        "Shipped Not Inv. (LCY) No VAT" :=
          Round("Shipped Not Invoiced (LCY)" / (1 + "VAT %" / 100),Currency2."Amount Rounding Precision");
    end;

    procedure ClearSalesHeader()
    begin
        Clear(SalesHeader);
    end;

    procedure GetDocumentTypeDescription(): Text
    var
        IdentityManagement: Codeunit "Identity Management";
    begin
        if IdentityManagement.IsInvAppId and ("Document Type" = "Document Type"::Quote) then
          exit(EstimateLbl);

        exit(Format("Document Type"));
    end;

    procedure FormatType(): Text[20]
    begin
        if Type = Type::" " then
          exit(CommentLbl);

        exit(Format(Type));
    end;

    procedure RenameNo(LineType: Option;OldNo: Code[20];NewNo: Code[20])
    begin
        Reset;
        SetRange(Type,LineType);
        SetRange("No.",OldNo);
        ModifyAll("No.",NewNo,true);
    end;

    procedure UpdatePlanned(): Boolean
    begin
        TestField("Qty. per Unit of Measure");
        CalcFields("Reserved Quantity");
        if Planned = ("Reserved Quantity" = "Outstanding Quantity") then
          exit(false);
        Planned := not Planned;
        exit(true);
    end;

    procedure AssignedItemCharge(): Boolean
    begin
        exit((Type = Type::"Charge (Item)") and ("No." <> '') and ("Qty. to Assign" < Quantity));
    end;

    local procedure UpdateLineDiscPct()
    var
        LineDiscountPct: Decimal;
    begin
        if Round(Quantity * "Unit Price",Currency."Amount Rounding Precision") <> 0 then begin
          LineDiscountPct := Round(
              "Line Discount Amount" / Round(Quantity * "Unit Price",Currency."Amount Rounding Precision") * 100,
              0.00001);
          if not (LineDiscountPct in [0..100]) then
            Error(LineDiscountPctErr);
          "Line Discount %" := LineDiscountPct;
        end else
          "Line Discount %" := 0;
    end;

    local procedure UpdateBaseAmounts(NewAmount: Decimal;NewAmountIncludingVAT: Decimal;NewVATBaseAmount: Decimal)
    begin
        Amount := NewAmount;
        "Amount Including VAT" := NewAmountIncludingVAT;
        "VAT Base Amount" := NewVATBaseAmount;
        if not SalesHeader."Prices Including VAT" and (Amount > 0) and (Amount < "Prepmt. Line Amount") then
          "Prepmt. Line Amount" := Amount;
        if SalesHeader."Prices Including VAT" and ("Amount Including VAT" > 0) and ("Amount Including VAT" < "Prepmt. Line Amount") then
          "Prepmt. Line Amount" := "Amount Including VAT";
    end;

    procedure CalcPlannedDate(): Date
    begin
        if Format("Shipping Time") <> '' then
          exit(CalcPlannedDeliveryDate(FieldNo("Planned Delivery Date")));

        exit(CalcPlannedShptDate(FieldNo("Planned Delivery Date")));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignFieldsForNo(var SalesLine: Record "Sales Line";var xSalesLine: Record "Sales Line";SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignHeaderValues(var SalesLine: Record "Sales Line";SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignStdTxtValues(var SalesLine: Record "Sales Line";StandardText: Record "Standard Text")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignGLAccountValues(var SalesLine: Record "Sales Line";GLAccount: Record "G/L Account")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignItemValues(var SalesLine: Record "Sales Line";Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignItemChargeValues(var SalesLine: Record "Sales Line";ItemCharge: Record "Item Charge")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignResourceValues(var SalesLine: Record "Sales Line";Resource: Record Resource)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignFixedAssetValues(var SalesLine: Record "Sales Line";FixedAsset: Record "Fixed Asset")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignItemUOM(var SalesLine: Record "Sales Line";Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignResourceUOM(var SalesLine: Record "Sales Line";Resource: Record Resource;ResourceUOM: Record "Resource Unit of Measure")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetUnitCost(var SalesLine: Record "Sales Line";Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateUnitPrice(var SalesLine: Record "Sales Line";xSalesLine: Record "Sales Line";CalledByFieldNo: Integer;CurrFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckAssocPurchOrder(SalesLine: Record "Sales Line";FieldCaption: Text[250];var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateUnitPrice(var SalesLine: Record "Sales Line";xSalesLine: Record "Sales Line";CalledByFieldNo: Integer;CurrFieldNo: Integer;var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeVerifyReservedQty(var SalesLine: Record "Sales Line";xSalesLine: Record "Sales Line";CalledByFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitHeaderDefaults(var SalesLine: Record "Sales Line";SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitOutstandingAmount(var SalesLine: Record "Sales Line";SalesHeader: Record "Sales Header";Currency: Record Currency)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitQtyToInvoice(var SalesLine: Record "Sales Line";CurrFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitQtyToShip(var SalesLine: Record "Sales Line";CurrFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitQtyToReceive(var SalesLine: Record "Sales Line";CurrFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalcVATAmountLines(var SalesHeader: Record "Sales Header";var SalesLine: Record "Sales Line";var VATAmountLine: Record "VAT Amount Line";QtyType: Option General,Invoicing,Shipping)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetLineAmountToHandle(SalesLine: Record "Sales Line";QtyToHandle: Decimal;var LineAmount: Decimal;var LineDiscAmount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateAmounts(var SalesLine: Record "Sales Line";var xSalesLine: Record "Sales Line";CurrentFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateAmountsDone(var SalesLine: Record "Sales Line";var xSalesLine: Record "Sales Line";CurrentFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateVATOnLines(var SalesHeader: Record "Sales Header";var SalesLine: Record "Sales Line";var VATAmountLine: Record "VAT Amount Line";QtyType: Option General,Invoicing,Shipping)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateDimTableIDs(var SalesLine: Record "Sales Line";FieldNo: Integer;var TableID: array [10] of Integer;var No: array [10] of Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterShowItemSub(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateReturnReasonCode(var SalesLine: Record "Sales Line";CallingFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateTypeOnCopyFromTempSalesLine(var SalesLine: Record "Sales Line";var TempSalesLine: Record "Sales Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateNoOnCopyFromTempSalesLine(var SalesLine: Record "Sales Line";var TempSalesLine: Record "Sales Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTestStatusOpen(var SalesLine: Record "Sales Line";var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetDefaultQuantity(var SalesLine: Record "Sales Line";var xSalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateTotalAmounts(var SalesLine: Record "Sales Line";SalesLine2: Record "Sales Line";var TotalAmount: Decimal;var TotalAmountInclVAT: Decimal;var TotalLineAmount: Decimal;var TotalInvDiscAmount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetDeferralPostDate(SalesHeader: Record "Sales Header";var DeferralPostingDate: Date)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAutoAsmToOrder(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAutoAsmToOrder(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterBlanketOrderLookup(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeBlanketOrderLookup(var SalesLine: Record "Sales Line";IsHandled: Boolean)
    begin
    end;

    procedure ShowDeferralSchedule()
    begin
        ShowDeferrals("Posting Date","Currency Code");
    end;
}

