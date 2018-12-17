page 1508 "Workflow Categories"
{
    // version NAVW113.00

    ApplicationArea = Suite;
    Caption = 'Workflow Categories';
    PageType = List;
    SourceTable = "Workflow Category";
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
                    ToolTip = 'Specifies the code for the workflow category.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the workflow category.';
                }
            }
        }
    }

    actions
    {
    }
}

