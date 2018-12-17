codeunit 1603 "Export Sales Cr.M. - PEPPOL2.0"
{
    // version NAVW113.00

    TableNo = "Record Export Buffer";

    trigger OnRun()
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        RecordRef: RecordRef;
    begin
        RecordRef.Get(RecordID);
        RecordRef.SetTable(SalesCrMemoHeader);

        ServerFilePath := GenerateXMLFile(SalesCrMemoHeader);

        Modify;
    end;

    var
        ExportPathGreaterThan250Err: Label 'The export path is longer than 250 characters.';

    procedure GenerateXMLFile(VariantRec: Variant): Text[250]
    var
        FileManagement: Codeunit "File Management";
        SalesCreditMemoPEPPOL20: XMLport "Sales Credit Memo - PEPPOL 2.0";
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
        SalesCreditMemoPEPPOL20.Initialize(VariantRec);
        SalesCreditMemoPEPPOL20.SetDestination(OutStream);
        SalesCreditMemoPEPPOL20.Export;
        OutFile.Close;

        exit(CopyStr(XmlServerPath,1,250));
    end;
}

