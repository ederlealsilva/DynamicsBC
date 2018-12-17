codeunit 3007 DotNet_String
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        DotNetString: DotNet String;

    [Scope('Personalization')]
    procedure Set(Text: Text)
    begin
        DotNetString := Text
    end;

    [Scope('Personalization')]
    procedure Replace(ToReplace: Text;ReplacementText: Text): Text
    begin
        exit(DotNetString.Replace(ToReplace,ReplacementText))
    end;

    [Scope('Personalization')]
    procedure Split(DotNet_ArraySplit: Codeunit DotNet_Array;var DotNet_ArrayReturn: Codeunit DotNet_Array)
    var
        DotNetArraySplit: DotNet Array;
    begin
        DotNet_ArraySplit.GetArray(DotNetArraySplit);
        DotNet_ArrayReturn.SetArray(DotNetString.Split(DotNetArraySplit));
    end;

    [Scope('Personalization')]
    procedure ToCharArray(StartIndex: Integer;Length: Integer;var DotNet_Array: Codeunit DotNet_Array)
    begin
        DotNet_Array.SetArray(DotNetString.ToCharArray(StartIndex,Length));
    end;

    [Scope('Personalization')]
    procedure StartsWith(Value: Text): Boolean
    begin
        exit(DotNetString.StartsWith(Value))
    end;

    [Scope('Personalization')]
    procedure EndsWith(Value: Text): Boolean
    begin
        exit(DotNetString.EndsWith(Value))
    end;

    [Scope('Personalization')]
    procedure ToString(): Text
    begin
        exit(DotNetString.ToString);
    end;

    [Scope('Personalization')]
    procedure IsDotNetNull(): Boolean
    begin
        exit(IsNull(DotNetString));
    end;

    procedure GetString(var DotNetString2: DotNet String)
    begin
        DotNetString2 := DotNetString
    end;

    procedure SetString(DotNetString2: DotNet String)
    begin
        DotNetString := DotNetString2
    end;
}

