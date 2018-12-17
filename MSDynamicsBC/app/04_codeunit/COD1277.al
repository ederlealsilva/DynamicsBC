codeunit 1277 "Exp. External Data Gen. Jnl."
{
    // version NAVW19.00

    Permissions = TableData "Data Exch."=rimd;
    TableNo = "Data Exch.";

    trigger OnRun()
    var
        TempBlob: Record TempBlob;
        FileMgt: Codeunit "File Management";
    begin
        CalcFields("File Content");
        if not "File Content".HasValue then
          Error(ExternalContentErr,FieldCaption("File Content"));

        TempBlob.Blob := "File Content";
        if FileMgt.BLOBExport(TempBlob,"Data Exch. Def Code" + ' ' + "Data Exch. Line Def Code" + TxtExtTok,true) = '' then
          Error(DownloadFromStreamErr);
    end;

    var
        ExternalContentErr: Label '%1 is empty.';
        DownloadFromStreamErr: Label 'The file has not been saved.';
        TxtExtTok: Label '.txt', Locked=true;
}

