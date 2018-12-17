page 5157 "Customer Template Card"
{
    // version NAVW113.00

    Caption = 'Customer Template Card';
    PageType = Card;
    SourceTable = "Customer Template";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code";Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for the customer template. You can set up as many codes as you want. The code must be unique. You cannot have the same code twice in one table.';
                }
                field(Description;Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the customer template.';
                }
                field("Contact Type";"Contact Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the contact type of the customer template.';
                }
                field("Country/Region Code";"Country/Region Code")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the country/region of the address.';
                }
                field("Territory Code";"Territory Code")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the territory code for the customer template.';
                }
                field("Currency Code";"Currency Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the currency code for the customer template.';
                }
                field("Gen. Bus. Posting Group";"Gen. Bus. Posting Group")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the vendor''s or customer''s trade type to link transactions made for this business partner with the appropriate general ledger account according to the general posting setup.';
                }
                field("VAT Bus. Posting Group";"VAT Bus. Posting Group")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the VAT specification of the involved customer or vendor to link transactions made for this record with the appropriate general ledger account according to the VAT posting setup.';
                }
                field("Customer Posting Group";"Customer Posting Group")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies a code for the customer posting group to which the customer template will belong. To see the customer posting group codes in the Customer Posting Groups window, click the field.';
                }
                field("Customer Price Group";"Customer Price Group")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies a code for the customer price group to which the customer template will belong. To see the price group codes in the Customer Price Groups window, click the field.';
                }
                field("Customer Disc. Group";"Customer Disc. Group")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the code for the customer discount group to which the customer template will belong. To see the customer discount group codes in the Customer Discount Group table, click the field.';
                }
                field("Allow Line Disc.";"Allow Line Disc.")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies that a line discount is calculated when the sales price is offered.';
                }
                field("Invoice Disc. Code";"Invoice Disc. Code")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the invoice discount code for the customer template.';
                }
                field("Prices Including VAT";"Prices Including VAT")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies if the Unit Price and Line Amount fields on document lines should be shown with or without VAT.';
                }
                field("Payment Terms Code";"Payment Terms Code")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies a formula that calculates the payment due date, payment discount date, and payment discount amount.';
                }
                field("Payment Method Code";"Payment Method Code")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies how to make payment, such as with bank transfer, cash, or check.';
                }
                field("Shipment Method Code";"Shipment Method Code")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the delivery conditions of the related shipment, such as free on board (FOB).';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207;Links)
            {
                Visible = false;
            }
            systempart(Control1905767507;Notes)
            {
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Customer Template")
            {
                Caption = '&Customer Template';
                Image = Template;
                action(Dimensions)
                {
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    RunObject = Page "Default Dimensions";
                    RunPageLink = "Table ID"=CONST(5105),
                                  "No."=FIELD(Code);
                    ShortCutKey = 'Shift+Ctrl+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';
                }
            }
            group("S&ales")
            {
                Caption = 'S&ales';
                Image = Sales;
                action("Invoice &Discounts")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'Invoice &Discounts';
                    Image = CalculateInvoiceDiscount;
                    RunObject = Page "Cust. Invoice Discounts";
                    RunPageLink = Code=FIELD("Invoice Disc. Code");
                    ToolTip = 'Set up different discounts that are applied to invoices for the customer. An invoice discount is automatically granted to the customer when the total on a sales invoice exceeds a certain amount.';
                }
            }
        }
    }
}

