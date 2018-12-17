report 107 "Customer - Order Summary"
{
    // version NAVW113.00

    DefaultLayout = RDLC;
    RDLCLayout = './Customer - Order Summary.rdlc';
    ApplicationArea = #Basic,#Suite;
    Caption = 'Customer - Order Summary';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Customer;Customer)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.","Search Name","Customer Posting Group","Currency Filter";
            column(CompanyName;COMPANYPROPERTY.DisplayName)
            {
            }
            column(PrintAmountsInLCY;PrintAmountsInLCY)
            {
            }
            column(CustFilter;TableCaption + ': ' + CustFilter)
            {
            }
            column(CustFilter1;CustFilter)
            {
            }
            column(PeriodStartDate1;Format(PeriodStartDate[1]))
            {
            }
            column(PeriodStartDate2;Format(PeriodStartDate[2]))
            {
            }
            column(PeriodStartDate3;Format(PeriodStartDate[3]))
            {
            }
            column(PeriodStartDate21;Format(PeriodStartDate[2] - 1))
            {
            }
            column(PeriodStartDate31;Format(PeriodStartDate[3] - 1))
            {
            }
            column(PeriodStartDate41;Format(PeriodStartDate[4] - 1))
            {
            }
            column(SalesAmtOnOrderLCY1;SalesAmtOnOrderLCY[1])
            {
                AutoFormatType = 1;
            }
            column(SalesAmtOnOrderLCY2;SalesAmtOnOrderLCY[2])
            {
                AutoFormatType = 1;
            }
            column(SalesAmtOnOrderLCY3;SalesAmtOnOrderLCY[3])
            {
                AutoFormatType = 1;
            }
            column(SalesAmtOnOrderLCY4;SalesAmtOnOrderLCY[4])
            {
                AutoFormatType = 1;
            }
            column(SalesAmtOnOrderLCY5;SalesAmtOnOrderLCY[5])
            {
                AutoFormatType = 1;
            }
            column(SalesOrderAmountLCY;SalesOrderAmountLCY)
            {
                AutoFormatType = 1;
            }
            column(No_Cust;"No.")
            {
            }
            column(SalesLineCurrencyFilter;SalesLine."Currency Code")
            {
            }
            column(SalesOrderAmount;SalesOrderAmount)
            {
                AutoFormatExpression = "Currency Code";
                AutoFormatType = 1;
            }
            column(SalesAmtOnOrder5;SalesAmtOnOrder[5])
            {
                AutoFormatExpression = "Currency Code";
                AutoFormatType = 1;
            }
            column(SalesAmtOnOrder4;SalesAmtOnOrder[4])
            {
                AutoFormatExpression = "Currency Code";
                AutoFormatType = 1;
            }
            column(SalesAmtOnOrder3;SalesAmtOnOrder[3])
            {
                AutoFormatExpression = "Currency Code";
                AutoFormatType = 1;
            }
            column(SalesAmtOnOrder2;SalesAmtOnOrder[2])
            {
                AutoFormatExpression = "Currency Code";
                AutoFormatType = 1;
            }
            column(SalesAmtOnOrder1;SalesAmtOnOrder[1])
            {
                AutoFormatExpression = "Currency Code";
                AutoFormatType = 1;
            }
            column(TotalSalesAmtOnOrder;TotalSalesAmtOnOrder)
            {
            }
            column(TotalSalesAmtOnOrderLCY;TotalSalesAmtOnOrderLCY)
            {
            }
            column(Name_Cust;Name)
            {
                IncludeCaption = true;
            }
            column(CustomerOrderSummaryCaption;CustomerOrderSummaryCaptionLbl)
            {
            }
            column(PageNoCaption;PageNoCaptionLbl)
            {
            }
            column(AllamountsareinLCYCaption;AllamountsareinLCYCaptionLbl)
            {
            }
            column(OutstandingOrdersCaption;OutstandingOrdersCaptionLbl)
            {
            }
            column(CustomerNoCaption;CustomerNoCaptionLbl)
            {
            }
            column(CustomerNameCaption;CustomerNameCap)
            {
            }
            column(BeforeCaption;BeforeCaptionLbl)
            {
            }
            column(AfterCaption;AfterCaptionLbl)
            {
            }
            column(TotalCaption;TotalCaptionLbl)
            {
            }
            column(TotalLCYCaption;TotalLCYCaptionLbl)
            {
            }

            trigger OnAfterGetRecord()
            begin
                SalesLine.SetCurrentKey("Document Type","Bill-to Customer No.","Currency Code");
                SalesLine.SetRange("Document Type",SalesLine."Document Type"::Order);
                SalesLine.SetFilter("Outstanding Quantity",'<>%1',0);
                SalesLine.SetRange("Bill-to Customer No.","No.");
                SalesLine.SetFilter("Shortcut Dimension 1 Code","Global Dimension 1 Filter");
                SalesLine.SetFilter("Shortcut Dimension 2 Code","Global Dimension 2 Filter");
                SalesLine.SetFilter("Currency Code",GetFilter("Currency Filter"));

                for PeriodNo := 1 to 5 do begin
                  SalesAmtOnOrder[PeriodNo] := 0;
                  SalesAmtOnOrderLCY[PeriodNo] := 0;
                end;
                TotalSalesAmtOnOrder := 0;
                TotalSalesAmtOnOrderLCY := 0;

                if SalesLine.FindSet then
                  repeat
                    PeriodNo := 1;
                    while SalesLine."Shipment Date" >= PeriodStartDate[PeriodNo] do
                      PeriodNo := PeriodNo + 1;

                    Currency.InitRoundingPrecision;
                    if SalesLine."VAT Calculation Type" in
                       [SalesLine."VAT Calculation Type"::"Normal VAT",SalesLine."VAT Calculation Type"::"Reverse Charge VAT"]
                    then
                      SalesOrderAmount :=
                        Round(
                          (SalesLine.Amount + SalesLine."VAT Base Amount" * SalesLine."VAT %" / 100) * SalesLine."Outstanding Quantity" /
                          SalesLine.Quantity / (1 + SalesLine."VAT %" / 100),
                          Currency."Amount Rounding Precision")
                    else
                      SalesOrderAmount :=
                        Round(
                          SalesLine."Outstanding Amount" / (1 + SalesLine."VAT %" / 100),
                          Currency."Amount Rounding Precision");
                    SalesOrderAmountLCY := SalesOrderAmount;
                    if SalesLine."Currency Code" <> '' then begin
                      SalesHeader.Get(SalesLine."Document Type",SalesLine."Document No.");
                      if SalesHeader."Currency Factor" <> 0 then
                        SalesOrderAmountLCY :=
                          Round(
                            CurrExchRate.ExchangeAmtFCYToLCY(
                              WorkDate,SalesLine."Currency Code",SalesOrderAmount,
                              SalesHeader."Currency Factor"));
                    end;

                    SalesAmtOnOrder[PeriodNo] := SalesAmtOnOrder[PeriodNo] + SalesOrderAmount;
                    SalesAmtOnOrderLCY[PeriodNo] := SalesAmtOnOrderLCY[PeriodNo] + SalesOrderAmountLCY;
                  until SalesLine.Next = 0
                else
                  CurrReport.Skip;

                for PeriodNo := 1 to 5 do begin
                  TotalSalesAmtOnOrder += SalesAmtOnOrder[PeriodNo];
                  TotalSalesAmtOnOrderLCY += SalesAmtOnOrderLCY[PeriodNo];
                end;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(ShwAmtinLCY;PrintAmountsInLCY)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Show Amounts in LCY';
                        ToolTip = 'Specifies if the reported amounts are shown in the local currency.';
                    }
                    field(StartingDate;PeriodStartDate[1])
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Starting Date';
                        NotBlank = true;
                        ToolTip = 'Specifies the date from which the report or batch job processes information.';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            if PeriodStartDate[1] = 0D then
              PeriodStartDate[1] := WorkDate;
        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    var
        CaptionManagement: Codeunit CaptionManagement;
    begin
        CustFilter := CaptionManagement.GetRecordFiltersWithCaptions(Customer);
        if not PrintAmountsInLCY then begin
          Currency.SetFilter(Code,Customer.GetFilter("Currency Filter"));
          if Currency.Count = 1 then
            Currency.FindFirst;
        end;
        for i := 1 to 3 do
          PeriodStartDate[i + 1] := CalcDate('<1M>',PeriodStartDate[i]);
        PeriodStartDate[5] := DMY2Date(31,12,9999);
    end;

    var
        CurrExchRate: Record "Currency Exchange Rate";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Currency: Record Currency;
        CustFilter: Text;
        SalesOrderAmount: Decimal;
        SalesOrderAmountLCY: Decimal;
        PeriodStartDate: array [5] of Date;
        SalesAmtOnOrderLCY: array [5] of Decimal;
        PrintAmountsInLCY: Boolean;
        PeriodNo: Integer;
        SalesAmtOnOrder: array [5] of Decimal;
        i: Integer;
        CustomerOrderSummaryCaptionLbl: Label 'Customer - Order Summary';
        PageNoCaptionLbl: Label 'Page';
        AllamountsareinLCYCaptionLbl: Label 'All amounts are in LCY';
        OutstandingOrdersCaptionLbl: Label 'Outstanding Orders';
        CustomerNoCaptionLbl: Label 'Customer No.';
        CustomerNameCap: Label 'Name';
        BeforeCaptionLbl: Label '...before';
        AfterCaptionLbl: Label 'after...';
        TotalCaptionLbl: Label 'Total';
        TotalLCYCaptionLbl: Label 'Total (LCY)';
        TotalSalesAmtOnOrder: Decimal;
        TotalSalesAmtOnOrderLCY: Decimal;

    [Scope('Personalization')]
    procedure InitializeRequest(StartingDate: Date;ShowAmountInLCY: Boolean)
    begin
        PeriodStartDate[1] := StartingDate;
        PrintAmountsInLCY := ShowAmountInLCY;
    end;
}

