page 1533 "Workflow User Groups"
{
    // version NAVW113.00

    ApplicationArea = Suite;
    Caption = 'Workflow User Groups';
    CardPageID = "Workflow User Group";
    PageType = List;
    SourceTable = "Workflow User Group";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the workflow user group.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the workflow user group.';
                }
            }
        }
    }

    actions
    {
    }
}

