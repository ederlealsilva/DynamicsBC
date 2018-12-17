page 7705 "Miniform Functions"
{
    // version NAVW113.00

    Caption = 'Miniform Functions';
    PageType = List;
    SourceTable = "Miniform Function";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Miniform Code";"Miniform Code")
                {
                    ApplicationArea = ADCS;
                    Editable = false;
                    ToolTip = 'Specifies the miniform that has a function assigned to it.';
                    Visible = false;
                }
                field("Function Code";"Function Code")
                {
                    ApplicationArea = ADCS;
                    ToolTip = 'Specifies the code of the function that is assigned to the miniform.';
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

