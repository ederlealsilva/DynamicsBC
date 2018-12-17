page 1281 "Bank Data Conv. Pmt. Types"
{
    // version NAVW110.0

    Caption = 'Bank Data Conv. Pmt. Types';
    PageType = List;
    SourceTable = "Bank Data Conversion Pmt. Type";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the code of the payment type. You set up payment types for a payment method so that the bank data conversion service can identify the payment type when exporting payments. The payment types are displayed in the Bank Data Conv. Pmt. Types window.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the description of the payment type. You set up payment types for a payment method so that the bank data conversion service can identify the payment type when exporting payments. The payment types are displayed in the Bank Data Conv. Pmt. Types window.';
                }
            }
        }
    }

    actions
    {
    }
}

