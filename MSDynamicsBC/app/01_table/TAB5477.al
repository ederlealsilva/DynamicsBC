table 5477 "Purch. Inv. Entity Aggregate"
{
    // version NAVW113.00

    Caption = 'Purch. Inv. Entity Aggregate';

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
            NotBlank = true;
            TableRelation = Vendor;

            trigger OnValidate()
            begin
                UpdateVendorId;
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
        field(23;"Payment Terms Code";Code[10])
        {
            Caption = 'Payment Terms Code';
            TableRelation = "Payment Terms";
        }
        field(24;"Due Date";Date)
        {
            Caption = 'Due Date';
        }
        field(27;"Shipment Method Code";Code[10])
        {
            Caption = 'Shipment Method Code';
            TableRelation = "Shipment Method";
        }
        field(31;"Vendor Posting Group";Code[20])
        {
            Caption = 'Vendor Posting Group';
            TableRelation = "Vendor Posting Group";
        }
        field(32;"Currency Code";Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(35;"Prices Including VAT";Boolean)
        {
            Caption = 'Prices Including VAT';
        }
        field(43;"Purchaser Code";Code[20])
        {
            Caption = 'Purchaser Code';
            TableRelation = "Salesperson/Purchaser";
        }
        field(44;"Order No.";Code[20])
        {
            AccessByPermission = TableData "Purch. Rcpt. Header"=R;
            Caption = 'Order No.';

            trigger OnValidate()
            begin
                UpdateOrderId;
            end;
        }
        field(56;"Recalculate Invoice Disc.";Boolean)
        {
            CalcFormula = Exist("Purchase Line" WHERE ("Document Type"=FIELD("Document Type"),
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
        field(68;"Vendor Invoice No.";Code[35])
        {
            Caption = 'Vendor Invoice No.';
        }
        field(79;"Buy-from Vendor Name";Text[50])
        {
            Caption = 'Buy-from Vendor Name';
            TableRelation = Vendor.Name;
            ValidateTableRelation = false;
        }
        field(81;"Buy-from Address";Text[50])
        {
            Caption = 'Buy-from Address';
        }
        field(82;"Buy-from Address 2";Text[50])
        {
            Caption = 'Buy-from Address 2';
        }
        field(83;"Buy-from City";Text[30])
        {
            Caption = 'Buy-from City';
            TableRelation = IF ("Buy-from Country/Region Code"=CONST('')) "Post Code".City
                            ELSE IF ("Buy-from Country/Region Code"=FILTER(<>'')) "Post Code".City WHERE ("Country/Region Code"=FIELD("Buy-from Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(84;"Buy-from Contact";Text[50])
        {
            Caption = 'Buy-from Contact';
        }
        field(88;"Buy-from Post Code";Code[20])
        {
            Caption = 'Buy-from Post Code';
            TableRelation = IF ("Buy-from Country/Region Code"=CONST('')) "Post Code"
                            ELSE IF ("Buy-from Country/Region Code"=FILTER(<>'')) "Post Code" WHERE ("Country/Region Code"=FIELD("Buy-from Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(89;"Buy-from County";Text[30])
        {
            CaptionClass = '5,1,' + "Buy-from Country/Region Code";
            Caption = 'Buy-from County';
        }
        field(90;"Buy-from Country/Region Code";Code[10])
        {
            Caption = 'Buy-from Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(99;"Document Date";Date)
        {
            Caption = 'Document Date';
        }
        field(1304;"Vendor Ledger Entry No.";Integer)
        {
            Caption = 'Vendor Ledger Entry No.';
            TableRelation = "Vendor Ledger Entry"."Entry No.";
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(1305;"Invoice Discount Amount";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Invoice Discount Amount';
        }
        field(5052;"Buy-from Contact No.";Code[20])
        {
            Caption = 'Buy-from Contact No.';
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
        field(9624;"Discount Applied Before Tax";Boolean)
        {
            Caption = 'Discount Applied Before Tax';
        }
        field(9630;"Last Modified Date Time";DateTime)
        {
            Caption = 'Last Modified Date Time';
            Editable = false;
        }
        field(9631;"Vendor Id";Guid)
        {
            Caption = 'Vendor Id';
            TableRelation = Vendor.Id;

            trigger OnValidate()
            begin
                UpdateVendorNo;
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
    }

    keys
    {
        key(Key1;"No.",Posted)
        {
        }
        key(Key2;Id)
        {
        }
        key(Key3;"Vendor Ledger Entry No.")
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
          Error(CannotModifyPostedInvioceErr);

        "Last Modified Date Time" := CurrentDateTime;
        UpdateReferencedRecordIds;
    end;

    var
        CannotChangeNumberOnNonPostedErr: Label 'The number of the invoice can not be changed.';
        CannotModifyPostedInvioceErr: Label 'The invoice has been posted and can no longer be modified.', Locked=true;
        IsRenameAllowed: Boolean;

    local procedure UpdateVendorNo()
    var
        Vendor: Record Vendor;
    begin
        if IsNullGuid("Vendor Id") then
          exit;

        Vendor.SetRange(Id,"Vendor Id");
        if not Vendor.FindFirst then
          exit;

        "Buy-from Vendor No." := Vendor."No.";
    end;

    local procedure UpdateVendorId()
    var
        Vendor: Record Vendor;
    begin
        if "Buy-from Vendor No." = '' then begin
          Clear("Vendor Id");
          exit;
        end;

        if not Vendor.Get("Buy-from Vendor No.") then
          exit;

        "Vendor Id" := Vendor.Id;
    end;

    local procedure UpdateOrderNo()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        if IsNullGuid("Order Id") then
          exit;

        PurchaseHeader.SetRange(Id,"Order Id");
        PurchaseHeader.SetRange("Document Type",PurchaseHeader."Document Type"::Order);
        if not PurchaseHeader.FindFirst then
          exit;

        "Order No." := PurchaseHeader."No.";
    end;

    local procedure UpdateOrderId()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        if not PurchaseHeader.Get(PurchaseHeader."Document Type"::Order,"Order No.") then
          exit;

        "Order Id" := PurchaseHeader.Id;
    end;

    procedure UpdateReferencedRecordIds()
    begin
        UpdateVendorId;

        if ("Order No." <> '') and IsNullGuid("Order Id") then
          UpdateOrderId;
    end;

    procedure SetIsRenameAllowed(RenameAllowed: Boolean)
    begin
        IsRenameAllowed := RenameAllowed;
    end;
}

