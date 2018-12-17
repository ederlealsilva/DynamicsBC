codeunit 3015 DotNet_StringComparison
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        DotNetStringComparison: DotNet StringComparison;

    [Scope('Personalization')]
    procedure OrdinalIgnoreCase(): Integer
    begin
        exit(DotNetStringComparison.OrdinalIgnoreCase)
    end;

    procedure GetStringComparison(var DotNetStringComparison2: DotNet StringComparison)
    begin
        DotNetStringComparison2 := DotNetStringComparison
    end;

    procedure SetStringComparison(DotNetStringComparison2: DotNet StringComparison)
    begin
        DotNetStringComparison := DotNetStringComparison2
    end;
}

