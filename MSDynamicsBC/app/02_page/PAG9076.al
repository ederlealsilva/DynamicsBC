page 9076 "Sales & Relationship Mgr. Act."
{
    // version NAVW113.00

    Caption = 'Activities';
    PageType = CardPart;
    SourceTable = "Relationship Mgmt. Cue";

    layout
    {
        area(content)
        {
            cuegroup("Intelligent Cloud")
            {
                Caption = 'Intelligent Cloud';
                Visible = ShowIntelligentCloud;

                actions
                {
                    action("Learn More")
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Learn More';
                        Image = TileInfo;
                        RunObject = Page "Intelligent Cloud";
                        RunPageMode = View;
                        ToolTip = ' Learn more about the Intelligent Cloud and how it can help your business.';
                    }
                    action("<Intelligent Cloud Insights>")
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Intelligent Cloud Insights';
                        Image = TileCloud;
                        RunPageMode = View;
                        ToolTip = 'View your Intelligent Cloud insights.';

                        trigger OnAction()
                        var
                            IntelligentCloud: Page "Intelligent Cloud";
                        begin
                            HyperLink(IntelligentCloud.GetIntelligentCloudInsightsUrl);
                        end;
                    }
                }
            }
            cuegroup(Contacts)
            {
                Caption = 'Contacts';
                field("Contacts - Companies";"Contacts - Companies")
                {
                    ApplicationArea = RelationshipMgmt;
                    DrillDownPageID = "Contact List";
                    ToolTip = 'Specifies contacts assigned to a company.';
                }
                field("Contacts - Persons";"Contacts - Persons")
                {
                    ApplicationArea = RelationshipMgmt;
                    DrillDownPageID = "Contact List";
                    ToolTip = 'Specifies contact persons.';
                }
                field("Contacts - Duplicates";"Contacts - Duplicates")
                {
                    ApplicationArea = RelationshipMgmt;
                    DrillDownPageID = "Contact Duplicates";
                    ToolTip = 'Specifies contacts that have duplicates.';
                }
            }
            cuegroup(Opportunities)
            {
                Caption = 'Opportunities';
                field("Open Opportunities";"Open Opportunities")
                {
                    ApplicationArea = RelationshipMgmt;
                    DrillDownPageID = "Opportunity List";
                    ToolTip = 'Specifies open opportunities.';
                }
                field("Opportunities Due in 7 Days";"Opportunities Due in 7 Days")
                {
                    ApplicationArea = RelationshipMgmt;
                    DrillDownPageID = "Opportunity Entries";
                    Style = Favorable;
                    StyleExpr = TRUE;
                    ToolTip = 'Specifies opportunities with a due date in seven days or more.';
                }
                field("Overdue Opportunities";"Overdue Opportunities")
                {
                    ApplicationArea = RelationshipMgmt;
                    DrillDownPageID = "Opportunity Entries";
                    Style = Unfavorable;
                    StyleExpr = TRUE;
                    ToolTip = 'Specifies opportunities that have exceeded the due date.';
                }
                field("Closed Opportunities";"Closed Opportunities")
                {
                    ApplicationArea = RelationshipMgmt;
                    DrillDownPageID = "Opportunity List";
                    ToolTip = 'Specifies opportunities that have been closed.';
                }
            }
            cuegroup(Sales)
            {
                Caption = 'Sales';
                field("Open Sales Quotes";"Open Sales Quotes")
                {
                    ApplicationArea = RelationshipMgmt;
                    DrillDownPageID = "Sales Quotes";
                    ToolTip = 'Specifies the number of sales quotes that are not yet converted to invoices or orders.';
                }
                field("Open Sales Orders";"Open Sales Orders")
                {
                    ApplicationArea = RelationshipMgmt;
                    DrillDownPageID = "Sales Order List";
                    ToolTip = 'Specifies the number of sales orders that are not fully posted.';
                }
                field("Active Campaigns";"Active Campaigns")
                {
                    ApplicationArea = RelationshipMgmt;
                    DrillDownPageID = "Campaign List";
                    ToolTip = 'Specifies marketing campaigns that are active.';
                }
                field("Uninvoiced Bookings";"Uninvoiced Bookings")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies non-invoiced bookings.';
                    Visible = ShowBookings;

                    trigger OnDrillDown()
                    var
                        BookingManager: Codeunit "Booking Manager";
                    begin
                        BookingManager.InvoiceBookingItems;
                    end;
                }
            }
            cuegroup(New)
            {
                Caption = 'New';
                Visible = IsWebMobile;

                actions
                {
                    action(NewContact)
                    {
                        AccessByPermission = TableData Contact=IMD;
                        ApplicationArea = RelationshipMgmt;
                        Caption = 'New Contact';
                        Image = TileNew;
                        RunObject = Page "Contact Card";
                        RunPageMode = Create;
                        ToolTip = 'Create a new contact.';
                    }
                    action(NewOpportunity)
                    {
                        AccessByPermission = TableData Opportunity=IMD;
                        ApplicationArea = RelationshipMgmt;
                        Caption = 'New Opportunity';
                        Image = TileNew;
                        RunObject = Page "Opportunity Card";
                        RunPageMode = Create;
                        ToolTip = 'Create a new opportunity.';
                    }
                    action(NewSegment)
                    {
                        AccessByPermission = TableData "Segment Header"=IMD;
                        ApplicationArea = RelationshipMgmt;
                        Caption = 'New Segment';
                        Image = TileNew;
                        RunObject = Page Segment;
                        RunPageMode = Create;
                        ToolTip = 'Create a new segment for which you manage interactions and campaigns.';
                    }
                    action(NewCampaign)
                    {
                        AccessByPermission = TableData Campaign=IMD;
                        ApplicationArea = RelationshipMgmt;
                        Caption = 'New Campaign';
                        Image = TileNew;
                        RunObject = Page "Campaign Card";
                        RunPageMode = Create;
                        ToolTip = 'Create a new campaign.';
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Set Up Cues")
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Set Up Cues';
                Image = Setup;
                ToolTip = 'Set up the cues (status tiles) related to the role.';

                trigger OnAction()
                var
                    CueSetup: Codeunit "Cue Setup";
                    CueRecordRef: RecordRef;
                begin
                    CueRecordRef.GetTable(Rec);
                    CueSetup.OpenCustomizePageForCurrentUser(CueRecordRef.Number);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CalculateCueFieldValues;
    end;

    trigger OnOpenPage()
    var
        BookingSync: Record "Booking Sync";
    begin
        IsWebMobile := ClientTypeManagement.GetCurrentClientType in [CLIENTTYPE::Web,CLIENTTYPE::Tablet,CLIENTTYPE::Phone];
        Reset;
        if not Get then begin
          Init;
          Insert;
        end;

        SetFilter("Due Date Filter",'<>%1&%2..%3',0D,WorkDate,WorkDate + 7);
        SetFilter("Overdue Date Filter",'<>%1&..%2',0D,WorkDate - 1);
        ShowBookings := BookingSync.IsSetup;
        ShowIntelligentCloud := not PermissionManager.SoftwareAsAService;
    end;

    var
        ClientTypeManagement: Codeunit ClientTypeManagement;
        PermissionManager: Codeunit "Permission Manager";
        IsWebMobile: Boolean;
        ShowBookings: Boolean;
        ShowIntelligentCloud: Boolean;

    local procedure CalculateCueFieldValues()
    var
        ActivitiesMgt: Codeunit "Activities Mgt.";
    begin
        if FieldActive("Uninvoiced Bookings") then
          "Uninvoiced Bookings" := ActivitiesMgt.CalcUninvoicedBookings;
    end;
}

