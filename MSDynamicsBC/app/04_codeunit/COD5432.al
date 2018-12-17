codeunit 5432 "Automation - Import RSPackage"
{
    // version NAVW113.00

    TableNo = "Config. Package";

    trigger OnRun()
    var
        TenantConfigPackageFile: Record "Tenant Config. Package File";
        TempBlobDecompressed: Record TempBlob temporary;
        TempBlob: Record TempBlob temporary;
        ConfigXMLExchange: Codeunit "Config. XML Exchange";
        InStream: InStream;
    begin
        Validate("Import Status","Import Status"::InProgress);
        Modify(true);

        TenantConfigPackageFile.Get(Code);
        TenantConfigPackageFile.CalcFields(Content);
        TempBlob.Blob := TenantConfigPackageFile.Content;

        ConfigXMLExchange.SetHideDialog(true);
        ConfigXMLExchange.DecompressPackageToBlob(TempBlob,TempBlobDecompressed);
        TempBlobDecompressed.Blob.CreateInStream(InStream);
        ConfigXMLExchange.ImportPackageXMLWithCodeFromStream(InStream,Code);

        // refreshing the record as ImportPackageXMLWithCodeFromStream updated the Configuration package with the number of records in the package, etc.
        Find;
        Validate("Import Status","Import Status"::Completed);
        Modify(true);
        Commit;
    end;
}

