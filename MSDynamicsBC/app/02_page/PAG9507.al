page 9507 "Debugger Breakpoint Condition"
{
    // version NAVW110.0

    Caption = 'Debugger Breakpoint Condition';
    DataCaptionExpression = DataCaption;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = StandardDialog;
    ShowFilter = false;
    SourceTable = "Debugger Breakpoint";

    layout
    {
        area(content)
        {
            group("Conditional Breakpoint")
            {
                InstructionalText = 'Enter a C/AL expression. When the debugger reaches the breakpoint, it evaluates the expression and code execution breaks only if the expression is true. Example: Amount > 0', Comment='Description text for the Condition field.';
                field(Condition;Condition)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the condition that is set on the breakpoint.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        CalcFields("Object Name");
        DataCaption := StrSubstNo(Text001,"Object Type","Object ID","Object Name","Line No.");
    end;

    var
        DataCaption: Text[100];
        Text001: Label '%1 %2 : %3, Line %4', Comment='Breakpoint text for the Data Caption: %1 = Object Type, %2 = Object ID, %3 = Object Name, %4 = Line No.';
}

