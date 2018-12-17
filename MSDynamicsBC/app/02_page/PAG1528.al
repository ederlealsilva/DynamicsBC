page 1528 "Workflow Status FactBox"
{
    // version NAVW111.00

    Caption = 'Workflows';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    ShowFilter = false;
    SourceTable = "Workflow Step Instance";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(WorkflowDescription;WorkflowDescription)
                {
                    ApplicationArea = Suite;
                    Caption = 'Active Workflows';
                    ToolTip = 'Specifies the number of enabled workflows that are currently running.';

                    trigger OnDrillDown()
                    var
                        TempWorkflowStepInstance: Record "Workflow Step Instance" temporary;
                    begin
                        TempWorkflowStepInstance.BuildTempWorkflowTree(ID);
                        PAGE.RunModal(PAGE::"Workflow Overview",TempWorkflowStepInstance);
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        if Workflow.Get("Workflow Code") then
          WorkflowDescription := Workflow.Description;
    end;

    trigger OnAfterGetRecord()
    begin
        if Workflow.Get("Workflow Code") then
          WorkflowDescription := Workflow.Description;
    end;

    var
        Workflow: Record Workflow;
        WorkflowDescription: Text;

    [Scope('Personalization')]
    procedure SetFilterOnWorkflowRecord(WorkflowStepRecID: RecordID): Boolean
    var
        WorkflowStepInstance: Record "Workflow Step Instance";
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
        InstanceID: Guid;
        "Filter": Text;
    begin
        WorkflowStepInstance.SetRange("Record ID",WorkflowStepRecID);
        if not WorkflowStepInstance.FindSet then
          exit(false);

        repeat
          if WorkflowStepInstance.ID <> InstanceID then
            WorkflowStepInstance.Mark(true);
          InstanceID := WorkflowStepInstance.ID;
        until WorkflowStepInstance.Next = 0;

        WorkflowStepInstance.MarkedOnly(true);
        Filter := SelectionFilterManagement.GetSelectionFilterForWorkflowStepInstance(WorkflowStepInstance);
        if Filter = '' then
          exit(false);

        Reset;
        SetRange("Record ID",WorkflowStepRecID);
        SetFilter("Original Workflow Step ID",Filter);
        CurrPage.Update(false);
        exit(FindSet);
    end;
}

