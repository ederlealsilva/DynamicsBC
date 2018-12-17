codeunit 45 AutoFormatManagement
{
    // version NAVW113.00

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        Currency: Record Currency;
        GLSetup: Record "General Ledger Setup";
        GLSetupRead: Boolean;
        Text012: Label '<Precision,%1><Standard Format,0>';
        CurrFormatTxt: Label '<Custom,%3%2<Precision,%1><Standard Format,0>>', Comment='{LOCKED} Do not translate';

    [Scope('Personalization')]
    procedure AutoFormatTranslate(AutoFormatType: Integer;AutoFormatExpr: Text[80]): Text[80]
    var
        FormatSubtype: Text;
        AutoFormatPrefixedText: Text;
        AutoFormatCurrencyCode: Text;
        NumCommasInAutoFomatExpr: Integer;
    begin
        if AutoFormatType = 0 then
          exit('');

        if not GetGLSetup then
          exit('');

        case AutoFormatType of
          1: // Amount
            begin
              if AutoFormatExpr = '' then
                exit(StrSubstNo(Text012,GLSetup."Amount Decimal Places"));
              if GetCurrency(CopyStr(AutoFormatExpr,1,10)) and
                 (Currency."Amount Decimal Places" <> '')
              then
                exit(StrSubstNo(Text012,Currency."Amount Decimal Places"));
              exit(StrSubstNo(Text012,GLSetup."Amount Decimal Places"));
            end;
          2: // Unit Amount
            begin
              if AutoFormatExpr = '' then
                exit(StrSubstNo(Text012,GLSetup."Unit-Amount Decimal Places"));
              if GetCurrency(CopyStr(AutoFormatExpr,1,10)) and
                 (Currency."Unit-Amount Decimal Places" <> '')
              then
                exit(StrSubstNo(Text012,Currency."Unit-Amount Decimal Places"));
              exit(StrSubstNo(Text012,GLSetup."Unit-Amount Decimal Places"));
            end;
          10: // Custom or AutoFormatExpr = '1[,<curr>[,<PrefixedText>]]' or '2[,<curr>[,<PrefixedText>]]'
            begin
              FormatSubtype := SelectStr(1,AutoFormatExpr);
              if FormatSubtype in ['1','2'] then begin
                NumCommasInAutoFomatExpr := StrLen(AutoFormatExpr) - StrLen(DelChr(AutoFormatExpr,'=',','));
                if NumCommasInAutoFomatExpr >= 1 then
                  AutoFormatCurrencyCode := SelectStr(2,AutoFormatExpr);
                if NumCommasInAutoFomatExpr >= 2 then
                  AutoFormatPrefixedText := SelectStr(3,AutoFormatExpr);
                if AutoFormatPrefixedText <> '' then
                  AutoFormatPrefixedText := AutoFormatPrefixedText + ' ';
              end else
                FormatSubtype := '';

              case FormatSubtype of
                '1':
                  begin
                    if AutoFormatCurrencyCode = '' then
                      exit(StrSubstNo(CurrFormatTxt,GLSetup."Amount Decimal Places",GLSetup.GetCurrencySymbol,AutoFormatPrefixedText));
                    if GetCurrency(CopyStr(AutoFormatCurrencyCode,1,10)) and
                       (Currency."Amount Decimal Places" <> '')
                    then
                      exit(StrSubstNo(CurrFormatTxt,Currency."Amount Decimal Places",Currency.GetCurrencySymbol,AutoFormatPrefixedText));
                    exit(StrSubstNo(CurrFormatTxt,GLSetup."Amount Decimal Places",GLSetup.GetCurrencySymbol,AutoFormatPrefixedText));
                  end;
                '2':
                  begin
                    if AutoFormatCurrencyCode = '' then
                      exit(
                        StrSubstNo(CurrFormatTxt,GLSetup."Unit-Amount Decimal Places",GLSetup.GetCurrencySymbol,AutoFormatPrefixedText));
                    if GetCurrency(CopyStr(AutoFormatCurrencyCode,1,10)) and
                       (Currency."Unit-Amount Decimal Places" <> '')
                    then
                      exit(
                        StrSubstNo(CurrFormatTxt,Currency."Unit-Amount Decimal Places",Currency.GetCurrencySymbol,AutoFormatPrefixedText));
                    exit(
                      StrSubstNo(CurrFormatTxt,GLSetup."Unit-Amount Decimal Places",GLSetup.GetCurrencySymbol,AutoFormatPrefixedText));
                  end;
                else
                  exit('<Custom,' + AutoFormatExpr + '>');
              end;
            end;
          11:
            exit(AutoFormatExpr);
        end;
    end;

    [Scope('Personalization')]
    procedure ReadRounding(): Decimal
    begin
        GetGLSetup;
        exit(GLSetup."Amount Rounding Precision");
    end;

    local procedure GetGLSetup(): Boolean
    begin
        if not GLSetupRead then
          GLSetupRead := GLSetup.Get;
        exit(GLSetupRead);
    end;

    local procedure GetCurrency(CurrencyCode: Code[10]): Boolean
    begin
        if CurrencyCode = Currency.Code then
          exit(true);
        if CurrencyCode = '' then begin
          Clear(Currency);
          Currency.InitRoundingPrecision;
          exit(true);
        end;
        exit(Currency.Get(CurrencyCode));
    end;

    [EventSubscriber(ObjectType::Codeunit, 2000000004, 'AutoFormatTranslate', '', false, false)]
    local procedure DoAutoFormatTranslate(AutoFormatType: Integer;AutoFormatExpr: Text[80];var Translation: Text[80])
    begin
        Translation := AutoFormatTranslate(AutoFormatType,AutoFormatExpr);
        OnAfterAutoFormatTranslate(AutoFormatType,AutoFormatExpr,Translation);
    end;

    [EventSubscriber(ObjectType::Codeunit, 2000000004, 'GetDefaultRoundingPrecision', '', false, false)]
    local procedure GetDefaultRoundingPrecision(var AmountRoundingPrecision: Decimal)
    begin
        AmountRoundingPrecision := ReadRounding;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAutoFormatTranslate(AutoFormatType: Integer;AutoFormatExpression: Text[80];var AutoFormatTranslation: Text[80])
    begin
    end;
}

