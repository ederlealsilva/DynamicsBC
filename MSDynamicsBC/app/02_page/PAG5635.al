page 5635 "FA Posting Types"
{
    // version NAVW110.0

    Caption = 'FA Posting Types';
    Editable = false;
    PageType = List;
    SourceTable = "FA Posting Type";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("FA Posting Type Name";"FA Posting Type Name")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the name of the fixed asset posting type.';
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

