page 5790 "Shipping Agent Services"
{
    // version NAVW113.00

    Caption = 'Shipping Agent Services';
    DataCaptionFields = "Shipping Agent Code";
    PageType = List;
    SourceTable = "Shipping Agent Services";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code";Code)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the shipping agent.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies a description of the shipping agent.';
                }
                field("Shipping Time";"Shipping Time")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies how long it takes from when the items are shipped from the warehouse to when they are delivered.';
                }
                field("Base Calendar Code";"Base Calendar Code")
                {
                    ApplicationArea = Warehouse;
                    DrillDown = false;
                    ToolTip = 'Specifies a customizable calendar for shipment planning that holds the shipping agent''s working days and holidays.';
                }
                field(CustomizedCalendar;CalendarMgmt.CustomizedCalendarExistText(CustomizedCalendar."Source Type"::"Shipping Agent","Shipping Agent Code",Code,"Base Calendar Code"))
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Customized Calendar';
                    ToolTip = 'Specifies if you have set up a customized calendar for the shipping agent.';

                    trigger OnDrillDown()
                    begin
                        CurrPage.SaveRecord;
                        TestField("Base Calendar Code");
                        CalendarMgmt.ShowCustomizedCalendar(
                          CustomizedCalEntry."Source Type"::"Shipping Agent","Shipping Agent Code",Code,"Base Calendar Code");
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
    }

    var
        CustomizedCalEntry: Record "Customized Calendar Entry";
        CustomizedCalendar: Record "Customized Calendar Change";
        CalendarMgmt: Codeunit "Calendar Management";
}

