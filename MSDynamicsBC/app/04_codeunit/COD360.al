codeunit 360 "Accounting Period Mgt."
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    [Scope('Personalization')]
    procedure GetPeriodStartingDate(): Date
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        AccountingPeriod.SetCurrentKey(Closed);
        AccountingPeriod.SetRange(Closed,false);
        if AccountingPeriod.FindFirst then
          exit(AccountingPeriod."Starting Date");
        exit(CalcDate('<-CY>',WorkDate));
    end;

    [Scope('Personalization')]
    procedure CheckPostingDateInFiscalYear(PostingDate: Date)
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        if AccountingPeriod.IsEmpty then
          exit;
        AccountingPeriod.Get(NormalDate(PostingDate) + 1);
        AccountingPeriod.TestField("New Fiscal Year",true);
        AccountingPeriod.TestField("Date Locked",true);
    end;

    [Scope('Personalization')]
    procedure FindFiscalYear(BalanceDate: Date): Date
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        if AccountingPeriod.IsEmpty then begin
          if BalanceDate = 0D then
            exit(CalcDate('<-CY>',WorkDate));
          exit(CalcDate('<-CY>',BalanceDate));
        end;
        AccountingPeriod.SetRange("New Fiscal Year",true);
        AccountingPeriod.SetRange("Starting Date",0D,BalanceDate);
        if AccountingPeriod.FindLast then
          exit(AccountingPeriod."Starting Date");
        AccountingPeriod.Reset;
        AccountingPeriod.FindFirst;
        exit(AccountingPeriod."Starting Date");
    end;

    [Scope('Personalization')]
    procedure FindEndOfFiscalYear(BalanceDate: Date): Date
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        if AccountingPeriod.IsEmpty then begin
          if BalanceDate = 0D then
            exit(CalcDate('<CY>',WorkDate));
          exit(CalcDate('<CY>',BalanceDate));
        end;
        AccountingPeriod.SetRange("New Fiscal Year",true);
        AccountingPeriod.SetFilter("Starting Date",'>%1',FindFiscalYear(BalanceDate));
        if AccountingPeriod.FindFirst then
          exit(CalcDate('<-1D>',AccountingPeriod."Starting Date"));
        exit(DMY2Date(31,12,9999));
    end;

    [Scope('Personalization')]
    procedure AccPeriodStartEnd(Date: Date;var StartDate: Date;var EndDate: Date;var PeriodError: Boolean;Steps: Integer;Type: Option " ",Period,"Fiscal Year";RangeFromType: Option Int,CP,LP;RangeToType: Option Int,CP,LP;RangeFromInt: Integer;RangeToInt: Integer)
    var
        AccountingPeriod: Record "Accounting Period";
        AccountingPeriodFY: Record "Accounting Period";
        CurrentPeriodNo: Integer;
    begin
        AccountingPeriod.SetFilter("Starting Date",'<=%1',Date);
        if not AccountingPeriod.FindLast then begin
          AccountingPeriod.Reset;
          if Steps < 0 then
            AccountingPeriod.FindFirst
          else
            AccountingPeriod.FindLast
        end;
        AccountingPeriod.Reset;

        case Type of
          Type::Period:
            begin
              if AccountingPeriod.Next(Steps) <> Steps then
                PeriodError := true;
              StartDate := AccountingPeriod."Starting Date";
              EndDate := AccPeriodEndDate(StartDate);
            end;
          Type::"Fiscal Year":
            begin
              AccountingPeriodFY := AccountingPeriod;
              while not AccountingPeriodFY."New Fiscal Year" do
                if AccountingPeriodFY.Find('<') then
                  CurrentPeriodNo += 1
                else
                  AccountingPeriodFY."New Fiscal Year" := true;
              AccountingPeriodFY.SetRange("New Fiscal Year",true);
              AccountingPeriodFY.Next(Steps);

              AccPeriodStartOrEnd(AccountingPeriodFY,CurrentPeriodNo,RangeFromType,RangeFromInt,false,StartDate);
              AccPeriodStartOrEnd(AccountingPeriodFY,CurrentPeriodNo,RangeToType,RangeToInt,true,EndDate);
            end;
        end;
    end;

    local procedure AccPeriodEndDate(StartDate: Date): Date
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        if AccountingPeriod.IsEmpty then
          exit(CalcDate('<CY>',StartDate));
        AccountingPeriod."Starting Date" := StartDate;
        if AccountingPeriod.Find('>') then
          exit(AccountingPeriod."Starting Date" - 1);
        exit(DMY2Date(31,12,9999));
    end;

    local procedure AccPeriodStartOrEnd(AccountingPeriod: Record "Accounting Period";CurrentPeriodNo: Integer;RangeType: Option Int,CP,LP;RangeInt: Integer;EndDate: Boolean;var Date: Date)
    begin
        case RangeType of
          RangeType::CP:
            AccPeriodGetPeriod(AccountingPeriod,CurrentPeriodNo);
          RangeType::LP:
            AccPeriodGetPeriod(AccountingPeriod,-1);
          RangeType::Int:
            AccPeriodGetPeriod(AccountingPeriod,RangeInt - 1);
        end;
        if EndDate then
          Date := AccPeriodEndDate(AccountingPeriod."Starting Date")
        else
          Date := AccountingPeriod."Starting Date";
    end;

    local procedure AccPeriodGetPeriod(var AccountingPeriod: Record "Accounting Period";AccPeriodNo: Integer)
    begin
        case true of
          AccPeriodNo > 0:
            begin
              AccountingPeriod.Next(AccPeriodNo);
              exit;
            end;
          AccPeriodNo = 0:
            exit;
          AccPeriodNo < 0:
            begin
              AccountingPeriod.SetRange("New Fiscal Year",true);
              if not AccountingPeriod.Find('>') then begin
                AccountingPeriod.Reset;
                AccountingPeriod.Find('+');
                exit;
              end;
              AccountingPeriod.Reset;
              AccountingPeriod.Find('<');
              exit;
            end;
        end;
    end;

    [Scope('Personalization')]
    procedure InitStartYearAccountingPeriod(var AccountingPeriod: Record "Accounting Period";PostingDate: Date)
    begin
        InitAccountingPeriod(AccountingPeriod,CalcDate('<-CY>',PostingDate),true);
    end;

    [Scope('Personalization')]
    procedure InitDefaultAccountingPeriod(var AccountingPeriod: Record "Accounting Period";PostingDate: Date)
    begin
        InitAccountingPeriod(AccountingPeriod,CalcDate('<-CM>',PostingDate),false);
    end;

    local procedure InitAccountingPeriod(var AccountingPeriod: Record "Accounting Period";StartingDate: Date;NewFiscalYear: Boolean)
    var
        InventorySetup: Record "Inventory Setup";
    begin
        AccountingPeriod.Init;
        AccountingPeriod."Starting Date" := CalcDate('<-CM>',StartingDate);
        AccountingPeriod.Name := Format(AccountingPeriod."Starting Date",0,'<Month Text>');
        AccountingPeriod."New Fiscal Year" := NewFiscalYear;
        if NewFiscalYear then begin
          InventorySetup.Get;
          AccountingPeriod."Average Cost Calc. Type" := InventorySetup."Average Cost Calc. Type";
          AccountingPeriod."Average Cost Period" := InventorySetup."Average Cost Period";
        end;
    end;

    procedure GetDefaultPeriodEndingDate(PostingDate: Date): Date
    begin
        exit(CalcDate('<CM>',PostingDate));
    end;
}

