codeunit 1608 "Exp. Service Cr.M. - PEPPOL2.1"
{
    // version NAVW113.00

    TableNo = "Record Export Buffer";

    trigger OnRun()
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        RecordRef: RecordRef;
    begin
        RecordRef.Get(RecordID);
        RecordRef.SetTable(ServiceCrMemoHeader);

        ServerFilePath := GenerateXMLFile(ServiceCrMemoHeader);

        Modify;
    end;

    var
        ExportPathGreaterThan250Err: Label 'The export path is longer than 250 characters.';

    procedure GenerateXMLFile(VariantRec: Variant): Text[250]
    var
        FileManagement: Codeunit "File Management";
        SalesCreditMemoPEPPOL: XMLport "Sales Credit Memo - PEPPOL 2.1";
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
        SalesCreditMemoPEPPOL.Initialize(VariantRec);
        SalesCreditMemoPEPPOL.SetDestination(OutStream);
        SalesCreditMemoPEPPOL.Export;
        OutFile.Close;

        exit(CopyStr(XmlServerPath,1,250));
    end;
}

