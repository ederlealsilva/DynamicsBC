table 747 "VAT Report Archive"
{
    // version NAVW113.00

    Caption = 'VAT Report Archive';
    Permissions = TableData "VAT Report Archive"=rimd;

    fields
    {
        field(1;"VAT Report Type";Option)
        {
            Caption = 'VAT Report Type';
            OptionCaption = 'EC Sales List,VAT Return';
            OptionMembers = "EC Sales List","VAT Return";
        }
        field(2;"VAT Report No.";Code[20])
        {
            Caption = 'VAT Report No.';
            TableRelation = "VAT Report Header"."No.";
        }
        field(4;"Submitted By";Code[50])
        {
            Caption = 'Submitted By';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(5;"Submission Message BLOB";BLOB)
        {
            Caption = 'Submission Message BLOB';
        }
        field(6;"Submittion Date";Date)
        {
            Caption = 'Submittion Date';
        }
        field(7;"Response Message BLOB";BLOB)
        {
            Caption = 'Response Message BLOB';
        }
        field(8;"Response Received Date";DateTime)
        {
            Caption = 'Response Received Date';
        }
    }

    keys
    {
        key(Key1;"VAT Report Type","VAT Report No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        FileManagement: Codeunit "File Management";
        NoSubmissionMessageAvailableErr: Label 'The submission message of the report is not available.';
        NoResponseMessageAvailableErr: Label 'The response message of the report is not available.';

    [Scope('Personalization')]
    procedure ArchiveSubmissionMessage(VATReportTypeValue: Option;VATReportNoValue: Code[20];SubmissionMessageTempBlob: Record TempBlob): Boolean
    var
        VATReportArchive: Record "VAT Report Archive";
    begin
        if VATReportNoValue = '' then
          exit(false);
        if not SubmissionMessageTempBlob.Blob.HasValue then
          exit(false);
        if VATReportArchive.Get(VATReportTypeValue,VATReportNoValue) then
          exit(false);

        VATReportArchive.Init;
        VATReportArchive."VAT Report No." := VATReportNoValue;
        VATReportArchive."VAT Report Type" := VATReportTypeValue;
        VATReportArchive."Submitted By" := UserId;
        VATReportArchive."Submittion Date" := Today;
        VATReportArchive."Submission Message BLOB" := SubmissionMessageTempBlob.Blob;
        VATReportArchive.Insert(true);
        exit(true);
    end;

    [Scope('Personalization')]
    procedure ArchiveResponseMessage(VATReportTypeValue: Option;VATReportNoValue: Code[20];ResponseMessageTempBlob: Record TempBlob): Boolean
    var
        VATReportArchive: Record "VAT Report Archive";
    begin
        if not VATReportArchive.Get(VATReportTypeValue,VATReportNoValue) then
          exit(false);
        if not ResponseMessageTempBlob.Blob.HasValue then
          exit(false);

        VATReportArchive."Response Received Date" := CurrentDateTime;
        VATReportArchive."Response Message BLOB" := ResponseMessageTempBlob.Blob;
        VATReportArchive.Modify(true);

        exit(true);
    end;

    [Scope('Personalization')]
    procedure DownloadSubmissionMessage(VATReportTypeValue: Option;VATReportNoValue: Code[20])
    var
        VATReportArchive: Record "VAT Report Archive";
        TempBlob: Record TempBlob;
        ServerFileName: Text;
        ZipFileName: Text[250];
    begin
        if not VATReportArchive.Get(VATReportTypeValue,VATReportNoValue) then
          Error(NoSubmissionMessageAvailableErr);

        if not VATReportArchive."Submission Message BLOB".HasValue then
          Error(NoSubmissionMessageAvailableErr);

        VATReportArchive.CalcFields("Submission Message BLOB");
        TempBlob.Init;
        TempBlob.Blob := VATReportArchive."Submission Message BLOB";

        ServerFileName := FileManagement.ServerTempFileName('xml');
        FileManagement.BLOBExportToServerFile(TempBlob,ServerFileName);

        ZipFileName := VATReportNoValue + '_Submission.txt';
        DownloadZipFile(ZipFileName,ServerFileName);
        FileManagement.DeleteServerFile(ServerFileName);
    end;

    [Scope('Personalization')]
    procedure DownloadResponseMessage(VATReportTypeValue: Option;VATReportNoValue: Code[20])
    var
        VATReportArchive: Record "VAT Report Archive";
        TempBlob: Record TempBlob;
        ServerFileName: Text;
        ZipFileName: Text[250];
    begin
        if not VATReportArchive.Get(VATReportTypeValue,VATReportNoValue) then
          Error(NoResponseMessageAvailableErr);

        if not VATReportArchive."Response Message BLOB".HasValue then
          Error(NoResponseMessageAvailableErr);

        VATReportArchive.CalcFields("Response Message BLOB");
        TempBlob.Init;
        TempBlob.Blob := VATReportArchive."Response Message BLOB";

        ServerFileName := FileManagement.ServerTempFileName('xml');
        FileManagement.BLOBExportToServerFile(TempBlob,ServerFileName);

        ZipFileName := VATReportNoValue + '_Response.txt';
        DownloadZipFile(ZipFileName,ServerFileName);
        FileManagement.DeleteServerFile(ServerFileName);
    end;

    local procedure DownloadZipFile(ZipFileName: Text[250];ServerFileName: Text)
    var
        ZipArchiveName: Text;
    begin
        ZipArchiveName := FileManagement.CreateZipArchiveObject;
        FileManagement.AddFileToZipArchive(ServerFileName,ZipFileName);

        FileManagement.CloseZipArchive;
        FileManagement.DownloadHandler(ZipArchiveName,'','','',ZipFileName + '.zip');
    end;
}

