page 9 Languages
{
    // version NAVW113.00

    ApplicationArea = Suite;
    Caption = 'Languages';
    PageType = List;
    SourceTable = Language;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code";Code)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the code for a language.';
                }
                field(Name;Name)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the name of the language.';
                }
                field("Windows Language ID";"Windows Language ID")
                {
                    ApplicationArea = Basic,Suite;
                    LookupPageID = "Windows Languages";
                    ToolTip = 'Specifies the ID of the Windows language associated with the language code you have set up in this line.';
                }
                field("Windows Language Name";"Windows Language Name")
                {
                    ApplicationArea = Basic,Suite;
                    DrillDown = false;
                    ToolTip = 'Specifies if you enter an ID in the Windows Language ID field.';
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

