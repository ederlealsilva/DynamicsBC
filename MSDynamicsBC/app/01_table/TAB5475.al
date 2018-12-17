table 5475 "Sales Invoice Entity Aggregate"
{
    // version NAVW113.00

    Caption = 'Sales Invoice Entity Aggregate';

    fields
    {
        field(1;"Document Type";Option)
        {
            Caption = 'Document Type';
            InitValue = Invoice;
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        }
        field(2;"Sell-to Customer No.";Code[20])
        {
            Caption = 'Sell-to Customer No.';
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
        }
        field(11;"Your Reference";Text[35])
        {
            Caption = 'Your Reference';
        }
        field(20;"Posting Date";Date)
        {
            Caption = 'Posting Date';
        }
        field(23;"Payment Terms Code";Code[10])
        {
            Caption = 'Payment Terms Code';
            TableRelation = "Payment Terms";

            trigger OnValidate()
            begin
                UpdatePaymentTermsId;
            end;
        }
        field(24;"Due Date";Date)
        {
            Caption = 'Due Date';
        }
        field(27;"Shipment Method Code";Code[10])
        {
            Caption = 'Shipment Method Code';
            TableRelation = "Shipment Method";

            trigger OnValidate()
            begin
                UpdateShipmentMethodId;
            end;
        }
        field(31;"Customer Posting Group";Code[20])
        {
            Caption = 'Customer Posting Group';
            TableRelation = "Customer Posting Group";
        }
        field(32;"Currency Code";Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;

            trigger OnValidate()
            begin
                UpdateCurrencyId;
            end;
        }
        field(35;"Prices Including VAT";Boolean)
        {
            Caption = 'Prices Including VAT';
        }
        field(43;"Salesperson Code";Code[20])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser";
        }
        field(44;"Order No.";Code[20])
        {
            AccessByPermission = TableData "Sales Shipment Header"=R;
            Caption = 'Order No.';

            trigger OnValidate()
            begin
                UpdateOrderId;
            end;
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
        }
        field(61;"Amount Including VAT";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount Including VAT';
        }
        field(70;"VAT Registration No.";Text[20])
        {
            Caption = 'VAT Registration No.';
        }
        field(79;"Sell-to Customer Name";Text[50])
        {
            Caption = 'Sell-to Customer Name';
            TableRelation = Customer;
            ValidateTableRelation = false;
        }
        field(81;"Sell-to Address";Text[50])
        {
            Caption = 'Sell-to Address';
        }
        field(82;"Sell-to Address 2";Text[50])
        {
            Caption = 'Sell-to Address 2';
        }
        field(83;"Sell-to City";Text[30])
        {
            Caption = 'Sell-to City';
            TableRelation = IF ("Sell-to Country/Region Code"=CONST('')) "Post Code".City
                            ELSE IF ("Sell-to Country/Region Code"=FILTER(<>'')) "Post Code".City WHERE ("Country/Region Code"=FIELD("Sell-to Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(84;"Sell-to Contact";Text[50])
        {
            Caption = 'Sell-to Contact';
        }
        field(88;"Sell-to Post Code";Code[20])
        {
            Caption = 'Sell-to Post Code';
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
        }
        field(90;"Sell-to Country/Region Code";Code[10])
        {
            Caption = 'Sell-to Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(99;"Document Date";Date)
        {
            Caption = 'Document Date';

            trigger OnValidate()
            begin
                Validate("Posting Date","Document Date");
            end;
        }
        field(100;"External Document No.";Code[35])
        {
            Caption = 'External Document No.';
        }
        field(114;"Tax Area Code";Code[20])
        {
            Caption = 'Tax Area Code';
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
        }
        field(116;"VAT Bus. Posting Group";Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
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
            OptionCaption = 'None,%,Amount';
            OptionMembers = "None","%",Amount;
        }
        field(122;"Invoice Discount Value";Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Invoice Discount Value';
        }
        field(167;"Last Email Sent Status";Option)
        {
            Caption = 'Last Email Sent Status';
            ObsoleteReason = 'Do not store the sent status in the entity but calculate it on a fly to avoid etag change after invoice sending.';
            ObsoleteState = Removed;
            OptionCaption = 'Not Sent,In Process,Finished,Error', Locked=true;
            OptionMembers = "Not Sent","In Process",Finished,Error;
        }
        field(170;IsTest;Boolean)
        {
            Caption = 'IsTest';
        }
        field(1304;"Cust. Ledger Entry No.";Integer)
        {
            Caption = 'Cust. Ledger Entry No.';
            TableRelation = "Cust. Ledger Entry"."Entry No.";
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(1305;"Invoice Discount Amount";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Invoice Discount Amount';
        }
        field(5052;"Sell-to Contact No.";Code[20])
        {
            Caption = 'Sell-to Contact No.';
            TableRelation = Contact;
        }
        field(8000;Id;Guid)
        {
            Caption = 'Id';
        }
        field(9600;"Total Tax Amount";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Total Tax Amount';
        }
        field(9601;Status;Option)
        {
            Caption = 'Status';
            OptionCaption = ' ,Draft,In Review,Open,Paid,Canceled,Corrective', Locked=true;
            OptionMembers = " ",Draft,"In Review",Open,Paid,Canceled,Corrective;
        }
        field(9602;Posted;Boolean)
        {
            Caption = 'Posted';
        }
        field(9603;"Subtotal Amount";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Subtotal Amount';
            Editable = false;
        }
        field(9624;"Discount Applied Before Tax";Boolean)
        {
            Caption = 'Discount Applied Before Tax';
        }
        field(9630;"Last Modified Date Time";DateTime)
        {
            Caption = 'Last Modified Date Time';
            Editable = false;
        }
        field(9631;"Customer Id";Guid)
        {
            Caption = 'Customer Id';
            TableRelation = Customer.Id;

            trigger OnValidate()
            begin
                UpdateCustomerNo;
            end;
        }
        field(9632;"Order Id";Guid)
        {
            Caption = 'Order Id';

            trigger OnValidate()
            begin
                UpdateOrderNo;
            end;
        }
        field(9633;"Contact Graph Id";Text[250])
        {
            Caption = 'Contact Graph Id';
        }
        field(9634;"Currency Id";Guid)
        {
            Caption = 'Currency Id';
            TableRelation = Currency.Id;

            trigger OnValidate()
            begin
                UpdateCurrencyCode;
            end;
        }
        field(9635;"Payment Terms Id";Guid)
        {
            Caption = 'Payment Terms Id';
            TableRelation = "Payment Terms".Id;

            trigger OnValidate()
            begin
                UpdatePaymentTermsCode;
            end;
        }
        field(9636;"Shipment Method Id";Guid)
        {
            Caption = 'Shipment Method Id';
            TableRelation = "Shipment Method".Id;

            trigger OnValidate()
            begin
                UpdateShipmentMethodCode;
            end;
        }
        field(9637;"Tax Area ID";Guid)
        {
            Caption = 'Tax Area ID';

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
        key(Key1;"No.",Posted)
        {
        }
        key(Key2;Id)
        {
        }
        key(Key3;"Cust. Ledger Entry No.")
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
        if not Posted then
          Error(CannotChangeNumberOnNonPostedErr);

        if Posted and (not IsRenameAllowed) then
          Error(CannotModifyPostedInvoiceErr);

        "Last Modified Date Time" := CurrentDateTime;
        UpdateReferencedRecordIds;
    end;

    var
        CannotChangeNumberOnNonPostedErr: Label 'The number of the invoice can not be changed.';
        CannotModifyPostedInvoiceErr: Label 'The invoice has been posted and can no longer be modified.', Locked=true;
        IsRenameAllowed: Boolean;
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

    local procedure UpdateOrderId()
    var
        SalesHeader: Record "Sales Header";
    begin
        if not SalesHeader.Get(SalesHeader."Document Type"::Order,"Order No.") then
          exit;

        "Order Id" := SalesHeader.Id;
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

    local procedure UpdateOrderNo()
    var
        SalesHeader: Record "Sales Header";
    begin
        if IsNullGuid("Order Id") then begin
          Validate("Order No.",'');
          exit;
        end;

        SalesHeader.SetRange(Id,"Order Id");
        SalesHeader.SetRange("Document Type",SalesHeader."Document Type"::Order);

        // Order gets deleted after fullfiled, so do not blank the Order No
        if not SalesHeader.FindFirst then
          exit;

        Validate("Order No.",SalesHeader."No.");
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

        if ("Order No." <> '') and IsNullGuid("Order Id") then
          UpdateOrderId;

        UpdateGraphContactId;
        UpdateTaxAreaId;
    end;

    procedure UpdateGraphContactId()
    var
        contactFound: Boolean;
    begin
        if "Sell-to Contact No." = '' then
          contactFound := UpdateContactIdFromCustomer
        else
          contactFound := UpdateContactIdFromSellToContactNo;

        if not contactFound then
          Clear("Contact Graph Id");
    end;

    local procedure UpdateContactIdFromCustomer(): Boolean
    var
        Customer: Record Customer;
        Contact: Record Contact;
        GraphIntContact: Codeunit "Graph Int. - Contact";
        GraphID: Text[250];
    begin
        if IsNullGuid("Customer Id") then
          exit(false);

        Customer.SetRange(Id,"Customer Id");
        if not Customer.FindFirst then
          exit(false);

        if not GraphIntContact.FindGraphContactIdFromCustomer(GraphID,Customer,Contact) then
          exit(false);

        "Contact Graph Id" := GraphID;

        exit(true);
    end;

    local procedure UpdateContactIdFromSellToContactNo(): Boolean
    var
        Contact: Record Contact;
        GraphIntegrationRecord: Record "Graph Integration Record";
        GraphID: Text[250];
    begin
        if not Contact.Get("Sell-to Contact No.") then
          exit(false);

        if not GraphIntegrationRecord.FindIDFromRecordID(Contact.RecordId,GraphID) then
          exit(false);

        "Contact Graph Id" := GraphID;

        exit(true);
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

    procedure SetIsRenameAllowed(RenameAllowed: Boolean)
    begin
        IsRenameAllowed := RenameAllowed;
    end;

    procedure GetParentRecordNativeInvoicing(var SalesHeader: Record "Sales Header";var SalesInvoiceHeader: Record "Sales Invoice Header"): Boolean
    begin
        SalesInvoiceHeader.SetAutoCalcFields("Last Email Sent Time","Last Email Sent Status","Work Description");
        SalesHeader.SetAutoCalcFields("Last Email Sent Time","Last Email Sent Status","Work Description");

        exit(GetParentRecord(SalesHeader,SalesInvoiceHeader));
    end;

    local procedure GetParentRecord(var SalesHeader: Record "Sales Header";var SalesInvoiceHeader: Record "Sales Invoice Header"): Boolean
    var
        MainRecordFound: Boolean;
    begin
        if Posted then begin
          MainRecordFound := SalesInvoiceHeader.Get("No.");
          Clear(SalesHeader);
        end else begin
          MainRecordFound := SalesHeader.Get(SalesHeader."Document Type"::Invoice,"No.");
          Clear(SalesInvoiceHeader);
        end;

        exit(MainRecordFound);
    end;
}

