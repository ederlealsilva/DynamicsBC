page 5351 "CRM Quote List"
{
    // version NAVW113.00

    ApplicationArea = Suite;
    Caption = 'Quotes - Microsoft Dynamics 365 for Sales';
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Dynamics 365 for Sales';
    SourceTable = "CRM Quote";
    SourceTableView = SORTING(Name);
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name;Name)
                {
                    ApplicationArea = Suite;
                    Caption = 'Name';
                    ToolTip = 'Specifies the name of the record.';
                }
                field(StateCode;StateCode)
                {
                    ApplicationArea = Suite;
                    Caption = 'Status';
                    OptionCaption = 'Draft,Active,Won,Closed';
                    ToolTip = 'Specifies information related to the Dynamics 365 for Sales connection. ';
                }
                field(TotalAmount;TotalAmount)
                {
                    ApplicationArea = Suite;
                    Caption = 'Total Amount';
                    ToolTip = 'Specifies information related to the Dynamics 365 for Sales connection. ';
                }
                field(EffectiveFrom;EffectiveFrom)
                {
                    ApplicationArea = Suite;
                    Caption = 'Effective From';
                    ToolTip = 'Specifies which date the sales quote is valid from.';
                }
                field(EffectiveTo;EffectiveTo)
                {
                    ApplicationArea = Suite;
                    Caption = 'Effective To';
                    ToolTip = 'Specifies which date the sales quote is valid to.';
                }
                field(ClosedOn;ClosedOn)
                {
                    ApplicationArea = Suite;
                    Caption = 'Closed On';
                    ToolTip = 'Specifies the date when quote was closed.';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(ActionGroupCRM)
            {
                Caption = 'Dynamics 365 for Sales';
                action(CRMGoToQuote)
                {
                    ApplicationArea = Suite;
                    Caption = 'Quote';
                    Image = CoupledQuote;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ToolTip = 'Open the selected Dynamics 365 for Sales quote.';

                    trigger OnAction()
                    var
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                    begin
                        HyperLink(CRMIntegrationManagement.GetCRMEntityUrlFromCRMID(DATABASE::"CRM Quote",QuoteId));
                    end;
                }
            }
        }
    }

    trigger OnInit()
    begin
        CODEUNIT.Run(CODEUNIT::"CRM Integration Management");
    end;
}

