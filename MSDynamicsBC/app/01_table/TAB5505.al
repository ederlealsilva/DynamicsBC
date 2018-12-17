table 5505 "Sales Quote Entity Buffer"
{
    // version NAVW113.00

    Caption = 'Sales Quote Entity Buffer';
    ReplicateData = false;

    fields
    {
        field(1;"Document Type";Option)
        {
            Caption = 'Document Type';
            DataClassification = SystemMetadata;
            InitValue = Invoice;
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        }
        field(2;"Sell-to Customer No.";Code[20])
        {
            Caption = 'Sell-to Customer No.';
            DataClassification = SystemMetadata;
            NotBlank = true;
            TableRelation = Customer;

            trigger OnValidate()
            begin
                UpdateCustomerId;
            end;
        }
        field(3;"No.";Code[20])
        {
            Caption = 'No.';
            DataClassification = SystemMetadata;
        }
        field(11;"Your Reference";Text[35])
        {
            Caption = 'Your Reference';
            DataClassification = SystemMetadata;
        }
        field(20;"Posting Date";Date)
        {
            Caption = 'Posting Date';
            DataClassification = SystemMetadata;
        }
        field(23;"Payment Terms Code";Code[10])
        {
            Caption = 'Payment Terms Code';
            DataClassification = SystemMetadata;
            TableRelation = "Payment Terms";

            trigger OnValidate()
            begin
                UpdatePaymentTermsId;
            end;
        }
        field(24;"Due Date";Date)
        {
            Caption = 'Due Date';
            DataClassification = SystemMetadata;
        }
        field(27;"Shipment Method Code";Code[10])
        {
            Caption = 'Shipment Method Code';
            DataClassification = SystemMetadata;
            TableRelation = "Shipment Method";

            trigger OnValidate()
            begin
                UpdateShipmentMethodId;
            end;
        }
        field(31;"Customer Posting Group";Code[20])
        {
            Caption = 'Customer Posting Group';
            DataClassification = SystemMetadata;
            TableRelation = "Customer Posting Group";
        }
        field(32;"Currency Code";Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = SystemMetadata;
            TableRelation = Currency;

            trigger OnValidate()
            begin
                UpdateCurrencyId;
            end;
        }
        field(35;"Prices Including VAT";Boolean)
        {
            Caption = 'Prices Including VAT';
            DataClassification = SystemMetadata;
        }
        field(43;"Salesperson Code";Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = SystemMetadata;
            TableRelation = "Salesperson/Purchaser";
        }
        field(56;"Recalculate Invoice Disc.";Boolean)
        {
            CalcFormula = Exist("Sales Line" WHERE ("Document Type"=CONST(Invoice),
                                                    "Document No."=FIELD("No."),
                                                    "Recalculate Invoice Disc."=CONST(true)));
            Caption = 'Recalculate Invoice Disc.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(60;Amount;Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount';
            DataClassification = SystemMetadata;
        }
        field(61;"Amount Including VAT";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount Including VAT';
            DataClassification = SystemMetadata;
        }
        field(70;"VAT Registration No.";Text[20])
        {
            Caption = 'VAT Registration No.';
            DataClassification = SystemMetadata;
        }
        field(79;"Sell-to Customer Name";Text[50])
        {
            Caption = 'Sell-to Customer Name';
            DataClassification = SystemMetadata;
            TableRelation = Customer.Name;
            ValidateTableRelation = false;
        }
        field(81;"Sell-to Address";Text[50])
        {
            Caption = 'Sell-to Address';
            DataClassification = SystemMetadata;
        }
        field(82;"Sell-to Address 2";Text[50])
        {
            Caption = 'Sell-to Address 2';
            DataClassification = SystemMetadata;
        }
        field(83;"Sell-to City";Text[30])
        {
            Caption = 'Sell-to City';
            DataClassification = SystemMetadata;
            TableRelation = IF ("Sell-to Country/Region Code"=CONST('')) "Post Code".City
                            ELSE IF ("Sell-to Country/Region Code"=FILTER(<>'')) "Post Code".City WHERE ("Country/Region Code"=FIELD("Sell-to Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(84;"Sell-to Contact";Text[50])
        {
            Caption = 'Sell-to Contact';
            DataClassification = SystemMetadata;
        }
        field(88;"Sell-to Post Code";Code[20])
        {
            Caption = 'Sell-to Post Code';
            DataClassification = SystemMetadata;
            TableRelation = IF ("Sell-to Country/Region Code"=CONST('')) "Post Code"
                            ELSE IF ("Sell-to Country/Region Code"=FILTER(<>'')) "Post Code" WHERE ("Country/Region Code"=FIELD("Sell-to Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(89;"Sell-to County";Text[30])
        {
            CaptionClass = '5,1,' + "Sell-to Country/Region Code";
            Caption = 'Sell-to County';
            DataClassification = SystemMetadata;
        }
        field(90;"Sell-to Country/Region Code";Code[10])
        {
            Caption = 'Sell-to Country/Region Code';
            DataClassification = SystemMetadata;
            TableRelation = "Country/Region";
        }
        field(99;"Document Date";Date)
        {
            Caption = 'Document Date';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                Validate("Posting Date","Document Date");
            end;
        }
        field(100;"External Document No.";Code[35])
        {
            Caption = 'External Document No.';
            DataClassification = SystemMetadata;
        }
        field(114;"Tax Area Code";Code[20])
        {
            Caption = 'Tax Area Code';
            DataClassification = SystemMetadata;
            TableRelation = "Tax Area";
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                if IsUsingVAT then
                  Error(SalesTaxOnlyFieldErr,FieldCaption("Tax Area Code"));
            end;
        }
        field(115;"Tax Liable";Boolean)
        {
            Caption = 'Tax Liable';
            DataClassification = SystemMetadata;
        }
        field(116;"VAT Bus. Posting Group";Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = SystemMetadata;
            TableRelation = "VAT Business Posting Group";

            trigger OnValidate()
            begin
                if not IsUsingVAT then
                  Error(VATOnlyFieldErr,FieldCaption("VAT Bus. Posting Group"));
            end;
        }
        field(121;"Invoice Discount Calculation";Option)
        {
            Caption = 'Invoice Discount Calculation';
            DataClassification = SystemMetadata;
            OptionCaption = 'None,%,Amount';
            OptionMembers = "None","%",Amount;
        }
        field(122;"Invoice Discount Value";Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Invoice Discount Value';
            DataClassification = SystemMetadata;
        }
        field(152;"Quote Valid Until Date";Date)
        {
            Caption = 'Quote Valid Until Date';
            DataClassification = SystemMetadata;
        }
        field(153;"Quote Sent to Customer";DateTime)
        {
            Caption = 'Quote Sent to Customer';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(154;"Quote Accepted";Boolean)
        {
            Caption = 'Quote Accepted';
            DataClassification = SystemMetadata;
        }
        field(155;"Quote Accepted Date";Date)
        {
            Caption = 'Quote Accepted Date';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(167;"Last Email Sent Status";Option)
        {
            Caption = 'Last Email Sent Status';
            DataClassification = SystemMetadata;
            ObsoleteReason = 'Do not store the sent status in the entity but calculate it on a fly to avoid etag change after quote sending.';
            ObsoleteState = Removed;
            OptionCaption = 'Not Sent,In Process,Finished,Error', Locked=true;
            OptionMembers = "Not Sent","In Process",Finished,Error;
        }
        field(1304;"Cust. Ledger Entry No.";Integer)
        {
            Caption = 'Cust. Ledger Entry No.';
            DataClassification = SystemMetadata;
            TableRelation = "Cust. Ledger Entry"."Entry No.";
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(1305;"Invoice Discount Amount";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Invoice Discount Amount';
            DataClassification = SystemMetadata;
        }
        field(5052;"Sell-to Contact No.";Code[20])
        {
            Caption = 'Sell-to Contact No.';
            DataClassification = SystemMetadata;
            TableRelation = Contact;
        }
        field(8000;Id;Guid)
        {
            Caption = 'Id';
            DataClassification = SystemMetadata;
        }
        field(9600;"Total Tax Amount";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Total Tax Amount';
            DataClassification = SystemMetadata;
        }
        field(9601;Status;Option)
        {
            Caption = 'Status';
            DataClassification = SystemMetadata;
            OptionCaption = 'Draft,Sent,Accepted', Locked=true;
            OptionMembers = Draft,Sent,Accepted,"Expired ";
        }
        field(9602;Posted;Boolean)
        {
            Caption = 'Posted';
            DataClassification = SystemMetadata;
        }
        field(9603;"Subtotal Amount";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Subtotal Amount';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(9624;"Discount Applied Before Tax";Boolean)
        {
            Caption = 'Discount Applied Before Tax';
            DataClassification = SystemMetadata;
        }
        field(9630;"Last Modified Date Time";DateTime)
        {
            Caption = 'Last Modified Date Time';
            DataClassification = SystemMetadata;
        }
        field(9631;"Customer Id";Guid)
        {
            Caption = 'Customer Id';
            DataClassification = SystemMetadata;
            TableRelation = Customer.Id;

            trigger OnValidate()
            begin
                UpdateCustomerNo;
            end;
        }
        field(9633;"Contact Graph Id";Text[250])
        {
            Caption = 'Contact Graph Id';
            DataClassification = SystemMetadata;
        }
        field(9634;"Currency Id";Guid)
        {
            Caption = 'Currency Id';
            DataClassification = SystemMetadata;
            TableRelation = Currency.Id;

            trigger OnValidate()
            begin
                UpdateCurrencyCode;
            end;
        }
        field(9635;"Payment Terms Id";Guid)
        {
            Caption = 'Payment Terms Id';
            DataClassification = SystemMetadata;
            TableRelation = "Payment Terms".Id;

            trigger OnValidate()
            begin
                UpdatePaymentTermsCode;
            end;
        }
        field(9636;"Shipment Method Id";Guid)
        {
            Caption = 'Shipment Method Id';
            DataClassification = SystemMetadata;
            TableRelation = "Shipment Method".Id;

            trigger OnValidate()
            begin
                UpdateShipmentMethodCode;
            end;
        }
        field(9637;"Tax Area ID";Guid)
        {
            Caption = 'Tax Area ID';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if IsUsingVAT then
                  UpdateVATBusinessPostingGroupCode
                else
                  UpdateTaxAreaCode;
            end;
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
        key(Key2;Id)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Last Modified Date Time" := CurrentDateTime;
        UpdateReferencedRecordIds;
    end;

    trigger OnModify()
    begin
        "Last Modified Date Time" := CurrentDateTime;
        UpdateReferencedRecordIds;
    end;

    trigger OnRename()
    begin
        "Last Modified Date Time" := CurrentDateTime;
        UpdateReferencedRecordIds;
    end;

    var
        SalesTaxOnlyFieldErr: Label 'Current Tax setup is set to VAT. Field %1 can only be used with Sales Tax.', Comment='%1 - Name of the field, e.g. Tax Liable, Tax Group Code, VAT Business posting group';
        VATOnlyFieldErr: Label 'Current Tax setup is set to Sales Tax. Field %1 can only be used with VAT.', Comment='%1 - Name of the field, e.g. Tax Liable, Tax Group Code, VAT Business posting group';

    local procedure UpdateCustomerId()
    var
        Customer: Record Customer;
    begin
        if "Sell-to Customer No." = '' then begin
          Clear("Customer Id");
          exit;
        end;

        if not Customer.Get("Sell-to Customer No.") then
          exit;

        "Customer Id" := Customer.Id;
    end;

    procedure UpdateCurrencyId()
    var
        Currency: Record Currency;
    begin
        if "Currency Code" = '' then begin
          Clear("Currency Id");
          exit;
        end;

        if not Currency.Get("Currency Code") then
          exit;

        "Currency Id" := Currency.Id;
    end;

    procedure UpdatePaymentTermsId()
    var
        PaymentTerms: Record "Payment Terms";
    begin
        if "Payment Terms Code" = '' then begin
          Clear("Payment Terms Id");
          exit;
        end;

        if not PaymentTerms.Get("Payment Terms Code") then
          exit;

        "Payment Terms Id" := PaymentTerms.Id;
    end;

    procedure UpdateShipmentMethodId()
    var
        ShipmentMethod: Record "Shipment Method";
    begin
        if "Shipment Method Code" = '' then begin
          Clear("Shipment Method Id");
          exit;
        end;

        if not ShipmentMethod.Get("Shipment Method Code") then
          exit;

        "Shipment Method Id" := ShipmentMethod.Id;
    end;

    local procedure UpdateCustomerNo()
    var
        Customer: Record Customer;
    begin
        if not IsNullGuid("Customer Id") then begin
          Customer.SetRange(Id,"Customer Id");
          Customer.FindFirst;
        end;

        Validate("Sell-to Customer No.",Customer."No.");
    end;

    local procedure UpdateCurrencyCode()
    var
        Currency: Record Currency;
    begin
        if not IsNullGuid("Currency Id") then begin
          Currency.SetRange(Id,"Currency Id");
          Currency.FindFirst;
        end;

        Validate("Currency Code",Currency.Code);
    end;

    local procedure UpdatePaymentTermsCode()
    var
        PaymentTerms: Record "Payment Terms";
    begin
        if not IsNullGuid("Payment Terms Id") then begin
          PaymentTerms.SetRange(Id,"Payment Terms Id");
          PaymentTerms.FindFirst;
        end;

        Validate("Payment Terms Code",PaymentTerms.Code);
    end;

    local procedure UpdateShipmentMethodCode()
    var
        ShipmentMethod: Record "Shipment Method";
    begin
        if not IsNullGuid("Shipment Method Id") then begin
          ShipmentMethod.SetRange(Id,"Shipment Method Id");
          ShipmentMethod.FindFirst;
        end;

        Validate("Shipment Method Code",ShipmentMethod.Code);
    end;

    procedure UpdateReferencedRecordIds()
    begin
        UpdateCustomerId;
        UpdateCurrencyId;
        UpdatePaymentTermsId;
        UpdateShipmentMethodId;

        UpdateGraphContactId;
        UpdateTaxAreaId;
    end;

    procedure UpdateGraphContactId()
    var
        Contact: Record Contact;
        GraphIntegrationRecord: Record "Graph Integration Record";
        GraphID: Text[250];
    begin
        if "Sell-to Contact No." = '' then begin
          Clear("Contact Graph Id");
          exit;
        end;

        if not Contact.Get("Sell-to Contact No.") then
          exit;

        if not GraphIntegrationRecord.FindIDFromRecordID(Contact.RecordId,GraphID) then
          exit;

        "Contact Graph Id" := GraphID;
    end;

    local procedure UpdateTaxAreaId()
    var
        TaxArea: Record "Tax Area";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
    begin
        if IsUsingVAT then begin
          if "VAT Bus. Posting Group" <> '' then begin
            VATBusinessPostingGroup.SetRange(Code,"VAT Bus. Posting Group");
            if VATBusinessPostingGroup.FindFirst then begin
              "Tax Area ID" := VATBusinessPostingGroup.Id;
              exit;
            end;
          end;

          Clear("Tax Area ID");
          exit;
        end;

        if "Tax Area Code" <> '' then begin
          TaxArea.SetRange(Code,"Tax Area Code");
          if TaxArea.FindFirst then begin
            "Tax Area ID" := TaxArea.Id;
            exit;
          end;
        end;

        Clear("Tax Area ID");
    end;

    local procedure UpdateTaxAreaCode()
    var
        TaxArea: Record "Tax Area";
    begin
        if not IsNullGuid("Tax Area ID") then begin
          TaxArea.SetRange(Id,"Tax Area ID");
          if TaxArea.FindFirst then begin
            Validate("Tax Area Code",TaxArea.Code);
            exit;
          end;
        end;

        Clear("Tax Area Code");
    end;

    local procedure UpdateVATBusinessPostingGroupCode()
    var
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
    begin
        if not IsNullGuid("Tax Area ID") then begin
          VATBusinessPostingGroup.SetRange(Id,"Tax Area ID");
          if VATBusinessPostingGroup.FindFirst then begin
            Validate("VAT Bus. Posting Group",VATBusinessPostingGroup.Code);
            exit;
          end;
        end;

        Clear("VAT Bus. Posting Group");
    end;

    procedure IsUsingVAT(): Boolean
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        exit(GeneralLedgerSetup.UseVat);
    end;

    procedure GetParentRecordNativeInvoicing(var SalesHeader: Record "Sales Header"): Boolean
    begin
        SalesHeader.SetAutoCalcFields("Last Email Sent Time","Last Email Sent Status","Work Description");
        exit(GetParentRecord(SalesHeader));
    end;

    local procedure GetParentRecord(var SalesHeader: Record "Sales Header"): Boolean
    var
        MainRecordFound: Boolean;
    begin
        MainRecordFound := SalesHeader.Get(SalesHeader."Document Type"::Quote,"No.");
        exit(MainRecordFound);
    end;
}

