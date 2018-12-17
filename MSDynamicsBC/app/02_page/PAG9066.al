page 9066 "Serv Outbound Technician Act."
{
    // version NAVW111.00

    Caption = 'Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "Service Cue";

    layout
    {
        area(content)
        {
            cuegroup("Outbound Service Orders")
            {
                Caption = 'Outbound Service Orders';
                field("Service Orders - Today";"Service Orders - Today")
                {
                    ApplicationArea = Service;
                    DrillDownPageID = "Service Orders";
                    ToolTip = 'Specifies the number of in-service orders that are displayed in the Service Cue on the Role Center. The documents are filtered by today''s date.';
                }
                field("Service Orders - to Follow-up";"Service Orders - to Follow-up")
                {
                    ApplicationArea = Service;
                    DrillDownPageID = "Service Orders";
                    ToolTip = 'Specifies the number of service orders that have been marked for follow up that are displayed in the Service Cue on the Role Center. The documents are filtered by today''s date.';
                }

                actions
                {
                    action("New Service Order")
                    {
                        ApplicationArea = Service;
                        Caption = 'New Service Order';
                        Image = Document;
                        RunObject = Page "Service Order";
                        RunPageMode = Create;
                        ToolTip = 'Create an order for specific service work to be performed on a customer''s item. ';
                    }
                    action("Service Item Worksheet")
                    {
                        ApplicationArea = Service;
                        Caption = 'Service Item Worksheet';
                        Image = ServiceItemWorksheet;
                        RunObject = Report "Service Item Worksheet";
                        ToolTip = 'View or edit a worksheet where you record information about service items, such as repair status, fault comments and codes, and cost. In this window, you can update information on the items such as repair status and fault and resolution codes. You can also enter new service lines for resource hours, for the use of spare parts and for specific service costs.';
                    }
                }
            }
            cuegroup("My User Tasks")
            {
                Caption = 'My User Tasks';
                field("Pending Tasks";"Pending Tasks")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Pending User Tasks';
                    DrillDownPageID = "User Task List";
                    Image = Checklist;
                    ToolTip = 'Specifies the number of pending tasks that are assigned to you.';
                }
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

        SetRespCenterFilter;
        SetRange("Date Filter",WorkDate,WorkDate);
        SetFilter("User ID Filter",UserId);
    end;
}

