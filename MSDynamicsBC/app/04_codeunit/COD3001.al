codeunit 3001 DotNet_RegEx
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        DotNetRegEx: DotNet Regex;

    [Scope('Personalization')]
    procedure Split(Input: Text;Pattern: Text;var DotNet_Array: Codeunit DotNet_Array)
    var
        DotNetArray: DotNet Array;
    begin
        DotNetArray := DotNetRegEx.Split(Input,Pattern);
        DotNet_Array.SetArray(DotNetArray)
    end;

    [Scope('Personalization')]
    procedure Regex(pattern: Text)
    begin
        DotNetRegEx := DotNetRegEx.Regex(pattern)
    end;

    [Scope('Personalization')]
    procedure Replace(input: Text;evaluator: Text): Text
    begin
        exit(DotNetRegEx.Replace(input,evaluator))
    end;

    procedure GetRegEx(var DotNetRegEx2: DotNet Regex)
    begin
        DotNetRegEx2 := DotNetRegEx
    end;

    procedure SetRegEx(DotNetRegEx2: DotNet Regex)
    begin
        DotNetRegEx := DotNetRegEx2
    end;
}

