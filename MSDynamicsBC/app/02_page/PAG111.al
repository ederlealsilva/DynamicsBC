page 111 "Vendor Posting Groups"
{
    // version NAVW113.00

    ApplicationArea = Basic,Suite;
    Caption = 'Vendor Posting Groups';
    CardPageID = "Vendor Posting Group Card";
    PageType = List;
    SourceTable = "Vendor Posting Group";
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
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies an identifier for the vendor posting group.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the description for the vendor posting group.';
                }
                field("Payables Account";"Payables Account")
                {
                    ApplicationArea = Basic,Suite;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the general ledger account to use when you post payables due to vendors in this posting group.';
                }
                field("Service Charge Acc.";"Service Charge Acc.")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the general ledger account to use when you post service charges due to vendors in this posting group.';
                }
                field("Payment Disc. Debit Acc.";"Payment Disc. Debit Acc.")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the general ledger account to use when you post reductions in payment discounts received from vendors in this posting group.';
                    Visible = PmtDiscountVisible;
                }
                field("Payment Disc. Credit Acc.";"Payment Disc. Credit Acc.")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the general ledger account to use when you post payment discounts received from vendors in this posting group.';
                    Visible = PmtDiscountVisible;
                }
                field("Invoice Rounding Account";"Invoice Rounding Account")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the general ledger account to use when amounts result from invoice rounding when you post transactions that involve vendors.';
                    Visible = InvRoundingVisible;
                }
                field("Debit Curr. Appln. Rndg. Acc.";"Debit Curr. Appln. Rndg. Acc.")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the general ledger account to use when you post rounding differences. These differences can occur when you apply entries in different currencies to one another.';
                    Visible = ApplnRoundingVisible;
                }
                field("Credit Curr. Appln. Rndg. Acc.";"Credit Curr. Appln. Rndg. Acc.")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the general ledger account to use when you post rounding differences. These differences can occur when you apply entries in different currencies to one another.';
                    Visible = ApplnRoundingVisible;
                }
                field("Debit Rounding Account";"Debit Rounding Account")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the general ledger account number to use when you post rounding differences from a remaining amount.';
                }
                field("Credit Rounding Account";"Credit Rounding Account")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the general ledger account number to use when you post rounding differences from a remaining amount.';
                }
                field("Payment Tolerance Debit Acc.";"Payment Tolerance Debit Acc.")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the general ledger account number to use when you post purchase tolerance amounts and payments for purchases. This applies to this particular combination of business posting group and product posting group.';
                    Visible = PmtToleranceVisible;
                }
                field("Payment Tolerance Credit Acc.";"Payment Tolerance Credit Acc.")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the general ledger account number to use when you post purchase tolerance amounts and payments for purchases. This applies to this particular combination of business posting group and product posting group.';
                    Visible = PmtToleranceVisible;
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
        SetAccountVisibility(PmtToleranceVisible,PmtDiscountVisible,InvRoundingVisible,ApplnRoundingVisible);
    end;

    var
        PmtDiscountVisible: Boolean;
        PmtToleranceVisible: Boolean;
        InvRoundingVisible: Boolean;
        ApplnRoundingVisible: Boolean;
}

