page 5133 "Close Opportunity Codes"
{
    // version NAVW113.00

    ApplicationArea = RelationshipMgmt;
    Caption = 'Close Opportunity Codes';
    DelayedInsert = true;
    PageType = List;
    PopulateAllFields = true;
    SourceTable = "Close Opportunity Code";
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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for closing the opportunity.';
                }
                field(Type;Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the opportunity was a success or a failure.';
                }
                field(Description;Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the reason for closing the opportunity.';
                }
                field("No. of Opportunities";"No. of Opportunities")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the number of opportunities closed using this close opportunity code. This field is not editable.';
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

    trigger OnOpenPage()
    begin
        if GetFilters <> '' then
          CurrPage.Editable(false);
    end;
}

