page 5910 "Service Costs"
{
    // version NAVW113.00

    ApplicationArea = Service;
    Caption = 'Service Costs';
    PageType = List;
    SourceTable = "Service Cost";
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
                    ApplicationArea = Service;
                    ToolTip = 'Specifies a code for the service cost.';
                }
                field("Cost Type";"Cost Type")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the cost type.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies a description of the service cost.';
                }
                field("Account No.";"Account No.")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the general ledger account number to which the service cost will be posted.';
                }
                field("Service Zone Code";"Service Zone Code")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the code of the service zone, to which travel applies if the Cost Type is Travel.';
                }
                field("Default Quantity";"Default Quantity")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the default quantity that is copied to the service lines containing this service cost.';
                }
                field("Unit of Measure Code";"Unit of Measure Code")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                field("Default Unit Cost";"Default Unit Cost")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the default unit cost that is copied to the service lines containing this service cost.';
                }
                field("Default Unit Price";"Default Unit Price")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the default unit price of the cost that is copied to the service lines containing this service cost.';
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

