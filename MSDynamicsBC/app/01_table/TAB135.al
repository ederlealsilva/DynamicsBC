table 135 "Acc. Sched. KPI Web Srv. Setup"
{
    // version NAVW113.00

    Caption = 'Acc. Sched. KPI Web Srv. Setup';

    fields
    {
        field(1;"Primary Key";Code[10])
        {
            Caption = 'Primary Key';

            trigger OnValidate()
            begin
                TestField("Primary Key",'');
            end;
        }
        field(2;"Forecasted Values Start";Option)
        {
            Caption = 'Forecasted Values Start';
            OptionCaption = 'After Latest Closed Period,After Current Date';
            OptionMembers = "After Latest Closed Period","After Current Date";
        }
        field(3;"G/L Budget Name";Code[10])
        {
            Caption = 'G/L Budget Name';
            TableRelation = "G/L Budget Name";
        }
        field(4;Period;Option)
        {
            Caption = 'Period';
            OptionCaption = 'Fiscal Year - Last Locked Period,Current Fiscal Year,Current Calendar Year,Current Calendar Quarter,Current Month,Today,Current Period,Last Locked Period,Current Fiscal Year + 3 Previous Years';
            OptionMembers = "Fiscal Year - Last Locked Period","Current Fiscal Year","Current Calendar Year","Current Calendar Quarter","Current Month",Today,"Current Period","Last Locked Period","Current Fiscal Year + 3 Previous Years";
        }
        field(5;"View By";Option)
        {
            Caption = 'View By';
            OptionCaption = 'Day,Week,Month,Quarter,Year,Period';
            OptionMembers = Day,Week,Month,Quarter,Year,Period;
        }
        field(6;"Web Service Name";Text[240])
        {
            Caption = 'Web Service Name';

            trigger OnValidate()
            var
                i: Integer;
                s: Text;
            begin
                if "Web Service Name" = '' then
                  exit;
                s := LowerCase("Web Service Name");
                for i := 1 to StrLen(s) do
                  if not (s[i] in ['a'..'z','0'..'9','-']) then
                    Error(ServiceNameErr);
            end;
        }
        field(7;Published;Boolean)
        {
            CalcFormula = Exist("Web Service" WHERE ("Object Type"=CONST(Page),
                                                     "Object ID"=CONST(197),
                                                     Published=CONST(true)));
            Caption = 'Published';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Primary Key")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        AccSchedKPIWebSrvLine: Record "Acc. Sched. KPI Web Srv. Line";
    begin
        AccSchedKPIWebSrvLine.DeleteAll;
    end;

    trigger OnInsert()
    begin
        TestField("Primary Key",'');
    end;

    var
        ServiceNameErr: Label 'The service name may only contain letters A-Z, a-z, digits 0-9, and hyphens (-). No other characters are allowed.';

    [Scope('Personalization')]
    procedure GetPeriodLength(var NoOfLines: Integer;var StartDate: Date;var EndDate: Date)
    var
        AccountingPeriod: Record "Accounting Period";
        TotalNoOfDays: Integer;
        NoOfDaysPerLine: Integer;
    begin
        case Period of
          Period::"Fiscal Year - Last Locked Period":
            GetFiscalYear(GetLastClosedAccDate,StartDate,EndDate);
          Period::"Current Fiscal Year":
            GetFiscalYear(WorkDate,StartDate,EndDate);
          Period::"Current Period":
            begin
              AccountingPeriod.SetFilter("Starting Date",'<=%1',WorkDate);
              AccountingPeriod.FindLast;
              StartDate := AccountingPeriod."Starting Date";
              AccountingPeriod.SetRange("Starting Date");
              if AccountingPeriod.Find('>') then
                EndDate := AccountingPeriod."Starting Date" - 1
              else
                EndDate := CalcDate('<CM>',StartDate);
            end;
          Period::"Last Locked Period":
            begin
              AccountingPeriod.SetFilter("Starting Date",'<=%1',GetLastClosedAccDate);
              AccountingPeriod.FindLast;
              StartDate := AccountingPeriod."Starting Date";
              AccountingPeriod.SetRange("Starting Date");
              if AccountingPeriod.Find('>') then
                EndDate := AccountingPeriod."Starting Date" - 1
              else
                EndDate := CalcDate('<CM>',StartDate);
            end;
          Period::"Current Calendar Year":
            begin
              StartDate := CalcDate('<-CY>',WorkDate);
              EndDate := CalcDate('<CY>',StartDate);
            end;
          Period::"Current Calendar Quarter":
            begin
              StartDate := CalcDate('<-CQ>',WorkDate);
              EndDate := CalcDate('<CQ>',StartDate);
            end;
          Period::"Current Month":
            begin
              StartDate := CalcDate('<-CM>',WorkDate);
              EndDate := CalcDate('<CM>',StartDate);
            end;
          Period::Today:
            begin
              StartDate := WorkDate;
              EndDate := WorkDate;
            end;
          Period::"Current Fiscal Year + 3 Previous Years":
            begin
              GetFiscalYear(WorkDate,StartDate,EndDate);
              StartDate := CalcDate('<-3Y>',StartDate);
              AccountingPeriod.SetRange("New Fiscal Year",true);
              AccountingPeriod.FindFirst; // Get oldest accounting year
              if AccountingPeriod."Starting Date" > StartDate then
                StartDate := AccountingPeriod."Starting Date";
            end;
        end;
        TotalNoOfDays := EndDate - StartDate + 1;

        case "View By" of
          "View By"::Period:
            NoOfDaysPerLine := TotalNoOfDays;
          "View By"::Year:
            NoOfDaysPerLine := TotalNoOfDays;
          "View By"::Quarter:
            NoOfDaysPerLine := 90;
          "View By"::Month:
            NoOfDaysPerLine := 30;
          "View By"::Week:
            NoOfDaysPerLine := 7;
          "View By"::Day:
            NoOfDaysPerLine := 1;
        end;

        NoOfLines := TotalNoOfDays div NoOfDaysPerLine;
        if NoOfLines = 0 then
          NoOfLines := 1;
    end;

    local procedure GetFiscalYear(Date: Date;var StartDate: Date;var EndDate: Date)
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        StartDate := Date;
        AccountingPeriod.SetFilter("Starting Date",'<=%1',Date);
        AccountingPeriod.SetRange("New Fiscal Year",true);
        if AccountingPeriod.FindLast then
          StartDate := AccountingPeriod."Starting Date";
        AccountingPeriod.SetRange("Starting Date");
        if AccountingPeriod.Find('>') then
          EndDate := AccountingPeriod."Starting Date" - 1
        else
          EndDate := CalcDate('<1Y-1D>',StartDate);
    end;

    [Scope('Personalization')]
    procedure CalcNextStartDate(OrgStartDate: Date;OffSet: Integer): Date
    var
        AccountingPeriod: Record "Accounting Period";
        DateCalc: DateFormula;
        DateCalcStr: Text;
    begin
        if OffSet = 0 then
          exit(OrgStartDate);

        case "View By" of
          "View By"::Period:
            begin
              AccountingPeriod."Starting Date" := OrgStartDate;
              AccountingPeriod.Find('=><');
              AccountingPeriod.Next(OffSet);
              exit(AccountingPeriod."Starting Date")
            end;
          "View By"::Year:
            DateCalcStr := '<%1Y>';
          "View By"::Quarter:
            DateCalcStr := '<%1Q>';
          "View By"::Month:
            DateCalcStr := '<%1M>';
          "View By"::Week:
            DateCalcStr := '<%1W>';
          "View By"::Day:
            DateCalcStr := '<%1D>';
        end;

        Evaluate(DateCalc,StrSubstNo(DateCalcStr,OffSet));
        exit(CalcDate(DateCalc,OrgStartDate));
    end;

    [Scope('Personalization')]
    procedure GetLastClosedAccDate(): Date
    var
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get;
        if GLSetup."Allow Posting From" <> 0D then
          exit(GLSetup."Allow Posting From" - 1);
        exit(WorkDate);
    end;

    [Scope('Personalization')]
    procedure GetLastBudgetChangedDate(): Date
    var
        GLBudgetEntry: Record "G/L Budget Entry";
    begin
        if "G/L Budget Name" <> '' then
          GLBudgetEntry.SetRange("Budget Name","G/L Budget Name");
        GLBudgetEntry.SetCurrentKey("Last Date Modified","Budget Name");
        if GLBudgetEntry.FindLast then
          exit(GLBudgetEntry."Last Date Modified");
        exit(0D);
    end;

    procedure PublishWebService()
    var
        WebService: Record "Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        TestField("Web Service Name");
        DeleteWebService;
        WebServiceManagement.CreateWebService(WebService."Object Type"::Page,
          PAGE::"Acc. Sched. KPI Web Service","Web Service Name",true);
        WebServiceManagement.CreateWebService(WebService."Object Type"::Query,
          QUERY::"Dimension Sets",'',true);
    end;

    procedure DeleteWebService()
    var
        WebService: Record "Web Service";
    begin
        WebService.SetRange("Object Type",WebService."Object Type"::Page);
        WebService.SetRange("Object ID",PAGE::"Acc. Sched. KPI Web Service");
        WebService.SetRange("Service Name","Web Service Name");
        if WebService.IsEmpty then
          WebService.SetRange("Service Name");
        MarkAndReset(WebService);

        WebService.SetRange("Object Type",WebService."Object Type"::Page);
        WebService.SetRange("Object ID",PAGE::"Acc. Sched. KPI WS Dimensions");
        MarkAndReset(WebService);

        WebService.SetRange("Object Type",WebService."Object Type"::Query);
        WebService.SetRange("Object ID",QUERY::"Dimension Sets");
        MarkAndReset(WebService);

        WebService.MarkedOnly(true);
        WebService.DeleteAll;
    end;

    local procedure MarkAndReset(var WebService: Record "Web Service")
    begin
        if WebService.FindSet then
          repeat
            WebService.Mark(true);
          until WebService.Next = 0;
        WebService.SetRange("Object Type");
        WebService.SetRange("Object ID");
        WebService.SetRange("Service Name");
    end;
}

