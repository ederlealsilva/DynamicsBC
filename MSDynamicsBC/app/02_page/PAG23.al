page 23 "Cust. Invoice Discounts"
{
    // version NAVW113.00

    Caption = 'Cust. Invoice Discounts';
    DataCaptionFields = "Code";
    PageType = List;
    SourceTable = "Cust. Invoice Disc.";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code";Code)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the contents of the Invoice Disc. Code field on the customer card.';
                    Visible = false;
                }
                field("Currency Code";"Currency Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the currency code for invoice discount terms.';
                }
                field("Minimum Amount";"Minimum Amount")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the minimum amount that the invoice must total for the discount to be granted or the service charge levied.';
                }
                field("Discount %";"Discount %")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the discount percentage that the customer can receive by buying for at least the minimum amount.';
                }
                field("Service Charge";"Service Charge")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the amount of the service charge that the customer will have to pay on a purchase of at least the amount in the Minimum Amount field.';
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
    }
}

