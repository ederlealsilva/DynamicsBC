codeunit 403 "Application Launch Management"
{
    // version NAVW113.00


    trigger OnRun()
    begin
        InsertStyleSheets;
    end;

    var
        Text001: Label 'No stylesheet has been imported.';
        Text010: Label 'Microsoft Word';
        Text011: Label 'Microsoft Excel';
        Text012: Label 'Default';
        Text018: Label 'Internet Explorer';
        StyleSheetDirectory: Text[250];
        InsertProgramFailedMsg: Label 'Program ''%1'' has not been successfully registered in the Send-To Programs window due to the following error: ''%2''. %3 cannot send data to ''%1'' until it has been successfully registered.', Comment='%1 is the name of an executable to which we send data, such as Excel, Word or Mail. %2 is the detailed error received from the server when attempting to register this program in the database. %3 - product name';
        InsertStyleSheetFailedMsg: Label 'Cannot import the ''%1'' style sheet due to the following error: ''%2''. You cannot send data that is based on ''%1'' until the style sheet has been successfully imported in the Manage Style Sheets window.', Comment='%1 is a file name of a default or custom stylesheet, such as ''myStyleSheet.xslt''. %2 is the detailed error received from the server whilst importing the stylesheet data to the database.';

    procedure InsertStyleSheets()
    var
        WordID: Text[38];
        ExcelID: Text[38];
        IExploreID: Text[38];
    begin
        WordID := '{000209FF-0000-0000-C000-000000000046}';  // defined in fin.stx
        ExcelID := '{00024500-0000-0000-C000-000000000046}';  // defined in fin.stx
        IExploreID := '{7B2AE575-8FF8-4761-9612-D72C447623B8}';

        InsertSendToProgram(WordID,'WINWORD.EXE','%1',Text010);
        InsertSendToProgram(ExcelID,'EXCEL.EXE','%1',Text011);
        InsertSendToProgram(IExploreID,'IEXPLORE.EXE','%1',Text018);

        // Stylesheets for the Dynamics NAV client
        InsertPageStyleSheet(WordID,Text012,'NavisionFormToWord.xslt',0);
        InsertPageStyleSheet(ExcelID,Text012,'NavisionFormToExcel.xslt',0);
        InsertPageStyleSheet(IExploreID,Text012,'NavisionFormToHTML.xslt',0);
    end;

    local procedure InsertSendToProgram(ProgID: Text[38];ExeName: Text[250];Param: Text[250];Name: Text[250])
    var
        SendToProgram: Record "Send-To Program";
        LogonManagement: Codeunit "Logon Management";
    begin
        if SendToProgram.Get(ProgID) then
          exit;

        SendToProgram.Init;
        SendToProgram."Program ID" := ProgID;
        SendToProgram.Executable := ExeName;
        SendToProgram.Parameter := Param;
        SendToProgram.Name := Name;
        if (not SendToProgram.Insert) and (not LogonManagement.IsLogonInProgress) then
          Message(InsertProgramFailedMsg,ExeName,GetLastErrorText,PRODUCTNAME.Full);
    end;

    local procedure InsertPageStyleSheet(ProgID: Text[38];Name: Text[250];FileName2: Text[100];PageID: Integer)
    var
        StyleSheet: Record "Style Sheet";
        LogonManagement: Codeunit "Logon Management";
        FileName: Text[250];
    begin
        with StyleSheet do begin
          SetCurrentKey("Object Type","Object ID","Program ID");
          SetRange("Object Type","Object Type"::Page);
          SetRange("Object ID",PageID);
          SetRange("Program ID",ProgID);
          if not IsEmpty then
            exit;
        end;

        if StyleSheetDirectory = '' then
          StyleSheetDirectory := ApplicationPath + 'StyleSheets\';
        FileName := CopyStr(StyleSheetDirectory + FileName2,1,MaxStrLen(FileName));

        if Exists(FileName) then begin
          StyleSheet.Init;
          StyleSheet."Style Sheet ID" := CreateGuid;
          StyleSheet."Object ID" := PageID;
          StyleSheet."Object Type" := StyleSheet."Object Type"::Page;
          StyleSheet."Program ID" := ProgID;
          StyleSheet.Name := Name;
          StyleSheet.Date := Today;
          StyleSheet."Style Sheet".Import(FileName);
          if (not StyleSheet.Insert) and (not LogonManagement.IsLogonInProgress) then
            Message(InsertStyleSheetFailedMsg,FileName,GetLastErrorText);
        end;
    end;

    procedure ExportStylesheet(var Stylesheet: Record "Style Sheet")
    var
        TempBlob: Record TempBlob;
        FileMgt: Codeunit "File Management";
    begin
        Stylesheet.CalcFields("Style Sheet");
        if not Stylesheet."Style Sheet".HasValue then
          Error(Text001);

        TempBlob.Blob := Stylesheet."Style Sheet";
        FileMgt.BLOBExport(TempBlob,Stylesheet.Name + '.xslt',true);
    end;

    [Scope('Personalization')]
    procedure SetStyleSheetDirectory(NewStyleSheetDirectory: Text[250])
    begin
        StyleSheetDirectory := NewStyleSheetDirectory;
        if (StyleSheetDirectory <> '') and (StyleSheetDirectory[StrLen(StyleSheetDirectory)] <> '\') then
          StyleSheetDirectory := CopyStr(StyleSheetDirectory + '\',1,MaxStrLen(StyleSheetDirectory));
    end;
}

