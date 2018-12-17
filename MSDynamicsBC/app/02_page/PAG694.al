page 694 "Style Sheets"
{
    // version NAVW113.00

    Caption = 'Style Sheets';
    DataCaptionExpression = StrSubstNo(text001,SendToProgramName,AllObjWithCaption."Object Caption");
    Editable = false;
    PageType = List;
    SourceTable = "Style Sheet";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Name;Name)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Name';
                    ToolTip = 'Specifies the name of the style sheet that you want to import to another program.';
                }
                field(Date;Date)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Date';
                    ToolTip = 'Specifies the date that a style sheet was added to the table.';
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

    var
        AllObjWithCaption: Record AllObjWithCaption;
        text001: Label '%1 Style Sheets for %2';
        SendToProgramName: Text[250];

    [Scope('Personalization')]
    procedure SetParams(NewObjectID: Integer;NewSendToProgramName: Text[250])
    begin
        if not AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Page,NewObjectID) then
          AllObjWithCaption.Init;
        SendToProgramName := NewSendToProgramName;
    end;
}

