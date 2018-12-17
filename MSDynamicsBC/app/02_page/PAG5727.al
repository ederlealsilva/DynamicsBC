page 5727 "Purchasing Codes"
{
    // version NAVW113.00

    ApplicationArea = Suite;
    Caption = 'Purchasing Codes';
    PageType = List;
    SourceTable = Purchasing;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code";Code)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies a code for a purchasing activity.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies a description of the purchasing activity specified by the code.';
                }
                field("Drop Shipment";"Drop Shipment")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies if your vendor ships the items directly to your customer.';
                }
                field("Special Order";"Special Order")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies that this purchase activity includes arranging for a special order.';
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

