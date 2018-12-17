table 5495 "Sales Order Entity Buffer"
{
    // version NAVW113.00

    Caption = 'Sales Order Entity Buffer';
    ReplicateData = false;

    fields
    {
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
        }
        field(100;"External Document No.";Code[35])
        {
            Caption = 'External Document No.';
            DataClassification = SystemMetadata;
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
        field(5052;"Sell-To Contact No.";Code[20])
        {
            Caption = 'Sell-To Contact No.';
            DataClassification = SystemMetadata;
            TableRelation = Contact;
        }
        field(5750;"Shipping Advice";Option)
        {
            AccessByPermission = TableData "Sales Shipment Header"=R;
            Caption = 'Shipping Advice';
            DataClassification = SystemMetadata;
            OptionCaption = 'Partial,Complete';
            OptionMembers = Partial,Complete;
        }
        field(5752;"Completely Shipped";Boolean)
        {
            Caption = 'Completely Shipped';
            DataClassification = SystemMetadata;
        }
        field(5790;"Requested Delivery Date";Date)
        {
            AccessByPermission = TableData "Order Promising Line"=R;
            Caption = 'Requested Delivery Date';
            DataClassification = SystemMetadata;
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
            OptionCaption = 'Draft,In Review,Open', Locked=true;
            OptionMembers = Draft,"In Review",Open;
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
    }

    keys
    {
        key(Key1;"No.")
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
        "Last Modified Date Time" := CurrentDateTime;
        UpdateReferencedRecordIds;
    end;

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

    procedure UpdateReferencedRecordIds()
    begin
        UpdateCustomerId;
        UpdateCurrencyId;
        UpdatePaymentTermsId;

        UpdateGraphContactId;
    end;

    procedure UpdateGraphContactId()
    var
        Contact: Record Contact;
        GraphIntegrationRecord: Record "Graph Integration Record";
        GraphID: Text[250];
    begin
        if "Sell-To Contact No." = '' then begin
          Clear("Contact Graph Id");
          exit;
        end;

        if not Contact.Get("Sell-To Contact No.") then
          exit;

        if not GraphIntegrationRecord.FindIDFromRecordID(Contact.RecordId,GraphID) then
          exit;

        "Contact Graph Id" := GraphID;
    end;
}

