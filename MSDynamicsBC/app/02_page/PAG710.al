page 710 "Activity Log"
{
    // version NAVW111.00

    Caption = 'Activity Log';
    DelayedInsert = false;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Activity Log";
    SourceTableView = SORTING("Activity Date")
                      ORDER(Descending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Activity Date";"Activity Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the data of the activity.';
                }
                field("User ID";"User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of the user who posted the entry, to be used, for example, in the change log.';
                }
                field(Context;Context)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the context in which the activity occurred.';
                }
                field(Status;Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status of the activity.';
                }
                field(Description;Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the activity.';
                }
                field("Activity Message";"Activity Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status or error message for the activity.';
                }
                field(HasDetailedInfo;HasDetailedInfo)
                {
                    ApplicationArea = All;
                    Caption = 'Detailed Info Available';
                    ToolTip = 'Specifies if detailed activity log details exist. If so, choose the View Details action.';

                    trigger OnDrillDown()
                    begin
                        Export('',true);
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(OpenRelatedRecord)
            {
                ApplicationArea = Suite,Invoicing;
                Caption = 'Open Related Record';
                Image = View;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Open the record that is associated with this activity.';

                trigger OnAction()
                var
                    PageManagement: Codeunit "Page Management";
                begin
                    if not PageManagement.PageRun("Record ID") then
                      Message(NoRelatedRecordMsg);
                end;
            }
            action(ViewDetails)
            {
                ApplicationArea = Suite,Invoicing;
                Caption = 'View Details';
                Ellipsis = true;
                Image = GetSourceDoc;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Show more information about this activity.';

                trigger OnAction()
                begin
                    Export('',true);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        HasDetailedInfo := "Detailed Info".HasValue;
    end;

    trigger OnAfterGetRecord()
    begin
        HasDetailedInfo := "Detailed Info".HasValue;
    end;

    trigger OnOpenPage()
    begin
        SetAutoCalcFields("Detailed Info");
    end;

    var
        HasDetailedInfo: Boolean;
        NoRelatedRecordMsg: Label 'There are no related records to display.';
}

