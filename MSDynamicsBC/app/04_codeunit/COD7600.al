codeunit 7600 "Calendar Management"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Location: Record Location;
        CompanyInfo: Record "Company Information";
        ServMgtSetup: Record "Service Mgt. Setup";
        Shippingagent: Record "Shipping Agent Services";
        BaseCalChange: Record "Base Calendar Change";
        CustCalChange: Record "Customized Calendar Change";
        TempCustChange: Record "Customized Calendar Change" temporary;
        TempCounter: Integer;
        Text001: Label 'Yes';
        Text002: Label 'No';
        Text003: Label 'The expression %1 cannot be negative.';
        OldSourceType: Integer;
        OldSourceCode: Code[20];
        OldAdditionalSourceCode: Code[20];
        OldCalendarCode: Code[10];

    [Scope('Personalization')]
    procedure ShowCustomizedCalendar(ForSourcetype: Option Company,Customer,Vendor,Location,"Shipping Agent",Service;ForSourceCode: Code[20];ForAdditionalSourceCode: Code[20];ForBaseCalendarCode: Code[10])
    var
        TempCustomizedCalEntry: Record "Customized Calendar Entry" temporary;
    begin
        TempCustomizedCalEntry.DeleteAll;
        TempCustomizedCalEntry.Init;
        TempCustomizedCalEntry."Source Type" := ForSourcetype;
        TempCustomizedCalEntry."Source Code" := ForSourceCode;
        TempCustomizedCalEntry."Additional Source Code" := ForAdditionalSourceCode;
        TempCustomizedCalEntry."Base Calendar Code" := ForBaseCalendarCode;
        TempCustomizedCalEntry.Insert;
        PAGE.Run(PAGE::"Customized Calendar Entries",TempCustomizedCalEntry);
    end;

    local procedure GetCalendarCode(SourceType: Option Company,Customer,Vendor,Location,"Shipping Agent",Service;SourceCode: Code[20];AdditionalSourceCode: Code[20]): Code[10]
    begin
        case SourceType of
          SourceType::Company:
            if CompanyInfo.Get then
              exit(CompanyInfo."Base Calendar Code");
          SourceType::Customer:
            if Customer.Get(SourceCode) then
              exit(Customer."Base Calendar Code");
          SourceType::Vendor:
            if Vendor.Get(SourceCode) then
              exit(Vendor."Base Calendar Code");
          SourceType::"Shipping Agent":
            begin
              if Shippingagent.Get(SourceCode,AdditionalSourceCode) then
                exit(Shippingagent."Base Calendar Code");

              if CompanyInfo.Get then
                exit(CompanyInfo."Base Calendar Code");
            end;
          SourceType::Location:
            begin
              if Location.Get(SourceCode) then
                if Location."Base Calendar Code" <> '' then
                  exit(Location."Base Calendar Code");
              if CompanyInfo.Get then
                exit(CompanyInfo."Base Calendar Code");
            end;
          SourceType::Service:
            if ServMgtSetup.Get then
              exit(ServMgtSetup."Base Calendar Code");
        end;
    end;

    procedure GetMaxDate(): Date
    var
        Date: Record Date;
    begin
        Date.SetRange("Period Type",Date."Period Type"::Date);
        Date.FindLast;
        exit(NormalDate(Date."Period End"));
    end;

    [Scope('Personalization')]
    procedure CheckDateStatus(CalendarCode: Code[10];TargetDate: Date;var Description: Text[50]): Boolean
    begin
        BaseCalChange.Reset;
        BaseCalChange.SetRange("Base Calendar Code",CalendarCode);
        if BaseCalChange.FindSet then
          repeat
            case BaseCalChange."Recurring System" of
              BaseCalChange."Recurring System"::" ":
                if TargetDate = BaseCalChange.Date then begin
                  Description := BaseCalChange.Description;
                  exit(BaseCalChange.Nonworking);
                end;
              BaseCalChange."Recurring System"::"Weekly Recurring":
                if Date2DWY(TargetDate,1) = BaseCalChange.Day then begin
                  Description := BaseCalChange.Description;
                  exit(BaseCalChange.Nonworking);
                end;
              BaseCalChange."Recurring System"::"Annual Recurring":
                if (Date2DMY(TargetDate,2) = Date2DMY(BaseCalChange.Date,2)) and
                   (Date2DMY(TargetDate,1) = Date2DMY(BaseCalChange.Date,1))
                then begin
                  Description := BaseCalChange.Description;
                  exit(BaseCalChange.Nonworking);
                end;
            end;
          until BaseCalChange.Next = 0;
        Description := '';
    end;

    [Scope('Personalization')]
    procedure CheckCustomizedDateStatus(SourceType: Option Company,Customer,Vendor,Location,"Shipping Agent",Service;SourceCode: Code[20];AdditionalSourceCode: Code[20];CalendarCode: Code[10];TargetDate: Date;var Description: Text[50]): Boolean
    begin
        CombineChanges(SourceType,SourceCode,AdditionalSourceCode,CalendarCode);
        TempCustChange.Reset;
        TempCustChange.SetCurrentKey("Entry No.");
        if TempCustChange.FindSet then
          repeat
            case TempCustChange."Recurring System" of
              TempCustChange."Recurring System"::" ":
                if TargetDate = TempCustChange.Date then begin
                  Description := TempCustChange.Description;
                  exit(TempCustChange.Nonworking);
                end;
              TempCustChange."Recurring System"::"Weekly Recurring":
                if Date2DWY(TargetDate,1) = TempCustChange.Day then begin
                  Description := TempCustChange.Description;
                  exit(TempCustChange.Nonworking);
                end;
              TempCustChange."Recurring System"::"Annual Recurring":
                if (Date2DMY(TargetDate,2) = Date2DMY(TempCustChange.Date,2)) and
                   (Date2DMY(TargetDate,1) = Date2DMY(TempCustChange.Date,1))
                then begin
                  Description := TempCustChange.Description;
                  exit(TempCustChange.Nonworking);
                end;
            end;
          until TempCustChange.Next = 0;
        Description := '';
    end;

    local procedure CombineChanges(SourceType: Option Company,Customer,Vendor,Location,"Shipping Agent",Service;SourceCode: Code[20];AdditionalSourceCode: Code[20];CalendarCode: Code[10])
    begin
        if (SourceType = OldSourceType) and
           (SourceCode = OldSourceCode) and (AdditionalSourceCode = OldAdditionalSourceCode) and (CalendarCode = OldCalendarCode)
        then
          exit;

        TempCustChange.Reset;
        TempCustChange.DeleteAll;

        TempCounter := 0;
        CustCalChange.Reset;
        CustCalChange.SetRange("Source Type",SourceType);
        CustCalChange.SetRange("Source Code",SourceCode);
        CustCalChange.SetRange("Base Calendar Code",CalendarCode);
        CustCalChange.SetRange("Additional Source Code",AdditionalSourceCode);
        if CustCalChange.FindSet then
          repeat
            TempCounter := TempCounter + 1;
            TempCustChange.Init;
            TempCustChange."Source Type" := CustCalChange."Source Type";
            TempCustChange."Source Code" := CustCalChange."Source Code";
            TempCustChange."Base Calendar Code" := CustCalChange."Base Calendar Code";
            TempCustChange."Additional Source Code" := CustCalChange."Additional Source Code";
            TempCustChange.Date := CustCalChange.Date;
            TempCustChange.Description := CustCalChange.Description;
            TempCustChange.Day := CustCalChange.Day;
            TempCustChange.Nonworking := CustCalChange.Nonworking;
            TempCustChange."Recurring System" := CustCalChange."Recurring System";
            TempCustChange."Entry No." := TempCounter;
            TempCustChange.Insert;
          until CustCalChange.Next = 0;

        BaseCalChange.Reset;
        BaseCalChange.SetRange("Base Calendar Code",CalendarCode);
        if BaseCalChange.FindSet then
          repeat
            TempCounter := TempCounter + 1;
            TempCustChange.Init;
            TempCustChange."Entry No." := TempCounter;
            TempCustChange."Source Type" := SourceType;
            TempCustChange."Source Code" := SourceCode;
            TempCustChange."Base Calendar Code" := BaseCalChange."Base Calendar Code";
            TempCustChange.Date := BaseCalChange.Date;
            TempCustChange.Description := BaseCalChange.Description;
            TempCustChange.Day := BaseCalChange.Day;
            TempCustChange.Nonworking := BaseCalChange.Nonworking;
            TempCustChange."Recurring System" := BaseCalChange."Recurring System";
            TempCustChange.Insert;
          until BaseCalChange.Next = 0;

        OldSourceType := SourceType;
        OldSourceCode := SourceCode;
        OldAdditionalSourceCode := AdditionalSourceCode;
        OldCalendarCode := CalendarCode;
    end;

    [Scope('Personalization')]
    procedure CreateWhereUsedEntries(BaseCalendarCode: Code[10])
    var
        WhereUsedBaseCalendar: Record "Where Used Base Calendar";
    begin
        WhereUsedBaseCalendar.DeleteAll;
        if CompanyInfo.Get then
          if CompanyInfo."Base Calendar Code" = BaseCalendarCode then begin
            WhereUsedBaseCalendar.Init;
            WhereUsedBaseCalendar."Base Calendar Code" := BaseCalendarCode;
            WhereUsedBaseCalendar."Source Type" := WhereUsedBaseCalendar."Source Type"::Company;
            WhereUsedBaseCalendar."Source Name" := CompanyInfo.Name;
            WhereUsedBaseCalendar."Customized Changes Exist" :=
              CustomizedChangesExist(
                WhereUsedBaseCalendar."Source Type"::Company,'','',BaseCalendarCode);
            WhereUsedBaseCalendar.Insert;
          end;

        Customer.Reset;
        Customer.SetRange("Base Calendar Code",BaseCalendarCode);
        if Customer.FindSet then
          repeat
            WhereUsedBaseCalendar.Init;
            WhereUsedBaseCalendar."Base Calendar Code" := BaseCalendarCode;
            WhereUsedBaseCalendar."Source Type" := WhereUsedBaseCalendar."Source Type"::Customer;
            WhereUsedBaseCalendar."Source Code" := Customer."No.";
            WhereUsedBaseCalendar."Source Name" := Customer.Name;
            WhereUsedBaseCalendar."Customized Changes Exist" :=
              CustomizedChangesExist(
                WhereUsedBaseCalendar."Source Type"::Customer,Customer."No.",'',BaseCalendarCode);
            WhereUsedBaseCalendar.Insert;
          until Customer.Next = 0;

        Vendor.Reset;
        Vendor.SetRange("Base Calendar Code",BaseCalendarCode);
        if Vendor.FindSet then
          repeat
            WhereUsedBaseCalendar.Init;
            WhereUsedBaseCalendar."Base Calendar Code" := BaseCalendarCode;
            WhereUsedBaseCalendar."Source Type" := WhereUsedBaseCalendar."Source Type"::Vendor;
            WhereUsedBaseCalendar."Source Code" := Vendor."No.";
            WhereUsedBaseCalendar."Source Name" := Vendor.Name;
            WhereUsedBaseCalendar."Customized Changes Exist" :=
              CustomizedChangesExist(
                WhereUsedBaseCalendar."Source Type"::Vendor,Vendor."No.",'',BaseCalendarCode);
            WhereUsedBaseCalendar.Insert;
          until Vendor.Next = 0;

        Location.Reset;
        Location.SetRange("Base Calendar Code",BaseCalendarCode);
        if Location.FindSet then
          repeat
            WhereUsedBaseCalendar.Init;
            WhereUsedBaseCalendar."Base Calendar Code" := BaseCalendarCode;
            WhereUsedBaseCalendar."Source Type" := WhereUsedBaseCalendar."Source Type"::Location;
            WhereUsedBaseCalendar."Source Code" := Location.Code;
            WhereUsedBaseCalendar."Source Name" := Location.Name;
            WhereUsedBaseCalendar."Customized Changes Exist" :=
              CustomizedChangesExist(
                WhereUsedBaseCalendar."Source Type"::Location,Location.Code,'',BaseCalendarCode);
            WhereUsedBaseCalendar.Insert;
          until Location.Next = 0;

        Shippingagent.Reset;
        Shippingagent.SetRange("Base Calendar Code",BaseCalendarCode);
        if Shippingagent.FindSet then
          repeat
            WhereUsedBaseCalendar.Init;
            WhereUsedBaseCalendar."Base Calendar Code" := BaseCalendarCode;
            WhereUsedBaseCalendar."Source Type" := WhereUsedBaseCalendar."Source Type"::"Shipping Agent";
            WhereUsedBaseCalendar."Source Code" := Shippingagent."Shipping Agent Code";
            WhereUsedBaseCalendar."Additional Source Code" := Shippingagent.Code;
            WhereUsedBaseCalendar."Source Name" := Shippingagent.Description;
            WhereUsedBaseCalendar."Customized Changes Exist" :=
              CustomizedChangesExist(
                WhereUsedBaseCalendar."Source Type"::"Shipping Agent",Shippingagent."Shipping Agent Code",
                Shippingagent.Code,BaseCalendarCode);
            WhereUsedBaseCalendar.Insert;
          until Shippingagent.Next = 0;

        if ServMgtSetup.Get then
          if ServMgtSetup."Base Calendar Code" = BaseCalendarCode then begin
            WhereUsedBaseCalendar.Init;
            WhereUsedBaseCalendar."Base Calendar Code" := BaseCalendarCode;
            WhereUsedBaseCalendar."Source Type" := WhereUsedBaseCalendar."Source Type"::Service;
            WhereUsedBaseCalendar."Source Name" := ServMgtSetup.TableCaption;
            WhereUsedBaseCalendar."Customized Changes Exist" :=
              CustomizedChangesExist(
                WhereUsedBaseCalendar."Source Type"::Service,'','',BaseCalendarCode);
            WhereUsedBaseCalendar.Insert;
          end;

        Commit;
    end;

    [Scope('Personalization')]
    procedure CustomizedChangesExist(SourceType: Option Company,Customer,Vendor,Location,"Shipping Agent",Service;SourceCode: Code[20];AdditionalSourceCode: Code[20];BaseCalendarCode: Code[10]): Boolean
    begin
        CustCalChange.Reset;
        CustCalChange.SetRange("Source Type",SourceType);
        CustCalChange.SetRange("Source Code",SourceCode);
        CustCalChange.SetRange("Additional Source Code",AdditionalSourceCode);
        CustCalChange.SetRange("Base Calendar Code",BaseCalendarCode);
        if CustCalChange.FindFirst then
          exit(true);
    end;

    [Scope('Personalization')]
    procedure CustomizedCalendarExistText(SourceType: Option Company,Customer,Vendor,Location,"Shipping Agent",Service;SourceCode: Code[20];AdditionalSourceCode: Code[20];BaseCalendarCode: Code[10]): Text[10]
    begin
        if CustomizedChangesExist(SourceType,SourceCode,AdditionalSourceCode,BaseCalendarCode) then
          exit(Text001);
        exit(Text002);
    end;

    [Scope('Personalization')]
    procedure CalcDateBOC(OrgDateExpression: Text[30];OrgDate: Date;FirstSourceType: Option Company,Customer,Vendor,Location,"Shipping Agent",Service;FirstSourceCode: Code[20];FirstAddCode: Code[20];SecondSourceType: Option Company,Customer,Vendor,Location,"Shipping Agent",Service;SecondSourceCode: Code[20];SecondAddCode: Code[20];CheckBothCalendars: Boolean): Date
    var
        FirstCalCode: Code[10];
        SecondCalCode: Code[10];
        LoopTerminator: Boolean;
        LoopCounter: Integer;
        NewDate: Date;
        TempDesc: Text[30];
        Nonworking: Boolean;
        Nonworking2: Boolean;
        LoopFactor: Integer;
        CalConvTimeFrame: Integer;
        DateFormula: DateFormula;
        Ok: Boolean;
        NegDateFormula: DateFormula;
        Handled: Boolean;
    begin
        OnBeforeCalcDateBOC(
          FirstCalCode,FirstSourceType,FirstSourceCode,FirstAddCode,
          SecondCalCode,SecondSourceType,SecondSourceCode,SecondAddCode,CalConvTimeFrame,Handled);

        if not Handled then begin
          if (FirstSourceType = FirstSourceType::"Shipping Agent") and
             ((FirstSourceCode = '') or (FirstAddCode = ''))
          then begin
            FirstSourceType := FirstSourceType::Company;
            FirstSourceCode := '';
            FirstAddCode := '';
          end;
          if (SecondSourceType = SecondSourceType::"Shipping Agent") and
             ((SecondSourceCode = '') or (SecondAddCode = ''))
          then begin
            SecondSourceType := SecondSourceType::Company;
            SecondSourceCode := '';
            SecondAddCode := '';
          end;
          if (FirstSourceType = FirstSourceType::Location) and
             (FirstSourceCode = '')
          then begin
            FirstSourceType := FirstSourceType::Company;
            FirstSourceCode := '';
          end;
          if (SecondSourceType = SecondSourceType::Location) and
             (SecondSourceCode = '')
          then begin
            SecondSourceType := SecondSourceType::Company;
            SecondSourceCode := '';
          end;
          if CompanyInfo.Get then
            CalConvTimeFrame := CalcDate(CompanyInfo."Cal. Convergence Time Frame",WorkDate) - WorkDate;

          FirstCalCode := GetCalendarCode(FirstSourceType,FirstSourceCode,FirstAddCode);
          SecondCalCode := GetCalendarCode(SecondSourceType,SecondSourceCode,SecondAddCode);
        end;

        Evaluate(DateFormula,OrgDateExpression);
        Evaluate(NegDateFormula,'<-0D>');

        if OrgDate = 0D then
          OrgDate := WorkDate;
        if (CalcDate(DateFormula,OrgDate) >= OrgDate) and (DateFormula <> NegDateFormula) then
          LoopFactor := 1
        else
          LoopFactor := -1;

        NewDate := OrgDate;
        if CalcDate(DateFormula,OrgDate) <> OrgDate then
          repeat
            NewDate := NewDate + LoopFactor;
            if CheckBothCalendars and (FirstCalCode = '') and (SecondCalCode <> '') then
              Ok := not CheckCustomizedDateStatus(
                  SecondSourceType,SecondSourceCode,SecondAddCode,SecondCalCode,NewDate,TempDesc)
            else
              Ok := not CheckCustomizedDateStatus(
                  FirstSourceType,FirstSourceCode,FirstAddCode,FirstCalCode,NewDate,TempDesc);
            if Ok then
              LoopCounter := LoopCounter + 1;
            if NewDate >= OrgDate + CalConvTimeFrame then
              LoopCounter := Abs(CalcDate(DateFormula,OrgDate) - OrgDate);
          until LoopCounter = Abs(CalcDate(DateFormula,OrgDate) - OrgDate);

        LoopCounter := 0;
        repeat
          LoopCounter := LoopCounter + 1;
          Nonworking :=
            CheckCustomizedDateStatus(
              FirstSourceType,FirstSourceCode,FirstAddCode,FirstCalCode,NewDate,TempDesc);
          Nonworking2 :=
            CheckCustomizedDateStatus(
              SecondSourceType,SecondSourceCode,SecondAddCode,SecondCalCode,NewDate,TempDesc);
          if Nonworking then begin
            NewDate := NewDate + LoopFactor;
          end else begin
            if not CheckBothCalendars then
              exit(NewDate);

            if (Nonworking = false) and
               (Nonworking2 = false)
            then
              exit(NewDate);

            NewDate := NewDate + LoopFactor;
          end;
          if LoopCounter >= CalConvTimeFrame then
            LoopTerminator := true;
        until LoopTerminator = true;
        exit(NewDate);
    end;

    [Scope('Personalization')]
    procedure CalcDateBOC2(OrgDateExpression: Text[30];OrgDate: Date;FirstSourceType: Option Company,Customer,Vendor,Location,"Shipping Agent",Service;FirstSourceCode: Code[20];FirstAddCode: Code[20];SecondSourceType: Option Company,Customer,Vendor,Location,"Shipping Agent",Service;SecondSourceCode: Code[20];SecondAddCode: Code[20];CheckBothCalendars: Boolean): Date
    var
        NewOrgDateExpression: Text[30];
    begin
        // Use this procedure to subtract time expression.
        NewOrgDateExpression := ReverseSign(OrgDateExpression);
        exit(CalcDateBOC(NewOrgDateExpression,OrgDate,FirstSourceType,FirstSourceCode,FirstAddCode,
            SecondSourceType,SecondSourceCode,SecondAddCode,CheckBothCalendars));
    end;

    local procedure ReverseSign(DateFormulaExpr: Text[30]): Text[30]
    var
        NewDateFormulaExpr: Text[30];
        Formula: DateFormula;
    begin
        Evaluate(Formula,DateFormulaExpr);
        NewDateFormulaExpr := ConvertStr(Format(Formula),'+-','-+');
        if not (DateFormulaExpr[1] in ['+','-']) then
          NewDateFormulaExpr := '-' + NewDateFormulaExpr;
        exit(NewDateFormulaExpr);
    end;

    [Scope('Personalization')]
    procedure CheckDateFormulaPositive(CurrentDateFormula: DateFormula)
    begin
        if CalcDate(CurrentDateFormula) < Today then
          Error(Text003,CurrentDateFormula);
    end;

    [Scope('Personalization')]
    procedure CalcTimeDelta(EndingTime: Time;StartingTime: Time) Result: Integer
    begin
        Result := EndingTime - StartingTime;
        if (Result <> 0) and (EndingTime = 235959T) then
          Result += 1000;
    end;

    [Scope('Personalization')]
    procedure CalcTimeSubtract(Time: Time;Value: Integer) Result: Time
    begin
        Result := Time - Value;
        if (Result <> 000000T) and (Time = 235959T) and (Value <> 0) then
          Result += 1000;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcDateBOC(var FirstCalCode: Code[10];var FirstSourceType: Option Company,Customer,Vendor,Location,"Shipping Agent",Service;var FirstSourceCode: Code[20];var FirstAddCode: Code[20];var SecondCalcCode: Code[10];var SecondSourceType: Option Company,Customer,Vendor,Location,"Shipping Agent",Service;var SecondSourceCode: Code[20];var SecondAddCode: Code[20];var CalConvTimeFrame: Integer;var Handled: Boolean)
    begin
    end;

    procedure DeleteCustomizedBaseCalendarData(SourceType: Option;SourceCode: Code[20])
    var
        CustomizedCalendarChange: Record "Customized Calendar Change";
        CustomizedCalendarEntry: Record "Customized Calendar Entry";
        WhereUsedBaseCalendar: Record "Where Used Base Calendar";
    begin
        CustomizedCalendarChange.SetRange("Source Type",SourceType);
        CustomizedCalendarChange.SetRange("Source Code",SourceCode);
        CustomizedCalendarChange.DeleteAll;

        CustomizedCalendarEntry.SetRange("Source Type",SourceType);
        CustomizedCalendarEntry.SetRange("Source Code",SourceCode);
        CustomizedCalendarEntry.DeleteAll;

        WhereUsedBaseCalendar.SetRange("Source Type",SourceType);
        WhereUsedBaseCalendar.SetRange("Source Code",SourceCode);
        WhereUsedBaseCalendar.DeleteAll;
    end;

    procedure RenameCustomizedBaseCalendarData(SourceType: Option;SourceCode: Code[20];xSourceCode: Code[20])
    var
        CustomizedCalendarChange: Record "Customized Calendar Change";
        TempCustomizedCalendarChange: Record "Customized Calendar Change" temporary;
        CustomizedCalendarEntry: Record "Customized Calendar Entry";
        TempCustomizedCalendarEntry: Record "Customized Calendar Entry" temporary;
        WhereUsedBaseCalendar: Record "Where Used Base Calendar";
        TempWhereUsedBaseCalendar: Record "Where Used Base Calendar" temporary;
    begin
        CustomizedCalendarChange.SetRange("Source Type",SourceType);
        CustomizedCalendarChange.SetRange("Source Code",xSourceCode);
        if CustomizedCalendarChange.FindSet then
          repeat
            TempCustomizedCalendarChange := CustomizedCalendarChange;
            TempCustomizedCalendarChange.Insert;
          until CustomizedCalendarChange.Next = 0;
        if TempCustomizedCalendarChange.FindSet then
          repeat
            Clear(CustomizedCalendarChange);
            CustomizedCalendarChange := TempCustomizedCalendarChange;
            CustomizedCalendarChange.Rename(
              CustomizedCalendarChange."Source Type",
              SourceCode,
              CustomizedCalendarChange."Additional Source Code",
              CustomizedCalendarChange."Base Calendar Code",
              CustomizedCalendarChange."Recurring System",
              CustomizedCalendarChange.Date,
              CustomizedCalendarChange.Day,
              CustomizedCalendarChange."Entry No.");
          until TempCustomizedCalendarChange.Next = 0;

        CustomizedCalendarEntry.SetRange("Source Type",SourceType);
        CustomizedCalendarEntry.SetRange("Source Code",xSourceCode);
        if CustomizedCalendarEntry.FindSet then
          repeat
            TempCustomizedCalendarEntry := CustomizedCalendarEntry;
            TempCustomizedCalendarEntry.Insert;
          until CustomizedCalendarEntry.Next = 0;
        if TempCustomizedCalendarEntry.FindSet then
          repeat
            Clear(CustomizedCalendarEntry);
            CustomizedCalendarEntry := TempCustomizedCalendarEntry;
            CustomizedCalendarEntry.Rename(
              CustomizedCalendarEntry."Source Type",
              SourceCode,
              CustomizedCalendarEntry."Additional Source Code",
              CustomizedCalendarEntry."Base Calendar Code",
              CustomizedCalendarEntry.Date);
          until TempCustomizedCalendarEntry.Next = 0;

        WhereUsedBaseCalendar.SetRange("Source Type",SourceType);
        WhereUsedBaseCalendar.SetRange("Source Code",xSourceCode);
        if WhereUsedBaseCalendar.FindSet then
          repeat
            TempWhereUsedBaseCalendar := WhereUsedBaseCalendar;
            TempWhereUsedBaseCalendar.Insert;
          until WhereUsedBaseCalendar.Next = 0;
        if TempWhereUsedBaseCalendar.FindSet then
          repeat
            Clear(WhereUsedBaseCalendar);
            WhereUsedBaseCalendar := TempWhereUsedBaseCalendar;
            WhereUsedBaseCalendar.Rename(
              WhereUsedBaseCalendar."Base Calendar Code",
              WhereUsedBaseCalendar."Source Type",
              SourceCode,
              WhereUsedBaseCalendar."Source Name");
          until TempWhereUsedBaseCalendar.Next = 0;
    end;
}

