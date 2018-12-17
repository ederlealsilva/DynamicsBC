page 9150 "My Customers"
{
    // version NAVW111.00

    Caption = 'My Customers';
    PageType = ListPart;
    SourceTable = "My Customer";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Customer No.";"Customer No.")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the customer numbers that are displayed in the My Customer Cue on the Role Center.';
                    Width = 4;
                }
                field(Name;Name)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Name';
                    DrillDown = false;
                    Lookup = false;
                    ToolTip = 'Specifies the name of the customer.';
                    Width = 20;
                }
                field("Phone No.";"Phone No.")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Phone No.';
                    DrillDown = false;
                    ExtendedDatatype = PhoneNo;
                    Lookup = false;
                    ToolTip = 'Specifies the customer''s phone number.';
                    Width = 8;
                }
                field("Balance (LCY)";"Balance (LCY)")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the payment amount that the customer owes for completed sales.';

                    trigger OnDrillDown()
                    begin
                        if Cust.Get("Customer No.") then
                          Cust.OpenCustomerLedgerEntries(false);
                    end;
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
                RunObject = Page "Customer Card";
                RunPageLink = "No."=FIELD("Customer No.");
                RunPageMode = View;
                RunPageView = SORTING("No.");
                Scope = Repeater;
                ShortCutKey = 'Return';
                ToolTip = 'Open the card for the selected record.';
            }
        }
    }

    trigger OnOpenPage()
    begin
        SetRange("User ID",UserId);
    end;

    var
        Cust: Record Customer;
}

