codeunit 1709 "Exp. External Data Pos. Pay"
{
    // version NAVW113.00

    Permissions = TableData "Data Exch."=rimd;
    TableNo = "Data Exch.";

    trigger OnRun()
    begin
    end;

    var
        ExternalContentErr: Label '%1 is empty.';
        DownloadFromStreamErr: Label 'The file has not been saved.';

    procedure CreateExportFile(DataExch: Record "Data Exch.";ShowDialog: Boolean)
    var
        TempBlob: Record TempBlob;
        FileMgt: Codeunit "File Management";
        ExportFileName: Text;
    begin
        DataExch.CalcFields("File Content");
        if not DataExch."File Content".HasValue then
          Error(ExternalContentErr,DataExch.FieldCaption("File Content"));

        TempBlob.Blob := DataExch."File Content";
        ExportFileName := DataExch."Data Exch. Def Code" + Format(Today,0,'<Month,2><Day,2><Year4>') + '.txt';
        if FileMgt.BLOBExport(TempBlob,ExportFileName,ShowDialog) = '' then
          Error(DownloadFromStreamErr);
    end;
}

