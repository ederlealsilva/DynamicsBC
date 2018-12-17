page 9078 "User Tasks Activities"
{
    // version NAVW111.00

    Caption = 'User Tasks Activities';
    PageType = CardPart;
    SourceTable = "User Task";

    layout
    {
        area(content)
        {
            cuegroup("My User Tasks")
            {
                Caption = 'My User Tasks';
                field(VarPendingTasksCount;VarPendingTasksCount)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Pending User Tasks';
                    DrillDownPageID = "User Task List";
                    Image = Checklist;
                    ToolTip = 'Specifies the number of pending tasks that are assigned to you.';

                    trigger OnDrillDown()
                    var
                        UserTaskList: Page "User Task List";
                    begin
                        UserTaskList.SetFiltersForUserTasksCue;
                        UserTaskList.Run;
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        SetRange("Assigned To",UserSecurityId);
        SetFilter("Percent Complete",'<>100');
        VarPendingTasksCount := Count;
        Reset;
    end;

    var
        VarPendingTasksCount: Integer;
}

