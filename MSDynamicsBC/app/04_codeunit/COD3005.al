codeunit 3005 DotNet_XMLConvert
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        DotNetXMLConvert: DotNet XmlConvert;

    [Scope('Personalization')]
    procedure ToDateTimeOffset(DateText: Text;var DotNet_DateTimeOffset: Codeunit DotNet_DateTimeOffset)
    begin
        DotNet_DateTimeOffset.SetDateTimeOffset(DotNetXMLConvert.ToDateTimeOffset(DateText))
    end;

    procedure GetXMLConvert(var DotNetXMLConvert2: DotNet XmlConvert)
    begin
        DotNetXMLConvert2 := DotNetXMLConvert
    end;

    procedure SetXMLConvert(DotNetXMLConvert2: DotNet XmlConvert)
    begin
        DotNetXMLConvert := DotNetXMLConvert2
    end;
}

