codeunit 3002 DotNet_CultureInfo
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        DotNetCultureInfo: DotNet CultureInfo;

    [Scope('Personalization')]
    procedure GetCultureInfoByName(CultureName: Text)
    begin
        DotNetCultureInfo := DotNetCultureInfo.GetCultureInfo(CultureName)
    end;

    [Scope('Personalization')]
    procedure GetCultureInfoById(LanguageId: Integer)
    begin
        DotNetCultureInfo := DotNetCultureInfo.GetCultureInfo(LanguageId)
    end;

    [Scope('Personalization')]
    procedure InvariantCulture()
    begin
        DotNetCultureInfo := DotNetCultureInfo.InvariantCulture
    end;

    [Scope('Personalization')]
    procedure Name(): Text
    begin
        exit(DotNetCultureInfo.Name)
    end;

    [Scope('Personalization')]
    procedure CurrentCultureName(): Text
    begin
        Clear(DotNetCultureInfo);
        exit(DotNetCultureInfo.CurrentCulture.Name)
    end;

    [Scope('Personalization')]
    procedure ToString(): Text
    begin
        exit(DotNetCultureInfo.ToString)
    end;

    [Scope('Personalization')]
    procedure TwoLetterISOLanguageName(): Text
    begin
        exit(DotNetCultureInfo.TwoLetterISOLanguageName)
    end;

    [Scope('Personalization')]
    procedure ThreeLetterWindowsLanguageName(): Text
    begin
        exit(DotNetCultureInfo.ThreeLetterWindowsLanguageName)
    end;

    [Scope('Personalization')]
    procedure DateTimeFormat(var DotNet_DateTimeFormatInfo: Codeunit DotNet_DateTimeFormatInfo)
    begin
        DotNet_DateTimeFormatInfo.SetDateTimeFormatInfo(DotNetCultureInfo.DateTimeFormat)
    end;

    procedure GetCultureInfo(var DotNetCultureInfo2: DotNet CultureInfo)
    begin
        DotNetCultureInfo2 := DotNetCultureInfo
    end;

    procedure SetCultureInfo(DotNetCultureInfo2: DotNet CultureInfo)
    begin
        DotNetCultureInfo := DotNetCultureInfo2
    end;
}

