page 7703 Miniforms
{
    // version NAVW113.00

    ApplicationArea = ADCS;
    Caption = 'Miniforms';
    CardPageID = Miniform;
    Editable = false;
    PageType = List;
    SourceTable = "Miniform Header";
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
                    ApplicationArea = ADCS;
                    ToolTip = 'Specifies a unique code for a specific miniform.';
                }
                field(Description;Description)
                {
                    ApplicationArea = ADCS;
                    ToolTip = 'Specifies your description of the miniform with the code on the header.';
                }
                field("No. of Records in List";"No. of Records in List")
                {
                    ApplicationArea = ADCS;
                    ToolTip = 'Specifies the number of records that will be sent to the handheld if the miniform on the header is either Selection List or Data List.';
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

