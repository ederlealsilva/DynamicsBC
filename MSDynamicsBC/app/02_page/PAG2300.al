page 2300 "BC O365 Getting Started"
{
    // version NAVW113.00

    Caption = 'Getting started';
    PageType = NavigatePage;
    SourceTable = "O365 Getting Started";

    layout
    {
        area(content)
        {
            group(Control3)
            {
                ShowCaption = false;
                Visible = CurrentPage;
                group(Control4)
                {
                    ShowCaption = false;
                    usercontrol(WelcomeWizard;"Microsoft.Dynamics.Nav.Client.WelcomeWizard")
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(CreateTestInvoice)
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Caption = 'Try it out and send yourself a test invoice';
                InFooterBar = true;
                Promoted = true;
                RunObject = Page "BC O365 Sales Invoice";
                RunPageLink = "No."=CONST('TESTINVOICE');
                RunPageMode = Create;
                ToolTip = 'Create a new test invoice for the customer.';
                Visible = CreateTestInvoiceVisible;

                trigger OnAction()
                begin
                    CurrPage.Close;
                end;
            }
            action("Get Started")
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Caption = 'Got it';
                InFooterBar = true;
                Promoted = true;

                trigger OnAction()
                begin
                    CurrPage.Close;
                end;
            }
        }
    }

    trigger OnClosePage()
    begin
        "Tour in Progress" := false;
        "Tour Completed" := true;
        Modify;
    end;

    trigger OnInit()
    begin
        SetRange("User ID",UserId);
        CreateTestInvoiceVisible := not O365SetupMgmt.ShowCreateTestInvoice;
    end;

    trigger OnOpenPage()
    begin
        if not AlreadyShown then
          MarkAsShown;

        CurrentPage := true;
    end;

    var
        O365SetupMgmt: Codeunit "O365 Setup Mgmt";
        TitleTxt: Label 'Welcome to %1', Comment='%1 is the branding PRODUCTNAME.MARKETING string constant';
        SubTitleTxt: Label 'An easy-to-use online app for sending professional looking invoices to customers';
        IntroTxt: Label 'Introduction';
        IntroDescTxt: Label 'Get to know %1', Comment='%1 is the branding PRODUCTNAME.MARKETING string constant';
        SendInvoicesTxt: Label 'Send invoices';
        SendInvoicesDescTxt: Label 'Send your first invoice to a customer';
        PaymentsTxt: Label 'Payments';
        PaymentsDescTxt: Label 'Get paid faster with online payments';
        SettingsTxt: Label 'Setup';
        SettingsDescTxt: Label 'Set up key information about your business';
        CurrentPage: Boolean;
        CreateTestInvoiceVisible: Boolean;
        GettingStartedCategoryLbl: Label 'AL Getting Started', Comment='{LOCKED}';
        IntroTelemetryTxt: Label 'Introduction video was played.', Comment='{LOCKED}';
        SendInvoicesTelemetryTxt: Label 'Send invoices video was played.', Comment='{LOCKED}';
        PaymentsTelemetryTxt: Label 'Payments video was played.', Comment='{LOCKED}';
        SetupTelemetryTxt: Label 'Setup was clicked from Getting Started.', Comment='{LOCKED}';
}

