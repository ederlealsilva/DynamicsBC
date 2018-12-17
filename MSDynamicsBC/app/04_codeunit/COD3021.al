codeunit 3021 DotNet_AppSource
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        [RunOnClient]
        DotNetAppSource: DotNet AppSource;

    procedure IsAvailable(): Boolean
    begin
        // do not make external
        exit(DotNetAppSource.IsAvailable)
    end;

    procedure Create()
    begin
        // do not make external
        DotNetAppSource := DotNetAppSource.Create
    end;

    procedure ShowAppSource()
    begin
        // do not make external
        DotNetAppSource.ShowAppSource
    end;

    procedure GetAppSource(var DotNetAppSource2: DotNet AppSource)
    begin
        DotNetAppSource2 := DotNetAppSource
    end;

    procedure SetAppSource(DotNetAppSource2: DotNet AppSource)
    begin
        DotNetAppSource := DotNetAppSource2
    end;
}

