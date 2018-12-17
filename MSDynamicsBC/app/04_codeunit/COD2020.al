codeunit 2020 "Image Analysis Management"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        HttpMessageHandler: DotNet HttpMessageHandler;
        "Key": Text;
        Uri: Text;
        LimitType: Option Year,Month,Day,Hour;
        LimitValue: Integer;
        ImagePath: Text;
        SetMediaErr: Label 'There was a problem uploading the image file. Please try again.';
        CognitiveServicesErr: Label 'Could not contact the %1. %2 Status code: %3.', Comment='%1: Error returned from called API. %2: HTTP status code of error';
        NoApiKeyUriErr: Label 'To analyze images, you must provide an API key and an API URI for Computer Vision.';
        NoImageErr: Label 'You haven''t uploaded an image to analyze.';
        LastError: Text;
        IsLastErrorUsageLimitError: Boolean;
        GenericErrorErr: Label 'There was an error in contacting the Computer Vision API. Please try again or contact an administrator.';
        ComputerVisionApiTxt: Label 'Computer Vision API';
        CustomVisionServiceTxt: Label 'Custom Vision Service';
        IsInitialized: Boolean;
        ChangingLimitAfterInitErr: Label 'You cannot change the limit setting after initialization.';

    [Scope('Personalization')]
    procedure Initialize()
    var
        ImageAnalysisSetup: Record "Image Analysis Setup";
        CortanaIntelligenceUsage: Record "Cortana Intelligence Usage";
        AzureKeyVaultManagement: Codeunit "Azure Key Vault Management";
        PermissionManager: Codeunit "Permission Manager";
    begin
        if IsInitialized then
          exit;
        if not ImageAnalysisSetup.Get then begin
          ImageAnalysisSetup.Init;
          ImageAnalysisSetup.Insert;
        end;

        if (Key = '') or (Uri = '') then begin
          Key := ImageAnalysisSetup.GetApiKey;
          Uri := ImageAnalysisSetup."Api Uri";
          CortanaIntelligenceUsage.SetImageAnalysisIsSetup(false);
        end else
          CortanaIntelligenceUsage.SetImageAnalysisIsSetup(true);

        if LimitValue = 0 then begin
          CortanaIntelligenceUsage.GetSingleInstance(CortanaIntelligenceUsage.Service::"Computer Vision");
          LimitType := CortanaIntelligenceUsage."Limit Period";
          LimitValue := CortanaIntelligenceUsage."Original Resource Limit";
        end;

        if LimitValue = 0 then
          SetLimitInYears(999);

        if ((Key = '') or (Uri = '')) and PermissionManager.SoftwareAsAService then
          AzureKeyVaultManagement.GetImageAnalysisCredentials(Key,Uri,LimitType,LimitValue);

        IsInitialized := true;
    end;

    [Scope('Personalization')]
    procedure SetMedia(MediaId: Guid)
    var
        TenantMedia: Record "Tenant Media";
        FileManagement: Codeunit "File Management";
    begin
        if TenantMedia.Get(MediaId) then begin
          ImagePath := FileManagement.ServerTempFileName('');
          TenantMedia.CalcFields(Content);
          TenantMedia.Content.Export(ImagePath);
        end else
          Error(SetMediaErr);
    end;

    [Scope('Personalization')]
    procedure SetImagePath(Path: Text)
    var
        FileManagement: Codeunit "File Management";
    begin
        FileManagement.IsAllowedPath(Path,false);
        ImagePath := Path;
    end;

    [Scope('Personalization')]
    procedure SetBlob(TempBlob: Record TempBlob temporary)
    var
        FileManagement: Codeunit "File Management";
    begin
        ImagePath := FileManagement.ServerTempFileName('');
        FileManagement.BLOBExportToServerFile(TempBlob,ImagePath);
    end;

    [Scope('Personalization')]
    procedure SetUriAndKey(UriValue: Text;KeyValue: Text)
    begin
        Uri := UriValue;
        Key := KeyValue;
    end;

    [Scope('Personalization')]
    procedure SetLimitInYears(Value: Integer)
    begin
        if IsInitialized then
          Error(ChangingLimitAfterInitErr);
        if Value <= 0 then
          exit;
        LimitType := LimitType::Year;
        LimitValue := Value;
    end;

    [Scope('Personalization')]
    procedure SetLimitInMonths(Value: Integer)
    begin
        if IsInitialized then
          Error(ChangingLimitAfterInitErr);
        if Value <= 0 then
          exit;
        LimitType := LimitType::Month;
        LimitValue := Value;
    end;

    [Scope('Personalization')]
    procedure SetLimitInDays(Value: Integer)
    begin
        if IsInitialized then
          Error(ChangingLimitAfterInitErr);
        if Value <= 0 then
          exit;
        LimitType := LimitType::Day;
        LimitValue := Value;
    end;

    [Scope('Personalization')]
    procedure SetLimitInHours(Value: Integer)
    begin
        if IsInitialized then
          Error(ChangingLimitAfterInitErr);
        if Value <= 0 then
          exit;
        LimitType := LimitType::Hour;
        LimitValue := Value;
    end;

    [Scope('Personalization')]
    procedure AnalyzeTags(var ImageAnalysisResult: Codeunit "Image Analysis Result"): Boolean
    var
        AnalysisType: Option Tags,Faces,Color;
    begin
        exit(Analyze(ImageAnalysisResult,AnalysisType::Tags));
    end;

    [Scope('Personalization')]
    procedure AnalyzeColors(var ImageAnalysisResult: Codeunit "Image Analysis Result"): Boolean
    var
        AnalysisType: Option Tags,Faces,Color;
    begin
        exit(Analyze(ImageAnalysisResult,AnalysisType::Color));
    end;

    [Scope('Personalization')]
    procedure AnalyzeFaces(var ImageAnalysisResult: Codeunit "Image Analysis Result"): Boolean
    var
        AnalysisType: Option Tags,Faces,Color;
    begin
        exit(Analyze(ImageAnalysisResult,AnalysisType::Faces));
    end;

    local procedure Analyze(var ImageAnalysisResult: Codeunit "Image Analysis Result";AnalysisType: Option Tags,Faces,Color): Boolean
    var
        ImageAnalysisSetup: Record "Image Analysis Setup";
        JSONManagement: Codeunit "JSON Management";
        UsageLimitError: Text;
    begin
        Initialize;
        SetLastError('',false);
        OnBeforeImageAnalysis;

        if (Key = '') or (Uri = '') then
          SetLastError(NoApiKeyUriErr,false)
        else
          if ImagePath = '' then
            SetLastError(NoImageErr,false)
          else
            if ImageAnalysisSetup.IsUsageLimitReached(UsageLimitError,LimitValue,LimitType) then
              SetLastError(UsageLimitError,true)
            else
              if InvokeAnalysis(JSONManagement,AnalysisType) then
                ImageAnalysisSetup.Increment
              else
                if LastError = '' then
                  SetLastError(GenericErrorErr,false);

        ImageAnalysisResult.SetJson(JSONManagement,AnalysisType);
        OnAfterImageAnalysis(ImageAnalysisResult);

        exit(not HasError);
    end;

    [TryFunction]
    local procedure InvokeAnalysis(var JSONManagement: Codeunit "JSON Management";AnalysisType: Option Tags,Faces,Color)
    var
        FileManagement: Codeunit "File Management";
        HttpClient: DotNet HttpClient;
        StreamContent: DotNet StreamContent;
        HttpResponseMessage: DotNet HttpResponseMessage;
        HttpRequestHeaders: DotNet HttpRequestHeaders;
        MediaTypeWithQualityHeaderValue: DotNet MediaTypeWithQualityHeaderValue;
        HttpContent: DotNet HttpContent;
        HttpContentHeaders: DotNet HttpContentHeaders;
        HttpHeaderValueCollection: DotNet HttpHeaderValueCollection_Of_T;
        ApiUri: DotNet Uri;
        Task: DotNet Task_Of_T;
        File: DotNet File;
        FileStream: DotNet FileStream;
        JsonResult: DotNet JObject;
        MessageText: Text;
        PostParameters: Text;
    begin
        if IsNull(HttpMessageHandler) then
          HttpClient := HttpClient.HttpClient
        else
          HttpClient := HttpClient.HttpClient(HttpMessageHandler);

        HttpClient.BaseAddress := ApiUri.Uri(Uri);

        HttpRequestHeaders := HttpClient.DefaultRequestHeaders;
        if HasCustomVisionUri then
          HttpRequestHeaders.TryAddWithoutValidation('Prediction-Key',Key)
        else begin
          HttpRequestHeaders.TryAddWithoutValidation('Ocp-Apim-Subscription-Key',Key);
          PostParameters := StrSubstNo('?visualFeatures=%1',Format(AnalysisType));
        end;
        HttpHeaderValueCollection := HttpRequestHeaders.Accept;
        MediaTypeWithQualityHeaderValue :=
          MediaTypeWithQualityHeaderValue.MediaTypeWithQualityHeaderValue('application/json');
        HttpHeaderValueCollection.Add(MediaTypeWithQualityHeaderValue);

        FileManagement.IsAllowedPath(ImagePath,false);

        FileStream := File.OpenRead(ImagePath);
        StreamContent := StreamContent.StreamContent(FileStream);
        HttpContentHeaders := StreamContent.Headers;
        HttpContentHeaders.Add('Content-Type','application/octet-stream');

        Task := HttpClient.PostAsync(PostParameters,StreamContent);

        HttpResponseMessage := Task.Result;
        HttpContent := HttpResponseMessage.Content;
        Task := HttpContent.ReadAsStringAsync;
        JSONManagement.InitializeObject(Task.Result);

        FileStream.Dispose;
        StreamContent.Dispose;
        HttpClient.Dispose;

        if not HttpResponseMessage.IsSuccessStatusCode then begin
          JSONManagement.GetJSONObject(JsonResult);
          JSONManagement.GetStringPropertyValueFromJObjectByName(JsonResult,'message',MessageText);
          if HasCustomVisionUri then
            SetLastError(StrSubstNo(CognitiveServicesErr,CustomVisionServiceTxt,MessageText,HttpResponseMessage.StatusCode),false)
          else
            SetLastError(StrSubstNo(CognitiveServicesErr,ComputerVisionApiTxt,MessageText,HttpResponseMessage.StatusCode),false);
          Error('');
        end;
    end;

    procedure SetHttpMessageHandler(NewHttpMessageHandler: DotNet HttpMessageHandler)
    begin
        HttpMessageHandler := NewHttpMessageHandler;
    end;

    [Scope('Personalization')]
    procedure GetLastError(var Message: Text;var IsUsageLimitError: Boolean): Boolean
    begin
        Message := LastError;
        IsUsageLimitError := IsLastErrorUsageLimitError;
        exit(HasError);
    end;

    local procedure SetLastError(ErrorMsg: Text;IsUsageLimitError: Boolean)
    begin
        LastError := ErrorMsg;
        IsLastErrorUsageLimitError := IsUsageLimitError;
    end;

    [Scope('Personalization')]
    procedure GetNoImageErr(): Text
    begin
        exit(NoImageErr);
    end;

    [Scope('Personalization')]
    procedure HasError(): Boolean
    begin
        exit(LastError <> '');
    end;

    [Scope('Personalization')]
    procedure GetLimitParams(var LimitTypeOut: Option Year,Month,Day,Hour;var LimitValueOut: Integer)
    begin
        LimitTypeOut := LimitType;
        LimitValueOut := LimitValue;
    end;

    local procedure HasCustomVisionUri(): Boolean
    begin
        exit(StrPos(Uri,'/customvision/') <> 0);
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnBeforeImageAnalysis()
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnAfterImageAnalysis(ImageAnalysisResult: Codeunit "Image Analysis Result")
    begin
    end;
}

