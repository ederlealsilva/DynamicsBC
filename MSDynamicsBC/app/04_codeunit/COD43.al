codeunit 43 LanguageManagement
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        SavedGlobalLanguageID: Integer;

    procedure SetGlobalLanguage()
    var
        TempLanguage: Record "Windows Language" temporary;
    begin
        GetApplicationLanguages(TempLanguage);

        with TempLanguage do begin
          SetCurrentKey(Name);
          if Get(GlobalLanguage) then;
          PAGE.Run(PAGE::"Application Languages",TempLanguage);
        end;
    end;

    [TryFunction]
    procedure TrySetGlobalLanguage(LanguageID: Integer)
    begin
        GlobalLanguage(LanguageID);
    end;

    procedure GetApplicationLanguages(var TempLanguage: Record "Windows Language" temporary)
    var
        Language: Record "Windows Language";
    begin
        with Language do begin
          GetLanguageFilters(Language);
          if FindSet then
            repeat
              TempLanguage := Language;
              TempLanguage.Insert;
            until Next = 0;
        end;
    end;

    [Scope('Personalization')]
    procedure ApplicationLanguage(): Integer
    begin
        exit(1033);
    end;

    procedure ValidateApplicationLanguage(LanguageID: Integer)
    var
        TempLanguage: Record "Windows Language" temporary;
    begin
        GetApplicationLanguages(TempLanguage);

        with TempLanguage do begin
          SetRange("Language ID",LanguageID);
          FindFirst;
        end;
    end;

    procedure LookupApplicationLanguage(var LanguageID: Integer)
    var
        TempLanguage: Record "Windows Language" temporary;
    begin
        GetApplicationLanguages(TempLanguage);

        with TempLanguage do begin
          if Get(LanguageID) then;
          if PAGE.RunModal(PAGE::"Windows Languages",TempLanguage) = ACTION::LookupOK then
            LanguageID := "Language ID";
        end;
    end;

    [Scope('Personalization')]
    procedure LookupWindowsLocale(var LocaleID: Integer)
    var
        WindowsLanguage: Record "Windows Language";
    begin
        with WindowsLanguage do begin
          SetCurrentKey(Name);
          if PAGE.RunModal(PAGE::"Windows Languages",WindowsLanguage) = ACTION::LookupOK then
            LocaleID := "Language ID";
        end;
    end;

    [Scope('Personalization')]
    procedure SetGlobalLanguageByCode(LanguageCode: Code[10])
    var
        Language: Record Language;
    begin
        if LanguageCode = '' then
          exit;
        SavedGlobalLanguageID := GlobalLanguage;
        GlobalLanguage(Language.GetLanguageID(LanguageCode));
    end;

    [Scope('Personalization')]
    procedure RestoreGlobalLanguage()
    begin
        if SavedGlobalLanguageID <> 0 then begin
          GlobalLanguage(SavedGlobalLanguageID);
          SavedGlobalLanguageID := 0;
        end;
    end;

    local procedure GetLanguageFilters(var WindowsLanguage: Record "Windows Language")
    begin
        WindowsLanguage.SetRange("Localization Exist",true);
        WindowsLanguage.SetRange("Globally Enabled",true);
    end;

    [Scope('Personalization')]
    procedure GetWindowsLanguageNameFromLanguageCode(LanguageCode: Code[10]): Text
    var
        Language: Record Language;
    begin
        if LanguageCode = '' then
          exit('');

        Language.SetAutoCalcFields("Windows Language Name");
        if Language.Get(LanguageCode) then
          exit(Language."Windows Language Name");

        exit('');
    end;

    [Scope('Personalization')]
    procedure GetWindowsLanguageIDFromLanguageName(LanguageName: Text): Integer
    var
        WindowsLanguage: Record "Windows Language";
    begin
        if LanguageName = '' then
          exit(0);
        WindowsLanguage.SetRange("Localization Exist",true);
        WindowsLanguage.SetFilter(Name,'@*' + CopyStr(LanguageName,1,MaxStrLen(WindowsLanguage.Name)) + '*');
        if not WindowsLanguage.FindFirst then
          exit(0);

        exit(WindowsLanguage."Language ID");
    end;

    [Scope('Personalization')]
    procedure GetLanguageCodeFromLanguageID(LanguageID: Integer): Code[10]
    var
        Language: Record Language;
    begin
        if LanguageID = 0 then
          exit('');
        Language.SetRange("Windows Language ID",LanguageID);
        if Language.FindFirst then
          exit(Language.Code);
        exit('');
    end;

    [Scope('Personalization')]
    procedure GetWindowsLanguageNameFromLanguageID(LanguageID: Integer): Text
    var
        Language: Record Language;
    begin
        if LanguageID = 0 then
          exit('');

        Language.SetRange("Windows Language ID",LanguageID);
        if Language.FindFirst then begin
          Language.CalcFields("Windows Language Name");
          exit(Language.Name);
        end;

        exit('');
    end;

    [EventSubscriber(ObjectType::Codeunit, 2000000004, 'GetApplicationLanguage', '', false, false)]
    local procedure GetApplicationLanguage(var language: Integer)
    begin
        language := ApplicationLanguage;
    end;
}

