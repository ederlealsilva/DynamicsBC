page 9039 "O365 Sales Activities"
{
    // version NAVW113.00

    Caption = 'Activities';
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
                CueGroupLayout = Wide;
                field("Invoiced YTD";"Invoiced YTD")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    AutoFormatExpression = CurrencyFormatTxt;
                    AutoFormatType = 10;
                    Caption = 'Sales this year';
                    ToolTip = 'Specifies the total invoiced amount for this year.';

                    trigger OnDrillDown()
                    begin
                        ShowYearlySalesOverview;
                    end;
                }
                field("Invoiced CM";"Invoiced CM")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    AutoFormatExpression = CurrencyFormatTxt;
                    AutoFormatType = 10;
                    Caption = 'Sales this month';
                    ToolTip = 'Specifies the total invoiced amount for this year.';
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        ShowMonthlySalesOverview;
                    end;
                }
            }
            cuegroup(Payments)
            {
                Caption = 'Payments';
                CueGroupLayout = Wide;
                field("Sales Invoices Outstanding";"Sales Invoices Outstanding")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    AutoFormatExpression = CurrencyFormatTxt;
                    AutoFormatType = 10;
                    Caption = 'Outstanding amount';
                    ToolTip = 'Specifies the total amount that has not yet been paid.';

                    trigger OnDrillDown()
                    begin
                        ShowInvoices(false);
                    end;
                }
                field("Sales Invoices Overdue";"Sales Invoices Overdue")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    AutoFormatExpression = CurrencyFormatTxt;
                    AutoFormatType = 10;
                    Caption = 'Overdue amount';
                    Style = Unfavorable;
                    StyleExpr = "Sales Invoices Overdue" > 0;
                    ToolTip = 'Specifies the total amount that has not been paid and is after the due date.';

                    trigger OnDrillDown()
                    begin
                        ShowInvoices(true);
                    end;
                }
            }
            cuegroup("Ongoing sales")
            {
                Caption = 'Ongoing sales';
                field(NoOfDrafts;"No. of Draft Invoices")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Caption = 'Draft invoices';
                    ToolTip = 'Specifies the number of draft invoices.';

                    trigger OnDrillDown()
                    begin
                        ShowDraftInvoices;
                    end;
                }
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
            }
            cuegroup(New)
            {
                Caption = 'New';

                actions
                {
                    action("New invoice")
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        Caption = 'New invoice';
                        Image = TileNew;
                        RunObject = Page "BC O365 Sales Invoice";
                        RunPageMode = Create;
                        ToolTip = 'Create a new invoice for the customer.';
                    }
                    action("New estimate")
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        Caption = 'New estimate';
                        Image = TileNew;
                        RunObject = Page "BC O365 Sales Quote";
                        RunPageMode = Create;
                        ToolTip = 'Create a new estimate for the customer.';
                    }
                }
            }
            cuegroup("Get started")
            {
                Caption = 'Get started';

                actions
                {
                    action(ReplayGettingStarted)
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        Caption = 'Play Getting Started';
                        Image = TileVideo;
                        ToolTip = 'Show the Getting Started guide.';

                        trigger OnAction()
                        var
                            O365GettingStarted: Record "O365 Getting Started";
                        begin
                            if O365GettingStarted.Get(UserId,ClientTypeManagement.GetCurrentClientType) then begin
                              O365GettingStarted."Tour in Progress" := false;
                              O365GettingStarted."Current Page" := 1;
                              O365GettingStarted.Modify;
                              Commit;
                            end;

                            O365GettingStartedMgt.LaunchWizard(true,false);
                        end;
                    }
                    action(SetupBusinessInfo)
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        Caption = 'Set up your information';
                        Image = TileSettings;
                        ToolTip = 'Set up your key business information';

                        trigger OnAction()
                        begin
                            PAGE.RunModal(PAGE::"BC O365 My Settings");
                        end;
                    }
                    action(CreateTestInvoice)
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        Caption = 'Send a test invoice';
                        Image = TileNew;
                        RunObject = Page "BC O365 Sales Invoice";
                        RunPageLink = "No."=CONST('TESTINVOICE');
                        RunPageMode = Create;
                        ToolTip = 'Create a new test invoice for the customer.';
                        Visible = CreateTestInvoiceVisible;
                    }
                }
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
        O365DocumentSendMgt.ShowRoleCenterEmailNotification(true);
        CreateTestInvoiceVisible := not O365SetupMgmt.ShowCreateTestInvoice;
    end;

    trigger OnOpenPage()
    begin
        OnOpenActivitiesPage(CurrencyFormatTxt);
        O365DocumentSendMgt.ShowRoleCenterEmailNotification(false);
        PrepareUserTours;
    end;

    var
        O365SetupMgmt: Codeunit "O365 Setup Mgmt";
        O365GettingStartedMgt: Codeunit "O365 Getting Started Mgt.";
        ClientTypeManagement: Codeunit ClientTypeManagement;
        O365DocumentSendMgt: Codeunit "O365 Document Send Mgt";
        [RunOnClient]
        [WithEvents]
        UserTours: DotNet UserTours;
        CurrencyFormatTxt: Text;
        CreateTestInvoiceVisible: Boolean;

    local procedure PrepareUserTours(): Boolean
    begin
        if (not UserTours.IsAvailable) or (not O365GettingStartedMgt.AreUserToursEnabled) then
          exit(false);
        UserTours := UserTours.Create;
        UserTours.NotifyShowTourWizard;
        exit(true);
    end;

    trigger UserTours::ShowTourWizard(hasTourCompleted: Boolean)
    begin
        if O365GettingStartedMgt.IsGettingStartedSupported then
          if O365GettingStartedMgt.LaunchWizard(false,hasTourCompleted) then;
    end;

    trigger UserTours::IsTourInProgressResultReady(isInProgress: Boolean)
    begin
    end;
}

