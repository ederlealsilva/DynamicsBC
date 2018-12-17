page 9153 "My Accounts"
{
    // version NAVW111.00

    Caption = 'My Accounts';
    PageType = ListPart;
    SourceTable = "My Account";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Account No.";"Account No.")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the G/L account number.';

                    trigger OnValidate()
                    begin
                        GetGLAccount;
                    end;
                }
                field(Name;Name)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Name';
                    DrillDown = false;
                    Lookup = false;
                    ToolTip = 'Specifies the name of the cash account.';
                }
                field(Balance;GLAccount.Balance)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Balance';
                    ToolTip = 'Specifies the balance on the bank account.';

                    trigger OnDrillDown()
                    var
                        GLEntry: Record "G/L Entry";
                        GLAccountsFilterText: Text;
                    begin
                        GetGLAccount;
                        GLAccountsFilterText := GLAccount."No.";
                        if GLAccount.IsTotaling then
                          GLAccountsFilterText := GLAccount.Totaling;
                        GLEntry.SetFilter("G/L Account No.",GLAccountsFilterText);
                        PAGE.Run(0,GLEntry);
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Open)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Open';
                Image = ViewDetails;
                RunObject = Page "G/L Account Card";
                RunPageLink = "No."=FIELD("Account No.");
                RunPageMode = View;
                RunPageView = SORTING("No.");
                ShortCutKey = 'Return';
                ToolTip = 'Open the card for the selected record.';
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        GetGLAccount;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(GLAccount);
    end;

    trigger OnOpenPage()
    begin
        SetRange("User ID",UserId);
    end;

    var
        GLAccount: Record "G/L Account";

    local procedure GetGLAccount()
    begin
        Clear(GLAccount);
        if GLAccount.Get("Account No.") then
          GLAccount.CalcFields(Balance);
    end;
}

