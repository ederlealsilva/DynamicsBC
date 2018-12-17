codeunit 248 "VAT Lookup Ext. Data Hndl"
{
    // version NAVW113.00

    Permissions = TableData "VAT Registration Log"=rimd;
    TableNo = "VAT Registration Log";

    trigger OnRun()
    begin
        VATRegistrationLog := Rec;

        LookupVatRegistrationFromWebService(true);

        Rec := VATRegistrationLog;
    end;

    var
        NamespaceTxt: Label 'urn:ec.europa.eu:taxud:vies:services:checkVat:types', Locked=true;
        VATRegistrationLog: Record "VAT Registration Log";
        VATRegistrationLogMgt: Codeunit "VAT Registration Log Mgt.";
        VatRegNrValidationWebServiceURLTxt: Label 'http://ec.europa.eu/taxation_customs/vies/services/checkVatService', Locked=true;
        VATRegistrationURL: Text;

    local procedure LookupVatRegistrationFromWebService(ShowErrors: Boolean)
    var
        RequestBodyTempBlob: Record TempBlob;
    begin
        RequestBodyTempBlob.Init;

        SendRequestToVatRegistrationService(RequestBodyTempBlob,ShowErrors);

        InsertLogEntry(RequestBodyTempBlob);

        Commit;
    end;

    local procedure SendRequestToVatRegistrationService(var BodyTempBlob: Record TempBlob;ShowErrors: Boolean)
    var
        VATRegNoSrvConfig: Record "VAT Reg. No. Srv Config";
        SOAPWebServiceRequestMgt: Codeunit "SOAP Web Service Request Mgt.";
        ResponseInStream: InStream;
        InStream: InStream;
        ResponseOutStream: OutStream;
    begin
        PrepareSOAPRequestBody(BodyTempBlob);

        BodyTempBlob.Blob.CreateInStream(InStream);
        VATRegistrationURL := VATRegNoSrvConfig.GetVATRegNoURL;
        SOAPWebServiceRequestMgt.SetGlobals(InStream,VATRegistrationURL,'','');
        SOAPWebServiceRequestMgt.DisableHttpsCheck;
        SOAPWebServiceRequestMgt.SetTimeout(60000);

        if SOAPWebServiceRequestMgt.SendRequestToWebService then begin
          SOAPWebServiceRequestMgt.GetResponseContent(ResponseInStream);

          BodyTempBlob.Blob.CreateOutStream(ResponseOutStream);
          CopyStream(ResponseOutStream,ResponseInStream);
        end else
          if ShowErrors then
            SOAPWebServiceRequestMgt.ProcessFaultResponse('');
    end;

    local procedure PrepareSOAPRequestBody(var BodyTempBlob: Record TempBlob)
    var
        XMLDOMMgt: Codeunit "XML DOM Management";
        BodyContentInputStream: InStream;
        BodyContentOutputStream: OutStream;
        BodyContentXmlDoc: DotNet XmlDocument;
        EnvelopeXmlNode: DotNet XmlNode;
        CreatedXmlNode: DotNet XmlNode;
    begin
        BodyTempBlob.Blob.CreateInStream(BodyContentInputStream);
        BodyContentXmlDoc := BodyContentXmlDoc.XmlDocument;

        XMLDOMMgt.AddRootElementWithPrefix(BodyContentXmlDoc,'checkVatApprox','',NamespaceTxt,EnvelopeXmlNode);
        XMLDOMMgt.AddElement(EnvelopeXmlNode,'countryCode',VATRegistrationLog.GetCountryCode,NamespaceTxt,CreatedXmlNode);
        XMLDOMMgt.AddElement(EnvelopeXmlNode,'vatNumber',VATRegistrationLog.GetVATRegNo,NamespaceTxt,CreatedXmlNode);

        Clear(BodyTempBlob.Blob);
        BodyTempBlob.Blob.CreateOutStream(BodyContentOutputStream);
        BodyContentXmlDoc.Save(BodyContentOutputStream);
    end;

    local procedure InsertLogEntry(ResponseBodyTempBlob: Record TempBlob)
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        XMLDocOut: DotNet XmlDocument;
        InStream: InStream;
    begin
        ResponseBodyTempBlob.Blob.CreateInStream(InStream);
        XMLDOMManagement.LoadXMLDocumentFromInStream(InStream,XMLDocOut);

        VATRegistrationLogMgt.LogVerification(VATRegistrationLog,XMLDocOut,NamespaceTxt);
    end;

    [Scope('Personalization')]
    procedure GetVATRegNrValidationWebServiceURL(): Text[250]
    begin
        exit(VatRegNrValidationWebServiceURLTxt);
    end;
}

