codeunit 3006 DotNet_DateTimeOffset
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        DotNetDateTimeOffset: DotNet DateTimeOffset;

    [Scope('Personalization')]
    procedure DateTime(var DotNet_DateTime: Codeunit DotNet_DateTime)
    begin
        DotNet_DateTime.SetDateTime(DotNetDateTimeOffset.DateTime)
    end;

    procedure GetDateTimeOffset(var DotNetDateTimeOffset2: DotNet DateTimeOffset)
    begin
        DotNetDateTimeOffset2 := DotNetDateTimeOffset
    end;

    procedure SetDateTimeOffset(DotNetDateTimeOffset2: DotNet DateTimeOffset)
    begin
        DotNetDateTimeOffset := DotNetDateTimeOffset2
    end;
}

