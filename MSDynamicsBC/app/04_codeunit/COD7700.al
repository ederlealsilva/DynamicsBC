codeunit 7700 "ADCS Management"
{
    // version NAVW113.00

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        InboundDocument: DotNet XmlDocument;
        OutboundDocument: DotNet XmlDocument;

    [Scope('Personalization')]
    procedure SendXMLReply(xmlout: DotNet XmlDocument)
    begin
        OutboundDocument := xmlout;
    end;

    procedure SendError(ErrorString: Text[250])
    var
        XMLDOMMgt: Codeunit "XML DOM Management";
        RootNode: DotNet XmlNode;
        Child: DotNet XmlNode;
        ReturnedNode: DotNet XmlNode;
    begin
        OutboundDocument := InboundDocument;

        // Error text
        Clear(XMLDOMMgt);
        RootNode := OutboundDocument.DocumentElement;

        if XMLDOMMgt.FindNode(RootNode,'Header',ReturnedNode) then begin
          if XMLDOMMgt.FindNode(RootNode,'Header/Input',Child) then
            ReturnedNode.RemoveChild(Child);
          if XMLDOMMgt.FindNode(RootNode,'Header/Comment',Child) then
            ReturnedNode.RemoveChild(Child);
          XMLDOMMgt.AddElement(ReturnedNode,'Comment',ErrorString,'',ReturnedNode);
        end;

        Clear(RootNode);
        Clear(Child);
    end;

    procedure ProcessDocument(Document: DotNet XmlDocument)
    var
        MiniformMgt: Codeunit "Miniform Management";
    begin
        InboundDocument := Document;
        MiniformMgt.ReceiveXML(InboundDocument);
    end;

    [Scope('Personalization')]
    procedure GetOutboundDocument(var Document: DotNet XmlDocument)
    begin
        Document := OutboundDocument;
    end;
}

