page 99000807 "Standard Task Descript. Sheet"
{
    // version NAVW113.00

    AutoSplitKey = true;
    Caption = 'Standard Task Descript. Sheet';
    DataCaptionFields = "Standard Task Code";
    MultipleNewLines = true;
    PageType = List;
    SourceTable = "Standard Task Description";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Text;Text)
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the text for the standard task description.';
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

