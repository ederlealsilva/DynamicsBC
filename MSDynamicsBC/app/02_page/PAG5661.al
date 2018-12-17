page 5661 "FA Date Types"
{
    // version NAVW110.0

    Caption = 'FA Date Types';
    Editable = false;
    PageType = List;
    SourceTable = "FA Date Type";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("FA Date Type Name";"FA Date Type Name")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the name of the fixed asset data type.';
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

