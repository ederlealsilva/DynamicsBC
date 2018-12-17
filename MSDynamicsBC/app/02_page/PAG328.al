page 328 "Intrastat Setup"
{
    // version NAVW113.00

    ApplicationArea = Basic,Suite;
    Caption = 'Intrastat Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "Intrastat Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Report Receipts";"Report Receipts")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies that you must include arrivals of received goods in Intrastat reports.';
                }
                field("Report Shipments";"Report Shipments")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies that you must include shipments of dispatched items in Intrastat reports.';
                }
                field("Intrastat Contact Type";"Intrastat Contact Type")
                {
                    ApplicationArea = Basic,Suite;
                    OptionCaption = ' ,Contact,Vendor';
                    ToolTip = 'Specifies the Intrastat contact type.';
                }
                field("Intrastat Contact No.";"Intrastat Contact No.")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the Intrastat contact.';
                }
            }
            group("Default Transactions")
            {
                Caption = 'Default Transactions';
                field("Default Transaction Type";"Default Trans. - Purchase")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the default transaction type in Intrastat reports for sales and purchases.';
                }
                field("Default Trans. Type - Returns";"Default Trans. - Return")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the default transaction type in Intrastat reports for purchase returns and sales.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(IntrastatChecklistSetup)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Intrastat Checklist  Setup';
                Image = Column;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "Intrastat Checklist Setup";
                ToolTip = 'View and edit fields to be verified by the Intrastat journal check.';
            }
        }
    }

    trigger OnOpenPage()
    begin
        Init;
        if not Get then
          Insert(true);
    end;
}

