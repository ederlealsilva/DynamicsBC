table 99008535 TempBlob
{
    // version NAVW113.00

    Caption = 'TempBlob';

    fields
    {
        field(1;"Primary Key";Integer)
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(2;Blob;BLOB)
        {
            Caption = 'Blob';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1;"Primary Key")
        {
        }
    }

    fieldgroups
    {
    }

    var
        GlobalInStream: InStream;
        GlobalOutStream: OutStream;
        ReadLinesInitialized: Boolean;
        WriteLinesInitialized: Boolean;
        NoContentErr: Label 'The BLOB field is empty.';
        UnknownImageTypeErr: Label 'Unknown image type.';
        XmlCannotBeLoadedErr: Label 'The XML cannot be loaded.';

    [Scope('Personalization')]
    procedure WriteAsText(Content: Text;Encoding: TextEncoding)
    var
        OutStr: OutStream;
    begin
        Clear(Blob);
        if Content = '' then
          exit;
        Blob.CreateOutStream(OutStr,Encoding);
        OutStr.WriteText(Content);
    end;

    [Scope('Personalization')]
    procedure ReadAsText(LineSeparator: Text;Encoding: TextEncoding) Content: Text
    var
        InStream: InStream;
        ContentLine: Text;
    begin
        Blob.CreateInStream(InStream,Encoding);

        InStream.ReadText(Content);
        while not InStream.EOS do begin
          InStream.ReadText(ContentLine);
          Content += LineSeparator + ContentLine;
        end;
    end;

    [Scope('Personalization')]
    procedure ReadAsTextWithCRLFLineSeparator(): Text
    var
        CRLF: Text[2];
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        exit(ReadAsText(CRLF,TEXTENCODING::UTF8));
    end;

    [Scope('Personalization')]
    procedure StartReadingTextLines(Encoding: TextEncoding)
    begin
        Blob.CreateInStream(GlobalInStream,Encoding);
        ReadLinesInitialized := true;
    end;

    [Scope('Personalization')]
    procedure StartWritingTextLines(Encoding: TextEncoding)
    begin
        Clear(Blob);
        Blob.CreateOutStream(GlobalOutStream,Encoding);
        WriteLinesInitialized := true;
    end;

    [Scope('Personalization')]
    procedure MoreTextLines(): Boolean
    begin
        if not ReadLinesInitialized then
          StartReadingTextLines(TEXTENCODING::Windows);
        exit(not GlobalInStream.EOS);
    end;

    [Scope('Personalization')]
    procedure ReadTextLine(): Text
    var
        ContentLine: Text;
    begin
        if not MoreTextLines then
          exit('');
        GlobalInStream.ReadText(ContentLine);
        exit(ContentLine);
    end;

    [Scope('Personalization')]
    procedure WriteTextLine(Content: Text)
    begin
        if not WriteLinesInitialized then
          StartWritingTextLines(TEXTENCODING::Windows);
        GlobalOutStream.WriteText(Content);
    end;

    [Scope('Personalization')]
    procedure ToBase64String(): Text
    var
        IStream: InStream;
        Convert: DotNet Convert;
        MemoryStream: DotNet MemoryStream;
        Base64String: Text;
    begin
        if not Blob.HasValue then
          exit('');
        Blob.CreateInStream(IStream);
        MemoryStream := MemoryStream.MemoryStream;
        CopyStream(MemoryStream,IStream);
        Base64String := Convert.ToBase64String(MemoryStream.ToArray);
        MemoryStream.Close;
        exit(Base64String);
    end;

    [Scope('Personalization')]
    procedure FromBase64String(Base64String: Text)
    var
        OStream: OutStream;
        Convert: DotNet Convert;
        MemoryStream: DotNet MemoryStream;
    begin
        if Base64String = '' then
          exit;
        MemoryStream := MemoryStream.MemoryStream(Convert.FromBase64String(Base64String));
        Blob.CreateOutStream(OStream);
        MemoryStream.WriteTo(OStream);
        MemoryStream.Close;
    end;

    [Scope('Personalization')]
    procedure GetHTMLImgSrc(): Text
    var
        ImageFormatAsTxt: Text;
    begin
        if not Blob.HasValue then
          exit('');
        if not TryGetImageFormatAsTxt(ImageFormatAsTxt) then
          exit('');
        exit(StrSubstNo('data:image/%1;base64,%2',ImageFormatAsTxt,ToBase64String));
    end;

    [TryFunction]
    local procedure TryGetImageFormatAsTxt(var ImageFormatAsTxt: Text)
    var
        Image: DotNet Image;
        ImageFormatConverter: DotNet ImageFormatConverter;
        InStream: InStream;
    begin
        Blob.CreateInStream(InStream);
        Image := Image.FromStream(InStream);
        ImageFormatConverter := ImageFormatConverter.ImageFormatConverter;
        ImageFormatAsTxt := ImageFormatConverter.ConvertToString(Image.RawFormat);
    end;

    [Scope('Personalization')]
    procedure GetImageType(): Text
    var
        ImageFormatAsTxt: Text;
    begin
        if not Blob.HasValue then
          Error(NoContentErr);
        if not TryGetImageFormatAsTxt(ImageFormatAsTxt) then
          Error(UnknownImageTypeErr);
        exit(ImageFormatAsTxt);
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure TryDownloadFromUrl(Url: Text)
    var
        FileManagement: Codeunit "File Management";
        WebClient: DotNet WebClient;
        MemoryStream: DotNet MemoryStream;
        OutStr: OutStream;
    begin
        FileManagement.IsAllowedPath(Url,false);
        WebClient := WebClient.WebClient;
        MemoryStream := MemoryStream.MemoryStream(WebClient.DownloadData(Url));
        Blob.CreateOutStream(OutStr);
        CopyStream(OutStr,MemoryStream);
    end;

    [TryFunction]
    local procedure TryGetXMLAsText(var Xml: Text)
    var
        XmlDoc: DotNet XmlDocument;
        InStr: InStream;
    begin
        Blob.CreateInStream(InStr);
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.PreserveWhitespace := false;
        XmlDoc.Load(InStr);
        Xml := XmlDoc.OuterXml;
    end;

    [Scope('Personalization')]
    procedure GetXMLAsText(): Text
    var
        Xml: Text;
    begin
        if not Blob.HasValue then
          Error(NoContentErr);
        if not TryGetXMLAsText(Xml) then
          Error(XmlCannotBeLoadedErr);
        exit(Xml);
    end;
}

