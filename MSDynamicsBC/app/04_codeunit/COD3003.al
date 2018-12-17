codeunit 3003 DotNet_DateTime
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        DotNetDateTime: DotNet DateTime;

    [Scope('Personalization')]
    procedure TryParse(DateTimeText: Text;DotNet_CultureInfo: Codeunit DotNet_CultureInfo;DotNet_DateTimeStyles: Codeunit DotNet_DateTimeStyles): Boolean
    var
        DotNetCultureInfo: DotNet CultureInfo;
        DotNetDateTimeStyles: DotNet DateTimeStyles;
    begin
        DateTimeFromInt(0);
        DotNet_CultureInfo.GetCultureInfo(DotNetCultureInfo);
        DotNet_DateTimeStyles.GetDateTimeStyles(DotNetDateTimeStyles);
        exit(DotNetDateTime.TryParse(DateTimeText,DotNetCultureInfo,DotNetDateTimeStyles,DotNetDateTime))
    end;

    [Scope('Personalization')]
    procedure TryParseExact(DateTimeText: Text;Format: Text;DotNet_CultureInfo: Codeunit DotNet_CultureInfo;DotNet_DateTimeStyles: Codeunit DotNet_DateTimeStyles): Boolean
    var
        DotNetCultureInfo: DotNet CultureInfo;
        DotNetDateTimeStyles: DotNet DateTimeStyles;
    begin
        DateTimeFromInt(0);
        DotNet_CultureInfo.GetCultureInfo(DotNetCultureInfo);
        DotNet_DateTimeStyles.GetDateTimeStyles(DotNetDateTimeStyles);
        exit(DotNetDateTime.TryParseExact(DateTimeText,Format,DotNetCultureInfo,DotNetDateTimeStyles,DotNetDateTime))
    end;

    [Scope('Personalization')]
    procedure DateTimeFromInt(IntegerDateTime: Integer)
    begin
        DotNetDateTime := DotNetDateTime.DateTime(IntegerDateTime)
    end;

    [Scope('Personalization')]
    procedure DateTimeFromYMD(Year: Integer;Month: Integer;Day: Integer)
    begin
        DotNetDateTime := DotNetDateTime.DateTime(Year,Month,Day)
    end;

    [Scope('Personalization')]
    procedure Day(): Integer
    begin
        exit(DotNetDateTime.Day)
    end;

    [Scope('Personalization')]
    procedure Month(): Integer
    begin
        exit(DotNetDateTime.Month)
    end;

    [Scope('Personalization')]
    procedure Year(): Integer
    begin
        exit(DotNetDateTime.Year)
    end;

    [Scope('Personalization')]
    procedure Hour(): Integer
    begin
        exit(DotNetDateTime.Hour)
    end;

    [Scope('Personalization')]
    procedure Minute(): Integer
    begin
        exit(DotNetDateTime.Minute)
    end;

    [Scope('Personalization')]
    procedure Second(): Integer
    begin
        exit(DotNetDateTime.Second)
    end;

    [Scope('Personalization')]
    procedure Millisecond(): Integer
    begin
        exit(DotNetDateTime.Millisecond)
    end;

    [Scope('Personalization')]
    procedure ToString(DotNet_DateTimeFormatInfo: Codeunit DotNet_DateTimeFormatInfo): Text
    var
        DotNetDateTimeFormatInfo: DotNet DateTimeFormatInfo;
    begin
        DotNet_DateTimeFormatInfo.GetDateTimeFormatInfo(DotNetDateTimeFormatInfo);
        exit(DotNetDateTime.ToString('d',DotNetDateTimeFormatInfo))
    end;

    procedure GetDateTime(var DotNetDateTime2: DotNet DateTime)
    begin
        DotNetDateTime2 := DotNetDateTime
    end;

    procedure SetDateTime(DotNetDateTime2: DotNet DateTime)
    begin
        DotNetDateTime := DotNetDateTime2
    end;
}

