codeunit 42 CaptionManagement
{
    // version NAVW113.00

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        GLSetup: Record "General Ledger Setup";
        GLSetupRead: Boolean;
        Text016: Label 'Excl. VAT';
        Text017: Label 'Incl. VAT';
        DefaultTxt: Label 'LCY';
        DefaultLongTxt: Label 'Local Currency';
        CountyTxt: Label 'County';

    [Scope('Personalization')]
    procedure CaptionClassTranslate(Language: Integer;CaptionExpr: Text[1024]): Text[1024]
    var
        CaptionArea: Text[80];
        CaptionRef: Text[1024];
        CommaPosition: Integer;
    begin
        // LANGUAGE
        // <DataType>   := [Integer]
        // <DataValue>  := Automatically mentioned by the system

        // CAPTIONEXPR
        // <DataType>   := [String]
        // <Length>     <= 80
        // <DataValue>  := <CAPTIONAREA>,<CAPTIONREF>

        // CAPTIONAREA
        // <DataType>   := [SubString]
        // <Length>     <= 10
        // <DataValue>  := 1..9999999999
        // 1 for Dimension Area
        // 2 for VAT

        // CAPTIONREF
        // <DataType>   := [SubString]
        // <Length>     <= 10
        // <DataValue>  :=
        // IF (<CAPTIONAREA> = 1) <DIMCAPTIONTYPE>,<DIMCAPTIONREF>
        // IF (<CAPTIONAREA> = 2) <VATCAPTIONTYPE>

        CommaPosition := StrPos(CaptionExpr,',');
        if (CommaPosition > 0) and (CommaPosition < 80) then begin
          CaptionArea := CopyStr(CaptionExpr,1,CommaPosition - 1);
          CaptionRef := CopyStr(CaptionExpr,CommaPosition + 1);
          case CaptionArea of
            '1':
              exit(DimCaptionClassTranslate(Language,CopyStr(CaptionRef,1,80)));
            '2':
              exit(VATCaptionClassTranslate(CopyStr(CaptionRef,1,80)));
            '3':
              exit(CaptionRef);
            '5':
              exit(CountyClassTranslate(CopyStr(CaptionRef,1,80)));
            '101':
              exit(CurCaptionClassTranslate(CaptionRef));
          end;
        end;
        exit(CaptionExpr);
    end;

    local procedure DimCaptionClassTranslate(Language: Integer;CaptionExpr: Text[80]): Text[80]
    var
        Dim: Record Dimension;
        DimCaptionType: Text[80];
        DimCaptionRef: Text[80];
        DimOptionalParam1: Text[80];
        DimOptionalParam2: Text[80];
        CommaPosition: Integer;
    begin
        // DIMCAPTIONTYPE
        // <DataType>   := [SubString]
        // <Length>     <= 10
        // <DataValue>  := 1..6
        // 1 to retrieve Code Caption of Global Dimension
        // 2 to retrieve Code Caption of Shortcut Dimension
        // 3 to retrieve Filter Caption of Global Dimension
        // 4 to retrieve Filter Caption of Shortcut Dimension
        // 5 to retrieve Code Caption of any kind of Dimensions
        // 6 to retrieve Filter Caption of any kind of Dimensions

        // DIMCAPTIONREF
        // <DataType>   := [SubString]
        // <Length>     <= 10
        // <DataValue>  :=
        // IF (<DIMCAPTIONTYPE> = 1) 1..2,<DIMOPTIONALPARAM1>,<DIMOPTIONALPARAM2>
        // IF (<DIMCAPTIONTYPE> = 2) 1..8,<DIMOPTIONALPARAM1>,<DIMOPTIONALPARAM2>
        // IF (<DIMCAPTIONTYPE> = 3) 1..2,<DIMOPTIONALPARAM1>,<DIMOPTIONALPARAM2>
        // IF (<DIMCAPTIONTYPE> = 4) 1..8,<DIMOPTIONALPARAM1>,<DIMOPTIONALPARAM2>
        // IF (<DIMCAPTIONTYPE> = 5) [Table]Dimension.[Field]Code,<DIMOPTIONALPARAM1>,<DIMOPTIONALPARAM2>
        // IF (<DIMCAPTIONTYPE> = 6) [Table]Dimension.[Field]Code,<DIMOPTIONALPARAM1>,<DIMOPTIONALPARAM2>

        // DIMOPTIONALPARAM1
        // <DataType>   := [SubString]
        // <Length>     <= 30
        // <DataValue>  := [String]
        // a string added before the dimension name

        // DIMOPTIONALPARAM2
        // <DataType>   := [SubString]
        // <Length>     <= 30
        // <DataValue>  := [String]
        // a string added after the dimension name

        if not GetGLSetup then
          exit('');

        CommaPosition := StrPos(CaptionExpr,',');
        if CommaPosition > 0 then begin
          DimCaptionType := CopyStr(CaptionExpr,1,CommaPosition - 1);
          DimCaptionRef := CopyStr(CaptionExpr,CommaPosition + 1);
          CommaPosition := StrPos(DimCaptionRef,',');
          if CommaPosition > 0 then begin
            DimOptionalParam1 := CopyStr(DimCaptionRef,CommaPosition + 1);
            DimCaptionRef := CopyStr(DimCaptionRef,1,CommaPosition - 1);
            CommaPosition := StrPos(DimOptionalParam1,',');
            if CommaPosition > 0 then begin
              DimOptionalParam2 := CopyStr(DimOptionalParam1,CommaPosition + 1);
              DimOptionalParam1 := CopyStr(DimOptionalParam1,1,CommaPosition - 1);
            end else
              DimOptionalParam2 := '';
          end else begin
            DimOptionalParam1 := '';
            DimOptionalParam2 := '';
          end;
          case DimCaptionType of
            '1':  // Code Caption - Global Dimension using No. as Reference
              case DimCaptionRef of
                '1':
                  exit(
                    DimCodeCaption(
                      Language,DimOptionalParam1,DimOptionalParam2,
                      GLSetup."Global Dimension 1 Code",
                      GLSetup.FieldCaption("Global Dimension 1 Code")));
                '2':
                  exit(
                    DimCodeCaption(
                      Language,DimOptionalParam1,DimOptionalParam2,
                      GLSetup."Global Dimension 2 Code",
                      GLSetup.FieldCaption("Global Dimension 2 Code")));
              end;
            '2':  // Code Caption - Shortcut Dimension using No. as Reference
              case DimCaptionRef of
                '1':
                  exit(
                    DimCodeCaption(
                      Language,DimOptionalParam1,DimOptionalParam2,
                      GLSetup."Shortcut Dimension 1 Code",
                      GLSetup.FieldCaption("Shortcut Dimension 1 Code")));
                '2':
                  exit(
                    DimCodeCaption(
                      Language,DimOptionalParam1,DimOptionalParam2,
                      GLSetup."Shortcut Dimension 2 Code",
                      GLSetup.FieldCaption("Shortcut Dimension 2 Code")));
                '3':
                  exit(
                    DimCodeCaption(
                      Language,DimOptionalParam1,DimOptionalParam2,
                      GLSetup."Shortcut Dimension 3 Code",
                      GLSetup.FieldCaption("Shortcut Dimension 3 Code")));
                '4':
                  exit(
                    DimCodeCaption(
                      Language,DimOptionalParam1,DimOptionalParam2,
                      GLSetup."Shortcut Dimension 4 Code",
                      GLSetup.FieldCaption("Shortcut Dimension 4 Code")));
                '5':
                  exit(
                    DimCodeCaption(
                      Language,DimOptionalParam1,DimOptionalParam2,
                      GLSetup."Shortcut Dimension 5 Code",
                      GLSetup.FieldCaption("Shortcut Dimension 5 Code")));
                '6':
                  exit(
                    DimCodeCaption(
                      Language,DimOptionalParam1,DimOptionalParam2,
                      GLSetup."Shortcut Dimension 6 Code",
                      GLSetup.FieldCaption("Shortcut Dimension 6 Code")));
                '7':
                  exit(
                    DimCodeCaption(
                      Language,DimOptionalParam1,DimOptionalParam2,
                      GLSetup."Shortcut Dimension 7 Code",
                      GLSetup.FieldCaption("Shortcut Dimension 7 Code")));
                '8':
                  exit(
                    DimCodeCaption(
                      Language,DimOptionalParam1,DimOptionalParam2,
                      GLSetup."Shortcut Dimension 8 Code",
                      GLSetup.FieldCaption("Shortcut Dimension 8 Code")));
              end;
            '3':  // Filter Caption - Global Dimension using No. as Reference
              case DimCaptionRef of
                '1':
                  exit(
                    DimFilterCaption(
                      Language,DimOptionalParam1,DimOptionalParam2,
                      GLSetup."Global Dimension 1 Code",
                      GLSetup.FieldCaption("Global Dimension 1 Code")));
                '2':
                  exit(
                    DimFilterCaption(
                      Language,DimOptionalParam1,DimOptionalParam2,
                      GLSetup."Global Dimension 2 Code",
                      GLSetup.FieldCaption("Global Dimension 2 Code")));
              end;
            '4':  // Filter Caption - Shortcut Dimension using No. as Reference
              case DimCaptionRef of
                '1':
                  exit(
                    DimFilterCaption(
                      Language,DimOptionalParam1,DimOptionalParam2,
                      GLSetup."Shortcut Dimension 1 Code",
                      GLSetup.FieldCaption("Shortcut Dimension 1 Code")));
                '2':
                  exit(
                    DimFilterCaption(
                      Language,DimOptionalParam1,DimOptionalParam2,
                      GLSetup."Shortcut Dimension 2 Code",
                      GLSetup.FieldCaption("Shortcut Dimension 2 Code")));
                '3':
                  exit(
                    DimFilterCaption(
                      Language,DimOptionalParam1,DimOptionalParam2,
                      GLSetup."Shortcut Dimension 3 Code",
                      GLSetup.FieldCaption("Shortcut Dimension 3 Code")));
                '4':
                  exit(
                    DimFilterCaption(
                      Language,DimOptionalParam1,DimOptionalParam2,
                      GLSetup."Shortcut Dimension 4 Code",
                      GLSetup.FieldCaption("Shortcut Dimension 4 Code")));
                '5':
                  exit(
                    DimFilterCaption(
                      Language,DimOptionalParam1,DimOptionalParam2,
                      GLSetup."Shortcut Dimension 5 Code",
                      GLSetup.FieldCaption("Shortcut Dimension 5 Code")));
                '6':
                  exit(
                    DimFilterCaption(
                      Language,DimOptionalParam1,DimOptionalParam2,
                      GLSetup."Shortcut Dimension 6 Code",
                      GLSetup.FieldCaption("Shortcut Dimension 6 Code")));
                '7':
                  exit(
                    DimFilterCaption(
                      Language,DimOptionalParam1,DimOptionalParam2,
                      GLSetup."Shortcut Dimension 7 Code",
                      GLSetup.FieldCaption("Shortcut Dimension 7 Code")));
                '8':
                  exit(
                    DimFilterCaption(
                      Language,DimOptionalParam1,DimOptionalParam2,
                      GLSetup."Shortcut Dimension 8 Code",
                      GLSetup.FieldCaption("Shortcut Dimension 8 Code")));
              end;
            '5':  // Code Caption - using Dimension Code as Reference
              begin
                if Dim.Get(DimCaptionRef) then
                  exit(DimOptionalParam1 + Dim.GetMLCodeCaption(Language) + DimOptionalParam2);
                exit(DimOptionalParam1);
              end;
            '6':  // Filter Caption - using Dimension Code as Reference
              begin
                if Dim.Get(DimCaptionRef) then
                  exit(DimOptionalParam1 + Dim.GetMLFilterCaption(Language) + DimOptionalParam2);
                exit(DimOptionalParam1);
              end;
          end;
        end;
        exit('');
    end;

    local procedure DimCodeCaption(Language: Integer;DimOptionalParam1: Text[80];DimOptionalParam2: Text[80];DimCode: Code[20];DimFieldCaption: Text[1024]): Text[80]
    var
        Dim: Record Dimension;
    begin
        if Dim.Get(DimCode) then
          exit(DimOptionalParam1 + Dim.GetMLCodeCaption(Language) + DimOptionalParam2);
        exit(
          DimOptionalParam1 +
          DimFieldCaption +
          DimOptionalParam2);
    end;

    local procedure DimFilterCaption(Language: Integer;DimOptionalParam1: Text[80];DimOptionalParam2: Text[80];DimCode: Code[20];DimFieldCaption: Text[1024]): Text[80]
    var
        Dim: Record Dimension;
    begin
        if Dim.Get(DimCode) then
          exit(DimOptionalParam1 + Dim.GetMLFilterCaption(Language) + DimOptionalParam2);
        exit(
          DimOptionalParam1 +
          DimFieldCaption +
          DimOptionalParam2);
    end;

    local procedure VATCaptionClassTranslate(CaptionExpr: Text[80]): Text[80]
    var
        VATCaptionType: Text[80];
        VATCaptionRef: Text[80];
        CommaPosition: Integer;
    begin
        // VATCAPTIONTYPE
        // <DataType>   := [SubString]
        // <Length>     =  1
        // <DataValue>  :=
        // '0' -> <field caption + 'Excl. VAT'>
        // '1' -> <field caption + 'Incl. VAT'>

        CommaPosition := StrPos(CaptionExpr,',');
        if CommaPosition > 0 then begin
          VATCaptionType := CopyStr(CaptionExpr,1,CommaPosition - 1);
          VATCaptionRef := CopyStr(CaptionExpr,CommaPosition + 1);
          case VATCaptionType of
            '0':
              exit(CopyStr(StrSubstNo('%1 %2',VATCaptionRef,Text016),1,80));
            '1':
              exit(CopyStr(StrSubstNo('%1 %2',VATCaptionRef,Text017),1,80));
          end;
        end;
        exit('');
    end;

    local procedure CurCaptionClassTranslate(CaptionExpr: Text): Text
    var
        Currency: Record Currency;
        GLSetupRead: Boolean;
        CurrencyResult: Text[30];
        CommaPosition: Integer;
        CurCaptionType: Text[30];
        CurCaptionRef: Text;
    begin
        // CURCAPTIONTYPE
        // <DataType>   := [SubString]
        // <Length>     =  1
        // <DataValue>  :=
        // '0' -> Currency Result := Local Currency Code
        // '1' -> Currency Result := Local Currency Description
        // '2' -> Currency Result := Additional Reporting Currency Code
        // '3' -> Currency Result := Additional Reporting Currency Description

        // CURCAPTIONREF
        // <DataType>   := [SubString]
        // <Length>     <= 70
        // <DataValue>  := [String]
        // This string is the actual string making up the Caption.
        // It will contain a '%1', and the Currency Result will substitute for it.

        CommaPosition := StrPos(CaptionExpr,',');
        if CommaPosition > 0 then begin
          CurCaptionType := CopyStr(CaptionExpr,1,CommaPosition - 1);
          CurCaptionRef := CopyStr(CaptionExpr,CommaPosition + 1);
          if not GLSetupRead then begin
            if not GLSetup.Get then
              exit(CurCaptionRef);
            GLSetupRead := true;
          end;
          case CurCaptionType of
            '0','1':
              begin
                if GLSetup."LCY Code" = '' then
                  if CurCaptionType = '0' then
                    CurrencyResult := DefaultTxt
                  else
                    CurrencyResult := DefaultLongTxt
                else
                  if not Currency.Get(GLSetup."LCY Code") then
                    CurrencyResult := GLSetup."LCY Code"
                  else
                    if CurCaptionType = '0' then
                      CurrencyResult := Currency.Code
                    else
                      CurrencyResult := Currency.Description;
                exit(CopyStr(StrSubstNo(CurCaptionRef,CurrencyResult),1,MaxStrLen(CurCaptionRef)));
              end;
            '2','3':
              begin
                if GLSetup."Additional Reporting Currency" = '' then
                  exit(CurCaptionRef);
                if not Currency.Get(GLSetup."Additional Reporting Currency") then
                  CurrencyResult := GLSetup."Additional Reporting Currency"
                else
                  if CurCaptionType = '2' then
                    CurrencyResult := Currency.Code
                  else
                    CurrencyResult := Currency.Description;
                exit(CopyStr(StrSubstNo(CurCaptionRef,CurrencyResult),1,MaxStrLen(CurCaptionRef)));
              end;
            else
              exit(CurCaptionRef);
          end;
        end;
        exit(CaptionExpr);
    end;

    local procedure CountyClassTranslate(CaptionExpr: Text[80]): Text
    var
        CountryRegion: Record "Country/Region";
        CommaPosition: Integer;
        CountyCaptionType: Text[30];
        CountyCaptionRef: Text;
    begin
        CommaPosition := StrPos(CaptionExpr,',');
        if CommaPosition > 0 then begin
          CountyCaptionType := CopyStr(CaptionExpr,1,CommaPosition - 1);
          CountyCaptionRef := CopyStr(CaptionExpr,CommaPosition + 1);
          case CountyCaptionType of
            '1':
              begin
                if CountryRegion.Get(CountyCaptionRef) and (CountryRegion."County Name" <> '') then
                  exit(CountryRegion."County Name");
                exit(CountyTxt);
              end;
            else
              exit(CountyTxt);
          end;
        end;
        exit(CountyTxt);
    end;

    local procedure GetGLSetup(): Boolean
    begin
        if not GLSetupRead then
          GLSetupRead := GLSetup.Get;
        exit(GLSetupRead);
    end;

    [Scope('Personalization')]
    procedure GetRecordFiltersWithCaptions(RecVariant: Variant) Filters: Text
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        FieldFilter: Text;
        Name: Text;
        Cap: Text;
        Pos: Integer;
        i: Integer;
    begin
        RecRef.GetTable(RecVariant);
        Filters := RecRef.GetFilters;
        if Filters = '' then
          exit;

        for i := 1 to RecRef.FieldCount do begin
          FieldRef := RecRef.FieldIndex(i);
          FieldFilter := FieldRef.GetFilter;
          if FieldFilter <> '' then begin
            Name := StrSubstNo('%1: ',FieldRef.Name);
            Cap := StrSubstNo('%1: ',FieldRef.Caption);
            Pos := StrPos(Filters,Name);
            if Pos <> 0 then
              Filters := InsStr(DelStr(Filters,Pos,StrLen(Name)),Cap,Pos);
          end;
        end;
    end;

    [Scope('Personalization')]
    procedure GetTranslatedFieldCaption(LanguageCode: Code[10];TableID: Integer;FieldId: Integer) TranslatedText: Text
    var
        Language: Record Language;
        "Field": Record "Field";
        CurrentLanguageCode: Integer;
    begin
        CurrentLanguageCode := GlobalLanguage;
        if (LanguageCode <> '') and (Language.GetLanguageID(LanguageCode) <> CurrentLanguageCode) then begin
          GlobalLanguage(Language.GetLanguageID(LanguageCode));
          Field.Get(TableID,FieldId);
          TranslatedText := Field."Field Caption";
          GlobalLanguage(CurrentLanguageCode);
        end else begin
          Field.Get(TableID,FieldId);
          TranslatedText := Field."Field Caption";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 2000000004, 'CaptionClassTranslate', '', false, false)]
    local procedure DoCaptionClassTranslate(Language: Integer;CaptionExpr: Text[1024];var Translation: Text[1024])
    var
        CaptionManagement: Codeunit CaptionManagement;
    begin
        Translation := CaptionManagement.CaptionClassTranslate(Language,CaptionExpr);
        OnAfterCaptionClassTranslate(Language,CaptionExpr,Translation);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCaptionClassTranslate(Language: Integer;CaptionExpression: Text[1024];var Caption: Text[1024])
    begin
    end;
}

