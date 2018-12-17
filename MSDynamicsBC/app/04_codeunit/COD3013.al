codeunit 3013 DotNet_XmlDocument
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        DotNetXmlDocument: DotNet XmlDocument;

    [Scope('Personalization')]
    procedure InitXmlDocument()
    begin
        DotNetXmlDocument := DotNetXmlDocument.XmlDocument
    end;

    [Scope('Personalization')]
    procedure PreserveWhitespace(PreserveWhitespace: Boolean)
    begin
        DotNetXmlDocument.PreserveWhitespace := PreserveWhitespace
    end;

    [Scope('Personalization')]
    procedure Load(InStream: InStream)
    begin
        DotNetXmlDocument.Load(InStream)
    end;

    [Scope('Personalization')]
    procedure OuterXml(): Text
    begin
        exit(DotNetXmlDocument.OuterXml)
    end;

    procedure GetXmlDocument(var DotNetXmlDocument2: DotNet XmlDocument)
    begin
        DotNetXmlDocument2 := DotNetXmlDocument
    end;

    procedure SetXmlDocument(DotNetXmlDocument2: DotNet XmlDocument)
    begin
        DotNetXmlDocument := DotNetXmlDocument2
    end;
}

