page 9152 "My Items"
{
    // version NAVW113.00

    Caption = 'My Items';
    PageType = ListPart;
    SourceTable = "My Item";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Item No.";"Item No.")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the item numbers that are displayed in the My Item Cue on the Role Center.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Description';
                    DrillDown = false;
                    Lookup = false;
                    ToolTip = 'Specifies a description of the item.';
                }
                field("Unit Price";"Unit Price")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Unit Price';
                    DrillDown = false;
                    Lookup = false;
                    ToolTip = 'Specifies the item''s unit price.';
                }
                field(Inventory;Inventory)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Inventory';
                    ToolTip = 'Specifies the inventory quantities of my items.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Open)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Open';
                Image = ViewDetails;
                RunObject = Page "Item Card";
                RunPageLink = "No."=FIELD("Item No.");
                RunPageMode = View;
                ShortCutKey = 'Return';
                ToolTip = 'Open the card for the selected record.';
            }
        }
    }

    trigger OnOpenPage()
    begin
        SetRange("User ID",UserId);
    end;
}

