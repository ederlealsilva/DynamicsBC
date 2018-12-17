page 406 "Transaction Specifications"
{
    // version NAVW113.00

    ApplicationArea = Basic,Suite;
    Caption = 'Transaction Specifications';
    PageType = List;
    SourceTable = "Transaction Specification";
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
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies a code for the transaction specification.';
                }
                field(Text;Text)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies a description of the transaction specification.';
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

