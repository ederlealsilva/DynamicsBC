table 407 "Graph Mail Setup"
{
    // version NAVW113.00

    Caption = 'Graph Mail Setup';

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(2;"Refresh Code";BLOB)
        {
            Caption = 'Refresh Code';
        }
        field(3;"Expires On";DateTime)
        {
            Caption = 'Expires On';
        }
        field(4;"Sender Email";Text[250])
        {
            Caption = 'Sender Email';
        }
        field(5;"Sender Name";Text[250])
        {
            Caption = 'Sender Name';
        }
        field(6;Enabled;Boolean)
        {
            Caption = 'Enabled';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        GraphMailCategoryTxt: Label 'AL GraphMail', Locked=true;
        GraphMailSentMsg: Label 'Sent an email', Locked=true;
        GraphMailSetupStartMsg: Label 'Setting up graph mail', Locked=true;
        GraphMailSetupFinishMsg: Label 'Graph mail setup for current user', Locked=true;
        GraphMailGetTokenMsg: Label 'Attempting to get a token using the existing refresh code', Locked=true;
        ClientResourceNameTxt: Label 'MailerResourceId', Locked=true;
        MissingClientInfoErr: Label 'Missing configuration data. Contact a system administrator.';
        InvalidResultErr: Label 'The configuration data is not valid. Contact a system administrator.';
        AuthFailErr: Label 'Could not authenticate while sending mail.';
        NotEnabledErr: Label 'Not enabled.';
        TestEmailSubjectTxt: Label 'Test Email';

    procedure IsEnabled(): Boolean
    var
        GraphMail: Codeunit "Graph Mail";
    begin
        exit(GraphMail.IsEnabled);
    end;

    procedure RenewRefreshToken()
    begin
        GetToken;
    end;

    local procedure GetToken(): Text
    var
        AzureKeyVaultManagement: Codeunit "Azure Key Vault Management";
        ResourceId: Text;
        RefreshToken: Text;
        AccessToken: Text;
    begin
        if not AzureKeyVaultManagement.GetAzureKeyVaultSecret(ResourceId,ClientResourceNameTxt) then
          Error(MissingClientInfoErr);

        if ResourceId = '' then
          Error(MissingClientInfoErr);

        if not IsEnabled then
          Error(NotEnabledErr);

        if not TryGetToken(RefreshToken,AccessToken) then begin
          Clear("Refresh Code");
          Clear("Expires On");
          Validate(Enabled,false);
          Modify;
          exit;
        end;

        SetRefreshToken(RefreshToken);
        Validate("Expires On",CreateDateTime(Today + 14,Time));
        Modify;

        exit(AccessToken);
    end;

    [TryFunction]
    local procedure TryGetToken(var RefreshToken: Text;var AccessToken: Text)
    var
        AzureADMgt: Codeunit "Azure AD Mgt.";
    begin
        SendTraceTag('00001QL',GraphMailCategoryTxt,VERBOSITY::Normal,GraphMailGetTokenMsg,DATACLASSIFICATION::SystemMetadata);
        AccessToken := AzureADMgt.GetTokenFromRefreshToken(GetRefreshToken,RefreshToken);

        if (AccessToken = '') or (RefreshToken = '') then
          Error('');
    end;

    procedure SendTestMail(Recipient: Text)
    var
        TempEmailItem: Record "Email Item" temporary;
        GraphMail: Codeunit "Graph Mail";
        Payload: Text;
    begin
        if Recipient = '' then
          Error('');

        TempEmailItem."Send to" := CopyStr(Recipient,1,MaxStrLen(TempEmailItem."Send to"));
        TempEmailItem."From Address" := CopyStr("Sender Email",1,MaxStrLen(TempEmailItem."From Address"));
        TempEmailItem."From Name" := CopyStr("Sender Name",1,MaxStrLen(TempEmailItem."From Name"));
        TempEmailItem.Subject := TestEmailSubjectTxt;
        TempEmailItem.SetBodyText(GraphMail.GetTestMessageBody);

        Payload := GraphMail.PrepareMessage(TempEmailItem);

        SendWebRequest(Payload,GetToken);
    end;

    procedure SendMail(TempEmailItem: Record "Email Item" temporary;var RefreshToken: Text)
    var
        GraphMail: Codeunit "Graph Mail";
        Payload: Text;
        Token: Text;
    begin
        if not TryGetToken(RefreshToken,Token) then
          Error(AuthFailErr);

        Payload := GraphMail.PrepareMessage(TempEmailItem);

        SendWebRequest(Payload,Token);
        SendTraceTag('00001QM',GraphMailCategoryTxt,VERBOSITY::Normal,GraphMailSentMsg,DATACLASSIFICATION::SystemMetadata);
    end;

    local procedure SendWebRequest(Payload: Text;Token: Text): Boolean
    var
        TempBlob: Record TempBlob temporary;
        HttpWebRequestMgt: Codeunit "Http Web Request Mgt.";
        GraphMail: Codeunit "Graph Mail";
        HttpStatusCode: DotNet HttpStatusCode;
        ResponseHeaders: DotNet NameValueCollection;
        ResponseInStream: InStream;
    begin
        TempBlob.Init;
        TempBlob.Blob.CreateInStream(ResponseInStream);

        HttpWebRequestMgt.Initialize(StrSubstNo('%1/v1.0/me/sendMail',GraphMail.GetGraphDomain));
        HttpWebRequestMgt.SetMethod('POST');
        HttpWebRequestMgt.SetContentType('application/json');
        HttpWebRequestMgt.SetReturnType('application/json');
        HttpWebRequestMgt.AddHeader('Authorization',StrSubstNo('Bearer %1',Token));
        HttpWebRequestMgt.AddBodyAsText(Payload);

        if not HttpWebRequestMgt.GetResponse(ResponseInStream,HttpStatusCode,ResponseHeaders) then begin
          HttpWebRequestMgt.ProcessFaultResponse('');
          exit(false);
        end;

        exit(true);
    end;

    local procedure GetRefreshToken() RefreshToken: Text
    var
        InStr: InStream;
    begin
        CalcFields("Refresh Code");
        "Refresh Code".CreateInStream(InStr);
        InStr.ReadText(RefreshToken);
    end;

    procedure SetRefreshToken(Token: Text)
    var
        OutStr: OutStream;
    begin
        "Refresh Code".CreateOutStream(OutStr);
        OutStr.WriteText(Token);
    end;

    procedure Initialize()
    var
        AzureKeyVaultManagement: Codeunit "Azure Key Vault Management";
        AzureADMgt: Codeunit "Azure AD Mgt.";
        ResourceId: Text;
        RefreshToken: Text;
        Token: Text;
    begin
        if not AzureKeyVaultManagement.GetAzureKeyVaultSecret(ResourceId,ClientResourceNameTxt) then
          Error(MissingClientInfoErr);

        if ResourceId = '' then
          Error(MissingClientInfoErr);

        SendTraceTag('00001QN',GraphMailCategoryTxt,VERBOSITY::Normal,GraphMailSetupStartMsg,DATACLASSIFICATION::SystemMetadata);
        Token := AzureADMgt.GetOnBehalfAccessTokenAndRefreshToken(ResourceId,RefreshToken);

        if (Token = '') or (RefreshToken = '') then
          Error(InvalidResultErr);

        SetRefreshToken(RefreshToken);
        Validate("Expires On",CreateDateTime(Today + 14,Time));

        SetUserFields(Token);
        SendTraceTag('00001QO',GraphMailCategoryTxt,VERBOSITY::Normal,GraphMailSetupFinishMsg,DATACLASSIFICATION::SystemMetadata);
    end;

    local procedure SetUserFields(Token: Text)
    var
        TempBlob: Record TempBlob temporary;
        HttpWebRequestMgt: Codeunit "Http Web Request Mgt.";
        JSONManagement: Codeunit "JSON Management";
        GraphMail: Codeunit "Graph Mail";
        HttpStatusCode: DotNet HttpStatusCode;
        JsonObject: DotNet JObject;
        ResponseHeaders: DotNet NameValueCollection;
        ResponseInStream: InStream;
        JsonResult: Variant;
        UserProfileJson: Text;
    begin
        TempBlob.Init;
        TempBlob.Blob.CreateInStream(ResponseInStream);

        HttpWebRequestMgt.Initialize(StrSubstNo('%1/v1.0/me/',GraphMail.GetGraphDomain));
        HttpWebRequestMgt.SetReturnType('application/json');
        HttpWebRequestMgt.AddHeader('Authorization',StrSubstNo('Bearer %1',Token));

        HttpWebRequestMgt.GetResponse(ResponseInStream,HttpStatusCode,ResponseHeaders);
        ResponseInStream.ReadText(UserProfileJson);
        JSONManagement.InitializeObject(UserProfileJson);
        JSONManagement.GetJSONObject(JsonObject);

        JSONManagement.GetPropertyValueFromJObjectByName(JsonObject,'displayName',JsonResult);
        Validate("Sender Name",JsonResult);

        JSONManagement.GetPropertyValueFromJObjectByName(JsonObject,'mail',JsonResult);
        Validate("Sender Email",JsonResult);

        TestField("Sender Email");
    end;
}

