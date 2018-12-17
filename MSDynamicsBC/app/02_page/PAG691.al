page 691 "Send-to Programs"
{
    // version NAVW113.00

    Caption = 'Send-to Programs';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Send-To Program";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Program ID";"Program ID")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Program ID';
                    ToolTip = 'Specifies the ID of the program to send data to from Business Central.';
                    Visible = false;
                }
                field(Executable;Executable)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Executable';
                    ToolTip = 'Specifies the name of the executable file that launches the program.';

                    trigger OnValidate()
                    begin
                        TestField(Executable);
                        CreateNewGUID;
                        if Name = '' then
                          Name := Executable;
                    end;
                }
                field(Name;Name)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Name';
                    ToolTip = 'Specifies the name of the program to send data to from Business Central.';
                }
                field(Parameter;Parameter)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Parameter';
                    ToolTip = 'Specifies the parameter to send to the program from Business Central.';
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207;Links)
            {
                Visible = false;
            }
            systempart(Control1905767507;Notes)
            {
                Visible = false;
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if IsNullGuid("Program ID") then
          CreateNewGUID;
        Parameter := '%1';
    end;

    local procedure CreateNewGUID()
    begin
        case UpperCase(Executable) of
          'WINWORD.EXE':
            "Program ID" := '{000209FF-0000-0000-C000-000000000046}';  // defined in fin.stx
          'EXCEL.EXE':
            "Program ID" := '{00024500-0000-0000-C000-000000000046}';  // defined in fin.stx
          else
            "Program ID" := CreateGuid;
        end;
    end;
}

