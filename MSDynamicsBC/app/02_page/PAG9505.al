page 9505 "Debugger Breakpoint List"
{
    // version NAVW111.00

    Caption = 'Debugger Breakpoint List';
    DelayedInsert = true;
    LinksAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Conditions For Break';
    RefreshOnActivate = true;
    SourceTable = "Debugger Breakpoint";
    SourceTableView = SORTING("Object Type","Object ID","Line No.","Column No.")
                      ORDER(Ascending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Object Type";"Object Type")
                {
                    ApplicationArea = All;
                    Caption = 'Object Type';
                    ToolTip = 'Specifies the type of the object where the breakpoint is set.';
                }
                field("Object ID";"Object ID")
                {
                    ApplicationArea = All;
                    Caption = 'Object ID';
                    ToolTip = 'Specifies the ID of the object on which the breakpoint is set.';
                }
                field("Object Name";"Object Name")
                {
                    ApplicationArea = All;
                    Caption = 'Object Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of the object in which the breakpoint is set.';
                }
                field("Line No.";"Line No.")
                {
                    ApplicationArea = All;
                    Caption = 'Line No.';
                    ToolTip = 'Specifies the line of code within the object on which the breakpoint is set. This is the absolute line number for lines of code in the object.';
                }
                field("Function Name";"Function Name")
                {
                    ApplicationArea = All;
                    Caption = 'Function Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of the function.';
                }
                field(Enabled;Enabled)
                {
                    ApplicationArea = All;
                    Caption = 'Enabled';
                    ToolTip = 'Specifies if the breakpoint is enabled.';
                }
                field(Condition;Condition)
                {
                    ApplicationArea = All;
                    Caption = 'Condition';
                    ToolTip = 'Specifies the condition that is set on the breakpoint.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            separator(Separator3)
            {
            }
            group(Breakpoint)
            {
                Caption = 'Breakpoint';
                action(Enable)
                {
                    ApplicationArea = All;
                    Caption = 'Enable';
                    Image = EnableBreakpoint;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Enable the selected breakpoints.';

                    trigger OnAction()
                    var
                        DebuggerBreakpoint: Record "Debugger Breakpoint";
                    begin
                        CurrPage.SetSelectionFilter(DebuggerBreakpoint);
                        DebuggerBreakpoint.ModifyAll(Enabled,true,true);
                    end;
                }
                action(Disable)
                {
                    ApplicationArea = All;
                    Caption = 'Disable';
                    Image = DisableBreakpoint;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Disable the selected breakpoints.';

                    trigger OnAction()
                    var
                        DebuggerBreakpoint: Record "Debugger Breakpoint";
                    begin
                        CurrPage.SetSelectionFilter(DebuggerBreakpoint);
                        DebuggerBreakpoint.ModifyAll(Enabled,false,true);
                    end;
                }
                action("Enable All")
                {
                    ApplicationArea = All;
                    Caption = 'Enable All';
                    Image = EnableAllBreakpoints;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Enable all breakpoints in the breakpoint list.';

                    trigger OnAction()
                    begin
                        ModifyAll(Enabled,true,true);
                    end;
                }
                action("Disable All")
                {
                    ApplicationArea = All;
                    Caption = 'Disable All';
                    Image = DisableAllBreakpoints;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Disable all breakpoints in the breakpoint list.';

                    trigger OnAction()
                    begin
                        ModifyAll(Enabled,false,true);
                    end;
                }
                action("Delete All")
                {
                    ApplicationArea = All;
                    Caption = 'Delete All';
                    Image = DeleteAllBreakpoints;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Delete all breakpoints in the breakpoint list.';

                    trigger OnAction()
                    var
                        DebuggerBreakpoint: Record "Debugger Breakpoint";
                    begin
                        if not Confirm(Text000,false) then
                          exit;

                        DebuggerBreakpoint.DeleteAll(true);
                    end;
                }
            }
        }
    }

    var
        Text000: Label 'Are you sure that you want to delete all breakpoints?', Comment='Asked when choosing the Delete All action for breakpoints.';
}

