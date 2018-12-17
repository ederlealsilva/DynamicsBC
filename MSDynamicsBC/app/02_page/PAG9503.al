page 9503 "Debugger Watch Value FactBox"
{
    // version NAVW113.00

    Caption = 'Debugger Watch Value';
    Editable = false;
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "Debugger Watch Value";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name;Name)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    ToolTip = 'Specifies the name of the variable that has been added to the Debugger Watch Value FactBox.';
                }
                field(Value;Value)
                {
                    ApplicationArea = All;
                    Caption = 'Value';
                    ToolTip = 'Specifies the value of variables for which you have specified to add a watch.';
                }
                field(Type;Type)
                {
                    ApplicationArea = All;
                    Caption = 'Type';
                    ToolTip = 'Specifies the type of variables for which you have specified to add a watch.';
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
            action("Delete Watch")
            {
                ApplicationArea = All;
                Caption = 'Delete Watch';
                Image = Delete;
                ShortCutKey = 'Ctrl+Delete';
                ToolTip = 'Delete the selected variables from the watch list.';

                trigger OnAction()
                var
                    DebuggerWatch: Record "Debugger Watch";
                    DebuggerWatchValue: Record "Debugger Watch Value";
                    DebuggerWatchValueTemp: Record "Debugger Watch Value" temporary;
                begin
                    CurrPage.SetSelectionFilter(DebuggerWatchValue);

                    // Copy the selected records to take a snapshot of the watches,
                    // otherwise the DELETEALL would dynamically change the Debugger Watch Value primary keys
                    // causing incorrect records to be deleted.

                    if DebuggerWatchValue.Find('-') then
                      repeat
                        DebuggerWatchValueTemp := DebuggerWatchValue;
                        DebuggerWatchValueTemp.Insert;
                      until DebuggerWatchValue.Next = 0;

                    if DebuggerWatchValueTemp.Find('-') then begin
                      repeat
                        DebuggerWatch.SetRange(Path,DebuggerWatchValueTemp.Name);
                        DebuggerWatch.DeleteAll(true);
                      until DebuggerWatchValueTemp.Next = 0;
                    end;
                end;
            }
        }
    }
}

