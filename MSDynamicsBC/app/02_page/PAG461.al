page 461 "Inventory Setup"
{
    // version NAVW113.00

    ApplicationArea = Basic,Suite;
    Caption = 'Inventory Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    PromotedActionCategories = 'New,Process,Report,General,Posting,Journal Templates';
    SourceTable = "Inventory Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Automatic Cost Posting";"Automatic Cost Posting")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies that the Automatic Cost Posting function is used.';
                }
                field("Expected Cost Posting to G/L";"Expected Cost Posting to G/L")
                {
                    ApplicationArea = Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the ability to post expected costs to interim accounts in the general ledger.';
                }
                field("Automatic Cost Adjustment";"Automatic Cost Adjustment")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies whether to adjust for any cost changes when you post inventory transactions.';
                }
                field("Default Costing Method";"Default Costing Method")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies default costing method.';
                }
                field("Average Cost Calc. Type";"Average Cost Calc. Type")
                {
                    ApplicationArea = Basic,Suite;
                    Importance = Additional;
                    OptionCaption = ',Item,Item & Location & Variant';
                    ToolTip = 'Specifies information about the method that the program uses to calculate average cost.';
                }
                field("Average Cost Period";"Average Cost Period")
                {
                    ApplicationArea = Basic,Suite;
                    Importance = Additional;
                    OptionCaption = ',Day,Week,Month,,,Accounting Period';
                    ToolTip = 'Specifies the period of time used to calculate the weighted average cost of items that apply the average costing method.';
                }
                field("Copy Comments Order to Shpt.";"Copy Comments Order to Shpt.")
                {
                    ApplicationArea = Comments;
                    Importance = Additional;
                    ToolTip = 'Specifies that you want the program to copy the comments entered on the transfer order to the transfer shipment.';
                }
                field("Copy Comments Order to Rcpt.";"Copy Comments Order to Rcpt.")
                {
                    ApplicationArea = Comments;
                    Importance = Additional;
                    ToolTip = 'Specifies that you want the program to copy the comments entered on the transfer order to the transfer receipt.';
                }
                field("Outbound Whse. Handling Time";"Outbound Whse. Handling Time")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTip = 'Specifies a date formula for the time it takes to get items ready to ship from this location. The time element is used in the calculation of the delivery date as follows: Shipment Date + Outbound Warehouse Handling Time = Planned Shipment Date + Shipping Time = Planned Delivery Date.';
                }
                field("Inbound Whse. Handling Time";"Inbound Whse. Handling Time")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTip = 'Specifies the time it takes to make items part of available inventory, after the items have been posted as received.';
                }
                field("Prevent Negative Inventory";"Prevent Negative Inventory")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies if you can post transactions that will bring inventory levels below zero.';
                }
            }
            group(Location)
            {
                Caption = 'Location';
                field("Location Mandatory";"Location Mandatory")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies whether items must have a location code in order to be posted.';
                }
            }
            group(Dimensions)
            {
                Caption = 'Dimensions';
                field("Item Group Dimension Code";"Item Group Dimension Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the dimension code that you want to use for product groups in analysis reports.';
                }
            }
            group(Numbering)
            {
                Caption = 'Numbering';
                field("Item Nos.";"Item Nos.")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the number series code that will be used to assign numbers to items.';
                }
                field("Nonstock Item Nos.";"Nonstock Item Nos.")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Non-stock Item Nos.';
                    Importance = Additional;
                    ToolTip = 'Specifies the number series that is used for catalog items.';
                }
                field("Transfer Order Nos.";"Transfer Order Nos.")
                {
                    ApplicationArea = Location;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series code that the program uses to assign numbers to transfer orders.';
                }
                field("Posted Transfer Shpt. Nos.";"Posted Transfer Shpt. Nos.")
                {
                    ApplicationArea = Location;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series code that the program uses to assign numbers to posted transfer shipments.';
                }
                field("Posted Transfer Rcpt. Nos.";"Posted Transfer Rcpt. Nos.")
                {
                    ApplicationArea = Location;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series code that will be used to assign numbers to posted transfer receipt documents.';
                }
                field("Inventory Put-away Nos.";"Inventory Put-away Nos.")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series code to assign numbers to inventory put-always.';
                }
                field("Posted Invt. Put-away Nos.";"Posted Invt. Put-away Nos.")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series code to assign numbers to posted inventory put-always.';
                }
                field("Inventory Pick Nos.";"Inventory Pick Nos.")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series code to assign numbers to inventory picks.';
                }
                field("Posted Invt. Pick Nos.";"Posted Invt. Pick Nos.")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series code to assign numbers to posted inventory picks.';
                }
                field("Inventory Movement Nos.";"Inventory Movement Nos.")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series code used to assign numbers to inventory movements.';
                }
                field("Registered Invt. Movement Nos.";"Registered Invt. Movement Nos.")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series code to assign numbers to registered inventory movements.';
                }
                field("Internal Movement Nos.";"Internal Movement Nos.")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series code used to assign numbers to internal movements.';
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
            action("Inventory Periods")
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Inventory Periods';
                Image = Period;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page "Inventory Periods";
                ToolTip = 'Set up periods in combinations with your accounting periods that define when you can post transactions that affect the value of your item inventory. When you close an inventory period, you cannot post any changes to the inventory value, either expected or actual value, before the ending date of the inventory period.';
            }
            action("Units of Measure")
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Units of Measure';
                Image = UnitOfMeasure;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page "Units of Measure";
                ToolTip = 'Set up the units of measure, such as PSC or HOUR, that you can select from in the Item Units of Measure window that you access from the item card.';
            }
            action("Item Discount Groups")
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Item Discount Groups';
                Image = Discount;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page "Item Disc. Groups";
                ToolTip = 'Set up discount group codes that you can use as criteria when you define special discounts on a customer, vendor, or item card.';
            }
            group(Posting)
            {
                Caption = 'Posting';
                action("Inventory Posting Setup")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Inventory Posting Setup';
                    Image = PostedInventoryPick;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    RunObject = Page "Inventory Posting Setup";
                    ToolTip = 'Set up links between inventory posting groups, inventory locations, and general ledger accounts to define where transactions for inventory items are recorded in the general ledger.';
                }
                action("Inventory Posting Groups")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Inventory Posting Groups';
                    Image = ItemGroup;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    RunObject = Page "Inventory Posting Groups";
                    ToolTip = 'Set up the posting groups that you assign to item cards to link business transactions made for the item with an inventory account in the general ledger to group amounts for that item type.';
                }
            }
            group("Journal Templates")
            {
                Caption = 'Journal Templates';
                action("Item Journal Templates")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Item Journal Templates';
                    Image = JournalSetup;
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedIsBig = true;
                    RunObject = Page "Item Journal Templates";
                    ToolTip = 'Set up number series and reason codes in the journals that you use for inventory adjustment. By using different templates you can design windows with different layouts and you can assign trace codes, number series, and reports to each template.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
          Init;
          Insert;
        end;
    end;
}

