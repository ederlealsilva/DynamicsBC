page 7381 "Phys. Invt. Counting Periods"
{
    // version NAVW113.00

    ApplicationArea = Basic,Suite,Warehouse;
    Caption = 'Physical Inventory Counting Periods';
    PageType = List;
    SourceTable = "Phys. Invt. Counting Period";
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
                    ToolTip = 'Specifies a code for physical inventory counting period.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies a description of the physical inventory counting period.';
                }
                field("Count Frequency per Year";"Count Frequency per Year")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the number of times you want the item or stockkeeping unit to be counted each year.';
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

