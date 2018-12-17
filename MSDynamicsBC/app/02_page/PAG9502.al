page 9502 "Debugger Callstack FactBox"
{
    // version NAVW113.00

    Caption = 'Debugger Callstack';
    Editable = false;
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "Debugger Call Stack";

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
                    ToolTip = 'Specifies the name of the object in which the breakpoint is set.';
                }
                field("Function Name";"Function Name")
                {
                    ApplicationArea = All;
                    Caption = 'Function Name';
                    ToolTip = 'Specifies the name of the function.';
                }
                field("Line No.";"Line No.")
                {
                    ApplicationArea = All;
                    Caption = 'Line No.';
                    ToolTip = 'Specifies the line number of the function call that led to the current line of code.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        if Update and (ID = 1) then begin
          SetRange(ID);
          Update := false;
        end;
        CurrentCallstack := Rec;
    end;

    var
        CurrentCallstack: Record "Debugger Call Stack";
        Update: Boolean;

    procedure GetCurrentCallstack(var CurrentCallstackRec: Record "Debugger Call Stack")
    begin
        CurrentCallstackRec := CurrentCallstack;
    end;

    [Scope('Personalization')]
    procedure ResetCallstackToTop()
    begin
        if CurrentCallstack.ID <> 1 then begin
          SetRange(ID,1,1);
          CurrPage.Update;
          Update := true;
        end;
    end;
}

