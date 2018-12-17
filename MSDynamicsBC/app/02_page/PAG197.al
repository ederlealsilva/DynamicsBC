page 197 "Acc. Sched. KPI Web Service"
{
    // version NAVW113.00

    ApplicationArea = Basic,Suite;
    Caption = 'Account Schedule KPI Web Service';
    Editable = false;
    PageType = List;
    SourceTable = "Integer";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Number;Number)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the number of the account-schedule KPI web service.';
                    Visible = false;
                }
                field(Date;Date)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Date';
                    ToolTip = 'Specifies the date that the account-schedule KPI data is based on.';
                }
                field("Closed Period";ClosedPeriod)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Closed Period';
                    ToolTip = 'Specifies if the accounting period is closed or locked.';
                }
                field("Account Schedule Name";AccScheduleName)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Account Schedule Name';
                    ToolTip = 'Specifies the name of the account schedule that the KPI web service is based on.';
                }
                field("KPI Code";KPICode)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'KPI Code';
                    ToolTip = 'Specifies a code for the account-schedule KPI web service.';
                }
                field("KPI Name";KPIName)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'KPI Name';
                    ToolTip = 'Specifies the name that will be shown on the KPI as a user-friendly name for the account schedule values.';
                }
                field("Net Change Actual";ColumnValue[1])
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Net Change Actual';
                    ToolTip = 'Specifies changes in the actual general ledger amount, for closed accounting periods, up until the date in the Date field.';
                }
                field("Balance at Date Actual";ColumnValue[2])
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Balance at Date Actual';
                    ToolTip = 'Specifies the actual general ledger balance, based on closed accounting periods, on the date in the Date field.';
                }
                field("Net Change Budget";ColumnValue[3])
                {
                    ApplicationArea = Suite;
                    Caption = 'Net Change Budget';
                    ToolTip = 'Specifies changes in the budgeted general ledger amount, based on the general ledger budget, up until the date in the Date field.';
                }
                field("Balance at Date Budget";ColumnValue[4])
                {
                    ApplicationArea = Suite;
                    Caption = 'Balance at Date Budget';
                    ToolTip = 'Specifies the budgeted general ledger balance, based on the general ledger budget, on the date in the Date field.';
                }
                field("Net Change Actual Last Year";ColumnValue[5])
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Net Change Actual Last Year';
                    ToolTip = 'Specifies actual changes in the general ledger amount, based on closed accounting periods, through the previous accounting year.';
                }
                field("Balance at Date Actual Last Year";ColumnValue[6])
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Balance at Date Actual Last Year';
                    ToolTip = 'Specifies the actual general ledger balance, based on closed accounting periods, on the date in the Date field in the previous accounting year.';
                }
                field("Net Change Budget Last Year";ColumnValue[7])
                {
                    ApplicationArea = Suite;
                    Caption = 'Net Change Budget Last Year';
                    ToolTip = 'Specifies budgeted changes in the general ledger amount, up until the date in the Date field in the previous year.';
                }
                field("Balance at Date Budget Last Year";ColumnValue[8])
                {
                    ApplicationArea = Suite;
                    Caption = 'Balance at Date Budget Last Year';
                    ToolTip = 'Specifies the budgeted general ledger balance, based on the general ledger budget, on the date in the Date field in the previous accounting year.';
                }
                field("Net Change Forecast";ColumnValue[9])
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Net Change Forecast';
                    ToolTip = 'Specifies forecasted changes in the general ledger amount, based on open accounting periods, up until the date in the Date field.';
                }
                field("Balance at Date Forecast";ColumnValue[10])
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Balance at Date Forecast';
                    ToolTip = 'Specifies the forecasted general ledger balance, based on open accounting periods, on the date in the Date field.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        CalcValues;
    end;

    trigger OnOpenPage()
    begin
        InitSetupData;
        FilterGroup(2);
        SetRange(Number,0,NoOfLines - 1);
        FilterGroup(0);
    end;

    var
        AccSchedKPIWebSrvSetup: Record "Acc. Sched. KPI Web Srv. Setup";
        TempAccScheduleLine: Record "Acc. Schedule Line" temporary;
        TempColumnLayout: Record "Column Layout" temporary;
        AccSchedManagement: Codeunit AccSchedManagement;
        NoOfActiveAccSchedLines: Integer;
        NoOfLines: Integer;
        StartDate: Date;
        EndDate: Date;
        LastClosedDate: Date;
        AccScheduleName: Code[10];
        KPICode: Code[10];
        KPIName: Text;
        ColumnValue: array [10] of Decimal;
        Date: Date;
        ClosedPeriod: Boolean;

    local procedure InitSetupData()
    var
        AccSchedKPIWebSrvLine: Record "Acc. Sched. KPI Web Srv. Line";
        AccScheduleLine: Record "Acc. Schedule Line";
        ColumnLayout: Record "Column Layout";
        LogInManagement: Codeunit LogInManagement;
    begin
        if not GuiAllowed then
          WorkDate := LogInManagement.GetDefaultWorkDate;
        AccSchedKPIWebSrvSetup.Get;
        AccSchedKPIWebSrvLine.FindSet;
        AccScheduleLine.SetRange(Show,AccScheduleLine.Show::Yes);
        AccScheduleLine.SetFilter(Totaling,'<>%1','');
        repeat
          AccScheduleLine.SetRange("Schedule Name",AccSchedKPIWebSrvLine."Acc. Schedule Name");
          AccScheduleLine.FindSet;
          repeat
            NoOfActiveAccSchedLines += 1;
            TempAccScheduleLine := AccScheduleLine;
            TempAccScheduleLine."Line No." := NoOfActiveAccSchedLines;
            TempAccScheduleLine.Insert;
          until AccScheduleLine.Next = 0;
        until AccSchedKPIWebSrvLine.Next = 0;

        with ColumnLayout do begin
          // Net Change Actual
          InsertTempColumn("Column Type"::"Net Change","Ledger Entry Type"::Entries,false);
          // Balance at Date Actual
          InsertTempColumn("Column Type"::"Balance at Date","Ledger Entry Type"::Entries,false);
          // Net Change Budget
          InsertTempColumn("Column Type"::"Net Change","Ledger Entry Type"::"Budget Entries",false);
          // Balance at Date Budget
          InsertTempColumn("Column Type"::"Balance at Date","Ledger Entry Type"::"Budget Entries",false);
          // Net Change Actual Last Year
          InsertTempColumn("Column Type"::"Net Change","Ledger Entry Type"::Entries,true);
          // Balance at Date Actual Last Year
          InsertTempColumn("Column Type"::"Balance at Date","Ledger Entry Type"::Entries,true);
          // Net Change Budget Last Year
          InsertTempColumn("Column Type"::"Net Change","Ledger Entry Type"::"Budget Entries",true);
          // Balance at Date Budget Last Year
          InsertTempColumn("Column Type"::"Balance at Date","Ledger Entry Type"::"Budget Entries",true);
        end;

        AccSchedKPIWebSrvSetup.GetPeriodLength(NoOfLines,StartDate,EndDate);
        NoOfLines *= NoOfActiveAccSchedLines;
        LastClosedDate := AccSchedKPIWebSrvSetup.GetLastClosedAccDate;
    end;

    local procedure InsertTempColumn(ColumnType: Option;EntryType: Option;LastYear: Boolean)
    begin
        with TempColumnLayout do begin
          if FindLast then;
          Init;
          "Line No." += 10000;
          "Column Type" := ColumnType;
          "Ledger Entry Type" := EntryType;
          if LastYear then
            Evaluate("Comparison Date Formula",'<-1Y>');
          Insert;
        end;
    end;

    local procedure CalcValues()
    var
        ToDate: Date;
        ColNo: Integer;
    begin
        Date := AccSchedKPIWebSrvSetup.CalcNextStartDate(StartDate,Number div NoOfActiveAccSchedLines);
        ToDate := AccSchedKPIWebSrvSetup.CalcNextStartDate(Date,1) - 1;
        TempAccScheduleLine.FindSet;
        if Number mod NoOfActiveAccSchedLines > 0 then
          TempAccScheduleLine.Next(Number mod NoOfActiveAccSchedLines);
        AccScheduleName := TempAccScheduleLine."Schedule Name";
        TempAccScheduleLine.SetRange("Date Filter",Date,ToDate);
        TempAccScheduleLine.SetRange("G/L Budget Filter",AccSchedKPIWebSrvSetup."G/L Budget Name");

        KPICode := TempAccScheduleLine."Row No.";
        KPIName := TempAccScheduleLine.Description;

        ColNo := 0;
        TempColumnLayout.FindSet;
        repeat
          ColNo += 1;
          ColumnValue[ColNo] := AccSchedManagement.CalcCell(TempAccScheduleLine,TempColumnLayout,false);
        until TempColumnLayout.Next = 0;

        ClosedPeriod := Date <= LastClosedDate;
        // Forecasted values
        with AccSchedKPIWebSrvSetup do
          if (("Forecasted Values Start" = "Forecasted Values Start"::"After Latest Closed Period") and not ClosedPeriod) or
             (("Forecasted Values Start" = "Forecasted Values Start"::"After Current Date") and (Date > WorkDate))
          then begin
            ColumnValue[9] := ColumnValue[3]; // Net Change Budget
            ColumnValue[10] := ColumnValue[4]; // Balance at Date Budget
          end else begin
            ColumnValue[9] := ColumnValue[1]; // Net Change Actual
            ColumnValue[10] := ColumnValue[2]; // Balance at Date Actual
          end;
    end;
}

