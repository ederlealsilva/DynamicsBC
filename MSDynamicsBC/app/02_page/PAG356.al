page 356 Printers
{
    // version NAVW113.00

    Caption = 'Printers';
    Editable = false;
    PageType = List;
    SourceTable = Printer;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(ID;ID)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the ID that applies.';
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
}

