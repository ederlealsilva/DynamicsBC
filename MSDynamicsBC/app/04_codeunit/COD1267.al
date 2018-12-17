codeunit 1267 "Password Helper"
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    var
        InsufficientPassLengthErr: Label 'The password must contain at least 8 characters.';
        CharacterSetOption: Option Uppercase,Lowercase,Number,SpecialCharacter;

    [Scope('Personalization')]
    procedure GeneratePassword(Length: Integer): Text
    var
        RNGCryptoServiceProvider: DotNet RNGCryptoServiceProvider;
        DotNetArray: DotNet Array;
        DotNetType: DotNet Type;
        Result: Text;
        I: Integer;
        Step: Integer;
        CharacterIndex: Integer;
        CharacterModValue: Integer;
        CharacterSet: Integer;
        UpercaseCharacterIncluded: Boolean;
        LowercaseCharacterIncluded: Boolean;
        NumericCharacterIncluded: Boolean;
        SpecialCharacterIncluded: Boolean;
        ByteValue: Byte;
    begin
        if Length < 8 then
          Error(InsufficientPassLengthErr);

        Result := '';

        // RNGCryptoServiceProvider ensures randomness of data
        RNGCryptoServiceProvider := RNGCryptoServiceProvider.RNGCryptoServiceProvider;
        DotNetType := DotNetType.GetType('System.Byte',false);
        DotNetArray := DotNetArray.CreateInstance(DotNetType,Length * 2);
        RNGCryptoServiceProvider.GetNonZeroBytes(DotNetArray);

        I := 0;
        Step := 2;
        repeat
          CharacterSet := DotNetArray.GetValue(I);
          CharacterSet := CharacterSet mod 4;

          // We must ensure we have included all types of character.
          // If we are within the last 4 characters of the string we will check.
          // If we are missing one, use that set instead.
          if StrLen(Result) >= Length - 4 then begin
            if not LowercaseCharacterIncluded then
              CharacterSet := CharacterSetOption::Lowercase;

            if not UpercaseCharacterIncluded then
              CharacterSet := CharacterSetOption::Uppercase;

            if not NumericCharacterIncluded then
              CharacterSet := CharacterSetOption::Number;

            if not SpecialCharacterIncluded then
              CharacterSet := CharacterSetOption::SpecialCharacter;

            // Write back updated character set
            ByteValue := CharacterSet;
            DotNetArray.SetValue(ByteValue,I);
          end;

          case CharacterSet of
            CharacterSetOption::Lowercase:
              LowercaseCharacterIncluded := true;
            CharacterSetOption::Uppercase:
              UpercaseCharacterIncluded := true;
            CharacterSetOption::Number:
              NumericCharacterIncluded := true;
            CharacterSetOption::SpecialCharacter:
              SpecialCharacterIncluded := true;
          end;

          CharacterIndex := DotNetArray.GetValue(I + 1);
          CharacterModValue := GetCharacterSetSize(CharacterSet);

          // We must ensure we meet certain complexity requirements used by several online services.
          // If the previous 2 characters are also the same type as this one
          // and the previous 2 characters are sequential from (or the same as) the current value.
          // We will pick the next character instead.
          if StrLen(Result) >= 2 then
            if IsCharacterSetEqual(CharacterSet,DotNetArray.GetValue(I - Step),DotNetArray.GetValue(I - 2 * Step)) then
              if IsCharacterValuesEqualOrSequential(
                   CharacterIndex,DotNetArray.GetValue(I - Step + 1),DotNetArray.GetValue(I - 2 * Step + 1),CharacterSet)
              then begin
                CharacterIndex := (CharacterIndex + 1) mod CharacterModValue;

                // Write back updated character index
                ByteValue := CharacterIndex;
                DotNetArray.SetValue(ByteValue,I + 1);
              end;

          CharacterIndex := CharacterIndex mod CharacterModValue;

          Result += GetCharacterFromCharacterSet(CharacterSet,CharacterIndex);

          I += Step;
        until I >= DotNetArray.Length - 1;

        exit(Result);
    end;

    local procedure GetCharacterSetSize(CharacterSet: Integer): Integer
    begin
        case CharacterSet of
          CharacterSetOption::Lowercase:
            exit(StrLen(GetCharacterPool));
          CharacterSetOption::Uppercase:
            exit(StrLen(GetCharacterPool));
          CharacterSetOption::Number:
            exit(10);
          CharacterSetOption::SpecialCharacter:
            exit(StrLen(GetSpecialCharacterPool));
        end;
    end;

    local procedure GetCharacterPool(): Text
    begin
        exit('ABCDEFGHIJKLNOPQRSTUVWXYZ');
    end;

    local procedure GetSpecialCharacterPool(): Text
    begin
        exit('!@#$*');
    end;

    local procedure GetCharacterFromCharacterSet(CharacterSet: Integer;CharacterIndex: Integer): Text
    begin
        case CharacterSet of
          CharacterSetOption::Lowercase:
            exit(LowerCase(Format(GetCharacterPool[CharacterIndex + 1])));
          CharacterSetOption::Uppercase:
            exit(UpperCase(Format(GetCharacterPool[CharacterIndex + 1])));
          CharacterSetOption::Number:
            exit(Format(CharacterIndex));
          CharacterSetOption::SpecialCharacter:
            exit(Format(GetSpecialCharacterPool[CharacterIndex + 1]));
        end;
    end;

    local procedure IsCharacterSetEqual(Type1: Integer;Type2: Integer;Type3: Integer): Boolean
    var
        NumberOfSets: Integer;
    begin
        NumberOfSets := 4;
        Type1 := Type1 mod NumberOfSets;
        Type2 := Type2 mod NumberOfSets;
        Type3 := Type3 mod NumberOfSets;

        if (Type1 = Type2) and (Type1 = Type3) then
          exit(true);

        exit(false);
    end;

    local procedure IsCharacterValuesEqualOrSequential(Character1: Integer;Character2: Integer;Character3: Integer;CharacterSet: Integer): Boolean
    var
        CharacterModValue: Integer;
    begin
        CharacterModValue := GetCharacterSetSize(CharacterSet);
        Character1 := Character1 mod CharacterModValue;
        Character2 := Character2 mod CharacterModValue;
        Character3 := Character3 mod CharacterModValue;

        // e.g. 'aaa'
        if (Character1 = Character2) and (Character1 = Character3) then
          exit(true);

        // e.g. 'cba'
        if (Character1 = Character2 + 1) and (Character1 = Character3 + 2) then
          exit(true);

        // e.g. 'abc'
        if (Character1 = Character2 - 1) and (Character1 = Character3 - 2) then
          exit(true);

        exit(false);
    end;
}

