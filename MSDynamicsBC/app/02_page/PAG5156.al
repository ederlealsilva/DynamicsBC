page 5156 "Customer Template List"
{
    // version NAVW113.00

    ApplicationArea = RelationshipMgmt;
    Caption = 'Customer Templates';
    CardPageID = "Customer Template Card";
    Editable = false;
    PageType = List;
    SourceTable = "Customer Template";
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
                    ApplicationArea = RelationshipMgmt;
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
                group(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    action("Dimensions-Single")
                    {
                        ApplicationArea = Dimensions;
                        Caption = 'Dimensions-Single';
                        Image = Dimensions;
                        RunObject = Page "Default Dimensions";
                        RunPageLink = "Table ID"=CONST(5105),
                                      "No."=FIELD(Code);
                        ShortCutKey = 'Shift+Ctrl+D';
                        ToolTip = 'View or edit the single set of dimensions that are set up for the selected record.';
                    }
                    action("Dimensions-&Multiple")
                    {
                        AccessByPermission = TableData Dimension=R;
                        ApplicationArea = Dimensions;
                        Caption = 'Dimensions-&Multiple';
                        Image = DimensionSets;
                        ToolTip = 'View or edit dimensions for a group of records. You can assign dimension codes to transactions to distribute costs and analyze historical information.';

                        trigger OnAction()
                        var
                            CustTemplate: Record "Customer Template";
                            DefaultDimMultiple: Page "Default Dimensions-Multiple";
                        begin
                            CurrPage.SetSelectionFilter(CustTemplate);
                            DefaultDimMultiple.SetMultiCustTemplate(CustTemplate);
                            DefaultDimMultiple.RunModal;
                        end;
                    }
                }
            }
        }
    }
}

