codeunit 1311 "Activities Mgt."
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    [Scope('Personalization')]
    procedure CalcOverdueSalesInvoiceAmount(CalledFromWebService: Boolean) Amount: Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        [SecurityFiltering(SecurityFilter::Filtered)]CustLedgEntryRemainAmtQuery: Query "Cust. Ledg. Entry Remain. Amt.";
    begin
        CustLedgEntryRemainAmtQuery.SetRange(Document_Type,CustLedgerEntry."Document Type"::Invoice);
        CustLedgEntryRemainAmtQuery.SetRange(IsOpen,true);
        if CalledFromWebService then
          CustLedgEntryRemainAmtQuery.SetFilter(Due_Date,'<%1',Today)
        else
          CustLedgEntryRemainAmtQuery.SetFilter(Due_Date,'<%1',WorkDate);
        CustLedgEntryRemainAmtQuery.Open;

        if CustLedgEntryRemainAmtQuery.Read then
          Amount := CustLedgEntryRemainAmtQuery.Sum_Remaining_Amt_LCY;
    end;

    [Scope('Personalization')]
    procedure DrillDownCalcOverdueSalesInvoiceAmount()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Document Type",CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange(Open,true);
        CustLedgerEntry.SetFilter("Due Date",'<%1',WorkDate);
        CustLedgerEntry.SetFilter("Remaining Amt. (LCY)",'<>0');
        CustLedgerEntry.SetCurrentKey("Remaining Amt. (LCY)");
        CustLedgerEntry.Ascending := false;

        PAGE.Run(PAGE::"Customer Ledger Entries",CustLedgerEntry);
    end;

    [Scope('Personalization')]
    procedure CalcOverduePurchaseInvoiceAmount(CalledFromWebService: Boolean) Amount: Decimal
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        [SecurityFiltering(SecurityFilter::Filtered)]VendLedgEntryRemainAmtQuery: Query "Vend. Ledg. Entry Remain. Amt.";
    begin
        VendLedgEntryRemainAmtQuery.SetRange(Document_Type,VendorLedgerEntry."Document Type"::Invoice);
        VendLedgEntryRemainAmtQuery.SetRange(IsOpen,true);
        if CalledFromWebService then
          VendLedgEntryRemainAmtQuery.SetFilter(Due_Date,'<%1',Today)
        else
          VendLedgEntryRemainAmtQuery.SetFilter(Due_Date,'<%1',WorkDate);
        VendLedgEntryRemainAmtQuery.Open;

        if VendLedgEntryRemainAmtQuery.Read then
          Amount := Abs(VendLedgEntryRemainAmtQuery.Sum_Remaining_Amt_LCY);
    end;

    [Scope('Personalization')]
    procedure DrillDownOverduePurchaseInvoiceAmount()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendorLedgerEntry.SetRange("Document Type",VendorLedgerEntry."Document Type"::Invoice);
        VendorLedgerEntry.SetFilter("Due Date",'<%1',WorkDate);
        VendorLedgerEntry.SetFilter("Remaining Amt. (LCY)",'<>0');
        VendorLedgerEntry.SetCurrentKey("Remaining Amt. (LCY)");
        VendorLedgerEntry.Ascending := true;

        PAGE.Run(PAGE::"Vendor Ledger Entries",VendorLedgerEntry);
    end;

    [Scope('Personalization')]
    procedure CalcSalesThisMonthAmount(CalledFromWebService: Boolean) Amount: Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        [SecurityFiltering(SecurityFilter::Filtered)]CustLedgEntrySales: Query "Cust. Ledg. Entry Sales";
    begin
        CustLedgEntrySales.SetFilter(Document_Type,'%1|%2',
          CustLedgerEntry."Document Type"::Invoice,CustLedgerEntry."Document Type"::"Credit Memo");
        if CalledFromWebService then
          CustLedgEntrySales.SetRange(Posting_Date,CalcDate('<-CM>',Today),Today)
        else
          CustLedgEntrySales.SetRange(Posting_Date,CalcDate('<-CM>',WorkDate),WorkDate);
        CustLedgEntrySales.Open;

        if CustLedgEntrySales.Read then
          Amount := CustLedgEntrySales.Sum_Sales_LCY;
    end;

    [Scope('Personalization')]
    procedure DrillDownSalesThisMonth()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetFilter("Document Type",'%1|%2',
          CustLedgerEntry."Document Type"::Invoice,CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Posting Date",CalcDate('<-CM>',WorkDate),WorkDate);
        PAGE.Run(PAGE::"Customer Ledger Entries",CustLedgerEntry);
    end;

    [Scope('Personalization')]
    procedure CalcSalesYTD() Amount: Decimal
    var
        AccountingPeriod: Record "Accounting Period";
        [SecurityFiltering(SecurityFilter::Filtered)]CustLedgEntrySales: Query "Cust. Ledg. Entry Sales";
    begin
        CustLedgEntrySales.SetRange(Posting_Date,AccountingPeriod.GetFiscalYearStartDate(WorkDate),WorkDate);
        CustLedgEntrySales.Open;

        if CustLedgEntrySales.Read then
          Amount := CustLedgEntrySales.Sum_Sales_LCY;
    end;

    [Scope('Personalization')]
    procedure CalcTop10CustomerSalesYTD() Amount: Decimal
    var
        AccountingPeriod: Record "Accounting Period";
        Top10CustomerSales: Query "Top 10 Customer Sales";
    begin
        // Total Sales (LCY) by top 10 list of customers year-to-date.
        Top10CustomerSales.SetRange(Posting_Date,AccountingPeriod.GetFiscalYearStartDate(WorkDate),WorkDate);
        Top10CustomerSales.Open;

        while Top10CustomerSales.Read do
          Amount += Top10CustomerSales.Sum_Sales_LCY;
    end;

    [Scope('Personalization')]
    procedure CalcTop10CustomerSalesRatioYTD() Amount: Decimal
    var
        TotalSales: Decimal;
    begin
        // Ratio of Sales by top 10 list of customers year-to-date.
        TotalSales := CalcSalesYTD;
        if TotalSales <> 0 then
          Amount := CalcTop10CustomerSalesYTD / TotalSales;
    end;

    [Scope('Personalization')]
    procedure CalcAverageCollectionDays() AverageDays: Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SumCollectionDays: Integer;
        CountInvoices: Integer;
    begin
        GetPaidSalesInvoices(CustLedgerEntry);
        if CustLedgerEntry.FindSet then begin
          repeat
            SumCollectionDays += (CustLedgerEntry."Closed at Date" - CustLedgerEntry."Posting Date");
            CountInvoices += 1;
          until CustLedgerEntry.Next = 0;

          AverageDays := SumCollectionDays / CountInvoices;
        end
    end;

    [Scope('Personalization')]
    procedure CalcUninvoicedBookings(): Integer
    var
        TempBookingItem: Record "Booking Item" temporary;
        BookingManager: Codeunit "Booking Manager";
    begin
        BookingManager.GetBookingItems(TempBookingItem);
        exit(TempBookingItem.Count);
    end;

    local procedure GetPaidSalesInvoices(var CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        CustLedgerEntry.SetRange("Document Type",CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange(Open,false);
        CustLedgerEntry.SetRange("Posting Date",CalcDate('<CM-3M>',WorkDate),WorkDate);
        CustLedgerEntry.SetRange("Closed at Date",CalcDate('<CM-3M>',WorkDate),WorkDate);
    end;

    [Scope('Personalization')]
    procedure CalcCashAccountsBalances() CashAccountBalance: Decimal
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.SetRange("Account Category",GLAccount."Account Category"::Assets);
        GLAccount.SetRange("Account Type",GLAccount."Account Type"::Posting);
        GLAccount.SetRange("Account Subcategory Entry No.",3);
        if GLAccount.FindSet then begin
          repeat
            GLAccount.CalcFields(Balance);
            CashAccountBalance += GLAccount.Balance;
          until GLAccount.Next = 0;
        end;
    end;

    [Scope('Personalization')]
    procedure DrillDownCalcCashAccountsBalances()
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.SetRange("Account Category",GLAccount."Account Category"::Assets);
        GLAccount.SetRange("Account Type",GLAccount."Account Type"::Posting);
        GLAccount.SetRange("Account Subcategory Entry No.",3);
        PAGE.Run(PAGE::"Chart of Accounts",GLAccount);
    end;
}

