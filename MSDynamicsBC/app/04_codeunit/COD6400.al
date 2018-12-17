codeunit 6400 "Flow Service Management"
{
    // version NAVW113.00

    // // Manages access to Microsoft Flow service API

    Permissions = TableData "Flow Service Configuration"=r;

    trigger OnRun()
    begin
    end;

    var
        FlowUrlProdTxt: Label 'https://flow.microsoft.com/', Locked=true;
        FlowUrlTip1Txt: Label 'https://tip1.flow.microsoft.com/', Locked=true;
        FlowUrlTip2Txt: Label 'https://tip2.flow.microsoft.com/', Locked=true;
        FlowARMResourceUrlTxt: Label 'https://management.core.windows.net/', Locked=true;
        AzureADGraphResourceUrlTxt: Label 'https://graph.windows.net', Locked=true;
        MicrosoftGraphResourceUrlTxt: Label 'https://graph.microsoft.com', Locked=true;
        FlowEnvironmentsProdApiTxt: Label 'https://management.azure.com/providers/Microsoft.ProcessSimple/environments?api-version=2016-11-01', Locked=true;
        FlowEnvironmentsTip1ApiTxt: Label 'https://tip1.api.powerapps.com/providers/Microsoft.PowerApps/environments?api-version=2016-11-01', Locked=true;
        FlowEnvironmentsTip2ApiTxt: Label 'https://tip2.api.powerapps.com/providers/Microsoft.PowerApps/environments?api-version=2016-11-01', Locked=true;
        GenericErr: Label 'An error occured while trying to access the Flow service. Please try again or contact your system administrator if the error persists.';
        FlowResourceNameTxt: Label 'Flow Services';
        FlowTemplatePageSizeTxt: Label '4', Locked=true;
        FlowTemplateDestinationNewTxt: Label 'new', Locked=true;
        FlowTemplateDestinationDetailsTxt: Label 'details', Locked=true;
        AzureAdMgt: Codeunit "Azure AD Mgt.";
        DotNetString: DotNet String;
        FlowPPEErr: Label 'Microsoft Flow integration is not supported outside of a PROD environment.';
        FlowAccessDeniedErr: Label 'Windows Azure Service Management API permissions need to be enabled for Flow in the Azure Portal. Contact your system administrator.';
        FlowLinkUrlFormatTxt: Label '%1manage/environments/%2/flows/%3/details', Locked=true;
        FlowManageLinkUrlFormatTxt: Label '%1manage/environments/%2/flows/', Locked=true;
        FlowLinkInvalidFlowIdErr: Label 'An invalid Flow ID was provided.';
        TemplateFilterTxt: Label 'Microsoft Dynamics 365 Business Central', Locked=true;
        SalesFilterTxt: Label 'Sales', Locked=true;
        PurchasingFilterTxt: Label 'Purchase', Locked=true;
        JournalFilterTxt: Label 'General Journal', Locked=true;
        CustomerFilterTxt: Label 'Customer', Locked=true;
        ItemFilterTxt: Label 'Item', Locked=true;
        VendorFilterTxt: Label 'Vendor', Locked=true;
        JObject: DotNet JObject;

    [Scope('Personalization')]
    procedure GetFlowUrl(): Text
    var
        FlowUrl: Text;
    begin
        if TryGetFlowUrl(FlowUrl) then
          exit(FlowUrl);

        exit(FlowUrlProdTxt);
    end;

    [Scope('Personalization')]
    procedure GetFlowEnvironmentsApi(): Text
    var
        FlowEnvironmentsApi: Text;
    begin
        if TryGetFlowEnvironmentsApi(FlowEnvironmentsApi) then
          exit(FlowEnvironmentsApi);

        exit(FlowEnvironmentsProdApiTxt);
    end;

    procedure GetLocale(): Text
    var
        CultureInfo: DotNet CultureInfo;
        TextInfo: DotNet TextInfo;
    begin
        CultureInfo := CultureInfo.CultureInfo(GlobalLanguage);
        TextInfo := CultureInfo.TextInfo;
        exit(LowerCase(TextInfo.CultureName));
    end;

    [Scope('Personalization')]
    procedure GetFlowDetailsUrl(FlowId: Guid) FlowDetailsUrl: Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        if IsNullGuid(FlowId) then
          Error(FlowLinkInvalidFlowIdErr);

        FlowDetailsUrl := StrSubstNo(FlowLinkUrlFormatTxt,GetFlowUrl,GetFlowEnvironmentID,TypeHelper.GetGuidAsString(FlowId));
    end;

    [Scope('Personalization')]
    procedure GetFlowManageUrl() Url: Text
    begin
        Url := StrSubstNo(FlowManageLinkUrlFormatTxt,GetFlowUrl,GetFlowEnvironmentID);
    end;

    [Scope('Personalization')]
    procedure GetFlowARMResourceUrl(): Text
    begin
        exit(FlowARMResourceUrlTxt);
    end;

    [Scope('Personalization')]
    procedure GetAzureADGraphhResourceUrl(): Text
    begin
        exit(AzureADGraphResourceUrlTxt);
    end;

    [Scope('Personalization')]
    procedure GetMicrosoftGraphhResourceUrl(): Text
    begin
        exit(MicrosoftGraphResourceUrlTxt);
    end;

    [Scope('Personalization')]
    procedure GetFlowResourceName(): Text
    begin
        exit(FlowResourceNameTxt);
    end;

    [Scope('Personalization')]
    procedure GetGenericError(): Text
    begin
        exit(GenericErr);
    end;

    [Scope('Personalization')]
    procedure GetFlowEnvironmentID() FlowEnvironmentId: Text
    var
        FlowUserEnvironmentConfig: Record "Flow User Environment Config";
    begin
        if FlowUserEnvironmentConfig.Get(UserSecurityId) then
          FlowEnvironmentId := FlowUserEnvironmentConfig."Environment ID"
        else begin
          SetSelectedFlowEnvironmentIDToDefault;
          if FlowUserEnvironmentConfig.Get(UserSecurityId) then
            FlowEnvironmentId := FlowUserEnvironmentConfig."Environment ID"
        end;
    end;

    [Scope('Personalization')]
    procedure GetFlowTemplatePageSize(): Text
    begin
        exit(FlowTemplatePageSizeTxt);
    end;

    [Scope('Personalization')]
    procedure GetFlowTemplateDestinationNew(): Text
    begin
        exit(FlowTemplateDestinationNewTxt);
    end;

    [Scope('Personalization')]
    procedure GetFlowTemplateDestinationDetails(): Text
    begin
        exit(FlowTemplateDestinationDetailsTxt);
    end;

    procedure IsUserReadyForFlow(): Boolean
    begin
        if not AzureAdMgt.IsAzureADAppSetupDone then
          exit(false);

        exit(not DotNetString.IsNullOrWhiteSpace(AzureAdMgt.GetAccessToken(GetFlowARMResourceUrl,GetFlowResourceName,false)));
    end;

    [Scope('Personalization')]
    procedure IsPPE(): Boolean
    var
        EnvironmentMgt: Codeunit "Environment Mgt.";
    begin
        exit(EnvironmentMgt.IsPPE);
    end;

    procedure GetFlowPPEError(): Text
    begin
        exit(FlowPPEErr);
    end;

    procedure GetTemplateFilter(): Text
    begin
        // Gets the default text value that filters Flow templates when opening page 6400.
        exit(TemplateFilterTxt);
    end;

    [Scope('Personalization')]
    procedure GetSalesTemplateFilter(): Text
    begin
        // Gets a text value that filters Flow templates for Sales pages when opening page 6400.
        exit(TemplateFilterTxt + ' ' + SalesFilterTxt);
    end;

    [Scope('Personalization')]
    procedure GetPurchasingTemplateFilter(): Text
    begin
        // Gets a text value that filters Flow templates for Purchasing pages when opening page 6400.
        exit(TemplateFilterTxt + ' ' + PurchasingFilterTxt);
    end;

    [Scope('Personalization')]
    procedure GetJournalTemplateFilter(): Text
    begin
        // Gets a text value that filters Flow templates for General Journal pages when opening page 6400.
        exit(TemplateFilterTxt + ' ' + JournalFilterTxt);
    end;

    [Scope('Personalization')]
    procedure GetCustomerTemplateFilter(): Text
    begin
        // Gets a text value that filters Flow templates for Customer pages when opening page 6400.
        exit(TemplateFilterTxt + ' ' + CustomerFilterTxt);
    end;

    [Scope('Personalization')]
    procedure GetItemTemplateFilter(): Text
    begin
        // Gets a text value that filters Flow templates for Item pages when opening page 6400.
        exit(TemplateFilterTxt + ' ' + ItemFilterTxt);
    end;

    [Scope('Personalization')]
    procedure GetVendorTemplateFilter(): Text
    begin
        // Gets a text value that filters Flow templates for Vendor pages when opening page 6400.
        exit(TemplateFilterTxt + ' ' + VendorFilterTxt);
    end;

    procedure GetSelectedFlowEnvironmentName() FlowEnvironmentName: Text
    var
        FlowUserEnvironmentConfig: Record "Flow User Environment Config";
    begin
        if FlowUserEnvironmentConfig.Get(UserSecurityId) then
          FlowEnvironmentName := FlowUserEnvironmentConfig."Environment Display Name"
        else begin
          SetSelectedFlowEnvironmentIDToDefault;
          if FlowUserEnvironmentConfig.Get(UserSecurityId) then
            FlowEnvironmentName := FlowUserEnvironmentConfig."Environment Display Name"
        end;
    end;

    procedure GetEnvironments(var TempFlowUserEnvironmentBuffer: Record "Flow User Environment Buffer" temporary)
    var
        WebRequestHelper: Codeunit "Web Request Helper";
        ResponseText: Text;
    begin
        // Gets a list of Flow user environments from the Flow API.
        if not WebRequestHelper.GetResponseText(
             'GET',GetFlowEnvironmentsApi,AzureAdMgt.GetAccessToken(FlowARMResourceUrlTxt,FlowResourceNameTxt,false),ResponseText)
        then
          Error(GenericErr);

        ParseResponseTextForEnvironments(ResponseText,TempFlowUserEnvironmentBuffer);
    end;

    procedure ParseResponseTextForEnvironments(ResponseText: Text;var TempFlowUserEnvironmentBuffer: Record "Flow User Environment Buffer" temporary)
    var
        FlowUserEnvironmentConfig: Record "Flow User Environment Config";
        Current: DotNet KeyValuePair_Of_T_U;
        JObj: DotNet JObject;
        JObjProp: DotNet JObject;
        ObjectEnumerator: DotNet IEnumerator;
        JArray: DotNet JArray;
        ArrayEnumerator: DotNet IEnumerator;
        JToken: DotNet JToken;
        JProperty: DotNet JProperty;
    begin
        // Parse the ResponseText from Flow environments api for a list of environments
        ObjectEnumerator := JObject.Parse(ResponseText).GetEnumerator;

        while ObjectEnumerator.MoveNext do begin
          Current := ObjectEnumerator.Current;

          if Format(Current.Key) = 'value' then begin
            JArray := Current.Value;
            ArrayEnumerator := JArray.GetEnumerator;

            while ArrayEnumerator.MoveNext do begin
              JObj := ArrayEnumerator.Current;
              JObjProp := JObj.SelectToken('properties');

              if not IsNull(JObjProp) then begin
                JProperty := JObjProp.Property('provisioningState');

                // only interested in those that succeeded
                if LowerCase(Format(JProperty.Value)) = 'succeeded' then begin
                  JToken := JObj.SelectToken('name');
                  JProperty := JObjProp.Property('displayName');

                  TempFlowUserEnvironmentBuffer.Init;
                  TempFlowUserEnvironmentBuffer."Environment ID" := JToken.ToString;
                  TempFlowUserEnvironmentBuffer."Environment Display Name" := Format(JProperty.Value);

                  // mark current environment as enabled/selected if it is currently the user selected environment
                  FlowUserEnvironmentConfig.Reset;
                  FlowUserEnvironmentConfig.SetRange("Environment ID",JToken.ToString);
                  FlowUserEnvironmentConfig.SetRange("User Security ID",UserSecurityId);
                  TempFlowUserEnvironmentBuffer.Enabled := FlowUserEnvironmentConfig.FindFirst;

                  // check if environment is the default
                  JProperty := JObjProp.Property('isDefault');
                  if LowerCase(Format(JProperty.Value)) = 'true' then
                    TempFlowUserEnvironmentBuffer.Default := true;

                  TempFlowUserEnvironmentBuffer.Insert;
                end;
              end;
            end;
          end;
        end;
    end;

    procedure SaveFlowUserEnvironmentSelection(var TempFlowUserEnvironmentBuffer: Record "Flow User Environment Buffer" temporary)
    var
        FlowUserEnvironmentConfig: Record "Flow User Environment Config";
    begin
        // User previously selected environment so update
        if FlowUserEnvironmentConfig.Get(UserSecurityId) then begin
          FlowUserEnvironmentConfig."Environment ID" := TempFlowUserEnvironmentBuffer."Environment ID";
          FlowUserEnvironmentConfig."Environment Display Name" := TempFlowUserEnvironmentBuffer."Environment Display Name";
          FlowUserEnvironmentConfig.Modify;

          exit;
        end;

        // User has no previous selection so add new one
        FlowUserEnvironmentConfig.Init;
        FlowUserEnvironmentConfig."User Security ID" := UserSecurityId;
        FlowUserEnvironmentConfig."Environment ID" := TempFlowUserEnvironmentBuffer."Environment ID";
        FlowUserEnvironmentConfig."Environment Display Name" := TempFlowUserEnvironmentBuffer."Environment Display Name";
        FlowUserEnvironmentConfig.Insert;
    end;

    procedure SetSelectedFlowEnvironmentIDToDefault()
    var
        TempFlowUserEnvironmentBuffer: Record "Flow User Environment Buffer" temporary;
        WebRequestHelper: Codeunit "Web Request Helper";
        ResponseText: Text;
        PostResult: Boolean;
    begin
        GetEnvironments(TempFlowUserEnvironmentBuffer);
        TempFlowUserEnvironmentBuffer.SetRange(Default,true);
        if TempFlowUserEnvironmentBuffer.FindFirst then
          SaveFlowUserEnvironmentSelection(TempFlowUserEnvironmentBuffer)
        else begin
          // No environment found so make a post call to create default environment. Post call returns error but actually creates environment
          PostResult := WebRequestHelper.GetResponseText(
              'POST',GetFlowEnvironmentsApi,AzureAdMgt.GetAccessToken(FlowARMResourceUrlTxt,FlowResourceNameTxt,false),ResponseText);

          if not PostResult then
            ; // Do nothing. Need to store the result of the POST call so that error from POST call doesn't bubble up. May need to look at this later.

          // we should have environments now so go ahead and set selected environment
          GetEnvironments(TempFlowUserEnvironmentBuffer);
          TempFlowUserEnvironmentBuffer.SetRange(Default,true);
          if TempFlowUserEnvironmentBuffer.FindFirst then
            SaveFlowUserEnvironmentSelection(TempFlowUserEnvironmentBuffer)
        end;
    end;

    procedure HasUserSelectedFlowEnvironment(): Boolean
    var
        FlowUserEnvironmentConfig: Record "Flow User Environment Config";
    begin
        exit(FlowUserEnvironmentConfig.Get(UserSecurityId));
    end;

    [EventSubscriber(ObjectType::Page, 6302, 'OnOAuthAccessDenied', '', false, false)]
    local procedure CheckOAuthAccessDenied(description: Text;resourceFriendlyName: Text)
    begin
        if StrPos(resourceFriendlyName,FlowResourceNameTxt) > 0 then begin
          if StrPos(description,'AADSTS65005') > 0 then
            Error(FlowAccessDeniedErr);
        end;
    end;

    [TryFunction]
    local procedure TryGetFlowUrl(var FlowUrl: Text)
    var
        FlowServiceConfiguration: Record "Flow Service Configuration";
    begin
        FlowUrl := FlowUrlProdTxt;
        if FlowServiceConfiguration.FindFirst then
          case FlowServiceConfiguration."Flow Service" of
            FlowServiceConfiguration."Flow Service"::"Testing Service (TIP 1)":
              FlowUrl := FlowUrlTip1Txt;
            FlowServiceConfiguration."Flow Service"::"Testing Service (TIP 2)":
              FlowUrl := FlowUrlTip2Txt;
          end;
    end;

    [TryFunction]
    local procedure TryGetFlowEnvironmentsApi(var FlowEnvironmentsApi: Text)
    var
        FlowServiceConfiguration: Record "Flow Service Configuration";
    begin
        FlowEnvironmentsApi := FlowEnvironmentsProdApiTxt;
        if FlowServiceConfiguration.FindFirst then
          case FlowServiceConfiguration."Flow Service" of
            FlowServiceConfiguration."Flow Service"::"Testing Service (TIP 1)":
              FlowEnvironmentsApi := FlowEnvironmentsTip1ApiTxt;
            FlowServiceConfiguration."Flow Service"::"Testing Service (TIP 2)":
              FlowEnvironmentsApi := FlowEnvironmentsTip2ApiTxt;
          end;
    end;
}

