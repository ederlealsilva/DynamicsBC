codeunit 1432 "Net Promoter Score Mgt."
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        DisplayDataTxt: Label 'display/financials/?puid=%1', Locked=true;
        RenderDataTxt: Label 'render/financials/?culture=%1&puid=%2', Locked=true;
        ClientTypeManagement: Codeunit ClientTypeManagement;
        NpsCategoryTxt: Label 'AL NPS Prompt', Locked=true;
        RequestTimeoutErr: Label 'Request timeout.', Locked=true;
        RequestFailedErr: Label 'Request failed.', Locked=true;

    procedure ShowNpsDialog(): Boolean
    var
        NetPromoterScoreSetup: Record "Net Promoter Score Setup";
    begin
        if not ShouldBePrompted then
          exit(false);

        if NetPromoterScoreSetup.GetApiUrl = '' then
          exit(false);

        DisableRequestSending;

        Commit;
        PAGE.RunModal(PAGE::"Net Promoter Score");
        exit(true);
    end;

    local procedure ShouldBePrompted(): Boolean
    var
        NetPromoterScore: Record "Net Promoter Score";
        DisplayUrl: Text;
        RenderUrl: Text;
        Response: Text;
        Display: Boolean;
    begin
        if not NetPromoterScore.ShouldSendRequest then
          exit(false);

        if not IsNpsSupported then
          exit(false);

        DisplayUrl := GetDisplayUrl;
        if DisplayUrl = '' then
          exit(false);

        RenderUrl := GetRenderUrl;
        if RenderUrl = '' then
          exit(false);

        if not ExecuteWebRequest(DisplayUrl,Response) then
          exit(false);

        if not TryGetDisplayProperty(Response,Display) then
          exit(false);

        exit(Display);
    end;

    [Scope('Personalization')]
    procedure IsNpsSupported(): Boolean
    var
        PermissionManager: Codeunit "Permission Manager";
    begin
        if not GuiAllowed then
          exit(false);

        if ClientTypeManagement.GetCurrentClientType in [CLIENTTYPE::Phone,CLIENTTYPE::Tablet] then
          exit(false);

        if not PermissionManager.SoftwareAsAService then
          exit(false);

        if not HasWritePermission then
          exit(false);

        if PermissionManager.IsSandboxConfiguration then
          exit(false);

        if GetApiUrl = '' then
          exit(false);

        exit(true);
    end;

    local procedure HasWritePermission(): Boolean
    var
        NetPromoterScoreSetup: Record "Net Promoter Score Setup";
        NetPromoterScore: Record "Net Promoter Score";
    begin
        if not NetPromoterScoreSetup.WritePermission then
          exit(false);

        if not NetPromoterScore.WritePermission then
          exit(false);

        exit(true);
    end;

    procedure TestConnection(BaseUrl: Text;var Response: Text;var ErrorMessage: Text): Boolean
    var
        TestUrl: Text;
        Success: Boolean;
    begin
        TestUrl := GetTestUrl(BaseUrl);
        Success := ExecuteWebRequest(TestUrl,Response);
        if not Success then
          ErrorMessage := GetLastErrorText;
        exit(Success);
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure ExecuteWebRequest(Url: Text;var Response: Text)
    var
        TempBlob: Record TempBlob temporary;
        HttpWebRequestMgt: Codeunit "Http Web Request Mgt.";
        WebRequestHelper: Codeunit "Web Request Helper";
        WebException: DotNet WebException;
        WebExceptionStatus: DotNet WebExceptionStatus;
        HttpStatusCode: DotNet HttpStatusCode;
        Headers: DotNet NameValueCollection;
        ResponseStream: InStream;
        ErrorMessage: Text;
        ServiceUrl: Text;
    begin
        TempBlob.Init;
        TempBlob.Blob.CreateInStream(ResponseStream);
        HttpWebRequestMgt.Initialize(Url);
        HttpWebRequestMgt.DisableUI;
        HttpWebRequestMgt.SetReturnType('application/json');
        HttpWebRequestMgt.AddHeader('Accept-Encoding','utf-8');
        HttpWebRequestMgt.SetMethod('GET');
        HttpWebRequestMgt.SetTimeout(TimeoutInMilliseconds);
        if not HttpWebRequestMgt.GetResponse(ResponseStream,HttpStatusCode,Headers) then begin
          ErrorMessage := WebRequestHelper.GetWebResponseError(WebException,ServiceUrl);
          if WebException.Status.Equals(WebExceptionStatus.Timeout) then
            SendTraceTag('000022P',NpsCategoryTxt,VERBOSITY::Error,RequestTimeoutErr,DATACLASSIFICATION::SystemMetadata)
          else
            SendTraceTag('000022Q',NpsCategoryTxt,VERBOSITY::Error,RequestFailedErr,DATACLASSIFICATION::SystemMetadata);
          Error(ErrorMessage);
        end;
        ResponseStream.ReadText(Response);
    end;

    procedure GetPuid(): Text
    var
        IdentityManagement: Codeunit "Identity Management";
        Puid: Text;
        Guid: Guid;
    begin
        Puid := IdentityManagement.GetObjectId(UserSecurityId);
        if not Evaluate(Guid,Puid) then
          Puid := '';
        exit(Puid);
    end;

    [Scope('Personalization')]
    procedure GetDisplayUrl(): Text
    var
        Data: Text;
        BaseUrl: Text;
        FullUrl: Text;
    begin
        Data := GetDisplayData;
        BaseUrl := GetApiUrl;
        FullUrl := GetFullUrl(BaseUrl,Data);
        exit(FullUrl);
    end;

    [Scope('Personalization')]
    procedure GetRenderUrl(): Text
    var
        Data: Text;
        BaseUrl: Text;
        FullUrl: Text;
    begin
        Data := GetRenderData;
        BaseUrl := GetApiUrl;
        FullUrl := GetFullUrl(BaseUrl,Data);
        exit(FullUrl);
    end;

    [Scope('Personalization')]
    procedure GetTestUrl(BaseUrl: Text): Text
    var
        Data: Text;
        FullUrl: Text;
    begin
        Data := GetTestData;
        FullUrl := GetFullUrl(BaseUrl,Data);
        exit(FullUrl);
    end;

    local procedure GetFullUrl(BaseUrl: Text;Data: Text): Text
    var
        FullUrl: Text;
    begin
        if (BaseUrl <> '') and (Data <> '') then
          FullUrl := StrSubstNo('%1%2',BaseUrl,Data);
        exit(FullUrl);
    end;

    local procedure GetApiUrl(): Text
    var
        NetPromoterScoreSetup: Record "Net Promoter Score Setup";
        Url: Text;
    begin
        Url := NetPromoterScoreSetup.GetApiUrl;
        exit(Url);
    end;

    local procedure GetTestData(): Text
    var
        Data: Text;
    begin
        Data := StrSubstNo(DisplayDataTxt,'');
        exit(Data);
    end;

    local procedure GetDisplayData(): Text
    var
        Puid: Text;
        Data: Text;
    begin
        Puid := GetPuid;
        Data := StrSubstNo(DisplayDataTxt,Puid);
        exit(Data);
    end;

    local procedure GetRenderData(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        Culture: Text;
        Puid: Text;
        Data: Text;
    begin
        Culture := LowerCase(TypeHelper.LanguageIDToCultureName(GlobalLanguage));
        Puid := GetPuid;
        Data := StrSubstNo(RenderDataTxt,Culture,Puid);
        exit(Data);
    end;

    [TryFunction]
    local procedure TryGetDisplayProperty(Data: Text;var DisplayProperty: Boolean)
    var
        JSONManagement: Codeunit "JSON Management";
        JObject: DotNet JObject;
    begin
        JSONManagement.InitializeObject(Data);
        JSONManagement.GetJSONObject(JObject);
        JSONManagement.GetBoolPropertyValueFromJObjectByName(JObject,'display',DisplayProperty);
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure TryGetMessageType(Data: Text;var MessageType: Text)
    var
        JSONManagement: Codeunit "JSON Management";
        JObject: DotNet JObject;
    begin
        JSONManagement.InitializeObject(Data);
        JSONManagement.GetJSONObject(JObject);
        JSONManagement.GetStringPropertyValueFromJObjectByName(JObject,'msgType',MessageType);
    end;

    [EventSubscriber(ObjectType::Codeunit, 40, 'OnAfterCompanyOpen', '', false, false)]
    local procedure OnAfterCompanyUpdateRequestSendingStatus()
    var
        NetPromoterScore: Record "Net Promoter Score";
    begin
        NetPromoterScore.UpdateRequestSendingStatus;
    end;

    [EventSubscriber(ObjectType::Codeunit, 2, 'OnCompanyInitialize', '', false, false)]
    [Scope('Personalization')]
    procedure OnCompanyInitializeInvalidateCache()
    var
        NetPromoterScoreSetup: Record "Net Promoter Score Setup";
    begin
        if NetPromoterScoreSetup.Get then begin
          NetPromoterScoreSetup."Expire Time" := CurrentDateTime;
          NetPromoterScoreSetup.Modify;
        end;
    end;

    [Scope('Personalization')]
    procedure DisableRequestSending()
    var
        NetPromoterScore: Record "Net Promoter Score";
    begin
        NetPromoterScore.DisableRequestSending;
    end;

    local procedure TimeoutInMilliseconds(): Integer
    begin
        exit(5000);
    end;
}

