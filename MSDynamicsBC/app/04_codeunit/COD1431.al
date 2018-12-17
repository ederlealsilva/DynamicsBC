codeunit 1431 "Forward Link Mgt."
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    var
        LanguageUrlParameterTxt: Label '&clcid=0x%1', Locked=true;

    [Scope('Personalization')]
    procedure GetLanguageSpecificUrl(NonLanguageSpecificURL: Text): Text
    var
        LanguageSpecificURL: Text;
    begin
        LanguageSpecificURL := NonLanguageSpecificURL + GetLanguageUrlParameter;
        exit(LanguageSpecificURL);
    end;

    local procedure GetLanguageUrlParameter(): Text
    var
        Convert: DotNet Convert;
        LanguageHexaDecimalCode: Text;
        LanguageUrlParameter: Text;
    begin
        LanguageHexaDecimalCode := Convert.ToString(GlobalLanguage,16);
        LanguageUrlParameter := StrSubstNo(LanguageUrlParameterTxt,LanguageHexaDecimalCode);
        exit(LanguageUrlParameter);
    end;
}

