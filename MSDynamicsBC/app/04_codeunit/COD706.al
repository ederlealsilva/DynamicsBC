codeunit 706 "Zip Stream Wrapper"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        ZipTempBlob: Record TempBlob;
        ZipArchive: DotNet ZipArchive;
        ZipArchiveMode: DotNet ZipArchiveMode;
        ZipFileFilterTxt: Label 'Zip Files (*.zip)|*.zip|All Files (*.*)|*.*', Comment='Only translate "Zip Files" and "All Files"';
        UploadZipFileTxt: Label 'Upload ZIP file';
        DownloadZipFileTxt: Label 'Download ZIP file';
        DefaultZipFileTxt: Label 'Default.zip';

    [Scope('Personalization')]
    procedure CreateNewZip()
    var
        OutputStream: OutStream;
    begin
        Clear(ZipTempBlob);
        ZipTempBlob.Blob.CreateOutStream(OutputStream);
        ZipArchive := ZipArchive.ZipArchive(OutputStream,ZipArchiveMode.Create);
    end;

    [Scope('Personalization')]
    procedure OpenZipFromStream(InputStream: InStream;ZipArchiveModeIsUpdate: Boolean)
    var
        OutputStream: OutStream;
    begin
        Clear(ZipTempBlob);
        ZipTempBlob.Blob.CreateOutStream(OutputStream);
        CopyStream(OutputStream,InputStream);

        if ZipArchiveModeIsUpdate then
          ZipArchive := ZipArchive.ZipArchive(OutputStream,ZipArchiveMode.Update)
        else
          ZipArchive := ZipArchive.ZipArchive(OutputStream,ZipArchiveMode.Read);
    end;

    [Scope('Personalization')]
    procedure UploadZip(DialogTitle: Text;FromFolder: Text;FromFilter: Text;FromFile: Text): Boolean
    var
        InputStream: InStream;
    begin
        if DialogTitle = '' then
          DialogTitle := UploadZipFileTxt;
        if FromFilter = '' then
          FromFilter := ZipFileFilterTxt;

        if UploadIntoStream(DialogTitle,FromFolder,FromFilter,FromFile,InputStream) then begin
          OpenZipFromStream(InputStream,false);
          exit(true);
        end;
    end;

    [Scope('Personalization')]
    procedure OpenZipFromTempBlob(var TempBlob: Record TempBlob;ZipArchiveModeIsUpdate: Boolean)
    var
        InputStream: InStream;
    begin
        TempBlob.Blob.CreateInStream(InputStream);
        OpenZipFromStream(InputStream,ZipArchiveModeIsUpdate);
    end;

    [Scope('Personalization')]
    procedure SaveZipToStream(OutputStream: OutStream)
    var
        InputStream: InStream;
    begin
        ZipArchive.Dispose;
        ZipTempBlob.Blob.CreateInStream(InputStream);
        CopyStream(OutputStream,InputStream);
        Clear(ZipTempBlob);
    end;

    [Scope('Personalization')]
    procedure DownloadZip(DialogTitle: Text;ToFolder: Text;ToFilter: Text;ToFile: Text): Boolean
    var
        InputStream: InStream;
        Result: Boolean;
    begin
        if DialogTitle = '' then
          DialogTitle := DownloadZipFileTxt;
        if ToFilter = '' then
          ToFilter := ZipFileFilterTxt;
        if ToFile = '' then
          ToFile := DefaultZipFileTxt;

        ZipArchive.Dispose;
        ZipTempBlob.Blob.CreateInStream(InputStream);
        Result := DownloadFromStream(InputStream,DialogTitle,ToFolder,ToFilter,ToFile);
        Clear(ZipTempBlob);
        exit(Result);
    end;

    [Scope('Personalization')]
    procedure SaveZipToTempBlob(var TempBlob: Record TempBlob)
    var
        OutputStream: OutStream;
    begin
        Clear(TempBlob);
        TempBlob.Blob.CreateOutStream(OutputStream);
        SaveZipToStream(OutputStream);
    end;

    [Scope('Personalization')]
    procedure GetEntries(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    var
        ZipArchiveEntry: DotNet ZipArchiveEntry;
    begin
        foreach ZipArchiveEntry in ZipArchive.Entries do
          TempNameValueBuffer.AddNewEntry(ZipArchiveEntry.FullName,ZipArchiveEntry.Name);
    end;

    [Scope('Personalization')]
    procedure WriteEntryFromZipToOutStream(EntryName: Text;var OutputStream: OutStream)
    var
        ZipArchiveEntry: DotNet ZipArchiveEntry;
        ZipArchiveEntryStream: DotNet Stream;
    begin
        ZipArchiveEntry := ZipArchive.GetEntry(EntryName);
        ZipArchiveEntryStream := ZipArchiveEntry.Open;
        ZipArchiveEntryStream.CopyTo(OutputStream);
        ZipArchiveEntryStream.Close;
    end;

    [Scope('Personalization')]
    procedure AddEntryFromStreamToZip(EntryName: Text;InputStream: InStream)
    var
        ZipArchiveEntry: DotNet ZipArchiveEntry;
        ZipArchiveEntryStream: DotNet Stream;
    begin
        ZipArchiveEntry := ZipArchive.CreateEntry(EntryName);
        ZipArchiveEntryStream := ZipArchiveEntry.Open;
        CopyStream(ZipArchiveEntryStream,InputStream);
        ZipArchiveEntryStream.Close;
    end;
}

