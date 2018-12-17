codeunit 1297 "Http Web Request Mgt."
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        HttpWebRequest: DotNet HttpWebRequest;
        TraceLogEnabled: Boolean;
        InvalidUrlErr: Label 'The URL is not valid.';
        NonSecureUrlErr: Label 'The URL is not secure.';
        GlobalSkipCheckHttps: Boolean;
        GlobalProgressDialogEnabled: Boolean;
        InternalErr: Label 'The remote service has returned the following error message:\\';
        NoCookieForYouErr: Label 'The web request has no cookies.';

    procedure GetResponse(var ResponseInStream: InStream;var HttpStatusCode: DotNet HttpStatusCode;var ResponseHeaders: DotNet NameValueCollection): Boolean
    var
        WebRequestHelper: Codeunit "Web Request Helper";
        HttpWebResponse: DotNet HttpWebResponse;
    begin
        exit(WebRequestHelper.GetWebResponse(HttpWebRequest,HttpWebResponse,ResponseInStream,HttpStatusCode,
            ResponseHeaders,GlobalProgressDialogEnabled));
    end;

    procedure GetResponseStream(var ResponseInStream: InStream): Boolean
    var
        WebRequestHelper: Codeunit "Web Request Helper";
        HttpWebResponse: DotNet HttpWebResponse;
        HttpStatusCode: DotNet HttpStatusCode;
        ResponseHeaders: DotNet NameValueCollection;
    begin
        exit(WebRequestHelper.GetWebResponse(HttpWebRequest,HttpWebResponse,ResponseInStream,HttpStatusCode,
            ResponseHeaders,GlobalProgressDialogEnabled));
    end;

    [TryFunction]
    procedure ProcessFaultResponse(SupportInfo: Text)
    begin
        ProcessFaultXMLResponse(SupportInfo,'','','');
    end;

    [TryFunction]
    procedure ProcessFaultXMLResponse(SupportInfo: Text;NodePath: Text;Prefix: Text;NameSpace: Text)
    var
        TempReturnTempBlob: Record TempBlob temporary;
        WebRequestHelper: Codeunit "Web Request Helper";
        XMLDOMMgt: Codeunit "XML DOM Management";
        WebException: DotNet WebException;
        XmlDoc: DotNet XmlDocument;
        ResponseInputStream: InStream;
        ErrorText: Text;
        ServiceURL: Text;
    begin
        ErrorText := WebRequestHelper.GetWebResponseError(WebException,ServiceURL);

        if not IsNull(WebException.Response) then begin
          ResponseInputStream := WebException.Response.GetResponseStream;

          TraceLogStreamToTempFile(ResponseInputStream,'WebExceptionResponse',TempReturnTempBlob);

          if NodePath <> '' then
            if TryLoadXMLResponse(ResponseInputStream,XmlDoc) then
              if Prefix = '' then
                ErrorText := XMLDOMMgt.FindNodeText(XmlDoc.DocumentElement,NodePath)
              else
                ErrorText := XMLDOMMgt.FindNodeTextWithNamespace(XmlDoc.DocumentElement,NodePath,Prefix,NameSpace);
        end;

        if ErrorText = '' then
          ErrorText := WebException.Message;

        ErrorText := InternalErr + ErrorText;

        if SupportInfo <> '' then
          ErrorText += '\\' + SupportInfo;

        Error(ErrorText);
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure CheckUrl(Url: Text)
    var
        Uri: DotNet Uri;
        UriKind: DotNet UriKind;
    begin
        if not Uri.TryCreate(Url,UriKind.Absolute,Uri) then
          Error(InvalidUrlErr);

        if not GlobalSkipCheckHttps and not (Uri.Scheme = 'https') then
          Error(NonSecureUrlErr);
    end;

    procedure GetUrl(): Text
    begin
        exit(HttpWebRequest.RequestUri.AbsoluteUri);
    end;

    procedure GetUri(): Text
    begin
        exit(HttpWebRequest.RequestUri.PathAndQuery);
    end;

    procedure GetMethod(): Text
    begin
        exit(HttpWebRequest.Method);
    end;

    local procedure TraceLogStreamToTempFile(var ToLogInStream: InStream;Name: Text;var TraceLogTempBlob: Record TempBlob)
    var
        Trace: Codeunit Trace;
    begin
        if TraceLogEnabled then
          Trace.LogStreamToTempFile(ToLogInStream,Name,TraceLogTempBlob);
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure TryLoadXMLResponse(ResponseInputStream: InStream;var XmlDoc: DotNet XmlDocument)
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
    begin
        XMLDOMManagement.LoadXMLDocumentFromInStream(ResponseInputStream,XmlDoc);
    end;

    [Scope('Personalization')]
    procedure SetTraceLogEnabled(Enabled: Boolean)
    begin
        TraceLogEnabled := Enabled;
    end;

    [Scope('Personalization')]
    procedure DisableUI()
    begin
        GlobalProgressDialogEnabled := false;
    end;

    procedure Initialize(URL: Text)
    var
        PermissionManager: Codeunit "Permission Manager";
    begin
        if not PermissionManager.SoftwareAsAService then
          OnOverrideUrl(URL);

        HttpWebRequest := HttpWebRequest.Create(URL);
        SetDefaults;
    end;

    local procedure SetDefaults()
    var
        CookieContainer: DotNet CookieContainer;
    begin
        HttpWebRequest.Method := 'GET';
        HttpWebRequest.KeepAlive := true;
        HttpWebRequest.AllowAutoRedirect := true;
        HttpWebRequest.UseDefaultCredentials := true;
        HttpWebRequest.Timeout := 60000;
        HttpWebRequest.Accept('application/xml');
        HttpWebRequest.ContentType('application/xml');
        CookieContainer := CookieContainer.CookieContainer;
        HttpWebRequest.CookieContainer := CookieContainer;

        GlobalSkipCheckHttps := true;
        GlobalProgressDialogEnabled := GuiAllowed;
        TraceLogEnabled := true;
    end;

    procedure AddBodyAsText(BodyText: Text)
    var
        Encoding: DotNet Encoding;
    begin
        // Assume UTF8
        AddBodyAsTextWithEncoding(BodyText,Encoding.UTF8);
    end;

    procedure AddBodyAsAsciiText(BodyText: Text)
    var
        Encoding: DotNet Encoding;
    begin
        AddBodyAsTextWithEncoding(BodyText,Encoding.ASCII);
    end;

    local procedure AddBodyAsTextWithEncoding(BodyText: Text;Encoding: DotNet Encoding)
    var
        RequestStr: DotNet Stream;
        StreamWriter: DotNet StreamWriter;
    begin
        RequestStr := HttpWebRequest.GetRequestStream;
        StreamWriter := StreamWriter.StreamWriter(RequestStr,Encoding);
        StreamWriter.Write(BodyText);
        StreamWriter.Flush;
        StreamWriter.Close;
        StreamWriter.Dispose;
    end;

    procedure SetTimeout(NewTimeout: Integer)
    begin
        HttpWebRequest.Timeout := NewTimeout;
    end;

    procedure SetMethod(Method: Text)
    begin
        HttpWebRequest.Method := Method;
    end;

    procedure SetDecompresionMethod(DecompressionMethod: DotNet DecompressionMethods)
    begin
        HttpWebRequest.AutomaticDecompression := DecompressionMethod;
    end;

    procedure SetContentType(ContentType: Text)
    begin
        HttpWebRequest.ContentType := ContentType;
    end;

    procedure SetReturnType(ReturnType: Text)
    begin
        HttpWebRequest.Accept := ReturnType;
    end;

    procedure SetProxy(ProxyUrl: Text)
    var
        WebProxy: DotNet WebProxy;
    begin
        if ProxyUrl = '' then
          exit;

        WebProxy := WebProxy.WebProxy(ProxyUrl);

        HttpWebRequest.Proxy := WebProxy;
    end;

    [Scope('Personalization')]
    procedure SetExpect(expectValue: Boolean)
    begin
        HttpWebRequest.ServicePoint.Expect100Continue := expectValue;
    end;

    procedure SetContentLength(ContentLength: BigInteger)
    begin
        HttpWebRequest.ContentLength := ContentLength;
    end;

    procedure AddSecurityProtocolTls12()
    var
        Convert: DotNet Convert;
        SecurityProtocolType: DotNet SecurityProtocolType;
        SecurityProtocol: Integer;
    begin
        SecurityProtocol := Convert.ToInt32(SecurityProtocolType.Tls12);
        AddSecurityProtocol(SecurityProtocol);
    end;

    local procedure AddSecurityProtocol(SecurityProtocol: Integer)
    var
        TypeHelper: Codeunit "Type Helper";
        Convert: DotNet Convert;
        ServicePointManager: DotNet ServicePointManager;
        CurrentSecurityProtocol: Integer;
    begin
        CurrentSecurityProtocol := Convert.ToInt32(ServicePointManager.SecurityProtocol);
        if TypeHelper.BitwiseAnd(CurrentSecurityProtocol,SecurityProtocol) <> SecurityProtocol then
          ServicePointManager.SecurityProtocol := TypeHelper.BitwiseOr(CurrentSecurityProtocol,SecurityProtocol);
    end;

    procedure AddHeader("Key": Text;Value: Text)
    begin
        HttpWebRequest.Headers.Add(Key,Value);
    end;

    procedure AddBody(BodyFilePath: Text)
    var
        FileManagement: Codeunit "File Management";
        FileStream: DotNet FileStream;
        FileMode: DotNet FileMode;
    begin
        if BodyFilePath = '' then
          exit;

        FileManagement.IsAllowedPath(BodyFilePath,false);

        FileStream := FileStream.FileStream(BodyFilePath,FileMode.Open);
        FileStream.CopyTo(HttpWebRequest.GetRequestStream);
    end;

    procedure AddBodyBlob(var TempBlob: Record TempBlob)
    var
        RequestStr: DotNet Stream;
        BlobStr: InStream;
    begin
        if not TempBlob.Blob.HasValue then
          exit;

        RequestStr := HttpWebRequest.GetRequestStream;
        TempBlob.Blob.CreateInStream(BlobStr);
        CopyStream(RequestStr,BlobStr);
        RequestStr.Flush;
        RequestStr.Close;
        RequestStr.Dispose;
    end;

    [Scope('Personalization')]
    procedure AddBasicAuthentication(BasicUserId: Text;BasicUserPassword: Text)
    var
        Credential: DotNet NetworkCredential;
    begin
        HttpWebRequest.UseDefaultCredentials(false);
        Credential := Credential.NetworkCredential;
        Credential.UserName := BasicUserId;
        Credential.Password := BasicUserPassword;
        HttpWebRequest.Credentials := Credential;
    end;

    procedure SetUserAgent(UserAgent: Text)
    begin
        HttpWebRequest.UserAgent := UserAgent;
    end;

    procedure SetCookie(var Cookie: DotNet Cookie)
    begin
        HttpWebRequest.CookieContainer.Add(Cookie);
    end;

    procedure GetCookie(var Cookie: DotNet Cookie)
    var
        CookieCollection: DotNet CookieCollection;
    begin
        if not HasCookie then
          Error(NoCookieForYouErr);
        CookieCollection := HttpWebRequest.CookieContainer.GetCookies(HttpWebRequest.RequestUri);
        Cookie := CookieCollection.Item(0);
    end;

    procedure HasCookie(): Boolean
    begin
        exit(HttpWebRequest.CookieContainer.Count > 0);
    end;

    [Scope('Personalization')]
    procedure CreateInstream(var InStr: InStream)
    var
        TempBlob: Record TempBlob;
    begin
        TempBlob.Init;
        TempBlob.Blob.CreateInStream(InStr);
    end;

    [IntegrationEvent(false, false)]
    procedure OnOverrideUrl(var Url: Text)
    begin
        // Provides an option to rewrite URL in non SaaS environments.
    end;
}

