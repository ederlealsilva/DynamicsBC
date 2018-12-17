page 5719 "Sub. Conditions"
{
    // version NAVW113.00

    AutoSplitKey = true;
    Caption = 'Sub. Conditions';
    Editable = false;
    PageType = List;
    SourceTable = "Substitution Condition";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Condition;Condition)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the condition for item substitution.';
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

