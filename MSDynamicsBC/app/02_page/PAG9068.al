page 9068 "Project Manager Activities"
{
    // version NAVW113.00

    Caption = 'Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    ShowFilter = false;
    SourceTable = "Job Cue";

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
            cuegroup(Invoicing)
            {
                Caption = 'Invoicing';
                Visible = SetupIsComplete;
                field("Upcoming Invoices";"Upcoming Invoices")
                {
                    ApplicationArea = Jobs;
                    DrillDownPageID = "Job List";
                    ToolTip = 'Specifies the number of upcoming invoices that are displayed in the Job Cue on the Role Center. The documents are filtered by today''s date.';
                }
                field("Invoices Due - Not Created";"Invoices Due - Not Created")
                {
                    ApplicationArea = Jobs;
                    DrillDownPageID = "Job List";
                    ToolTip = 'Specifies the number of invoices that are due but not yet created that are displayed in the Job Cue on the Role Center. The documents are filtered by today''s date.';
                }

                actions
                {
                    action("Job Create Sales Invoice")
                    {
                        ApplicationArea = Jobs;
                        Caption = 'Job Create Sales Invoice';
                        Image = CreateJobSalesInvoice;
                        RunObject = Report "Job Create Sales Invoice";
                        ToolTip = 'Create an invoice for a job or for one or more job tasks for a customer when either the work to be invoiced is complete or the date for invoicing based on an invoicing schedule has been reached.';
                    }
                }
            }
            cuegroup("Work in Process")
            {
                Caption = 'Work in Process';
                Visible = SetupIsComplete;
                field("WIP Not Posted";"WIP Not Posted")
                {
                    ApplicationArea = Suite;
                    DrillDownPageID = "Job List";
                    ToolTip = 'Specifies the amount of work in process that has not been posted that is displayed in the Service Cue on the Role Center. The documents are filtered by today''s date.';
                }
                field("Completed - WIP Not Calculated";"Completed - WIP Not Calculated")
                {
                    ApplicationArea = Suite;
                    DrillDownPageID = "Job List";
                    ToolTip = 'Specifies the total of work in process that is complete but not calculated that is displayed in the Job Cue on the Role Center. The documents are filtered by today''s date.';
                }

                actions
                {
                    action("Update Job Item Cost")
                    {
                        ApplicationArea = Jobs;
                        Caption = 'Update Job Item Cost';
                        Image = "Report";
                        RunObject = Report "Update Job Item Cost";
                        ToolTip = 'Update the usage costs in the job ledger entries to match the actual costs in the item ledger entry. If adjustment value entries have a different date than the original value entry, such as when the inventory period is closed, then the job ledger is not updated.';
                    }
                    action("<Action15>")
                    {
                        ApplicationArea = Jobs;
                        Caption = 'Job WIP Cockpit';
                        RunObject = Page "Job WIP Cockpit";
                        ToolTip = 'Get an overview of work in process (WIP). The Job WIP Cockpit is the central location to track WIP for all of your projects. Each line contains information about a job, including calculated and posted WIP.';
                    }
                }
            }
            cuegroup("Jobs to Budget")
            {
                Caption = 'Jobs to Budget';
                Visible = SetupIsComplete;
                field("Jobs Over Budget";"Jobs Over Budget")
                {
                    ApplicationArea = Jobs;
                    Caption = 'Over Budget';
                    DrillDownPageID = "Job List";
                    Editable = false;
                    ToolTip = 'Specifies the number of jobs where the usage cost exceeds the budgeted cost.';
                }
            }
            cuegroup("My User Tasks")
            {
                Caption = 'My User Tasks';
                Visible = SetupIsComplete;
                field("Pending Tasks";"Pending Tasks")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Pending User Tasks';
                    DrillDownPageID = "User Task List";
                    Image = Checklist;
                    ToolTip = 'Specifies the number of pending tasks that are assigned to you.';
                }
            }
            cuegroup(Start)
            {
                Caption = 'Start';
                Visible = SetupIsComplete;

                actions
                {
                    action("<Page Job>")
                    {
                        AccessByPermission = TableData Job=IMD;
                        ApplicationArea = Basic,Suite;
                        Caption = 'New Job';
                        Image = TileNew;
                        RunObject = Page "Job Creation Wizard";
                        RunPageMode = Create;
                        ToolTip = 'Create a new job.';
                    }
                    action("<Page Job Journal>")
                    {
                        AccessByPermission = TableData "Job Journal Template"=IMD;
                        ApplicationArea = Basic,Suite;
                        Caption = 'Job Journal';
                        Image = TileNew;
                        RunObject = Page "Job Journal";
                        RunPageMode = Edit;
                        ToolTip = 'Prepare to post usage for a job.';
                    }
                    action("Create Job &Sales Invoice")
                    {
                        AccessByPermission = TableData "Job Task"=IMD;
                        ApplicationArea = Jobs;
                        Caption = 'Create Job &Sales Invoice';
                        Image = TileNew;
                        Promoted = true;
                        PromotedCategory = Process;
                        RunObject = Report "Job Create Sales Invoice";
                        ToolTip = 'Use a batch job to help you create job sales invoices for the involved job planning lines.';
                        Visible = JobSimplificationAvailable;
                    }
                }
            }
            cuegroup("Get started")
            {
                Caption = 'Get started';
                Visible = ReplayGettingStartedVisible;

                actions
                {
                    action(ShowStartInMyCompany)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Try with my own data';
                        Image = TileSettings;
                        ToolTip = 'Set up My Company with the settings you choose. We''ll show you how, it''s easy.';
                        Visible = false;

                        trigger OnAction()
                        begin
                            if UserTours.IsAvailable and O365GettingStartedMgt.AreUserToursEnabled then
                              UserTours.StartUserTour(O365GettingStartedMgt.GetChangeCompanyTourID);
                        end;
                    }
                    action(ReplayGettingStarted)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Replay Getting Started';
                        Image = TileVideo;
                        ToolTip = 'Show the Getting Started guide again.';

                        trigger OnAction()
                        var
                            O365GettingStarted: Record "O365 Getting Started";
                        begin
                            if O365GettingStarted.Get(UserId,ClientTypeManagement.GetCurrentClientType) then begin
                              O365GettingStarted."Tour in Progress" := false;
                              O365GettingStarted."Current Page" := 1;
                              O365GettingStarted.Modify;
                              Commit;
                            end;

                            O365GettingStartedMgt.LaunchWizard(true,false);
                        end;
                    }
                }
            }
            cuegroup(Jobs)
            {
                Caption = 'Jobs';
                Visible = NOT SetupIsComplete;

                actions
                {
                    action("<PageJobSetup>")
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Set Up Jobs';
                        Image = TileSettings;
                        RunObject = Page "Jobs Setup Wizard";
                        RunPageMode = Create;
                        ToolTip = 'Open the assisted setup guide to set up how you want to use jobs.';
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
                    CueRecordRef: RecordRef;
                begin
                    CueRecordRef.GetTable(Rec);
                    CueSetup.OpenCustomizePageForCurrentUser(CueRecordRef.Number);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        O365GettingStartedMgt.UpdateGettingStartedVisible(TileGettingStartedVisible,ReplayGettingStartedVisible);
    end;

    trigger OnInit()
    var
        Job: Record Job;
        JobsSetup: Record "Jobs Setup";
        MyCompName: Text;
    begin
        O365GettingStartedMgt.UpdateGettingStartedVisible(TileGettingStartedVisible,ReplayGettingStartedVisible);
        JobSimplificationAvailable := Job.IsJobSimplificationAvailable;

        SetupIsComplete := false;

        MyCompName := CompanyName;

        if JobsSetup.FindFirst then begin
          if MyCompName = MyCompanyTxt then
            SetupIsComplete := JobsSetup."Default Job Posting Group" <> ''
          else
            SetupIsComplete := JobsSetup."Job Nos." <> '';
        end;
    end;

    trigger OnOpenPage()
    var
        RoleCenterNotificationMgt: Codeunit "Role Center Notification Mgt.";
    begin
        Reset;
        if not Get then begin
          Init;
          Insert;
        end;

        SetFilter("Date Filter",'>=%1',WorkDate);
        SetFilter("Date Filter2",'<%1&<>%2',WorkDate,0D);
        SetRange("User ID Filter",UserId);

        RoleCenterNotificationMgt.ShowChangeToPremiumExpNotification;

        ShowIntelligentCloud := not PermissionManager.SoftwareAsAService;
    end;

    var
        CueSetup: Codeunit "Cue Setup";
        O365GettingStartedMgt: Codeunit "O365 Getting Started Mgt.";
        ClientTypeManagement: Codeunit ClientTypeManagement;
        PermissionManager: Codeunit "Permission Manager";
        [RunOnClient]
        [WithEvents]
        UserTours: DotNet UserTours;
        ReplayGettingStartedVisible: Boolean;
        TileGettingStartedVisible: Boolean;
        JobSimplificationAvailable: Boolean;
        SetupIsComplete: Boolean;
        MyCompanyTxt: Label 'My Company';
        ShowIntelligentCloud: Boolean;

    [Scope('Personalization')]
    procedure RefreshRoleCenter()
    begin
        CurrPage.Update;
    end;

    trigger UserTours::ShowTourWizard(hasTourCompleted: Boolean)
    begin
    end;

    trigger UserTours::IsTourInProgressResultReady(isInProgress: Boolean)
    begin
    end;
}

