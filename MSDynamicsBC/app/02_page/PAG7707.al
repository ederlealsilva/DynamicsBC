page 7707 "Item Identifiers List"
{
    // version NAVW113.00

    Caption = 'Item Identifiers List';
    DataCaptionFields = "Code","Item No.";
    Editable = false;
    PageType = List;
    SourceTable = "Item Identifier";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code";Code)
                {
                    ApplicationArea = ADCS;
                    ToolTip = 'Specifies a unique code for a particular item in terms that are useful for automatic data capture.';
                }
                field("Item No.";"Item No.")
                {
                    ApplicationArea = ADCS;
                    ToolTip = 'Specifies the number of the item to be identified by the identifier code on the line.';
                    Visible = false;
                }
                field("Variant Code";"Variant Code")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant of the item on the line.';
                }
                field("Unit of Measure Code";"Unit of Measure Code")
                {
                    ApplicationArea = ADCS;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
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

