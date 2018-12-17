codeunit 41 TextManagement
{
    // version NAVW113.00

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        TodayText: Label 'TODAY', Comment='Must be uppercase hint reuse the transtaltion from cod1 for 2009 sp1';
        WorkdateText: Label 'WORKDATE', Comment='Must be uppercase hint reuse the transtaltion from cod1 for 2009 sp1';
        PeriodText: Label 'PERIOD', Comment='Must be uppercase hint reuse the transtaltion from cod1 for 2009 sp1';
        YearText: Label 'YEAR', Comment='Must be uppercase hint reuse the transtaltion from cod1 for 2009 sp1';
        NumeralOutOfRangeError: Label 'When you specify periods and years, you can use numbers from 1 - 999, such as P-1, P1, Y2 or Y+3.';
        AlphabetText: Label 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', Comment='Uppercase - translate into entire alphabet.';
        NowText: Label 'NOW', Comment='Must be uppercase.';
        YesterdayText: Label 'YESTERDAY', Comment='Must be uppercase';
        TomorrowText: Label 'TOMORROW', Comment='Must be uppercase';
        WeekText: Label 'WEEK', Comment='Must be uppercase';
        MonthText: Label 'MONTH', Comment='Must be uppercase';
        QuarterText: Label 'QUARTER', Comment='Must be uppercase';
        UserText: Label 'USER', Comment='Must be uppercase';
        MeText: Label 'ME', Comment='Must be uppercase';
        MyCustomersText: Label 'MYCUSTOMERS', Comment='Must be uppercase';
        MyItemsText: Label 'MYITEMS', Comment='Must be uppercase';
        MyVendorsText: Label 'MYVENDORS', Comment='Must be uppercase';
        CompanyText: Label 'COMPANY', Comment='Must be uppercase';
        OverflowMsg: Label 'The filter contains more than 2000 numbers and has been truncated.';
        UnincrementableStringErr: Label '%1 contains no number and cannot be incremented.';
        FilterType: Option DateTime,Date,Time;

    [Scope('Personalization')]
    procedure MakeDateTimeText(var DateTimeText: Text): Integer
    var
        Date: Date;
        Time: Time;
    begin
        if GetSeparateDateTime(DateTimeText,Date,Time) then begin
          if Date = 0D then
            exit(0);
          if Time = 0T then
            Time := 000000T;
          DateTimeText := Format(CreateDateTime(Date,Time));
        end;
        exit(0);
    end;

    [Scope('Personalization')]
    procedure GetSeparateDateTime(DateTimeText: Text;var Date: Date;var Time: Time): Boolean
    var
        DateText: Text[250];
        TimeText: Text[250];
        Position: Integer;
        Length: Integer;
    begin
        if DateTimeText in [NowText,'NOW'] then
          DateTimeText := Format(CurrentDateTime);
        Date := 0D;
        Time := 0T;
        Position := 1;
        Length := StrLen(DateTimeText);
        ReadCharacter(' ',DateTimeText,Position,Length);
        ReadUntilCharacter(' ',DateTimeText,Position,Length);
        DateText := DelChr(CopyStr(DateTimeText,1,Position - 1),'<>');
        TimeText := DelChr(CopyStr(DateTimeText,Position),'<>');
        if DateText = '' then
          exit(true);

        if MakeDateText(DateText) = 0 then;
        if not Evaluate(Date,DateText) then
          exit(false);

        if TimeText = '' then
          exit(true);

        if MakeTimeText(TimeText) = 0 then;
        if Evaluate(Time,TimeText) then
          exit(true);
    end;

    [Scope('Personalization')]
    procedure MakeDateText(var DateText: Text): Integer
    var
        Date: Date;
        PartOfText: Text;
        Position: Integer;
        Length: Integer;
    begin
        Position := 1;
        Length := StrLen(DateText);
        ReadCharacter(' ',DateText,Position,Length);
        if not FindText(PartOfText,DateText,Position,Length) then
          exit(0);
        case PartOfText of
          CopyStr('TODAY',1,StrLen(PartOfText)),CopyStr(TodayText,1,StrLen(PartOfText)):
            Date := Today;
          CopyStr('WORKDATE',1,StrLen(PartOfText)),CopyStr(WorkdateText,1,StrLen(PartOfText)):
            Date := WorkDate;
          else
            exit(0);
        end;
        Position := Position + StrLen(PartOfText);
        ReadCharacter(' ',DateText,Position,Length);
        if Position > Length then begin
          DateText := Format(Date);
          exit(0);
        end;
        exit(Position);
    end;

    [Scope('Personalization')]
    procedure MakeTimeText(var TimeText: Text): Integer
    var
        PartOfText: Text[132];
        Position: Integer;
        Length: Integer;
    begin
        Position := 1;
        Length := StrLen(TimeText);
        ReadCharacter(' ',TimeText,Position,Length);
        if not FindText(PartOfText,TimeText,Position,Length) then
          exit(0);
        if PartOfText <> CopyStr(TimeText,1,StrLen(PartOfText)) then
          exit(0);
        Position := Position + StrLen(PartOfText);
        ReadCharacter(' ',TimeText,Position,Length);
        if Position <= Length then
          exit(Position);
        TimeText := Format(000000T + Round(Time - 000000T,1000));
        exit(0);
    end;

    [Scope('Personalization')]
    procedure MakeText(var Text: Text): Integer
    var
        StandardText: Record "Standard Text";
        PartOfText: Text[132];
        Position: Integer;
        Length: Integer;
    begin
        Position := 1;
        Length := StrLen(Text);
        ReadCharacter(' ',Text,Position,Length);
        if not ReadSymbol('?',Text,Position,Length) then
          exit(0);
        PartOfText := CopyStr(Text,Position);
        if PartOfText = '' then begin
          if PAGE.RunModal(0,StandardText) = ACTION::LookupOK then
            Text := StandardText.Description;
          exit(0);
        end;
        StandardText.Code := CopyStr(Text,Position,MaxStrLen(StandardText.Code));
        if not StandardText.Find('=>') or
           (UpperCase(PartOfText) <> CopyStr(StandardText.Code,1,StrLen(PartOfText)))
        then
          exit(Position);
        Text := StandardText.Description;
        exit(0);
    end;

    procedure MakeTextFilter(var TextFilterText: Text): Integer
    var
        Position: Integer;
        Length: Integer;
        PartOfText: Text[250];
        HandledByEvent: Boolean;
    begin
        OnBeforeMakeTextFilter(TextFilterText,Position,HandledByEvent);
        if HandledByEvent then
          exit(Position);

        Position := 1;
        Length := StrLen(TextFilterText);
        ReadCharacter(' ',TextFilterText,Position,Length);
        if FindText(PartOfText,TextFilterText,Position,Length) then
          case PartOfText of
            CopyStr('ME',1,StrLen(PartOfText)),CopyStr(MeText,1,StrLen(PartOfText)):
              begin
                Position := Position + StrLen(PartOfText);
                TextFilterText := UserId;
              end;
            CopyStr('USER',1,StrLen(PartOfText)),CopyStr(UserText,1,StrLen(PartOfText)):
              begin
                Position := Position + StrLen(PartOfText);
                TextFilterText := UserId;
              end;
            CopyStr('COMPANY',1,StrLen(PartOfText)),CopyStr(CompanyText,1,StrLen(PartOfText)):
              begin
                Position := Position + StrLen(PartOfText);
                TextFilterText := CompanyName;
              end;
            CopyStr('MYCUSTOMERS',1,StrLen(PartOfText)),CopyStr(MyCustomersText,1,StrLen(PartOfText)):
              begin
                Position := Position + StrLen(PartOfText);
                GetMyFilterText(TextFilterText,DATABASE::"My Customer");
              end;
            CopyStr('MYITEMS',1,StrLen(PartOfText)),CopyStr(MyItemsText,1,StrLen(PartOfText)):
              begin
                Position := Position + StrLen(PartOfText);
                GetMyFilterText(TextFilterText,DATABASE::"My Item");
              end;
            CopyStr('MYVENDORS',1,StrLen(PartOfText)),CopyStr(MyVendorsText,1,StrLen(PartOfText)):
              begin
                Position := Position + StrLen(PartOfText);
                GetMyFilterText(TextFilterText,DATABASE::"My Vendor");
              end;
          end;
        OnAfterMakeTextFilter(TextFilterText,Position);
        exit(Position);
    end;

    [Scope('Personalization')]
    procedure MakeDateTimeFilter(var DateTimeFilterText: Text): Integer
    var
        FilterText: Text;
    begin
        FilterText := DateTimeFilterText;
        MakeFilterExpression(FilterType::DateTime,FilterText);
        DateTimeFilterText := CopyStr(FilterText,1,MaxStrLen(DateTimeFilterText));
        OnAfterMakeDateTimeFilter(DateTimeFilterText);
        exit(0);
    end;

    local procedure MakeDateTimeFilter2(var DateTimeFilterText: Text)
    var
        DateTime1: DateTime;
        DateTime2: DateTime;
        Date1: Date;
        Date2: Date;
        Time1: Time;
        Time2: Time;
        StringPosition: Integer;
    begin
        StringPosition := StrPos(DateTimeFilterText,'..');
        if StringPosition = 0 then begin
          if not GetSeparateDateTime(DateTimeFilterText,Date1,Time1) then
            exit;
          if Date1 = 0D then
            exit;
          if Time1 = 0T then begin
            DateTimeFilterText := Format(CreateDateTime(Date1,000000T)) + '..' + Format(CreateDateTime(Date1,235959.995T));
            exit;
          end;
          DateTimeFilterText := Format(CreateDateTime(Date1,Time1));
          exit;
        end;
        if not GetSeparateDateTime(CopyStr(DateTimeFilterText,1,StringPosition - 1),Date1,Time1) then
          exit;
        if not GetSeparateDateTime(CopyStr(DateTimeFilterText,StringPosition + 2),Date2,Time2) then
          exit;

        if (Date1 = 0D) and (Date2 = 0D) then
          exit;

        if Date1 <> 0D then begin
          if Time1 = 0T then
            Time1 := 000000T;
          DateTime1 := CreateDateTime(Date1,Time1);
        end;
        if Date2 <> 0D then begin
          if Time2 = 0T then
            Time2 := 235959T;
          DateTime2 := CreateDateTime(Date2,Time2);
        end;
        DateTimeFilterText := Format(DateTime1) + '..' + Format(DateTime2);
    end;

    [Scope('Personalization')]
    procedure MakeDateFilter(var DateFilterText: Text): Integer
    begin
        MakeFilterExpression(FilterType::Date,DateFilterText);
        OnAfterMakeDateFilter(DateFilterText);
        exit(0);
    end;

    local procedure MakeDateFilterInternal(var DateFilterText: Text): Integer
    var
        Date1: Date;
        Date2: Date;
        Text1: Text[30];
        Text2: Text[30];
        StringPosition: Integer;
        i: Integer;
        OK: Boolean;
    begin
        DateFilterText := DelChr(DateFilterText,'<>');
        if DateFilterText = '' then
          exit(0);
        StringPosition := StrPos(DateFilterText,'..');
        if StringPosition = 0 then begin
          i := MakeDateFilter2(OK,Date1,Date2,DateFilterText);
          if i <> 0 then
            exit(i);
          if OK then
            if Date1 = Date2 then
              DateFilterText := Format(Date1)
            else
              DateFilterText := StrSubstNo('%1..%2',Date1,Date2);
          exit(0);
        end;

        Text1 := CopyStr(DateFilterText,1,StringPosition - 1);
        i := MakeDateFilter2(OK,Date1,Date2,Text1);
        if i <> 0 then
          exit(i);
        if OK then
          Text1 := Format(Date1);

        ReadCharacter('.',DateFilterText,StringPosition,StrLen(DateFilterText));

        Text2 := CopyStr(DateFilterText,StringPosition);
        i := MakeDateFilter2(OK,Date1,Date2,Text2);
        if i <> 0 then
          exit(StringPosition + i - 1);
        if OK then
          Text2 := Format(Date2);

        DateFilterText := Text1 + '..' + Text2;
        exit(0);
    end;

    local procedure MakeDateFilter2(var OK: Boolean;var Date1: Date;var Date2: Date;DateFilterText: Text): Integer
    var
        PartOfText: Text[250];
        RemainderOfText: Text;
        Position: Integer;
        Length: Integer;
        DateFormula: DateFormula;
    begin
        if Evaluate(DateFormula,DateFilterText) then begin
          RemainderOfText := DateFilterText;
          DateFilterText := '';
        end else begin
          Position := StrPos(DateFilterText,'+');
          if Position = 0 then
            Position := StrPos(DateFilterText,'-');

          if Position > 0 then begin
            RemainderOfText := DelChr(CopyStr(DateFilterText,Position));
            if Evaluate(DateFormula,RemainderOfText) then
              DateFilterText := DelChr(CopyStr(DateFilterText,1,Position - 1))
            else
              RemainderOfText := '';
          end;
        end;

        Position := 1;
        Length := StrLen(DateFilterText);
        FindText(PartOfText,DateFilterText,Position,Length);

        if PartOfText <> '' then
          case PartOfText of
            CopyStr('PERIOD',1,StrLen(PartOfText)),CopyStr(PeriodText,1,StrLen(PartOfText)):
              OK := FindPeriod(Date1,Date2,false,DateFilterText,PartOfText,Position,Length);
            CopyStr('YEAR',1,StrLen(PartOfText)),CopyStr(YearText,1,StrLen(PartOfText)):
              OK := FindPeriod(Date1,Date2,true,DateFilterText,PartOfText,Position,Length);
            CopyStr('TODAY',1,StrLen(PartOfText)),CopyStr(TodayText,1,StrLen(PartOfText)):
              OK := FindDate(Today,Date1,Date2,DateFilterText,PartOfText,Position,Length);
            CopyStr('WORKDATE',1,StrLen(PartOfText)),CopyStr(WorkdateText,1,StrLen(PartOfText)):
              OK := FindDate(WorkDate,Date1,Date2,DateFilterText,PartOfText,Position,Length);
            CopyStr('NOW',1,StrLen(PartOfText)),CopyStr(NowText,1,StrLen(PartOfText)):
              OK := FindDate(DT2Date(CurrentDateTime),Date1,Date2,DateFilterText,PartOfText,Position,Length);
            CopyStr('YESTERDAY',1,StrLen(PartOfText)),CopyStr(YesterdayText,1,StrLen(PartOfText)):
              OK := FindDate(CalcDate('<-1D>'),Date1,Date2,DateFilterText,PartOfText,Position,Length);
            CopyStr('TOMORROW',1,StrLen(PartOfText)),CopyStr(TomorrowText,1,StrLen(PartOfText)):
              OK := FindDate(CalcDate('<1D>'),Date1,Date2,DateFilterText,PartOfText,Position,Length);
            CopyStr('WEEK',1,StrLen(PartOfText)),CopyStr(WeekText,1,StrLen(PartOfText)):
              OK := FindDates('<-CW>','<CW>',Date1,Date2,DateFilterText,PartOfText,Position,Length);
            CopyStr('MONTH',1,StrLen(PartOfText)),CopyStr(MonthText,1,StrLen(PartOfText)):
              OK := FindDates('<-CM>','<CM>',Date1,Date2,DateFilterText,PartOfText,Position,Length);
            CopyStr('QUARTER',1,StrLen(PartOfText)),CopyStr(QuarterText,1,StrLen(PartOfText)):
              OK := FindDates('<-CQ>','<CQ>',Date1,Date2,DateFilterText,PartOfText,Position,Length);
          end
        else
          if (DateFilterText <> '') and Evaluate(Date1,DateFilterText) then begin
            Date2 := Date1;
            OK := true;
            Position := 0;
          end else
            if RemainderOfText <> '' then begin
              Date1 := Today;
              Date2 := Date1;
              OK := true;
              Position := 0;
            end else
              OK := false;

        if OK and (RemainderOfText <> '') then begin
          Date1 := CalcDate(DateFormula,Date1);
          Date2 := CalcDate(DateFormula,Date2);
        end;
        exit(Position);
    end;

    [Scope('Personalization')]
    procedure MakeTimeFilter(var TimeFilterText: Text): Integer
    var
        FilterText: Text;
    begin
        FilterText := TimeFilterText;
        MakeFilterExpression(FilterType::Time,FilterText);
        TimeFilterText := CopyStr(FilterText,1,MaxStrLen(TimeFilterText));
        OnAfterMakeTimeFilter(TimeFilterText);
        exit(0);
    end;

    local procedure MakeTimeFilter2(var TimeFilterText: Text)
    var
        Time1: Time;
        Time2: Time;
        StringPosition: Integer;
    begin
        StringPosition := StrPos(TimeFilterText,'..');
        if StringPosition = 0 then begin
          if not GetTime(Time1,TimeFilterText) then
            exit;
          if Time1 = 0T then begin
            TimeFilterText := Format(000000T) + '..' + Format(235959.995T);
            exit;
          end;
          TimeFilterText := Format(Time1);
          exit;
        end;
        if not GetTime(Time1,CopyStr(TimeFilterText,1,StringPosition - 1)) then
          exit;
        if not GetTime(Time2,CopyStr(TimeFilterText,StringPosition + 2)) then
          exit;

        if Time1 = 0T then
          Time1 := 000000T;
        if Time2 = 0T then
          Time2 := 235959T;

        TimeFilterText := Format(Time1) + '..' + Format(Time2);
    end;

    local procedure MakeFilterExpression(TypeOfFilter: Option;var FilterText: Text)
    var
        Head: Text;
        Tail: Text;
        Position: Integer;
        Length: Integer;
    begin
        FilterText := DelChr(FilterText,'<>');
        Position := 1;
        Length := StrLen(FilterText);
        while Length <> 0 do begin
          ReadCharacter(' |()',FilterText,Position,Length);
          if Position > 1 then begin
            Head := Head + CopyStr(FilterText,1,Position - 1);
            FilterText := CopyStr(FilterText,Position);
            Position := 1;
            Length := StrLen(FilterText);
          end;
          if Length <> 0 then begin
            ReadUntilCharacter('|()',FilterText,Position,Length);
            if Position > 1 then begin
              Tail := CopyStr(FilterText,Position);
              FilterText := CopyStr(FilterText,1,Position - 1);
              CallMakeFilterFunction(TypeOfFilter,FilterText);
              Evaluate(Head,Head + FilterText);
              FilterText := Tail;
              Position := 1;
              Length := StrLen(FilterText);
            end;
          end;
        end;
        FilterText := Head;
    end;

    local procedure CallMakeFilterFunction(TypeOfFilter: Option;var FilterText: Text)
    begin
        case TypeOfFilter of
          FilterType::DateTime:
            MakeDateTimeFilter2(FilterText);
          FilterType::Date:
            MakeDateFilterInternal(FilterText);
          FilterType::Time:
            MakeTimeFilter2(FilterText);
        end;
    end;

    [Scope('Personalization')]
    procedure EvaluateIncStr(StringToIncrement: Code[20];ErrorHint: Text)
    begin
        if IncStr(StringToIncrement) = '' then
          Error(UnincrementableStringError,ErrorHint);
    end;

    [Scope('Personalization')]
    procedure UnincrementableStringError(): Text
    begin
        exit(UnincrementableStringErr)
    end;

    local procedure GetTime(var Time0: Time;FilterText: Text): Boolean
    begin
        FilterText := DelChr(FilterText);
        if FilterText in [NowText,'NOW'] then begin
          Time0 := Time;
          exit(true);
        end;
        exit(Evaluate(Time0,FilterText));
    end;

    local procedure FindPeriod(var Date1: Date;var Date2: Date;FindYear: Boolean;DateFilterText: Text;PartOfText: Text;var Position: Integer;Length: Integer): Boolean
    var
        AccountingPeriod: Record "Accounting Period";
        AccountingPeriodMgt: Codeunit "Accounting Period Mgt.";
        Sign: Text[1];
        Numeral: Integer;
    begin
        Position := Position + StrLen(PartOfText);
        ReadCharacter(' ',DateFilterText,Position,Length);

        if AccountingPeriod.IsEmpty then begin
          if FindYear then
            AccountingPeriodMgt.InitStartYearAccountingPeriod(AccountingPeriod,WorkDate)
          else
            AccountingPeriodMgt.InitDefaultAccountingPeriod(AccountingPeriod,WorkDate);
          ReadNumeral(Numeral,DateFilterText,Position,Length);
          Date1 := AccountingPeriod."Starting Date";
          Date2 := CalcDate('<CY>',AccountingPeriod."Starting Date");
          ReadCharacter(' ',DateFilterText,Position,Length);
          if Position > Length then
            Position := 0;
          exit(true);
        end;

        if FindYear then
          AccountingPeriod.SetRange("New Fiscal Year",true)
        else
          AccountingPeriod.SetRange("New Fiscal Year");
        Sign := '';
        if ReadSymbol('+',DateFilterText,Position,Length) then
          Sign := '+'
        else
          if ReadSymbol('-',DateFilterText,Position,Length) then
            Sign := '-';
        if Sign = '' then
          if ReadNumeral(Numeral,DateFilterText,Position,Length) then begin
            if FindYear then
              AccountingPeriod.FindFirst
            else begin
              AccountingPeriod.SetRange("New Fiscal Year",true);
              AccountingPeriod."Starting Date" := WorkDate;
              AccountingPeriod.Find('=<');
              AccountingPeriod.SetRange("New Fiscal Year");
            end;
            AccountingPeriod.Next(Numeral - 1);
          end else begin
            AccountingPeriod."Starting Date" := WorkDate;
            AccountingPeriod.Find('=<');
          end
        else begin
          if not ReadNumeral(Numeral,DateFilterText,Position,Length) then
            exit(true);
          if Sign = '-' then
            Numeral := -Numeral;
          AccountingPeriod."Starting Date" := WorkDate;
          AccountingPeriod.Find('=<');
          AccountingPeriod.Next(Numeral);
        end;
        Date1 := AccountingPeriod."Starting Date";
        if AccountingPeriod.Next = 0 then
          Date2 := DMY2Date(31,12,9999)
        else
          Date2 := AccountingPeriod."Starting Date" - 1;
        ReadCharacter(' ',DateFilterText,Position,Length);
        if Position > Length then
          Position := 0;
        exit(true);
    end;

    local procedure FindDate(Date1Input: Date;var Date1: Date;var Date2: Date;DateFilterText: Text;PartOfText: Text;var Position: Integer;Length: Integer): Boolean
    begin
        Position := Position + StrLen(PartOfText);
        ReadCharacter(' ',DateFilterText,Position,Length);
        Date1 := Date1Input;
        Date2 := Date1;
        if Position > Length then
          Position := 0;
        exit(true);
    end;

    local procedure FindDates(DateFormulaText1: Text;DateFormulaText2: Text;var Date1: Date;var Date2: Date;DateFilterText: Text;PartOfText: Text;var Position: Integer;Length: Integer): Boolean
    var
        DateFormula1: DateFormula;
        DateFormula2: DateFormula;
    begin
        Position := Position + StrLen(PartOfText);
        ReadCharacter(' ',DateFilterText,Position,Length);
        Evaluate(DateFormula1,DateFormulaText1);
        Evaluate(DateFormula2,DateFormulaText2);
        Date1 := CalcDate(DateFormula1);
        Date2 := CalcDate(DateFormula2);
        if Position > Length then
          Position := 0;
        exit(true);
    end;

    local procedure FindText(var PartOfText: Text;Text: Text;Position: Integer;Length: Integer): Boolean
    var
        Position2: Integer;
    begin
        Position2 := Position;
        ReadCharacter(AlphabetText,Text,Position,Length);
        if Position = Position2 then
          exit(false);
        PartOfText := UpperCase(CopyStr(Text,Position2,Position - Position2));
        exit(true);
    end;

    local procedure ReadSymbol(Token: Text[30];Text: Text;var Position: Integer;Length: Integer): Boolean
    begin
        if Token <> CopyStr(Text,Position,StrLen(Token)) then
          exit(false);
        Position := Position + StrLen(Token);
        ReadCharacter(' ',Text,Position,Length);
        exit(true);
    end;

    local procedure ReadNumeral(var Numeral: Integer;Text: Text;var Position: Integer;Length: Integer): Boolean
    var
        Position2: Integer;
        i: Integer;
    begin
        Position2 := Position;
        ReadCharacter('0123456789',Text,Position,Length);
        if Position2 = Position then
          exit(false);
        Numeral := 0;
        for i := Position2 to Position - 1 do
          if Numeral < 1000 then
            Numeral := Numeral * 10 + StrPos('0123456789',CopyStr(Text,i,1)) - 1;
        if (Numeral < 1) or (Numeral > 999) then
          Error(NumeralOutOfRangeError);
        exit(true);
    end;

    local procedure ReadCharacter(Character: Text[50];Text: Text;var Position: Integer;Length: Integer)
    begin
        while (Position <= Length) and (StrPos(Character,UpperCase(CopyStr(Text,Position,1))) <> 0) do
          Position := Position + 1;
    end;

    local procedure ReadUntilCharacter(Character: Text[50];Text: Text;var Position: Integer;Length: Integer)
    begin
        while (Position <= Length) and (StrPos(Character,UpperCase(CopyStr(Text,Position,1))) = 0) do
          Position := Position + 1;
    end;

    local procedure GetMyFilterText(var TextFilterText: Text;MyTableNo: Integer)
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        NoOfValues: Integer;
    begin
        if not (MyTableNo in [DATABASE::"My Customer",DATABASE::"My Vendor",DATABASE::"My Item"]) then
          exit;

        TextFilterText := '';
        NoOfValues := 0;
        RecRef.Open(MyTableNo);
        FieldRef := RecRef.Field(1);
        FieldRef.SetRange(UserId);
        if RecRef.Find('-') then
          repeat
            FieldRef := RecRef.Field(2);
            AddToFilter(TextFilterText,Format(FieldRef.Value));
            NoOfValues += 1;
          until (RecRef.Next = 0) or (NoOfValues > 2000);
        RecRef.Close;

        if NoOfValues > 2000 then
          Message(OverflowMsg);
    end;

    local procedure AddToFilter(var FilterString: Text;MyNo: Code[20])
    begin
        if FilterString = '' then
          FilterString := MyNo
        else
          FilterString += '|' + MyNo;
    end;

    [Scope('Personalization')]
    procedure RemoveMessageTrailingDots(Message: Text): Text
    begin
        exit(DelChr(Message,'>','.'));
    end;

    [Scope('Personalization')]
    procedure GetRecordErrorMessage(ErrorMessageField1: Text[250];ErrorMessageField2: Text[250];ErrorMessageField3: Text[250];ErrorMessageField4: Text[250]): Text
    begin
        exit(ErrorMessageField1 + ErrorMessageField2 + ErrorMessageField3 + ErrorMessageField4);
    end;

    [Scope('Personalization')]
    procedure SetRecordErrorMessage(var ErrorMessageField1: Text[250];var ErrorMessageField2: Text[250];var ErrorMessageField3: Text[250];var ErrorMessageField4: Text[250];ErrorText: Text)
    begin
        ErrorMessageField2 := '';
        ErrorMessageField3 := '';
        ErrorMessageField4 := '';
        ErrorMessageField1 := CopyStr(ErrorText,1,250);
        if StrLen(ErrorText) > 250 then
          ErrorMessageField2 := CopyStr(ErrorText,251,250);
        if StrLen(ErrorText) > 500 then
          ErrorMessageField3 := CopyStr(ErrorText,501,250);
        if StrLen(ErrorText) > 750 then
          ErrorMessageField4 := CopyStr(ErrorText,751,250);
    end;

    procedure XMLTextIndent(InputXMLText: Text): Text
    var
        TempBlob: Record TempBlob;
        XMLDOMMgt: Codeunit "XML DOM Management";
        XMLDocument: DotNet XmlDocument;
        OutStream: OutStream;
    begin
        // Format input XML text: append indentations
        if XMLDOMMgt.LoadXMLDocumentFromText(InputXMLText,XMLDocument) then begin
          TempBlob.Init;
          TempBlob.Blob.CreateOutStream(OutStream,TEXTENCODING::UTF8);
          XMLDocument.Save(OutStream);
          exit(TempBlob.ReadAsTextWithCRLFLineSeparator);
        end;
        ClearLastError;
        exit(InputXMLText);
    end;

    [Scope('Personalization')]
    procedure Replace(InputText: Text;ToReplace: Text;ReplacementText: Text): Text
    var
        DotNetString: DotNet String;
    begin
        if ToReplace = '' then
          exit(InputText);

        DotNetString := InputText;
        exit(DotNetString.Replace(ToReplace,ReplacementText));
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure ReplaceRegex(InputText: Text;ReplacePattern: Text;ReplacementText: Text;var Result: Text)
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        Result := TypeHelper.RegexReplace(InputText,ReplacePattern,ReplacementText);
    end;

    [EventSubscriber(ObjectType::Codeunit, 2000000007, 'MakeDateTimeFilter', '', false, false)]
    local procedure DoMakeDateTimeFilter(var DateTimeFilterText: Text)
    begin
        MakeDateTimeFilter(DateTimeFilterText);
    end;

    [EventSubscriber(ObjectType::Codeunit, 2000000007, 'MakeDateFilter', '', false, false)]
    local procedure DoMakeDateFilter(var DateFilterText: Text)
    begin
        MakeDateFilter(DateFilterText);
    end;

    [EventSubscriber(ObjectType::Codeunit, 2000000007, 'MakeTextFilter', '', false, false)]
    local procedure DoMakeTextFilter(var TextFilterText: Text)
    begin
        MakeTextFilter(TextFilterText);
    end;

    [EventSubscriber(ObjectType::Codeunit, 2000000007, 'MakeCodeFilter', '', false, false)]
    local procedure DoMakeCodeFilter(var TextFilterText: Text)
    begin
        MakeTextFilter(TextFilterText);
    end;

    [EventSubscriber(ObjectType::Codeunit, 2000000007, 'MakeTimeFilter', '', false, false)]
    local procedure DoMakeTimeFilter(var TimeFilterText: Text)
    begin
        MakeTimeFilter(TimeFilterText);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeMakeTextFilter(var TextFilterText: Text;var Position: Integer;var HandledByEvent: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterMakeDateTimeFilter(var DateTimeFilterText: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterMakeDateFilter(var DateFilterText: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterMakeTextFilter(var TextFilterText: Text;var Position: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterMakeTimeFilter(var TimeFilterText: Text)
    begin
    end;
}

