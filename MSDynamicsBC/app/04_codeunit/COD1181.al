codeunit 1181 "Prvacy Data Mgmt Excel"
{
    // version NAVW113.00

    TableNo = "Config. Package Table";

    trigger OnRun()
    var
        ReportInbox: Record "Report Inbox";
        TempBlob: Record TempBlob;
        ConfigExcelExchange: Codeunit "Config. Excel Exchange";
        FileManagement: Codeunit "File Management";
        OutStr: OutStream;
        FileName: Text;
    begin
        FileName := FileManagement.ServerTempFileName('.xlsx');
        ConfigExcelExchange.SetFileOnServer(true);
        if ConfigExcelExchange.ExportExcel(FileName,Rec,false,false) then
          if FileManagement.ServerFileExists(FileName) then begin
            FileManagement.BLOBImportFromServerFile(TempBlob,FileName);

            ReportInbox.Init;
            ReportInbox."User ID" := UserId;
            ReportInbox.Validate("Output Type",ReportInbox."Output Type"::Excel);
            ReportInbox.Description := StrSubstNo(PrivacyDataTxt,"Package Code");
            ReportInbox."Report Name" := StrSubstNo(PrivacyDataTxt,"Package Code");
            ReportInbox."Report Output".CreateOutStream(OutStr);
            ReportInbox."Report Output" := TempBlob.Blob;
            ReportInbox."Created Date-Time" := RoundDateTime(CurrentDateTime,60000);
            if not ReportInbox.Insert(true) then
              ReportInbox.Modify(true);

            // IF STRPOS(Rec."Package Code",'*') > 0 THEN BEGIN
            // ConfigPackage.SETRANGE(Code,Rec."Package Code");
            // ConfigPackage.DELETE(TRUE);
            // END;
          end;
    end;

    var
        PrivacyDataTxt: Label 'Privacy Data for %1', Comment='%1=The name of the package code.';
}

