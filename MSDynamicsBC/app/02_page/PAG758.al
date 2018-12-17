page 758 "Payment Method Translations"
{
    // version NAVW113.00

    Caption = 'Payment Method Translations';
    DataCaptionFields = "Payment Method Code";
    PageType = List;
    SourceTable = "Payment Method Translation";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Language Code";"Language Code")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the language that is used when translating specified text on documents to business partners abroad, such as an item description on an order confirmation.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the translation of the payment method.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6;Links)
            {
                Visible = false;
            }
            systempart(Control7;Notes)
            {
                Visible = false;
            }
        }
    }

    actions
    {
    }
}

