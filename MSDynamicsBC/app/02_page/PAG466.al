page 466 "Tax Jurisdictions"
{
    // version NAVW113.00

    Caption = 'Tax Jurisdictions';
    PageType = List;
    SourceTable = "Tax Jurisdiction";

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
                    ToolTip = 'Specifies the code you want to assign to this tax jurisdiction. You can enter up to 10 characters, both numbers and letters. It is a good idea to enter a code that is easy to remember.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies a description of the tax jurisdiction. For example, if the tax jurisdiction code is ATLANTA GA, enter the description as Atlanta, Georgia.';
                }
                field("Default Sales and Use Tax";DefaultTax)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Default Sales and Use Tax';
                    Enabled = DefaultTaxIsEnabled;
                    Style = Subordinate;
                    StyleExpr = NOT DefaultTaxIsEnabled;
                    ToolTip = 'Specifies the default tax in locations where the sales tax and use tax are identical.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        TaxDetail: Record "Tax Detail";
                    begin
                        GetDefaultTaxDetail(TaxDetail);
                        PAGE.RunModal(PAGE::"Tax Details",TaxDetail);
                        DefaultTax := GetDefaultTax;
                    end;

                    trigger OnValidate()
                    begin
                        SetDefaultTax(DefaultTax);
                    end;
                }
                field("Calculate Tax on Tax";"Calculate Tax on Tax")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies whether to calculate the sales tax amount with the tax on tax principle.';
                    Visible = false;
                }
                field("Unrealized VAT Type";"Unrealized VAT Type")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies how to handle unrealized tax, which is tax that is calculated but not due until the invoice is paid.';
                    Visible = false;
                }
                field("Adjust for Payment Discount";"Adjust for Payment Discount")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies whether to recalculate tax amounts when you post payments that trigger payment discounts.';
                    Visible = false;
                }
                field("Tax Account (Sales)";"Tax Account (Sales)")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the general ledger account you want to use for posting calculated tax on sales transactions.';
                }
                field("Unreal. Tax Acc. (Sales)";"Unreal. Tax Acc. (Sales)")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the general ledger account you want to use for posting calculated unrealized tax on sales transactions.';
                    Visible = false;
                }
                field("Tax Account (Purchases)";"Tax Account (Purchases)")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the general ledger account you want to use for posting calculated tax on purchase transactions.';
                }
                field("Reverse Charge (Purchases)";"Reverse Charge (Purchases)")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the general ledger account you want to use for posting calculated reverse-charge tax on purchase transactions.';
                }
                field("Unreal. Tax Acc. (Purchases)";"Unreal. Tax Acc. (Purchases)")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the general ledger account you want to use for posting calculated unrealized tax on purchase transactions.';
                    Visible = false;
                }
                field("Unreal. Rev. Charge (Purch.)";"Unreal. Rev. Charge (Purch.)")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the general ledger account you want to use for posting calculated unrealized reverse-charge tax on purchase transactions.';
                    Visible = false;
                }
                field("Report-to Jurisdiction";"Report-to Jurisdiction")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the tax jurisdiction you want to associate with the jurisdiction you are setting up. For example, if you are setting up a jurisdiction for Atlanta, Georgia, the report-to jurisdiction is Georgia because Georgia is the tax authority to which you report Atlanta sales tax.';
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
        area(navigation)
        {
            group("&Jurisdiction")
            {
                Caption = '&Jurisdiction';
                Image = ViewDetails;
                action("Ledger &Entries")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Ledger &Entries';
                    Image = CustomerLedger;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    RunObject = Page "VAT Entries";
                    RunPageLink = "Tax Jurisdiction Code"=FIELD(Code);
                    RunPageView = SORTING("Tax Jurisdiction Code");
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'View Tax entries, which result from posting transactions in journals and sales and purchase documents, and from the Calc. and Post Tax Settlement batch job.';
                }
                action(Details)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Details';
                    Image = View;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "Tax Details";
                    RunPageLink = "Tax Jurisdiction Code"=FIELD(Code);
                    ToolTip = 'View tax-detail entries. A tax-detail entry includes all of the information that is used to calculate the amount of tax to be charged.';
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        DefaultTax := GetDefaultTax;
    end;

    trigger OnAfterGetRecord()
    begin
        DefaultTax := GetDefaultTax;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        TaxSetup: Record "Tax Setup";
    begin
        TaxSetup.Get;
        DefaultTax := 0;
        DefaultTaxIsEnabled := TaxSetup."Auto. Create Tax Details";
    end;

    var
        DefaultTax: Decimal;
        DefaultTaxIsEnabled: Boolean;

    local procedure GetDefaultTax(): Decimal
    var
        TaxDetail: Record "Tax Detail";
    begin
        GetDefaultTaxDetail(TaxDetail);
        exit(TaxDetail."Tax Below Maximum");
    end;

    local procedure SetDefaultTax(NewTaxBelowMaximum: Decimal)
    var
        TaxDetail: Record "Tax Detail";
    begin
        GetDefaultTaxDetail(TaxDetail);
        TaxDetail."Tax Below Maximum" := NewTaxBelowMaximum;
        TaxDetail.Modify;
    end;

    local procedure GetDefaultTaxDetail(var TaxDetail: Record "Tax Detail")
    begin
        TaxDetail.SetRange("Tax Jurisdiction Code",Code);
        TaxDetail.SetRange("Tax Group Code",'');
        TaxDetail.SetRange("Tax Type",TaxDetail."Tax Type"::"Sales Tax");
        if TaxDetail.FindLast then begin
          DefaultTaxIsEnabled := true;
          TaxDetail.SetRange("Effective Date",TaxDetail."Effective Date");
          TaxDetail.FindLast;
        end else begin
          DefaultTaxIsEnabled := false;
          TaxDetail.SetRange("Effective Date");
        end;
    end;
}

