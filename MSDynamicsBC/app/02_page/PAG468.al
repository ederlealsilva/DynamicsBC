page 468 "Tax Details"
{
    // version NAVW111.00

    Caption = 'Tax Details';
    DataCaptionFields = "Tax Jurisdiction Code","Tax Group Code";
    PageType = List;
    SourceTable = "Tax Detail";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Tax Jurisdiction Code";"Tax Jurisdiction Code")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the tax jurisdiction code for the tax-detail entry.';
                }
                field("Tax Group Code";"Tax Group Code")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the tax group code for the tax-detail entry.';
                }
                field("Tax Type";"Tax Type")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the type of tax (Sales Tax or Excise Tax) that applies to the tax-detail entry.';
                }
                field("Effective Date";"Effective Date")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies a date on which the tax-detail entry will go into effect. This allows you to set up tax details in advance.';
                }
                field("Tax Below Maximum";"Tax Below Maximum")
                {
                    ApplicationArea = Basic,Suite;
                    MinValue = 0;
                    ToolTip = 'Specifies the percentage that will be used to calculate tax for all amounts or quantities below the maximum amount quantity in the Maximum Amount/Qty. field.';
                }
                field("Maximum Amount/Qty.";"Maximum Amount/Qty.")
                {
                    ApplicationArea = Basic,Suite;
                    MinValue = 0;
                    ToolTip = 'Specifies a maximum amount or quantity. The program finds the appropriate tax percentage in either the Tax Below Maximum or the Tax Above Maximum field.';
                }
                field("Tax Above Maximum";"Tax Above Maximum")
                {
                    ApplicationArea = Basic,Suite;
                    MinValue = 0;
                    ToolTip = 'Specifies the percentage that will be used to calculate tax for all amounts or quantities above the maximum amount quantity in the Maximum Amount/Qty. field.';
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
            group("&Detail")
            {
                Caption = '&Detail';
                Image = View;
                action("Ledger &Entries")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Ledger &Entries';
                    Image = VATLedger;
                    Promoted = false;
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'View Tax entries, which result from posting transactions in journals and sales and purchase documents, and from the Calc. and Post Tax Settlement batch job.';

                    trigger OnAction()
                    var
                        VATEntry: Record "VAT Entry";
                    begin
                        VATEntry.SetCurrentKey("Tax Jurisdiction Code","Tax Group Used","Tax Type","Use Tax","Posting Date");
                        VATEntry.SetRange("Tax Jurisdiction Code","Tax Jurisdiction Code");
                        VATEntry.SetRange("Tax Group Used","Tax Group Code");
                        VATEntry.SetRange("Tax Type","Tax Type");
                        PAGE.Run(PAGE::"VAT Entries",VATEntry);
                    end;
                }
            }
        }
    }
}

