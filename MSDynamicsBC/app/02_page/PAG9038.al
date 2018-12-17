page 9038 "Production Planner Activities"
{
    // version NAVW113.00

    Caption = 'Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "Manufacturing Cue";

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
            cuegroup("Production Orders")
            {
                Caption = 'Production Orders';
                field("Planned Prod. Orders - All";"Planned Prod. Orders - All")
                {
                    ApplicationArea = Manufacturing;
                    DrillDownPageID = "Planned Production Orders";
                    ToolTip = 'Specifies the number of planned production orders that are displayed in the Manufacturing Cue on the Role Center. The documents are filtered by today''s date.';
                }
                field("Firm Plan. Prod. Orders - All";"Firm Plan. Prod. Orders - All")
                {
                    ApplicationArea = Manufacturing;
                    DrillDownPageID = "Firm Planned Prod. Orders";
                    ToolTip = 'Specifies the number of firm planned production orders that are displayed in the Manufacturing Cue on the Role Center. The documents are filtered by today''s date.';
                }
                field("Released Prod. Orders - All";"Released Prod. Orders - All")
                {
                    ApplicationArea = Manufacturing;
                    DrillDownPageID = "Released Production Orders";
                    ToolTip = 'Specifies the number of released production orders that are displayed in the Manufacturing Cue on the Role Center. The documents are filtered by today''s date.';
                }

                actions
                {
                    action("Change Production Order Status")
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Change Production Order Status';
                        Image = ChangeStatus;
                        RunObject = Page "Change Production Order Status";
                        ToolTip = 'Change the production order to another status, such as Released.';
                    }
                    action("New Production Order")
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'New Production Order';
                        RunObject = Page "Planned Production Order";
                        RunPageMode = Create;
                        ToolTip = 'Prepare to produce an end item. ';
                    }
                    action(Navigate)
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Navigate';
                        Image = Navigate;
                        RunObject = Page Navigate;
                        ToolTip = 'Find all entries and documents that exist for the document number and posting date on the selected entry or document.';
                    }
                }
            }
            cuegroup("Planning - Operations")
            {
                Caption = 'Planning - Operations';
                field("Purchase Orders";"Purchase Orders")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'My Purchase Orders';
                    DrillDown = true;
                    DrillDownPageID = "Purchase Order List";
                    ToolTip = 'Specifies the number of purchase orders that are displayed in the Manufacturing Cue on the Role Center. The documents are filtered by today''s date.';
                }

                actions
                {
                    action("New Purchase Order")
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'New Purchase Order';
                        RunObject = Page "Purchase Order";
                        RunPageMode = Create;
                        ToolTip = 'Purchase goods or services from a vendor.';
                    }
                    action("Edit Planning Worksheet")
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Edit Planning Worksheet';
                        RunObject = Page "Planning Worksheet";
                        ToolTip = 'Plan supply orders automatically to fulfill new demand.';
                    }
                    action("Edit Subcontracting Worksheet")
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Edit Subcontracting Worksheet';
                        RunObject = Page "Subcontracting Worksheet";
                        ToolTip = 'Plan outsourcing of operation on released production orders.';
                    }
                }
            }
            cuegroup(Design)
            {
                Caption = 'Design';
                field("Prod. BOMs under Development";"Prod. BOMs under Development")
                {
                    ApplicationArea = Manufacturing;
                    DrillDownPageID = "Production BOM List";
                    ToolTip = 'Specifies the number of production BOMs that are under development that are displayed in the Manufacturing Cue on the Role Center. The documents are filtered by today''s date.';
                }
                field("Routings under Development";"Routings under Development")
                {
                    ApplicationArea = Manufacturing;
                    DrillDownPageID = "Routing List";
                    ToolTip = 'Specifies the routings under development that are displayed in the Manufacturing Cue on the Role Center. The documents are filtered by today''s date.';
                }

                actions
                {
                    action("New Item")
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'New Item';
                        Image = NewItem;
                        RunObject = Page "Item Card";
                        RunPageMode = Create;
                        ToolTip = 'Create an item card based on the stockkeeping unit.';
                    }
                    action("New Production BOM")
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'New Production BOM';
                        RunObject = Page "Production BOM";
                        RunPageMode = Create;
                        ToolTip = 'Create a bill of material that defines the components in a produced item.';
                    }
                    action("New Routing")
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'New Routing';
                        RunObject = Page Routing;
                        RunPageMode = Create;
                        ToolTip = 'Create a routing that defines the operations required to produce an end item.';
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
                    CueRecordRef: RecordRef;
                begin
                    CueRecordRef.GetTable(Rec);
                    CueSetup.OpenCustomizePageForCurrentUser(CueRecordRef.Number);
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        RoleCenterNotificationMgt: Codeunit "Role Center Notification Mgt.";
    begin
        Reset;
        if not Get then begin
          Init;
          Insert;
        end;

        SetRange("User ID Filter",UserId);

        RoleCenterNotificationMgt.ShowChangeToPremiumExpNotification;

        ShowIntelligentCloud := not PermissionManager.SoftwareAsAService;
    end;

    var
        CueSetup: Codeunit "Cue Setup";
        PermissionManager: Codeunit "Permission Manager";
        ShowIntelligentCloud: Boolean;
}

