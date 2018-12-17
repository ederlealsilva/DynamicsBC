codeunit 707 "RegEx Split Wrapper"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        SplitArray: DotNet Array;
        ArrayIsEmptyErr: Label 'No split string has been supplied.';
        IndexOutOfBoundsErr: Label 'Index out of bounds.', Comment='%1 = integer';

    [Scope('Personalization')]
    procedure Split(Text: Text;Separator: Text)
    begin
        if not TrySplit(Text,Separator) then
          Error(GetLastErrorText);
    end;

    [Scope('Personalization')]
    procedure GetLength(): Integer
    begin
        CheckIfArrayIsEmpty;
        exit(SplitArray.Length());
    end;

    [Scope('Personalization')]
    procedure GetIndex(Index: Integer): Text
    begin
        CheckIfArrayIsEmpty;
        CheckIfIndexIsWithinBoundaries(Index);
        exit(SplitArray.GetValue(Index));
    end;

    local procedure CheckIfArrayIsEmpty()
    begin
        if IsNull(SplitArray) then
          Error(ArrayIsEmptyErr);
    end;

    local procedure CheckIfIndexIsWithinBoundaries(Index: Integer)
    begin
        if ((Index + 1) > GetLength) or (Index < 0) then
          Error(IndexOutOfBoundsErr);
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure TrySplit(Text: Text;Separator: Text)
    var
        RegEx: DotNet Regex;
    begin
        SplitArray := RegEx.Split(Text,Separator);
    end;
}

