codeunit 3025 DotNet_StreamWriter
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        DotNetStreamWriter: DotNet StreamWriter;

    [Scope('Personalization')]
    procedure Write(Text: Text)
    begin
        DotNetStreamWriter.Write(Text);
    end;

    [Scope('Personalization')]
    procedure WriteLine(LineText: Text)
    begin
        DotNetStreamWriter.WriteLine(LineText);
    end;

    [Scope('Personalization')]
    procedure StreamWriter(var OutStream: OutStream;DotNet_Encoding: Codeunit DotNet_Encoding)
    var
        DotNetEncoding: DotNet Encoding;
    begin
        DotNet_Encoding.GetEncoding(DotNetEncoding);
        DotNetStreamWriter := DotNetStreamWriter.StreamWriter(OutStream,DotNetEncoding);
    end;

    [Scope('Personalization')]
    procedure StreamWriterWithDefaultEncoding(var OutStream: OutStream)
    begin
        DotNetStreamWriter := DotNetStreamWriter.StreamWriter(OutStream);
    end;

    [Scope('Personalization')]
    procedure Flush()
    begin
        DotNetStreamWriter.Flush;
    end;

    [Scope('Personalization')]
    procedure Close()
    begin
        DotNetStreamWriter.Close;
    end;

    [Scope('Personalization')]
    procedure Dispose()
    begin
        DotNetStreamWriter.Dispose;
    end;
}

