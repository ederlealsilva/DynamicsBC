page 1315 "Accountant Portal Finance Cues"
{
    // version NAVW111.00

    Caption = 'Accountant Portal Finance Cues';
    PageType = List;
    SourceTable = "Finance Cue";

    layout
    {
        area(content)
        {
            group(OverduePurchaseDocuments)
            {
                Caption = 'OverduePurchaseDocuments', Locked=true;
                field(OverduePurchaseDocumentsAmount;OverduePurchaseDocumentsAmount)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'OverduePurchaseDocumentsAmount', Locked=true;
                    ToolTip = 'Specifies the number of purchase invoices where your payment is late.';
                }
                field(OverduePurchaseDocumentsStyle;OverduePurchaseDocumentsStyle)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'OverduePurchaseDocumentsStyle', Locked=true;
                    ToolTip = 'Specifies the number of purchase invoices where your payment is late.';
                }
            }
            group(PurchaseDiscountsNextWeek)
            {
                Caption = 'PurchaseDiscountsNextWeek', Locked=true;
                field(PurchaseDiscountsNextWeekAmount;PurchaseDiscountsNextWeekAmount)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'PurchaseDiscountsNextWeekAmount', Locked=true;
                    ToolTip = 'Specifies the number of purchase discounts that are available next week, for example, because the discount expires after next week.';
                }
                field(PurchaseDiscountsNextWeekStyle;PurchaseDiscountsNextWeekStyle)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'PurchaseDiscountsNextWeekStyle', Locked=true;
                    ToolTip = 'Specifies the number of purchase discounts that are available next week, for example, because the discount expires after next week.';
                }
            }
            group(OverdueSalesDocuments)
            {
                Caption = 'OverdueSalesDocuments', Locked=true;
                field(OverdueSalesDocumentsAmount;OverdueSalesDocumentsAmount)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'OverdueSalesDocumentsAmount', Locked=true;
                    ToolTip = 'Specifies the number of invoices where the customer is late with payment.';
                }
                field(OverdueSalesDocumentsStyle;OverdueSalesDocumentsStyle)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'OverdueSalesDocumentsStyle', Locked=true;
                    ToolTip = 'Specifies the number of invoices where the customer is late with payment.';
                }
            }
            group(PurchaseDocumentsDueToday)
            {
                Caption = 'PurchaseDocumentsDueToday', Locked=true;
                field(PurchaseDocumentsDueTodayAmount;PurchaseDocumentsDueTodayAmount)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'PurchaseDocumentsDueTodayAmount', Locked=true;
                    ToolTip = 'Specifies the number of purchase invoices that are due for payment today.';
                }
                field(PurchaseDocumentsDueTodayStyle;PurchaseDocumentsDueTodayStyle)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'PurchaseDocumentsDueTodayStyle', Locked=true;
                    ToolTip = 'Specifies the number of purchase invoices that are due for payment today.';
                }
            }
            group(VendorsPaymentsOnHold)
            {
                Caption = 'VendorsPaymentsOnHold', Locked=true;
                field(VendorsPaymentsOnHoldAmount;VendorsPaymentsOnHoldAmount)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'VendorsPaymentsOnHoldAmount', Locked=true;
                    ToolTip = 'Specifies the number of vendor to whom your payment is on hold.';
                }
                field(VendorsPaymentsOnHoldStyle;VendorsPaymentsOnHoldStyle)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'VendorsPaymentsOnHoldStyle', Locked=true;
                    ToolTip = 'Specifies the number of vendor to whom your payment is on hold.';
                }
            }
            group(POsPendingApproval)
            {
                Caption = 'POsPendingApproval', Locked=true;
                field(POsPendingApprovalAmount;POsPendingApprovalAmount)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'POsPendingApprovalAmount', Locked=true;
                    ToolTip = 'Specifies the number of purchase orders that are pending approval.';
                }
                field(POsPendingApprovalStyle;POsPendingApprovalStyle)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'POsPendingApprovalStyle', Locked=true;
                    ToolTip = 'Specifies the number of purchase orders that are pending approval.';
                }
            }
            group(SOsPendingApproval)
            {
                Caption = 'SOsPendingApproval', Locked=true;
                field(SOsPendingApprovalAmount;SOsPendingApprovalAmount)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'SOsPendingApprovalAmount', Locked=true;
                    ToolTip = 'Specifies the number of sales orders that are pending approval.';
                }
                field(SOsPendingApprovalStyle;SOsPendingApprovalStyle)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'SOsPendingApprovalStyle', Locked=true;
                    ToolTip = 'Specifies the number of sales orders that are pending approval.';
                }
            }
            group(ApprovedSalesOrders)
            {
                Caption = 'ApprovedSalesOrders', Locked=true;
                field(ApprovedSalesOrdersAmount;ApprovedSalesOrdersAmount)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'ApprovedSalesOrdersAmount', Locked=true;
                    ToolTip = 'Specifies the number of approved sales orders in the company.';
                }
                field(ApprovedSalesOrdersStyle;ApprovedSalesOrdersStyle)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'ApprovedSalesOrdersStyle', Locked=true;
                    ToolTip = 'Specifies the number of approved sales orders in the company.';
                }
            }
            group(ApprovedPurchaseOrders)
            {
                Caption = 'ApprovedPurchaseOrders', Locked=true;
                field(ApprovedPurchaseOrdersAmount;ApprovedPurchaseOrdersAmount)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'ApprovedPurchaseOrdersAmount', Locked=true;
                    ToolTip = 'Specifies the number of approved purchase orders in the company.';
                }
                field(ApprovedPurchaseOrdersStyle;ApprovedPurchaseOrdersStyle)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'ApprovedPurchaseOrdersStyle', Locked=true;
                    ToolTip = 'Specifies the number of approved purchase orders in the company.';
                }
            }
            group(PurchaseReturnOrders)
            {
                Caption = 'PurchaseReturnOrders', Locked=true;
                field(PurchaseReturnOrdersAmount;PurchaseReturnOrdersAmount)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'PurchaseReturnOrdersAmount', Locked=true;
                    ToolTip = 'Specifies the number of purchase return orders in the company.';
                }
                field(PurchaseReturnOrdersStyle;PurchaseReturnOrdersStyle)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'PurchaseReturnOrdersStyle', Locked=true;
                    ToolTip = 'Specifies the number of purchase return orders in the company.';
                }
            }
            group(SalesReturnOrdersAll)
            {
                Caption = 'SalesReturnOrdersAll', Locked=true;
                field(SalesReturnOrdersAllAmount;SalesReturnOrdersAllAmount)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'SalesReturnOrdersAllAmount', Locked=true;
                    ToolTip = 'Specifies the number of sales return orders in the company.';
                }
                field(SalesReturnOrdersAllStyle;SalesReturnOrdersAllStyle)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'SalesReturnOrdersAllStyle', Locked=true;
                    ToolTip = 'Specifies the number of sales return orders in the company.';
                }
            }
            group(CustomersBlocked)
            {
                Caption = 'CustomersBlocked', Locked=true;
                field(CustomersBlockedAmount;CustomersBlockedAmount)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'CustomersBlockedAmount', Locked=true;
                    ToolTip = 'Specifies the number of customers with a status of Blocked in the company.';
                }
                field(CustomersBlockedStyle;CustomersBlockedStyle)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'CustomersBlockedStyle', Locked=true;
                    ToolTip = 'Specifies the number of customers with a status of Blocked in the company.';
                }
            }
            group(NewIncomingDocuments)
            {
                Caption = 'NewIncomingDocuments', Locked=true;
                field(NewIncomingDocumentsAmount;NewIncomingDocumentsAmount)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'NewIncomingDocumentsAmount', Locked=true;
                    ToolTip = 'Specifies the number of new incoming documents in the company. The documents are filtered by today''s date.';
                }
                field(NewIncomingDocumentsStyle;NewIncomingDocumentsStyle)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'NewIncomingDocumentsStyle', Locked=true;
                    ToolTip = 'Specifies the number of new incoming documents in the company. The documents are filtered by today''s date.';
                }
            }
            group(ApprovedIncomingDocuments)
            {
                Caption = 'ApprovedIncomingDocuments', Locked=true;
                field(ApprovedIncomingDocumentsAmount;ApprovedIncomingDocumentsAmount)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'ApprovedIncomingDocumentsAmount', Locked=true;
                    ToolTip = 'Specifies the number of approved incoming documents in the company. The documents are filtered by today''s date.';
                }
                field(ApprovedIncomingDocumentsStyle;ApprovedIncomingDocumentsStyle)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'ApprovedIncomingDocumentsStyle', Locked=true;
                    ToolTip = 'Specifies the number of approved incoming documents in the company. The documents are filtered by today''s date.';
                }
            }
            group(OCRPending)
            {
                Caption = 'OCRPending', Locked=true;
                field(OCRPendingAmount;OCRPendingAmount)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'OCRPendingAmount', Locked=true;
                    ToolTip = 'Specifies the number of incoming document records whose creation by the OCR service is pending.';
                }
                field(OCRPendingStyle;OCRPendingStyle)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'OCRPendingStyle', Locked=true;
                    ToolTip = 'Specifies the number of incoming document records whose creation by the OCR service is pending.';
                }
            }
            group(OCRCompleted)
            {
                Caption = 'OCRCompleted', Locked=true;
                field(OCRCompletedAmount;OCRCompletedAmount)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'OCRCompletedAmount', Locked=true;
                    ToolTip = 'Specifies that incoming document records that have been created by the OCR service.';
                }
                field(OCRCompletedStyle;OCRCompletedStyle)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'OCRCompletedStyle', Locked=true;
                    ToolTip = 'Specifies that incoming document records that have been created by the OCR service.';
                }
            }
            group(RequestsToApprove)
            {
                Caption = 'RequestsToApprove', Locked=true;
                field(RequestsToApproveAmount;RequestsToApproveAmount)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'RequestsToApproveAmount', Locked=true;
                    ToolTip = 'Specifies the number of requests that need approval.';
                }
                field(RequestsToApproveStyle;RequestsToApproveStyle)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'RequestsToApproveStyle', Locked=true;
                    ToolTip = 'Specifies the number of requests that need approval.';
                }
            }
            group(RequestsSentForApproval)
            {
                Caption = 'RequestsSentForApproval', Locked=true;
                field(RequestsSentForApprovalAmount;RequestsSentForApprovalAmount)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'RequestsSentForApprovalAmount', Locked=true;
                    ToolTip = 'Specifies the number of requests that have been sent for approval.';
                }
                field(RequestsSentForApprovalStyle;RequestsSentForApprovalStyle)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'RequestsSentForApprovalStyle', Locked=true;
                    ToolTip = 'Specifies the number of requests that have been sent for approval.';
                }
            }
            group(CashAccountsBalance)
            {
                Caption = 'CashAccountsBalance', Locked=true;
                field(CashAccountsBalanceAmount;CashAccountsBalanceAmount)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'CashAccountsBalanceAmount', Locked=true;
                    ToolTip = 'Specifies the sum total of the cash accounts in the company.';
                }
                field(CashAccountsBalanceStyle;CashAccountsBalanceStyle)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'CashAccountsBalanceStyle', Locked=true;
                    ToolTip = 'Specifies the sum total of the cash accounts in the company.';
                }
            }
            group(LastDepreciatedPostedDate)
            {
                Caption = 'LastDepreciatedPostedDate', Locked=true;
                field(LastDepreciatedPostedDateAmount;LastDepreciatedPostedDateAmount)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'LastDepreciatedPostedDateAmount', Locked=true;
                    ToolTip = 'Specifies the last depreciation posted date.';
                }
                field(LastDepreciatedPostedDateStyle;LastDepreciatedPostedDateStyle)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'LastDepreciatedPostedDateStyle', Locked=true;
                    ToolTip = 'Specifies the last depreciation posted date.';
                }
            }
            group(LastLoginDate)
            {
                Caption = 'LastLoginDate', Locked=true;
                field(LastLoginDateAmount;LastLoginDateAmount)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'LastLoginDateAmount', Locked=true;
                    ToolTip = 'Specifies the last login date for the user.';
                }
                field(LastLoginDateStyle;LastLoginDateStyle)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'LastLoginDateStyle', Locked=true;
                    ToolTip = 'Specifies the last login date for the user.';
                }
            }
            group(MyUserTask)
            {
                Caption = 'MyUserTask', Locked=true;
                field(MyUserTaskStyle;MyUserTaskCueStyle)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'MyUserTaskStyle', Locked=true;
                    ToolTip = 'Specifies the style for my user tasks cue.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        SetAccountantPortalFields;
        GetLastLoginDate;
    end;

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
          Init;
          Insert;
          Commit;
        end;
        SetFilter("Due Date Filter",'<=%1',Today);
        SetFilter("Overdue Date Filter",'<%1',Today);
        SetFilter("Due Next Week Filter",'%1..%2',CalcDate('<1D>',Today),CalcDate('<1W>',Today));
        SetRange("User ID Filter",UserId);
    end;

    var
        ActivitiesMgt: Codeunit "Activities Mgt.";
        OverduePurchaseDocumentsAmount: Text;
        OverduePurchaseDocumentsStyle: Option "None",,,,,,,Favorable,Unfavorable,Ambiguous,Subordinate;
        PurchaseDiscountsNextWeekAmount: Text;
        PurchaseDiscountsNextWeekStyle: Option "None",,,,,,,Favorable,Unfavorable,Ambiguous,Subordinate;
        OverdueSalesDocumentsAmount: Text;
        OverdueSalesDocumentsStyle: Option "None",,,,,,,Favorable,Unfavorable,Ambiguous,Subordinate;
        PurchaseDocumentsDueTodayAmount: Text;
        PurchaseDocumentsDueTodayStyle: Option "None",,,,,,,Favorable,Unfavorable,Ambiguous,Subordinate;
        VendorsPaymentsOnHoldAmount: Text;
        VendorsPaymentsOnHoldStyle: Option "None",,,,,,,Favorable,Unfavorable,Ambiguous,Subordinate;
        POsPendingApprovalAmount: Text;
        POsPendingApprovalStyle: Option "None",,,,,,,Favorable,Unfavorable,Ambiguous,Subordinate;
        SOsPendingApprovalAmount: Text;
        SOsPendingApprovalStyle: Option "None",,,,,,,Favorable,Unfavorable,Ambiguous,Subordinate;
        ApprovedSalesOrdersAmount: Text;
        ApprovedSalesOrdersStyle: Option "None",,,,,,,Favorable,Unfavorable,Ambiguous,Subordinate;
        ApprovedPurchaseOrdersAmount: Text;
        ApprovedPurchaseOrdersStyle: Option "None",,,,,,,Favorable,Unfavorable,Ambiguous,Subordinate;
        PurchaseReturnOrdersAmount: Text;
        PurchaseReturnOrdersStyle: Option "None",,,,,,,Favorable,Unfavorable,Ambiguous,Subordinate;
        SalesReturnOrdersAllAmount: Text;
        SalesReturnOrdersAllStyle: Option "None",,,,,,,Favorable,Unfavorable,Ambiguous,Subordinate;
        CustomersBlockedAmount: Text;
        CustomersBlockedStyle: Option "None",,,,,,,Favorable,Unfavorable,Ambiguous,Subordinate;
        NewIncomingDocumentsAmount: Text;
        NewIncomingDocumentsStyle: Option "None",,,,,,,Favorable,Unfavorable,Ambiguous,Subordinate;
        ApprovedIncomingDocumentsAmount: Text;
        ApprovedIncomingDocumentsStyle: Option "None",,,,,,,Favorable,Unfavorable,Ambiguous,Subordinate;
        OCRPendingAmount: Text;
        OCRPendingStyle: Option "None",,,,,,,Favorable,Unfavorable,Ambiguous,Subordinate;
        OCRCompletedAmount: Text;
        OCRCompletedStyle: Option "None",,,,,,,Favorable,Unfavorable,Ambiguous,Subordinate;
        RequestsToApproveAmount: Text;
        RequestsToApproveStyle: Option "None",,,,,,,Favorable,Unfavorable,Ambiguous,Subordinate;
        RequestsSentForApprovalAmount: Text;
        RequestsSentForApprovalStyle: Option "None",,,,,,,Favorable,Unfavorable,Ambiguous,Subordinate;
        CashAccountsBalanceAmount: Text;
        CashAccountsBalanceStyle: Option "None",,,,,,,Favorable,Unfavorable,Ambiguous,Subordinate;
        LastDepreciatedPostedDateAmount: Text;
        LastDepreciatedPostedDateStyle: Option "None",,,,,,,Favorable,Unfavorable,Ambiguous,Subordinate;
        LastLoginDateAmount: Text;
        LastLoginDateStyle: Option "None",,,,,,,Favorable,Unfavorable,Ambiguous,Subordinate;
        MyUserTaskCueStyle: Option "None",,,,,,,Favorable,Unfavorable,Ambiguous,Subordinate;

    local procedure SetAccountantPortalFields()
    var
        AcctWebServicesMgt: Codeunit "Acct. WebServices Mgt.";
        StringConversionManagement: Codeunit StringConversionManagement;
        Justification: Option Right,Left;
        TempString: Text[250];
        UnlimitedTempString: Text;
        MyUserTasksCountInDec: Decimal;
    begin
        CalcFields("Overdue Purchase Documents");
        TempString := Format("Overdue Purchase Documents");
        OverduePurchaseDocumentsAmount := StringConversionManagement.GetPaddedString(TempString,30,' ',Justification::Right);
        AcctWebServicesMgt.SetCueStyle(9054,16,"Overdue Purchase Documents",OverduePurchaseDocumentsStyle);

        CalcFields("Purchase Discounts Next Week");
        TempString := Format("Purchase Discounts Next Week");
        PurchaseDiscountsNextWeekAmount := StringConversionManagement.GetPaddedString(TempString,30,' ',Justification::Right);
        AcctWebServicesMgt.SetCueStyle(9054,17,"Purchase Discounts Next Week",PurchaseDiscountsNextWeekStyle);

        CalcFields("Overdue Sales Documents");
        TempString := Format("Overdue Sales Documents");
        OverdueSalesDocumentsAmount := StringConversionManagement.GetPaddedString(TempString,30,' ',Justification::Right);
        AcctWebServicesMgt.SetCueStyle(9054,2,"Overdue Sales Documents",OverdueSalesDocumentsStyle);

        CalcFields("Purchase Documents Due Today");
        TempString := Format("Purchase Documents Due Today");
        PurchaseDocumentsDueTodayAmount := StringConversionManagement.GetPaddedString(TempString,30,' ',Justification::Right);
        AcctWebServicesMgt.SetCueStyle(9054,3,"Purchase Documents Due Today",PurchaseDocumentsDueTodayStyle);

        CalcFields("Vendors - Payment on Hold");
        TempString := Format("Vendors - Payment on Hold");
        VendorsPaymentsOnHoldAmount := StringConversionManagement.GetPaddedString(TempString,30,' ',Justification::Right);
        AcctWebServicesMgt.SetCueStyle(9054,8,"Vendors - Payment on Hold",VendorsPaymentsOnHoldStyle);

        CalcFields("POs Pending Approval");
        TempString := Format("POs Pending Approval");
        POsPendingApprovalAmount := StringConversionManagement.GetPaddedString(TempString,30,' ',Justification::Right);
        AcctWebServicesMgt.SetCueStyle(9054,4,"POs Pending Approval",POsPendingApprovalStyle);

        CalcFields("SOs Pending Approval");
        TempString := Format("SOs Pending Approval");
        SOsPendingApprovalAmount := StringConversionManagement.GetPaddedString(TempString,30,' ',Justification::Right);
        AcctWebServicesMgt.SetCueStyle(9054,4,"SOs Pending Approval",SOsPendingApprovalStyle);

        CalcFields("Approved Sales Orders");
        TempString := Format("Approved Sales Orders");
        ApprovedSalesOrdersAmount := StringConversionManagement.GetPaddedString(TempString,30,' ',Justification::Right);
        AcctWebServicesMgt.SetCueStyle(9054,6,"Approved Sales Orders",ApprovedSalesOrdersStyle);

        CalcFields("Approved Purchase Orders");
        TempString := Format("Approved Purchase Orders");
        ApprovedPurchaseOrdersAmount := StringConversionManagement.GetPaddedString(TempString,30,' ',Justification::Right);
        AcctWebServicesMgt.SetCueStyle(9054,7,"Approved Purchase Orders",ApprovedPurchaseOrdersStyle);

        CalcFields("Purchase Return Orders");
        TempString := Format("Purchase Return Orders");
        PurchaseReturnOrdersAmount := StringConversionManagement.GetPaddedString(TempString,30,' ',Justification::Right);
        AcctWebServicesMgt.SetCueStyle(9054,9,"Purchase Return Orders",PurchaseReturnOrdersStyle);

        CalcFields("Sales Return Orders - All");
        TempString := Format("Sales Return Orders - All");
        SalesReturnOrdersAllAmount := StringConversionManagement.GetPaddedString(TempString,30,' ',Justification::Right);
        AcctWebServicesMgt.SetCueStyle(9054,10,"Sales Return Orders - All",SalesReturnOrdersAllStyle);

        CalcFields("Customers - Blocked");
        TempString := Format("Customers - Blocked");
        CustomersBlockedAmount := StringConversionManagement.GetPaddedString(TempString,30,' ',Justification::Right);
        AcctWebServicesMgt.SetCueStyle(9054,11,"Customers - Blocked",CustomersBlockedStyle);

        CalcFields("New Incoming Documents");
        TempString := Format("New Incoming Documents");
        NewIncomingDocumentsAmount := StringConversionManagement.GetPaddedString(TempString,30,' ',Justification::Right);
        AcctWebServicesMgt.SetCueStyle(9054,22,"New Incoming Documents",NewIncomingDocumentsStyle);

        CalcFields("Approved Incoming Documents");
        TempString := Format("Approved Incoming Documents");
        ApprovedIncomingDocumentsAmount := StringConversionManagement.GetPaddedString(TempString,30,' ',Justification::Right);
        AcctWebServicesMgt.SetCueStyle(9054,23,"Approved Incoming Documents",ApprovedIncomingDocumentsStyle);

        CalcFields("OCR Pending");
        TempString := Format("OCR Pending");
        OCRPendingAmount := StringConversionManagement.GetPaddedString(TempString,30,' ',Justification::Right);
        AcctWebServicesMgt.SetCueStyle(9054,24,"OCR Pending",OCRPendingStyle);

        CalcFields("OCR Completed");
        TempString := Format("OCR Completed");
        OCRCompletedAmount := StringConversionManagement.GetPaddedString(TempString,30,' ',Justification::Right);
        AcctWebServicesMgt.SetCueStyle(9054,25,"OCR Completed",OCRCompletedStyle);

        CalcFields("Requests to Approve");
        TempString := Format("Requests to Approve");
        RequestsToApproveAmount := StringConversionManagement.GetPaddedString(TempString,30,' ',Justification::Right);
        AcctWebServicesMgt.SetCueStyle(9054,26,"Requests to Approve",RequestsToApproveStyle);

        CalcFields("Requests Sent for Approval");
        TempString := Format("Requests Sent for Approval");
        RequestsSentForApprovalAmount := StringConversionManagement.GetPaddedString(TempString,30,' ',Justification::Right);
        AcctWebServicesMgt.SetCueStyle(9054,27,"Requests Sent for Approval",RequestsSentForApprovalStyle);

        "Cash Accounts Balance" := ActivitiesMgt.CalcCashAccountsBalances;
        UnlimitedTempString := AcctWebServicesMgt.FormatAmountString("Cash Accounts Balance");
        TempString := CopyStr(UnlimitedTempString,1,250);
        CashAccountsBalanceAmount := StringConversionManagement.GetPaddedString(TempString,30,' ',Justification::Right);
        AcctWebServicesMgt.SetCueStyle(9054,30,"Cash Accounts Balance",CashAccountsBalanceStyle);

        CalcFields("Last Depreciated Posted Date");
        TempString := Format("Last Depreciated Posted Date");
        LastDepreciatedPostedDateAmount := StringConversionManagement.GetPaddedString(TempString,30,' ',Justification::Right);
        LastDepreciatedPostedDateStyle := 0;

        // Get my pending user tasks aka. MyUserTasksCount
        CalcFields("Pending Tasks");
        MyUserTasksCountInDec := Round("Pending Tasks",1);
        AcctWebServicesMgt.SetCueStyle(9054,32,MyUserTasksCountInDec,MyUserTaskCueStyle);
    end;

    local procedure GetLastLoginDate()
    var
        GLSetup: Record "General Ledger Setup";
        UserSetup: Record "User Setup";
        UserTimeRegister: Record "User Time Register";
        UserSetupFound: Boolean;
        RegisterTime: Boolean;
    begin
        LastLoginDateStyle := 0;
        if UserId <> '' then begin
          if UserSetup.Get(UserId) then begin
            UserSetupFound := true;
            RegisterTime := UserSetup."Register Time";
          end;
          if not UserSetupFound then
            if GLSetup.Get then
              RegisterTime := GLSetup."Register Time";

          if RegisterTime then begin
            UserTimeRegister.SetRange("User ID",UserId);
            if UserTimeRegister.FindFirst then
              LastLoginDateAmount := Format(UserTimeRegister.Date)
            else
              LastLoginDateAmount := Format(Today);
          end else
            LastLoginDateAmount := Format(Today);
        end;
    end;
}

