page 99000768 "Manufacturing Setup"
{
    // version NAVW113.00

    ApplicationArea = Manufacturing;
    Caption = 'Manufacturing Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Manufacturing Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Normal Starting Time";"Normal Starting Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the normal starting time of the workday.';
                }
                field("Normal Ending Time";"Normal Ending Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the normal ending time of a workday.';
                }
                field("Preset Output Quantity";"Preset Output Quantity")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies what to show in the Output Quantity field of a production journal when it is first opened.';
                }
                field("Show Capacity In";"Show Capacity In")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies which capacity unit of measure to use by default to record and track capacity.';
                }
                field("Planning Warning";"Planning Warning")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies whether to run the MRP engine to detect if planned shipment dates cannot be met.';
                }
                field("Doc. No. Is Prod. Order No.";"Doc. No. Is Prod. Order No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies that the production order number is also the document number in the ledger entries posted for the production order.';
                }
                field("Dynamic Low-Level Code";"Dynamic Low-Level Code")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies whether to immediately assign and calculate low-level codes for each component in the product structure.';
                }
                field("Cost Incl. Setup";"Cost Incl. Setup")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies whether the setup times are to be included in the cost calculation of the Standard Cost field.';
                }
            }
            group(Numbering)
            {
                Caption = 'Numbering';
                field("Simulated Order Nos.";"Simulated Order Nos.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number series code to use when assigning numbers to a simulated production order.';
                }
                field("Planned Order Nos.";"Planned Order Nos.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number series code to use when assigning numbers to a planned production order.';
                }
                field("Firm Planned Order Nos.";"Firm Planned Order Nos.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number series code to use when assigning numbers to firm planned production orders.';
                }
                field("Released Order Nos.";"Released Order Nos.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number series code to use when assigning numbers to a released production order.';
                }
                field("Work Center Nos.";"Work Center Nos.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number series code to use when assigning numbers to work centers.';
                }
                field("Machine Center Nos.";"Machine Center Nos.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number series code to use when assigning numbers to machine centers.';
                }
                field("Production BOM Nos.";"Production BOM Nos.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number series code to use when assigning numbers to production BOMs.';
                }
                field("Routing Nos.";"Routing Nos.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number series code to use when assigning numbers to routings.';
                }
            }
            group(Planning)
            {
                Caption = 'Planning';
                field("Current Production Forecast";"Current Production Forecast")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the name of the relevant production forecast to use to calculate a plan.';
                }
                field("Use Forecast on Locations";"Use Forecast on Locations")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies whether to filter according to location when calculating a plan.';
                }
                field("Default Safety Lead Time";"Default Safety Lead Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies a time period that is added to the lead time of all items that do not have another value specified in the Safety Lead Time field.';
                }
                field("Blank Overflow Level";"Blank Overflow Level")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies how the planning system should react if the Overflow Level field on the item or SKU card is empty.';
                }
                field("Combined MPS/MRP Calculation";"Combined MPS/MRP Calculation")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies whether MPS and MRP are calculated in one step when you run the planning worksheet.';
                }
                field("Components at Location";"Components at Location")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the inventory location from where the production order components are to be taken.';
                }
                field("Default Dampener Period";"Default Dampener Period")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies a period of time during which you do not want the planning system to propose to reschedule existing supply orders forward.';
                }
                field("Default Dampener %";"Default Dampener %")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies a percentage of an item''s lot size by which an existing supply must change before a planning suggestion is made.';
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

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
          Init;
          Insert;
        end;
    end;
}

