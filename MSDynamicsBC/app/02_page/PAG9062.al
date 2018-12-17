page 9062 "User Security Activities"
{
    // version NAVW113.00

    Caption = 'User Security Activities';
    Editable = false;
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "User Security Status";

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
            cuegroup(Control2)
            {
                CueGroupLayout = Wide;
                ShowCaption = false;
                field("Users - To review";"Users - To review")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Users - To review';
                    DrillDownPageID = "User Security Status List";
                    Editable = false;
                    ToolTip = 'Specifies new users who have not yet been reviewed by an administrator.';
                }
                field("Users - Without Subscriptions";"Users - Without Subscriptions")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Users - Without Subscription Plans';
                    DrillDownPageID = "User Security Status List";
                    Editable = false;
                    ToolTip = 'Specifies users without subscription to use Business Central.';
                    Visible = SoftwareAsAService;
                }
                field("Users - Not Group Members";"Users - Not Group Members")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Users - Not Group Members';
                    DrillDownPageID = "User Security Status List";
                    Editable = false;
                    ToolTip = 'Specifies users who have not yet been reviewed by an administrator.';
                    Visible = SoftwareAsAService;
                }
                field(NumberOfPlans;NumberOfPlans)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Number of plans';
                    ToolTip = 'Specifies the number of plans.';
                    Visible = SoftwareAsAService;

                    trigger OnDrillDown()
                    var
                        Plan: Record Plan;
                    begin
                        if not SoftwareAsAService then
                          exit;
                        PAGE.Run(PAGE::Plans,Plan)
                    end;
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

    trigger OnAfterGetCurrRecord()
    var
        RoleCenterNotificationMgt: Codeunit "Role Center Notification Mgt.";
    begin
        RoleCenterNotificationMgt.HideEvaluationNotificationAfterStartingTrial;
    end;

    trigger OnOpenPage()
    var
        UserSecurityStatus: Record "User Security Status";
        DataSensitivity: Record "Data Sensitivity";
        PermissionManager: Codeunit "Permission Manager";
        RoleCenterNotificationMgt: Codeunit "Role Center Notification Mgt.";
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
    begin
        SoftwareAsAService := PermissionManager.SoftwareAsAService;
        if SoftwareAsAService then
          NumberOfPlans := GetNumberOfPlans;
        UserSecurityStatus.LoadUsers;
        Reset;
        if not Get then begin
          Init;
          Insert;
        end;

        DataSensitivity.SetRange("Company Name",CompanyName);
        DataSensitivity.SetRange("Data Sensitivity",DataSensitivity."Data Sensitivity"::Unclassified);
        UnclassifiedFields := DataSensitivity.Count;

        RoleCenterNotificationMgt.ShowNotifications;
        ConfPersonalizationMgt.OnRoleCenterOpen;
        ShowIntelligentCloud := not SoftwareAsAService;

        if PageNotifier.IsAvailable then begin
          PageNotifier := PageNotifier.Create;
          PageNotifier.NotifyPageReady;
        end;
    end;

    var
        [RunOnClient]
        [WithEvents]
        PageNotifier: DotNet PageNotifier;
        SoftwareAsAService: Boolean;
        NumberOfPlans: Integer;
        UnclassifiedFields: Integer;
        ShowIntelligentCloud: Boolean;

    local procedure GetNumberOfPlans(): Integer
    var
        Plan: Record Plan;
    begin
        if not SoftwareAsAService then
          exit(0);
        exit(Plan.Count);
    end;

    trigger PageNotifier::PageReady()
    var
        NetPromoterScoreMgt: Codeunit "Net Promoter Score Mgt.";
    begin
        NetPromoterScoreMgt.ShowNpsDialog;
    end;
}

