codeunit 1292 Trace
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        TraceLogInStream: InStream;
        TraceStreamLogAlreadyInUseErr: Label 'Debug stream logging is already in use.';

    procedure LogStreamToTempFile(var ToLogInStream: InStream;Name: Text;var TraceLogTempBlob: Record TempBlob) Filename: Text
    var
        FileManagement: Codeunit "File Management";
        OutStream: OutStream;
    begin
        TraceLogTempBlob.CalcFields(Blob);
        if TraceLogTempBlob.Blob.HasValue then
          if not TraceLogInStream.EOS then
            Error(TraceStreamLogAlreadyInUseErr);

        TraceLogTempBlob.Blob.CreateOutStream(OutStream);
        CopyStream(OutStream,ToLogInStream);

        Filename := FileManagement.ServerTempFileName(Name + '.XML');

        TraceLogTempBlob.Blob.Export(Filename);

        TraceLogTempBlob.Blob.CreateInStream(TraceLogInStream);
        ToLogInStream := TraceLogInStream;
    end;

    procedure LogXmlDocToTempFile(var XmlDoc: DotNet XmlDocument;Name: Text) Filename: Text
    var
        FileManagement: Codeunit "File Management";
    begin
        Filename := FileManagement.ServerTempFileName(Name + '.XML');
        FileManagement.IsAllowedPath(Filename,false);

        XmlDoc.Save(Filename);
    end;

    procedure LogTextToTempFile(TextToLog: Text;FileName: Text)
    var
        FileManagement: Codeunit "File Management";
        OutStream: OutStream;
        TempFile: File;
    begin
        TempFile.Create(FileManagement.ServerTempFileName(FileName + '.txt'));
        TempFile.CreateOutStream(OutStream);
        OutStream.WriteText(TextToLog);
        TempFile.Close;
    end;
}

