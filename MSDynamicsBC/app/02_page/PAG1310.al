page 1310 "O365 Activities"
{
    // version NAVW113.00

    Caption = 'Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    ShowFilter = false;
    SourceTable = "Activities Cue";

    layout
    {
        area(content)
        {
            cuegroup("Intelligent Cloud")
            {
                Caption = 'Intelligent Cloud';
                Visible = ShowIntelligentCloud;

                actions
                {
                    action("Learn More")
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Learn More';
                        Image = TileInfo;
                        RunObject = Page "Intelligent Cloud";
                        RunPageMode = View;
                        ToolTip = ' Learn more about the Intelligent Cloud and how it can help your business.';
                    }
                    action("<Intelligent Cloud Insights>")
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Intelligent Cloud Insights';
                        Image = TileCloud;
                        RunPageMode = View;
                        ToolTip = 'View your Intelligent Cloud insights.';

                        trigger OnAction()
                        var
                            IntelligentCloud: Page "Intelligent Cloud";
                        begin
                            HyperLink(IntelligentCloud.GetIntelligentCloudInsightsUrl);
                        end;
                    }
                }
            }
            cuegroup(Control54)
            {
                CueGroupLayout = Wide;
                ShowCaption = false;
                field("Sales This Month";"Sales This Month")
                {
                    ApplicationArea = Basic,Suite;
                    DrillDownPageID = "Sales Invoice List";
                    ToolTip = 'Specifies the sum of sales in the current month.';

                    trigger OnDrillDown()
                    begin
                        ActivitiesMgt.DrillDownSalesThisMonth;
                    end;
                }
                field("Overdue Sales Invoice Amount";"Overdue Sales Invoice Amount")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the sum of overdue payments from customers.';

                    trigger OnDrillDown()
                    begin
                        ActivitiesMgt.DrillDownCalcOverdueSalesInvoiceAmount;
                    end;
                }
                field("Overdue Purch. Invoice Amount";"Overdue Purch. Invoice Amount")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the sum of your overdue payments to vendors.';

                    trigger OnDrillDown()
                    begin
                        ActivitiesMgt.DrillDownOverduePurchaseInvoiceAmount;
                    end;
                }
            }
            cuegroup(Welcome)
            {
                Caption = 'Welcome';
                Visible = TileGettingStartedVisible;

                actions
                {
                    action(GettingStartedTile)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Return to Getting Started';
                        Image = TileVideo;
                        ToolTip = 'Learn how to get started with Dynamics 365.';

                        trigger OnAction()
                        begin
                            O365GettingStartedMgt.LaunchWizard(true,false);
                        end;
                    }
                }
            }
            cuegroup("Ongoing Sales")
            {
                Caption = 'Ongoing Sales';
                field("Ongoing Sales Quotes";"Ongoing Sales Quotes")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Sales Quotes';
                    DrillDownPageID = "Sales Quotes";
                    ToolTip = 'Specifies sales quotes that have not yet been converted to invoices or orders.';
                }
                field("Ongoing Sales Orders";"Ongoing Sales Orders")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Sales Orders';
                    DrillDownPageID = "Sales Order List";
                    ToolTip = 'Specifies sales orders that are not yet posted or only partially posted.';
                }
                field("Ongoing Sales Invoices";"Ongoing Sales Invoices")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Sales Invoices';
                    DrillDownPageID = "Sales Invoice List";
                    ToolTip = 'Specifies sales invoices that are not yet posted or only partially posted.';
                }
                field("Uninvoiced Bookings";"Uninvoiced Bookings")
                {
                    ApplicationArea = Basic,Suite;
                    Enabled = ShowBookings;
                    Visible = ShowBookings;

                    trigger OnDrillDown()
                    var
                        BookingManager: Codeunit "Booking Manager";
                    begin
                        BookingManager.InvoiceBookingItems;
                    end;
                }
            }
            cuegroup("Document Exchange Service")
            {
                Caption = 'Document Exchange Service';
                Visible = ShowDocumentsPendingDocExchService;
                field("Sales Inv. - Pending Doc.Exch.";"Sales Inv. - Pending Doc.Exch.")
                {
                    ApplicationArea = Suite;
                    DrillDownPageID = "Posted Sales Invoices";
                    ToolTip = 'Specifies sales invoices that await sending to the customer through the document exchange service.';
                    Visible = ShowDocumentsPendingDocExchService;
                }
                field("Sales CrM. - Pending Doc.Exch.";"Sales CrM. - Pending Doc.Exch.")
                {
                    ApplicationArea = Suite;
                    DrillDownPageID = "Posted Sales Credit Memos";
                    ToolTip = 'Specifies sales credit memos that await sending to the customer through the document exchange service.';
                    Visible = ShowDocumentsPendingDocExchService;
                }
            }
            cuegroup("Ongoing Purchases")
            {
                Caption = 'Ongoing Purchases';
                field("Purchase Orders";"Purchase Orders")
                {
                    ApplicationArea = Suite;
                    DrillDownPageID = "Purchase Order List";
                    ToolTip = 'Specifies purchases orders that are not posted or only partially posted.';
                }
                field("Ongoing Purchase Invoices";"Ongoing Purchase Invoices")
                {
                    ApplicationArea = Basic,Suite;
                    DrillDownPageID = "Purchase Invoices";
                    ToolTip = 'Specifies purchases invoices that are not posted or only partially posted.';
                }
                field("Purch. Invoices Due Next Week";"Purch. Invoices Due Next Week")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the number of payments to vendors that are due next week.';
                }
            }
            cuegroup(Approvals)
            {
                Caption = 'Approvals';
                Visible = false;
                field("Requests to Approve";"Requests to Approve")
                {
                    ApplicationArea = Suite;
                    DrillDownPageID = "Requests to Approve";
                    ToolTip = 'Specifies the number of approval requests that require your approval.';
                }
            }
            cuegroup(Intercompany)
            {
                Caption = 'Intercompany';
                Visible = ShowIntercompanyActivities;
                field("IC Inbox Transactions";"IC Inbox Transactions")
                {
                    ApplicationArea = Intercompany;
                    Caption = 'Pending Inbox Transactions';
                    DrillDownPageID = "IC Inbox Transactions";
                    Visible = "IC Inbox Transactions" <> 0;
                }
                field("IC Outbox Transactions";"IC Outbox Transactions")
                {
                    ApplicationArea = Intercompany;
                    Caption = 'Pending Outbox Transactions';
                    DrillDownPageID = "IC Outbox Transactions";
                    Visible = "IC Outbox Transactions" <> 0;
                }
            }
            cuegroup(Payments)
            {
                Caption = 'Payments';
                field("Non-Applied Payments";"Non-Applied Payments")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Unprocessed Payments';
                    Image = Cash;
                    ToolTip = 'Specifies imported bank transactions for payments that are not yet reconciled in the Payment Reconciliation Journal window.';

                    trigger OnDrillDown()
                    begin
                        CODEUNIT.Run(CODEUNIT::"Pmt. Rec. Journals Launcher");
                    end;
                }
                field("Average Collection Days";"Average Collection Days")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies how long customers took to pay invoices in the last three months. This is the average number of days from when invoices are issued to when customers pay the invoices.';
                }
                field("Outstanding Vendor Invoices";"Outstanding Vendor Invoices")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the number of invoices from your vendors that have not been paid yet.';
                }
            }
            cuegroup(Camera)
            {
                Caption = 'Camera';
                Visible = HasCamera;

                actions
                {
                    action(CreateIncomingDocumentFromCamera)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Create Incoming Doc. from Camera';
                        Image = TileCamera;
                        ToolTip = 'Create an incoming document by taking a photo of the document with your mobile device camera. The photo will be attached to the new document.';

                        trigger OnAction()
                        var
                            CameraOptions: DotNet CameraOptions;
                        begin
                            if not HasCamera then
                              exit;

                            CameraOptions := CameraOptions.CameraOptions;
                            CameraOptions.Quality := 100; // 100%
                            CameraProvider.RequestPictureAsync(CameraOptions);
                        end;
                    }
                }
            }
            cuegroup("Incoming Documents")
            {
                Caption = 'Incoming Documents';
                field("My Incoming Documents";"My Incoming Documents")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies incoming documents that are assigned to you.';
                }
                field("Awaiting Verfication";"Inc. Doc. Awaiting Verfication")
                {
                    ApplicationArea = Suite;
                    DrillDown = true;
                    ToolTip = 'Specifies incoming documents in OCR processing that require you to log on to the OCR service website to manually verify the OCR values before the documents can be received.';
                    Visible = ShowAwaitingIncomingDoc;

                    trigger OnDrillDown()
                    var
                        OCRServiceSetup: Record "OCR Service Setup";
                    begin
                        if OCRServiceSetup.Get then
                          if OCRServiceSetup.Enabled then
                            HyperLink(OCRServiceSetup."Sign-in URL");
                    end;
                }
            }
            cuegroup("My User Tasks")
            {
                Caption = 'My User Tasks';
                field("Pending Tasks";"Pending Tasks")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Pending User Tasks';
                    DrillDownPageID = "User Task List";
                    Image = Checklist;
                    ToolTip = 'Specifies the number of pending tasks that are assigned to you.';
                }
            }
            cuegroup(Start)
            {
                Caption = 'Start';

                actions
                {
                    action("Sales Quote")
                    {
                        AccessByPermission = TableData "Sales Header"=IMD;
                        ApplicationArea = Basic,Suite;
                        Caption = 'Sales Quote';
                        Image = TileNew;
                        RunObject = Page "Sales Quote";
                        RunPageMode = Create;
                        ToolTip = 'Offer items or services to a customer.';
                    }
                    action("Sales Order")
                    {
                        AccessByPermission = TableData "Sales Header"=IMD;
                        ApplicationArea = Basic,Suite;
                        Caption = 'Sales Order';
                        Image = TileNew;
                        RunObject = Page "Sales Order";
                        RunPageMode = Create;
                        ToolTip = 'Create a new sales order for items or services that require partial posting or order confirmation.';
                    }
                    action("Sales Invoice")
                    {
                        AccessByPermission = TableData "Sales Header"=IMD;
                        ApplicationArea = Basic,Suite;
                        Caption = 'Sales Invoice';
                        Image = TileNew;
                        RunObject = Page "Sales Invoice";
                        RunPageMode = Create;
                        ToolTip = 'Create a new invoice for the sales of items or services. Invoice quantities cannot be posted partially.';
                    }
                    action("Purchase Invoice")
                    {
                        AccessByPermission = TableData "Purchase Header"=IMD;
                        ApplicationArea = Basic,Suite;
                        Caption = 'Purchase Invoice';
                        Image = TileNew;
                        RunObject = Page "Purchase Invoice";
                        RunPageMode = Create;
                        ToolTip = 'Create a new purchase invoice for items or services.';
                    }
                    action("Sales Return Order")
                    {
                        AccessByPermission = TableData "Sales Header"=IMD;
                        ApplicationArea = SalesReturnOrder;
                        Caption = 'Sales Return Order';
                        Image = TileNew;
                        RunObject = Page "Sales Return Order";
                        RunPageMode = Create;
                        ToolTip = 'Create a new sales return order for items or services.';
                    }
                }
            }
            cuegroup("Product Videos")
            {
                Caption = 'Product Videos';
                Visible = ShowProductVideosActivities;

                actions
                {
                    action("Product Videos")
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Product Videos';
                        Image = TileVideo;
                        RunObject = Page "Product Videos";
                        ToolTip = 'Open a list of videos that showcase some of the product capabilities.';
                    }
                }
            }
            cuegroup("Get started")
            {
                Caption = 'Get started';
                Visible = ReplayGettingStartedVisible;

                actions
                {
                    action(ShowStartInMyCompany)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Try with my own data';
                        Image = TileSettings;
                        ToolTip = 'Set up My Company with the settings you choose. We''ll show you how, it''s easy.';
                        Visible = false;

                        trigger OnAction()
                        begin
                            if UserTours.IsAvailable and O365GettingStartedMgt.AreUserToursEnabled then
                              UserTours.StartUserTour(O365GettingStartedMgt.GetChangeCompanyTourID);
                        end;
                    }
                    action(ReplayGettingStarted)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Replay Getting Started';
                        Image = TileVideo;
                        ToolTip = 'Show the Getting Started guide again.';

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
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Set Up Cues")
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Set Up Cues';
                Image = Setup;
                ToolTip = 'Set up the cues (status tiles) related to the role.';

                trigger OnAction()
                var
                    CueRecordRef: RecordRef;
                begin
                    CueRecordRef.GetTable(Rec);
                    CueSetup.OpenCustomizePageForCurrentUser(CueRecordRef.Number);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        RoleCenterNotificationMgt: Codeunit "Role Center Notification Mgt.";
    begin
        if UserTours.IsAvailable and O365GettingStartedMgt.AreUserToursEnabled then
          O365GettingStartedMgt.UpdateGettingStartedVisible(TileGettingStartedVisible,ReplayGettingStartedVisible);
        RoleCenterNotificationMgt.HideEvaluationNotificationAfterStartingTrial;
    end;

    trigger OnAfterGetRecord()
    var
        DocExchServiceSetup: Record "Doc. Exch. Service Setup";
    begin
        CalculateCueFieldValues;
        ShowDocumentsPendingDocExchService := false;
        if DocExchServiceSetup.Get then
          ShowDocumentsPendingDocExchService := DocExchServiceSetup.Enabled;
        SetActivityGroupVisibility;
    end;

    trigger OnInit()
    begin
        if UserTours.IsAvailable and O365GettingStartedMgt.AreUserToursEnabled then
          O365GettingStartedMgt.UpdateGettingStartedVisible(TileGettingStartedVisible,ReplayGettingStartedVisible);
    end;

    trigger OnOpenPage()
    var
        BookingSync: Record "Booking Sync";
        OCRServiceMgt: Codeunit "OCR Service Mgt.";
        RoleCenterNotificationMgt: Codeunit "Role Center Notification Mgt.";
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
    begin
        Reset;
        if not Get then begin
          Init;
          Insert;
          Commit;
        end;
        SetFilter("Due Date Filter",'>=%1',WorkDate);
        SetFilter("Overdue Date Filter",'<%1',WorkDate);
        SetFilter("Due Next Week Filter",'%1..%2',CalcDate('<1D>',WorkDate),CalcDate('<1W>',WorkDate));
        SetRange("User ID Filter",UserId);

        HasCamera := CameraProvider.IsAvailable;
        if HasCamera then
          CameraProvider := CameraProvider.Create;

        PrepareOnLoadDialog;

        ShowBookings := BookingSync.IsSetup;
        ShowAwaitingIncomingDoc := OCRServiceMgt.OcrServiceIsEnable;
        ShowIntercompanyActivities := true;
        ShowProductVideosActivities := ClientTypeManagement.GetCurrentClientType <> CLIENTTYPE::Phone;
        ShowIntelligentCloud := not PermissionManager.SoftwareAsAService;

        RoleCenterNotificationMgt.ShowNotifications;
        ConfPersonalizationMgt.OnRoleCenterOpen;
    end;

    var
        ActivitiesMgt: Codeunit "Activities Mgt.";
        CueSetup: Codeunit "Cue Setup";
        O365GettingStartedMgt: Codeunit "O365 Getting Started Mgt.";
        ClientTypeManagement: Codeunit ClientTypeManagement;
        PermissionManager: Codeunit "Permission Manager";
        [RunOnClient]
        [WithEvents]
        CameraProvider: DotNet CameraProvider;
        [RunOnClient]
        [WithEvents]
        UserTours: DotNet UserTours;
        [RunOnClient]
        [WithEvents]
        PageNotifier: DotNet PageNotifier;
        HasCamera: Boolean;
        ShowBookings: Boolean;
        ShowDocumentsPendingDocExchService: Boolean;
        ShowAwaitingIncomingDoc: Boolean;
        ShowIntercompanyActivities: Boolean;
        ShowProductVideosActivities: Boolean;
        ShowIntelligentCloud: Boolean;
        TileGettingStartedVisible: Boolean;
        ReplayGettingStartedVisible: Boolean;
        HideNpsDialog: Boolean;
        WhatIsNewTourVisible: Boolean;

    local procedure CalculateCueFieldValues()
    begin
        if FieldActive("Overdue Sales Invoice Amount") then
          "Overdue Sales Invoice Amount" := ActivitiesMgt.CalcOverdueSalesInvoiceAmount(false);
        if FieldActive("Overdue Purch. Invoice Amount") then
          "Overdue Purch. Invoice Amount" := ActivitiesMgt.CalcOverduePurchaseInvoiceAmount(false);
        if FieldActive("Sales This Month") then
          "Sales This Month" := ActivitiesMgt.CalcSalesThisMonthAmount(false);
        if FieldActive("Top 10 Customer Sales YTD") then
          "Top 10 Customer Sales YTD" := ActivitiesMgt.CalcTop10CustomerSalesRatioYTD;
        if FieldActive("Average Collection Days") then
          "Average Collection Days" := ActivitiesMgt.CalcAverageCollectionDays;
        if FieldActive("Uninvoiced Bookings") then
          "Uninvoiced Bookings" := ActivitiesMgt.CalcUninvoicedBookings;
    end;

    local procedure SetActivityGroupVisibility()
    begin
        ShowIntercompanyActivities := ("IC Inbox Transactions" <> 0) or ("IC Outbox Transactions" <> 0);
    end;

    local procedure StartWhatIsNewTour(hasTourCompleted: Boolean)
    var
        O365UserTours: Record "User Tours";
        TourID: Integer;
    begin
        TourID := O365GettingStartedMgt.GetWhatIsNewTourID;

        if O365UserTours.AlreadyCompleted(TourID) then
          exit;

        if (not hasTourCompleted) and (not PermissionManager.IsPreview) then begin
          UserTours.StartUserTour(TourID);
          WhatIsNewTourVisible := true;
          exit;
        end;

        if WhatIsNewTourVisible then begin
          O365UserTours.MarkAsCompleted(TourID);
          WhatIsNewTourVisible := false;
        end;
    end;

    local procedure PrepareOnLoadDialog()
    begin
        if PrepareUserTours then
          exit;
        PreparePageNotifier;
    end;

    local procedure PreparePageNotifier()
    begin
        if not PageNotifier.IsAvailable then
          exit;
        PageNotifier := PageNotifier.Create;
        PageNotifier.NotifyPageReady;
    end;

    local procedure PrepareUserTours(): Boolean
    var
        NetPromoterScore: Record "Net Promoter Score";
    begin
        if (not UserTours.IsAvailable) or (not O365GettingStartedMgt.AreUserToursEnabled) then
          exit(false);
        UserTours := UserTours.Create;
        UserTours.NotifyShowTourWizard;
        if O365GettingStartedMgt.IsGettingStartedSupported then begin
          HideNpsDialog := O365GettingStartedMgt.WizardHasToBeLaunched(false);
          if HideNpsDialog then
            NetPromoterScore.DisableRequestSending;
        end;
        exit(true);
    end;

    trigger CameraProvider::PictureAvailable(PictureName: Text;PictureFilePath: Text)
    var
        IncomingDocument: Record "Incoming Document";
    begin
        IncomingDocument.CreateIncomingDocumentFromServerFile(PictureName,PictureFilePath);
        CurrPage.Update;
    end;

    trigger UserTours::ShowTourWizard(hasTourCompleted: Boolean)
    var
        NetPromoterScoreMgt: Codeunit "Net Promoter Score Mgt.";
    begin
        if O365GettingStartedMgt.IsGettingStartedSupported then
          if O365GettingStartedMgt.LaunchWizard(false,hasTourCompleted) then
            exit;

        if (not hasTourCompleted) and (not HideNpsDialog) then
          if NetPromoterScoreMgt.ShowNpsDialog then begin
            HideNpsDialog := true;
            exit;
          end;

        StartWhatIsNewTour(hasTourCompleted);
    end;

    trigger UserTours::IsTourInProgressResultReady(isInProgress: Boolean)
    begin
    end;

    trigger PageNotifier::PageReady()
    var
        NetPromoterScoreMgt: Codeunit "Net Promoter Score Mgt.";
    begin
        if O365GettingStartedMgt.WizardShouldBeOpenedForDevices then begin
          Commit;
          PAGE.RunModal(PAGE::"O365 Getting Started Device");
          exit;
        end;

        if not HideNpsDialog then
          if NetPromoterScoreMgt.ShowNpsDialog then
            HideNpsDialog := true;
    end;
}

