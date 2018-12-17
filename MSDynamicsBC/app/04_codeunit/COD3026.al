codeunit 3026 DotNet_Encoding
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        DotNetEncoding: DotNet Encoding;

    [Scope('Personalization')]
    procedure ASCII()
    begin
        DotNetEncoding := DotNetEncoding.ASCII;
    end;

    [Scope('Personalization')]
    procedure UTF8()
    begin
        DotNetEncoding := DotNetEncoding.UTF8;
    end;

    [Scope('Personalization')]
    procedure UTF32()
    begin
        DotNetEncoding := DotNetEncoding.UTF32;
    end;

    [Scope('Personalization')]
    procedure Unicode()
    begin
        DotNetEncoding := DotNetEncoding.Unicode;
    end;

    [Scope('Personalization')]
    procedure Encoding(codePage: Integer)
    begin
        DotNetEncoding := DotNetEncoding.GetEncoding(codePage);
    end;

    [Scope('Personalization')]
    procedure Codepage(): Integer
    begin
        exit(DotNetEncoding.CodePage);
    end;

    [Scope('Personalization')]
    procedure GetEncoding(var DotNetEncoding2: DotNet Encoding)
    begin
        DotNetEncoding2 := DotNetEncoding;
    end;

    [Scope('Personalization')]
    procedure SetEncoding(DotNetEncoding2: DotNet Encoding)
    begin
        DotNetEncoding := DotNetEncoding2;
    end;
}

