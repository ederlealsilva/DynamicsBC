table 92 "Customer Posting Group"
{
    // version NAVW113.00

    Caption = 'Customer Posting Group';
    LookupPageID = "Customer Posting Groups";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2;"Receivables Account";Code[20])
        {
            Caption = 'Receivables Account';
            TableRelation = "G/L Account";

            trigger OnLookup()
            begin
                GLAccountCategoryMgt.LookupGLAccount(
                  "Receivables Account",GLAccountCategory."Account Category"::Assets,GLAccountCategoryMgt.GetAR);
            end;

            trigger OnValidate()
            begin
                GLAccountCategoryMgt.CheckGLAccount(
                  "Receivables Account",false,false,GLAccountCategory."Account Category"::Assets,GLAccountCategoryMgt.GetAR);
            end;
        }
        field(7;"Service Charge Acc.";Code[20])
        {
            Caption = 'Service Charge Acc.';
            TableRelation = "G/L Account";

            trigger OnLookup()
            begin
                GLAccountCategoryMgt.LookupGLAccount(
                  "Service Charge Acc.",GLAccountCategory."Account Category"::Income,GLAccountCategoryMgt.GetIncomeService);
            end;

            trigger OnValidate()
            begin
                GLAccountCategoryMgt.CheckGLAccount(
                  "Service Charge Acc.",true,true,GLAccountCategory."Account Category"::Income,GLAccountCategoryMgt.GetIncomeService);
            end;
        }
        field(8;"Payment Disc. Debit Acc.";Code[20])
        {
            Caption = 'Payment Disc. Debit Acc.';
            TableRelation = "G/L Account";

            trigger OnLookup()
            begin
                GLAccountCategoryMgt.LookupGLAccount("Payment Disc. Debit Acc.",GLAccountCategory."Account Category"::Expense,'');
            end;

            trigger OnValidate()
            begin
                GLAccountCategoryMgt.CheckGLAccount("Payment Disc. Debit Acc.",false,false,GLAccountCategory."Account Category"::Expense,'');
            end;
        }
        field(9;"Invoice Rounding Account";Code[20])
        {
            Caption = 'Invoice Rounding Account';
            TableRelation = "G/L Account";

            trigger OnLookup()
            begin
                GLAccountCategoryMgt.LookupGLAccount("Invoice Rounding Account",GLAccountCategory."Account Category"::Income,'');
            end;

            trigger OnValidate()
            begin
                GLAccountCategoryMgt.CheckGLAccount("Invoice Rounding Account",true,false,GLAccountCategory."Account Category"::Income,'');
            end;
        }
        field(10;"Additional Fee Account";Code[20])
        {
            Caption = 'Additional Fee Account';
            TableRelation = "G/L Account";

            trigger OnLookup()
            begin
                GLAccountCategoryMgt.LookupGLAccount("Additional Fee Account",GLAccountCategory."Account Category"::Income,'');
            end;

            trigger OnValidate()
            begin
                GLAccountCategoryMgt.CheckGLAccount("Additional Fee Account",true,true,GLAccountCategory."Account Category"::Income,'');
            end;
        }
        field(11;"Interest Account";Code[20])
        {
            Caption = 'Interest Account';
            TableRelation = "G/L Account";

            trigger OnLookup()
            begin
                GLAccountCategoryMgt.LookupGLAccount("Interest Account",GLAccountCategory."Account Category"::Income,'');
            end;

            trigger OnValidate()
            begin
                GLAccountCategoryMgt.CheckGLAccount("Interest Account",true,false,GLAccountCategory."Account Category"::Income,'');
            end;
        }
        field(12;"Debit Curr. Appln. Rndg. Acc.";Code[20])
        {
            Caption = 'Debit Curr. Appln. Rndg. Acc.';
            TableRelation = "G/L Account";

            trigger OnLookup()
            begin
                GLAccountCategoryMgt.LookupGLAccount("Debit Curr. Appln. Rndg. Acc.",GLAccountCategory."Account Category"::Income,'');
            end;

            trigger OnValidate()
            begin
                GLAccountCategoryMgt.CheckGLAccount(
                  "Debit Curr. Appln. Rndg. Acc.",false,false,GLAccountCategory."Account Category"::Income,'');
            end;
        }
        field(13;"Credit Curr. Appln. Rndg. Acc.";Code[20])
        {
            Caption = 'Credit Curr. Appln. Rndg. Acc.';
            TableRelation = "G/L Account";

            trigger OnLookup()
            begin
                GLAccountCategoryMgt.LookupGLAccount("Credit Curr. Appln. Rndg. Acc.",GLAccountCategory."Account Category"::Income,'');
            end;

            trigger OnValidate()
            begin
                GLAccountCategoryMgt.CheckGLAccount(
                  "Credit Curr. Appln. Rndg. Acc.",false,false,GLAccountCategory."Account Category"::Income,'');
            end;
        }
        field(14;"Debit Rounding Account";Code[20])
        {
            Caption = 'Debit Rounding Account';
            TableRelation = "G/L Account";

            trigger OnLookup()
            begin
                GLAccountCategoryMgt.LookupGLAccount("Debit Rounding Account",GLAccountCategory."Account Category"::Income,'');
            end;

            trigger OnValidate()
            begin
                GLAccountCategoryMgt.CheckGLAccount(
                  "Debit Rounding Account",false,false,GLAccountCategory."Account Category"::Income,'');
            end;
        }
        field(15;"Credit Rounding Account";Code[20])
        {
            Caption = 'Credit Rounding Account';
            TableRelation = "G/L Account";

            trigger OnLookup()
            begin
                GLAccountCategoryMgt.LookupGLAccount("Credit Rounding Account",GLAccountCategory."Account Category"::Income,'');
            end;

            trigger OnValidate()
            begin
                GLAccountCategoryMgt.CheckGLAccount(
                  "Credit Rounding Account",false,false,GLAccountCategory."Account Category"::Income,'');
            end;
        }
        field(16;"Payment Disc. Credit Acc.";Code[20])
        {
            Caption = 'Payment Disc. Credit Acc.';
            TableRelation = "G/L Account";

            trigger OnLookup()
            begin
                GLAccountCategoryMgt.LookupGLAccount("Payment Disc. Credit Acc.",GLAccountCategory."Account Category"::Expense,'');
            end;

            trigger OnValidate()
            begin
                GLAccountCategoryMgt.CheckGLAccount("Payment Disc. Credit Acc.",false,false,GLAccountCategory."Account Category"::Expense,'');
            end;
        }
        field(17;"Payment Tolerance Debit Acc.";Code[20])
        {
            Caption = 'Payment Tolerance Debit Acc.';
            TableRelation = "G/L Account";

            trigger OnLookup()
            begin
                GLAccountCategoryMgt.LookupGLAccount("Payment Tolerance Debit Acc.",GLAccountCategory."Account Category"::Expense,'');
            end;

            trigger OnValidate()
            begin
                GLAccountCategoryMgt.CheckGLAccount(
                  "Payment Tolerance Debit Acc.",false,false,GLAccountCategory."Account Category"::Expense,'');
            end;
        }
        field(18;"Payment Tolerance Credit Acc.";Code[20])
        {
            Caption = 'Payment Tolerance Credit Acc.';
            TableRelation = "G/L Account";

            trigger OnLookup()
            begin
                GLAccountCategoryMgt.LookupGLAccount(
                  "Payment Tolerance Debit Acc.",GLAccountCategory."Account Category"::Expense,GLAccountCategoryMgt.GetInterestExpense);
            end;

            trigger OnValidate()
            begin
                GLAccountCategoryMgt.CheckGLAccount(
                  "Payment Tolerance Debit Acc.",false,false,
                  GLAccountCategory."Account Category"::Expense,GLAccountCategoryMgt.GetInterestExpense);
            end;
        }
        field(19;"Add. Fee per Line Account";Code[20])
        {
            Caption = 'Add. Fee per Line Account';
            TableRelation = "G/L Account";

            trigger OnLookup()
            begin
                GLAccountCategoryMgt.LookupGLAccount("Add. Fee per Line Account",GLAccountCategory."Account Category"::Income,'');
            end;

            trigger OnValidate()
            begin
                GLAccountCategoryMgt.CheckGLAccount("Add. Fee per Line Account",true,false,GLAccountCategory."Account Category"::Income,'');
            end;
        }
        field(20;Description;Text[50])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Brick;"Code")
        {
        }
    }

    trigger OnDelete()
    begin
        CheckCustEntries;
    end;

    var
        GLSetup: Record "General Ledger Setup";
        GLAccountCategory: Record "G/L Account Category";
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
        PostingSetupMgt: Codeunit PostingSetupManagement;
        YouCannotDeleteErr: Label 'You cannot delete %1.', Comment='%1 = Code';

    local procedure CheckCustEntries()
    var
        Customer: Record Customer;
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        Customer.SetRange("Customer Posting Group",Code);
        if not Customer.IsEmpty then
          Error(YouCannotDeleteErr,Code);

        CustLedgerEntry.SetRange("Customer Posting Group",Code);
        if not CustLedgerEntry.IsEmpty then
          Error(YouCannotDeleteErr,Code);
    end;

    [Scope('Personalization')]
    procedure GetReceivablesAccount(): Code[20]
    begin
        if "Receivables Account" = '' then
          PostingSetupMgt.SendCustPostingGroupNotification(Rec,FieldCaption("Receivables Account"));
        TestField("Receivables Account");
        exit("Receivables Account");
    end;

    [Scope('Personalization')]
    procedure GetPmtDiscountAccount(Debit: Boolean): Code[20]
    begin
        if Debit then begin
          if "Payment Disc. Debit Acc." = '' then
            PostingSetupMgt.SendCustPostingGroupNotification(Rec,FieldCaption("Payment Disc. Debit Acc."));
          TestField("Payment Disc. Debit Acc.");
          exit("Payment Disc. Debit Acc.");
        end;
        if "Payment Disc. Credit Acc." = '' then
          PostingSetupMgt.SendCustPostingGroupNotification(Rec,FieldCaption("Payment Disc. Credit Acc."));
        TestField("Payment Disc. Credit Acc.");
        exit("Payment Disc. Credit Acc.");
    end;

    [Scope('Personalization')]
    procedure GetPmtToleranceAccount(Debit: Boolean): Code[20]
    begin
        if Debit then begin
          if "Payment Tolerance Debit Acc." = '' then
            PostingSetupMgt.SendCustPostingGroupNotification(Rec,FieldCaption("Payment Tolerance Debit Acc."));
          TestField("Payment Tolerance Debit Acc.");
          exit("Payment Tolerance Debit Acc.");
        end;
        if "Payment Tolerance Credit Acc." = '' then
          PostingSetupMgt.SendCustPostingGroupNotification(Rec,FieldCaption("Payment Tolerance Credit Acc."));
        TestField("Payment Tolerance Credit Acc.");
        exit("Payment Tolerance Credit Acc.");
    end;

    [Scope('Personalization')]
    procedure GetRoundingAccount(Debit: Boolean): Code[20]
    begin
        if Debit then begin
          if "Debit Rounding Account" = '' then
            PostingSetupMgt.SendCustPostingGroupNotification(Rec,FieldCaption("Debit Rounding Account"));
          TestField("Debit Rounding Account");
          exit("Debit Rounding Account");
        end;
        if "Credit Rounding Account" = '' then
          PostingSetupMgt.SendCustPostingGroupNotification(Rec,FieldCaption("Credit Rounding Account"));
        TestField("Credit Rounding Account");
        exit("Credit Rounding Account");
    end;

    [Scope('Personalization')]
    procedure GetApplRoundingAccount(Debit: Boolean): Code[20]
    begin
        if Debit then begin
          if "Debit Curr. Appln. Rndg. Acc." = '' then
            PostingSetupMgt.SendCustPostingGroupNotification(Rec,FieldCaption("Debit Curr. Appln. Rndg. Acc."));
          TestField("Debit Curr. Appln. Rndg. Acc.");
          exit("Debit Curr. Appln. Rndg. Acc.");
        end;
        if "Credit Curr. Appln. Rndg. Acc." = '' then
          PostingSetupMgt.SendCustPostingGroupNotification(Rec,FieldCaption("Credit Curr. Appln. Rndg. Acc."));
        TestField("Credit Curr. Appln. Rndg. Acc.");
        exit("Credit Curr. Appln. Rndg. Acc.");
    end;

    [Scope('Personalization')]
    procedure GetInvRoundingAccount(): Code[20]
    begin
        if "Invoice Rounding Account" = '' then
          PostingSetupMgt.SendCustPostingGroupNotification(Rec,FieldCaption("Invoice Rounding Account"));
        TestField("Invoice Rounding Account");
        exit("Invoice Rounding Account");
    end;

    [Scope('Personalization')]
    procedure GetServiceChargeAccount(): Code[20]
    begin
        if "Service Charge Acc." = '' then
          PostingSetupMgt.SendCustPostingGroupNotification(Rec,FieldCaption("Service Charge Acc."));
        TestField("Service Charge Acc.");
        exit("Service Charge Acc.");
    end;

    [Scope('Personalization')]
    procedure GetAdditionalFeeAccount(): Code[20]
    begin
        if "Additional Fee Account" = '' then
          PostingSetupMgt.SendCustPostingGroupNotification(Rec,FieldCaption("Additional Fee Account"));
        TestField("Additional Fee Account");
        exit("Additional Fee Account");
    end;

    [Scope('Personalization')]
    procedure GetAddFeePerLineAccount(): Code[20]
    begin
        if "Add. Fee per Line Account" = '' then
          PostingSetupMgt.SendCustPostingGroupNotification(Rec,FieldCaption("Add. Fee per Line Account"));
        TestField("Add. Fee per Line Account");
        exit("Add. Fee per Line Account");
    end;

    [Scope('Personalization')]
    procedure GetInterestAccount(): Code[20]
    begin
        if "Interest Account" = '' then
          PostingSetupMgt.SendCustPostingGroupNotification(Rec,FieldCaption("Interest Account"));
        TestField("Interest Account");
        exit("Interest Account");
    end;

    procedure SetAccountVisibility(var PmtToleranceVisible: Boolean;var PmtDiscountVisible: Boolean;var InvRoundingVisible: Boolean;var ApplnRoundingVisible: Boolean)
    var
        SalesSetup: Record "Sales & Receivables Setup";
        PaymentTerms: Record "Payment Terms";
    begin
        GLSetup.Get;
        PmtToleranceVisible := GLSetup."Payment Tolerance %" > 0;
        PmtDiscountVisible := PaymentTerms.UsePaymentDiscount;

        SalesSetup.Get;
        InvRoundingVisible := SalesSetup."Invoice Rounding";
        ApplnRoundingVisible := SalesSetup."Appln. between Currencies" <> SalesSetup."Appln. between Currencies"::None;
    end;
}

