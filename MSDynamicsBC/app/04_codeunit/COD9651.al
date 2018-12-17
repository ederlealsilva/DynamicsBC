codeunit 9651 "Document Report Mgt."
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        NotImplementedErr: Label 'This option is not available.';
        TemplateValidationQst: Label 'The Word layout does not comply with the current report design (for example, fields are missing or the report ID is wrong).\The following errors were detected during the layout validation:\%1\Do you want to continue?';
        TemplateValidationErr: Label 'The Word layout does not comply with the current report design (for example, fields are missing or the report ID is wrong).\The following errors were detected during the document validation:\%1\You must update the layout to match the current report design.';
        AbortWithValidationErr: Label 'The Word layout action has been canceled because of validation errors.';
        TemplateValidationUpdateQst: Label 'The Word layout does not comply with the current report design (for example, fields are missing or the report ID is wrong).\The following errors were detected during the layout validation:\%1\Do you want to run an automatic update?';
        TemplateAfterUpdateValidationErr: Label 'The automatic update could not resolve all the conflicts in the current Word layout. For example, the layout uses fields that are missing in the report design or the report ID is wrong.\The following errors were detected:\%1\You must manually update the layout to match the current report design.';
        UpgradeMessageMsg: Label 'The report upgrade process returned the following log messages:\%1.';
        NoReportLayoutUpgradeRequiredMsg: Label 'The layout upgrade process completed without detecting any required changes in the current application.';
        CompanyInformationPicErr: Label 'The document contains elements that cannot be converted to PDF. This may be caused by missing image data in the document.';
        UnexpectedHexCharacterRegexErr: Label 'hexadecimal value 0x[0-9a-fA-F]*, is an invalid character', Comment='{LOCKED}';
        UnexpectedCharInDataErr: Label 'Cannot create the document because it includes garbled text. Make sure the text is readable and then try again.';
        FileTypeWordTxt: Label 'docx', Locked=true;
        FileTypePdfTxt: Label 'pdf', Locked=true;
        FileTypeHtmlTxt: Label 'html', Locked=true;
        NoOutputErr: Label 'No data exists for the specified report filters.';
        ClientTypeManagement: Codeunit ClientTypeManagement;

    procedure MergeWordLayout(ReportID: Integer;ReportAction: Option SaveAsPdf,SaveAsWord,SaveAsExcel,Preview,Print,SaveAsHtml;InStrXmlData: InStream;FileName: Text)
    var
        ReportLayoutSelection: Record "Report Layout Selection";
        CustomReportLayout: Record "Custom Report Layout";
        InTempBlob: Record TempBlob;
        OutTempBlob: Record TempBlob;
        FileMgt: Codeunit "File Management";
        TypeHelper: Codeunit "Type Helper";
        InStrWordDoc: InStream;
        OutStrWordDoc: OutStream;
        CustomLayoutCode: Code[20];
        CurrentFileType: Text;
        PrinterName: Text;
        VerifyXmlHasData: Boolean;
        Handled: Boolean;
    begin
        if ReportAction = ReportAction::Print then
          PrinterName := FileName;

        OutTempBlob.Blob.CreateOutStream(OutStrWordDoc);
        OnBeforeMergeDocument(ReportID,ReportAction,InStrXmlData,PrinterName,OutStrWordDoc,Handled,FileName = '');
        if Handled then begin
          if (FileName <> '') and OutTempBlob.Blob.HasValue then
            OutTempBlob.Blob.Export(FileName);
          exit;
        end;

        // Temporarily selected layout for Design-time report execution?
        if ReportLayoutSelection.GetTempLayoutSelected <> '' then
          CustomLayoutCode := ReportLayoutSelection.GetTempLayoutSelected
        else  // Normal selection
          if ReportLayoutSelection.Get(ReportID,CompanyName) and
             (ReportLayoutSelection.Type = ReportLayoutSelection.Type::"Custom Layout")
          then
            CustomLayoutCode := ReportLayoutSelection."Custom Report Layout Code";

        if CustomLayoutCode <> '' then
          if not CustomReportLayout.Get(CustomLayoutCode) then
            CustomLayoutCode := '';

        if CustomLayoutCode = '' then
          REPORT.WordLayout(ReportID,InStrWordDoc)
        else begin
          ValidateAndUpdateWordLayoutOnRecord(CustomReportLayout);
          CustomReportLayout.GetLayoutBlob(InTempBlob);
          InTempBlob.Blob.CreateInStream(InStrWordDoc);
          ValidateWordLayoutCheckOnly(ReportID,InStrWordDoc);
        end;

        // By default - throw an error in case of empty dataset
        VerifyXmlHasData := true;
        OnBeforeMergeWordDocument(VerifyXmlHasData);
        if VerifyXmlHasData then
          VerifyXmlContainsDataset(InStrXmlData);

        if not TryXmlMergeWordDocument(InStrWordDoc,InStrXmlData,OutStrWordDoc) then begin
          if TypeHelper.IsMatch(GetLastErrorText,UnexpectedHexCharacterRegexErr) then
            Error(UnexpectedCharInDataErr);

          Error(GetLastErrorText);
        end;

        Commit;
        OnAfterMergeWordDocument(ReportID,InStrXmlData,OutTempBlob);

        CurrentFileType := '';
        case ReportAction of
          ReportAction::SaveAsWord:
            CurrentFileType := FileTypeWordTxt;
          ReportAction::SaveAsPdf:
            begin
              CurrentFileType := FileTypePdfTxt;
              ConvertToPdf(OutTempBlob);
            end;
          ReportAction::SaveAsHtml:
            begin
              CurrentFileType := FileTypeHtmlTxt;
              ConvertToHtml(OutTempBlob);
            end;
          ReportAction::SaveAsExcel:
            Error(NotImplementedErr);
          ReportAction::Print:
            PrintWordDoc(ReportID,OutTempBlob,PrinterName,true);
          ReportAction::Preview:
            FileMgt.BLOBExport(OutTempBlob,UserFileName(ReportID,CurrentFileType),true);
        end;

        // Export the file to the client of the action generates an output object in which case currentFileType is non-empty.
        if CurrentFileType <> '' then
          if FileName = '' then
            FileMgt.BLOBExport(OutTempBlob,UserFileName(ReportID,CurrentFileType),true)
          else
            // Dont' use FileMgt.BLOBExportToServerFile. It will fail if run through
            // CodeUnit 8800, as the filename will exist in a temp folder.
            OutTempBlob.Blob.Export(FileName);
    end;

    [TryFunction]
    local procedure TryXmlMergeWordDocument(var InStrWordDoc: InStream;var InStrXmlData: InStream;var OutStrWordDoc: OutStream)
    var
        NAVWordXMLMerger: DotNet WordReportManager;
    begin
        OutStrWordDoc := NAVWordXMLMerger.MergeWordDocument(InStrWordDoc,InStrXmlData,OutStrWordDoc) ;
    end;

    [Scope('Personalization')]
    procedure ValidateWordLayout(ReportID: Integer;DocumentStream: InStream;useConfirm: Boolean;updateContext: Boolean): Boolean
    var
        NAVWordXMLMerger: DotNet WordReportManager;
        ValidationErrors: Text;
        ValidationErrorFormat: Text;
    begin
        ValidationErrors := NAVWordXMLMerger.ValidateWordDocumentTemplate(DocumentStream,REPORT.WordXmlPart(ReportID,true));
        if ValidationErrors <> '' then begin
          if useConfirm then begin
            if not Confirm(TemplateValidationQst,false,ValidationErrors) then
              Error(AbortWithValidationErr);
          end else begin
            if updateContext then
              ValidationErrorFormat := TemplateAfterUpdateValidationErr
            else
              ValidationErrorFormat := TemplateValidationErr;

            Error(ValidationErrorFormat,ValidationErrors);
          end;

          exit(false);
        end;
        exit(true);
    end;

    local procedure ValidateWordLayoutCheckOnly(ReportID: Integer;DocumentStream: InStream)
    var
        NAVWordXMLMerger: DotNet WordReportManager;
        ValidationErrors: Text;
        ValidationErrorFormat: Text;
    begin
        ValidationErrors := NAVWordXMLMerger.ValidateWordDocumentTemplate(DocumentStream,REPORT.WordXmlPart(ReportID,true));
        if ValidationErrors <> '' then begin
          ValidationErrorFormat := TemplateAfterUpdateValidationErr;
          Message(ValidationErrorFormat,ValidationErrors);
        end;
    end;

    local procedure ValidateAndUpdateWordLayoutOnRecord(CustomReportLayout: Record "Custom Report Layout"): Boolean
    var
        TempBlob: Record TempBlob;
        NAVWordXMLMerger: DotNet WordReportManager;
        DocumentStream: InStream;
        ValidationErrors: Text;
    begin
        CustomReportLayout.TestField(Type,CustomReportLayout.Type::Word);
        CustomReportLayout.GetLayoutBlob(TempBlob);
        TempBlob.Blob.CreateInStream(DocumentStream);
        NAVWordXMLMerger := NAVWordXMLMerger.WordReportManager;

        ValidationErrors :=
          NAVWordXMLMerger.ValidateWordDocumentTemplate(DocumentStream,REPORT.WordXmlPart(CustomReportLayout."Report ID",true));
        if ValidationErrors <> '' then begin
          if Confirm(TemplateValidationUpdateQst,false,ValidationErrors) then begin
            ValidationErrors := CustomReportLayout.TryUpdateLayout(false);
            Commit;
            exit(true);
          end;
          Error(TemplateValidationErr,ValidationErrors);
        end;
        exit(false);
    end;

    [Scope('Personalization')]
    procedure TryUpdateWordLayout(DocumentStream: InStream;var UpdateStream: OutStream;CachedCustomPart: Text;CurrentCustomPart: Text): Text
    var
        NAVWordXMLMerger: DotNet WordReportManager;
    begin
        NAVWordXMLMerger := NAVWordXMLMerger.WordReportManager;
        NAVWordXMLMerger.UpdateWordDocumentLayout(DocumentStream,UpdateStream,CachedCustomPart,CurrentCustomPart,true);
        exit(NAVWordXMLMerger.LastUpdateError);
    end;

    [Scope('Personalization')]
    procedure TryUpdateRdlcLayout(reportId: Integer;RdlcStream: InStream;RdlcUpdatedStream: OutStream;CachedCustomPart: Text;CurrentCustomPart: Text;IgnoreDelete: Boolean): Text
    var
        NAVWordXMLMerger: DotNet RdlcReportManager;
    begin
        exit(NAVWordXMLMerger.TryUpdateRdlcLayout(reportId,RdlcStream,RdlcUpdatedStream,
            CachedCustomPart,CurrentCustomPart,IgnoreDelete));
    end;

    [Scope('Personalization')]
    procedure NewWordLayout(ReportId: Integer;var DocumentStream: OutStream)
    var
        NAVWordXmlMerger: DotNet WordReportManager;
    begin
        NAVWordXmlMerger.NewWordDocumentLayout(DocumentStream,REPORT.WordXmlPart(ReportId));
    end;

    local procedure ConvertToPdf(var TempBlob: Record TempBlob)
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        if not TypeHelper.TryConvertWordBlobToPdf(TempBlob) then
          Error(CompanyInformationPicErr);
    end;

    local procedure ConvertToHtml(var TempBlob: Record TempBlob)
    var
        TempBlobHtml: Record TempBlob;
        InStreamWordDoc: InStream;
        OutStreamHtmlDoc: OutStream;
        PdfWriter: DotNet WordToPdf;
    begin
        TempBlob.Blob.CreateInStream(InStreamWordDoc);
        TempBlobHtml.Blob.CreateOutStream(OutStreamHtmlDoc);
        PdfWriter.ConvertToHtml(InStreamWordDoc,OutStreamHtmlDoc);
        TempBlob.Blob := TempBlobHtml.Blob;
    end;

    local procedure PrintWordDoc(ReportID: Integer;var TempBlob: Record TempBlob;PrinterName: Text;Collate: Boolean)
    var
        FileMgt: Codeunit "File Management";
    begin
        if FileMgt.IsWindowsClient then
          PrintWordDocInWord(ReportID,TempBlob,PrinterName,Collate,1)
        else
          if FileMgt.IsWebOrDeviceClient then begin
            ConvertToPdf(TempBlob);
            FileMgt.BLOBExport(TempBlob,UserFileName(ReportID,FileTypePdfTxt),true);
          end else
            PrintWordDocOnServer(TempBlob,PrinterName,Collate);
    end;

    local procedure PrintWordDocInWord(ReportID: Integer;TempBlob: Record TempBlob;PrinterName: Text;Collate: Boolean;Copies: Integer)
    var
        FileMgt: Codeunit "File Management";
        [RunOnClient]
        WordApplication: DotNet ApplicationClass;
        [RunOnClient]
        WordDocument: DotNet Document;
        [RunOnClient]
        WordHelper: DotNet WordHelper;
        FileName: Text;
        T0: DateTime;
    begin
        if GetWordApplication(WordApplication) and not IsNull(WordApplication) then begin
          FileName := StrSubstNo('%1.docx',CreateGuid);
          FileName := FileMgt.BLOBExport(TempBlob,FileName,false);

          if PrinterName = '' then
            if not SelectPrinter(PrinterName,Collate,Copies) then
              exit;

          WordDocument := WordHelper.CallOpen(WordApplication,FileName,false,false);
          WordHelper.CallPrintOut(WordDocument,PrinterName,Collate,Copies);

          T0 := CurrentDateTime;
          while (WordApplication.BackgroundPrintingStatus > 0) and (CurrentDateTime < T0 + 180000) do
            Sleep(250);
          WordHelper.CallQuit(WordApplication,false);
          if DeleteClientFile(FileName) then;
        end else begin
          if (PrinterName <> '') and IsValidPrinter(PrinterName) then
            PrintWordDocOnServer(TempBlob,PrinterName,Collate) // Don't print on server if the printer has not been setup.
          else
            FileMgt.BLOBExport(TempBlob,UserFileName(ReportID,FileTypeWordTxt),true);
        end;
    end;

    local procedure SelectPrinter(var PrinterName: Text;var Collate: Boolean;var Copies: Integer): Boolean
    var
        [RunOnClient]
        DotNetPrintDialog: DotNet PrintDialog;
        [RunOnClient]
        DotNetDialogResult: DotNet DialogResult;
        [RunOnClient]
        DotNetPrinterSettings: DotNet PrinterSettings;
        PrintDialogResult: Integer;
    begin
        DotNetPrinterSettings := DotNetPrinterSettings.PrinterSettings;
        DotNetPrintDialog := DotNetPrintDialog.PrintDialog;

        DotNetPrintDialog.ShowNetwork := true;
        DotNetDialogResult := DotNetPrintDialog.ShowDialog;
        PrintDialogResult := DotNetDialogResult;

        // 1 - means OK
        // 6 - means YES
        if not (PrintDialogResult in [1,6]) then
          exit(false);

        DotNetPrinterSettings := DotNetPrintDialog.PrinterSettings;
        PrinterName := DotNetPrinterSettings.PrinterName;
        Collate := DotNetPrinterSettings.Collate;
        Copies := DotNetPrinterSettings.Copies;

        exit(true);
    end;

    [TryFunction]
    local procedure DeleteClientFile(FileName: Text)
    var
        FileMgt: Codeunit "File Management";
    begin
        FileMgt.DeleteClientFile(FileName);
    end;

    local procedure IsValidPrinter(PrinterName: Text): Boolean
    var
        Printer: Record Printer;
    begin
        Printer.SetFilter(Name,PrinterName);
        Printer.FindFirst;
        exit(not Printer.IsEmpty);
    end;

    [TryFunction]
    local procedure GetWordApplication(var WordApplication: DotNet ApplicationClass)
    begin
        WordApplication := WordApplication.ApplicationClass;
    end;

    local procedure PrintWordDocOnServer(TempBlob: Record TempBlob;PrinterName: Text;Collate: Boolean)
    var
        PdfWriter: DotNet WordToPdf;
        InStreamWordDoc: InStream;
    begin
        TempBlob.Blob.CreateInStream(InStreamWordDoc);
        PdfWriter.PrintWordDoc(InStreamWordDoc,PrinterName,Collate);
    end;

    local procedure UserFileName(ReportID: Integer;fileExtension: Text): Text
    var
        ReportMetadata: Record "Report Metadata";
        FileManagement: Codeunit "File Management";
    begin
        ReportMetadata.Get(ReportID);
        if fileExtension = '' then
          fileExtension := FileTypeWordTxt;

        exit(FileManagement.GetSafeFileName(ReportMetadata.Caption) + '.' + fileExtension);
    end;

    procedure ApplyUpgradeToReports(var ReportUpgradeCollection: DotNet ReportUpgradeCollection;testOnly: Boolean): Boolean
    var
        CustomReportLayout: Record "Custom Report Layout";
        ReportUpgrade: DotNet ReportUpgradeSet;
        ReportChangeLogCollection: DotNet IReportChangeLogCollection;
    begin
        foreach ReportUpgrade in ReportUpgradeCollection do begin
          CustomReportLayout.SetFilter("Report ID",Format(ReportUpgrade.ReportId));
          if CustomReportLayout.Find('-') then
            repeat
              CustomReportLayout.ApplyUpgrade(ReportUpgrade,ReportChangeLogCollection,testOnly);
            until CustomReportLayout.Next = 0;
        end;

        if IsNull(ReportChangeLogCollection) then begin // Don't break upgrade process with user information
          if (ClientTypeManagement.GetCurrentClientType <> CLIENTTYPE::Background) and
             (ClientTypeManagement.GetCurrentClientType <> CLIENTTYPE::Management)
          then
            Message(NoReportLayoutUpgradeRequiredMsg);

          exit(false);
        end;

        ProcessUpgradeLog(ReportChangeLogCollection);
        exit(ReportChangeLogCollection.Count > 0);
    end;

    [Scope('Personalization')]
    procedure CalculateUpgradeChangeSet(var ReportUpgradeCollection: DotNet ReportUpgradeCollection)
    var
        CustomReportLayout: Record "Custom Report Layout";
        ReportUpgradeSet: DotNet IReportUpgradeSet;
    begin
        if CustomReportLayout.Find('-') then
          repeat
            ReportUpgradeSet := ReportUpgradeCollection.AddReport(CustomReportLayout."Report ID"); // runtime will load the current XmlPart from metadata
            if not IsNull(ReportUpgradeSet) then
              ReportUpgradeSet.CalculateAutoChangeSet(CustomReportLayout.GetCustomXmlPart);
          until CustomReportLayout.Next <> 1;
    end;

    local procedure ProcessUpgradeLog(var ReportChangeLogCollection: DotNet IReportChangeLogCollection)
    var
        ReportLayoutUpdateLog: Codeunit "Report Layout Update Log";
    begin
        if IsNull(ReportChangeLogCollection) then
          exit;

        if (ClientTypeManagement.GetCurrentClientType <> CLIENTTYPE::Background) and
           (ClientTypeManagement.GetCurrentClientType <> CLIENTTYPE::Management)
        then
          ReportLayoutUpdateLog.ViewLog(ReportChangeLogCollection)
        else
          Message(UpgradeMessageMsg,Format(ReportChangeLogCollection));
    end;

    procedure BulkUpgrade(testMode: Boolean)
    var
        ReportUpgradeCollection: DotNet ReportUpgradeCollection;
    begin
        ReportUpgradeCollection := ReportUpgradeCollection.ReportUpgradeCollection;
        CalculateUpgradeChangeSet(ReportUpgradeCollection);
        ApplyUpgradeToReports(ReportUpgradeCollection,testMode);
    end;

    local procedure VerifyXmlContainsDataset(XmlData: InStream)
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        XmlNode: DotNet XmlNode;
    begin
        if XMLDOMManagement.LoadXMLNodeFromInStream(XmlData,XmlNode) and
           XMLDOMManagement.FindNode(XmlNode,'DataItems',XmlNode)
        then
          if XmlNode.ChildNodes.Count = 0 then
            Error(NoOutputErr);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterMergeWordDocument(ReportID: Integer;InStrXmlData: InStream;var OutTempBlob: Record TempBlob)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeMergeDocument(ReportID: Integer;ReportAction: Option SaveAsPdf,SaveAsWord,SaveAsExcel,Preview,Print,SaveAsHtml;InStrXmlData: InStream;PrinterName: Text;OutStream: OutStream;var Handled: Boolean;IsFileNameBlank: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeMergeWordDocument(var VerifyXmlHasData: Boolean)
    begin
    end;
}

