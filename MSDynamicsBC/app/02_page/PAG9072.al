page 9072 "IT Operations Activities"
{
    // version NAVW113.00

    Caption = 'Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "Administration Cue";

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
            cuegroup(Administration)
            {
                Caption = 'Administration';
                field("Job Queue Entries Until Today";"Job Queue Entries Until Today")
                {
                    ApplicationArea = Jobs;
                    DrillDownPageID = "Job Queue Entries";
                    ToolTip = 'Specifies the number of job queue entries that are displayed in the Administration Cue on the Role Center. The documents are filtered by today''s date.';
                }
                field("User Posting Period";"User Posting Period")
                {
                    ApplicationArea = Basic,Suite;
                    DrillDownPageID = "User Setup";
                    ToolTip = 'Specifies the period number of the documents that are displayed in the Administration Cue on the Role Center.';
                }
                field("No. Series Period";"No. Series Period")
                {
                    ApplicationArea = Basic,Suite;
                    DrillDownPageID = "No. Series Lines";
                    ToolTip = 'Specifies the period number of the number series for the documents that are displayed in the Administration Cue on the Role Center. The documents are filtered by today''s date.';
                }

                actions
                {
                    action("Edit Job Queue Entry Card")
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Edit Job Queue Entry Card';
                        RunObject = Page "Job Queue Entry Card";
                        ToolTip = 'Change the settings for the job queue entry.';
                    }
                    action("Edit User Setup")
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Edit User Setup';
                        RunObject = Page "User Setup";
                        ToolTip = 'Manage users and their permissions.';
                    }
                    action("Edit Migration Overview")
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Edit Migration Overview';
                        RunObject = Page "Config. Package Card";
                        ToolTip = 'Get an overview of data migration tasks.';
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
            cuegroup("Data Privacy")
            {
                Caption = 'Data Privacy';
                field(UnclassifiedFields;UnclassifiedFields)
                {
                    ApplicationArea = All;
                    Caption = 'Fields Missing Data Sensitivity';
                    ToolTip = 'Specifies the number fields with Data Sensitivity set to unclassified.';

                    trigger OnDrillDown()
                    var
                        DataSensitivity: Record "Data Sensitivity";
                    begin
                        DataSensitivity.SetRange("Company Name",CompanyName);
                        DataSensitivity.SetRange("Data Sensitivity",DataSensitivity."Data Sensitivity"::Unclassified);
                        PAGE.Run(PAGE::"Data Classification Worksheet",DataSensitivity);
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        DataSensitivity: Record "Data Sensitivity";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Reset;
        if not Get then begin
          Init;
          Insert;
        end;

        DataClassificationMgt.ShowNotifications;

        DataSensitivity.SetRange("Company Name",CompanyName);
        DataSensitivity.SetRange("Data Sensitivity",DataSensitivity."Data Sensitivity"::Unclassified);
        UnclassifiedFields := DataSensitivity.Count;

        SetFilter("Date Filter2",'<=%1',CreateDateTime(Today,0T));
        SetFilter("Date Filter3",'>%1',CreateDateTime(Today,0T));
        SetFilter("User ID Filter",UserId);

        ShowIntelligentCloud := not PermissionManager.SoftwareAsAService;
    end;

    var
        PermissionManager: Codeunit "Permission Manager";
        UnclassifiedFields: Integer;
        ShowIntelligentCloud: Boolean;
}

