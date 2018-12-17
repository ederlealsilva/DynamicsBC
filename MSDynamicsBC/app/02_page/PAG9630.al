page 9630 "Page Fields Selection List"
{
    // version NAVW111.00

    Caption = 'Select Field';
    Editable = false;
    PageType = List;
    SourceTable = "Page Table Field";

    layout
    {
        area(content)
        {
            repeater(Control2)
            {
                ShowCaption = false;
                field(Caption;Caption)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Name';
                    ToolTip = 'Specifies the primary name associated with the field.';
                }
            }
        }
    }

    actions
    {
    }
}

