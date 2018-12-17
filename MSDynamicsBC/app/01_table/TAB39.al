table 39 "Purchase Line"
{
    // version NAVW113.00

    Caption = 'Purchase Line';
    DrillDownPageID = "Purchase Lines";
    LookupPageID = "Purchase Lines";

    fields
    {
        field(1;"Document Type";Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        }
        field(2;"Buy-from Vendor No.";Code[20])
        {
            Caption = 'Buy-from Vendor No.';
            Editable = false;
            TableRelation = Vendor;
        }
        field(3;"Document No.";Code[20])
        {
            Caption = 'Document No.';
            TableRelation = "Purchase Header"."No." WHERE ("Document Type"=FIELD("Document Type"));
        }
        field(4;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(5;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = ' ,G/L Account,Item,,Fixed Asset,Charge (Item)';
            OptionMembers = " ","G/L Account",Item,,"Fixed Asset","Charge (Item)";

            trigger OnValidate()
            var
                TempPurchLine: Record "Purchase Line" temporary;
            begin
                GetPurchHeader;
                TestStatusOpen;

                TestField("Qty. Rcd. Not Invoiced",0);
                TestField("Quantity Received",0);
                TestField("Receipt No.",'');

                TestField("Return Qty. Shipped Not Invd.",0);
                TestField("Return Qty. Shipped",0);
                TestField("Return Shipment No.",'');

                TestField("Prepmt. Amt. Inv.",0);

                if "Drop Shipment" then
                  Error(
                    Text001,
                    FieldCaption(Type),"Sales Order No.");
                if "Special Order" then
                  Error(
                    Text001,
                    FieldCaption(Type),"Special Order Sales No.");
                if "Prod. Order No." <> '' then
                  Error(
                    Text044,
                    FieldCaption(Type),FieldCaption("Prod. Order No."),"Prod. Order No.");

                if Type <> xRec.Type then begin
                  if Quantity <> 0 then begin
                    ReservePurchLine.VerifyChange(Rec,xRec);
                    CalcFields("Reserved Qty. (Base)");
                    TestField("Reserved Qty. (Base)",0);
                    WhseValidateSourceLine.PurchaseLineVerifyChange(Rec,xRec);
                  end;
                  if xRec.Type in [Type::Item,Type::"Fixed Asset"] then begin
                    if Quantity <> 0 then
                      PurchHeader.TestField(Status,PurchHeader.Status::Open);
                    DeleteItemChargeAssgnt("Document Type","Document No.","Line No.");
                  end;
                  if xRec.Type = Type::"Charge (Item)" then
                    DeleteChargeChargeAssgnt("Document Type","Document No.","Line No.");
                  if xRec."Deferral Code" <> '' then
                    DeferralUtilities.RemoveOrSetDeferralSchedule('',
                      DeferralUtilities.GetPurchDeferralDocType,'','',
                      xRec."Document Type",xRec."Document No.",xRec."Line No.",
                      xRec.GetDeferralAmount,PurchHeader."Posting Date",'',xRec."Currency Code",true);
                end;
                TempPurchLine := Rec;
                Init;

                if xRec."Line Amount" <> 0 then
                  "Recalculate Invoice Disc." := true;

                Type := TempPurchLine.Type;
                "System-Created Entry" := TempPurchLine."System-Created Entry";
                OnValidateTypeOnCopyFromTempPurchLine(Rec,TempPurchLine);
                Validate("FA Posting Type");

                if Type = Type::Item then
                  "Allow Item Charge Assignment" := true
                else
                  "Allow Item Charge Assignment" := false;
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
                                                                                                        ELSE IF (Type=CONST("Fixed Asset")) "Fixed Asset"
                                                                                                        ELSE IF (Type=CONST("Charge (Item)")) "Item Charge"
                                                                                                        ELSE IF (Type=CONST(Item)) Item WHERE (Blocked=CONST(false));
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                TempPurchLine: Record "Purchase Line" temporary;
                FindRecordMgt: Codeunit "Find Record Management";
            begin
                "No." := FindRecordMgt.FindNoFromTypedValue(Type,"No.",not "System-Created Entry");

                TestStatusOpen;
                TestField("Qty. Rcd. Not Invoiced",0);
                TestField("Quantity Received",0);
                TestField("Receipt No.",'');

                TestField("Prepmt. Amt. Inv.",0);

                TestReturnFieldsZero;

                if "Drop Shipment" then
                  Error(
                    Text001,
                    FieldCaption("No."),"Sales Order No.");

                if "Special Order" then
                  Error(
                    Text001,
                    FieldCaption("No."),"Special Order Sales No.");

                if "Prod. Order No." <> '' then
                  Error(
                    Text044,
                    FieldCaption(Type),FieldCaption("Prod. Order No."),"Prod. Order No.");

                if "No." <> xRec."No." then begin
                  if (Quantity <> 0) and ItemExists(xRec."No.") then begin
                    ReservePurchLine.VerifyChange(Rec,xRec);
                    CalcFields("Reserved Qty. (Base)");
                    TestField("Reserved Qty. (Base)",0);
                    if Type = Type::Item then
                      WhseValidateSourceLine.PurchaseLineVerifyChange(Rec,xRec);
                  end;
                  if Type = Type::Item then
                    DeleteItemChargeAssgnt("Document Type","Document No.","Line No.");
                  if Type = Type::"Charge (Item)" then
                    DeleteChargeChargeAssgnt("Document Type","Document No.","Line No.");
                end;
                TempPurchLine := Rec;
                Init;
                if xRec."Line Amount" <> 0 then
                  "Recalculate Invoice Disc." := true;
                Type := TempPurchLine.Type;
                "No." := TempPurchLine."No.";
                OnValidateNoOnCopyFromTempPurchLine(Rec,TempPurchLine);
                if "No." = '' then
                  exit;

                if HasTypeToFillMandatoryFields then begin
                  Quantity := TempPurchLine.Quantity;
                  "Outstanding Qty. (Base)" := TempPurchLine."Outstanding Qty. (Base)";
                end;

                "System-Created Entry" := TempPurchLine."System-Created Entry";
                GetPurchHeader;
                InitHeaderDefaults(PurchHeader);
                UpdateLeadTimeFields;
                UpdateDates;

                OnAfterAssignHeaderValues(Rec,PurchHeader);

                case Type of
                  Type::" ":
                    CopyFromStandardText;
                  Type::"G/L Account":
                    CopyFromGLAccount;
                  Type::Item:
                    CopyFromItem;
                  3:
                    Error(Text003);
                  Type::"Fixed Asset":
                    CopyFromFixedAsset;
                  Type::"Charge (Item)":
                    CopyFromItemCharge;
                end;

                OnAfterAssignFieldsForNo(Rec,xRec,PurchHeader);

                if HasTypeToFillMandatoryFields and not (Type = Type::"Fixed Asset") then
                  Validate("VAT Prod. Posting Group");

                UpdatePrepmtSetupFields;

                if HasTypeToFillMandatoryFields then begin
                  Quantity := xRec.Quantity;
                  Validate("Unit of Measure Code");
                  if Quantity <> 0 then begin
                    InitOutstanding;
                    if "Document Type" in ["Document Type"::"Return Order","Document Type"::"Credit Memo"] then
                      InitQtyToShip
                    else
                      InitQtyToReceive;
                  end;
                  UpdateWithWarehouseReceive;
                  UpdateDirectUnitCost(FieldNo("No."));
                  if xRec."Job No." <> '' then
                    Validate("Job No.",xRec."Job No.");
                  "Job Line Type" := xRec."Job Line Type";
                  if xRec."Job Task No." <> '' then begin
                    Validate("Job Task No.",xRec."Job Task No.");
                    if "No." = xRec."No." then
                      Validate("Job Planning Line No.",xRec."Job Planning Line No.");
                  end;
                end;

                if not IsTemporary then
                  CreateDim(
                    DimMgt.TypeToTableID3(Type),"No.",
                    DATABASE::Job,"Job No.",
                    DATABASE::"Responsibility Center","Responsibility Center",
                    DATABASE::"Work Center","Work Center No.");

                PurchHeader.Get("Document Type","Document No.");
                UpdateItemReference;

                GetDefaultBin;

                if JobTaskIsSet then begin
                  CreateTempJobJnlLine(true);
                  UpdateJobPrices;
                  UpdateDimensionsFromJobTask;
                end;

                PostingSetupMgt.CheckGenPostingSetupPurchAccount("Gen. Bus. Posting Group","Gen. Prod. Posting Group");
                PostingSetupMgt.CheckVATPostingSetupPurchAccount("VAT Bus. Posting Group","VAT Prod. Posting Group");
            end;
        }
        field(7;"Location Code";Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location WHERE ("Use As In-Transit"=CONST(false));

            trigger OnValidate()
            begin
                TestStatusOpen;

                if "Location Code" <> '' then
                  if IsNonInventoriableItem then
                    Item.TestField(Type,Item.Type::Inventory);
                if xRec."Location Code" <> "Location Code" then begin
                  if "Prepmt. Amt. Inv." <> 0 then
                    if not Confirm(Text046,false,FieldCaption("Direct Unit Cost"),FieldCaption("Location Code"),PRODUCTNAME.Full) then begin
                      "Location Code" := xRec."Location Code";
                      exit;
                    end;
                  TestField("Qty. Rcd. Not Invoiced",0);
                  TestField("Receipt No.",'');

                  TestField("Return Qty. Shipped Not Invd.",0);
                  TestField("Return Shipment No.",'');
                end;

                if "Drop Shipment" then
                  Error(
                    Text001,
                    FieldCaption("Location Code"),"Sales Order No.");
                if "Special Order" then
                  Error(
                    Text001,
                    FieldCaption("Location Code"),"Special Order Sales No.");

                if "Location Code" <> xRec."Location Code" then
                  InitItemAppl;

                if (xRec."Location Code" <> "Location Code") and (Quantity <> 0) then begin
                  ReservePurchLine.VerifyChange(Rec,xRec);
                  WhseValidateSourceLine.PurchaseLineVerifyChange(Rec,xRec);
                  UpdateWithWarehouseReceive;
                  PostingSetupMgt.CheckInvtPostingSetupInventoryAccount("Location Code","Posting Group");
                end;
                "Bin Code" := '';

                if Type = Type::Item then
                  UpdateDirectUnitCost(FieldNo("Location Code"));

                if "Location Code" = '' then begin
                  if InvtSetup.Get then
                    "Inbound Whse. Handling Time" := InvtSetup."Inbound Whse. Handling Time";
                end else
                  if Location.Get("Location Code") then
                    "Inbound Whse. Handling Time" := Location."Inbound Whse. Handling Time";

                UpdateLeadTimeFields;
                UpdateDates;

                GetDefaultBin;
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
        field(10;"Expected Receipt Date";Date)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header"=R;
            Caption = 'Expected Receipt Date';

            trigger OnValidate()
            begin
                if not TrackingBlocked then
                  CheckDateConflict.PurchLineCheck(Rec,CurrFieldNo <> 0);

                if "Expected Receipt Date" <> 0D then
                  Validate(
                    "Planned Receipt Date",
                    CalendarMgmt.CalcDateBOC2(InternalLeadTimeDays("Expected Receipt Date"),"Expected Receipt Date",
                      CalChange."Source Type"::Location,"Location Code",'',
                      CalChange."Source Type"::Location,"Location Code",'',false))
                else
                  Validate("Planned Receipt Date","Expected Receipt Date");
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
                                                                                                        ELSE IF (Type=CONST("Fixed Asset")) "Fixed Asset".Description
                                                                                                        ELSE IF (Type=CONST("Charge (Item)")) "Item Charge".Description;
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                Item: Record Item;
                ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
                FindRecordMgt: Codeunit "Find Record Management";
                ReturnValue: Text[50];
                DescriptionIsNo: Boolean;
            begin
                if Type = Type::" " then
                  exit;

                if ("No." <> '') and (Type in [Type::Item,Type::"Charge (Item)"]) then begin
                  case Type of
                    Type::Item:
                      begin
                        if (StrLen(Description) <= MaxStrLen(Item."No.")) and ("No." <> '') then
                          DescriptionIsNo := Item.Get(Description)
                        else
                          DescriptionIsNo := false;

                        if not DescriptionIsNo then begin
                          Item.SetFilter(Description,'@%1',ConvertStr(Description,'''','?'));
                          if not Item.FindFirst then
                            exit;
                          if Item."No." = "No." then
                            exit;
                          if IsReceivedFromOcr then
                            exit;
                          if Confirm(AnotherItemWithSameDescrQst,false,Item."No.",Item.Description) then
                            Validate("No.",Item."No.");
                          exit;
                        end;

                        if Item.TryGetItemNoOpenCard(ReturnValue,Description,false,false,false) then
                          case ReturnValue of
                            '',"No.":
                              Description := xRec.Description;
                            else
                              Validate("No.",CopyStr(ReturnValue,1,MaxStrLen(Item."No.")));
                          end;
                      end;
                    Type::"Charge (Item)":
                      begin
                        ItemCharge.SetFilter(Description,'@%1',ConvertStr(Description,'''','?'));
                        if not ItemCharge.FindFirst then
                          exit;
                        if ItemCharge."No." = "No." then
                          exit;
                        if Confirm(AnotherChargeItemWithSameDescQst,false,ItemCharge."No.",ItemCharge.Description) then
                          Validate("No.",ItemCharge."No.");
                      end;
                  end;
                end else
                  if ("No." = '') or (CurrFieldNo = FieldNo(Description)) then
                    if FindRecordMgt.FindRecordByDescription(ReturnValue,Type,Description) = 1 then begin
                      CurrFieldNo := FieldNo("No.");
                      Validate("No.",CopyStr(ReturnValue,1,MaxStrLen("No.")));
                    end;

                if ("No." = '') and GuiAllowed and ApplicationAreaMgmtFacade.IsFoundationEnabled then
                  if "Document Type" in ["Document Type"::Order] then
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
        }
        field(15;Quantity;Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0:5;

            trigger OnValidate()
            begin
                TestStatusOpen;

                if "Drop Shipment" and ("Document Type" <> "Document Type"::Invoice) then
                  Error(
                    Text001,
                    FieldCaption(Quantity),"Sales Order No.");
                "Quantity (Base)" := CalcBaseQty(Quantity);
                if "Document Type" in ["Document Type"::"Return Order","Document Type"::"Credit Memo"] then begin
                  if (Quantity * "Return Qty. Shipped" < 0) or
                     ((Abs(Quantity) < Abs("Return Qty. Shipped")) and ("Return Shipment No." = ''))
                  then
                    FieldError(Quantity,StrSubstNo(Text004,FieldCaption("Return Qty. Shipped")));
                  if ("Quantity (Base)" * "Return Qty. Shipped (Base)" < 0) or
                     ((Abs("Quantity (Base)") < Abs("Return Qty. Shipped (Base)")) and ("Return Shipment No." = ''))
                  then
                    FieldError("Quantity (Base)",StrSubstNo(Text004,FieldCaption("Return Qty. Shipped (Base)")));
                end else begin
                  if (Quantity * "Quantity Received" < 0) or
                     ((Abs(Quantity) < Abs("Quantity Received")) and ("Receipt No." = ''))
                  then
                    FieldError(Quantity,StrSubstNo(Text004,FieldCaption("Quantity Received")));
                  if ("Quantity (Base)" * "Qty. Received (Base)" < 0) or
                     ((Abs("Quantity (Base)") < Abs("Qty. Received (Base)")) and ("Receipt No." = ''))
                  then
                    FieldError("Quantity (Base)",StrSubstNo(Text004,FieldCaption("Qty. Received (Base)")));
                end;

                if (Type = Type::"Charge (Item)") and (CurrFieldNo <> 0) then begin
                  if (Quantity = 0) and ("Qty. to Assign" <> 0) then
                    FieldError("Qty. to Assign",StrSubstNo(Text011,FieldCaption(Quantity),Quantity));
                  if (Quantity * "Qty. Assigned" < 0) or (Abs(Quantity) < Abs("Qty. Assigned")) then
                    FieldError(Quantity,StrSubstNo(Text004,FieldCaption("Qty. Assigned")));
                end;

                if "Receipt No." <> '' then
                  CheckReceiptRelation
                else
                  if "Return Shipment No." <> '' then
                    CheckRetShptRelation;

                if (xRec.Quantity <> Quantity) or (xRec."Quantity (Base)" <> "Quantity (Base)") or
                   ("No." = xRec."No.")
                then begin
                  InitOutstanding;
                  if "Document Type" in ["Document Type"::"Return Order","Document Type"::"Credit Memo"] then
                    InitQtyToShip
                  else
                    InitQtyToReceive;
                end;
                if (Quantity * xRec.Quantity < 0) or (Quantity = 0) then
                  InitItemAppl;

                if Type = Type::Item then
                  UpdateDirectUnitCost(FieldNo(Quantity))
                else
                  Validate("Line Discount %");

                if Type = Type::"Charge (Item)" then
                  "Line Discount %" := 0;

                UpdateWithWarehouseReceive;
                if (xRec.Quantity <> Quantity) or (xRec."Quantity (Base)" <> "Quantity (Base)") then begin
                  OnBeforeVerifyReservedQty(Rec,xRec,FieldNo(Quantity));
                  ReservePurchLine.VerifyQuantity(Rec,xRec);
                  WhseValidateSourceLine.PurchaseLineVerifyChange(Rec,xRec);
                  CheckApplToItemLedgEntry;
                end;

                if (xRec.Quantity <> Quantity) and (Quantity = 0) and
                   ((Amount <> 0) or ("Amount Including VAT" <> 0) or ("VAT Base Amount" <> 0))
                then begin
                  Amount := 0;
                  "Amount Including VAT" := 0;
                  "VAT Base Amount" := 0;
                end;

                UpdatePrePaymentAmounts;

                if "Job Planning Line No." <> 0 then
                  Validate("Job Planning Line No.");

                if JobTaskIsSet then begin
                  CreateTempJobJnlLine(true);
                  UpdateJobPrices;
                end;

                CheckWMS;
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
                if ("Qty. to Invoice" * Quantity < 0) or (Abs("Qty. to Invoice") > Abs(MaxQtyToInvoice)) then
                  Error(
                    Text006,
                    MaxQtyToInvoice);
                if ("Qty. to Invoice (Base)" * "Quantity (Base)" < 0) or (Abs("Qty. to Invoice (Base)") > Abs(MaxQtyToInvoiceBase)) then
                  Error(
                    Text007,
                    MaxQtyToInvoiceBase);
                "VAT Difference" := 0;
                CalcInvDiscToInvoice;
                CalcPrepaymentToDeduct;

                if "Job Planning Line No." <> 0 then
                  Validate("Job Planning Line No.");
            end;
        }
        field(18;"Qty. to Receive";Decimal)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header"=R;
            Caption = 'Qty. to Receive';
            DecimalPlaces = 0:5;

            trigger OnValidate()
            begin
                GetLocation("Location Code");
                if (CurrFieldNo <> 0) and
                   (Type = Type::Item) and
                   (not "Drop Shipment")
                then begin
                  if Location."Require Receive" and
                     ("Qty. to Receive" <> 0)
                  then
                    CheckWarehouse;
                  WhseValidateSourceLine.PurchaseLineVerifyChange(Rec,xRec);
                end;

                if "Qty. to Receive" = Quantity - "Quantity Received" then
                  InitQtyToReceive
                else begin
                  "Qty. to Receive (Base)" := CalcBaseQty("Qty. to Receive");
                  InitQtyToInvoice;
                end;
                if ((("Qty. to Receive" < 0) xor (Quantity < 0)) and (Quantity <> 0) and ("Qty. to Receive" <> 0)) or
                   (Abs("Qty. to Receive") > Abs("Outstanding Quantity")) or
                   (((Quantity < 0 ) xor ("Outstanding Quantity" < 0)) and (Quantity <> 0) and ("Outstanding Quantity" <> 0))
                then
                  Error(
                    Text008,
                    "Outstanding Quantity");
                if ((("Qty. to Receive (Base)" < 0) xor ("Quantity (Base)" < 0)) and ("Quantity (Base)" <> 0) and ("Qty. to Receive (Base)" <> 0)) or
                   (Abs("Qty. to Receive (Base)") > Abs("Outstanding Qty. (Base)")) or
                   ((("Quantity (Base)" < 0) xor ("Outstanding Qty. (Base)" < 0)) and ("Quantity (Base)" <> 0) and ("Outstanding Qty. (Base)" <> 0))
                then
                  Error(
                    Text009,
                    "Outstanding Qty. (Base)");

                if (CurrFieldNo <> 0) and (Type = Type::Item) and ("Qty. to Receive" < 0) then
                  CheckApplToItemLedgEntry;

                if "Job Planning Line No." <> 0 then
                  Validate("Job Planning Line No.");
            end;
        }
        field(22;"Direct Unit Cost";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            CaptionClass = GetCaptionClass(FieldNo("Direct Unit Cost"));
            Caption = 'Direct Unit Cost';

            trigger OnValidate()
            begin
                Validate("Line Discount %");
            end;
        }
        field(23;"Unit Cost (LCY)";Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost (LCY)';

            trigger OnValidate()
            var
                IndirectCostPercent: Decimal;
            begin
                TestStatusOpen;
                TestField("No.");
                TestField(Quantity);

                if "Prod. Order No." <> '' then
                  Error(
                    Text99000000,
                    FieldCaption("Unit Cost (LCY)"));

                if CurrFieldNo = FieldNo("Unit Cost (LCY)") then
                  if Type = Type::Item then begin
                    GetItem;
                    if Item."Costing Method" = Item."Costing Method"::Standard then
                      Error(
                        Text010,
                        FieldCaption("Unit Cost (LCY)"),Item.FieldCaption("Costing Method"),Item."Costing Method");
                  end;

                UnitCostCurrency := "Unit Cost (LCY)";
                GetPurchHeader;
                if PurchHeader."Currency Code" <> '' then begin
                  PurchHeader.TestField("Currency Factor");
                  GetGLSetup;
                  UnitCostCurrency :=
                    Round(
                      CurrExchRate.ExchangeAmtLCYToFCY(
                        GetDate,"Currency Code",
                        "Unit Cost (LCY)",PurchHeader."Currency Factor"),
                      GLSetup."Unit-Amount Rounding Precision");
                end;

                "Indirect Cost %" := 0;
                if ("Direct Unit Cost" <> 0) and
                   ("Direct Unit Cost" <> ("Line Discount Amount" / Quantity))
                then begin
                  IndirectCostPercent :=
                    Round(
                      (UnitCostCurrency - "Direct Unit Cost" + "Line Discount Amount" / Quantity) /
                      ("Direct Unit Cost" - "Line Discount Amount" / Quantity) * 100,0.00001);
                  if IndirectCostPercent >= 0 then
                    "Indirect Cost %" := IndirectCostPercent;
                end;

                UpdateSalesCost;

                if JobTaskIsSet then begin
                  CreateTempJobJnlLine(false);
                  TempJobJnlLine.Validate("Unit Cost (LCY)","Unit Cost (LCY)");
                  UpdateJobPrices;
                end
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
                TestStatusOpen;
                GetPurchHeader;
                "Line Discount Amount" :=
                  Round(
                    Round(Quantity * "Direct Unit Cost",Currency."Amount Rounding Precision") *
                    "Line Discount %" / 100,
                    Currency."Amount Rounding Precision");
                "Inv. Discount Amount" := 0;
                "Inv. Disc. Amount to Invoice" := 0;
                UpdateAmounts;
                UpdateUnitCost;
            end;
        }
        field(28;"Line Discount Amount";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Line Discount Amount';

            trigger OnValidate()
            begin
                GetPurchHeader;
                "Line Discount Amount" := Round("Line Discount Amount",Currency."Amount Rounding Precision");
                TestStatusOpen;
                TestField(Quantity);
                if xRec."Line Discount Amount" <> "Line Discount Amount" then
                  UpdateLineDiscPct;
                "Inv. Discount Amount" := 0;
                "Inv. Disc. Amount to Invoice" := 0;
                UpdateAmounts;
                UpdateUnitCost;
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
                GetPurchHeader;
                Amount := Round(Amount,Currency."Amount Rounding Precision");
                case "VAT Calculation Type" of
                  "VAT Calculation Type"::"Normal VAT",
                  "VAT Calculation Type"::"Reverse Charge VAT":
                    begin
                      "VAT Base Amount" :=
                        Round(Amount * (1 - PurchHeader."VAT Base Discount %" / 100),Currency."Amount Rounding Precision");
                      "Amount Including VAT" :=
                        Round(Amount + "VAT Base Amount" * "VAT %" / 100,Currency."Amount Rounding Precision");
                    end;
                  "VAT Calculation Type"::"Full VAT":
                    if Amount <> 0 then
                      FieldError(Amount,
                        StrSubstNo(
                          Text011,FieldCaption("VAT Calculation Type"),
                          "VAT Calculation Type"));
                  "VAT Calculation Type"::"Sales Tax":
                    begin
                      PurchHeader.TestField("VAT Base Discount %",0);
                      "VAT Base Amount" := Amount;
                      if "Use Tax" then
                        "Amount Including VAT" := "VAT Base Amount"
                      else begin
                        "Amount Including VAT" :=
                          Amount +
                          Round(
                            SalesTaxCalculate.CalculateTax(
                              "Tax Area Code","Tax Group Code","Tax Liable",PurchHeader."Posting Date",
                              "VAT Base Amount","Quantity (Base)",PurchHeader."Currency Factor"),
                            Currency."Amount Rounding Precision");
                        if "VAT Base Amount" <> 0 then
                          "VAT %" :=
                            Round(100 * ("Amount Including VAT" - "VAT Base Amount") / "VAT Base Amount",0.00001)
                        else
                          "VAT %" := 0;
                      end;
                    end;
                end;

                InitOutstandingAmount;
                UpdateUnitCost;
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
                GetPurchHeader;
                "Amount Including VAT" := Round("Amount Including VAT",Currency."Amount Rounding Precision");
                case "VAT Calculation Type" of
                  "VAT Calculation Type"::"Normal VAT",
                  "VAT Calculation Type"::"Reverse Charge VAT":
                    begin
                      Amount :=
                        Round(
                          "Amount Including VAT" /
                          (1 + (1 - PurchHeader."VAT Base Discount %" / 100) * "VAT %" / 100),
                          Currency."Amount Rounding Precision");
                      "VAT Base Amount" :=
                        Round(Amount * (1 - PurchHeader."VAT Base Discount %" / 100),Currency."Amount Rounding Precision");
                    end;
                  "VAT Calculation Type"::"Full VAT":
                    begin
                      Amount := 0;
                      "VAT Base Amount" := 0;
                    end;
                  "VAT Calculation Type"::"Sales Tax":
                    begin
                      PurchHeader.TestField("VAT Base Discount %",0);
                      if "Use Tax" then begin
                        Amount := "Amount Including VAT";
                        "VAT Base Amount" := Amount;
                      end else begin
                        Amount :=
                          Round(
                            SalesTaxCalculate.ReverseCalculateTax(
                              "Tax Area Code","Tax Group Code","Tax Liable",PurchHeader."Posting Date",
                              "Amount Including VAT","Quantity (Base)",PurchHeader."Currency Factor"),
                            Currency."Amount Rounding Precision");
                        "VAT Base Amount" := Amount;
                        if "VAT Base Amount" <> 0 then
                          "VAT %" :=
                            Round(100 * ("Amount Including VAT" - "VAT Base Amount") / "VAT Base Amount",0.00001)
                        else
                          "VAT %" := 0;
                      end;
                    end;
                end;

                InitOutstandingAmount;
                UpdateUnitCost;
            end;
        }
        field(31;"Unit Price (LCY)";Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Price (LCY)';
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
                  UpdateUnitCost;
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
                SelectItemEntry;
            end;

            trigger OnValidate()
            begin
                if "Appl.-to Item Entry" <> 0 then
                  "Location Code" := CheckApplToItemLedgEntry;
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
            end;
        }
        field(45;"Job No.";Code[20])
        {
            Caption = 'Job No.';
            TableRelation = Job;

            trigger OnValidate()
            var
                Job: Record Job;
            begin
                TestField("Drop Shipment",false);
                TestField("Special Order",false);
                TestField("Receipt No.",'');
                if "Document Type" = "Document Type"::Order then
                  TestField("Quantity Received",0);

                if ReservEntryExist then
                  TestField("Job No.",'');

                if "Job No." <> xRec."Job No." then begin
                  Validate("Job Task No.",'');
                  Validate("Job Planning Line No.",0);
                end;

                if "Job No." = '' then begin
                  CreateDim(
                    DATABASE::Job,"Job No.",
                    DimMgt.TypeToTableID3(Type),"No.",
                    DATABASE::"Responsibility Center","Responsibility Center",
                    DATABASE::"Work Center","Work Center No.");
                  exit;
                end;

                if not (Type in [Type::Item,Type::"G/L Account"]) then
                  FieldError("Job No.",StrSubstNo(Text012,FieldCaption(Type),Type));
                Job.Get("Job No.");
                Job.TestBlocked;
                "Job Currency Code" := Job."Currency Code";

                CreateDim(
                  DATABASE::Job,"Job No.",
                  DimMgt.TypeToTableID3(Type),"No.",
                  DATABASE::"Responsibility Center","Responsibility Center",
                  DATABASE::"Work Center","Work Center No.");
            end;
        }
        field(54;"Indirect Cost %";Decimal)
        {
            Caption = 'Indirect Cost %';
            DecimalPlaces = 0:5;
            MinValue = 0;

            trigger OnValidate()
            begin
                TestField("No.");
                TestStatusOpen;

                if Type = Type::"Charge (Item)" then
                  TestField("Indirect Cost %",0);

                if (Type = Type::Item) and ("Prod. Order No." = '') then begin
                  GetItem;
                  if Item."Costing Method" = Item."Costing Method"::Standard then
                    Error(
                      Text010,
                      FieldCaption("Indirect Cost %"),Item.FieldCaption("Costing Method"),Item."Costing Method");
                end;

                UpdateUnitCost;
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
                GetPurchHeader;
                Currency2.InitRoundingPrecision;
                if PurchHeader."Currency Code" <> '' then
                  "Outstanding Amount (LCY)" :=
                    Round(
                      CurrExchRate.ExchangeAmtFCYToLCY(
                        GetDate,"Currency Code",
                        "Outstanding Amount",PurchHeader."Currency Factor"),
                      Currency2."Amount Rounding Precision")
                else
                  "Outstanding Amount (LCY)" :=
                    Round("Outstanding Amount",Currency2."Amount Rounding Precision");

                "Outstanding Amt. Ex. VAT (LCY)" :=
                  Round("Outstanding Amount (LCY)" / (1 + "VAT %" / 100),Currency2."Amount Rounding Precision");
            end;
        }
        field(58;"Qty. Rcd. Not Invoiced";Decimal)
        {
            Caption = 'Qty. Rcd. Not Invoiced';
            DecimalPlaces = 0:5;
            Editable = false;
        }
        field(59;"Amt. Rcd. Not Invoiced";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amt. Rcd. Not Invoiced';
            Editable = false;

            trigger OnValidate()
            var
                Currency2: Record Currency;
            begin
                GetPurchHeader;
                Currency2.InitRoundingPrecision;
                if PurchHeader."Currency Code" <> '' then
                  "Amt. Rcd. Not Invoiced (LCY)" :=
                    Round(
                      CurrExchRate.ExchangeAmtFCYToLCY(
                        GetDate,"Currency Code",
                        "Amt. Rcd. Not Invoiced",PurchHeader."Currency Factor"),
                      Currency2."Amount Rounding Precision")
                else
                  "Amt. Rcd. Not Invoiced (LCY)" :=
                    Round("Amt. Rcd. Not Invoiced",Currency2."Amount Rounding Precision");

                "A. Rcd. Not Inv. Ex. VAT (LCY)" :=
                  Round("Amt. Rcd. Not Invoiced (LCY)" / (1 + "VAT %" / 100),Currency2."Amount Rounding Precision");
            end;
        }
        field(60;"Quantity Received";Decimal)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header"=R;
            Caption = 'Quantity Received';
            DecimalPlaces = 0:5;
            Editable = false;
        }
        field(61;"Quantity Invoiced";Decimal)
        {
            Caption = 'Quantity Invoiced';
            DecimalPlaces = 0:5;
            Editable = false;
        }
        field(63;"Receipt No.";Code[20])
        {
            Caption = 'Receipt No.';
            Editable = false;
        }
        field(64;"Receipt Line No.";Integer)
        {
            Caption = 'Receipt Line No.';
            Editable = false;
        }
        field(65;"Order No.";Code[20])
        {
            Caption = 'Order No.';
        }
        field(66;"Order Line No.";Integer)
        {
            Caption = 'Order Line No.';
        }
        field(67;"Profit %";Decimal)
        {
            Caption = 'Profit %';
            DecimalPlaces = 0:5;
            Editable = false;
        }
        field(68;"Pay-to Vendor No.";Code[20])
        {
            Caption = 'Pay-to Vendor No.';
            Editable = false;
            TableRelation = Vendor;
        }
        field(69;"Inv. Discount Amount";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Inv. Discount Amount';
            Editable = false;

            trigger OnValidate()
            begin
                UpdateAmounts;
                UpdateUnitCost;
                CalcInvDiscToInvoice;
            end;
        }
        field(70;"Vendor Item No.";Text[20])
        {
            Caption = 'Vendor Item No.';

            trigger OnValidate()
            begin
                if PurchHeader."Send IC Document" and
                   ("IC Partner Ref. Type" = "IC Partner Ref. Type"::"Vendor Item No.")
                then
                  "IC Partner Reference" := "Vendor Item No.";
            end;
        }
        field(71;"Sales Order No.";Code[20])
        {
            Caption = 'Sales Order No.';
            Editable = false;
            TableRelation = IF ("Drop Shipment"=CONST(true)) "Sales Header"."No." WHERE ("Document Type"=CONST(Order));

            trigger OnValidate()
            begin
                if (xRec."Sales Order No." <> "Sales Order No.") and (Quantity <> 0) then begin
                  ReservePurchLine.VerifyChange(Rec,xRec);
                  WhseValidateSourceLine.PurchaseLineVerifyChange(Rec,xRec);
                end;
            end;
        }
        field(72;"Sales Order Line No.";Integer)
        {
            Caption = 'Sales Order Line No.';
            Editable = false;
            TableRelation = IF ("Drop Shipment"=CONST(true)) "Sales Line"."Line No." WHERE ("Document Type"=CONST(Order),
                                                                                            "Document No."=FIELD("Sales Order No."));

            trigger OnValidate()
            begin
                if (xRec."Sales Order Line No." <> "Sales Order Line No.") and (Quantity <> 0) then begin
                  ReservePurchLine.VerifyChange(Rec,xRec);
                  WhseValidateSourceLine.PurchaseLineVerifyChange(Rec,xRec);
                end;
            end;
        }
        field(73;"Drop Shipment";Boolean)
        {
            AccessByPermission = TableData "Drop Shpt. Post. Buffer"=R;
            Caption = 'Drop Shipment';
            Editable = false;

            trigger OnValidate()
            begin
                if (xRec."Drop Shipment" <> "Drop Shipment") and (Quantity <> 0) then begin
                  ReservePurchLine.VerifyChange(Rec,xRec);
                  WhseValidateSourceLine.PurchaseLineVerifyChange(Rec,xRec);
                end;
                if "Drop Shipment" then begin
                  "Bin Code" := '';
                  Evaluate("Inbound Whse. Handling Time",'<0D>');
                  Validate("Inbound Whse. Handling Time");
                  InitOutstanding;
                  InitQtyToReceive;
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
            TableRelation = "Purchase Line"."Line No." WHERE ("Document Type"=FIELD("Document Type"),
                                                              "Document No."=FIELD("Document No."));
        }
        field(81;"Entry Point";Code[10])
        {
            Caption = 'Entry Point';
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
                UpdateAmounts;
            end;
        }
        field(88;"Use Tax";Boolean)
        {
            Caption = 'Use Tax';

            trigger OnValidate()
            begin
                UpdateAmounts;
            end;
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
                GetPurchHeader;
                "VAT %" := VATPostingSetup."VAT %";
                "VAT Calculation Type" := VATPostingSetup."VAT Calculation Type";
                "VAT Identifier" := VATPostingSetup."VAT Identifier";
                case "VAT Calculation Type" of
                  "VAT Calculation Type"::"Reverse Charge VAT",
                  "VAT Calculation Type"::"Sales Tax":
                    "VAT %" := 0;
                  "VAT Calculation Type"::"Full VAT":
                    begin
                      TestField(Type,Type::"G/L Account");
                      TestField("No.",VATPostingSetup.GetPurchAccount(false));
                    end;
                end;
                if PurchHeader."Prices Including VAT" and (Type = Type::Item) then
                  "Direct Unit Cost" :=
                    Round(
                      "Direct Unit Cost" * (100 + "VAT %") / (100 + xRec."VAT %"),
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
        field(93;"Amt. Rcd. Not Invoiced (LCY)";Decimal)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header"=R;
            AutoFormatType = 1;
            Caption = 'Amt. Rcd. Not Invoiced (LCY)';
            Editable = false;
        }
        field(95;"Reserved Quantity";Decimal)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header"=R;
            CalcFormula = Sum("Reservation Entry".Quantity WHERE ("Source ID"=FIELD("Document No."),
                                                                  "Source Ref. No."=FIELD("Line No."),
                                                                  "Source Type"=CONST(39),
                                                                  "Source Subtype"=FIELD("Document Type"),
                                                                  "Reservation Status"=CONST(Reservation)));
            Caption = 'Reserved Quantity';
            DecimalPlaces = 0:5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(97;"Blanket Order No.";Code[20])
        {
            AccessByPermission = TableData "Purch. Rcpt. Header"=R;
            Caption = 'Blanket Order No.';
            TableRelation = "Purchase Header"."No." WHERE ("Document Type"=CONST("Blanket Order"));
            //This property is currently not supported
            //TestTableRelation = false;

            trigger OnLookup()
            begin
                TestField("Quantity Received",0);
                BlanketOrderLookup;
            end;

            trigger OnValidate()
            begin
                TestField("Quantity Received",0);
                if "Blanket Order No." = '' then
                  "Blanket Order Line No." := 0
                else
                  Validate("Blanket Order Line No.");
            end;
        }
        field(98;"Blanket Order Line No.";Integer)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header"=R;
            Caption = 'Blanket Order Line No.';
            TableRelation = "Purchase Line"."Line No." WHERE ("Document Type"=CONST("Blanket Order"),
                                                              "Document No."=FIELD("Blanket Order No."));
            //This property is currently not supported
            //TestTableRelation = false;

            trigger OnLookup()
            begin
                BlanketOrderLookup;
            end;

            trigger OnValidate()
            begin
                TestField("Quantity Received",0);
                if "Blanket Order Line No." <> 0 then begin
                  PurchLine2.Get("Document Type"::"Blanket Order","Blanket Order No.","Blanket Order Line No.");
                  PurchLine2.TestField(Type,Type);
                  PurchLine2.TestField("No.","No.");
                  PurchLine2.TestField("Pay-to Vendor No.","Pay-to Vendor No.");
                  PurchLine2.TestField("Buy-from Vendor No.","Buy-from Vendor No.");
                  if "Drop Shipment" then begin
                    PurchLine2.TestField("Variant Code","Variant Code");
                    PurchLine2.TestField("Location Code","Location Code");
                    PurchLine2.TestField("Unit of Measure Code","Unit of Measure Code");
                  end else begin
                    Validate("Variant Code",PurchLine2."Variant Code");
                    Validate("Location Code",PurchLine2."Location Code");
                    Validate("Unit of Measure Code",PurchLine2."Unit of Measure Code");
                  end;
                  Validate("Direct Unit Cost",PurchLine2."Direct Unit Cost");
                  Validate("Line Discount %",PurchLine2."Line Discount %");
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
            begin
                TestField(Type);
                TestField(Quantity);
                TestField("Direct Unit Cost");

                GetPurchHeader;
                "Line Amount" := Round("Line Amount",Currency."Amount Rounding Precision");
                Validate(
                  "Line Discount Amount",Round(Quantity * "Direct Unit Cost",Currency."Amount Rounding Precision") - "Line Amount");
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
            OptionCaption = ' ,G/L Account,Item,,,Charge (Item),Cross Reference,Common Item No.,Vendor Item No.';
            OptionMembers = " ","G/L Account",Item,,,"Charge (Item)","Cross Reference","Common Item No.","Vendor Item No.";

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
                ItemVendorCatalog: Record "Item Vendor";
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
                        GetPurchHeader;
                        ItemCrossReference.Reset;
                        ItemCrossReference.SetCurrentKey("Cross-Reference Type","Cross-Reference Type No.");
                        ItemCrossReference.SetFilter(
                          "Cross-Reference Type",'%1|%2',
                          ItemCrossReference."Cross-Reference Type"::Vendor,
                          ItemCrossReference."Cross-Reference Type"::" ");
                        ItemCrossReference.SetFilter("Cross-Reference Type No.",'%1|%2',PurchHeader."Buy-from Vendor No.",'');
                        if PAGE.RunModal(PAGE::"Cross Reference List",ItemCrossReference) = ACTION::LookupOK then
                          Validate("IC Partner Reference",ItemCrossReference."Cross-Reference No.");
                      end;
                    "IC Partner Ref. Type"::"Vendor Item No.":
                      begin
                        GetPurchHeader;
                        ItemVendorCatalog.SetCurrentKey("Vendor No.");
                        ItemVendorCatalog.SetRange("Vendor No.",PurchHeader."Buy-from Vendor No.");
                        if PAGE.RunModal(PAGE::"Vendor Item Catalog",ItemVendorCatalog) = ACTION::LookupOK then
                          Validate("IC Partner Reference",ItemVendorCatalog."Vendor Item No.");
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
                  FieldError("Prepmt. Line Amount",StrSubstNo(Text038,"Prepmt. Amt. Inv."));
                if "Prepmt. Line Amount" > "Line Amount" then
                  FieldError("Prepmt. Line Amount",StrSubstNo(Text039,"Line Amount"));
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
                    StrSubstNo(Text039,"Prepmt. Amt. Inv." - "Prepmt Amt Deducted"));

                if "Prepmt Amt to Deduct" > "Qty. to Invoice" * "Direct Unit Cost" then
                  FieldError(
                    "Prepmt Amt to Deduct",
                    StrSubstNo(Text039,"Qty. to Invoice" * "Direct Unit Cost"));
                if ("Prepmt. Amt. Inv." - "Prepmt Amt to Deduct" - "Prepmt Amt Deducted") >
                   (Quantity - "Qty. to Invoice" - "Quantity Invoiced") * "Direct Unit Cost"
                then
                  FieldError(
                    "Prepmt Amt to Deduct",
                    StrSubstNo(Text038,
                      "Prepmt. Amt. Inv." - "Prepmt Amt Deducted" -
                      (Quantity - "Qty. to Invoice" - "Quantity Invoiced") * "Direct Unit Cost"));
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
                  GetPurchHeader;
                  PurchHeader.TestField("Buy-from IC Partner Code",'');
                  PurchHeader.TestField("Pay-to IC Partner Code",'');
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
        field(140;"Outstanding Amt. Ex. VAT (LCY)";Decimal)
        {
            Caption = 'Outstanding Amt. Ex. VAT (LCY)';
        }
        field(141;"A. Rcd. Not Inv. Ex. VAT (LCY)";Decimal)
        {
            Caption = 'A. Rcd. Not Inv. Ex. VAT (LCY)';
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
        field(1001;"Job Task No.";Code[20])
        {
            Caption = 'Job Task No.';
            TableRelation = "Job Task"."Job Task No." WHERE ("Job No."=FIELD("Job No."));

            trigger OnValidate()
            begin
                TestField("Receipt No.",'');

                if "Job Task No." <> xRec."Job Task No." then begin
                  Validate("Job Planning Line No.",0);
                  if "Document Type" = "Document Type"::Order then
                    TestField("Quantity Received",0);
                end;

                if "Job Task No." = '' then begin
                  Clear(TempJobJnlLine);
                  "Job Line Type" := "Job Line Type"::" ";
                  UpdateJobPrices;
                  CreateDim(
                    DimMgt.TypeToTableID3(Type),"No.",
                    DATABASE::Job,"Job No.",
                    DATABASE::"Responsibility Center","Responsibility Center",
                    DATABASE::"Work Center","Work Center No.");
                  exit;
                end;

                JobSetCurrencyFactor;
                if JobTaskIsSet then begin
                  CreateTempJobJnlLine(true);
                  UpdateJobPrices;
                end;
                UpdateDimensionsFromJobTask;
            end;
        }
        field(1002;"Job Line Type";Option)
        {
            AccessByPermission = TableData Job=R;
            Caption = 'Job Line Type';
            OptionCaption = ' ,Budget,Billable,Both Budget and Billable';
            OptionMembers = " ",Budget,Billable,"Both Budget and Billable";

            trigger OnValidate()
            begin
                TestField("Receipt No.",'');
                if "Document Type" = "Document Type"::Order then
                  TestField("Quantity Received",0);

                if "Job Planning Line No." <> 0 then
                  Error(Text048,FieldCaption("Job Line Type"),FieldCaption("Job Planning Line No."));
            end;
        }
        field(1003;"Job Unit Price";Decimal)
        {
            AccessByPermission = TableData Job=R;
            BlankZero = true;
            Caption = 'Job Unit Price';

            trigger OnValidate()
            begin
                TestField("Receipt No.",'');
                if "Document Type" = "Document Type"::Order then
                  TestField("Quantity Received",0);

                if JobTaskIsSet then begin
                  CreateTempJobJnlLine(false);
                  TempJobJnlLine.Validate("Unit Price","Job Unit Price");
                  UpdateJobPrices;
                end;
            end;
        }
        field(1004;"Job Total Price";Decimal)
        {
            AccessByPermission = TableData Job=R;
            BlankZero = true;
            Caption = 'Job Total Price';
            Editable = false;
        }
        field(1005;"Job Line Amount";Decimal)
        {
            AccessByPermission = TableData Job=R;
            AutoFormatExpression = "Job Currency Code";
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Job Line Amount';

            trigger OnValidate()
            begin
                TestField("Receipt No.",'');
                if "Document Type" = "Document Type"::Order then
                  TestField("Quantity Received",0);

                if JobTaskIsSet then begin
                  CreateTempJobJnlLine(false);
                  TempJobJnlLine.Validate("Line Amount","Job Line Amount");
                  UpdateJobPrices;
                end;
            end;
        }
        field(1006;"Job Line Discount Amount";Decimal)
        {
            AccessByPermission = TableData Job=R;
            AutoFormatExpression = "Job Currency Code";
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Job Line Discount Amount';

            trigger OnValidate()
            begin
                TestField("Receipt No.",'');
                if "Document Type" = "Document Type"::Order then
                  TestField("Quantity Received",0);

                if JobTaskIsSet then begin
                  CreateTempJobJnlLine(false);
                  TempJobJnlLine.Validate("Line Discount Amount","Job Line Discount Amount");
                  UpdateJobPrices;
                end;
            end;
        }
        field(1007;"Job Line Discount %";Decimal)
        {
            AccessByPermission = TableData Job=R;
            BlankZero = true;
            Caption = 'Job Line Discount %';
            DecimalPlaces = 0:5;
            MaxValue = 100;
            MinValue = 0;

            trigger OnValidate()
            begin
                TestField("Receipt No.",'');
                if "Document Type" = "Document Type"::Order then
                  TestField("Quantity Received",0);

                if JobTaskIsSet then begin
                  CreateTempJobJnlLine(false);
                  TempJobJnlLine.Validate("Line Discount %","Job Line Discount %");
                  UpdateJobPrices;
                end;
            end;
        }
        field(1008;"Job Unit Price (LCY)";Decimal)
        {
            AccessByPermission = TableData Job=R;
            BlankZero = true;
            Caption = 'Job Unit Price (LCY)';
            Editable = false;

            trigger OnValidate()
            begin
                TestField("Receipt No.",'');
                if "Document Type" = "Document Type"::Order then
                  TestField("Quantity Received",0);

                if JobTaskIsSet then begin
                  CreateTempJobJnlLine(false);
                  TempJobJnlLine.Validate("Unit Price (LCY)","Job Unit Price (LCY)");
                  UpdateJobPrices;
                end;
            end;
        }
        field(1009;"Job Total Price (LCY)";Decimal)
        {
            AccessByPermission = TableData Job=R;
            BlankZero = true;
            Caption = 'Job Total Price (LCY)';
            Editable = false;
        }
        field(1010;"Job Line Amount (LCY)";Decimal)
        {
            AccessByPermission = TableData Job=R;
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Job Line Amount (LCY)';
            Editable = false;

            trigger OnValidate()
            begin
                TestField("Receipt No.",'');
                if "Document Type" = "Document Type"::Order then
                  TestField("Quantity Received",0);

                if JobTaskIsSet then begin
                  CreateTempJobJnlLine(false);
                  TempJobJnlLine.Validate("Line Amount (LCY)","Job Line Amount (LCY)");
                  UpdateJobPrices;
                end;
            end;
        }
        field(1011;"Job Line Disc. Amount (LCY)";Decimal)
        {
            AccessByPermission = TableData Job=R;
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Job Line Disc. Amount (LCY)';
            Editable = false;

            trigger OnValidate()
            begin
                TestField("Receipt No.",'');
                if "Document Type" = "Document Type"::Order then
                  TestField("Quantity Received",0);

                if JobTaskIsSet then begin
                  CreateTempJobJnlLine(false);
                  TempJobJnlLine.Validate("Line Discount Amount (LCY)","Job Line Disc. Amount (LCY)");
                  UpdateJobPrices;
                end;
            end;
        }
        field(1012;"Job Currency Factor";Decimal)
        {
            BlankZero = true;
            Caption = 'Job Currency Factor';
        }
        field(1013;"Job Currency Code";Code[20])
        {
            Caption = 'Job Currency Code';
        }
        field(1019;"Job Planning Line No.";Integer)
        {
            AccessByPermission = TableData Job=R;
            BlankZero = true;
            Caption = 'Job Planning Line No.';

            trigger OnLookup()
            var
                JobPlanningLine: Record "Job Planning Line";
            begin
                JobPlanningLine.SetRange("Job No.","Job No.");
                JobPlanningLine.SetRange("Job Task No.","Job Task No.");
                case Type of
                  Type::"G/L Account":
                    JobPlanningLine.SetRange(Type,JobPlanningLine.Type::"G/L Account");
                  Type::Item:
                    JobPlanningLine.SetRange(Type,JobPlanningLine.Type::Item);
                end;
                JobPlanningLine.SetRange("No.","No.");
                JobPlanningLine.SetRange("Usage Link",true);
                JobPlanningLine.SetRange("System-Created Entry",false);

                if PAGE.RunModal(0,JobPlanningLine) = ACTION::LookupOK then
                  Validate("Job Planning Line No.",JobPlanningLine."Line No.");
            end;

            trigger OnValidate()
            var
                JobPlanningLine: Record "Job Planning Line";
            begin
                if "Job Planning Line No." <> 0 then begin
                  JobPlanningLine.Get("Job No.","Job Task No.","Job Planning Line No.");
                  JobPlanningLine.TestField("Job No.","Job No.");
                  JobPlanningLine.TestField("Job Task No.","Job Task No.");
                  case Type of
                    Type::"G/L Account":
                      JobPlanningLine.TestField(Type,JobPlanningLine.Type::"G/L Account");
                    Type::Item:
                      JobPlanningLine.TestField(Type,JobPlanningLine.Type::Item);
                  end;
                  JobPlanningLine.TestField("No.","No.");
                  JobPlanningLine.TestField("Usage Link",true);
                  JobPlanningLine.TestField("System-Created Entry",false);
                  "Job Line Type" := JobPlanningLine."Line Type" + 1;
                  Validate("Job Remaining Qty.",JobPlanningLine."Remaining Qty." - "Qty. to Invoice");
                end else
                  Validate("Job Remaining Qty.",0);
            end;
        }
        field(1030;"Job Remaining Qty.";Decimal)
        {
            AccessByPermission = TableData Job=R;
            Caption = 'Job Remaining Qty.';
            DecimalPlaces = 0:5;

            trigger OnValidate()
            var
                JobPlanningLine: Record "Job Planning Line";
            begin
                if ("Job Remaining Qty." <> 0) and ("Job Planning Line No." = 0) then
                  Error(Text047,FieldCaption("Job Remaining Qty."),FieldCaption("Job Planning Line No."));

                if "Job Planning Line No." <> 0 then begin
                  JobPlanningLine.Get("Job No.","Job Task No.","Job Planning Line No.");
                  if JobPlanningLine.Quantity >= 0 then begin
                    if "Job Remaining Qty." < 0 then
                      "Job Remaining Qty." := 0;
                  end else begin
                    if "Job Remaining Qty." > 0 then
                      "Job Remaining Qty." := 0;
                  end;
                end;
                "Job Remaining Qty. (Base)" := CalcBaseQty("Job Remaining Qty.");
            end;
        }
        field(1031;"Job Remaining Qty. (Base)";Decimal)
        {
            Caption = 'Job Remaining Qty. (Base)';
        }
        field(1700;"Deferral Code";Code[10])
        {
            Caption = 'Deferral Code';
            TableRelation = "Deferral Template"."Deferral Code";

            trigger OnValidate()
            var
                DeferralPostDate: Date;
            begin
                GetPurchHeader;
                DeferralPostDate := PurchHeader."Posting Date";

                DeferralUtilities.DeferralCodeOnValidate(
                  "Deferral Code",DeferralUtilities.GetPurchDeferralDocType,'','',
                  "Document Type","Document No.","Line No.",
                  GetDeferralAmount,DeferralPostDate,
                  Description,PurchHeader."Currency Code");

                if "Document Type" = "Document Type"::"Return Order" then
                  "Returns Deferral Start Date" :=
                    DeferralUtilities.GetDeferralStartDate(DeferralUtilities.GetPurchDeferralDocType,
                      "Document Type","Document No.","Line No.","Deferral Code",PurchHeader."Posting Date");
            end;
        }
        field(1702;"Returns Deferral Start Date";Date)
        {
            Caption = 'Returns Deferral Start Date';

            trigger OnValidate()
            var
                DeferralHeader: Record "Deferral Header";
                DeferralUtilities: Codeunit "Deferral Utilities";
            begin
                GetPurchHeader;
                if DeferralHeader.Get(DeferralUtilities.GetPurchDeferralDocType,'','',"Document Type","Document No.","Line No.") then
                  DeferralUtilities.CreateDeferralSchedule("Deferral Code",DeferralUtilities.GetPurchDeferralDocType,'','',
                    "Document Type","Document No.","Line No.",GetDeferralAmount,
                    DeferralHeader."Calc. Method","Returns Deferral Start Date",
                    DeferralHeader."No. of Periods",true,
                    DeferralHeader."Schedule Description",false,
                    PurchHeader."Currency Code");
            end;
        }
        field(5401;"Prod. Order No.";Code[20])
        {
            AccessByPermission = TableData "Machine Center"=R;
            Caption = 'Prod. Order No.';
            Editable = false;
            TableRelation = "Production Order"."No." WHERE (Status=CONST(Released));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                if "Drop Shipment" then
                  Error(
                    Text001,
                    FieldCaption("Prod. Order No."),"Sales Order No.");

                AddOnIntegrMgt.ValidateProdOrderOnPurchLine(Rec);
            end;
        }
        field(5402;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = IF (Type=CONST(Item)) "Item Variant".Code WHERE ("Item No."=FIELD("No."));

            trigger OnValidate()
            begin
                if "Variant Code" <> '' then
                  TestField(Type,Type::Item);
                TestStatusOpen;

                if xRec."Variant Code" <> "Variant Code" then begin
                  TestField("Qty. Rcd. Not Invoiced",0);
                  TestField("Receipt No.",'');

                  TestField("Return Qty. Shipped Not Invd.",0);
                  TestField("Return Shipment No.",'');
                end;

                if "Drop Shipment" then
                  Error(
                    Text001,
                    FieldCaption("Variant Code"),"Sales Order No.");

                if Type = Type::Item then
                  UpdateDirectUnitCost(FieldNo("Variant Code"));

                if (xRec."Variant Code" <> "Variant Code") and (Quantity <> 0) then begin
                  ReservePurchLine.VerifyChange(Rec,xRec);
                  WhseValidateSourceLine.PurchaseLineVerifyChange(Rec,xRec);
                  InitItemAppl;
                end;

                UpdateLeadTimeFields;
                UpdateDates;
                GetDefaultBin;
                if Type = Type::Item then
                  UpdateItemReference;

                if JobTaskIsSet then begin
                  CreateTempJobJnlLine(true);
                  UpdateJobPrices;
                end;
            end;
        }
        field(5403;"Bin Code";Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = IF ("Document Type"=FILTER(Order|Invoice),
                                Quantity=FILTER(<0)) "Bin Content"."Bin Code" WHERE ("Location Code"=FIELD("Location Code"),
                                                                                     "Item No."=FIELD("No."),
                                                                                     "Variant Code"=FIELD("Variant Code"))
                                                                                     ELSE IF ("Document Type"=FILTER("Return Order"|"Credit Memo"),
                                                                                              Quantity=FILTER(>=0)) "Bin Content"."Bin Code" WHERE ("Location Code"=FIELD("Location Code"),
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
                  if not IsInbound and ("Quantity (Base)" <> 0) then
                    WMSManagement.FindBinContent("Location Code","Bin Code","No.","Variant Code",'')
                  else
                    WMSManagement.FindBin("Location Code","Bin Code",'');
                end;

                if "Drop Shipment" then
                  Error(
                    Text001,
                    FieldCaption("Bin Code"),"Sales Order No.");

                TestField(Type,Type::Item);
                TestField("Location Code");

                if "Bin Code" <> '' then begin
                  GetLocation("Location Code");
                  Location.TestField("Bin Mandatory");
                  CheckWarehouse;
                end;
            end;
        }
        field(5404;"Qty. per Unit of Measure";Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0:5;
            Editable = false;
            InitValue = 1;
        }
        field(5407;"Unit of Measure Code";Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = IF (Type=CONST(Item),
                                "No."=FILTER(<>'')) "Item Unit of Measure".Code WHERE ("Item No."=FIELD("No."))
                                ELSE "Unit of Measure";

            trigger OnValidate()
            var
                UnitOfMeasureTranslation: Record "Unit of Measure Translation";
            begin
                TestStatusOpen;
                TestField("Quantity Received",0);
                TestField("Qty. Received (Base)",0);
                TestField("Qty. Rcd. Not Invoiced",0);
                TestField("Return Qty. Shipped",0);
                TestField("Return Qty. Shipped (Base)",0);
                if "Unit of Measure Code" <> xRec."Unit of Measure Code" then begin
                  TestField("Receipt No.",'');
                  TestField("Return Shipment No.",'');
                end;
                if "Drop Shipment" then
                  Error(
                    Text001,
                    FieldCaption("Unit of Measure Code"),"Sales Order No.");
                if (xRec."Unit of Measure Code" <> "Unit of Measure Code") and (Quantity <> 0) then
                  WhseValidateSourceLine.PurchaseLineVerifyChange(Rec,xRec);
                UpdateDirectUnitCost(FieldNo("Unit of Measure Code"));
                if "Unit of Measure Code" = '' then
                  "Unit of Measure" := ''
                else begin
                  UnitOfMeasure.Get("Unit of Measure Code");
                  "Unit of Measure" := UnitOfMeasure.Description;
                  GetPurchHeader;
                  if PurchHeader."Language Code" <> '' then begin
                    UnitOfMeasureTranslation.SetRange(Code,"Unit of Measure Code");
                    UnitOfMeasureTranslation.SetRange("Language Code",PurchHeader."Language Code");
                    if UnitOfMeasureTranslation.FindFirst then
                      "Unit of Measure" := UnitOfMeasureTranslation.Description;
                  end;
                end;
                if Type = Type::Item then
                  UpdateItemReference;
                if "Prod. Order No." = '' then begin
                  if (Type = Type::Item) and ("No." <> '') then begin
                    GetItem;
                    "Qty. per Unit of Measure" := UOMMgt.GetQtyPerUnitOfMeasure(Item,"Unit of Measure Code");
                    "Gross Weight" := Item."Gross Weight" * "Qty. per Unit of Measure";
                    "Net Weight" := Item."Net Weight" * "Qty. per Unit of Measure";
                    "Unit Volume" := Item."Unit Volume" * "Qty. per Unit of Measure";
                    "Units per Parcel" := Round(Item."Units per Parcel" / "Qty. per Unit of Measure",0.00001);
                    OnAfterAssignItemUOM(Rec,Item);
                    if "Qty. per Unit of Measure" > xRec."Qty. per Unit of Measure" then
                      InitItemAppl;
                    UpdateUOMQtyPerStockQty;
                  end else
                    "Qty. per Unit of Measure" := 1;
                end else
                  "Qty. per Unit of Measure" := 0;

                Validate(Quantity);
            end;
        }
        field(5415;"Quantity (Base)";Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0:5;

            trigger OnValidate()
            begin
                TestField("Qty. per Unit of Measure",1);
                Validate(Quantity,"Quantity (Base)");
                UpdateDirectUnitCost(FieldNo("Quantity (Base)"));
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
        field(5418;"Qty. to Receive (Base)";Decimal)
        {
            Caption = 'Qty. to Receive (Base)';
            DecimalPlaces = 0:5;

            trigger OnValidate()
            begin
                TestField("Qty. per Unit of Measure",1);
                Validate("Qty. to Receive","Qty. to Receive (Base)");
            end;
        }
        field(5458;"Qty. Rcd. Not Invoiced (Base)";Decimal)
        {
            Caption = 'Qty. Rcd. Not Invoiced (Base)';
            DecimalPlaces = 0:5;
            Editable = false;
        }
        field(5460;"Qty. Received (Base)";Decimal)
        {
            Caption = 'Qty. Received (Base)';
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
            CalcFormula = Sum("Reservation Entry"."Quantity (Base)" WHERE ("Source Type"=CONST(39),
                                                                           "Source Subtype"=FIELD("Document Type"),
                                                                           "Source ID"=FIELD("Document No."),
                                                                           "Source Ref. No."=FIELD("Line No."),
                                                                           "Reservation Status"=CONST(Reservation)));
            Caption = 'Reserved Qty. (Base)';
            DecimalPlaces = 0:5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5600;"FA Posting Date";Date)
        {
            Caption = 'FA Posting Date';
        }
        field(5601;"FA Posting Type";Option)
        {
            AccessByPermission = TableData "Fixed Asset"=R;
            Caption = 'FA Posting Type';
            OptionCaption = ' ,Acquisition Cost,Maintenance,,Appreciation';
            OptionMembers = " ","Acquisition Cost",Maintenance,,Appreciation;

            trigger OnValidate()
            begin
                if Type = Type::"Fixed Asset" then begin
                  TestField("Job No.",'');
                  if "FA Posting Type" = "FA Posting Type"::" " then
                    "FA Posting Type" := "FA Posting Type"::"Acquisition Cost";
                  GetFAPostingGroup;
                end else begin
                  "Depreciation Book Code" := '';
                  "FA Posting Date" := 0D;
                  "Salvage Value" := 0;
                  "Depr. until FA Posting Date" := false;
                  "Depr. Acquisition Cost" := false;
                  "Maintenance Code" := '';
                  "Insurance No." := '';
                  "Budgeted FA No." := '';
                  "Duplicate in Depreciation Book" := '';
                  "Use Duplication List" := false;
                end;
            end;
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
        field(5603;"Salvage Value";Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Salvage Value';
        }
        field(5605;"Depr. until FA Posting Date";Boolean)
        {
            AccessByPermission = TableData "Fixed Asset"=R;
            Caption = 'Depr. until FA Posting Date';
        }
        field(5606;"Depr. Acquisition Cost";Boolean)
        {
            AccessByPermission = TableData "Fixed Asset"=R;
            Caption = 'Depr. Acquisition Cost';
        }
        field(5609;"Maintenance Code";Code[10])
        {
            Caption = 'Maintenance Code';
            TableRelation = Maintenance;
        }
        field(5610;"Insurance No.";Code[20])
        {
            Caption = 'Insurance No.';
            TableRelation = Insurance;
        }
        field(5611;"Budgeted FA No.";Code[20])
        {
            Caption = 'Budgeted FA No.';
            TableRelation = "Fixed Asset";

            trigger OnValidate()
            var
                FixedAsset: Record "Fixed Asset";
            begin
                if "Budgeted FA No." <> '' then begin
                  FixedAsset.Get("Budgeted FA No.");
                  FixedAsset.TestField("Budgeted Asset",true);
                end;
            end;
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
                  DATABASE::Job,"Job No.",
                  DATABASE::"Work Center","Work Center No.");
            end;
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
                GetPurchHeader;
                "Buy-from Vendor No." := PurchHeader."Buy-from Vendor No.";

                ReturnedCrossRef.Init;
                if "Cross-Reference No." <> '' then begin
                  DistIntegration.ICRLookupPurchaseItem(Rec,ReturnedCrossRef,CurrFieldNo <> 0);
                  Validate("No.",ReturnedCrossRef."Item No.");
                  SetVendorItemNo;
                  if ReturnedCrossRef."Variant Code" <> '' then
                    Validate("Variant Code",ReturnedCrossRef."Variant Code");
                  if ReturnedCrossRef."Unit of Measure" <> '' then
                    Validate("Unit of Measure Code",ReturnedCrossRef."Unit of Measure");
                  UpdateDirectUnitCost(FieldNo("Cross-Reference No."));
                end;

                "Unit of Measure (Cross Ref.)" := ReturnedCrossRef."Unit of Measure";
                "Cross-Reference Type" := ReturnedCrossRef."Cross-Reference Type";
                "Cross-Reference Type No." := ReturnedCrossRef."Cross-Reference Type No.";
                "Cross-Reference No." := ReturnedCrossRef."Cross-Reference No.";

                if (ReturnedCrossRef.Description <> '') or (ReturnedCrossRef."Description 2" <> '') then begin
                  Description := ReturnedCrossRef.Description;
                  "Description 2" := ReturnedCrossRef."Description 2";
                end;

                UpdateICPartner;
            end;
        }
        field(5706;"Unit of Measure (Cross Ref.)";Code[10])
        {
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
        }
        field(5711;"Purchasing Code";Code[10])
        {
            Caption = 'Purchasing Code';
            Editable = false;
            TableRelation = Purchasing;

            trigger OnValidate()
            var
                PurchasingCode: Record Purchasing;
            begin
                if PurchasingCode.Get("Purchasing Code") then begin
                  "Drop Shipment" := PurchasingCode."Drop Shipment";
                  "Special Order" := PurchasingCode."Special Order";
                end else
                  "Drop Shipment" := false;
                Validate("Drop Shipment","Drop Shipment");
            end;
        }
        field(5712;"Product Group Code";Code[10])
        {
            Caption = 'Product Group Code';
            ObsoleteReason = 'Product Groups became first level children of Item Categories.';
            ObsoleteState = Pending;
            TableRelation = "Product Group".Code WHERE ("Item Category Code"=FIELD("Item Category Code"));
            ValidateTableRelation = false;
        }
        field(5713;"Special Order";Boolean)
        {
            Caption = 'Special Order';

            trigger OnValidate()
            begin
                if (xRec."Special Order" <> "Special Order") and (Quantity <> 0) then
                  WhseValidateSourceLine.PurchaseLineVerifyChange(Rec,xRec);
            end;
        }
        field(5714;"Special Order Sales No.";Code[20])
        {
            AccessByPermission = TableData "Drop Shpt. Post. Buffer"=R;
            Caption = 'Special Order Sales No.';
            TableRelation = IF ("Special Order"=CONST(true)) "Sales Header"."No." WHERE ("Document Type"=CONST(Order));

            trigger OnValidate()
            begin
                if (xRec."Special Order Sales No." <> "Special Order Sales No.") and (Quantity <> 0) then
                  WhseValidateSourceLine.PurchaseLineVerifyChange(Rec,xRec);
            end;
        }
        field(5715;"Special Order Sales Line No.";Integer)
        {
            AccessByPermission = TableData "Drop Shpt. Post. Buffer"=R;
            Caption = 'Special Order Sales Line No.';
            TableRelation = IF ("Special Order"=CONST(true)) "Sales Line"."Line No." WHERE ("Document Type"=CONST(Order),
                                                                                            "Document No."=FIELD("Special Order Sales No."));

            trigger OnValidate()
            begin
                if (xRec."Special Order Sales Line No." <> "Special Order Sales Line No.") and (Quantity <> 0) then
                  WhseValidateSourceLine.PurchaseLineVerifyChange(Rec,xRec);
            end;
        }
        field(5750;"Whse. Outstanding Qty. (Base)";Decimal)
        {
            AccessByPermission = TableData Location=R;
            BlankZero = true;
            CalcFormula = Sum("Warehouse Receipt Line"."Qty. Outstanding (Base)" WHERE ("Source Type"=CONST(39),
                                                                                        "Source Subtype"=FIELD("Document Type"),
                                                                                        "Source No."=FIELD("Document No."),
                                                                                        "Source Line No."=FIELD("Line No.")));
            Caption = 'Whse. Outstanding Qty. (Base)';
            DecimalPlaces = 0:5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5752;"Completely Received";Boolean)
        {
            Caption = 'Completely Received';
            Editable = false;
        }
        field(5790;"Requested Receipt Date";Date)
        {
            AccessByPermission = TableData "Order Promising Line"=R;
            Caption = 'Requested Receipt Date';

            trigger OnValidate()
            begin
                TestStatusOpen;
                if (CurrFieldNo <> 0) and
                   ("Promised Receipt Date" <> 0D)
                then
                  Error(
                    Text023,
                    FieldCaption("Requested Receipt Date"),
                    FieldCaption("Promised Receipt Date"));

                if "Requested Receipt Date" <> 0D then
                  Validate("Order Date",
                    CalendarMgmt.CalcDateBOC2(AdjustDateFormula("Lead Time Calculation"),"Requested Receipt Date",
                      CalChange."Source Type"::Vendor,"Buy-from Vendor No.",'',
                      CalChange."Source Type"::Location,"Location Code",'',true))
                else
                  if "Requested Receipt Date" <> xRec."Requested Receipt Date" then
                    GetUpdateBasicDates;
            end;
        }
        field(5791;"Promised Receipt Date";Date)
        {
            AccessByPermission = TableData "Order Promising Line"=R;
            Caption = 'Promised Receipt Date';

            trigger OnValidate()
            begin
                if CurrFieldNo <> 0 then
                  if "Promised Receipt Date" <> 0D then
                    Validate("Planned Receipt Date","Promised Receipt Date")
                  else
                    Validate("Requested Receipt Date")
                else
                  Validate("Planned Receipt Date","Promised Receipt Date");
            end;
        }
        field(5792;"Lead Time Calculation";DateFormula)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header"=R;
            Caption = 'Lead Time Calculation';

            trigger OnValidate()
            begin
                TestStatusOpen;
                LeadTimeMgt.CheckLeadTimeIsNotNegative("Lead Time Calculation");

                if "Requested Receipt Date" <> 0D then
                  Validate("Planned Receipt Date")
                else
                  GetUpdateBasicDates;
            end;
        }
        field(5793;"Inbound Whse. Handling Time";DateFormula)
        {
            AccessByPermission = TableData Location=R;
            Caption = 'Inbound Whse. Handling Time';

            trigger OnValidate()
            begin
                TestStatusOpen;
                if ("Promised Receipt Date" <> 0D) or
                   ("Requested Receipt Date" <> 0D)
                then
                  Validate("Planned Receipt Date")
                else
                  Validate("Expected Receipt Date");
            end;
        }
        field(5794;"Planned Receipt Date";Date)
        {
            AccessByPermission = TableData "Order Promising Line"=R;
            Caption = 'Planned Receipt Date';

            trigger OnValidate()
            begin
                TestStatusOpen;
                if "Promised Receipt Date" <> 0D then begin
                  if "Planned Receipt Date" <> 0D then
                    "Expected Receipt Date" :=
                      CalendarMgmt.CalcDateBOC(InternalLeadTimeDays("Planned Receipt Date"),"Planned Receipt Date",
                        CalChange."Source Type"::Location,"Location Code",'',
                        CalChange."Source Type"::Location,"Location Code",'',false)
                  else
                    "Expected Receipt Date" := "Planned Receipt Date";
                end else
                  if "Planned Receipt Date" <> 0D then begin
                    "Order Date" :=
                      CalendarMgmt.CalcDateBOC2(AdjustDateFormula("Lead Time Calculation"),"Planned Receipt Date",
                        CalChange."Source Type"::Vendor,"Buy-from Vendor No.",'',
                        CalChange."Source Type"::Location,"Location Code",'',true);
                    "Expected Receipt Date" :=
                      CalendarMgmt.CalcDateBOC(InternalLeadTimeDays("Planned Receipt Date"),"Planned Receipt Date",
                        CalChange."Source Type"::Location,"Location Code",'',
                        CalChange."Source Type"::Location,"Location Code",'',false)
                  end else
                    GetUpdateBasicDates;

                if not TrackingBlocked then
                  CheckDateConflict.PurchLineCheck(Rec,CurrFieldNo <> 0);
            end;
        }
        field(5795;"Order Date";Date)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header"=R;
            Caption = 'Order Date';

            trigger OnValidate()
            begin
                TestStatusOpen;
                if (CurrFieldNo <> 0) and
                   ("Document Type" = "Document Type"::Order) and
                   ("Order Date" < WorkDate) and
                   ("Order Date" <> 0D)
                then
                  Message(
                    Text018,
                    FieldCaption("Order Date"),"Order Date",WorkDate);

                if "Order Date" <> 0D then
                  "Planned Receipt Date" :=
                    CalendarMgmt.CalcDateBOC(AdjustDateFormula("Lead Time Calculation"),"Order Date",
                      CalChange."Source Type"::Vendor,"Buy-from Vendor No.",'',
                      CalChange."Source Type"::Location,"Location Code",'',true);

                if "Planned Receipt Date" <> 0D then
                  "Expected Receipt Date" :=
                    CalendarMgmt.CalcDateBOC(InternalLeadTimeDays("Planned Receipt Date"),"Planned Receipt Date",
                      CalChange."Source Type"::Location,"Location Code",'',
                      CalChange."Source Type"::Location,"Location Code",'',false)
                else
                  "Expected Receipt Date" := "Planned Receipt Date";

                if not TrackingBlocked then
                  CheckDateConflict.PurchLineCheck(Rec,CurrFieldNo <> 0);
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
            CalcFormula = Sum("Item Charge Assignment (Purch)"."Qty. to Assign" WHERE ("Document Type"=FIELD("Document Type"),
                                                                                       "Document No."=FIELD("Document No."),
                                                                                       "Document Line No."=FIELD("Line No.")));
            Caption = 'Qty. to Assign';
            DecimalPlaces = 0:5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5802;"Qty. Assigned";Decimal)
        {
            CalcFormula = Sum("Item Charge Assignment (Purch)"."Qty. Assigned" WHERE ("Document Type"=FIELD("Document Type"),
                                                                                      "Document No."=FIELD("Document No."),
                                                                                      "Document Line No."=FIELD("Line No.")));
            Caption = 'Qty. Assigned';
            DecimalPlaces = 0:5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5803;"Return Qty. to Ship";Decimal)
        {
            AccessByPermission = TableData "Return Shipment Header"=R;
            Caption = 'Return Qty. to Ship';
            DecimalPlaces = 0:5;

            trigger OnValidate()
            begin
                if (CurrFieldNo <> 0) and
                   (Type = Type::Item) and
                   ("Return Qty. to Ship" <> 0) and
                   (not "Drop Shipment")
                then
                  CheckWarehouse;

                if "Return Qty. to Ship" = Quantity - "Return Qty. Shipped" then
                  InitQtyToShip
                else begin
                  "Return Qty. to Ship (Base)" := CalcBaseQty("Return Qty. to Ship");
                  InitQtyToInvoice;
                end;
                if ("Return Qty. to Ship" * Quantity < 0) or
                   (Abs("Return Qty. to Ship") > Abs("Outstanding Quantity")) or
                   (Quantity * "Outstanding Quantity" < 0)
                then
                  Error(
                    Text020,
                    "Outstanding Quantity");
                if ("Return Qty. to Ship (Base)" * "Quantity (Base)" < 0) or
                   (Abs("Return Qty. to Ship (Base)") > Abs("Outstanding Qty. (Base)")) or
                   ("Quantity (Base)" * "Outstanding Qty. (Base)" < 0)
                then
                  Error(
                    Text021,
                    "Outstanding Qty. (Base)");

                if (CurrFieldNo <> 0) and (Type = Type::Item) and ("Return Qty. to Ship" > 0) then
                  CheckApplToItemLedgEntry;
            end;
        }
        field(5804;"Return Qty. to Ship (Base)";Decimal)
        {
            Caption = 'Return Qty. to Ship (Base)';
            DecimalPlaces = 0:5;

            trigger OnValidate()
            begin
                TestField("Qty. per Unit of Measure",1);
                Validate("Return Qty. to Ship","Return Qty. to Ship (Base)");
            end;
        }
        field(5805;"Return Qty. Shipped Not Invd.";Decimal)
        {
            Caption = 'Return Qty. Shipped Not Invd.';
            DecimalPlaces = 0:5;
            Editable = false;
        }
        field(5806;"Ret. Qty. Shpd Not Invd.(Base)";Decimal)
        {
            Caption = 'Ret. Qty. Shpd Not Invd.(Base)';
            DecimalPlaces = 0:5;
            Editable = false;
        }
        field(5807;"Return Shpd. Not Invd.";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Return Shpd. Not Invd.';
            Editable = false;

            trigger OnValidate()
            var
                Currency2: Record Currency;
            begin
                GetPurchHeader;
                Currency2.InitRoundingPrecision;
                if PurchHeader."Currency Code" <> '' then
                  "Return Shpd. Not Invd. (LCY)" :=
                    Round(
                      CurrExchRate.ExchangeAmtFCYToLCY(
                        GetDate,"Currency Code",
                        "Return Shpd. Not Invd.",PurchHeader."Currency Factor"),
                      Currency2."Amount Rounding Precision")
                else
                  "Return Shpd. Not Invd. (LCY)" :=
                    Round("Return Shpd. Not Invd.",Currency2."Amount Rounding Precision");
            end;
        }
        field(5808;"Return Shpd. Not Invd. (LCY)";Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Return Shpd. Not Invd. (LCY)';
            Editable = false;
        }
        field(5809;"Return Qty. Shipped";Decimal)
        {
            AccessByPermission = TableData "Return Shipment Header"=R;
            Caption = 'Return Qty. Shipped';
            DecimalPlaces = 0:5;
            Editable = false;
        }
        field(5810;"Return Qty. Shipped (Base)";Decimal)
        {
            Caption = 'Return Qty. Shipped (Base)';
            DecimalPlaces = 0:5;
            Editable = false;
        }
        field(6600;"Return Shipment No.";Code[20])
        {
            Caption = 'Return Shipment No.';
            Editable = false;
        }
        field(6601;"Return Shipment Line No.";Integer)
        {
            Caption = 'Return Shipment Line No.';
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
        field(6609;Subtype;Option)
        {
            Caption = 'Subtype';
            OptionCaption = ' ,Item - Inventory,Item - Service,Comment';
            OptionMembers = " ","Item - Inventory","Item - Service",Comment;
        }
        field(6610;"Copied From Posted Doc.";Boolean)
        {
            Caption = 'Copied From Posted Doc.';
        }
        field(7010;"Attached Doc Count";Integer)
        {
            BlankNumbers = DontBlank;
            CalcFormula = Count("Document Attachment" WHERE ("Table ID"=CONST(39),
                                                             "No."=FIELD("Document No."),
                                                             "Document Type"=FIELD("Document Type"),
                                                             "Line No."=FIELD("Line No.")));
            Caption = 'Attached Doc Count';
            FieldClass = FlowField;
            InitValue = 0;
        }
        field(99000750;"Routing No.";Code[20])
        {
            Caption = 'Routing No.';
            TableRelation = "Routing Header";
        }
        field(99000751;"Operation No.";Code[10])
        {
            Caption = 'Operation No.';
            Editable = false;
            TableRelation = "Prod. Order Routing Line"."Operation No." WHERE (Status=CONST(Released),
                                                                              "Prod. Order No."=FIELD("Prod. Order No."),
                                                                              "Routing No."=FIELD("Routing No."));

            trigger OnValidate()
            var
                ProdOrderRtngLine: Record "Prod. Order Routing Line";
            begin
                if "Operation No." = '' then
                  exit;

                TestField(Type,Type::Item);
                TestField("Prod. Order No.");
                TestField("Routing No.");

                ProdOrderRtngLine.Get(
                  ProdOrderRtngLine.Status::Released,
                  "Prod. Order No.",
                  "Routing Reference No.",
                  "Routing No.",
                  "Operation No.");

                ProdOrderRtngLine.TestField(
                  Type,
                  ProdOrderRtngLine.Type::"Work Center");

                "Expected Receipt Date" := ProdOrderRtngLine."Ending Date";
                Validate("Work Center No.",ProdOrderRtngLine."No.");
                Validate("Direct Unit Cost",ProdOrderRtngLine."Direct Unit Cost");
            end;
        }
        field(99000752;"Work Center No.";Code[20])
        {
            Caption = 'Work Center No.';
            Editable = false;
            TableRelation = "Work Center";

            trigger OnValidate()
            begin
                if Type = Type::"Charge (Item)" then
                  TestField("Work Center No.",'');
                if "Work Center No." = '' then
                  exit;

                WorkCenter.Get("Work Center No.");
                "Gen. Prod. Posting Group" := WorkCenter."Gen. Prod. Posting Group";
                "VAT Prod. Posting Group" := '';
                if GenProdPostingGrp.ValidateVatProdPostingGroup(GenProdPostingGrp,"Gen. Prod. Posting Group") then
                  "VAT Prod. Posting Group" := GenProdPostingGrp."Def. VAT Prod. Posting Group";
                Validate("VAT Prod. Posting Group");

                "Overhead Rate" := WorkCenter."Overhead Rate";
                Validate("Indirect Cost %",WorkCenter."Indirect Cost %");

                CreateDim(
                  DATABASE::"Work Center","Work Center No.",
                  DimMgt.TypeToTableID3(Type),"No.",
                  DATABASE::Job,"Job No.",
                  DATABASE::"Responsibility Center","Responsibility Center");
            end;
        }
        field(99000753;Finished;Boolean)
        {
            Caption = 'Finished';
        }
        field(99000754;"Prod. Order Line No.";Integer)
        {
            Caption = 'Prod. Order Line No.';
            Editable = false;
            TableRelation = "Prod. Order Line"."Line No." WHERE (Status=FILTER(Released..),
                                                                 "Prod. Order No."=FIELD("Prod. Order No."));
        }
        field(99000755;"Overhead Rate";Decimal)
        {
            Caption = 'Overhead Rate';
            DecimalPlaces = 0:5;

            trigger OnValidate()
            begin
                Validate("Indirect Cost %");
            end;
        }
        field(99000756;"MPS Order";Boolean)
        {
            Caption = 'MPS Order';
        }
        field(99000757;"Planning Flexibility";Option)
        {
            Caption = 'Planning Flexibility';
            OptionCaption = 'Unlimited,None';
            OptionMembers = Unlimited,"None";

            trigger OnValidate()
            begin
                if "Planning Flexibility" <> xRec."Planning Flexibility" then
                  ReservePurchLine.UpdatePlanningFlexibility(Rec);
            end;
        }
        field(99000758;"Safety Lead Time";DateFormula)
        {
            Caption = 'Safety Lead Time';

            trigger OnValidate()
            begin
                Validate("Inbound Whse. Handling Time");
            end;
        }
        field(99000759;"Routing Reference No.";Integer)
        {
            Caption = 'Routing Reference No.';
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
        key(Key3;"Document Type",Type,"No.","Variant Code","Drop Shipment","Location Code","Expected Receipt Date")
        {
            SumIndexFields = "Outstanding Qty. (Base)";
        }
        key(Key4;"Document Type","Pay-to Vendor No.","Currency Code")
        {
            MaintainSIFTIndex = false;
            SumIndexFields = "Outstanding Amount","Amt. Rcd. Not Invoiced","Outstanding Amount (LCY)","Amt. Rcd. Not Invoiced (LCY)";
        }
        key(Key5;"Document Type",Type,"No.","Variant Code","Drop Shipment","Shortcut Dimension 1 Code","Shortcut Dimension 2 Code","Location Code","Expected Receipt Date")
        {
            Enabled = false;
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Outstanding Qty. (Base)";
        }
        key(Key6;"Document Type","Pay-to Vendor No.","Shortcut Dimension 1 Code","Shortcut Dimension 2 Code","Currency Code")
        {
            Enabled = false;
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Outstanding Amount","Amt. Rcd. Not Invoiced","Outstanding Amount (LCY)","Amt. Rcd. Not Invoiced (LCY)";
        }
        key(Key7;"Document Type","Blanket Order No.","Blanket Order Line No.")
        {
        }
        key(Key8;"Document Type",Type,"Prod. Order No.","Prod. Order Line No.","Routing No.","Operation No.")
        {
        }
        key(Key9;"Document Type","Document No.","Location Code")
        {
            MaintainSQLIndex = false;
            SumIndexFields = Amount,"Amount Including VAT";
        }
        key(Key10;"Document Type","Receipt No.","Receipt Line No.")
        {
        }
        key(Key11;Type,"No.","Variant Code","Drop Shipment","Location Code","Document Type","Expected Receipt Date")
        {
            MaintainSQLIndex = false;
        }
        key(Key12;"Document Type","Buy-from Vendor No.")
        {
        }
        key(Key13;"Document Type","Job No.","Job Task No.")
        {
            SumIndexFields = "Outstanding Amt. Ex. VAT (LCY)","A. Rcd. Not Inv. Ex. VAT (LCY)";
        }
        key(Key14;"Document Type","Document No.",Type,"No.")
        {
            Enabled = false;
        }
        key(Key15;"Document Type",Type,"No.")
        {
            Enabled = false;
            SumIndexFields = "Outstanding Qty. (Base)";
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        PurchCommentLine: Record "Purch. Comment Line";
        SalesOrderLine: Record "Sales Line";
    begin
        TestStatusOpen;
        if not StatusCheckSuspended and (PurchHeader.Status = PurchHeader.Status::Released) and
           (Type in [Type::"G/L Account",Type::"Charge (Item)"])
        then
          Validate(Quantity,0);

        if (Quantity <> 0) and ItemExists("No.") then begin
          ReservePurchLine.DeleteLine(Rec);
          if "Receipt No." = '' then
            TestField("Qty. Rcd. Not Invoiced",0);
          if "Return Shipment No." = '' then
            TestField("Return Qty. Shipped Not Invd.",0);

          CalcFields("Reserved Qty. (Base)");
          TestField("Reserved Qty. (Base)",0);
          WhseValidateSourceLine.PurchaseLineDelete(Rec);
        end;

        if ("Document Type" = "Document Type"::Order) and (Quantity <> "Quantity Invoiced") then
          TestField("Prepmt. Amt. Inv.","Prepmt Amt Deducted");

        if "Sales Order Line No." <> 0 then begin
          LockTable;
          SalesOrderLine.LockTable;
          SalesOrderLine.Get(SalesOrderLine."Document Type"::Order,"Sales Order No.","Sales Order Line No.");
          SalesOrderLine."Purchase Order No." := '';
          SalesOrderLine."Purch. Order Line No." := 0;
          SalesOrderLine.Modify;
        end;

        if ("Special Order Sales Line No." <> 0) and ("Quantity Invoiced" = 0) then begin
          LockTable;
          SalesOrderLine.LockTable;
          if SalesOrderLine.Get(
               SalesOrderLine."Document Type"::Order,"Special Order Sales No.","Special Order Sales Line No.")
          then begin
            SalesOrderLine."Special Order Purchase No." := '';
            SalesOrderLine."Special Order Purch. Line No." := 0;
            SalesOrderLine.Modify;
          end;
        end;

        CatalogItemMgt.DelNonStockPurch(Rec);

        if "Document Type" = "Document Type"::"Blanket Order" then begin
          PurchLine2.Reset;
          PurchLine2.SetCurrentKey("Document Type","Blanket Order No.","Blanket Order Line No.");
          PurchLine2.SetRange("Blanket Order No.","Document No.");
          PurchLine2.SetRange("Blanket Order Line No.","Line No.");
          if PurchLine2.FindFirst then
            PurchLine2.TestField("Blanket Order Line No.",0);
        end;

        if Type = Type::Item then
          DeleteItemChargeAssgnt("Document Type","Document No.","Line No.");

        if Type = Type::"Charge (Item)" then
          DeleteChargeChargeAssgnt("Document Type","Document No.","Line No.");

        if "Line No." <> 0 then begin
          PurchLine2.Reset;
          PurchLine2.SetRange("Document Type","Document Type");
          PurchLine2.SetRange("Document No.","Document No.");
          PurchLine2.SetRange("Attached to Line No.","Line No.");
          PurchLine2.SetFilter("Line No.",'<>%1',"Line No.");
          PurchLine2.DeleteAll(true);
        end;

        PurchCommentLine.SetRange("Document Type","Document Type");
        PurchCommentLine.SetRange("No.","Document No.");
        PurchCommentLine.SetRange("Document Line No.","Line No.");
        if not PurchCommentLine.IsEmpty then
          PurchCommentLine.DeleteAll;

        if ("Line No." <> 0) and ("Attached to Line No." = 0) then begin
          PurchLine2.Copy(Rec);
          PurchLine2.SetRange("Document No.",PurchLine2."Document No.");
          PurchLine2.SetRange("Document Type",PurchLine2."Document Type");
          if PurchLine2.Find('<>') then begin
            PurchLine2.Validate("Recalculate Invoice Disc.",true);
            PurchLine2.Modify;
          end;
        end;

        if "Deferral Code" <> '' then
          DeferralUtilities.DeferralCodeOnDelete(
            DeferralUtilities.GetPurchDeferralDocType,'','',
            "Document Type","Document No.","Line No.");
    end;

    trigger OnInsert()
    begin
        TestStatusOpen;
        if Quantity <> 0 then begin
          OnBeforeVerifyReservedQty(Rec,xRec,0);
          ReservePurchLine.VerifyQuantity(Rec,xRec);
        end;
        LockTable;
        PurchHeader."No." := '';
        if ("Deferral Code" <> '') and (GetDeferralAmount <> 0) then
          UpdateDeferralAmounts;
    end;

    trigger OnModify()
    begin
        if ("Document Type" = "Document Type"::"Blanket Order") and
           ((Type <> xRec.Type) or ("No." <> xRec."No."))
        then begin
          PurchLine2.Reset;
          PurchLine2.SetCurrentKey("Document Type","Blanket Order No.","Blanket Order Line No.");
          PurchLine2.SetRange("Blanket Order No.","Document No.");
          PurchLine2.SetRange("Blanket Order Line No.","Line No.");
          if PurchLine2.FindSet then
            repeat
              PurchLine2.TestField(Type,Type);
              PurchLine2.TestField("No.","No.");
            until PurchLine2.Next = 0;
        end;

        if ((Quantity <> 0) or (xRec.Quantity <> 0)) and ItemExists(xRec."No.") then
          ReservePurchLine.VerifyChange(Rec,xRec);
    end;

    trigger OnRename()
    begin
        Error(Text000,TableCaption);
    end;

    var
        Text000: Label 'You cannot rename a %1.';
        Text001: Label 'You cannot change %1 because the order line is associated with sales order %2.';
        Text002: Label 'Prices including VAT cannot be calculated when %1 is %2.';
        Text003: Label 'You cannot purchase resources.';
        Text004: Label 'must not be less than %1';
        Text006: Label 'You cannot invoice more than %1 units.';
        Text007: Label 'You cannot invoice more than %1 base units.';
        Text008: Label 'You cannot receive more than %1 units.';
        Text009: Label 'You cannot receive more than %1 base units.';
        Text010: Label 'You cannot change %1 when %2 is %3.';
        Text011: Label ' must be 0 when %1 is %2';
        Text012: Label 'must not be specified when %1 = %2';
        Text016: Label '%1 is required for %2 = %3.';
        Text017: Label '\The entered information may be disregarded by warehouse operations.';
        Text018: Label '%1 %2 is earlier than the work date %3.';
        Text020: Label 'You cannot return more than %1 units.';
        Text021: Label 'You cannot return more than %1 base units.';
        Text022: Label 'You cannot change %1, if item charge is already posted.';
        Text023: Label 'You cannot change the %1 when the %2 has been filled in.';
        Text029: Label 'must be positive.';
        Text030: Label 'must be negative.';
        Text031: Label 'You cannot define item tracking on this line because it is linked to production order %1.';
        Text032: Label '%1 must not be greater than the sum of %2 and %3.';
        Text033: Label 'Warehouse ';
        Text034: Label 'Inventory ';
        Text035: Label '%1 units for %2 %3 have already been returned or transferred. Therefore, only %4 units can be returned.';
        Text037: Label 'cannot be %1.';
        Text038: Label 'cannot be less than %1.';
        Text039: Label 'cannot be more than %1.';
        Text040: Label 'You must use form %1 to enter %2, if item tracking is used.';
        ItemChargeAssignmentErr: Label 'You can only assign Item Charges for Line Types of Charge (Item).';
        Text99000000: Label 'You cannot change %1 when the purchase order is associated to a production order.';
        PurchHeader: Record "Purchase Header";
        PurchLine2: Record "Purchase Line";
        GLAcc: Record "G/L Account";
        Item: Record Item;
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        VATPostingSetup: Record "VAT Posting Setup";
        GenBusPostingGrp: Record "Gen. Business Posting Group";
        GenProdPostingGrp: Record "Gen. Product Posting Group";
        UnitOfMeasure: Record "Unit of Measure";
        ItemCharge: Record "Item Charge";
        SKU: Record "Stockkeeping Unit";
        WorkCenter: Record "Work Center";
        InvtSetup: Record "Inventory Setup";
        Location: Record Location;
        GLSetup: Record "General Ledger Setup";
        CalChange: Record "Customized Calendar Change";
        TempJobJnlLine: Record "Job Journal Line" temporary;
        PurchSetup: Record "Purchases & Payables Setup";
        SalesTaxCalculate: Codeunit "Sales Tax Calculate";
        ReservEngineMgt: Codeunit "Reservation Engine Mgt.";
        ReservePurchLine: Codeunit "Purch. Line-Reserve";
        UOMMgt: Codeunit "Unit of Measure Management";
        AddOnIntegrMgt: Codeunit AddOnIntegrManagement;
        DimMgt: Codeunit DimensionManagement;
        DistIntegration: Codeunit "Dist. Integration";
        CatalogItemMgt: Codeunit "Catalog Item Management";
        WhseValidateSourceLine: Codeunit "Whse. Validate Source Line";
        LeadTimeMgt: Codeunit "Lead-Time Management";
        PurchPriceCalcMgt: Codeunit "Purch. Price Calc. Mgt.";
        CalendarMgmt: Codeunit "Calendar Management";
        CheckDateConflict: Codeunit "Reservation-Check Date Confl.";
        DeferralUtilities: Codeunit "Deferral Utilities";
        PostingSetupMgt: Codeunit PostingSetupManagement;
        TrackingBlocked: Boolean;
        StatusCheckSuspended: Boolean;
        GLSetupRead: Boolean;
        UnitCostCurrency: Decimal;
        UpdateFromVAT: Boolean;
        Text042: Label 'You cannot return more than the %1 units that you have received for %2 %3.';
        Text043: Label 'must be positive when %1 is not 0.';
        Text044: Label 'You cannot change %1 because this purchase order is associated with %2 %3.';
        Text046: Label '%3 will not update %1 when changing %2 because a prepayment invoice has been posted. Do you want to continue?', Comment='%1 - product name';
        Text047: Label '%1 can only be set when %2 is set.';
        Text048: Label '%1 cannot be changed when %2 is set.';
        PrePaymentLineAmountEntered: Boolean;
        Text049: Label 'You have changed one or more dimensions on the %1, which is already shipped. When you post the line with the changed dimension to General Ledger, amounts on the Inventory Interim account will be out of balance when reported per dimension.\\Do you want to keep the changed dimension?';
        Text050: Label 'Cancelled.';
        Text051: Label 'must have the same sign as the receipt';
        Text052: Label 'The quantity that you are trying to invoice is greater than the quantity in receipt %1.';
        Text053: Label 'must have the same sign as the return shipment';
        Text054: Label 'The quantity that you are trying to invoice is greater than the quantity in return shipment %1.';
        AnotherItemWithSameDescrQst: Label 'Item No. %1 also has the description "%2".\Do you want to change the current item no. to %1?', Comment='%1=Item no., %2=item description';
        AnotherChargeItemWithSameDescQst: Label 'Item charge No. %1 also has the description "%2".\Do you want to change the current item charge no. to %1?', Comment='%1=Item charge no., %2=item charge description';
        PurchSetupRead: Boolean;
        CannotFindDescErr: Label 'Cannot find %1 with Description %2.\\Make sure to use the correct type.', Comment='%1 = Type caption %2 = Description';
        CommentLbl: Label 'Comment';
        LineDiscountPctErr: Label 'The value in the Line Discount % field must be between 0 and 100.';
        PurchasingBlockedErr: Label 'You cannot purchase this item because the Purchasing Blocked check box is selected on the item card.';
        CannotChangePrepaidServiceChargeErr: Label 'You cannot change the line because it will affect service charges that are already invoiced as part of a prepayment.';

    [Scope('Personalization')]
    procedure InitOutstanding()
    begin
        if "Document Type" in ["Document Type"::"Return Order","Document Type"::"Credit Memo"] then begin
          "Outstanding Quantity" := Quantity - "Return Qty. Shipped";
          "Outstanding Qty. (Base)" := "Quantity (Base)" - "Return Qty. Shipped (Base)";
          "Return Qty. Shipped Not Invd." := "Return Qty. Shipped" - "Quantity Invoiced";
          "Ret. Qty. Shpd Not Invd.(Base)" := "Return Qty. Shipped (Base)" - "Qty. Invoiced (Base)";
        end else begin
          "Outstanding Quantity" := Quantity - "Quantity Received";
          "Outstanding Qty. (Base)" := "Quantity (Base)" - "Qty. Received (Base)";
          "Qty. Rcd. Not Invoiced" := "Quantity Received" - "Quantity Invoiced";
          "Qty. Rcd. Not Invoiced (Base)" := "Qty. Received (Base)" - "Qty. Invoiced (Base)";
        end;
        "Completely Received" := (Quantity <> 0) and ("Outstanding Quantity" = 0);
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
          "Outstanding Amt. Ex. VAT (LCY)" := 0;
          "Amt. Rcd. Not Invoiced" := 0;
          "Amt. Rcd. Not Invoiced (LCY)" := 0;
          "Return Shpd. Not Invd." := 0;
          "Return Shpd. Not Invd. (LCY)" := 0;
        end else begin
          GetPurchHeader;
          AmountInclVAT := "Amount Including VAT";
          Validate(
            "Outstanding Amount",
            Round(
              AmountInclVAT * "Outstanding Quantity" / Quantity,
              Currency."Amount Rounding Precision"));
          if "Document Type" in ["Document Type"::"Return Order","Document Type"::"Credit Memo"] then
            Validate(
              "Return Shpd. Not Invd.",
              Round(
                AmountInclVAT * "Return Qty. Shipped Not Invd." / Quantity,
                Currency."Amount Rounding Precision"))
          else
            Validate(
              "Amt. Rcd. Not Invoiced",
              Round(
                AmountInclVAT * "Qty. Rcd. Not Invoiced" / Quantity,
                Currency."Amount Rounding Precision"));
        end;

        OnAfterInitOutstandingAmount(Rec,xRec,PurchHeader,Currency);
    end;

    [Scope('Personalization')]
    procedure InitQtyToReceive()
    begin
        GetPurchSetup;
        if (PurchSetup."Default Qty. to Receive" = PurchSetup."Default Qty. to Receive"::Remainder) or
           ("Document Type" = "Document Type"::Invoice)
        then begin
          "Qty. to Receive" := "Outstanding Quantity";
          "Qty. to Receive (Base)" := "Outstanding Qty. (Base)";
        end else
          if "Qty. to Receive" <> 0 then
            "Qty. to Receive (Base)" := CalcBaseQty("Qty. to Receive");

        OnAfterInitQtyToReceive(Rec,CurrFieldNo);

        InitQtyToInvoice;
    end;

    [Scope('Personalization')]
    procedure InitQtyToShip()
    begin
        GetPurchSetup;
        if (PurchSetup."Default Qty. to Receive" = PurchSetup."Default Qty. to Receive"::Remainder) or
           ("Document Type" = "Document Type"::"Credit Memo")
        then begin
          "Return Qty. to Ship" := "Outstanding Quantity";
          "Return Qty. to Ship (Base)" := "Outstanding Qty. (Base)";
        end else
          if "Return Qty. to Ship" <> 0 then
            "Return Qty. to Ship (Base)" := CalcBaseQty("Return Qty. to Ship");

        OnAfterInitQtyToShip(Rec,CurrFieldNo);

        InitQtyToInvoice;
    end;

    [Scope('Personalization')]
    procedure InitQtyToInvoice()
    begin
        "Qty. to Invoice" := MaxQtyToInvoice;
        "Qty. to Invoice (Base)" := MaxQtyToInvoiceBase;
        "VAT Difference" := 0;
        CalcInvDiscToInvoice;
        if PurchHeader."Document Type" <> PurchHeader."Document Type"::Invoice then
          CalcPrepaymentToDeduct;

        OnAfterInitQtyToInvoice(Rec,CurrFieldNo);
    end;

    local procedure InitItemAppl()
    begin
        "Appl.-to Item Entry" := 0;
    end;

    local procedure InitHeaderDefaults(PurchHeader: Record "Purchase Header")
    begin
        PurchHeader.TestField("Buy-from Vendor No.");

        "Buy-from Vendor No." := PurchHeader."Buy-from Vendor No.";
        "Currency Code" := PurchHeader."Currency Code";
        "Expected Receipt Date" := PurchHeader."Expected Receipt Date";
        "Shortcut Dimension 1 Code" := PurchHeader."Shortcut Dimension 1 Code";
        "Shortcut Dimension 2 Code" := PurchHeader."Shortcut Dimension 2 Code";
        if not IsNonInventoriableItem then
          "Location Code" := PurchHeader."Location Code";
        "Transaction Type" := PurchHeader."Transaction Type";
        "Transport Method" := PurchHeader."Transport Method";
        "Pay-to Vendor No." := PurchHeader."Pay-to Vendor No.";
        "Gen. Bus. Posting Group" := PurchHeader."Gen. Bus. Posting Group";
        "VAT Bus. Posting Group" := PurchHeader."VAT Bus. Posting Group";
        "Entry Point" := PurchHeader."Entry Point";
        Area := PurchHeader.Area;
        "Transaction Specification" := PurchHeader."Transaction Specification";
        "Tax Area Code" := PurchHeader."Tax Area Code";
        "Tax Liable" := PurchHeader."Tax Liable";
        if not "System-Created Entry" and ("Document Type" = "Document Type"::Order) and HasTypeToFillMandatoryFields or
           IsServiceCharge
        then
          "Prepayment %" := PurchHeader."Prepayment %";
        "Prepayment Tax Area Code" := PurchHeader."Tax Area Code";
        "Prepayment Tax Liable" := PurchHeader."Tax Liable";
        "Responsibility Center" := PurchHeader."Responsibility Center";
        "Requested Receipt Date" := PurchHeader."Requested Receipt Date";
        "Promised Receipt Date" := PurchHeader."Promised Receipt Date";
        "Inbound Whse. Handling Time" := PurchHeader."Inbound Whse. Handling Time";
        "Order Date" := PurchHeader."Order Date";

        OnAfterInitHeaderDefaults(Rec,PurchHeader);
    end;

    [Scope('Personalization')]
    procedure MaxQtyToInvoice(): Decimal
    begin
        if "Prepayment Line" then
          exit(1);
        if "Document Type" in ["Document Type"::"Return Order","Document Type"::"Credit Memo"] then
          exit("Return Qty. Shipped" + "Return Qty. to Ship" - "Quantity Invoiced");

        exit("Quantity Received" + "Qty. to Receive" - "Quantity Invoiced");
    end;

    [Scope('Personalization')]
    procedure MaxQtyToInvoiceBase(): Decimal
    begin
        if "Document Type" in ["Document Type"::"Return Order","Document Type"::"Credit Memo"] then
          exit("Return Qty. Shipped (Base)" + "Return Qty. to Ship (Base)" - "Qty. Invoiced (Base)");

        exit("Qty. Received (Base)" + "Qty. to Receive (Base)" - "Qty. Invoiced (Base)");
    end;

    [Scope('Personalization')]
    procedure CalcInvDiscToInvoice()
    var
        OldInvDiscAmtToInv: Decimal;
    begin
        GetPurchHeader;
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

    local procedure CalcBaseQty(Qty: Decimal): Decimal
    begin
        if "Prod. Order No." = '' then
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
        GetGLSetup;
        Item.TestField(Blocked,false);
        Item.TestField("Gen. Prod. Posting Group");
        if Item."Purchasing Blocked" then
          Error(PurchasingBlockedErr);
        if Item.Type = Item.Type::Inventory then begin
          Item.TestField("Inventory Posting Group");
          "Posting Group" := Item."Inventory Posting Group";
        end;
        Description := Item.Description;
        "Description 2" := Item."Description 2";
        "Unit Price (LCY)" := Item."Unit Price";
        "Units per Parcel" := Item."Units per Parcel";
        "Indirect Cost %" := Item."Indirect Cost %";
        "Overhead Rate" := Item."Overhead Rate";
        "Allow Invoice Disc." := Item."Allow Invoice Disc.";
        "Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
        "VAT Prod. Posting Group" := Item."VAT Prod. Posting Group";
        "Tax Group Code" := Item."Tax Group Code";
        Nonstock := Item."Created From Nonstock Item";
        "Item Category Code" := Item."Item Category Code";
        "Allow Item Charge Assignment" := true;
        PrepaymentMgt.SetPurchPrepaymentPct(Rec,PurchHeader."Posting Date");
        if Item.Type = Item.Type::Inventory then
          PostingSetupMgt.CheckInvtPostingSetupInventoryAccount("Location Code","Posting Group");

        if Item."Price Includes VAT" then begin
          if not VATPostingSetup.Get(Item."VAT Bus. Posting Gr. (Price)",Item."VAT Prod. Posting Group") then
            VATPostingSetup.Init;
          case VATPostingSetup."VAT Calculation Type" of
            VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT":
              VATPostingSetup."VAT %" := 0;
            VATPostingSetup."VAT Calculation Type"::"Sales Tax":
              Error(
                Text002,
                VATPostingSetup.FieldCaption("VAT Calculation Type"),
                VATPostingSetup."VAT Calculation Type");
          end;
          "Unit Price (LCY)" :=
            Round("Unit Price (LCY)" / (1 + VATPostingSetup."VAT %" / 100),
              GLSetup."Unit-Amount Rounding Precision");
        end;

        if PurchHeader."Language Code" <> '' then
          GetItemTranslation;

        "Unit of Measure Code" := Item."Purch. Unit of Measure";
        InitDeferralCode;
        OnAfterAssignItemValues(Rec,Item);
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
        "Indirect Cost %" := 0;
        "Overhead Rate" := 0;
        OnAfterAssignItemChargeValues(Rec,ItemCharge);
    end;

    local procedure SelectItemEntry()
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        TestField("Prod. Order No.",'');
        ItemLedgEntry.SetCurrentKey("Item No.",Open);
        ItemLedgEntry.SetRange("Item No.","No.");
        ItemLedgEntry.SetRange(Open,true);
        ItemLedgEntry.SetRange(Positive,true);
        if "Location Code" <> '' then
          ItemLedgEntry.SetRange("Location Code","Location Code");
        ItemLedgEntry.SetRange("Variant Code","Variant Code");

        if PAGE.RunModal(PAGE::"Item Ledger Entries",ItemLedgEntry) = ACTION::LookupOK then
          Validate("Appl.-to Item Entry",ItemLedgEntry."Entry No.");
    end;

    [Scope('Personalization')]
    procedure SetPurchHeader(NewPurchHeader: Record "Purchase Header")
    begin
        PurchHeader := NewPurchHeader;

        if PurchHeader."Currency Code" = '' then
          Currency.InitRoundingPrecision
        else begin
          PurchHeader.TestField("Currency Factor");
          Currency.Get(PurchHeader."Currency Code");
          Currency.TestField("Amount Rounding Precision");
        end;
    end;

    local procedure GetPurchHeader()
    begin
        TestField("Document No.");
        if ("Document Type" <> PurchHeader."Document Type") or ("Document No." <> PurchHeader."No.") then begin
          PurchHeader.Get("Document Type","Document No.");
          if PurchHeader."Currency Code" = '' then
            Currency.InitRoundingPrecision
          else begin
            PurchHeader.TestField("Currency Factor");
            Currency.Get(PurchHeader."Currency Code");
            Currency.TestField("Amount Rounding Precision");
          end;
        end;
    end;

    local procedure GetItem()
    begin
        TestField("No.");
        if Item."No." <> "No." then
          Item.Get("No.");
    end;

    local procedure UpdateDirectUnitCost(CalledByFieldNo: Integer)
    var
        Handled: Boolean;
    begin
        OnBeforeUpdateDirectUnitCost(Rec,xRec,CalledByFieldNo,CurrFieldNo,Handled);
        if Handled then
          exit;

        if (CurrFieldNo <> 0) and ("Prod. Order No." <> '') then
          UpdateAmounts;

        if ((CalledByFieldNo <> CurrFieldNo) and (CurrFieldNo <> 0)) or
           ("Prod. Order No." <> '')
        then
          exit;

        if Type = Type::Item then begin
          GetPurchHeader;
          PurchPriceCalcMgt.FindPurchLinePrice(PurchHeader,Rec,CalledByFieldNo);
          if not ("Copied From Posted Doc." and IsCreditDocType) then
            PurchPriceCalcMgt.FindPurchLineLineDisc(PurchHeader,Rec);
          Validate("Direct Unit Cost");

          if CalledByFieldNo in [FieldNo("No."),FieldNo("Variant Code"),FieldNo("Location Code")] then
            UpdateItemReference;
        end;

        OnAfterUpdateDirectUnitCost(Rec,xRec,CalledByFieldNo,CurrFieldNo);
    end;

    procedure UpdateUnitCost()
    var
        DiscountAmountPerQty: Decimal;
    begin
        GetPurchHeader;
        GetGLSetup;
        if Quantity = 0 then
          DiscountAmountPerQty := 0
        else
          DiscountAmountPerQty :=
            Round(("Line Discount Amount" + "Inv. Discount Amount") / Quantity,
              GLSetup."Unit-Amount Rounding Precision");

        if "VAT Calculation Type" = "VAT Calculation Type"::"Full VAT" then
          "Unit Cost" := 0
        else
          if PurchHeader."Prices Including VAT" then
            "Unit Cost" :=
              ("Direct Unit Cost" - DiscountAmountPerQty) * (1 + "Indirect Cost %" / 100) / (1 + "VAT %" / 100) +
              GetOverheadRateFCY - "VAT Difference"
          else
            "Unit Cost" :=
              ("Direct Unit Cost" - DiscountAmountPerQty) * (1 + "Indirect Cost %" / 100) +
              GetOverheadRateFCY;

        if PurchHeader."Currency Code" <> '' then begin
          PurchHeader.TestField("Currency Factor");
          "Unit Cost (LCY)" :=
            CurrExchRate.ExchangeAmtFCYToLCY(
              GetDate,"Currency Code",
              "Unit Cost",PurchHeader."Currency Factor");
        end else
          "Unit Cost (LCY)" := "Unit Cost";

        if (Type = Type::Item) and ("Prod. Order No." = '') then begin
          GetItem;
          if Item."Costing Method" = Item."Costing Method"::Standard then begin
            if GetSKU then
              "Unit Cost (LCY)" := SKU."Unit Cost" * "Qty. per Unit of Measure"
            else
              "Unit Cost (LCY)" := Item."Unit Cost" * "Qty. per Unit of Measure";
          end;
        end;

        "Unit Cost (LCY)" := Round("Unit Cost (LCY)",GLSetup."Unit-Amount Rounding Precision");
        if PurchHeader."Currency Code" <> '' then
          Currency.TestField("Unit-Amount Rounding Precision");
        "Unit Cost" := Round("Unit Cost",Currency."Unit-Amount Rounding Precision");

        OnAfterUpdateUnitCost(Rec,xRec,PurchHeader,Item,SKU,Currency,GLSetup);

        UpdateSalesCost;

        if JobTaskIsSet and not UpdateFromVAT and not "Prepayment Line" then begin
          CreateTempJobJnlLine(false);
          TempJobJnlLine.Validate("Unit Cost (LCY)","Unit Cost (LCY)");
          UpdateJobPrices;
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
        GetPurchHeader;

        VATBaseAmount := "VAT Base Amount";
        "Recalculate Invoice Disc." := true;

        if "Line Amount" <> xRec."Line Amount" then begin
          "VAT Difference" := 0;
          LineAmountChanged := true;
        end;
        if "Line Amount" <> Round(Quantity * "Direct Unit Cost",Currency."Amount Rounding Precision") - "Line Discount Amount" then begin
          "Line Amount" :=
            Round(Quantity * "Direct Unit Cost",Currency."Amount Rounding Precision") - "Line Discount Amount";
          "VAT Difference" := 0;
          LineAmountChanged := true;
        end;

        if not "Prepayment Line" then begin
          if "Prepayment %" <> 0 then begin
            if Quantity < 0 then
              FieldError(Quantity,StrSubstNo(Text043,FieldCaption("Prepayment %")));
            if "Direct Unit Cost" < 0 then
              FieldError("Direct Unit Cost",StrSubstNo(Text043,FieldCaption("Prepayment %")));
          end;
          if PurchHeader."Document Type" <> PurchHeader."Document Type"::Invoice then begin
            "Prepayment VAT Difference" := 0;
            if not PrePaymentLineAmountEntered then
              "Prepmt. Line Amount" := Round("Line Amount" * "Prepayment %" / 100,Currency."Amount Rounding Precision");
            if "Prepmt. Line Amount" < "Prepmt. Amt. Inv." then begin
              if IsServiceCharge then
                Error(CannotChangePrepaidServiceChargeErr);
              FieldError("Prepmt. Line Amount",StrSubstNo(Text037,"Prepmt. Amt. Inv."));
            end;
            PrePaymentLineAmountEntered := false;
            if "Prepmt. Line Amount" <> 0 then begin
              RemLineAmountToInvoice :=
                Round("Line Amount" * (Quantity - "Quantity Invoiced") / Quantity,Currency."Amount Rounding Precision");
              if RemLineAmountToInvoice < ("Prepmt. Line Amount" - "Prepmt Amt Deducted") then
                FieldError("Prepmt. Line Amount",StrSubstNo(Text039,RemLineAmountToInvoice + "Prepmt Amt Deducted"));
            end;
          end else
            if (CurrFieldNo <> 0) and ("Line Amount" <> xRec."Line Amount") and
               ("Prepmt. Amt. Inv." <> 0) and ("Prepayment %" = 100)
            then begin
              if "Line Amount" < xRec."Line Amount" then
                FieldError("Line Amount",StrSubstNo(Text038,xRec."Line Amount"));
              FieldError("Line Amount",StrSubstNo(Text039,xRec."Line Amount"));
            end;
        end;

        OnAfterUpdateAmounts(Rec,xRec,CurrFieldNo);

        UpdateVATAmounts;
        if VATBaseAmount <> "VAT Base Amount" then
          LineAmountChanged := true;

        if LineAmountChanged then begin
          UpdateDeferralAmounts;
          LineAmountChanged := false;
        end;

        InitOutstandingAmount;

        if Type = Type::"Charge (Item)" then
          UpdateItemChargeAssgnt;

        CalcPrepaymentToDeduct;

        OnAfterUpdateAmountsDone(Rec,xRec,CurrFieldNo);
    end;

    local procedure UpdateVATAmounts()
    var
        PurchLine2: Record "Purchase Line";
        TotalLineAmount: Decimal;
        TotalInvDiscAmount: Decimal;
        TotalAmount: Decimal;
        TotalAmountInclVAT: Decimal;
        TotalQuantityBase: Decimal;
    begin
        GetPurchHeader;
        PurchLine2.SetRange("Document Type","Document Type");
        PurchLine2.SetRange("Document No.","Document No.");
        PurchLine2.SetFilter("Line No.",'<>%1',"Line No.");
        if "Line Amount" = 0 then
          if xRec."Line Amount" >= 0 then
            PurchLine2.SetFilter(Amount,'>%1',0)
          else
            PurchLine2.SetFilter(Amount,'<%1',0)
        else
          if "Line Amount" > 0 then
            PurchLine2.SetFilter(Amount,'>%1',0)
          else
            PurchLine2.SetFilter(Amount,'<%1',0);
        PurchLine2.SetRange("VAT Identifier","VAT Identifier");
        PurchLine2.SetRange("Tax Group Code","Tax Group Code");

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
            if not PurchLine2.IsEmpty then begin
              PurchLine2.CalcSums("Line Amount","Inv. Discount Amount",Amount,"Amount Including VAT","Quantity (Base)");
              TotalLineAmount := PurchLine2."Line Amount";
              TotalInvDiscAmount := PurchLine2."Inv. Discount Amount";
              TotalAmount := PurchLine2.Amount;
              TotalAmountInclVAT := PurchLine2."Amount Including VAT";
              TotalQuantityBase := PurchLine2."Quantity (Base)";
              OnAfterUpdateTotalAmounts(Rec,PurchLine2,TotalAmount,TotalAmountInclVAT,TotalLineAmount,TotalInvDiscAmount);
            end;

          if PurchHeader."Prices Including VAT" then
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
                      Amount * (1 - PurchHeader."VAT Base Discount %" / 100),
                      Currency."Amount Rounding Precision");
                  "Amount Including VAT" :=
                    TotalLineAmount + "Line Amount" -
                    Round(
                      (TotalAmount + Amount) * (PurchHeader."VAT Base Discount %" / 100) * "VAT %" / 100,
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
                  PurchHeader.TestField("VAT Base Discount %",0);
                  "Amount Including VAT" :=
                    Round(CalcLineAmount,Currency."Amount Rounding Precision");
                  if "Use Tax" then
                    Amount := "Amount Including VAT"
                  else
                    Amount :=
                      Round(
                        SalesTaxCalculate.ReverseCalculateTax(
                          "Tax Area Code","Tax Group Code","Tax Liable",PurchHeader."Posting Date",
                          TotalAmountInclVAT + "Amount Including VAT",TotalQuantityBase + "Quantity (Base)",
                          PurchHeader."Currency Factor"),
                        Currency."Amount Rounding Precision") -
                      TotalAmount;
                  "VAT Base Amount" := Amount;
                  if "VAT Base Amount" <> 0 then
                    "VAT %" :=
                      Round(100 * ("Amount Including VAT" - "VAT Base Amount") / "VAT Base Amount",0.00001)
                  else
                    "VAT %" := 0;
                end;
            end
          else
            case "VAT Calculation Type" of
              "VAT Calculation Type"::"Normal VAT",
              "VAT Calculation Type"::"Reverse Charge VAT":
                begin
                  Amount := Round(CalcLineAmount,Currency."Amount Rounding Precision");
                  "VAT Base Amount" :=
                    Round(Amount * (1 - PurchHeader."VAT Base Discount %" / 100),Currency."Amount Rounding Precision");
                  "Amount Including VAT" :=
                    TotalAmount + Amount +
                    Round(
                      (TotalAmount + Amount) * (1 - PurchHeader."VAT Base Discount %" / 100) * "VAT %" / 100,
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
                  if "Use Tax" then
                    "Amount Including VAT" := Amount
                  else
                    "Amount Including VAT" :=
                      TotalAmount + Amount +
                      Round(
                        SalesTaxCalculate.CalculateTax(
                          "Tax Area Code","Tax Group Code","Tax Liable",PurchHeader."Posting Date",
                          TotalAmount + Amount,TotalQuantityBase + "Quantity (Base)",
                          PurchHeader."Currency Factor"),
                        Currency."Amount Rounding Precision") -
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
    procedure UpdatePrepmtSetupFields()
    var
        GenPostingSetup: Record "General Posting Setup";
        GLAcc: Record "G/L Account";
    begin
        if ("Prepayment %" <> 0) and HasTypeToFillMandatoryFields then begin
          TestField("Document Type","Document Type"::Order);
          TestField("No.");
          GenPostingSetup.Get("Gen. Bus. Posting Group","Gen. Prod. Posting Group");
          if GenPostingSetup."Purch. Prepayments Account" <> '' then begin
            GLAcc.Get(GenPostingSetup."Purch. Prepayments Account");
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

    local procedure UpdateSalesCost()
    var
        SalesOrderLine: Record "Sales Line";
    begin
        case true of
          "Sales Order Line No." <> 0:
            // Drop Shipment
            SalesOrderLine.Get(SalesOrderLine."Document Type"::Order,"Sales Order No.","Sales Order Line No.");
          "Special Order Sales Line No." <> 0:
            // Special Order
            begin
              if not
                 SalesOrderLine.Get(SalesOrderLine."Document Type"::Order,"Special Order Sales No.","Special Order Sales Line No.")
              then
                exit;
            end;
          else
            exit;
        end;
        SalesOrderLine."Unit Cost (LCY)" := "Unit Cost (LCY)" * SalesOrderLine."Qty. per Unit of Measure" / "Qty. per Unit of Measure";
        SalesOrderLine."Unit Cost" := "Unit Cost" * SalesOrderLine."Qty. per Unit of Measure" / "Qty. per Unit of Measure";
        SalesOrderLine.Validate("Unit Cost (LCY)");
        SalesOrderLine.Modify;
    end;

    local procedure GetFAPostingGroup()
    var
        LocalGLAcc: Record "G/L Account";
        FAPostingGr: Record "FA Posting Group";
        FADeprBook: Record "FA Depreciation Book";
        FASetup: Record "FA Setup";
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
        if "FA Posting Type" = "FA Posting Type"::" " then
          "FA Posting Type" := "FA Posting Type"::"Acquisition Cost";
        FADeprBook.Get("No.","Depreciation Book Code");
        FADeprBook.TestField("FA Posting Group");
        FAPostingGr.Get(FADeprBook."FA Posting Group");
        case "FA Posting Type" of
          "FA Posting Type"::"Acquisition Cost":
            LocalGLAcc.Get(FAPostingGr.GetAcquisitionCostAccount);
          "FA Posting Type"::Appreciation:
            LocalGLAcc.Get(FAPostingGr.GetAppreciationAccount);
          "FA Posting Type"::Maintenance:
            LocalGLAcc.Get(FAPostingGr.GetMaintenanceExpenseAccount);
        end;
        LocalGLAcc.CheckGLAcc;
        LocalGLAcc.TestField("Gen. Prod. Posting Group");
        "Posting Group" := FADeprBook."FA Posting Group";
        "Gen. Prod. Posting Group" := LocalGLAcc."Gen. Prod. Posting Group";
        "Tax Group Code" := LocalGLAcc."Tax Group Code";
        Validate("VAT Prod. Posting Group",LocalGLAcc."VAT Prod. Posting Group");
    end;

    procedure UpdateUOMQtyPerStockQty()
    begin
        GetItem;
        "Unit Cost (LCY)" := Item."Unit Cost" * "Qty. per Unit of Measure";
        "Unit Price (LCY)" := Item."Unit Price" * "Qty. per Unit of Measure";
        GetPurchHeader;
        if PurchHeader."Currency Code" <> '' then
          "Unit Cost" :=
            CurrExchRate.ExchangeAmtLCYToFCY(
              GetDate,PurchHeader."Currency Code",
              "Unit Cost (LCY)",PurchHeader."Currency Factor")
        else
          "Unit Cost" := "Unit Cost (LCY)";
        UpdateDirectUnitCost(FieldNo("Unit of Measure Code"));
    end;

    [Scope('Personalization')]
    procedure ShowReservation()
    var
        Reservation: Page Reservation;
    begin
        TestField(Type,Type::Item);
        TestField("Prod. Order No.",'');
        TestField("No.");
        Clear(Reservation);
        Reservation.SetPurchLine(Rec);
        Reservation.RunModal;
    end;

    [Scope('Personalization')]
    procedure ShowReservationEntries(Modal: Boolean)
    var
        ReservEntry: Record "Reservation Entry";
    begin
        TestField(Type,Type::Item);
        TestField("No.");
        ReservEngineMgt.InitFilterAndSortingLookupFor(ReservEntry,true);
        ReservePurchLine.FilterReservFor(ReservEntry,Rec);
        if Modal then
          PAGE.RunModal(PAGE::"Reservation Entries",ReservEntry)
        else
          PAGE.Run(PAGE::"Reservation Entries",ReservEntry);
    end;

    [Scope('Personalization')]
    procedure GetDate(): Date
    begin
        if PurchHeader."Posting Date" <> 0D then
          exit(PurchHeader."Posting Date");
        exit(WorkDate);
    end;

    [Scope('Personalization')]
    procedure Signed(Value: Decimal): Decimal
    begin
        case "Document Type" of
          "Document Type"::Quote,
          "Document Type"::Order,
          "Document Type"::Invoice,
          "Document Type"::"Blanket Order":
            exit(Value);
          "Document Type"::"Return Order",
          "Document Type"::"Credit Memo":
            exit(-Value);
        end;
    end;

    [Scope('Personalization')]
    procedure BlanketOrderLookup()
    begin
        PurchLine2.Reset;
        PurchLine2.SetCurrentKey("Document Type",Type,"No.");
        PurchLine2.SetRange("Document Type","Document Type"::"Blanket Order");
        PurchLine2.SetRange(Type,Type);
        PurchLine2.SetRange("No.","No.");
        PurchLine2.SetRange("Pay-to Vendor No.","Pay-to Vendor No.");
        PurchLine2.SetRange("Buy-from Vendor No.","Buy-from Vendor No.");
        if PAGE.RunModal(PAGE::"Purchase Lines",PurchLine2) = ACTION::LookupOK then begin
          PurchLine2.TestField("Document Type","Document Type"::"Blanket Order");
          "Blanket Order No." := PurchLine2."Document No.";
          Validate("Blanket Order Line No.",PurchLine2."Line No.");
        end;
    end;

    [Scope('Personalization')]
    procedure BlockDynamicTracking(SetBlock: Boolean)
    begin
        TrackingBlocked := SetBlock;
        ReservePurchLine.Block(SetBlock);
    end;

    [Scope('Personalization')]
    procedure ShowDimensions()
    begin
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet("Dimension Set ID",StrSubstNo('%1 %2 %3',"Document Type","Document No.","Line No."));
        VerifyItemLineDim;
        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID","Shortcut Dimension 1 Code","Shortcut Dimension 2 Code");
    end;

    [Scope('Personalization')]
    procedure OpenItemTrackingLines()
    begin
        TestField(Type,Type::Item);
        TestField("No.");
        if "Prod. Order No." <> '' then
          Error(Text031,"Prod. Order No.");

        TestField("Quantity (Base)");

        ReservePurchLine.CallItemTracking(Rec);
    end;

    [Scope('Personalization')]
    procedure CreateDim(Type1: Integer;No1: Code[20];Type2: Integer;No2: Code[20];Type3: Integer;No3: Code[20];Type4: Integer;No4: Code[20])
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
        TableID[4] := Type4;
        No[4] := No4;
        OnAfterCreateDimTableIDs(Rec,CurrFieldNo,TableID,No);

        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        GetPurchHeader;
        "Dimension Set ID" :=
          DimMgt.GetRecDefaultDimID(
            Rec,CurrFieldNo,TableID,No,SourceCodeSetup.Purchases,
            "Shortcut Dimension 1 Code","Shortcut Dimension 2 Code",PurchHeader."Dimension Set ID",DATABASE::Vendor);
        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID","Shortcut Dimension 1 Code","Shortcut Dimension 2 Code");
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

    local procedure GetSKU(): Boolean
    begin
        TestField("No.");
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
    procedure ShowItemChargeAssgnt()
    var
        ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)";
        AssignItemChargePurch: Codeunit "Item Charge Assgnt. (Purch.)";
        ItemChargeAssgnts: Page "Item Charge Assignment (Purch)";
        ItemChargeAssgntLineAmt: Decimal;
    begin
        Get("Document Type","Document No.","Line No.");
        TestField("No.");
        TestField(Quantity);

        if Type <> Type::"Charge (Item)" then
          Error(ItemChargeAssignmentErr);

        GetPurchHeader;
        if PurchHeader."Currency Code" = '' then
          Currency.InitRoundingPrecision
        else
          Currency.Get(PurchHeader."Currency Code");
        if ("Inv. Discount Amount" = 0) and
           ("Line Discount Amount" = 0) and
           (not PurchHeader."Prices Including VAT")
        then
          ItemChargeAssgntLineAmt := "Line Amount"
        else
          if PurchHeader."Prices Including VAT" then
            ItemChargeAssgntLineAmt :=
              Round(CalcLineAmount / (1 + "VAT %" / 100),Currency."Amount Rounding Precision")
          else
            ItemChargeAssgntLineAmt := CalcLineAmount;

        ItemChargeAssgntPurch.Reset;
        ItemChargeAssgntPurch.SetRange("Document Type","Document Type");
        ItemChargeAssgntPurch.SetRange("Document No.","Document No.");
        ItemChargeAssgntPurch.SetRange("Document Line No.","Line No.");
        ItemChargeAssgntPurch.SetRange("Item Charge No.","No.");
        if not ItemChargeAssgntPurch.FindLast then begin
          ItemChargeAssgntPurch."Document Type" := "Document Type";
          ItemChargeAssgntPurch."Document No." := "Document No.";
          ItemChargeAssgntPurch."Document Line No." := "Line No.";
          ItemChargeAssgntPurch."Item Charge No." := "No.";
          ItemChargeAssgntPurch."Unit Cost" :=
            Round(ItemChargeAssgntLineAmt / Quantity,
              Currency."Unit-Amount Rounding Precision");
        end;

        ItemChargeAssgntLineAmt :=
          Round(
            ItemChargeAssgntLineAmt * ("Qty. to Invoice" / Quantity),
            Currency."Amount Rounding Precision");

        if "Document Type" in ["Document Type"::"Return Order","Document Type"::"Credit Memo"] then
          AssignItemChargePurch.CreateDocChargeAssgnt(ItemChargeAssgntPurch,"Return Shipment No.")
        else
          AssignItemChargePurch.CreateDocChargeAssgnt(ItemChargeAssgntPurch,"Receipt No.");
        Clear(AssignItemChargePurch);
        Commit;

        ItemChargeAssgnts.Initialize(Rec,ItemChargeAssgntLineAmt);
        ItemChargeAssgnts.RunModal;

        CalcFields("Qty. to Assign");
    end;

    [Scope('Personalization')]
    procedure UpdateItemChargeAssgnt()
    var
        ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)";
        ShareOfVAT: Decimal;
        TotalQtyToAssign: Decimal;
        TotalAmtToAssign: Decimal;
    begin
        if "Document Type" = "Document Type"::"Blanket Order" then
          exit;

        CalcFields("Qty. Assigned","Qty. to Assign");
        if Abs("Quantity Invoiced") > Abs(("Qty. Assigned" + "Qty. to Assign")) then
          Error(Text032,FieldCaption("Quantity Invoiced"),FieldCaption("Qty. Assigned"),FieldCaption("Qty. to Assign"));

        ItemChargeAssgntPurch.SetRange("Document Type","Document Type");
        ItemChargeAssgntPurch.SetRange("Document No.","Document No.");
        ItemChargeAssgntPurch.SetRange("Document Line No.","Line No.");
        ItemChargeAssgntPurch.CalcSums("Qty. to Assign");
        TotalQtyToAssign := ItemChargeAssgntPurch."Qty. to Assign";
        if (CurrFieldNo <> 0) and ("Unit Cost" <> xRec."Unit Cost") then begin
          ItemChargeAssgntPurch.SetFilter("Qty. Assigned",'<>0');
          if not ItemChargeAssgntPurch.IsEmpty then
            Error(Text022,
              FieldCaption("Unit Cost"));
          ItemChargeAssgntPurch.SetRange("Qty. Assigned");
        end;

        if (CurrFieldNo <> 0) and (Quantity <> xRec.Quantity) then begin
          ItemChargeAssgntPurch.SetFilter("Qty. Assigned",'<>0');
          if not ItemChargeAssgntPurch.IsEmpty then
            Error(Text022,
              FieldCaption(Quantity));
          ItemChargeAssgntPurch.SetRange("Qty. Assigned");
        end;

        if ItemChargeAssgntPurch.FindSet(true) and (Quantity <> 0) then begin
          GetPurchHeader;
          TotalAmtToAssign := CalcTotalAmtToAssign(TotalQtyToAssign);
          repeat
            ShareOfVAT := 1;
            if PurchHeader."Prices Including VAT" then
              ShareOfVAT := 1 + "VAT %" / 100;
            if ItemChargeAssgntPurch."Unit Cost" <>
               Round(CalcLineAmount / Quantity / ShareOfVAT,Currency."Unit-Amount Rounding Precision")
            then
              ItemChargeAssgntPurch."Unit Cost" :=
                Round(CalcLineAmount / Quantity / ShareOfVAT,Currency."Unit-Amount Rounding Precision");
            if TotalQtyToAssign <> 0 then begin
              ItemChargeAssgntPurch."Amount to Assign" :=
                Round(ItemChargeAssgntPurch."Qty. to Assign" / TotalQtyToAssign * TotalAmtToAssign,
                  Currency."Amount Rounding Precision");
              TotalQtyToAssign -= ItemChargeAssgntPurch."Qty. to Assign";
              TotalAmtToAssign -= ItemChargeAssgntPurch."Amount to Assign";
            end;
            ItemChargeAssgntPurch.Modify;
          until ItemChargeAssgntPurch.Next = 0;
          CalcFields("Qty. to Assign");
        end;
    end;

    local procedure DeleteItemChargeAssgnt(DocType: Option;DocNo: Code[20];DocLineNo: Integer)
    var
        ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)";
    begin
        ItemChargeAssgntPurch.SetRange("Applies-to Doc. Type",DocType);
        ItemChargeAssgntPurch.SetRange("Applies-to Doc. No.",DocNo);
        ItemChargeAssgntPurch.SetRange("Applies-to Doc. Line No.",DocLineNo);
        if not ItemChargeAssgntPurch.IsEmpty then
          ItemChargeAssgntPurch.DeleteAll(true);
    end;

    local procedure DeleteChargeChargeAssgnt(DocType: Option;DocNo: Code[20];DocLineNo: Integer)
    var
        ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)";
    begin
        if DocType <> "Document Type"::"Blanket Order" then
          if "Quantity Invoiced" <> 0 then begin
            CalcFields("Qty. Assigned");
            TestField("Qty. Assigned","Quantity Invoiced");
          end;

        ItemChargeAssgntPurch.Reset;
        ItemChargeAssgntPurch.SetRange("Document Type",DocType);
        ItemChargeAssgntPurch.SetRange("Document No.",DocNo);
        ItemChargeAssgntPurch.SetRange("Document Line No.",DocLineNo);
        if not ItemChargeAssgntPurch.IsEmpty then
          ItemChargeAssgntPurch.DeleteAll;
    end;

    [Scope('Personalization')]
    procedure CheckItemChargeAssgnt()
    var
        ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)";
    begin
        ItemChargeAssgntPurch.SetRange("Applies-to Doc. Type","Document Type");
        ItemChargeAssgntPurch.SetRange("Applies-to Doc. No.","Document No.");
        ItemChargeAssgntPurch.SetRange("Applies-to Doc. Line No.","Line No.");
        ItemChargeAssgntPurch.SetRange("Document Type","Document Type");
        ItemChargeAssgntPurch.SetRange("Document No.","Document No.");
        if ItemChargeAssgntPurch.FindSet then begin
          TestField("Allow Item Charge Assignment");
          repeat
            ItemChargeAssgntPurch.TestField("Qty. to Assign",0);
          until ItemChargeAssgntPurch.Next = 0;
        end;
    end;

    local procedure GetFieldCaption(FieldNumber: Integer): Text[100]
    var
        "Field": Record "Field";
    begin
        Field.Get(DATABASE::"Purchase Line",FieldNumber);
        exit(Field."Field Caption");
    end;

    [Scope('Personalization')]
    procedure GetCaptionClass(FieldNumber: Integer): Text[80]
    begin
        if not PurchHeader.Get("Document Type","Document No.") then begin
          PurchHeader."No." := '';
          PurchHeader.Init;
        end;
        case FieldNumber of
          FieldNo("No."):
            exit(StrSubstNo('3,%1',GetFieldCaption(FieldNumber)));
          else begin
            if PurchHeader."Prices Including VAT" then
              exit('2,1,' + GetFieldCaption(FieldNumber));
            exit('2,0,' + GetFieldCaption(FieldNumber));
          end
        end;
    end;

    [Scope('Personalization')]
    procedure TestStatusOpen()
    begin
        if StatusCheckSuspended then
          exit;
        GetPurchHeader;
        if not "System-Created Entry" then
          if HasTypeToFillMandatoryFields then
            PurchHeader.TestField(Status,PurchHeader.Status::Open);
    end;

    [Scope('Personalization')]
    procedure SuspendStatusCheck(Suspend: Boolean)
    begin
        StatusCheckSuspended := Suspend;
    end;

    [Scope('Personalization')]
    procedure UpdateLeadTimeFields()
    begin
        if Type = Type::Item then begin
          GetPurchHeader;

          Evaluate("Lead Time Calculation",
            LeadTimeMgt.PurchaseLeadTime(
              "No.","Location Code","Variant Code",
              "Buy-from Vendor No."));
          if Format("Lead Time Calculation") = '' then
            "Lead Time Calculation" := PurchHeader."Lead Time Calculation";
          Evaluate("Safety Lead Time",LeadTimeMgt.SafetyLeadTime("No.","Location Code","Variant Code"));
        end;
    end;

    [Scope('Personalization')]
    procedure GetUpdateBasicDates()
    begin
        GetPurchHeader;
        if PurchHeader."Expected Receipt Date" <> 0D then
          Validate("Expected Receipt Date",PurchHeader."Expected Receipt Date")
        else
          Validate("Order Date",PurchHeader."Order Date");
    end;

    [Scope('Personalization')]
    procedure UpdateDates()
    begin
        if "Promised Receipt Date" <> 0D then
          Validate("Promised Receipt Date")
        else
          if "Requested Receipt Date" <> 0D then
            Validate("Requested Receipt Date")
          else
            GetUpdateBasicDates;
    end;

    [Scope('Personalization')]
    procedure InternalLeadTimeDays(PurchDate: Date): Text[30]
    var
        TotalDays: DateFormula;
    begin
        Evaluate(
          TotalDays,'<' + Format(CalcDate("Safety Lead Time",CalcDate("Inbound Whse. Handling Time",PurchDate)) - PurchDate) + 'D>');
        exit(Format(TotalDays));
    end;

    [Scope('Personalization')]
    procedure UpdateVATOnLines(QtyType: Option General,Invoicing,Shipping;var PurchHeader: Record "Purchase Header";var PurchLine: Record "Purchase Line";var VATAmountLine: Record "VAT Amount Line") LineWasModified: Boolean
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
        if PurchHeader."Currency Code" = '' then
          Currency.InitRoundingPrecision
        else
          Currency.Get(PurchHeader."Currency Code");

        TempVATAmountLineRemainder.DeleteAll;

        with PurchLine do begin
          SetRange("Document Type",PurchHeader."Document Type");
          SetRange("Document No.",PurchHeader."No.");
          LockTable;
          if FindSet then
            repeat
              if not ZeroAmountLine(QtyType) then begin
                DeferralAmount := GetDeferralAmount;
                VATAmountLine.Get("VAT Identifier","VAT Calculation Type","Tax Group Code","Use Tax","Line Amount" >= 0);
                if VATAmountLine.Modified then begin
                  if not TempVATAmountLineRemainder.Get(
                       "VAT Identifier","VAT Calculation Type","Tax Group Code","Use Tax","Line Amount" >= 0)
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
                      if QtyType = QtyType::General then
                        LineAmountToInvoice := "Line Amount"
                      else
                        LineAmountToInvoice :=
                          Round("Line Amount" * "Qty. to Invoice" / Quantity,Currency."Amount Rounding Precision");
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
                    if PurchHeader."Prices Including VAT" then begin
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
                          NewAmount * (1 - PurchHeader."VAT Base Discount %" / 100),
                          Currency."Amount Rounding Precision");
                    end else begin
                      if "VAT Calculation Type" = "VAT Calculation Type"::"Full VAT" then begin
                        VATAmount := CalcLineAmount;
                        NewAmount := 0;
                        NewVATBaseAmount := 0;
                      end else begin
                        NewAmount := CalcLineAmount;
                        NewVATBaseAmount :=
                          Round(
                            NewAmount * (1 - PurchHeader."VAT Base Discount %" / 100),
                            Currency."Amount Rounding Precision");
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
                  if not ((Type = Type::"Charge (Item)") and ("Quantity Invoiced" <> "Qty. Assigned")) then begin
                    SetUpdateFromVAT(true);
                    UpdateUnitCost;
                  end;
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

        OnAfterUpdateVATOnLines(PurchHeader,PurchLine,VATAmountLine,QtyType);
    end;

    [Scope('Personalization')]
    procedure CalcVATAmountLines(QtyType: Option General,Invoicing,Shipping;var PurchHeader: Record "Purchase Header";var PurchLine: Record "Purchase Line";var VATAmountLine: Record "VAT Amount Line")
    var
        TotalVATAmount: Decimal;
        QtyToHandle: Decimal;
        AmtToHandle: Decimal;
        RoundingLineInserted: Boolean;
    begin
        Currency.Initialize(PurchHeader."Currency Code");

        VATAmountLine.DeleteAll;

        with PurchLine do begin
          SetRange("Document Type",PurchHeader."Document Type");
          SetRange("Document No.",PurchHeader."No.");
          if FindSet then
            repeat
              if not ZeroAmountLine(QtyType) then begin
                if (Type = Type::"G/L Account") and not "Prepayment Line" then
                  RoundingLineInserted := ("No." = GetVPGInvRoundAcc(PurchHeader)) or RoundingLineInserted;
                if "VAT Calculation Type" in
                   ["VAT Calculation Type"::"Reverse Charge VAT","VAT Calculation Type"::"Sales Tax"]
                then
                  "VAT %" := 0;
                if not VATAmountLine.Get(
                     "VAT Identifier","VAT Calculation Type","Tax Group Code","Use Tax","Line Amount" >= 0)
                then
                  VATAmountLine.InsertNewLine(
                    "VAT Identifier","VAT Calculation Type","Tax Group Code","Use Tax","VAT %","Line Amount" >= 0,false);

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
                        (not PurchHeader.Receive) and PurchHeader.Invoice and (not "Prepayment Line"):
                          if "Receipt No." = '' then begin
                            QtyToHandle := GetAbsMin("Qty. to Invoice","Qty. Rcd. Not Invoiced");
                            VATAmountLine.Quantity += GetAbsMin("Qty. to Invoice (Base)","Qty. Rcd. Not Invoiced (Base)");
                          end else begin
                            QtyToHandle := "Qty. to Invoice";
                            VATAmountLine.Quantity += "Qty. to Invoice (Base)";
                          end;
                        ("Document Type" in ["Document Type"::"Return Order","Document Type"::"Credit Memo"]) and
                        (not PurchHeader.Ship) and PurchHeader.Invoice:
                          if "Return Shipment No." = '' then begin
                            QtyToHandle := GetAbsMin("Qty. to Invoice","Return Qty. Shipped Not Invd.");
                            VATAmountLine.Quantity += GetAbsMin("Qty. to Invoice (Base)","Ret. Qty. Shpd Not Invd.(Base)");
                          end else begin
                            QtyToHandle := "Qty. to Invoice";
                            VATAmountLine.Quantity += "Qty. to Invoice (Base)";
                          end;
                        else begin
                          QtyToHandle := "Qty. to Invoice";
                          VATAmountLine.Quantity += "Qty. to Invoice (Base)";
                        end;
                      end;
                      AmtToHandle := GetLineAmountToHandle(QtyToHandle);
                      if PurchHeader."Invoice Discount Calculation" <> PurchHeader."Invoice Discount Calculation"::Amount then
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
                        QtyToHandle := "Return Qty. to Ship";
                        VATAmountLine.Quantity += "Return Qty. to Ship (Base)";
                      end else begin
                        QtyToHandle := "Qty. to Receive";
                        VATAmountLine.Quantity += "Qty. to Receive (Base)";
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
          TotalVATAmount,Currency,PurchHeader."Currency Factor",PurchHeader."Prices Including VAT",
          PurchHeader."VAT Base Discount %",PurchHeader."Tax Area Code",PurchHeader."Tax Liable",PurchHeader."Posting Date");

        if RoundingLineInserted and (TotalVATAmount <> 0) then
          if VATAmountLine.Get(PurchLine."VAT Identifier",PurchLine."VAT Calculation Type",
               PurchLine."Tax Group Code",PurchLine."Use Tax",PurchLine."Line Amount" >= 0)
          then begin
            VATAmountLine."VAT Amount" += TotalVATAmount;
            VATAmountLine."Amount Including VAT" += TotalVATAmount;
            VATAmountLine."Calculated VAT Amount" += TotalVATAmount;
            VATAmountLine.Modify;
          end;

        OnAfterCalcVATAmountLines(PurchHeader,PurchLine,VATAmountLine,QtyType);
    end;

    [Scope('Personalization')]
    procedure UpdateWithWarehouseReceive()
    begin
        if Type = Type::Item then
          case true of
            ("Document Type" in ["Document Type"::Quote,"Document Type"::Order]) and (Quantity >= 0):
              if Location.RequireReceive("Location Code") then
                Validate("Qty. to Receive",0)
              else
                Validate("Qty. to Receive","Outstanding Quantity");
            ("Document Type" in ["Document Type"::Quote,"Document Type"::Order]) and (Quantity < 0):
              if Location.RequireShipment("Location Code") then
                Validate("Qty. to Receive",0)
              else
                Validate("Qty. to Receive","Outstanding Quantity");
            ("Document Type" = "Document Type"::"Return Order") and (Quantity >= 0):
              if Location.RequireShipment("Location Code") then
                Validate("Return Qty. to Ship",0)
              else
                Validate("Return Qty. to Ship","Outstanding Quantity");
            ("Document Type" = "Document Type"::"Return Order") and (Quantity < 0):
              if Location.RequireReceive("Location Code") then
                Validate("Return Qty. to Ship",0)
              else
                Validate("Return Qty. to Ship","Outstanding Quantity");
          end;

        GetPurchHeader;
        OnAfterUpdateWithWarehouseReceive(PurchHeader,Rec);

        SetDefaultQuantity;
    end;

    local procedure CheckWarehouse()
    var
        Location2: Record Location;
        WhseSetup: Record "Warehouse Setup";
        ShowDialog: Option " ",Message,Error;
        DialogText: Text[50];
    begin
        if "Prod. Order No." <> '' then
          exit;
        GetLocation("Location Code");
        if "Location Code" = '' then begin
          WhseSetup.Get;
          Location2."Require Shipment" := WhseSetup."Require Shipment";
          Location2."Require Pick" := WhseSetup."Require Pick";
          Location2."Require Receive" := WhseSetup."Require Receive";
          Location2."Require Put-away" := WhseSetup."Require Put-away";
        end else
          Location2 := Location;

        DialogText := Text033;
        if ("Document Type" in ["Document Type"::Order,"Document Type"::"Return Order"]) and
           Location2."Directed Put-away and Pick"
        then begin
          ShowDialog := ShowDialog::Error;
          if (("Document Type" = "Document Type"::Order) and (Quantity >= 0)) or
             (("Document Type" = "Document Type"::"Return Order") and (Quantity < 0))
          then
            DialogText :=
              DialogText + Location2.GetRequirementText(Location2.FieldNo("Require Receive"))
          else
            DialogText :=
              DialogText + Location2.GetRequirementText(Location2.FieldNo("Require Shipment"));
        end else begin
          if (("Document Type" = "Document Type"::Order) and (Quantity >= 0) and
              (Location2."Require Receive" or Location2."Require Put-away")) or
             (("Document Type" = "Document Type"::"Return Order") and (Quantity < 0) and
              (Location2."Require Receive" or Location2."Require Put-away"))
          then begin
            if WhseValidateSourceLine.WhseLinesExist(
                 DATABASE::"Purchase Line",
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
              DialogText := Text034;
              DialogText :=
                DialogText + Location2.GetRequirementText(Location2.FieldNo("Require Put-away"));
            end;
          end;

          if (("Document Type" = "Document Type"::Order) and (Quantity < 0) and
              (Location2."Require Shipment" or Location2."Require Pick")) or
             (("Document Type" = "Document Type"::"Return Order") and (Quantity >= 0) and
              (Location2."Require Shipment" or Location2."Require Pick"))
          then begin
            if WhseValidateSourceLine.WhseLinesExist(
                 DATABASE::"Purchase Line",
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
              DialogText := Text034;
              DialogText :=
                DialogText + Location2.GetRequirementText(Location2.FieldNo("Require Pick"));
            end;
          end;
        end;

        case ShowDialog of
          ShowDialog::Message:
            Message(Text016 + Text017,DialogText,FieldCaption("Line No."),"Line No.");
          ShowDialog::Error:
            Error(Text016,DialogText,FieldCaption("Line No."),"Line No.")
        end;

        HandleDedicatedBin(true);
    end;

    local procedure GetOverheadRateFCY(): Decimal
    var
        QtyPerUOM: Decimal;
    begin
        if "Prod. Order No." = '' then
          QtyPerUOM := "Qty. per Unit of Measure"
        else begin
          GetItem;
          QtyPerUOM := UOMMgt.GetQtyPerUnitOfMeasure(Item,"Unit of Measure Code");
        end;

        exit(
          CurrExchRate.ExchangeAmtLCYToFCY(
            GetDate,"Currency Code","Overhead Rate" * QtyPerUOM,PurchHeader."Currency Factor"));
    end;

    [Scope('Personalization')]
    procedure GetItemTranslation()
    var
        ItemTranslation: Record "Item Translation";
    begin
        GetPurchHeader;
        if ItemTranslation.Get("No.","Variant Code",PurchHeader."Language Code") then begin
          Description := ItemTranslation.Description;
          "Description 2" := ItemTranslation."Description 2";
        end;
    end;

    local procedure GetGLSetup()
    begin
        if not GLSetupRead then
          GLSetup.Get;
        GLSetupRead := true;
    end;

    local procedure GetPurchSetup()
    begin
        if not PurchSetupRead then
          PurchSetup.Get;
        PurchSetupRead := true;
    end;

    [Scope('Personalization')]
    procedure AdjustDateFormula(DateFormulatoAdjust: DateFormula): Text[30]
    begin
        if Format(DateFormulatoAdjust) <> '' then
          exit(Format(DateFormulatoAdjust));
        Evaluate(DateFormulatoAdjust,'<0D>');
        exit(Format(DateFormulatoAdjust));
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
    procedure RowID1(): Text[250]
    var
        ItemTrackingMgt: Codeunit "Item Tracking Management";
    begin
        exit(ItemTrackingMgt.ComposeRowID(DATABASE::"Purchase Line","Document Type",
            "Document No.",'',0,"Line No."));
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
            WMSManagement.GetDefaultBin("No.","Variant Code","Location Code","Bin Code");
            HandleDedicatedBin(false);
          end;
        end;
    end;

    [Scope('Personalization')]
    procedure IsInbound(): Boolean
    begin
        case "Document Type" of
          "Document Type"::Order,"Document Type"::Invoice,"Document Type"::Quote,"Document Type"::"Blanket Order":
            exit("Quantity (Base)" > 0);
          "Document Type"::"Return Order","Document Type"::"Credit Memo":
            exit("Quantity (Base)" < 0);
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

    procedure CrossReferenceNoLookUp()
    var
        ItemCrossReference: Record "Item Cross Reference";
    begin
        if Type = Type::Item then begin
          GetPurchHeader;
          ItemCrossReference.Reset;
          ItemCrossReference.SetCurrentKey("Cross-Reference Type","Cross-Reference Type No.");
          ItemCrossReference.SetFilter(
            "Cross-Reference Type",'%1|%2',
            ItemCrossReference."Cross-Reference Type"::Vendor,
            ItemCrossReference."Cross-Reference Type"::" ");
          ItemCrossReference.SetFilter("Cross-Reference Type No.",'%1|%2',PurchHeader."Buy-from Vendor No.",'');
          if PAGE.RunModal(PAGE::"Cross Reference List",ItemCrossReference) = ACTION::LookupOK then begin
            Validate("Cross-Reference No.",ItemCrossReference."Cross-Reference No.");
            PurchPriceCalcMgt.FindPurchLinePrice(PurchHeader,Rec,FieldNo("Cross-Reference No."));
            PurchPriceCalcMgt.FindPurchLineLineDisc(PurchHeader,Rec);
            Validate("Direct Unit Cost");
          end;
        end;
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

    local procedure GetAbsMin(QtyToHandle: Decimal;QtyHandled: Decimal): Decimal
    begin
        if Abs(QtyHandled) < Abs(QtyToHandle) then
          exit(QtyHandled);

        exit(QtyToHandle);
    end;

    local procedure CheckApplToItemLedgEntry(): Code[10]
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ApplyRec: Record "Item Application Entry";
        ItemTrackingLines: Page "Item Tracking Lines";
        ReturnedQty: Decimal;
        RemainingtobeReturnedQty: Decimal;
    begin
        if "Appl.-to Item Entry" = 0 then
          exit;

        if "Receipt No." <> '' then
          exit;

        TestField(Type,Type::Item);
        TestField(Quantity);
        if Signed(Quantity) > 0 then
          TestField("Prod. Order No.",'');
        if "Document Type" in ["Document Type"::"Return Order","Document Type"::"Credit Memo"] then begin
          if Quantity < 0 then
            FieldError(Quantity,Text029);
        end else begin
          if Quantity > 0 then
            FieldError(Quantity,Text030);
        end;
        ItemLedgEntry.Get("Appl.-to Item Entry");
        ItemLedgEntry.TestField(Positive,true);
        if ItemLedgEntry.TrackingExists then
          Error(Text040,ItemTrackingLines.Caption,FieldCaption("Appl.-to Item Entry"));

        ItemLedgEntry.TestField("Item No.","No.");
        ItemLedgEntry.TestField("Variant Code","Variant Code");

        // Track qty in both alternative and base UOM for better error checking and reporting
        if Abs("Quantity (Base)") > ItemLedgEntry.Quantity then
          Error(
            Text042,
            ItemLedgEntry.Quantity,ItemLedgEntry.FieldCaption("Document No."),
            ItemLedgEntry."Document No.");

        if "Document Type" in ["Document Type"::"Return Order","Document Type"::"Credit Memo"] then
          if Abs("Outstanding Qty. (Base)") > ItemLedgEntry."Remaining Quantity" then begin
            ReturnedQty := ApplyRec.Returned(ItemLedgEntry."Entry No.");
            RemainingtobeReturnedQty := ItemLedgEntry.Quantity - ReturnedQty;
            if not ("Qty. per Unit of Measure" = 0) then begin
              ReturnedQty := Round(ReturnedQty / "Qty. per Unit of Measure",0.00001);
              RemainingtobeReturnedQty := Round(RemainingtobeReturnedQty / "Qty. per Unit of Measure",0.00001);
            end;

            if ((("Qty. per Unit of Measure" = 0) and (RemainingtobeReturnedQty < Abs("Outstanding Qty. (Base)"))) or
                (("Qty. per Unit of Measure" <> 0) and (RemainingtobeReturnedQty < Abs("Outstanding Quantity"))))
            then
              Error(
                Text035,
                ReturnedQty,ItemLedgEntry.FieldCaption("Document No."),
                ItemLedgEntry."Document No.",RemainingtobeReturnedQty);
          end;

        exit(ItemLedgEntry."Location Code");
    end;

    [Scope('Personalization')]
    procedure CalcPrepaymentToDeduct()
    begin
        if ("Qty. to Invoice" <> 0) and ("Prepmt. Amt. Inv." <> 0) then begin
          GetPurchHeader;
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

        GetPurchHeader;

        if "Prepmt Amt to Deduct" = 0 then
          LineAmount := Round(QtyToHandle * "Direct Unit Cost",Currency."Amount Rounding Precision")
        else begin
          LineAmount := Round(Quantity * "Direct Unit Cost",Currency."Amount Rounding Precision");
          LineAmount := Round(QtyToHandle * LineAmount / Quantity,Currency."Amount Rounding Precision");
        end;

        if QtyToHandle <> Quantity then
          LineDiscAmount := Round(LineAmount * "Line Discount %" / 100,Currency."Amount Rounding Precision")
        else
          LineDiscAmount := "Line Discount Amount";

        OnAfterGetLineAmountToHandle(Rec,QtyToHandle,LineAmount,LineDiscAmount);
        exit(LineAmount - LineDiscAmount);
    end;

    [Scope('Personalization')]
    procedure JobTaskIsSet(): Boolean
    var
        JobTaskSet: Boolean;
    begin
        JobTaskSet := false;
        OnBeforeJobTaskIsSet(Rec,JobTaskSet);

        exit(
          (("Job No." <> '') and ("Job Task No." <> '') and (Type in [Type::"G/L Account",Type::Item])) or
          JobTaskSet);
    end;

    [Scope('Personalization')]
    procedure CreateTempJobJnlLine(GetPrices: Boolean)
    begin
        GetPurchHeader;
        Clear(TempJobJnlLine);
        TempJobJnlLine.DontCheckStdCost;
        TempJobJnlLine.Validate("Job No.","Job No.");
        TempJobJnlLine.Validate("Job Task No.","Job Task No.");
        TempJobJnlLine.Validate("Posting Date",PurchHeader."Posting Date");
        TempJobJnlLine.SetCurrencyFactor("Job Currency Factor");
        if Type = Type::"G/L Account" then
          TempJobJnlLine.Validate(Type,TempJobJnlLine.Type::"G/L Account")
        else
          TempJobJnlLine.Validate(Type,TempJobJnlLine.Type::Item);
        TempJobJnlLine.Validate("No.","No.");
        TempJobJnlLine.Validate(Quantity,Quantity);
        TempJobJnlLine.Validate("Variant Code","Variant Code");
        TempJobJnlLine.Validate("Unit of Measure Code","Unit of Measure Code");

        if not GetPrices then begin
          if xRec."Line No." <> 0 then begin
            TempJobJnlLine."Unit Cost" := xRec."Unit Cost";
            TempJobJnlLine."Unit Cost (LCY)" := xRec."Unit Cost (LCY)";
            TempJobJnlLine."Unit Price" := xRec."Job Unit Price";
            TempJobJnlLine."Line Amount" := xRec."Job Line Amount";
            TempJobJnlLine."Line Discount %" := xRec."Job Line Discount %";
            TempJobJnlLine."Line Discount Amount" := xRec."Job Line Discount Amount";
          end else begin
            TempJobJnlLine."Unit Cost" := "Unit Cost";
            TempJobJnlLine."Unit Cost (LCY)" := "Unit Cost (LCY)";
            TempJobJnlLine."Unit Price" := "Job Unit Price";
            TempJobJnlLine."Line Amount" := "Job Line Amount";
            TempJobJnlLine."Line Discount %" := "Job Line Discount %";
            TempJobJnlLine."Line Discount Amount" := "Job Line Discount Amount";
          end;
          TempJobJnlLine.Validate("Unit Price");
        end else
          TempJobJnlLine.Validate("Unit Cost (LCY)","Unit Cost (LCY)");

        OnAfterCreateTempJobJnlLine(TempJobJnlLine,Rec,xRec,GetPrices,CurrFieldNo);
    end;

    [Scope('Personalization')]
    procedure UpdateJobPrices()
    var
        PurchRcptLine: Record "Purch. Rcpt. Line";
    begin
        if "Receipt No." = '' then begin
          "Job Unit Price" := TempJobJnlLine."Unit Price";
          "Job Total Price" := TempJobJnlLine."Total Price";
          "Job Unit Price (LCY)" := TempJobJnlLine."Unit Price (LCY)";
          "Job Total Price (LCY)" := TempJobJnlLine."Total Price (LCY)";
          "Job Line Amount (LCY)" := TempJobJnlLine."Line Amount (LCY)";
          "Job Line Disc. Amount (LCY)" := TempJobJnlLine."Line Discount Amount (LCY)";
          "Job Line Amount" := TempJobJnlLine."Line Amount";
          "Job Line Discount %" := TempJobJnlLine."Line Discount %";
          "Job Line Discount Amount" := TempJobJnlLine."Line Discount Amount";
        end else begin
          PurchRcptLine.Get("Receipt No.","Receipt Line No.");
          "Job Unit Price" := PurchRcptLine."Job Unit Price";
          "Job Total Price" := PurchRcptLine."Job Total Price";
          "Job Unit Price (LCY)" := PurchRcptLine."Job Unit Price (LCY)";
          "Job Total Price (LCY)" := PurchRcptLine."Job Total Price (LCY)";
          "Job Line Amount (LCY)" := PurchRcptLine."Job Line Amount (LCY)";
          "Job Line Disc. Amount (LCY)" := PurchRcptLine."Job Line Disc. Amount (LCY)";
          "Job Line Amount" := PurchRcptLine."Job Line Amount";
          "Job Line Discount %" := PurchRcptLine."Job Line Discount %";
          "Job Line Discount Amount" := PurchRcptLine."Job Line Discount Amount";
        end;

        OnAfterUpdateJobPrices(Rec,TempJobJnlLine,PurchRcptLine);
    end;

    [Scope('Personalization')]
    procedure JobSetCurrencyFactor()
    begin
        GetPurchHeader;
        Clear(TempJobJnlLine);
        TempJobJnlLine.Validate("Job No.","Job No.");
        TempJobJnlLine.Validate("Job Task No.","Job Task No.");
        TempJobJnlLine.Validate("Posting Date",PurchHeader."Posting Date");
        "Job Currency Factor" := TempJobJnlLine."Currency Factor";
    end;

    [Scope('Personalization')]
    procedure SetUpdateFromVAT(UpdateFromVAT2: Boolean)
    begin
        UpdateFromVAT := UpdateFromVAT2;
    end;

    [Scope('Personalization')]
    procedure InitQtyToReceive2()
    begin
        "Qty. to Receive" := "Outstanding Quantity";
        "Qty. to Receive (Base)" := "Outstanding Qty. (Base)";

        "Qty. to Invoice" := MaxQtyToInvoice;
        "Qty. to Invoice (Base)" := MaxQtyToInvoiceBase;
        "VAT Difference" := 0;

        CalcInvDiscToInvoice;

        CalcPrepaymentToDeduct;

        if "Job Planning Line No." <> 0 then
          Validate("Job Planning Line No.");
    end;

    [Scope('Personalization')]
    procedure ClearQtyIfBlank()
    begin
        if "Document Type" = "Document Type"::Order then begin
          GetPurchSetup;
          if PurchSetup."Default Qty. to Receive" = PurchSetup."Default Qty. to Receive"::Blank then begin
            "Qty. to Receive" := 0;
            "Qty. to Receive (Base)" := 0;
          end;
        end;
    end;

    [Scope('Personalization')]
    procedure ShowLineComments()
    var
        PurchCommentLine: Record "Purch. Comment Line";
    begin
        TestField("Document No.");
        TestField("Line No.");
        PurchCommentLine.ShowComments("Document Type","Document No.","Line No.");
    end;

    [Scope('Personalization')]
    procedure SetDefaultQuantity()
    begin
        GetPurchSetup;
        if PurchSetup."Default Qty. to Receive" = PurchSetup."Default Qty. to Receive"::Blank then begin
          if ("Document Type" = "Document Type"::Order) or ("Document Type" = "Document Type"::Quote) then begin
            "Qty. to Receive" := 0;
            "Qty. to Receive (Base)" := 0;
            "Qty. to Invoice" := 0;
            "Qty. to Invoice (Base)" := 0;
          end;
          if "Document Type" = "Document Type"::"Return Order" then begin
            "Return Qty. to Ship" := 0;
            "Return Qty. to Ship (Base)" := 0;
            "Qty. to Invoice" := 0;
            "Qty. to Invoice (Base)" := 0;
          end;
        end;

        OnAfterSetDefaultQuantity(Rec,xRec);
    end;

    [Scope('Personalization')]
    procedure UpdatePrePaymentAmounts()
    var
        ReceiptLine: Record "Purch. Rcpt. Line";
        PurchOrderLine: Record "Purchase Line";
        PurchOrderHeader: Record "Purchase Header";
    begin
        if ("Document Type" <> "Document Type"::Invoice) or ("Prepayment %" = 0) then
          exit;

        if not ReceiptLine.Get("Receipt No.","Receipt Line No.") then begin
          "Prepmt Amt to Deduct" := 0;
          "Prepmt VAT Diff. to Deduct" := 0;
        end else
          if PurchOrderLine.Get(PurchOrderLine."Document Type"::Order,ReceiptLine."Order No.",ReceiptLine."Order Line No.") then begin
            if ("Prepayment %" = 100) and (Quantity <> PurchOrderLine.Quantity - PurchOrderLine."Quantity Invoiced") then
              "Prepmt Amt to Deduct" := "Line Amount"
            else
              "Prepmt Amt to Deduct" :=
                Round((PurchOrderLine."Prepmt. Amt. Inv." - PurchOrderLine."Prepmt Amt Deducted") *
                  Quantity / (PurchOrderLine.Quantity - PurchOrderLine."Quantity Invoiced"),Currency."Amount Rounding Precision");
            "Prepmt VAT Diff. to Deduct" := "Prepayment VAT Difference" - "Prepmt VAT Diff. Deducted";
            PurchOrderHeader.Get(PurchOrderHeader."Document Type"::Order,PurchOrderLine."Document No.");
          end else begin
            "Prepmt Amt to Deduct" := 0;
            "Prepmt VAT Diff. to Deduct" := 0;
          end;

        GetPurchHeader;
        PurchHeader.TestField("Prices Including VAT",PurchOrderHeader."Prices Including VAT");
        if PurchHeader."Prices Including VAT" then begin
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
    procedure SetVendorItemNo()
    var
        ItemVend: Record "Item Vendor";
    begin
        GetItem;
        ItemVend.Init;
        ItemVend."Vendor No." := "Buy-from Vendor No.";
        ItemVend."Variant Code" := "Variant Code";
        Item.FindItemVend(ItemVend,"Location Code");
        Validate("Vendor Item No.",ItemVend."Vendor Item No.");
    end;

    [Scope('Personalization')]
    procedure ZeroAmountLine(QtyType: Option General,Invoicing,Shipping): Boolean
    begin
        if Type = Type::" " then
          exit(true);
        if Quantity = 0 then
          exit(true);
        if "Direct Unit Cost" = 0 then
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
        SetCurrentKey("Document Type",Type,"No.","Variant Code","Drop Shipment","Location Code","Expected Receipt Date");
        SetRange("Document Type",DocumentType);
        SetRange(Type,Type::Item);
        SetRange("No.",Item."No.");
        SetFilter("Variant Code",Item.GetFilter("Variant Filter"));
        SetFilter("Location Code",Item.GetFilter("Location Filter"));
        SetFilter("Drop Shipment",Item.GetFilter("Drop Shipment Filter"));
        SetFilter("Expected Receipt Date",Item.GetFilter("Date Filter"));
        SetFilter("Shortcut Dimension 1 Code",Item.GetFilter("Global Dimension 1 Filter"));
        SetFilter("Shortcut Dimension 2 Code",Item.GetFilter("Global Dimension 2 Filter"));
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

    [Scope('Personalization')]
    procedure GetVPGInvRoundAcc(var PurchHeader: Record "Purchase Header"): Code[20]
    var
        Vendor: Record Vendor;
        VendorPostingGroup: Record "Vendor Posting Group";
    begin
        GetPurchSetup;
        if PurchSetup."Invoice Rounding" then
          if Vendor.Get(PurchHeader."Pay-to Vendor No.") then
            VendorPostingGroup.Get(Vendor."Vendor Posting Group");

        exit(VendorPostingGroup."Invoice Rounding Account");
    end;

    local procedure CheckReceiptRelation()
    var
        PurchRcptLine: Record "Purch. Rcpt. Line";
    begin
        PurchRcptLine.Get("Receipt No.","Receipt Line No.");
        if (Quantity * PurchRcptLine."Qty. Rcd. Not Invoiced") < 0 then
          FieldError("Qty. to Invoice",Text051);
        if Abs(Quantity) > Abs(PurchRcptLine."Qty. Rcd. Not Invoiced") then
          Error(Text052,PurchRcptLine."Document No.");
    end;

    local procedure CheckRetShptRelation()
    var
        ReturnShptLine: Record "Return Shipment Line";
    begin
        ReturnShptLine.Get("Return Shipment No.","Return Shipment Line No.");
        if (Quantity * (ReturnShptLine.Quantity - ReturnShptLine."Quantity Invoiced")) < 0 then
          FieldError("Qty. to Invoice",Text053);
        if Abs(Quantity) > Abs(ReturnShptLine.Quantity - ReturnShptLine."Quantity Invoiced") then
          Error(Text054,ReturnShptLine."Document No.");
    end;

    local procedure VerifyItemLineDim()
    begin
        if IsReceivedShippedItemDimChanged then
          ConfirmReceivedShippedItemDimChange;
    end;

    [Scope('Personalization')]
    procedure IsReceivedShippedItemDimChanged(): Boolean
    begin
        exit(("Dimension Set ID" <> xRec."Dimension Set ID") and (Type = Type::Item) and
          (("Qty. Rcd. Not Invoiced" <> 0) or ("Return Qty. Shipped Not Invd." <> 0)));
    end;

    local procedure IsServiceCharge(): Boolean
    var
        VendorPostingGroup: Record "Vendor Posting Group";
    begin
        if Type <> Type::"G/L Account" then
          exit(false);

        GetPurchHeader;
        VendorPostingGroup.Get(PurchHeader."Vendor Posting Group");
        exit(VendorPostingGroup."Service Charge Acc." = "No.");
    end;

    [Scope('Personalization')]
    procedure ConfirmReceivedShippedItemDimChange(): Boolean
    begin
        if not Confirm(Text049,true,TableCaption) then
          Error(Text050);

        exit(true);
    end;

    [Scope('Personalization')]
    procedure InitType()
    begin
        if "Document No." <> '' then begin
          if not PurchHeader.Get("Document Type","Document No.") then
            exit;
          if (PurchHeader.Status = PurchHeader.Status::Released) and
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
          DialogText := Text033;
          if "Quantity (Base)" <> 0 then
            case "Document Type" of
              "Document Type"::Invoice:
                if "Receipt No." = '' then
                  if Location.Get("Location Code") and Location."Directed Put-away and Pick" then begin
                    DialogText += Location.GetRequirementText(Location.FieldNo("Require Receive"));
                    Error(Text016,DialogText,FieldCaption("Line No."),"Line No.");
                  end;
              "Document Type"::"Credit Memo":
                if "Return Shipment No." = '' then
                  if Location.Get("Location Code") and Location."Directed Put-away and Pick" then begin
                    DialogText += Location.GetRequirementText(Location.FieldNo("Require Shipment"));
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

    local procedure ReservEntryExist(): Boolean
    var
        NewReservEntry: Record "Reservation Entry";
    begin
        ReservePurchLine.FilterReservFor(NewReservEntry,Rec);
        NewReservEntry.SetRange("Reservation Status",NewReservEntry."Reservation Status"::Reservation,
          NewReservEntry."Reservation Status"::Tracking);

        exit(not NewReservEntry.IsEmpty);
    end;

    local procedure ValidateReturnReasonCode(CallingFieldNo: Integer)
    var
        ReturnReason: Record "Return Reason";
    begin
        if CallingFieldNo = 0 then
          exit;
        if "Return Reason Code" = '' then
          UpdateDirectUnitCost(CallingFieldNo);

        if ReturnReason.Get("Return Reason Code") then begin
          if (CallingFieldNo <> FieldNo("Location Code")) and (ReturnReason."Default Location Code" <> '') then
            Validate("Location Code",ReturnReason."Default Location Code");
          if ReturnReason."Inventory Value Zero" then
            Validate("Direct Unit Cost",0)
          else
            UpdateDirectUnitCost(CallingFieldNo);
        end;
    end;

    local procedure UpdateDimensionsFromJobTask()
    var
        SourceCodeSetup: Record "Source Code Setup";
        DimSetArrID: array [10] of Integer;
        DimValue1: Code[20];
        DimValue2: Code[20];
    begin
        SourceCodeSetup.Get;
        DimSetArrID[1] := "Dimension Set ID";
        DimSetArrID[2] :=
          DimMgt.CreateDimSetFromJobTaskDim("Job No.",
            "Job Task No.",DimValue1,DimValue2);
        DimMgt.CreateDimForPurchLineWithHigherPriorities(
          Rec,CurrFieldNo,DimSetArrID[3],DimValue1,DimValue2,SourceCodeSetup.Purchases,DATABASE::Job);

        "Dimension Set ID" :=
          DimMgt.GetCombinedDimensionSetID(
            DimSetArrID,DimValue1,DimValue2);

        "Shortcut Dimension 1 Code" := DimValue1;
        "Shortcut Dimension 2 Code" := DimValue2;
    end;

    local procedure UpdateItemCrossRef()
    begin
        DistIntegration.EnterPurchaseItemCrossRef(Rec);
        UpdateICPartner;
    end;

    local procedure UpdateItemReference()
    begin
        UpdateItemCrossRef;
        if Type <> Type::Item then
          exit;

        if "Cross-Reference No." = '' then
          SetVendorItemNo
        else
          Validate("Vendor Item No.","Cross-Reference No.");
    end;

    local procedure UpdateICPartner()
    var
        ICPartner: Record "IC Partner";
        ItemCrossReference: Record "Item Cross Reference";
    begin
        if PurchHeader."Send IC Document" and
           (PurchHeader."IC Direction" = PurchHeader."IC Direction"::Outgoing)
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
                ICPartner.Get(PurchHeader."Buy-from IC Partner Code");
                case ICPartner."Outbound Purch. Item No. Type" of
                  ICPartner."Outbound Purch. Item No. Type"::"Common Item No.":
                    Validate("IC Partner Ref. Type","IC Partner Ref. Type"::"Common Item No.");
                  ICPartner."Outbound Purch. Item No. Type"::"Internal No.",
                  ICPartner."Outbound Purch. Item No. Type"::"Cross Reference":
                    begin
                      if ICPartner."Outbound Purch. Item No. Type" = ICPartner."Outbound Purch. Item No. Type"::"Internal No." then
                        Validate("IC Partner Ref. Type","IC Partner Ref. Type"::Item)
                      else
                        Validate("IC Partner Ref. Type","IC Partner Ref. Type"::"Cross Reference");
                      ItemCrossReference.SetRange("Cross-Reference Type",ItemCrossReference."Cross-Reference Type"::Vendor);
                      ItemCrossReference.SetRange("Cross-Reference Type No.","Buy-from Vendor No.");
                      ItemCrossReference.SetRange("Item No.","No.");
                      ItemCrossReference.SetRange("Variant Code","Variant Code");
                      ItemCrossReference.SetRange("Unit of Measure","Unit of Measure Code");
                      if ItemCrossReference.FindFirst then
                        "IC Partner Reference" := ItemCrossReference."Cross-Reference No."
                      else
                        "IC Partner Reference" := "No.";
                    end;
                  ICPartner."Outbound Purch. Item No. Type"::"Vendor Item No.":
                    begin
                      "IC Partner Ref. Type" := "IC Partner Ref. Type"::"Vendor Item No.";
                      "IC Partner Reference" := "Vendor Item No.";
                    end;
                end;
              end;
            Type::"Fixed Asset":
              begin
                "IC Partner Ref. Type" := "IC Partner Ref. Type"::" ";
                "IC Partner Reference" := '';
              end;
          end;
    end;

    local procedure CalcTotalAmtToAssign(TotalQtyToAssign: Decimal) TotalAmtToAssign: Decimal
    begin
        TotalAmtToAssign := CalcLineAmount * TotalQtyToAssign / Quantity;

        if PurchHeader."Prices Including VAT" then
          TotalAmtToAssign := TotalAmtToAssign / (1 + "VAT %" / 100) - "VAT Difference";

        TotalAmtToAssign := Round(TotalAmtToAssign,Currency."Amount Rounding Precision");
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
        DeferralPostDate: Date;
        AdjustStartDate: Boolean;
    begin
        GetPurchHeader;
        DeferralPostDate := PurchHeader."Posting Date";
        AdjustStartDate := true;
        if "Document Type" = "Document Type"::"Return Order" then begin
          if "Returns Deferral Start Date" = 0D then
            "Returns Deferral Start Date" := PurchHeader."Posting Date";
          DeferralPostDate := "Returns Deferral Start Date";
          AdjustStartDate := false;
        end;

        DeferralUtilities.RemoveOrSetDeferralSchedule(
          "Deferral Code",DeferralUtilities.GetPurchDeferralDocType,'','',
          "Document Type","Document No.","Line No.",
          GetDeferralAmount,DeferralPostDate,Description,PurchHeader."Currency Code",AdjustStartDate);
    end;

    procedure ShowDeferrals(PostingDate: Date;CurrencyCode: Code[10]): Boolean
    begin
        exit(DeferralUtilities.OpenLineScheduleEdit(
            "Deferral Code",DeferralUtilities.GetPurchDeferralDocType,'','',
            "Document Type","Document No.","Line No.",
            GetDeferralAmount,PostingDate,Description,CurrencyCode));
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
        end;
    end;

    [Scope('Personalization')]
    procedure IsCreditDocType(): Boolean
    begin
        exit("Document Type" in ["Document Type"::"Return Order","Document Type"::"Credit Memo"]);
    end;

    [Scope('Personalization')]
    procedure IsInvoiceDocType(): Boolean
    begin
        exit("Document Type" in ["Document Type"::Order,"Document Type"::Invoice]);
    end;

    local procedure IsReceivedFromOcr(): Boolean
    var
        IncomingDocument: Record "Incoming Document";
    begin
        GetPurchHeader;
        if not IncomingDocument.Get(PurchHeader."Incoming Document Entry No.") then
          exit(false);
        exit(IncomingDocument."OCR Status" = IncomingDocument."OCR Status"::Success);
    end;

    local procedure TestReturnFieldsZero()
    begin
        TestField("Return Qty. Shipped Not Invd.",0);
        TestField("Return Qty. Shipped",0);
        TestField("Return Shipment No.",'');
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

    [Scope('Personalization')]
    procedure TestItemFields(ItemNo: Code[20];VariantCode: Code[10];LocationCode: Code[10])
    begin
        TestField(Type,Type::Item);
        TestField("No.",ItemNo);
        TestField("Variant Code",VariantCode);
        TestField("Location Code",LocationCode);
    end;

    procedure ClearPurchaseHeader()
    begin
        Clear(PurchHeader);
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

    local procedure UpdateLineDiscPct()
    var
        LineDiscountPct: Decimal;
    begin
        if Round(Quantity * "Direct Unit Cost",Currency."Amount Rounding Precision") <> 0 then begin
          LineDiscountPct := Round(
              "Line Discount Amount" / Round(Quantity * "Direct Unit Cost",Currency."Amount Rounding Precision") * 100,
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
        if not PurchHeader."Prices Including VAT" and (Amount > 0) and (Amount < "Prepmt. Line Amount") then
          "Prepmt. Line Amount" := Amount;
        if PurchHeader."Prices Including VAT" and ("Amount Including VAT" > 0) and ("Amount Including VAT" < "Prepmt. Line Amount") then
          "Prepmt. Line Amount" := "Amount Including VAT";
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignFieldsForNo(var PurchLine: Record "Purchase Line";var xPurchLine: Record "Purchase Line";PurchHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignHeaderValues(var PurchLine: Record "Purchase Line";PurchHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignStdTxtValues(var PurchLine: Record "Purchase Line";StandardText: Record "Standard Text")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignGLAccountValues(var PurchLine: Record "Purchase Line";GLAccount: Record "G/L Account")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignItemValues(var PurchLine: Record "Purchase Line";Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignItemChargeValues(var PurchLine: Record "Purchase Line";ItemCharge: Record "Item Charge")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignFixedAssetValues(var PurchLine: Record "Purchase Line";FixedAsset: Record "Fixed Asset")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignItemUOM(var PurchLine: Record "Purchase Line";Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateDirectUnitCost(var PurchLine: Record "Purchase Line";xPurchLine: Record "Purchase Line";CalledByFieldNo: Integer;CurrFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateDirectUnitCost(var PurchLine: Record "Purchase Line";xPurchLine: Record "Purchase Line";CalledByFieldNo: Integer;CurrFieldNo: Integer;var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeVerifyReservedQty(var PurchLine: Record "Purchase Line";xPurchLine: Record "Purchase Line";CalledByFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitHeaderDefaults(var PurchLine: Record "Purchase Line";PurchHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitOutstandingAmount(var PurchLine: Record "Purchase Line";xPurchLine: Record "Purchase Line";PurchHeader: Record "Purchase Header";Currency: Record Currency)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitQtyToInvoice(var PurchLine: Record "Purchase Line";CurrFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitQtyToShip(var PurchLine: Record "Purchase Line";CurrFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitQtyToReceive(var PurchLine: Record "Purchase Line";CurrFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetDefaultQuantity(var PurchLine: Record "Purchase Line";var xPurchLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalcVATAmountLines(var PurchHeader: Record "Purchase Header";var PurchLine: Record "Purchase Line";var VATAmountLine: Record "VAT Amount Line";QtyType: Option General,Invoicing,Shipping)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateDimTableIDs(var PurchLine: Record "Purchase Line";FieldNo: Integer;var TableID: array [10] of Integer;var No: array [10] of Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetLineAmountToHandle(PurchLine: Record "Purchase Line";QtyToHandle: Decimal;var LineAmount: Decimal;var LineDiscAmount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateAmounts(var PurchLine: Record "Purchase Line";var xPurchLine: Record "Purchase Line";CurrFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateAmountsDone(var PurchLine: Record "Purchase Line";var xPurchLine: Record "Purchase Line";CurrFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateUnitCost(var PurchLine: Record "Purchase Line";xPurchLine: Record "Purchase Line";PurchHeader: Record "Purchase Header";Item: Record Item;StockkeepingUnit: Record "Stockkeeping Unit";Currency: Record Currency;GLSetup: Record "General Ledger Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateJobPrices(var PurchLine: Record "Purchase Line";JobJnlLine: Record "Job Journal Line";PurchRcptLine: Record "Purch. Rcpt. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateWithWarehouseReceive(PurchaseHeader: Record "Purchase Header";var PurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateVATOnLines(var PurchHeader: Record "Purchase Header";var PurchLine: Record "Purchase Line";var VATAmountLine: Record "VAT Amount Line";QtyType: Option General,Invoicing,Shipping)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateTotalAmounts(var PurchaseLine: Record "Purchase Line";PurchaseLine2: Record "Purchase Line";var TotalAmount: Decimal;var TotalAmountInclVAT: Decimal;var TotalLineAmount: Decimal;var TotalInvDiscAmount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeJobTaskIsSet(PurchLine: Record "Purchase Line";var IsJobLine: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateTempJobJnlLine(var JobJournalLine: Record "Job Journal Line";PurchLine: Record "Purchase Line";xPurchLine: Record "Purchase Line";GetPrices: Boolean;CurrFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateTypeOnCopyFromTempPurchLine(var PurchLine: Record "Purchase Line";TempPurchaseLine: Record "Purchase Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateNoOnCopyFromTempPurchLine(var PurchLine: Record "Purchase Line";TempPurchaseLine: Record "Purchase Line" temporary)
    begin
    end;

    procedure AssignedItemCharge(): Boolean
    begin
        exit((Type = Type::"Charge (Item)") and ("No." <> '') and ("Qty. to Assign" < Quantity));
    end;

    procedure ShowDeferralSchedule()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.Get("Document Type","Document No.");
        ShowDeferrals(PurchaseHeader."Posting Date",PurchaseHeader."Currency Code");
    end;
}

