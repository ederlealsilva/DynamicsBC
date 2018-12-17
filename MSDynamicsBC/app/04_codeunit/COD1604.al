codeunit 1604 "Export Serv. Inv. - PEPPOL 2.1"
{
    // version NAVW113.00

    TableNo = "Record Export Buffer";

    trigger OnRun()
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        RecordRef: RecordRef;
    begin
        RecordRef.Get(RecordID);
        RecordRef.SetTable(ServiceInvoiceHeader);

        ServerFilePath := GenerateXMLFile(ServiceInvoiceHeader);

        Modify;
    end;

    var
        ExportPathGreaterThan250Err: Label 'The export path is longer than 250 characters.';

    procedure GenerateXMLFile(ServiceInvoiceHeader: Record "Service Invoice Header"): Text[250]
    var
        FileManagement: Codeunit "File Management";
        SalesInvoicePEPPOL: XMLport "Sales Invoice - PEPPOL 2.1";
        OutFile: File;
        OutStream: OutStream;
        XmlServerPath: Text;
    begin
        XmlServerPath := FileManagement.ServerTempFileName('xml');

        if StrLen(XmlServerPath) > 250 then
          Error(ExportPathGreaterThan250Err);

        if not Exists(XmlServerPath) then
          OutFile.Create(XmlServerPath)
        else
          OutFile.Open(XmlServerPath);

        // Generate XML
        OutFile.CreateOutStream(OutStream);
        SalesInvoicePEPPOL.Initialize(ServiceInvoiceHeader);
        SalesInvoicePEPPOL.SetDestination(OutStream);
        SalesInvoicePEPPOL.Export;
        OutFile.Close;

        exit(CopyStr(XmlServerPath,1,250));
    end;
}

