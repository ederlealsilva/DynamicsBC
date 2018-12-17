codeunit 2200 "Azure Key Vault Management"
{
    // version NAVW113.00

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        NavAzureKeyVaultClient: DotNet MachineLearningCredentialsHelper;
        AzureKeyVaultSecretProvider: DotNet IAzureKeyVaultSecretProvider;
        ApplicationSecretsTxt: Label 'ml-forecast,qbo-consumerkey,qbo-consumersecret,amcname,amcpassword,YodleeCobrandName,YodleeCobrandPassword,YodleeServiceUri,YodleeFastlinkUrl,ExchangeAuthMethod,NpsApiUrl,NpsCacheLifeTime,NpsTimeBetweenRequests,webhooksadapteruri,webhooksadapterclientid,webhooksadapterclientsecret,webhooksadapterresourceuri,webhooksadapterauthority,c2graphclientid,c2graphsecret,c2graphresource,c2graphauthority,xeroimportapp-key,xeroimportapp-secret,qbo-businesscenter-consumerkey,qbo-businesscenter-consumersecret,walletpaymentrequesturl,qbo-datamigration-consumerkey,qbo-datamigration-consumersecret,govtalk-vendorid,MSWalletAADAppID,MSWalletAADAppKey,MSWalletAADIdentityService,MSWalletSignUpUrl,MSWalletMerchantAPI,MSWalletMerchantAPIResource,QBVisibleForInv,MailerResourceId,machinelearning,background-ml-enabled,extmgmt-marketplace-disable,opaycardoriginatorfornav,opaycardprivatekey,opaycardmerchantid,opaycarddisplayid,SmtpSetup', Locked=true;
        ImageAnalysisSecretTxt: Label 'cognitive-vision-params', Locked=true;
        SecretNotFoundErr: Label '%1 is not an application secret. Choose one of the following secrets: %2.', Comment='%1 = Secret Name. %2 = Available secrets.';
        AzureForecastApiUriTxt: Label 'AzureForecastApiUri', Locked=true;
        AzureForecastApiKeyTxt: Label 'AzureForecastApiKey', Locked=true;
        AzureForecastLimitTypeTxt: Label 'AzureForecastLimitType';
        AzureForecastLimitTxt: Label 'AzureForecastLimit', Locked=true;
        MissingImageAnalysisSecretErr: Label 'There is a missing configuration value on our end. Try again later.';
        CachedSecretsDictionary: DotNet Dictionary_Of_T_U;
        AzureMachineLearingApiUriTxt: Label 'AzureMachineLearningApiUri', Locked=true;
        AzureMachineLearningApiKeyTxt: Label 'AzureMachineLearningApiKey', Locked=true;
        AzureMachineLearningLimitTypeTxt: Label 'AzureMachineLearningLimitType';
        AzureMachineLearningLimitTxt: Label 'AzureMachineLearningLimit', Locked=true;
        LimitTypeOption: Option Year,Month,Day,Hour;
        SMTPSetupTxt: Label 'SmtpSetup', Locked=true;

    [TryFunction]
    procedure GetMLForecastCredentials(var ApiUri: Text[250];var ApiKey: Text[200];var LimitType: Option;var Limit: Decimal)
    var
        LimitAsText: Text;
        LimitTypeAsText: Text;
    begin
        if KeyValuePairInBuffer(AzureForecastApiUriTxt,ApiUri) and
           KeyValuePairInBuffer(AzureForecastApiKeyTxt,ApiKey) and
           KeyValuePairInBuffer(AzureForecastLimitTypeTxt,LimitTypeAsText) and
           KeyValuePairInBuffer(AzureForecastLimitTxt,LimitAsText)
        then begin
          Evaluate(Limit,LimitAsText);
          Evaluate(LimitType,LimitTypeAsText);
          exit;
        end;

        GetMLCredentials(NavAzureKeyVaultClient.GetMLForecastSecretName,ApiUri,ApiKey,LimitType,Limit);

        StoreKeyValuePairInBuffer(AzureForecastApiUriTxt,ApiUri);
        StoreKeyValuePairInBuffer(AzureForecastApiKeyTxt,ApiKey);
        StoreKeyValuePairInBuffer(AzureForecastLimitTxt,Format(Limit));
        StoreKeyValuePairInBuffer(AzureForecastLimitTypeTxt,Format(LimitType));
    end;

    [TryFunction]
    procedure GetMachineLearningCredentials(var ApiUri: Text[250];var ApiKey: Text[200];var LimitType: Option;var Limit: Decimal)
    var
        LimitAsText: Text;
        LimitTypeAsText: Text;
    begin
        if KeyValuePairInBuffer(AzureMachineLearingApiUriTxt,ApiUri) and
           KeyValuePairInBuffer(AzureMachineLearningApiKeyTxt,ApiKey) and
           KeyValuePairInBuffer(AzureMachineLearningLimitTypeTxt,LimitTypeAsText) and
           KeyValuePairInBuffer(AzureMachineLearningLimitTxt,LimitAsText)
        then begin
          Evaluate(Limit,LimitAsText);
          Evaluate(LimitType,LimitTypeAsText);
          exit;
        end;

        GetMLCredentials(NavAzureKeyVaultClient.GetMachineLearningSecretName,ApiUri,ApiKey,LimitType,Limit);

        StoreKeyValuePairInBuffer(AzureMachineLearingApiUriTxt,ApiUri);
        StoreKeyValuePairInBuffer(AzureMachineLearningApiKeyTxt,ApiKey);
        StoreKeyValuePairInBuffer(AzureMachineLearningLimitTxt,Format(Limit));
        StoreKeyValuePairInBuffer(AzureMachineLearningLimitTypeTxt,Format(LimitType));
    end;

    local procedure GetMLCredentials(SecretName: Text;var ApiUri: Text[250];var ApiKey: Text[200];var LimitType: Option;var Limit: Decimal)
    var
        ResultArray: DotNet Array;
    begin
        NavAzureKeyVaultClient := NavAzureKeyVaultClient.MachineLearningCredentialsHelper;
        NavAzureKeyVaultClient.SetAzureKeyVaultProvider(AzureKeyVaultSecretProvider);
        ResultArray := NavAzureKeyVaultClient.GetMLCredentials(SecretName);
        ApiKey := Format(ResultArray.GetValue(0));
        ApiUri := Format(ResultArray.GetValue(1));
        if not IsNull(ResultArray.GetValue(2)) then
          Evaluate(Limit,Format(ResultArray.GetValue(2)));
        if not IsNull(ResultArray.GetValue(3)) then
          LimitType := GetLimitTypeOptionFromText(Format(ResultArray.GetValue(3)));
    end;

    local procedure GetLimitTypeOptionFromText(LimitTypeTxt: Text): Integer
    begin
        case LimitTypeTxt of
          'Year':
            exit(LimitTypeOption::Year);
          'Month':
            exit(LimitTypeOption::Month);
          'Day':
            exit(LimitTypeOption::Day);
          'Hour':
            exit(LimitTypeOption::Hour);
        end;
    end;

    [TryFunction]
    procedure GetImageAnalysisCredentials(var ApiKey: Text;var ApiUri: Text;var LimitType: Option;var LimitValue: Integer)
    var
        JSONManagement: Codeunit "JSON Management";
        ImageAnalysisParameter: DotNet JObject;
        ImageAnalysisParametersText: Text;
        LimitTypeTxt: Text;
        LimitValueTxt: Text;
    begin
        GetAzureKeyVaultSecret(ImageAnalysisParametersText,ImageAnalysisSecretTxt);
        JSONManagement.InitializeCollection(ImageAnalysisParametersText);
        if JSONManagement.GetCollectionCount = 0 then
          exit;
        JSONManagement.GetJObjectFromCollectionByIndex(
          ImageAnalysisParameter,
          GetTenantBasedIdInRange(JSONManagement.GetCollectionCount) - 1);
        JSONManagement.GetStringPropertyValueFromJObjectByName(ImageAnalysisParameter,'key',ApiKey);
        JSONManagement.GetStringPropertyValueFromJObjectByName(ImageAnalysisParameter,'endpoint',ApiUri);

        JSONManagement.GetStringPropertyValueFromJObjectByName(ImageAnalysisParameter,'limittype',LimitTypeTxt);
        if LimitTypeTxt = '' then
          Error(MissingImageAnalysisSecretErr);

        LimitType := GetLimitTypeOptionFromText(LimitTypeTxt);

        JSONManagement.GetStringPropertyValueFromJObjectByName(ImageAnalysisParameter,'limitvalue',LimitValueTxt);
        if LimitValueTxt = '' then
          Error(MissingImageAnalysisSecretErr);
        Evaluate(LimitValue,LimitValueTxt);
    end;

    procedure GetSMTPCredentials(var SMTPMailSetup: Record "SMTP Mail Setup")
    var
        JSONManagement: Codeunit "JSON Management";
        SMTPServerParameter: DotNet JObject;
        SMTPServerParameters: Text;
        VaultAuthentication: Text;
        VaultUserID: Text[250];
        VaultSMTPServerPort: Text;
        VaultSecureConnection: Text;
        VaultPasswordKey: Text;
    begin
        GetAzureKeyVaultSecret(SMTPServerParameters,SMTPSetupTxt);
        JSONManagement.InitializeCollection(SMTPServerParameters);
        if JSONManagement.GetCollectionCount = 0 then
          exit;
        JSONManagement.GetJObjectFromCollectionByIndex(
          SMTPServerParameter,
          GetTenantBasedIdInRange(JSONManagement.GetCollectionCount) - 1);
        JSONManagement.GetStringPropertyValueFromJObjectByName(SMTPServerParameter,'Server',SMTPMailSetup."SMTP Server");
        JSONManagement.GetStringPropertyValueFromJObjectByName(SMTPServerParameter,'ServerPort',VaultSMTPServerPort);
        if VaultSMTPServerPort <> '' then
          Evaluate(SMTPMailSetup."SMTP Server Port",VaultSMTPServerPort);
        JSONManagement.GetStringPropertyValueFromJObjectByName(SMTPServerParameter,'Authentication',VaultAuthentication);
        if VaultAuthentication <> '' then
          Evaluate(SMTPMailSetup.Authentication,VaultAuthentication);
        JSONManagement.GetStringPropertyValueFromJObjectByName(SMTPServerParameter,'User',VaultUserID);
        SMTPMailSetup.Validate("User ID",VaultUserID);
        JSONManagement.GetStringPropertyValueFromJObjectByName(SMTPServerParameter,'Password',VaultPasswordKey);
        SMTPMailSetup.SetPassword(VaultPasswordKey);
        JSONManagement.GetStringPropertyValueFromJObjectByName(SMTPServerParameter,'SecureConnection',VaultSecureConnection);
        if VaultSecureConnection <> '' then
          Evaluate(SMTPMailSetup."Secure Connection",VaultSecureConnection);
    end;

    [TryFunction]
    procedure GetAzureKeyVaultSecret(var Secret: Text;SecretName: Text)
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        if TypeHelper.GetOptionNo(SecretName,GetAllowedSecrets) = -1 then
          if not (StrPos(SecretName,'isv-') = 1) then
            Error(SecretNotFoundErr,SecretName,GetAllowedSecrets);

        if KeyValuePairInBuffer(SecretName,Secret) then
          exit;

        NavAzureKeyVaultClient := NavAzureKeyVaultClient.MachineLearningCredentialsHelper;
        NavAzureKeyVaultClient.SetAzureKeyVaultProvider(AzureKeyVaultSecretProvider);
        Secret := NavAzureKeyVaultClient.GetAzureKeyVaultSecret(SecretName);

        StoreKeyValuePairInBuffer(SecretName,Secret);
    end;

    procedure SetAzureKeyVaultSecretProvider(NewAzureKeyVaultSecretProvider: DotNet IAzureKeyVaultSecretProvider)
    begin
        ClearBufferAndDotNetKeyvaultObjects;
        AzureKeyVaultSecretProvider := NewAzureKeyVaultSecretProvider;
    end;

    procedure IsEnable(): Boolean
    begin
        NavAzureKeyVaultClient := NavAzureKeyVaultClient.MachineLearningCredentialsHelper;
        exit(NavAzureKeyVaultClient.Enable);
    end;

    local procedure KeyValuePairInBuffer("Key": Text;var Value: Text): Boolean
    var
        ValueFound: Boolean;
        ValueToReturn: Text;
    begin
        InitBuffer;

        ValueFound := CachedSecretsDictionary.TryGetValue(Key,ValueToReturn);
        Value := ValueToReturn;
        exit(ValueFound);
    end;

    local procedure StoreKeyValuePairInBuffer("Key": Text;Value: Text)
    begin
        InitBuffer;

        CachedSecretsDictionary.Add(Key,Value);
    end;

    local procedure ClearBufferAndDotNetKeyvaultObjects()
    begin
        Clear(NavAzureKeyVaultClient);
        Clear(AzureKeyVaultSecretProvider);

        InitBuffer;

        CachedSecretsDictionary.Clear;
    end;

    local procedure GetTenantBasedIdInRange(MaxNumber: Integer): Integer
    var
        TenantIdString: DotNet String;
    begin
        TenantIdString := TenantId;
        Randomize(TenantIdString.GetHashCode);
        exit(Random(MaxNumber));
    end;

    local procedure GetAllowedSecrets(): Text
    begin
        exit(ApplicationSecretsTxt + ',' + ImageAnalysisSecretTxt + ',isv-*');
    end;

    local procedure InitBuffer()
    begin
        if IsNull(CachedSecretsDictionary) then
          CachedSecretsDictionary := CachedSecretsDictionary.Dictionary;
    end;
}

