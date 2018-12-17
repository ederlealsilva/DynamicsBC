codeunit 3000 DotNet_Array
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        DotNetArray: DotNet Array;

    [Scope('Personalization')]
    procedure Length(): Integer
    begin
        exit(DotNetArray.Length)
    end;

    [Scope('Personalization')]
    procedure GetValueAsText(Index: Integer): Text
    begin
        exit(DotNetArray.GetValue(Index))
    end;

    procedure GetArray(var DotNetArray2: DotNet Array)
    begin
        DotNetArray2 := DotNetArray
    end;

    procedure SetArray(DotNetArray2: DotNet Array)
    begin
        DotNetArray := DotNetArray2
    end;
}

