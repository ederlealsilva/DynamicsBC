codeunit 3027 DotNet_StreamReader
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        DotNetStreamReader: DotNet StreamReader;

    [Scope('Personalization')]
    procedure StreamReader(var InputStream: InStream;DotNet_Encoding: Codeunit DotNet_Encoding)
    var
        DotNetEncoding: DotNet Encoding;
    begin
        DotNet_Encoding.GetEncoding(DotNetEncoding);
        DotNetStreamReader := DotNetStreamReader.StreamReader(InputStream,DotNetEncoding);
    end;

    [Scope('Personalization')]
    procedure StreamReaderDetectEncoding(var InputStream: InStream;DetectEncodingFromByteOrderMarks: Boolean)
    begin
        DotNetStreamReader := DotNetStreamReader.StreamReader(InputStream,DetectEncodingFromByteOrderMarks);
    end;

    [Scope('Personalization')]
    procedure Close()
    begin
        DotNetStreamReader.Close;
    end;

    [Scope('Personalization')]
    procedure Dispose()
    begin
        DotNetStreamReader.Dispose;
    end;

    [Scope('Personalization')]
    procedure EndOfStream(): Boolean
    begin
        exit(DotNetStreamReader.EndOfStream);
    end;

    [Scope('Personalization')]
    procedure CurrentEncoding(var DotNet_Encoding: Codeunit DotNet_Encoding)
    begin
        DotNet_Encoding.SetEncoding(DotNetStreamReader.CurrentEncoding);
    end;

    [Scope('Personalization')]
    procedure ReadLine(): Text
    begin
        exit(DotNetStreamReader.ReadLine);
    end;

    [Scope('Personalization')]
    procedure ReadToEnd(): Text
    begin
        exit(DotNetStreamReader.ReadToEnd);
    end;
}

