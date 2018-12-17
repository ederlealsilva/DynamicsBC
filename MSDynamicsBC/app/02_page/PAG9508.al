page 9508 "Debugger Variable List"
{
    // version NAVW111.00

    Caption = 'Debugger Variable List';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Watch';
    SourceTable = "Debugger Variable";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = Indentation;
                ShowAsTree = true;
                field(Name;Name)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    ToolTip = 'Specifies the name of the variable that has been added to the Debugger Variable List.';
                }
                field(Value;Value)
                {
                    ApplicationArea = All;
                    Caption = 'Value';
                    ToolTip = 'Specifies the value of the variable that has been added to the Debugger Variable List.';
                }
                field(Type;Type)
                {
                    ApplicationArea = All;
                    Caption = 'Type';
                    ToolTip = 'Specifies the type of the variable that has been added to the Debugger Variable List.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            separator(Separator9)
            {
            }
            action("Add Watch")
            {
                ApplicationArea = All;
                Caption = 'Add Watch';
                Image = AddWatch;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                ShortCutKey = 'Ctrl+Insert';
                ToolTip = 'Add the selected variable to the watch list.';

                trigger OnAction()
                var
                    DebuggerManagement: Codeunit "Debugger Management";
                begin
                    DebuggerManagement.AddWatch(Path,false);
                end;
            }
        }
    }
}

