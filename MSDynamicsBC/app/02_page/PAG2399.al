page 2399 "BC O365 My Settings"
{
    // version NAVW113.00

    Caption = 'Settings';
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            group("Business information")
            {
                Caption = 'Business information';
                part(Control20;"O365 Business Info Settings")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                }
            }
            group(Language)
            {
                Caption = 'Language';
                Visible = LanguageVisible;
                part(Control30;"BC O365 Language Settings")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                }
            }
            group("Email account")
            {
                Caption = 'Email account';
                part(GraphMailPage;"BC O365 Graph Mail Settings")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    UpdatePropagation = Both;
                    Visible = GraphMailVisible;
                }
                part(SmtpMailPage;"BC O365 Email Account Settings")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    UpdatePropagation = Both;
                    Visible = SmtpMailVisible;
                }
            }
            group("Email settings")
            {
                Caption = 'Email settings';
                part(Control50;"BC O365 Email Settings Part")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                }
            }
            group("Invoice and estimate numbers")
            {
                Caption = 'Invoice and estimate numbers';
                part(Control61;"BC O365 No. Series Settings")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                }
            }
            group(Payments)
            {
                Caption = 'Payments';
                part(Control70;"BC O365 Payments Settings")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                }
            }
            group("Payment services")
            {
                Caption = 'Payment services';
                Visible = PaymentServicesVisible;
                part(Control100;"BC O365 Payment Services")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    UpdatePropagation = Both;
                }
            }
            group("VAT rates")
            {
                Caption = 'VAT rates';
                part(Control57;"BC O365 VAT Posting Setup List")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                }
            }
            group(Services)
            {
                Caption = 'Services';
                part(Control110;"BC O365 Service Settings")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                }
            }
            group("Intuit QuickBooks")
            {
                Caption = 'Intuit QuickBooks';
                Visible = QuickBooksVisible;
                part(Control12;"BC O365 Quickbooks Settings")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                }
            }
            group(Control18)
            {
                Caption = 'Share';
                group(Share)
                {
                    Caption = '';
                    InstructionalText = 'Share an overview of sent invoices in an email.';
                    field(ExportInvoices;ExportInvoicesLbl)
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        Editable = false;
                        ShowCaption = false;

                        trigger OnDrillDown()
                        begin
                            PAGE.RunModal(PAGE::"O365 Export Invoices");
                        end;
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetMailProviderVisibility;
    end;

    trigger OnOpenPage()
    var
        TempPaymentServiceSetup: Record "Payment Service Setup" temporary;
    begin
        TempPaymentServiceSetup.OnRegisterPaymentServiceProviders(TempPaymentServiceSetup);
        PaymentServicesVisible := not TempPaymentServiceSetup.IsEmpty;

        QuickBooksVisible := O365SalesManagement.GetQuickBooksVisible;

        SetMailProviderVisibility;
        SetLanguageVisibility;
    end;

    var
        O365SalesManagement: Codeunit "O365 Sales Management";
        PaymentServicesVisible: Boolean;
        ExportInvoicesLbl: Label 'Send overview of invoices';
        QuickBooksVisible: Boolean;
        GraphMailVisible: Boolean;
        SmtpMailVisible: Boolean;
        LanguageVisible: Boolean;

    local procedure SetMailProviderVisibility()
    var
        O365SetupEmail: Codeunit "O365 Setup Email";
        GraphMail: Codeunit "Graph Mail";
    begin
        SmtpMailVisible := (O365SetupEmail.SMTPEmailIsSetUp and (not GraphMail.IsEnabled)) or (not GraphMail.HasConfiguration);
        GraphMailVisible := not SmtpMailVisible;
    end;

    local procedure SetLanguageVisibility()
    var
        TempLanguage: Record "Windows Language" temporary;
        LanguageManagement: Codeunit LanguageManagement;
    begin
        LanguageManagement.GetApplicationLanguages(TempLanguage);
        LanguageVisible := TempLanguage.Count > 1;
    end;
}

