codeunit 2501 ExtensionMarketplaceMgmt
{
    // version NAVW113.00

    // // This codeunit is used as a helper for managing interations between
    // // Madeira and the SPZA marketplace. The marketplace provides a gallery
    // // that users can use to select and install Extensions published (an thus
    // // available) on Madeira.
    // // When and item is selected from the gallery, a JSON object is returned
    // // and needs to be parsed for the key information we need to perform an
    // // install.
    // // At current the key pieces of that object look like this:
    // //
    // // "msgType":"<type name string>",
    // // "data":
    // //    "applicationId":"<string identifier for selected extension>",
    // //    "telemetryUrl":"<url>",


    trigger OnRun()
    begin
    end;

    var
        GlobalPropertyValue: Text;
        ParseFailureErr: Label 'Failed to extract ''%1'' property from JSON object.', Comment='JSON parsing error. %1=target property name';
        TelemetryBodyTxt: Label '{"acquisitionResult":"%1", "detail":"%2"}', Comment='%1=SPZA operation result option, %2=details describing the context or reason for the result';
        GlobalId: Text;
        ParseApplicationIdErr: Label 'Failed to extract ''%1'' token from Application Id.', Comment='%1=Name of token that we expected   ';
        Token: Option PUBID,AID,PACKID,PAPPID;
        NullGuidTok: Label '00000000-0000-0000-0000-000000000000', Locked=true;
        AppsourceTxt: Label 'https://appsource.microsoft.com', Locked=true;
        AppsourcePPETxt: Label 'https://appsource.microsoft.com', Locked=true;
        EmbedRelativeTxt: Label '/embed/en-us/marketplace?product=project-madeira', Locked=true;
        MarketplaceDisabledSecretTxt: Label 'extmgmt-marketplace-disable', Locked=true;

    [Scope('Personalization')]
    procedure GetMarketplaceEmbeddedUrl(): Text
    begin
        // Returns the url to the Madeira SPZA Embedded Gallery.
        if IsPPE then
          exit(AppsourcePPETxt + EmbedRelativeTxt);

        exit(AppsourceTxt + EmbedRelativeTxt);
    end;

    [Scope('Personalization')]
    procedure GetMessageType(JObject: DotNet JObject): Text
    begin
        // Extracts the 'msgType' property from the
        exit(GetValue(JObject,'msgType',true));
    end;

    local procedure GetValue(JObject: DotNet JObject;Property: Text;ThrowError: Boolean): Text
    begin
        // Helper for extracting a property value out of a JObject
        if TryGetValue(JObject,Property) then
          exit(GlobalPropertyValue);

        if ThrowError then
          Error(ParseFailureErr,Property);

        exit('');
    end;

    [TryFunction]
    local procedure TryGetValue(JObject: DotNet JObject;Property: Text)
    var
        StringComparison: DotNet StringComparison;
        JToken: DotNet JToken;
    begin
        // Helper to 'safely' extract the value of a JProperty. Ignores case and 'catches' exceptions
        JToken := JObject.GetValue(Property,StringComparison.OrdinalIgnoreCase);
        GlobalPropertyValue := JToken.ToString;
    end;

    [Scope('Personalization')]
    procedure GetApplicationIdFromData(JObject: DotNet JObject): Text
    var
        TempObject: DotNet JObject;
    begin
        // Extracts the applicationId property out of the data object return by the SPZA site
        TempObject := TempObject.Parse(GetValue(JObject,'data',true));
        exit(GetValue(TempObject,'applicationId',true));
    end;

    [Scope('Personalization')]
    procedure MapMarketplaceIdToPackageId(ApplicationId: Text): Guid
    begin
        // When an ISV submits an Extension to SPZA for publication to
        // the marketplace, their artifact (.NAVX) is associated with an
        // id created internally by the SPZA team.
        // The .NAVX and other associated data are then submitted to our
        // Certification/Validation service. The id that SPZA created for
        // this item is is included as part of this payload. Unfortunately,
        // the id isn't provided to our service using the same name: 'applicationId'.
        // It is currently not known what name is used during this initial
        // submission, but once known it will be our responsibility to create
        // a mapping path between that service, the extension, and this codeunit.
        // Format:
        // PUBID.<value>|AID.<value>|PACKID.<package id>{|-preview}

        if TryParseApplicationId(ApplicationId,Token::PACKID) then
          exit(GlobalId);

        exit(NullGuidTok);
    end;

    [Scope('Personalization')]
    procedure GetTelementryUrlFromData(JObject: DotNet JObject): Text
    var
        TempObject: DotNet JObject;
    begin
        // Extracts the telemetryUrl property out of the data object return by the SPZA site
        // NOTE: the temp object is needed here. While JObject.Parse looks like a static call
        // to the JObject type, it will in fact reload and modify the underlying referenced object
        // as well as return the result of a 'parse'
        TempObject := TempObject.Parse(GetValue(JObject,'data',false));
        exit(GetValue(TempObject,'responseUrl',false));
    end;

    [TryFunction]
    local procedure TryMakeMarketplaceTelemetryCallback(TelemetryUrl: Text;OperationResult: Option UserNotAuthorized,DeploymentFailedDueToPackage,DeploymentFailed,Successful,UserCancel,UserTimeOut)
    var
        HttpWebRequestMgt: Codeunit "Http Web Request Mgt.";
        ResponseStr: InStream;
        HttpStatusCode: DotNet HttpStatusCode;
        ResponseHeaders: DotNet NameValueCollection;
    begin
        // Extracted from CODE1294::UploadFile
        HttpWebRequestMgt.Initialize(TelemetryUrl);
        HttpWebRequestMgt.DisableUI;
        HttpWebRequestMgt.SetReturnType('*/*');
        HttpWebRequestMgt.SetContentType('application/json');
        HttpWebRequestMgt.SetMethod('POST');
        HttpWebRequestMgt.AddBodyAsText(CreateTelemetryBody(OperationResult));
        HttpWebRequestMgt.CreateInstream(ResponseStr);

        HttpWebRequestMgt.GetResponse(ResponseStr,HttpStatusCode,ResponseHeaders)
    end;

    local procedure CreateTelemetryBody(OperationResult: Option UserNotAuthorized,DeploymentFailedDueToPackage,DeploymentFailed,Successful,UserCancel,UserTimeOut): Text
    begin
        // The telmetry callback expects an object of the form:
        // {
        // ..."Result":"<result value>",
        // ..."ResultDetail":"<result detail>",
        // }
        // Result is an enum string that SPZA recognizes, as defined by
        // the OperationResult variable in this function.
        // ResultDetail is an internal value that we can specify to identify the
        // task that the telmetry entry relates to.
        exit(StrSubstNo(TelemetryBodyTxt,Format(OperationResult),'ExtensionInstallation'));
    end;

    [TryFunction]
    local procedure TryParseApplicationId(ApplicationId: Text;ExpectedToken: Option PUBID,AID,PACKID,PAPPID)
    var
        actualToken: Text;
        TokenFound: Boolean;
        CurrentToken: Text;
    begin
        // Extract token value from Formats:
        // PUBID.<value>|AID.<value>|PACKID.<package id>{|-preview}
        // PUBID.<value>|AID.<value>|PAPPID.<app id>{|-preview}

        // Since 'split' in C\AL depends on comma delimiters, make sure we remove existing commas
        GlobalId := ConvertStr(ApplicationId,',',';');

        // Create 'split' points at pipes
        GlobalId := ConvertStr(GlobalId,'|',',');

        // Flag to indicate if expected token found or not
        TokenFound := false;

        // Iterate over tokens
        while GlobalId <> '' do begin
          CurrentToken := SelectStr(1,GlobalId);

          // Remove the scanned token from GlobalID
          GlobalId := DelStr(GlobalId,1,StrLen(CurrentToken) + 1);

          // Create 'split' point at token\value separator
          CurrentToken := ConvertStr(CurrentToken,'.',',');

          // Get token
          actualToken := SelectStr(1,CurrentToken);
          if actualToken = Format(ExpectedToken) then begin
            TokenFound := true;
            break;
          end;
        end;

        if not TokenFound then
          Error(ParseApplicationIdErr,ExpectedToken);

        // Select the value of the token
        GlobalId := SelectStr(2,CurrentToken);
    end;

    [Scope('Personalization')]
    procedure MapMarketplaceIdToAppId(ApplicationId: Text): Guid
    begin
        // When an ISV submits an Extension to SPZA for publication to
        // the marketplace, their artifact (.NAVX) is associated with an
        // id created internally by the SPZA team.
        // The .NAVX and other associated data are then submitted to our
        // Certification/Validation service. The id that SPZA created for
        // this item is is included as part of this payload. Unfortunately,
        // the id isn't provided to our service using the same name: 'applicationId'.
        // It is currently not known what name is used during this initial
        // submission, but once known it will be our responsibility to create
        // a mapping path between that service, the extension, and this codeunit.
        // Format:
        // PUBID.<value>|AID.<value>|PACKID.<package id>{|-preview}

        if TryParseApplicationId(ApplicationId,Token::PAPPID) then
          exit(GlobalId);

        exit(NullGuidTok);
    end;

    procedure MakeMarketplaceTelemetryCallback(TelemetryUrl: Text;OperationResult: Option UserNotAuthorized,DeploymentFailedDueToPackage,DeploymentFailed,Successful,UserCancel,UserTimeOut;PackageId: Text)
    var
        ActivityLog: Record "Activity Log";
        Related: Record "NAV App";
    begin
        if not TryMakeMarketplaceTelemetryCallback(TelemetryUrl,OperationResult) then begin
          Related."Package ID" := PackageId;
          ActivityLog.LogActivity(Related,ActivityLog.Status::Failed,
            'ExtensionInstallation',StrSubstNo('Make SPZA Telemetry call with result: %1',OperationResult),GetLastErrorText);
        end;
    end;

    procedure GetLoadMarketplaceMessage() Message: Text
    var
        User: Record User;
        AzureADMgt: Codeunit "Azure AD Mgt.";
        PowerBiServiceMgt: Codeunit "Power BI Service Mgt.";
        HttpUtility: DotNet HttpUtility;
        TempString: Text;
        FisrtName: Text;
        LastName: Text;
        AccessToken: Text;
    begin
        User.SetRange("User Security ID",UserSecurityId);
        User.FindFirst;
        TempString := User."Full Name";
        TempString := DelChr(TempString,'<>',' ');
        TempString := ConvertStr(TempString,' ',',');
        FisrtName := SelectStr(1,TempString);
        if StrPos(TempString,',') = 0 then
          LastName := ''
        else
          LastName := SelectStr(2,TempString);

        AccessToken := AzureADMgt.GetAccessToken(PowerBiServiceMgt.GetPowerBiResourceUrl,PowerBiServiceMgt.GetPowerBiResourceName,false);
        AccessToken := HttpUtility.JavaScriptStringEncode(AccessToken);

        // What is azure resource uri for Madeira? As of now getting access token for power bi.
        Message := '{"msgType":"loadMarketplace","hostData":{"firstName" :"' + FisrtName + '","lastName":"' + LastName + '","workEmail":"';
        Message := Message + User."Authentication Email" + '","accessToken":"' + AccessToken + '"}}';
    end;

    local procedure IsPPE(): Boolean
    var
        EnvironmentMgt: Codeunit "Environment Mgt.";
    begin
        exit(EnvironmentMgt.IsPPE);
    end;

    [TryFunction]
    procedure InstallExtension(ApplicationID: Text;TelemetryUrl: Text)
    var
        MarketplaceExtnDeployment: Page "Marketplace Extn. Deployment";
        ID: Guid;
    begin
        ID := MapMarketplaceIdToAppId(ApplicationID);

        MarketplaceExtnDeployment.SetAppIDAndTelemetryUrl(ID,TelemetryUrl);
        MarketplaceExtnDeployment.RunModal;
    end;

    procedure IsMarketplaceEnabled(): Boolean
    var
        AzureKeyVaultManagement: Codeunit "Azure Key Vault Management";
        DisabledSecret: Text[250];
        DisabledValue: Boolean;
    begin
        // Try to retrieve config value from keyvault, but if we fail (not there, or not boolean) then assume true
        if AzureKeyVaultManagement.GetAzureKeyVaultSecret(DisabledSecret,MarketplaceDisabledSecretTxt) then
          if Evaluate(DisabledValue,DisabledSecret) then
            exit(not DisabledValue);

        exit(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 2000000006, 'InvokeExtensionInstallation', '', false, false)]
    local procedure InvokeExtensionInstallation(AppId: Text;ResponseUrl: Text)
    begin
        if not InstallExtension(AppId,ResponseUrl) then
          Message(GetLastErrorText);
    end;
}

