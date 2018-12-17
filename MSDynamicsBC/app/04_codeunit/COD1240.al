codeunit 1240 "Read Data Exch. from File"
{
    // version NAVW111.00

    TableNo = "Data Exch.";

    trigger OnRun()
    var
        TempBlob: Record TempBlob;
        FileMgt: Codeunit "File Management";
    begin
        OnBeforeFileImport(TempBlob,"File Name");

        if not TempBlob.Blob.HasValue then
          "File Name" := CopyStr(FileMgt.BLOBImportWithFilter(TempBlob,ImportBankStmtTxt,'',FileFilterTxt,FileFilterExtensionTxt),1,250);

        if "File Name" <> '' then
          "File Content" := TempBlob.Blob;
    end;

    var
        ImportBankStmtTxt: Label 'Select a file to import';
        FileFilterTxt: Label 'All Files(*.*)|*.*|XML Files(*.xml)|*.xml|Text Files(*.txt;*.csv;*.asc)|*.txt;*.csv;*.asc,*.nda';
        FileFilterExtensionTxt: Label 'txt,csv,asc,xml,nda', Locked=true;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFileImport(var TempBlob: Record TempBlob;var FileName: Text)
    begin
    end;
}

