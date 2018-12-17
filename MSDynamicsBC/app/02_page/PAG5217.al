page 5217 "Employment Contracts"
{
    // version NAVW113.00

    ApplicationArea = Advanced;
    Caption = 'Employment Contracts';
    PageType = List;
    SourceTable = "Employment Contract";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code";Code)
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies a code for the employment contract.';
                }
                field(Description;Description)
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies a description for the employment contract.';
                }
                field("No. of Contracts";"No. of Contracts")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the number of contracts associated with the entry.';
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

