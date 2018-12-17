codeunit 1326 "Top Five Customers Chart Mgt."
{
    // version NAVW113.00

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        CustomerXCaptionTxt: Label 'Customer Name';
        SalesLCYYCaptionTxt: Label 'Sales (LCY)';
        AllOtherCustomersTxt: Label 'All Other Customers';
        IdentityManagement: Codeunit "Identity Management";
        LastUpdatedCustLedgerEntryNo: Integer;
        SavedCustomerName: array [6] of Text[50];
        SavedSalesLCY: array [6] of Decimal;
        SalesAmountCaptionTxt: Label 'Amount Excl. VAT (%1)', Comment='%1=Currency Symbol (e.g. $)';

    [Scope('Personalization')]
    procedure UpdateChart(var BusChartBuf: Record "Business Chart Buffer")
    var
        GLSetup: Record "General Ledger Setup";
        ColumnIndex: Integer;
        CustomerName: array [11] of Text[50];
        SalesLCY: array [11] of Decimal;
    begin
        with BusChartBuf do begin
          Initialize;
          if GLSetup.Get then;
          if IdentityManagement.IsInvAppId then
            AddMeasure(StrSubstNo(SalesAmountCaptionTxt,GLSetup.GetCurrencySymbol),1,"Data Type"::Decimal,"Chart Type"::Doughnut)
          else
            AddMeasure(SalesLCYYCaptionTxt,1,"Data Type"::Decimal,"Chart Type"::Doughnut);
          SetXAxis(CustomerXCaptionTxt,"Data Type"::String);
          CalcTopSalesCustomers(CustomerName,SalesLCY);
          for ColumnIndex := 1 to 6 do begin
            if SalesLCY[ColumnIndex] = 0 then
              exit;
            AddColumn(CustomerName[ColumnIndex]);
            SetValueByIndex(0,ColumnIndex - 1,SalesLCY[ColumnIndex]);
          end;
        end;
    end;

    [Scope('Personalization')]
    procedure DrillDown(var BusChartBuf: Record "Business Chart Buffer")
    var
        CustomerName: Variant;
    begin
        BusChartBuf.GetXValue(BusChartBuf."Drill-Down X Index",CustomerName);
        // drill down only for top 5 customers
        // for the 6th column "all other customers", it drills down to customer list of all other customers
        if (BusChartBuf."Drill-Down Measure Index" = 0) and (BusChartBuf."Drill-Down X Index" < 5) then
          DrillDownCust(Format(CustomerName));
        if (BusChartBuf."Drill-Down Measure Index" = 0) and (BusChartBuf."Drill-Down X Index" = 5) then
          DrillDownOtherCustList;
    end;

    local procedure CalcTopSalesCustomers(var CustomerName: array [6] of Text[50];var SalesLCY: array [6] of Decimal)
    var
        Customer: Record Customer;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        LastCustLedgerEntry: Record "Cust. Ledger Entry";
        ColumnIndex: Integer;
    begin
        if LastCustLedgerEntry.FindLast then;
        if LastUpdatedCustLedgerEntryNo = LastCustLedgerEntry."Entry No." then begin // refresh if cust ledger has been updated
          for ColumnIndex := 1 to 6 do begin
            CustomerName[ColumnIndex] := SavedCustomerName[ColumnIndex];
            SalesLCY[ColumnIndex] := SavedSalesLCY[ColumnIndex];
          end;
          exit;
        end;
        ColumnIndex := 0;
        CustLedgerEntry.CalcSums("Sales (LCY)");
        SalesLCY[6] := CustLedgerEntry."Sales (LCY)";
        Customer.SetCurrentKey("Sales (LCY)");
        Customer.Ascending(false);
        with Customer do begin
          if Find('-') then
            repeat
              ColumnIndex := ColumnIndex + 1;
              // Return Sales (LCY) for top 5 customer, and as 6th measure - the sum of Sales (LCY) for all other customers
              CustomerName[ColumnIndex] := Name;
              SalesLCY[ColumnIndex] := "Sales (LCY)";
              SalesLCY[6] -= "Sales (LCY)";
            until (Next = 0) or (ColumnIndex = 5);
          CustomerName[6] := AllOtherCustomersTxt;
        end;
        for ColumnIndex := 1 to 6 do begin
          SavedCustomerName[ColumnIndex] := CustomerName[ColumnIndex];
          SavedSalesLCY[ColumnIndex] := SalesLCY[ColumnIndex];
        end;
        LastUpdatedCustLedgerEntryNo := LastCustLedgerEntry."Entry No.";
    end;

    local procedure DrillDownCust(DrillDownName: Text[50])
    var
        Customer: Record Customer;
    begin
        Customer.SetRange(Name,DrillDownName);
        Customer.FindFirst;
        if IdentityManagement.IsInvAppId then
          PAGE.Run(PAGE::"BC O365 Sales Customer Card",Customer)
        else
          PAGE.Run(PAGE::"Customer Card",Customer);
    end;

    local procedure DrillDownOtherCustList()
    var
        Customer: Record Customer;
    begin
        Customer.SetFilter("No.",GetFilterToExcludeTopFiveCustomers);
        Customer.SetCurrentKey(Name);
        Customer.Ascending(true);
        if IdentityManagement.IsInvAppId then
          PAGE.Run(PAGE::"BC O365 Customer List",Customer)
        else
          PAGE.Run(PAGE::"Customer List",Customer);
    end;

    local procedure GetFilterToExcludeTopFiveCustomers(): Text
    var
        Customer: Record Customer;
        CustomerCounter: Integer;
        FilterToExcludeTopFiveCustomers: Text;
    begin
        CustomerCounter := 1;
        Customer.CalcFields("Sales (LCY)");
        Customer.SetCurrentKey("Sales (LCY)");
        Customer.Ascending(false);
        with Customer do begin
          if Find('-') then
            repeat
              if CustomerCounter = 1 then
                FilterToExcludeTopFiveCustomers := StrSubstNo('<>%1',"No.")
              else
                FilterToExcludeTopFiveCustomers += StrSubstNo('&<>%1',"No.");
              CustomerCounter := CustomerCounter + 1;
            until (Next = 0) or (CustomerCounter = 6);
        end;
        exit(FilterToExcludeTopFiveCustomers);
    end;
}

