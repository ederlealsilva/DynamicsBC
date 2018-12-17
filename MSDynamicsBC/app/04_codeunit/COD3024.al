codeunit 3024 DotNet_Uri
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        DotNetUri: DotNet Uri;

    [Scope('Personalization')]
    procedure Init(Url: Text)
    begin
        DotNetUri := DotNetUri.Uri(Url);
    end;

    [Scope('Personalization')]
    procedure EscapeDataString(Text: Text): Text
    begin
        exit(DotNetUri.EscapeDataString(Text));
    end;

    [Scope('Personalization')]
    procedure UnescapeDataString(Text: Text): Text
    begin
        exit(DotNetUri.UnescapeDataString(Text));
    end;

    [Scope('Personalization')]
    procedure Scheme(): Text
    begin
        exit(DotNetUri.Scheme);
    end;

    [Scope('Personalization')]
    procedure Segments(var DotNet_Array: Codeunit DotNet_Array)
    begin
        DotNet_Array.SetArray(DotNetUri.Segments);
    end;

    procedure GetUri(var DotNetUri2: DotNet Uri)
    begin
        DotNetUri2 := DotNetUri;
    end;

    procedure SetUri(DotNetUri2: DotNet Uri)
    begin
        DotNetUri := DotNetUri2;
    end;
}

