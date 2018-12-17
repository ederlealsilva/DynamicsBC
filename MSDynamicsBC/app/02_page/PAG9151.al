page 9151 "My Vendors"
{
    // version NAVW113.00

    Caption = 'My Vendors';
    PageType = ListPart;
    SourceTable = "My Vendor";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Vendor No.";"Vendor No.")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the vendor numbers that are displayed in the My Vendor Cue on the Role Center.';
                }
                field("Phone No.";"Phone No.")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Phone No.';
                    DrillDown = false;
                    ExtendedDatatype = PhoneNo;
                    Lookup = false;
                    ToolTip = 'Specifies the vendor''s phone number.';
                }
                field(Name;Name)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Name';
                    DrillDown = false;
                    Lookup = false;
                    ToolTip = 'Specifies the name of the record.';
                }
                field("<Balance>";"Balance (LCY)")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Balance';
                    ToolTip = 'Specifies the balance. ';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        Vend: Record Vendor;
                    begin
                        if Vend.Get("Vendor No.") then
                          Vend.OpenVendorLedgerEntries(false);
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
                RunObject = Page "Vendor Card";
                RunPageLink = "No."=FIELD("Vendor No.");
                RunPageMode = View;
                RunPageView = SORTING("No.");
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

