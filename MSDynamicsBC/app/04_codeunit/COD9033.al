codeunit 9033 "Invite External Accountant"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        ErrorAcquiringTokenTxt: Label 'Failed to acquire an access token.  This is necessary to invite the external accountant.  Contact your administrator.', Locked=true;
        InviteReedemUrlTxt: Label 'inviteRedeemUrl', Locked=true;
        InvitedUserIdTxt: Label 'invitedUser', Locked=true;
        IdTxt: Label 'id', Locked=true;
        ConsumedUnitsTxt: Label 'consumedUnits', Locked=true;
        ErrorTxt: Label 'error', Locked=true;
        MessageTxt: Label 'message', Locked=true;
        ValueTxt: Label 'value', Locked=true;
        SkuIdTxt: Label 'skuId', Locked=true;
        PrepaidUnitsTxt: Label 'prepaidUnits', Locked=true;
        EnabledUnitsTxt: Label 'enabled', Locked=true;
        GlobalAdministratorRoleTemplateIdTxt: Label '62e90394-69f5-4237-9190-012177145e10', Locked=true;
        UserAdministratorRoleTemplateIdTxt: Label 'fe930be7-5e62-47db-91af-98c3a49a38b1', Locked=true;
        ExternalAccountantLicenseSkuIdTxt: Label '9a1e33ed-9697-43f3-b84c-1b0959dbb1d4', Locked=true;
        TenantTxt: Label 'TENANT ID:  %1.  ', Locked=true;
        UserTxt: Label 'USER ID:  %1.  ', Locked=true;
        CountryTxt: Label 'Country:  %1.  ', Locked=true;
        InviteExternalAccountantTelemetryCategoryTxt: Label 'AL Dynamics 365 Invite External Accountant', Locked=true;
        InviteExternalAccountantTelemetryStartTxt: Label 'Invite External Accountant process started.', Locked=true;
        InviteExternalAccountantTelemetryEndTxt: Label 'Invite External Accountant process ended with the following result:  %1:  %2', Locked=true;
        InviteExternalAccountantTelemetryLicenseFailTxt: Label 'Invite External Accountant wizard failed to start due to there being no external accountant license avaialble.', Locked=true;
        InviteExternalAccountantTelemetryAADPermissionFailTxt: Label 'Invite External Accountant wizard failed to start due to the user not having the necessary AAD permissions.', Locked=true;
        InviteExternalAccountantTelemetryUserTablePermissionFailTxt: Label 'Invite External Accountant wizard failed to start due to the session not being admin or the user being Super in all companies.', Locked=true;
        InviteExternalAccountantTelemetryCreateNewUserSuccessTxt: Label 'Invite External Accountant wizard successfully created a new user.', Locked=true;
        InviteExternalAccountantTelemetryCreateNewUserFailedTxt: Label 'Invite External Accountant wizard was unable to create a new user.', Locked=true;
        ResponseCodeTxt: Label 'responseCode', Locked=true;
        EmailAddressIsConsumerAccountTxt: Label 'The email address looks like a personal email address.  Enter your accountant''s work email address to continue.';
        EmailAddressIsInvalidTxt: Label 'The email address is invalid.  Enter your accountant''s work email address to continue.';
        InsufficientDataReturnedFromInvitationsApiTxt: Label 'Insufficient information was returned when inviting the user. Please contact your administrator.';
        AccountantPortalTelemetryCategoryTxt: Label 'AL Dynamics 365 Accountant Hub', Locked=true;
        AccountantPortalTelemetryGoToCompanyTxt: Label 'EVENT:  Accountant Portal user logged into their clients company from the embedded company detail page.', Locked=true;
        WidsClaimNameTok: Label 'WIDS', Locked=true;
        ExternalAccountantLicenseAvailabilityErr: Label 'Failed to determine if an External Accountant license is available. Please try again later.';

    procedure InvokeInvitationsRequest(DisplayName: Text;EmailAddress: Text;WebClientUrl: Text;var InvitedUserId: Guid;var InviteReedemUrl: Text;var ErrorMessage: Text): Boolean
    var
        JSONManagement: Codeunit "JSON Management";
        JsonObject: DotNet JObject;
        InviteUserIdJsonObject: DotNet JObject;
        InviteUserIdObjectValue: Text;
        ResponseContent: Text;
        Body: Text;
        FoundInviteRedeemUrlValue: Boolean;
        FoundInvitedUserObjectValue: Boolean;
        FoundInviteUserIdValue: Boolean;
    begin
        Body := '{';
        Body := Body + '"invitedUserDisplayName" : "' + DisplayName + '",';
        Body := Body + '"invitedUserEmailAddress" : "' + EmailAddress + '",';
        Body := Body + '"inviteRedirectUrl" : "' + WebClientUrl + '",';
        Body := Body + '"sendInvitationMessage" : "false"';
        Body := Body + '}';

        if InvokeRequestWithGraphAccessToken(GetGraphInvitationsUrl,'POST',Body,ResponseContent) then begin
          JSONManagement.InitializeObject(ResponseContent);
          JSONManagement.GetJSONObject(JsonObject);
          FoundInviteRedeemUrlValue :=
            JSONManagement.GetStringPropertyValueFromJObjectByName(JsonObject,InviteReedemUrlTxt,InviteReedemUrl);
          FoundInvitedUserObjectValue :=
            JSONManagement.GetStringPropertyValueFromJObjectByName(JsonObject,InvitedUserIdTxt,InviteUserIdObjectValue);
          JSONManagement.InitializeObject(InviteUserIdObjectValue);
          JSONManagement.GetJSONObject(InviteUserIdJsonObject);
          FoundInviteUserIdValue := JSONManagement.GetGuidPropertyValueFromJObjectByName(InviteUserIdJsonObject,IdTxt,InvitedUserId);

          if FoundInviteRedeemUrlValue and FoundInvitedUserObjectValue and FoundInviteUserIdValue then
            exit(true);

          ErrorMessage := InsufficientDataReturnedFromInvitationsApiTxt;
          exit(false);
        end;

        ErrorMessage := GetMessageFromErrorJSON(ResponseContent);
        exit(false);
    end;

    procedure InvokeUserProfileUpdateRequest(var GuestGraphUser: DotNet UserInfo;CountryLetterCode: Text;var ErrorMessage: Text): Boolean
    var
        Body: Text;
        ResponseContent: Text;
        GraphUserUrl: Text;
    begin
        GraphUserUrl := GetGraphUserUrl + '/' + GuestGraphUser.ObjectId;
        Body := '{"usageLocation" : "' + CountryLetterCode + '"}';

        // Set usage location on guest user to current tenant's country letter code.
        if InvokeRequestWithGraphAccessToken(GraphUserUrl,'PATCH',Body,ResponseContent) then
          exit(true);

        ErrorMessage := GetMessageFromErrorJSON(ResponseContent);
        exit(false);
    end;

    procedure InvokeUserAssignLicenseRequest(var GraphUser: DotNet UserInfo;var ErrorMessage: Text): Boolean
    var
        Body: Text;
        ResponseContent: Text;
        Url: Text;
    begin
        Url := GetGraphUserUrl + '/' + GraphUser.ObjectId + '/assignLicense';

        Body := '{';
        Body := Body + '"addLicenses": [';
        Body := Body + '{';
        Body := Body + '"disabledPlans": [],';
        Body := Body + '"skuId": "9a1e33ed-9697-43f3-b84c-1b0959dbb1d4"';
        Body := Body + '}],';
        Body := Body + '"removeLicenses": []';
        Body := Body + '}';

        if InvokeRequestWithGraphAccessToken(Url,'POST',Body,ResponseContent) then
          exit(true);

        ErrorMessage := GetMessageFromErrorJSON(ResponseContent);
        exit(false);
    end;

    procedure InvokeIsExternalAccountantLicenseAvailable(var ErrorMessage: Text): Boolean
    var
        JSONManagement: Codeunit "JSON Management";
        JsonObject: DotNet JObject;
        JsonArray: DotNet JArray;
        PrepaidUnitsJsonObject: DotNet JObject;
        NumberSkus: Integer;
        ResponseContent: Text;
        SkuIdValue: Text;
        ConsumedUnitsValue: Decimal;
        PrepaidUnitsValue: Text;
        EnabledUnitsValue: Decimal;
    begin
        if InvokeRequestWithGraphAccessToken(GetGraphSubscribedSkusUrl,'GET','',ResponseContent) then begin
          if not JSONManagement.TryParseJObjectFromString(JsonObject,ResponseContent) then
            Error(ExternalAccountantLicenseAvailabilityErr);

          if not JSONManagement.GetArrayPropertyValueFromJObjectByName(JsonObject,ValueTxt,JsonArray) then
            Error(ExternalAccountantLicenseAvailabilityErr);
          JSONManagement.InitializeCollectionFromJArray(JsonArray);

          NumberSkus := JSONManagement.GetCollectionCount;
          while NumberSkus > 0 do begin
            NumberSkus := NumberSkus - 1;
            if JSONManagement.GetJObjectFromCollectionByIndex(JsonObject,NumberSkus) then begin
              if not JSONManagement.GetStringPropertyValueFromJObjectByName(JsonObject,SkuIdTxt,SkuIdValue) then
                Error(ExternalAccountantLicenseAvailabilityErr);
              if not JSONManagement.GetDecimalPropertyValueFromJObjectByName(JsonObject,ConsumedUnitsTxt,ConsumedUnitsValue) then
                Error(ExternalAccountantLicenseAvailabilityErr);
              // Check to see if there is an external accountant license available.
              if SkuIdValue = ExternalAccountantLicenseSkuIdTxt then begin
                if not JSONManagement.GetStringPropertyValueFromJObjectByName(JsonObject,PrepaidUnitsTxt,PrepaidUnitsValue) then
                  Error(ExternalAccountantLicenseAvailabilityErr);
                if not JSONManagement.TryParseJObjectFromString(PrepaidUnitsJsonObject,PrepaidUnitsValue) then
                  Error(ExternalAccountantLicenseAvailabilityErr);
                if not JSONManagement.GetDecimalPropertyValueFromJObjectByName(PrepaidUnitsJsonObject,EnabledUnitsTxt,EnabledUnitsValue) then
                  Error(ExternalAccountantLicenseAvailabilityErr);

                if ConsumedUnitsValue < EnabledUnitsValue then
                  exit(true);

                exit(false);
              end;
            end;
          end;
        end;

        ErrorMessage := GetMessageFromErrorJSON(ResponseContent);
        exit(false);
    end;

    procedure VerifySMTPIsEnabledAndSetup(): Boolean
    var
        SMTPMail: Codeunit "SMTP Mail";
    begin
        if not SMTPMail.IsEnabled then
          exit(false);

        exit(true);
    end;

    procedure InvokeEmailAddressIsAADAccount(EmailAddress: Text;var ErrorMessage: Text): Boolean
    var
        JSONManagement: Codeunit "JSON Management";
        JsonObject: DotNet JObject;
        ResponseContent: Text;
        Url: Text;
        Body: Text;
        ResponseCodeValue: Text;
    begin
        Url := GetSignupPrefix + 'api/signupservice/usersignup?api-version=1';
        Body := '{"emailaddress": "' + EmailAddress + '","skuid": "basic","skipVerificationEmail": true}';

        InvokeRequestWithSignupAccessToken(Url,'POST',Body,ResponseContent);
        JSONManagement.InitializeObject(ResponseContent);
        JSONManagement.GetJSONObject(JsonObject);
        JSONManagement.GetStringPropertyValueFromJObjectByName(JsonObject,ResponseCodeTxt,ResponseCodeValue);
        case ResponseCodeValue of
          'Success':
            exit(true);
          'UserExists':
            exit(true);
          'ConsumerDomainNotAllowed':
            ErrorMessage := EmailAddressIsConsumerAccountTxt;
          else
            ErrorMessage := EmailAddressIsInvalidTxt;
        end;

        exit(false);
    end;

    procedure InvokeIsUserAdministrator(): Boolean
    var
        AzureADUserManagement: Codeunit "Azure AD User Management";
        ClaimValue: Text;
    begin
        ClaimValue := AzureADUserManagement.GetCurrentUserTokenClaim(WidsClaimNameTok);
        if ClaimValue = '' then
          exit(false);

        if StrPos(UpperCase(ClaimValue),UpperCase(GlobalAdministratorRoleTemplateIdTxt)) > 0 then
          exit(true);
        if StrPos(UpperCase(ClaimValue),UpperCase(UserAdministratorRoleTemplateIdTxt)) > 0 then
          exit(true);

        exit(false);
    end;

    procedure CreateNewUser(InvitedUserId: Guid)
    var
        AzureADUserManagement: Codeunit "Azure AD User Management";
        GuestGraphUser: DotNet UserInfo;
        Graph: DotNet GraphQuery;
        "Count": Integer;
    begin
        Graph := Graph.GraphQuery;

        repeat
          Sleep(2000);
          Count := Count + 1;
          Graph.TryGetUserByObjectId(InvitedUserId,GuestGraphUser);
        until (Graph.GetUserAssignedPlans(GuestGraphUser).Count > 1) or (Count = 10);

        if Graph.GetUserAssignedPlans(GuestGraphUser).Count > 1 then begin
          OnInvitationCreateNewUser(true);
          AzureADUserManagement.CreateNewUserFromGraphUser(GuestGraphUser);
        end else
          OnInvitationCreateNewUser(false);
    end;

    procedure TryGetGuestGraphUser(InvitedUserId: Guid;var GuestGraphUser: DotNet UserInfo): Boolean
    var
        Graph: DotNet GraphQuery;
        FoundUser: Boolean;
        "Count": Integer;
    begin
        Graph := Graph.GraphQuery;

        repeat
          Sleep(2000);
          Count := Count + 1;
          FoundUser := Graph.TryGetUserByObjectId(InvitedUserId,GuestGraphUser);
        until FoundUser or (Count = 10);

        exit(FoundUser);
    end;

    procedure UpdateAssistedSetup()
    var
        AssistedSetup: Record "Assisted Setup";
    begin
        if AssistedSetup.WritePermission then
          if AssistedSetup.Get(PAGE::"Invite External Accountant") then begin
            AssistedSetup.Validate(Status,AssistedSetup.Status::Completed);
            AssistedSetup.Modify(true);
          end;
    end;

    local procedure InvokeRequestWithGraphAccessToken(Url: Text;Verb: Text;Body: Text;var ResponseContent: Text): Boolean
    begin
        exit(InvokeRequest(Url,Verb,Body,GetGraphPrefix,ResponseContent));
    end;

    local procedure InvokeRequestWithSignupAccessToken(Url: Text;Verb: Text;Body: Text;var ResponseContent: Text): Boolean
    begin
        exit(InvokeRequest(Url,Verb,Body,GetSignupPrefix,ResponseContent));
    end;

    local procedure InvokeRequest(Url: Text;Verb: Text;Body: Text;AuthResourceUrl: Text;var ResponseContent: Text): Boolean
    var
        TempBlob: Record TempBlob;
        AzureADMgt: Codeunit "Azure AD Mgt.";
        IdentityManagement: Codeunit "Identity Management";
        HttpWebRequestMgt: Codeunit "Http Web Request Mgt.";
        WebRequestHelper: Codeunit "Web Request Helper";
        HttpStatusCode: DotNet HttpStatusCode;
        ResponseHeaders: DotNet NameValueCollection;
        WebException: DotNet WebException;
        InStr: InStream;
        AccessToken: Text;
        ServiceUrl: Text;
        ChunkText: Text;
        WasSuccessful: Boolean;
    begin
        AccessToken := AzureADMgt.GetGuestAccessToken(AuthResourceUrl,IdentityManagement.GetAadTenantId);

        if AccessToken = '' then begin
          ResponseContent := ErrorAcquiringTokenTxt;
          exit(false);
        end;

        HttpWebRequestMgt.Initialize(Url);
        HttpWebRequestMgt.DisableUI;
        HttpWebRequestMgt.SetReturnType('application/json');
        HttpWebRequestMgt.SetContentType('application/json');
        HttpWebRequestMgt.SetMethod(Verb);
        HttpWebRequestMgt.AddHeader('Authorization','Bearer ' + AccessToken);
        if Verb <> 'GET' then
          HttpWebRequestMgt.AddBodyAsText(Body);

        TempBlob.Init;
        TempBlob.Blob.CreateInStream(InStr);
        if HttpWebRequestMgt.GetResponse(InStr,HttpStatusCode,ResponseHeaders) then
          WasSuccessful := true
        else begin
          WebRequestHelper.GetWebResponseError(WebException,ServiceUrl);
          WebException.Response.GetResponseStream.CopyTo(InStr);
          WasSuccessful := false;
        end;

        while not InStr.EOS do begin
          InStr.ReadText(ChunkText);
          ResponseContent += ChunkText;
        end;

        exit(WasSuccessful);
    end;

    local procedure GetMessageFromErrorJSON(ResponseContent: Text): Text
    var
        JSONManagement: Codeunit "JSON Management";
        JsonObject: DotNet JObject;
        ErrorObjectValue: Text;
        MessageValue: Text;
    begin
        JSONManagement.InitializeObject(ResponseContent);
        JSONManagement.GetJSONObject(JsonObject);
        if JSONManagement.GetStringPropertyValueFromJObjectByName(JsonObject,ErrorTxt,ErrorObjectValue) then begin
          JSONManagement.InitializeObject(ErrorObjectValue);
          JSONManagement.GetJSONObject(JsonObject);
          JSONManagement.GetStringPropertyValueFromJObjectByName(JsonObject,MessageTxt,MessageValue);
        end;

        exit(MessageValue);
    end;

    local procedure GetGraphInvitationsUrl(): Text
    begin
        if IsPPE then
          exit('https://graph.microsoft-ppe.com/beta/invitations');

        exit('https://graph.microsoft.com/v1.0/invitations');
    end;

    local procedure GetGraphUserUrl(): Text
    begin
        if IsPPE then
          exit('https://graph.microsoft-ppe.com/v1.0/users');

        exit('https://graph.microsoft.com/v1.0/users');
    end;

    local procedure GetGraphSubscribedSkusUrl(): Text
    begin
        if IsPPE then
          exit('https://graph.microsoft-ppe.com/v1.0/subscribedSkus');

        exit('https://graph.microsoft.com/v1.0/subscribedSkus');
    end;

    local procedure GetGraphPrefix(): Text
    begin
        if IsPPE then
          exit('https://graph.microsoft-ppe.com');

        exit('https://graph.microsoft.com');
    end;

    local procedure GetSignupPrefix(): Text
    begin
        if IsPPE then
          exit('https://signupppe.microsoft.com/');

        exit('https://signup.microsoft.com/');
    end;

    procedure IsPPE(): Boolean
    var
        EnvironmentMgt: Codeunit "Environment Mgt.";
    begin
        if EnvironmentMgt.IsPPE then
          exit(true);

        exit(false);
    end;

    [EventSubscriber(ObjectType::Page, 9033, 'OnInvitationStart', '', false, false)]
    local procedure SendTelemetryForInvitationStart()
    begin
        SendTraceTag('0000178',InviteExternalAccountantTelemetryCategoryTxt,VERBOSITY::Normal,GetTelemetryCommonInformation +
          InviteExternalAccountantTelemetryStartTxt,DATACLASSIFICATION::EndUserIdentifiableInformation);
    end;

    [EventSubscriber(ObjectType::Page, 9033, 'OnInvitationNoExternalAccountantLicenseFail', '', false, false)]
    local procedure SendTelemetryForInvitationNoExternalAccountantLicenseFail()
    begin
        SendTraceTag('0000179',InviteExternalAccountantTelemetryCategoryTxt,VERBOSITY::Error,GetTelemetryCommonInformation +
          InviteExternalAccountantTelemetryLicenseFailTxt,DATACLASSIFICATION::EndUserIdentifiableInformation);
    end;

    [EventSubscriber(ObjectType::Page, 9033, 'OnInvitationNoAADPermissionsFail', '', false, false)]
    local procedure SendTelemetryForInvitationNoAADPermissionsFail()
    begin
        SendTraceTag('000017A',InviteExternalAccountantTelemetryCategoryTxt,VERBOSITY::Error,GetTelemetryCommonInformation +
          InviteExternalAccountantTelemetryAADPermissionFailTxt,DATACLASSIFICATION::EndUserIdentifiableInformation);
    end;

    [EventSubscriber(ObjectType::Page, 9033, 'OnInvitationNoUserTablePermissionsFail', '', false, false)]
    local procedure SendTelemetryForInvitationNoUserTableWritePermissionsFail()
    begin
        SendTraceTag('00001DK',InviteExternalAccountantTelemetryCategoryTxt,VERBOSITY::Error,GetTelemetryCommonInformation +
          InviteExternalAccountantTelemetryUserTablePermissionFailTxt,DATACLASSIFICATION::EndUserIdentifiableInformation);
    end;

    [EventSubscriber(ObjectType::Page, 9033, 'OnInvitationEnd', '', false, false)]
    local procedure SendTelemetryForInvitationEnd(WasInvitationSuccessful: Boolean;Result: Text;Progress: Text)
    begin
        if WasInvitationSuccessful then
          SendTraceTag('000017B',InviteExternalAccountantTelemetryCategoryTxt,VERBOSITY::Normal,GetTelemetryCommonInformation +
            StrSubstNo(InviteExternalAccountantTelemetryEndTxt,Result,Progress),DATACLASSIFICATION::EndUserIdentifiableInformation)
        else
          SendTraceTag('000017C',InviteExternalAccountantTelemetryCategoryTxt,VERBOSITY::Error,GetTelemetryCommonInformation +
            StrSubstNo(InviteExternalAccountantTelemetryEndTxt,Result,Progress),DATACLASSIFICATION::EndUserIdentifiableInformation);
    end;

    [EventSubscriber(ObjectType::Codeunit, 9033, 'OnInvitationCreateNewUser', '', false, false)]
    local procedure SendTelemetryForInvitationCreateNewUser(UserCreated: Boolean)
    begin
        if UserCreated then
          SendTraceTag('00001DL',InviteExternalAccountantTelemetryCategoryTxt,VERBOSITY::Normal,GetTelemetryCommonInformation +
            InviteExternalAccountantTelemetryCreateNewUserSuccessTxt,DATACLASSIFICATION::EndUserIdentifiableInformation)
        else
          SendTraceTag('00001DM',InviteExternalAccountantTelemetryCategoryTxt,VERBOSITY::Error,GetTelemetryCommonInformation +
            InviteExternalAccountantTelemetryCreateNewUserFailedTxt,DATACLASSIFICATION::EndUserIdentifiableInformation);
    end;

    [EventSubscriber(ObjectType::Page, 1156, 'OnGoToCompany', '', false, false)]
    local procedure SendTelemetryForAccountantHubGoToClient()
    begin
        SendTraceTag('00001HR',AccountantPortalTelemetryCategoryTxt,VERBOSITY::Normal,GetTelemetryCommonInformation +
          AccountantPortalTelemetryGoToCompanyTxt,DATACLASSIFICATION::EndUserIdentifiableInformation);
    end;

    local procedure GetTelemetryCommonInformation(): Text
    var
        Graph: DotNet GraphQuery;
        TenantDetail: DotNet TenantInfo;
    begin
        Graph := Graph.GraphQuery;
        TenantDetail := Graph.GetTenantDetail;
        exit(StrSubstNo(TenantTxt,TenantDetail.ObjectId) +
          StrSubstNo(CountryTxt,TenantDetail.CountryLetterCode) + StrSubstNo(UserTxt,UserId));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInvitationCreateNewUser(UserCreated: Boolean)
    begin
        // This event is called when the invitation process tries to create a user.
    end;
}

