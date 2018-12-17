codeunit 1288 "Imp. Bank Conv. Ext. Data Hndl"
{
    // version NAVW113.00

    Permissions = TableData "Bank Data Conv. Service Setup"=r,
                  TableData "Service Password"=r;
    TableNo = "Data Exch.";

    trigger OnRun()
    var
        TempBankStmtTempBlob: Record TempBlob temporary;
        FileMgt: Codeunit "File Management";
    begin
        "File Name" :=
          CopyStr(FileMgt.BLOBImportWithFilter(TempBankStmtTempBlob,ImportBankStmtTxt,'',FileFilterTxt,FileFilterExtensionTxt),1,250);
        if "File Name" = '' then
          exit;

        ConvertBankStatementToFormat(TempBankStmtTempBlob,Rec);
    end;

    var
        NoRequestBodyErr: Label 'The request body is not set.';
        FileFilterTxt: Label 'All Files(*.*)|*.*|XML Files(*.xml)|*.xml|Text Files(*.txt;*.csv;*.asc)|*.txt;*.csv;*.asc';
        FileFilterExtensionTxt: Label 'txt,csv,asc,xml', Locked=true;
        FinstaNotCollectedErr: Label 'The bank data conversion service has not returned any statement transactions.\\For more information, go to %1.';
        ResponseNodeTxt: Label 'reportExportResponse', Locked=true;
        ImportBankStmtTxt: Label 'Select a file to import.';
        BankDataConvServSysErr: Label 'The bank data conversion service has returned the following error message:';
        AddnlInfoTxt: Label 'For more information, go to %1.';
        BankDataConvServMgt: Codeunit "Bank Data Conv. Serv. Mgt.";

    procedure ConvertBankStatementToFormat(var TempBankStatementTempBlob: Record TempBlob temporary;var DataExch: Record "Data Exch.")
    var
        TempResultTempBlob: Record TempBlob temporary;
    begin
        SendDataToConversionService(TempResultTempBlob,TempBankStatementTempBlob);
        DataExch."File Content" := TempResultTempBlob.Blob;
    end;

    local procedure SendDataToConversionService(var TempStatementTempBlob: Record TempBlob temporary;var TempBodyTempBlob: Record TempBlob temporary)
    var
        BankDataConvServiceSetup: Record "Bank Data Conv. Service Setup";
        SOAPWebServiceRequestMgt: Codeunit "SOAP Web Service Request Mgt.";
        ResponseInStream: InStream;
        InStream: InStream;
    begin
        BankDataConvServMgt.CheckCredentials;

        if not TempBodyTempBlob.Blob.HasValue then
          Error(NoRequestBodyErr);

        PrepareSOAPRequestBody(TempBodyTempBlob);

        BankDataConvServiceSetup.Get;

        TempBodyTempBlob.Blob.CreateInStream(InStream);

        SOAPWebServiceRequestMgt.SetGlobals(InStream,
          BankDataConvServiceSetup."Service URL",BankDataConvServiceSetup.GetUserName,BankDataConvServiceSetup.GetPassword);

        if not SOAPWebServiceRequestMgt.SendRequestToWebService then
          SOAPWebServiceRequestMgt.ProcessFaultResponse(StrSubstNo(AddnlInfoTxt,BankDataConvServiceSetup."Support URL"));

        SOAPWebServiceRequestMgt.GetResponseContent(ResponseInStream);

        CheckIfErrorsOccurred(ResponseInStream);

        ReadContentFromResponse(TempStatementTempBlob,ResponseInStream);
    end;

    local procedure PrepareSOAPRequestBody(var TempBodyTempBlob: Record TempBlob temporary)
    var
        XMLDOMMgt: Codeunit "XML DOM Management";
        BodyContentOutputStream: OutStream;
        BodyContentXmlDoc: DotNet XmlDocument;
        EnvelopeXmlNode: DotNet XmlNode;
        HeaderXmlNode: DotNet XmlNode;
        PackXmlNode: DotNet XmlNode;
        DataXmlNode: DotNet XmlNode;
        MsgTypeXmlNode: DotNet XmlNode;
    begin
        BodyContentXmlDoc := BodyContentXmlDoc.XmlDocument;

        with XMLDOMMgt do begin
          AddRootElementWithPrefix(BodyContentXmlDoc,'reportExport','',BankDataConvServMgt.GetNamespace,EnvelopeXmlNode);

          AddElementWithPrefix(EnvelopeXmlNode,'amcreportreq','','','',HeaderXmlNode);
          AddAttribute(HeaderXmlNode,'xmlns','');

          AddElementWithPrefix(HeaderXmlNode,'pack','','','',PackXmlNode);

          AddNode(PackXmlNode,'journalnumber',DelChr(LowerCase(Format(CreateGuid)),'=','{}'));
          AddElementWithPrefix(PackXmlNode,'data',EncodeBankStatementFile(TempBodyTempBlob),'','',DataXmlNode);

          AddElementWithPrefix(EnvelopeXmlNode,'messagetype','finsta','','',MsgTypeXmlNode);
        end;

        Clear(TempBodyTempBlob.Blob);
        TempBodyTempBlob.Blob.CreateOutStream(BodyContentOutputStream);
        BodyContentXmlDoc.Save(BodyContentOutputStream);
    end;

    local procedure EncodeBankStatementFile(TempBodyTempBlob: Record TempBlob temporary): Text
    var
        FileMgt: Codeunit "File Management";
        Convert: DotNet Convert;
        File: DotNet File;
        FileName: Text;
    begin
        FileName := FileMgt.ServerTempFileName('txt');
        FileMgt.IsAllowedPath(FileName,false);
        FileMgt.BLOBExportToServerFile(TempBodyTempBlob,FileName);
        exit(Convert.ToBase64String(File.ReadAllBytes(FileName)));
    end;

    local procedure CheckIfErrorsOccurred(var ResponseInStream: InStream)
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        ResponseXmlDoc: DotNet XmlDocument;
    begin
        XMLDOMManagement.LoadXMLDocumentFromInStream(ResponseInStream,ResponseXmlDoc);

        if ResponseHasErrors(ResponseXmlDoc) then
          DisplayErrorFromResponse(ResponseXmlDoc);
    end;

    local procedure ResponseHasErrors(ResponseXmlDoc: DotNet XmlDocument): Boolean
    var
        XMLDOMMgt: Codeunit "XML DOM Management";
        XmlNode: DotNet XmlNode;
    begin
        exit(XMLDOMMgt.FindNodeWithNamespace(ResponseXmlDoc.DocumentElement,
            BankDataConvServMgt.GetErrorXPath(ResponseNodeTxt),'amc',BankDataConvServMgt.GetNamespace,XmlNode));
    end;

    local procedure DisplayErrorFromResponse(ResponseXmlDoc: DotNet XmlDocument)
    var
        XMLDOMMgt: Codeunit "XML DOM Management";
        XMLNodeList: DotNet XmlNodeList;
        Found: Boolean;
        ErrorText: Text;
        i: Integer;
    begin
        Found := XMLDOMMgt.FindNodesWithNamespace(ResponseXmlDoc.DocumentElement,
            BankDataConvServMgt.GetErrorXPath(ResponseNodeTxt),'amc',BankDataConvServMgt.GetNamespace,XMLNodeList);
        if Found then begin
          ErrorText := BankDataConvServSysErr;
          for i := 1 to XMLNodeList.Count do
            ErrorText += '\\' + XMLDOMMgt.FindNodeText(XMLNodeList.Item(i - 1),'text') + '\' +
              XMLDOMMgt.FindNodeText(XMLNodeList.Item(i - 1),'hinttext') + '\\' +
              StrSubstNo(AddnlInfoTxt,BankDataConvServMgt.GetSupportURL(XMLNodeList.Item(i - 1)));

          Error(ErrorText);
        end;
    end;

    local procedure ReadContentFromResponse(var TempStatementTempBlob: Record TempBlob temporary;ResponseInStream: InStream)
    var
        XMLDOMMgt: Codeunit "XML DOM Management";
        FinstaXmlNode: DotNet XmlNode;
        ResponseXmlDoc: DotNet XmlDocument;
        ResponseOutStream: OutStream;
        Found: Boolean;
    begin
        XMLDOMMgt.LoadXMLDocumentFromInStream(ResponseInStream,ResponseXmlDoc);

        Found := XMLDOMMgt.FindNodeWithNamespace(ResponseXmlDoc.DocumentElement,
            BankDataConvServMgt.GetFinstaXPath(ResponseNodeTxt),'amc',BankDataConvServMgt.GetNamespace,FinstaXmlNode);
        if not Found then
          Error(FinstaNotCollectedErr,BankDataConvServMgt.GetSupportURL(FinstaXmlNode));

        TempStatementTempBlob.Blob.CreateOutStream(ResponseOutStream);
        CopyStream(ResponseOutStream,ResponseInStream);
    end;
}

