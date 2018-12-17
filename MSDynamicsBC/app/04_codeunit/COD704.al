codeunit 704 "MemoryStream Wrapper"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        MemoryStream: DotNet MemoryStream;
        StreamWriter: DotNet StreamWriter;
        StreamReader: DotNet StreamReader;

    [Scope('Personalization')]
    procedure Create(Capacity: Integer)
    begin
        MemoryStream := MemoryStream.MemoryStream(Capacity);
    end;

    [Scope('Personalization')]
    procedure SetPosition(Position: Integer)
    begin
        MemoryStream.Position := Position;
    end;

    [Scope('Personalization')]
    procedure GetPosition(): Integer
    begin
        exit(MemoryStream.Position);
    end;

    [Scope('Personalization')]
    procedure CopyTo(OutStream: OutStream)
    begin
        MemoryStream.CopyTo(OutStream);
    end;

    [Scope('Personalization')]
    procedure GetInStream(var InStream: InStream)
    begin
        InStream := MemoryStream;
    end;

    [Scope('Personalization')]
    procedure ReadFrom(var InStream: InStream)
    begin
        CopyStream(MemoryStream,InStream);
    end;

    [Scope('Personalization')]
    procedure ToText(): Text
    begin
        MemoryStream.Position := 0;
        if IsNull(StreamReader) then
          StreamReader := StreamReader.StreamReader(MemoryStream);
        exit(StreamReader.ReadToEnd());
    end;

    [Scope('Personalization')]
    procedure AddText(Txt: Text)
    begin
        if IsNull(StreamWriter) then
          StreamWriter := StreamWriter.StreamWriter(MemoryStream);
        StreamWriter.Write(Txt);
        StreamWriter.Flush();
    end;

    [Scope('Personalization')]
    procedure Length(): Integer
    begin
        exit(MemoryStream.Length);
    end;
}

