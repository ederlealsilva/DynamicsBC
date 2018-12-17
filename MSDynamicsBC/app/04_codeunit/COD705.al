codeunit 705 "Stream Management"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        MemoryStream: DotNet MemoryStream;

    [Scope('Personalization')]
    procedure MtomStreamToXmlStream(MtomStream: InStream;var XmlStream: InStream;ContentType: Text)
    var
        TextEncoding: DotNet Encoding;
        DotNetArray: DotNet Array;
        XmlDocument: DotNet XmlDocument;
        XmlDictionaryReader: DotNet XmlDictionaryReader;
        XmlDictionaryReaderQuotas: DotNet XmlDictionaryReaderQuotas;
    begin
        DotNetArray := DotNetArray.CreateInstance(GetDotNetType(TextEncoding),1);
        DotNetArray.SetValue(TextEncoding.UTF8,0);
        XmlDictionaryReader := XmlDictionaryReader.CreateMtomReader(MtomStream,DotNetArray,ContentType,XmlDictionaryReaderQuotas.Max);
        XmlDictionaryReader.MoveToContent;

        XmlDocument := XmlDocument.XmlDocument;
        XmlDocument.PreserveWhitespace := true;
        XmlDocument.Load(XmlDictionaryReader);
        MemoryStream := MemoryStream.MemoryStream;
        XmlDocument.Save(MemoryStream);
        MemoryStream.Position := 0;
        XmlStream := MemoryStream;
    end;
}

