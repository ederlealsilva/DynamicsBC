page 9042 "Team Member Activities"
{
    // version NAVW113.00

    Caption = 'Self-Service';
    PageType = CardPart;
    RefreshOnActivate = true;
    ShowFilter = false;
    SourceTable = "Team Member Cue";

    layout
    {
        area(content)
        {
            cuegroup("Time Sheets")
            {
                Caption = 'Time Sheets';
                field("Open Time Sheets";"Open Time Sheets")
                {
                    ApplicationArea = Basic,Suite;
                    DrillDownPageID = "Time Sheet List";
                    ToolTip = 'Specifies the number of time sheets that are currently assigned to you and not submitted for approval.';
                }
            }
            cuegroup("Pending Time Sheets")
            {
                Caption = 'Pending Time Sheets';
                field("Submitted Time Sheets";"Submitted Time Sheets")
                {
                    ApplicationArea = Basic,Suite;
                    DrillDownPageID = "Time Sheet List";
                    ToolTip = 'Specifies the number of time sheets that you have submitted for approval but are not yet approved.';
                }
                field("Rejected Time Sheets";"Rejected Time Sheets")
                {
                    ApplicationArea = Basic,Suite;
                    DrillDownPageID = "Time Sheet List";
                    ToolTip = 'Specifies the number of time sheets that you submitted for approval but were rejected.';
                }
                field("Approved Time Sheets";"Approved Time Sheets")
                {
                    ApplicationArea = Basic,Suite;
                    DrillDownPageID = "Time Sheet List";
                    ToolTip = 'Specifies the number of time sheets that have been approved.';
                }
            }
            cuegroup(Approvals)
            {
                Caption = 'Approvals';
                field("Requests to Approve";"Requests to Approve")
                {
                    ApplicationArea = Basic,Suite;
                    DrillDownPageID = "Requests to Approve";
                    ToolTip = 'Specifies requests for certain documents, cards, or journal lines that you must approve for other users before they can proceed.';
                }
                field("Time Sheets to Approve";"Time Sheets to Approve")
                {
                    ApplicationArea = Basic,Suite;
                    DrillDownPageID = "Manager Time Sheet List";
                    ToolTip = 'Specifies the number of time sheets that need to be approved.';
                    Visible = ShowTimeSheetsToApprove;
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
        TimeSheetHeader: Record "Time Sheet Header";
        RoleCenterNotificationMgt: Codeunit "Role Center Notification Mgt.";
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
    begin
        Reset;
        if not Get then begin
          Init;
          Insert;
        end;

        TimeSheetHeader.SetRange("Approver User ID",UserId);
        if TimeSheetHeader.FindFirst then begin
          SetRange("Approve ID Filter",UserId);
          SetRange("User ID Filter",UserId);
          ShowTimeSheetsToApprove := true;
        end else begin
          SetRange("User ID Filter",UserId);
          ShowTimeSheetsToApprove := false;
        end;

        RoleCenterNotificationMgt.ShowNotifications;
        ConfPersonalizationMgt.OnRoleCenterOpen;

        if PageNotifier.IsAvailable then begin
          PageNotifier := PageNotifier.Create;
          PageNotifier.NotifyPageReady;
        end;
    end;

    var
        [RunOnClient]
        [WithEvents]
        PageNotifier: DotNet PageNotifier;
        ShowTimeSheetsToApprove: Boolean;

    trigger PageNotifier::PageReady()
    var
        NetPromoterScoreMgt: Codeunit "Net Promoter Score Mgt.";
    begin
        NetPromoterScoreMgt.ShowNpsDialog;
    end;
}

