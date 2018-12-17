page 6055 "Service Contract Template"
{
    // version NAVW113.00

    Caption = 'Service Contract Template';
    PageType = Card;
    SourceTable = "Service Contract Template";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No.";"No.")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';

                    trigger OnAssistEdit()
                    begin
                        AssistEdit(Rec);
                    end;
                }
                field(Description;Description)
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies a description of the service contract.';
                }
                field("Contract Group Code";"Contract Group Code")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the contract group code of the service contract.';
                }
                field("Service Order Type";"Service Order Type")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the service order type assigned to service orders linked to this service contract.';
                }
                field("Default Service Period";"Default Service Period")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the default service period for the items in the contract.';
                }
                field("Price Update Period";"Price Update Period")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the price update period for this service contract.';
                }
                field("Default Response Time (Hours)";"Default Response Time (Hours)")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the default response time for the service contract created from this service contract template.';
                }
                field("Max. Labor Unit Price";"Max. Labor Unit Price")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the maximum unit price that can be set for a resource on lines for service orders associated with the service contract.';
                }
            }
            group(Invoice)
            {
                Caption = 'Invoice';
                field("Serv. Contract Acc. Gr. Code";"Serv. Contract Acc. Gr. Code")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the code associated with the service contract account group.';
                }
                field("Invoice Period";"Invoice Period")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the invoice period for the service contract.';
                }
                field("Price Inv. Increase Code";"Price Inv. Increase Code")
                {
                    ApplicationArea = Service;
                    Caption = 'Contract Increase Text';
                    ToolTip = 'Specifies all billable prices for the job task, expressed in the local currency.';
                }
                field(Prepaid;Prepaid)
                {
                    ApplicationArea = Service;
                    Enabled = PrepaidEnable;
                    ToolTip = 'Specifies that this service contract is prepaid.';

                    trigger OnValidate()
                    begin
                        PrepaidOnAfterValidate;
                    end;
                }
                field("Allow Unbalanced Amounts";"Allow Unbalanced Amounts")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies if the contents of the Calcd. Annual Amount field are copied into the Annual Amount field in the service contract or contract quote.';
                }
                field("Combine Invoices";"Combine Invoices")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies you want to combine invoices for this service contract with invoices for other service contracts with the same bill-to customer.';
                }
                field("Automatic Credit Memos";"Automatic Credit Memos")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies that a credit memo is created when you remove a contract line from the service contract under certain conditions.';
                }
                field("Contract Lines on Invoice";"Contract Lines on Invoice")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies you want contract lines to appear as text on the invoice.';
                }
                field("Invoice after Service";"Invoice after Service")
                {
                    ApplicationArea = Service;
                    Enabled = InvoiceAfterServiceEnable;
                    ToolTip = 'Specifies you can only invoice the contract if you have posted a service order linked to the contract since you last invoiced the contract.';

                    trigger OnValidate()
                    begin
                        InvoiceafterServiceOnAfterVali;
                    end;
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
            group("&Contract Template")
            {
                Caption = '&Contract Template';
                Image = Template;
                action(Dimensions)
                {
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    RunObject = Page "Default Dimensions";
                    RunPageLink = "Table ID"=CONST(5968),
                                  "No."=FIELD("No.");
                    ShortCutKey = 'Shift+Ctrl+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';
                }
                action("Service Dis&counts")
                {
                    ApplicationArea = Service;
                    Caption = 'Service Dis&counts';
                    Image = Discount;
                    RunObject = Page "Contract/Service Discounts";
                    RunPageLink = "Contract Type"=CONST(Template),
                                  "Contract No."=FIELD("No.");
                    ToolTip = 'View or edit the discounts that you grant for the contract on spare parts in particular service item groups, the discounts on resource hours for resources in particular resource groups, and the discounts on particular service costs.';
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        ActivateFields;
    end;

    trigger OnInit()
    begin
        InvoiceAfterServiceEnable := true;
        PrepaidEnable := true;
    end;

    trigger OnOpenPage()
    begin
        ActivateFields;
    end;

    var
        [InDataSet]
        PrepaidEnable: Boolean;
        [InDataSet]
        InvoiceAfterServiceEnable: Boolean;

    local procedure ActivateFields()
    begin
        PrepaidEnable := (not "Invoice after Service" or Prepaid);
        InvoiceAfterServiceEnable := (not Prepaid or "Invoice after Service");
    end;

    local procedure InvoiceafterServiceOnAfterVali()
    begin
        ActivateFields;
    end;

    local procedure PrepaidOnAfterValidate()
    begin
        ActivateFields;
    end;
}

