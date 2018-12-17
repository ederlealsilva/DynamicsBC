page 9077 "O365 Invoicing Activities"
{
    // version NAVW113.00

    Caption = 'Sales Activities';
    Description = 'ENU=Activites';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "O365 Sales Cue";

    layout
    {
        area(content)
        {
            cuegroup(Invoiced)
            {
                Caption = 'Invoiced';
                field("Invoiced YTD";"Invoiced YTD")
                {
                    ApplicationArea = Invoicing;
                    AutoFormatExpression = CurrencyFormatTxt;
                    AutoFormatType = 10;
                    Caption = 'Year to Date';
                    ToolTip = 'Specifies the total invoiced amount for this year.';

                    trigger OnDrillDown()
                    begin
                        ShowYearlySalesOverview;
                    end;
                }
                field("Invoiced CM";"Invoiced CM")
                {
                    ApplicationArea = Invoicing;
                    AutoFormatExpression = CurrencyFormatTxt;
                    AutoFormatType = 10;
                    Caption = 'This Month';
                    ToolTip = 'Specifies the total amount invoiced for the current month.';

                    trigger OnDrillDown()
                    begin
                        ShowMonthlySalesOverview;
                    end;
                }
            }
            cuegroup(Payments)
            {
                Caption = 'Payments';
                field("Sales Invoices Outstanding";"Sales Invoices Outstanding")
                {
                    ApplicationArea = Invoicing;
                    AutoFormatExpression = CurrencyFormatTxt;
                    AutoFormatType = 10;
                    Caption = 'Outstanding';
                    ToolTip = 'Specifies the total amount that has not yet been paid.';

                    trigger OnDrillDown()
                    begin
                        ShowInvoices(false);
                    end;
                }
                field("Sales Invoices Overdue";"Sales Invoices Overdue")
                {
                    ApplicationArea = Invoicing;
                    AutoFormatExpression = CurrencyFormatTxt;
                    AutoFormatType = 10;
                    Caption = 'Overdue';
                    ToolTip = 'Specifies the total amount that has not been paid and is after the due date.';

                    trigger OnDrillDown()
                    begin
                        ShowInvoices(true);
                    end;
                }
            }
            cuegroup(Ongoing)
            {
                Caption = 'Ongoing';
                field(NoOfQuotes;"No. of Quotes")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Caption = 'Estimates';
                    ToolTip = 'Specifies the number of estimates.';

                    trigger OnDrillDown()
                    begin
                        ShowQuotes;
                    end;
                }
                field(NoOfDrafts;"No. of Draft Invoices")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Caption = 'Invoice Drafts';
                    ToolTip = 'Specifies the number of draft invoices.';

                    trigger OnDrillDown()
                    begin
                        ShowDraftInvoices;
                    end;
                }
            }
            cuegroup("Invoice Now")
            {
                Caption = 'Invoice Now';
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    var
        RoleCenterNotificationMgt: Codeunit "Role Center Notification Mgt.";
    begin
        RoleCenterNotificationMgt.HideEvaluationNotificationAfterStartingTrial;
    end;

    trigger OnInit()
    begin
        if IdentityManagement.IsInvAppId then
          CODEUNIT.Run(CODEUNIT::"O365 Sales Initial Setup");
    end;

    trigger OnOpenPage()
    begin
        OnOpenActivitiesPage(CurrencyFormatTxt);

        if PageNotifier.IsAvailable then begin
          PageNotifier := PageNotifier.Create;
          PageNotifier.NotifyPageReady;
        end;
    end;

    var
        IdentityManagement: Codeunit "Identity Management";
        [RunOnClient]
        [WithEvents]
        PageNotifier: DotNet PageNotifier;
        CurrencyFormatTxt: Text;

    trigger PageNotifier::PageReady()
    var
        NetPromoterScoreMgt: Codeunit "Net Promoter Score Mgt.";
    begin
        NetPromoterScoreMgt.ShowNpsDialog;
    end;
}

