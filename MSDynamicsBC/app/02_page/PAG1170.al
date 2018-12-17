page 1170 "User Task List"
{
    // version NAVW113.00

    ApplicationArea = Basic,Suite;
    Caption = 'User Tasks';
    CardPageID = "User Task Card";
    DelayedInsert = true;
    DeleteAllowed = true;
    Editable = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    ODataKeyFields = ID;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "User Task";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Title;Title)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the title of the task.';
                }
                field("Due DateTime";"Due DateTime")
                {
                    ApplicationArea = Basic,Suite;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies when the task must be completed.';
                }
                field(Priority;Priority)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the priority of the task.';
                }
                field("Percent Complete";"Percent Complete")
                {
                    ApplicationArea = Basic,Suite;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the progress of the task.';
                }
                field("Assigned To User Name";"Assigned To User Name")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies who the task is assigned to.';
                }
                field("Created DateTime";"Created DateTime")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies when the task was created.';
                    Visible = false;
                }
                field("Completed DateTime";"Completed DateTime")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies when the task was completed.';
                    Visible = false;
                }
                field("Start DateTime";"Start DateTime")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies when the task must start.';
                    Visible = false;
                }
                field("Created By User Name";"Created By User Name")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies who created the task.';
                    Visible = false;
                }
                field("Completed By User Name";"Completed By User Name")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies who completed the task.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Mark Complete")
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Mark as Completed';
                Image = CheckList;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Indicate that the task is completed. The % Complete field is set to 100.';

                trigger OnAction()
                var
                    UserTask: Record "User Task";
                begin
                    CurrPage.SetSelectionFilter(UserTask);
                    if UserTask.FindSet(true) then
                      repeat
                        UserTask.SetCompleted;
                        UserTask.Modify;
                      until UserTask.Next = 0;
                end;
            }
            action("Go To Task Item")
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Go To Task Item';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Open the page or report that is associated with this task.';

                trigger OnAction()
                begin
                    RunReportOrPageLink;
                end;
            }
        }
        area(processing)
        {
            action("Delete User Tasks")
            {
                ApplicationArea = All;
                Caption = 'Delete User Tasks';
                Image = Delete;
                RunObject = Report "User Task Utility";
                ToolTip = 'Find and delete user tasks.';
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        StyleTxt := SetStyle;
    end;

    var
        StyleTxt: Text;

    procedure SetFiltersForUserTasksCue()
    var
        OriginalFilterGroup: Integer;
    begin
        OriginalFilterGroup := FilterGroup;
        FilterGroup(25);
        SetFilter("Percent Complete",'<>100');
        SetRange("Assigned To",UserSecurityId);
        FilterGroup(OriginalFilterGroup);
    end;

    local procedure RunReportOrPageLink()
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if ("Object Type" = 0) or ("Object ID" = 0) then
          exit;
        if "Object Type" = AllObjWithCaption."Object Type"::Page then
          PAGE.Run("Object ID")
        else
          REPORT.Run("Object ID");
    end;

    [ServiceEnabled]
    [Scope('Personalization')]
    procedure SetComplete()
    begin
        SetCompleted;
        Modify;
    end;
}

