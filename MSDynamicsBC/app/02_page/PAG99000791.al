page 99000791 "Family List"
{
    // version NAVW113.00

    ApplicationArea = Manufacturing;
    Caption = 'Families';
    CardPageID = Family;
    Editable = false;
    PageType = List;
    SourceTable = Family;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No.";"No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies a description for a product family.';
                }
                field("Description 2";"Description 2")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies an additional description of the product family if there is not enough space in the Description field.';
                    Visible = false;
                }
                field("Routing No.";"Routing No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number of the routing which is used for the production of the family.';
                }
                field(Blocked;Blocked)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies that the related record is blocked from being posted in transactions, for example a customer that is declared insolvent or an item that is placed in quarantine.';
                    Visible = false;
                }
                field("Last Date Modified";"Last Date Modified")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies when the standard data of this production family was last modified.';
                    Visible = false;
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

