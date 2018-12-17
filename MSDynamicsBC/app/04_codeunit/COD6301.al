codeunit 6301 "Power BI Service Mgt."
{
    // version NAVW113.00

    // // Manages access to the Power BI service API's (aka powerbi.com)


    trigger OnRun()
    begin
    end;

    var
        AzureAdMgt: Codeunit "Azure AD Mgt.";
        PowerBiApiResourceUrlTxt: Label 'https://analysis.windows.net/powerbi/api', Locked=true;
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
        JObject: DotNet JObject;
        DotNetString: DotNet String;
        PowerBiApiResourceUrlPPETxt: Label 'https://analysis.windows-int.net/powerbi/api', Locked=true;
        FinancialsResourceUrlTxt: Label 'https://api.financials.dynamics.com', Comment='Link to the Financials API';
        FinancialsResourceUrlPPETxt: Label 'https://api.financials.dynamics-servicestie.com', Comment='Link to the Financials API';
        ReportsUrlTxt: Label 'https://api.powerbi.com/beta/myorg/reports', Locked=true;
        ReportsUrlPPETxt: Label 'https://biazure-int-edog-redirect.analysis-df.windows.net/beta/myorg/reports', Locked=true;
        PowerBiApiUrlTxt: Label 'https://api.powerbi.com', Locked=true;
        PowerBiApiUrlPPETxt: Label 'https://biazure-int-edog-redirect.analysis-df.windows.net ', Locked=true;
        GenericErr: Label 'An error occurred while trying to get reports from the Power BI service. Please try again or contact your system administrator if the error persists.';
        PowerBiResourceNameTxt: Label 'Power BI Services';
        ReportPageSizeTxt: Label '16:9', Locked=true;
        PowerBIurlErr: Label 'https://powerbi.microsoft.com', Locked=true;
        UnauthorizedErr: Label 'You do not have a Power BI account. You can get a Power BI account at the following location.';
        NavAppSourceUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=862351', Locked=true;
        Dyn365AppSourceUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=862352', Locked=true;
        PowerBIMyOrgUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=862353', Locked=true;
        NullGuidTxt: Label '00000000-0000-0000-0000-000000000000';

    procedure GetReports(var TempPowerBIReportBuffer: Record "Power BI Report Buffer" temporary;var ExceptionMessage: Text;var ExceptionDetails: Text;Context: Text[30])
    var
        PowerBIReportConfiguration: Record "Power BI Report Configuration";
        DotNetExceptionHandler: Codeunit "DotNet Exception Handler";
        WebRequestHelper: Codeunit "Web Request Helper";
        JObj: DotNet JObject;
        ObjectEnumerator: DotNet IEnumerator;
        Current: DotNet KeyValuePair_Of_T_U;
        JArray: DotNet JArray;
        ArrayEnumerator: DotNet IEnumerator;
        JToken: DotNet JToken;
        HttpWebResponse: DotNet HttpWebResponse;
        WebException: DotNet WebException;
        HttpStatusCode: DotNet HttpStatusCode;
        Exception: DotNet Exception;
        Url: Text;
        "Key": Text;
        ResponseText: Text;
    begin
        // Gets a list of reports from the user's Power BI account and loads them into the given buffer.
        // Reports are marked as Enabled if they've previously been selected for the given context (page ID).
        if not TempPowerBIReportBuffer.IsEmpty then
          exit;

        if not CanHandleServiceCalls then begin
          OnGetReports(TempPowerBIReportBuffer,ExceptionMessage,ExceptionDetails,Context);
          exit;
        end;

        if IsPPE then
          Url := ReportsUrlPPETxt
        else
          Url := ReportsUrlTxt;

        if not WebRequestHelper.GetResponseText(
             'GET',Url,AzureAdMgt.GetAccessToken(GetPowerBiResourceUrl,GetPowerBiResourceName,false),ResponseText)
        then begin
          Exception := GetLastErrorObject;
          ExceptionMessage := Exception.Message;
          ExceptionDetails := Exception.ToString;

          DotNetExceptionHandler.Collect;
          if DotNetExceptionHandler.CastToType(WebException,GetDotNetType(WebException)) then begin
            HttpWebResponse := WebException.Response;
            HttpStatusCode := HttpWebResponse.StatusCode;

            if HttpWebResponse.StatusCode = 401 then
              Error(UnauthorizedErr);
          end else
            Error(GenericErr);
        end;

        JObj := JObject.Parse(ResponseText); // TODO: check versions

        ObjectEnumerator := JObj.GetEnumerator;

        while ObjectEnumerator.MoveNext do begin
          Current := ObjectEnumerator.Current;
          Key := Current.Key;

          if Key = 'value' then begin
            JArray := Current.Value;
            ArrayEnumerator := JArray.GetEnumerator;

            while ArrayEnumerator.MoveNext do begin
              JObj := ArrayEnumerator.Current;
              TempPowerBIReportBuffer.Init;

              // report GUID identifier
              JToken := JObj.SelectToken('id');
              Evaluate(TempPowerBIReportBuffer.ReportID,JToken.ToString);

              // report name
              JToken := JObj.SelectToken('name');
              TempPowerBIReportBuffer.ReportName := JToken.ToString;

              // report embedding url
              JToken := JObj.SelectToken('embedUrl');
              TempPowerBIReportBuffer.EmbedUrl := JToken.ToString;

              // report enabled
              TempPowerBIReportBuffer.Enabled := PowerBIReportConfiguration.Get(UserSecurityId,TempPowerBIReportBuffer.ReportID,Context);

              TempPowerBIReportBuffer.Insert;
            end;
          end
        end;
    end;

    procedure IsUserReadyForPowerBI(): Boolean
    begin
        if not AzureAdMgt.IsAzureADAppSetupDone then
          exit(false);

        exit(not DotNetString.IsNullOrWhiteSpace(AzureAdMgt.GetAccessToken(GetPowerBiResourceUrl,GetPowerBiResourceName,false)));
    end;

    procedure UserHasMissingReportUrls(Context: Text[30]): Boolean
    var
        PowerBIReportConfiguration: Record "Power BI Report Configuration";
    begin
        // Checks whether the user has any reports with blank URLs, for the current context (to be used by spinner/factbox).
        // These would be Report Configuration (table 6301) rows created before the addition of the URL column, so they
        // don't have a cached URL we can load. In that case we need to load reports the old fashioned way, from the PBI
        // service with a GetReports call. (Empty URLs like this only get updated on running the Select Reports page.)
        PowerBIReportConfiguration.SetFilter("User Security ID",UserSecurityId);
        PowerBIReportConfiguration.SetFilter(Context,Context);
        PowerBIReportConfiguration.SetFilter(EmbedUrl,'=%1','');
        exit(not PowerBIReportConfiguration.IsEmpty);
    end;

    procedure GetCachedReports(var TempPowerBiReportBuffer: Record "Power BI Report Buffer" temporary;Context: Text[30])
    var
        PowerBIReportConfiguration: Record "Power BI Report Configuration";
    begin
        // Gets the user's enabled reports from the Report Configuration table, rather than getting the full report
        // list from the PBI service (this means it's faster but theoretically could include reports the user has
        // deleted since the last time they logged in - can't detect that until they visit the Select Reports page.)
        TempPowerBiReportBuffer.DeleteAll;

        PowerBIReportConfiguration.Reset;
        PowerBIReportConfiguration.SetFilter("User Security ID",UserSecurityId);
        PowerBIReportConfiguration.SetFilter(Context,Context);

        if PowerBIReportConfiguration.Find('-') then
          repeat
            if PowerBIReportConfiguration.EmbedUrl <> '' then begin
              TempPowerBiReportBuffer.ReportID := PowerBIReportConfiguration."Report ID";
              TempPowerBiReportBuffer.EmbedUrl := PowerBIReportConfiguration.EmbedUrl;
              TempPowerBiReportBuffer.Enabled := true;
              TempPowerBiReportBuffer.Insert;
            end;
          until PowerBIReportConfiguration.Next = 0;
    end;

    [Scope('Personalization')]
    procedure GetPowerBiResourceUrl(): Text
    begin
        if IsPPE then
          exit(PowerBiApiResourceUrlPPETxt);

        exit(PowerBiApiResourceUrlTxt);
    end;

    [Scope('Personalization')]
    procedure GetPowerBiResourceName(): Text
    begin
        exit(PowerBiResourceNameTxt);
    end;

    [Scope('Personalization')]
    procedure GetGenericError(): Text
    begin
        exit(GenericErr);
    end;

    local procedure IsPPE(): Boolean
    var
        EnvironmentMgt: Codeunit "Environment Mgt.";
    begin
        exit(EnvironmentMgt.IsPPE);
    end;

    [Scope('Personalization')]
    procedure GetReportPageSize(): Text
    begin
        exit(ReportPageSizeTxt);
    end;

    [Scope('Personalization')]
    procedure GetUnauthorizedErrorText(): Text
    begin
        exit(UnauthorizedErr);
    end;

    [Scope('Personalization')]
    procedure GetPowerBIUrl(): Text
    begin
        exit(PowerBIurlErr);
    end;

    [Scope('Personalization')]
    procedure GetContentPacksServicesUrl(): Text
    var
        AzureADMgt: Codeunit "Azure AD Mgt.";
    begin
        // Gets the URL for AppSource's list of content packs, like Power BI's Services button, filtered to Dynamics reports.
        if AzureADMgt.IsSaaS then
          exit(Dyn365AppSourceUrlTxt);

        exit(NavAppSourceUrlTxt);
    end;

    [Scope('Personalization')]
    procedure GetContentPacksMyOrganizationUrl(): Text
    begin
        // Gets the URL for Power BI's embedded AppSource page listing reports shared by the user's organization.
        exit(PowerBIMyOrgUrlTxt);
    end;

    procedure UploadDefaultReportsInBackground()
    begin
        // Schedules a background task to do default report deployment (codeunit 6311 which calls back into
        // the UploadAllDefaultReports method in this codeunit).
        SetIsDeployingReports(true);
        TASKSCHEDULER.CreateTask(CODEUNIT::"PBI Start Uploads Task",CODEUNIT::"PBI Deployment Failure",true);
    end;

    procedure UploadAllDefaultReports()
    var
        Continue: Boolean;
    begin
        // Does a series of batches to deploy all default reports that the current user hasn't deployed yet.
        // Prioritizes the active role center over other reports since the user will probably see those first.
        // Ends early if anything failed, which makes it more likely we'll retry soon instead of having to wait
        // for all lower priority reports to finish first (retries started by page 6303).
        // Should only be called as part of a background session to reduce perf impact (see UploadDefaultReportsInBackground).
        Continue := UploadDefaultReportBatch(ConfPersonalizationMgt.GetCurrentProfileIDNoError,false);
        if Continue then
          Continue := UploadDefaultReportBatch('',true);

        if Continue then
          Continue := UploadDefaultReportBatch('',false);

        SetIsDeployingReports(false);
    end;

    local procedure UploadDefaultReportBatch(PriorityContext: Text[30];PrioritizeAnyContext: Boolean) WasSuccessful: Boolean
    var
        PowerBIBlob: Record "Power BI Blob";
        PowerBIReportUploads: Record "Power BI Report Uploads";
        PowerBICustomerReports: Record "Power BI Customer Reports";
        IntelligentCloud: Record "Intelligent Cloud";
        PbiServiceWrapper: DotNet ServiceWrapper;
        ApiRequest: DotNet ImportReportRequest;
        ApiRequestList: DotNet ImportReportRequestList;
        ApiResponseList: DotNet ImportReportResponseList;
        ApiResponse: DotNet ImportReportResponse;
        DotNetDateTime: DotNet DateTime;
        BlobStream: InStream;
        AzureAccessToken: Text;
        FinancialsAccessToken: Text;
    begin
        // Uploads a batch of default reports based on the passed in priorities (see DoesDefaultReportMatchPriority).
        // Returns true if all attempted uploads completely finished, otherwise false.
        if not IsPBIServiceAvailable then
          exit(false);
        WasSuccessful := true;
        ApiRequestList := ApiRequestList.ImportReportRequestList();
        PowerBIBlob.Reset;
        if PowerBIBlob.Find('-') then
          repeat
            if (DoesDefaultReportMatchPriority(PowerBIBlob.Id,PriorityContext,PrioritizeAnyContext) and
                CanUserAccessDefaultReport(PowerBIBlob.Id))
            then begin
              PowerBIReportUploads.Reset;
              PowerBIReportUploads.SetFilter("User ID",UserSecurityId);
              PowerBIReportUploads.SetFilter("PBIX BLOB ID",PowerBIBlob.Id);
              if (PowerBIReportUploads.IsEmpty and not IntelligentCloud.Get and not PowerBIBlob."GP Enabled") or
                 (PowerBIReportUploads.FindFirst and (PowerBIReportUploads."Deployed Version" <> PowerBIBlob.Version) and
                  not PowerBIReportUploads."Needs Deletion") or (IntelligentCloud.Get and PowerBIBlob."GP Enabled")
              then begin
                PowerBIBlob.CalcFields("Blob File"); // Calcfields necessary for accessing stored Blob bytes.
                PowerBIBlob."Blob File".CreateInStream(BlobStream);
                ApiRequest := ApiRequest.ImportReportRequest
                  (PowerBIBlob.Id,BlobStream,PowerBIBlob.Name,not PowerBIReportUploads.IsEmpty);
                ApiRequestList.Add(ApiRequest);
              end;
            end;
          until PowerBIBlob.Next = 0;
        if not PowerBICustomerReports.IsEmpty then begin
          PowerBICustomerReports.Reset;
          if PowerBICustomerReports.Find('-') then
            repeat
              PowerBIReportUploads.Reset;
              PowerBIReportUploads.SetFilter("User ID",UserSecurityId);
              PowerBIReportUploads.SetFilter("PBIX BLOB ID",PowerBICustomerReports.Id);
              if PowerBIReportUploads.IsEmpty or (PowerBIReportUploads.FindFirst and
                                                  (PowerBIReportUploads."Deployed Version" <> PowerBICustomerReports.Version) and
                                                  not PowerBIReportUploads."Needs Deletion")
              then begin
                PowerBICustomerReports.CalcFields("Blob File"); // Calcfields necessary for accessing stored Blob bytes.
                PowerBICustomerReports."Blob File".CreateInStream(BlobStream);
                ApiRequest := ApiRequest.ImportReportRequest
                  (PowerBICustomerReports.Id,BlobStream,PowerBICustomerReports.Name,not PowerBIReportUploads.IsEmpty);
                ApiRequestList.Add(ApiRequest);
              end;
            until PowerBICustomerReports.Next = 0;
        end;
        if ApiRequestList.Count > 0 then begin
          if CanHandleServiceCalls then begin
            AzureAccessToken := AzureAdMgt.GetAccessToken(GetPowerBiResourceUrl,GetPowerBiResourceName,false);

            if IsPPE then begin
              PbiServiceWrapper := PbiServiceWrapper.ServiceWrapper(AzureAccessToken,PowerBiApiUrlPPETxt);
              FinancialsAccessToken := AzureAdMgt.GetAccessToken(FinancialsResourceUrlPPETxt,'',false)
            end else begin
              PbiServiceWrapper := PbiServiceWrapper.ServiceWrapper(AzureAccessToken,PowerBiApiUrlTxt);
              FinancialsAccessToken := AzureAdMgt.GetAccessToken(FinancialsResourceUrlTxt,'',false);
            end;

            ApiResponseList := PbiServiceWrapper.ImportReports(ApiRequestList,
                CompanyName,FinancialsAccessToken,GetServiceRetries);
          end else begin
            ApiResponseList := ApiResponseList.ImportReportResponseList();
            OnUploadReports(ApiRequestList,ApiResponseList);
          end;
          foreach ApiResponse in ApiResponseList do
            WasSuccessful := WasSuccessful and HandleUploadResponse(ApiResponse.ImportId,ApiResponse.RequestReportId,
                ApiResponse.ImportedReport,ApiResponse.ShouldRetry,ApiResponse.RetryAfter);

          if not IsNull(ApiResponseList.RetryAfter) then begin
            WasSuccessful := false;
            DotNetDateTime := ApiResponseList.RetryAfter;
            UpdatePBIServiceAvailability(DotNetDateTime);
          end;
        end;
    end;

    procedure RetryUnfinishedReportsInBackground()
    begin
        // Schedules a background task to do completion of partial uploads (codeunit 6312 which calls
        // back into the RetryAllPartialReportUploads method in this codeunit).
        SetIsRetryingUploads(true);
        TASKSCHEDULER.CreateTask(CODEUNIT::"PBI Retry Uploads Task",CODEUNIT::"PBI Retry Failure",true);
    end;

    procedure RetryAllPartialReportUploads()
    begin
        // Starts a sequence of default report deployments for any reports that only partially finished.
        // Prioritizes the active role center over other reports since the user will probably see those first.
        // Unlike UploadAllDefaultReports, doesn't end early if anything failed - want to avoid getting stuck
        // on a faulty report.
        // Should only be called as part of a background session to reduce perf impact (see RetryUnfinishedReportsInBackground).
        RetryPartialUploadBatch(ConfPersonalizationMgt.GetCurrentProfileIDNoError,false);
        RetryPartialUploadBatch('',false);

        SetIsRetryingUploads(false);
    end;

    local procedure RetryPartialUploadBatch(PriorityContext: Text[30];PrioritizeAnyContext: Boolean) WasSuccessful: Boolean
    var
        PowerBIReportUploads: Record "Power BI Report Uploads";
        PbiServiceWrapper: DotNet ServiceWrapper;
        ImportIdList: DotNet ImportedReportRequestList;
        ApiResponseList: DotNet ImportedReportResponseList;
        ApiResponse: DotNet ImportedReportResponse;
        DotNetDateTime: DotNet DateTime;
        AzureAccessToken: Text;
        FinancialsAccessToken: Text;
    begin
        // Retries a batch of default reports that have had their uploads started but not finished, based on
        // the passed in priority (see DoesDefaultReportMatchPriority). This will attempt to have the PBI service
        // retry the connection/refresh tasks to finish the upload process.
        // Returns true if all attempted retries completely finished, otherwise false.
        if not IsPBIServiceAvailable then
          exit(false);

        WasSuccessful := true;
        ImportIdList := ImportIdList.ImportedReportRequestList();

        PowerBIReportUploads.Reset;
        PowerBIReportUploads.SetFilter("User ID",UserSecurityId);
        PowerBIReportUploads.SetFilter("Uploaded Report ID",NullGuidTxt);
        PowerBIReportUploads.SetFilter("Should Retry",'%1',true);
        PowerBIReportUploads.SetFilter("Retry After",'<%1',CurrentDateTime);
        PowerBIReportUploads.SetFilter("Needs Deletion",'%1',false);
        if PowerBIReportUploads.Find('-') then
          repeat
            if DoesDefaultReportMatchPriority(PowerBIReportUploads."PBIX BLOB ID",PriorityContext,PrioritizeAnyContext) and
               CanUserAccessDefaultReport(PowerBIReportUploads."PBIX BLOB ID")
            then
              ImportIdList.Add(PowerBIReportUploads."Import ID");
          until PowerBIReportUploads.Next = 0;

        if ImportIdList.Count > 0 then begin
          if CanHandleServiceCalls then begin
            AzureAccessToken := AzureAdMgt.GetAccessToken(GetPowerBiResourceUrl,GetPowerBiResourceName,false);

            if IsPPE then begin
              PbiServiceWrapper := PbiServiceWrapper.ServiceWrapper(AzureAccessToken,PowerBiApiUrlPPETxt);
              FinancialsAccessToken := AzureAdMgt.GetAccessToken(FinancialsResourceUrlPPETxt,'',false)
            end else begin
              PbiServiceWrapper := PbiServiceWrapper.ServiceWrapper(AzureAccessToken,PowerBiApiUrlTxt);
              FinancialsAccessToken := AzureAdMgt.GetAccessToken(FinancialsResourceUrlTxt,'',false);
            end;

            ApiResponseList := PbiServiceWrapper.GetImportedReports(ImportIdList,
                CompanyName,FinancialsAccessToken,GetServiceRetries);
          end else begin
            ApiResponseList := ApiResponseList.ImportedReportResponseList();
            OnRetryUploads(ImportIdList,ApiResponseList);
          end;
          foreach ApiResponse in ApiResponseList do
            WasSuccessful := WasSuccessful and HandleUploadResponse(ApiResponse.ImportId,NullGuidTxt,ApiResponse.ImportedReport,
                ApiResponse.ShouldRetry,ApiResponse.RetryAfter);

          if not IsNull(ApiResponseList.RetryAfter) then begin
            WasSuccessful := false;
            DotNetDateTime := ApiResponseList.RetryAfter;
            UpdatePBIServiceAvailability(DotNetDateTime);
          end;
        end;
    end;

    local procedure HandleUploadResponse(ImportId: Text;BlobId: Guid;ReturnedReport: DotNet ImportedReport;ShouldRetry: DotNet Nullable_Of_T;RetryAfter: DotNet Nullable_Of_T) WasSuccessful: Boolean
    var
        PowerBIBlob: Record "Power BI Blob";
        PowerBIReportUploads: Record "Power BI Report Uploads";
        PowerBICustomerReports: Record "Power BI Customer Reports";
        DotNetBoolean: DotNet Boolean;
        DotNetDateTime: DotNet DateTime;
    begin
        // Deals with individual responses from the Power BI service for importing or finishing imports of
        // default reports. This is what updates the tables so we know which reports are actually ready
        // to be selected, versus still needing work, depending on the info sent back by the service.
        // Returns true if the upload completely finished (i.e. got a report ID back), otherwise false.
        if ImportId <> '' then begin
          PowerBIReportUploads.Reset;
          PowerBIReportUploads.SetFilter("User ID",UserSecurityId);

          // Empty blob ID happens when we're finishing a partial upload (existing record in table 6307).
          if IsNullGuid(BlobId) then
            PowerBIReportUploads.SetFilter("Import ID",ImportId)
          else
            PowerBIReportUploads.SetFilter("PBIX BLOB ID",BlobId);

          if PowerBIReportUploads.IsEmpty then begin
            // First time this report has been uploaded.
            PowerBIReportUploads.Init;
            PowerBIReportUploads."PBIX BLOB ID" := BlobId;
            PowerBIReportUploads."User ID" := UserSecurityId;
            PowerBIReportUploads."Is Selection Done" := false;
          end else
            // Overwriting or finishing a previously uploaded report.
            PowerBIReportUploads.FindFirst;

          if not IsNull(ReturnedReport) then begin
            WasSuccessful := true;
            PowerBIReportUploads."Uploaded Report ID" := ReturnedReport.ReportId;
            PowerBIReportUploads."Embed Url" := ReturnedReport.EmbedUrl;
            PowerBIReportUploads."Import ID" := NullGuidTxt;
            PowerBIReportUploads."Should Retry" := false;
            PowerBIReportUploads."Retry After" := 0DT;
          end else begin
            WasSuccessful := false;
            PowerBIReportUploads."Import ID" := ImportId;
            PowerBIReportUploads."Uploaded Report ID" := NullGuidTxt;
            if not IsNull(ShouldRetry) then begin
              DotNetBoolean := ShouldRetry;
              PowerBIReportUploads."Should Retry" := DotNetBoolean.Equals(true);
            end;
            if not IsNull(RetryAfter) then begin
              DotNetDateTime := RetryAfter;
              PowerBIReportUploads."Retry After" := DotNetDateTime;
            end;
          end;

          if PowerBIBlob.Get(PowerBIReportUploads."PBIX BLOB ID") then begin
            PowerBIReportUploads."Deployed Version" := PowerBIBlob.Version;
            PowerBIReportUploads.IsGP := PowerBIBlob."GP Enabled";
          end else
            if PowerBICustomerReports.Get(PowerBIReportUploads."PBIX BLOB ID") then
              PowerBIReportUploads."Deployed Version" := PowerBICustomerReports.Version;

          if PowerBIReportUploads.IsEmpty then
            PowerBIReportUploads.Insert
          else
            PowerBIReportUploads.Modify;
          Commit;
        end;
    end;

    procedure SelectDefaultReports()
    var
        PowerBIDefaultSelection: Record "Power BI Default Selection";
        PowerBIReportConfiguration: Record "Power BI Report Configuration";
        PowerBIUserConfiguration: Record "Power BI User Configuration";
        PowerBIReportUploads: Record "Power BI Report Uploads";
        IntelligentCloud: Record "Intelligent Cloud";
    begin
        // Finds all recently uploaded default reports and enables/selects them on the appropriate pages
        // per table 2000000145.
        // (Note that each report only gets auto-selection done one time - if the user later deselects it
        // we won't keep reselecting it.)

        // If the GP flag is set in TAB2000000146, the report for the selected page/role center is removed
        // and we select the GP report
        PowerBIReportUploads.Reset;
        PowerBIReportUploads.SetFilter("User ID",UserSecurityId);
        PowerBIReportUploads.SetFilter("Uploaded Report ID",'<>%1',NullGuidTxt);
        PowerBIReportUploads.SetFilter("Is Selection Done",'%1',false);
        if IntelligentCloud.Get then
          PowerBIReportUploads.SetFilter(IsGP,'%1',true)
        else
          PowerBIReportUploads.SetFilter(IsGP,'%1',false);
        if PowerBIReportUploads.Find('-') then
          repeat
            PowerBIReportUploads."Is Selection Done" := true;
            PowerBIReportUploads.Modify;

            PowerBIDefaultSelection.Reset;
            PowerBIDefaultSelection.SetFilter(Id,PowerBIReportUploads."PBIX BLOB ID");
            if PowerBIDefaultSelection.Find('-') then
              repeat
                if CanUserAccessPage(PowerBIDefaultSelection.Context) then begin
                  PowerBIReportConfiguration.Reset;
                  PowerBIReportConfiguration.SetFilter("User Security ID",UserSecurityId);
                  PowerBIReportConfiguration.SetFilter("Report ID",PowerBIReportUploads."Uploaded Report ID");
                  PowerBIReportConfiguration.SetFilter(Context,PowerBIDefaultSelection.Context);
                  if not PowerBIReportConfiguration.IsEmpty then
                    PowerBIReportConfiguration.Delete;
                  PowerBIReportConfiguration.Init;
                  PowerBIReportConfiguration."User Security ID" := UserSecurityId;
                  PowerBIReportConfiguration."Report ID" := PowerBIReportUploads."Uploaded Report ID";
                  PowerBIReportConfiguration.EmbedUrl := PowerBIReportUploads."Embed Url";
                  PowerBIReportConfiguration.Context := PowerBIDefaultSelection.Context;
                  if PowerBIReportConfiguration.Insert then;
                end;

                if PowerBIDefaultSelection.Selected then begin
                  PowerBIUserConfiguration.Reset;
                  PowerBIUserConfiguration.SetFilter("User Security ID",UserSecurityId);
                  PowerBIUserConfiguration.SetFilter("Page ID",PowerBIDefaultSelection.Context);
                  PowerBIUserConfiguration.SetFilter("Profile ID",ConfPersonalizationMgt.GetCurrentProfileIDNoError);

                  // Don't want to override user's existing selections (e.g. in upgrade scenarios).
                  if PowerBIUserConfiguration.IsEmpty then begin
                    PowerBIUserConfiguration.Init;
                    PowerBIUserConfiguration."User Security ID" := UserSecurityId;
                    PowerBIUserConfiguration."Page ID" := PowerBIDefaultSelection.Context;
                    PowerBIUserConfiguration."Profile ID" := ConfPersonalizationMgt.GetCurrentProfileIDNoError;
                    PowerBIUserConfiguration."Selected Report ID" := PowerBIReportUploads."Uploaded Report ID";
                    PowerBIUserConfiguration."Report Visibility" := true;
                    PowerBIUserConfiguration.Insert;
                  end else begin
                    // Modify existing selection if entry exists but no report selected (e.g. active page created
                    // empty configuration entry on page load before upload code even runs).
                    PowerBIUserConfiguration.FindFirst;
                    if IsNullGuid(PowerBIUserConfiguration."Selected Report ID") then begin
                      PowerBIUserConfiguration."Selected Report ID" := PowerBIReportUploads."Uploaded Report ID";
                      PowerBIUserConfiguration.Modify;
                    end;
                  end;

                  Commit;
                end;
              until PowerBIDefaultSelection.Next = 0;
          until PowerBIReportUploads.Next = 0;
    end;

    procedure DeleteDefaultReportsInBackground()
    begin
        // Schedules a background task to do default report deletion (codeunit 6315 which calls back into
        // the DeleteMarkedDefaultReports method in this codeunit).
        SetIsDeletingReports(true);
        TASKSCHEDULER.CreateTask(CODEUNIT::"PBI Start Deletions Task",CODEUNIT::"PBI Deletion Failure",true);
    end;

    procedure DeleteMarkedDefaultReports()
    var
        PowerBIReportUploads: Record "Power BI Report Uploads";
        PowerBICustomerReports: Record "Power BI Customer Reports";
    begin
        // Deletes a batch of default reports that have been marked for deletion for the current user. Reports are
        // deleted from the user's Power BI workspace first, and then removed from the uploads table if that was
        // successful.
        // Should only be called as part of a background session to reduce perf impact (see DeleteDefaultReportsInBackground).
        if not IsPBIServiceAvailable then
          exit;

        PowerBIReportUploads.Reset;
        PowerBIReportUploads.SetFilter("User ID",UserSecurityId);
        PowerBIReportUploads.SetFilter("Needs Deletion",'%1',true);

        if PowerBIReportUploads.Find('-') then
          repeat
            PowerBICustomerReports.Reset;
            PowerBICustomerReports.SetFilter(Id,PowerBIReportUploads."PBIX BLOB ID");
            repeat
              if PowerBICustomerReports.Id = PowerBIReportUploads."PBIX BLOB ID" then
                PowerBICustomerReports.Delete;
            until PowerBICustomerReports.Next = 0;
            PowerBIReportUploads.Delete;
          until PowerBIReportUploads.Next = 0;

        // TODO: Delete from ReportConfiguration table and replace with null GUID in UserConfiguration table.
        // TODO: ^^^ may confuse page 6303 depending on timing?
        // TODO: Only do after API says it was deleted from workspace successfully (below)

        // REPEAT
        // IF NOT ISNULLGUID(PowerBIReportUploads."Uploaded Report ID") THEN BEGIN
        // TODO: Add Uploaded Report ID to API request list
        // END;

        // IF NOT ISNULLGUID(PowerBIReportUploads."Import ID") THEN BEGIN
        // TODO: Add Import ID to API request list
        // END;
        // UNTIL PowerBIReportUploads.NEXT = 0;

        // TODO: Send list of IDs to PBI API to try deleting those reports.
        // TODO: For each successfully delete report according to the API return, delete that row now.
        // TODO: Set service availability depending on API's response.

        SetIsDeletingReports(false);
    end;

    procedure UserNeedsToDeployReports(): Boolean
    var
        PowerBIBlob: Record "Power BI Blob";
        PowerBIReportUploads: Record "Power BI Report Uploads";
        PowerBICustomerReports: Record "Power BI Customer Reports";
        IntelligentCloud: Record "Intelligent Cloud";
    begin
        // Checks whether the user has any un-uploaded OOB reports, by checking for rows in table 2000000144
        // without corresponding rows in table 6307 yet (or rows that are an old version).
        PowerBIBlob.Reset;
        if PowerBIBlob.Find('-') then
          repeat
            if CanUserAccessDefaultReport(PowerBIBlob.Id) and ((not PowerBIBlob."GP Enabled" and not IntelligentCloud.Get) or
                                                               (PowerBIBlob."GP Enabled" and IntelligentCloud.Get))
            then begin
              PowerBIReportUploads.Reset;
              PowerBIReportUploads.SetFilter("User ID",UserSecurityId);
              PowerBIReportUploads.SetFilter("PBIX BLOB ID",PowerBIBlob.Id);

              if PowerBIReportUploads.IsEmpty then
                exit(true);

              PowerBIReportUploads.FindFirst;
              if PowerBIReportUploads."Deployed Version" < PowerBIBlob.Version then
                exit(true);
            end;
          until PowerBIBlob.Next = 0;

        PowerBICustomerReports.Reset;
        if PowerBICustomerReports.Find('-') then
          repeat
            PowerBIReportUploads.Reset;
            PowerBIReportUploads.SetFilter("User ID",UserSecurityId);
            PowerBIReportUploads.SetFilter("PBIX BLOB ID",PowerBICustomerReports.Id);

            if PowerBIReportUploads.IsEmpty then
              exit(true);

            PowerBIReportUploads.FindFirst;
            if PowerBIReportUploads."Deployed Version" < PowerBICustomerReports.Version then
              exit(true);

          until PowerBICustomerReports.Next = 0;

        exit(false);
    end;

    procedure UserNeedsToRetryUploads(): Boolean
    var
        PowerBIReportUploads: Record "Power BI Report Uploads";
    begin
        // Checks whether the user has any partially deployed OOB reports that we need to finish the upload
        // process on (probably because it errored out partway through) i.e. rows in table 6307 that don't
        // have a final report ID from the PBI website yet.
        if not IsPBIServiceAvailable or IsUserRetryingUploads then
          exit(false);

        PowerBIReportUploads.Reset;
        PowerBIReportUploads.SetFilter("User ID",UserSecurityId);
        PowerBIReportUploads.SetFilter("Uploaded Report ID",NullGuidTxt);
        PowerBIReportUploads.SetFilter("Should Retry",'%1',true);
        PowerBIReportUploads.SetFilter("Retry After",'<%1',CurrentDateTime);
        exit(not PowerBIReportUploads.IsEmpty);
    end;

    procedure UserNeedsToDeleteReports(): Boolean
    var
        PowerBIReportUploads: Record "Power BI Report Uploads";
    begin
        // Checks whether the user has any uploaded OOB reports (including partially uploaded but not successfully
        // refreshed) by checking for rows in table 6307 with Needs Deletion set to TRUE.
        if not IsPBIServiceAvailable or IsUserDeletingReports then
          exit(false);

        PowerBIReportUploads.Reset;
        PowerBIReportUploads.SetFilter("User ID",UserSecurityId);
        PowerBIReportUploads.SetFilter("Needs Deletion",'%1',true);
        exit(not PowerBIReportUploads.IsEmpty);
    end;

    local procedure GetPageNumberFromContext(Context: Text[30]): Integer
    var
        PageNumber: Integer;
    begin
        // Pulls the page ID from the given context value if it's in an appropriate format,
        // or 0 if it couldn't tell. (Expect the values given to us by the pages' runtime code
        // to be e.g. "Page 22" for typical pages, vs. e.g. "ORDER PROCESSOR" for role centers.)
        if StrPos(Context,'Page') = 1 then
          if Evaluate(PageNumber,CopyStr(Context,6)) then
            exit(PageNumber);

        exit(0);
    end;

    local procedure CanUserAccessPage(Context: Text[30]): Boolean
    var
        PageMetadata: Record "Page Metadata";
        RecordRef: RecordRef;
        PageNumber: Integer;
    begin
        // Checks if the user has permission to view a given page, based on its source table,
        // so we know whether or not to deploy reports to that page. Pages are identified by
        // the Context value like we use for the PBI selection tables.
        // Automatically returns True if the page has no source table, or if the context isn't
        // in a format where we can find page ID (e.g. role center names), since we don't have
        // a good way to actually check those permissions in those cases. Page IDs that can't be
        // found in the page metadata table return False because they don't appear to exist.
        PageNumber := GetPageNumberFromContext(Context);
        if PageNumber = 0 then
          exit(true);

        PageMetadata.SetRange(ID,PageNumber);
        if PageMetadata.FindFirst then begin
          if PageMetadata.SourceTable = 0 then
            exit(true);

          RecordRef.Open(PageMetadata.SourceTable);
          exit(RecordRef.ReadPermission);
        end;

        exit(false);
    end;

    procedure CanUserAccessDefaultReport(ReportBlobID: Guid): Boolean
    var
        PowerBIDefaultSelection: Record "Power BI Default Selection";
    begin
        // Checks if the user should be able to deploy and access the given default report. The
        // user has permissions to the report if they have permissions to at least one page that
        // the report will be initially visible on, or if the report just won't be on any pages.
        PowerBIDefaultSelection.Reset;
        PowerBIDefaultSelection.SetFilter(Id,ReportBlobID);
        if PowerBIDefaultSelection.Find('-') then begin
          repeat
            if CanUserAccessPage(PowerBIDefaultSelection.Context) then
              exit(true);
          until PowerBIDefaultSelection.Next = 0;

          exit(false);
        end;

        exit(true);
    end;

    local procedure DoesDefaultReportMatchPriority(ReportBlobId: Guid;Context: Text[30];PrioritizeAnyContext: Boolean): Boolean
    var
        PowerBIDefaultSelection: Record "Power BI Default Selection";
    begin
        // Checks if the given default report should be deployed in the current batch, based on the
        // given priority. Returns true if Context is non-empty and the report matches that page,
        // or if PrioritizeAnyContext is true and the report matches at least one page, or if no
        // contexts are being prioritized at all (i.e. deploying all reports).
        PowerBIDefaultSelection.Reset;
        PowerBIDefaultSelection.SetFilter(Id,ReportBlobId);

        if Context <> '' then begin
          PowerBIDefaultSelection.SetFilter(Context,Context);
          exit(not PowerBIDefaultSelection.IsEmpty);
        end;

        if PrioritizeAnyContext then
          exit(not PowerBIDefaultSelection.IsEmpty);

        exit(true);
    end;

    procedure IsUserDeployingReports(): Boolean
    var
        PowerBIOngoingDeployments: Record "Power BI Ongoing Deployments";
    begin
        // Checks whether any background sessions are running (or waiting to run) for doing PBI default
        // report uploads, based on the values in table 6308.
        PowerBIOngoingDeployments.Reset;
        PowerBIOngoingDeployments.SetFilter("User Security ID",UserSecurityId);
        exit(PowerBIOngoingDeployments.FindFirst and PowerBIOngoingDeployments."Is Deploying Reports");
    end;

    procedure IsUserRetryingUploads(): Boolean
    var
        PowerBIOngoingDeployments: Record "Power BI Ongoing Deployments";
    begin
        // Checks whether any background sessions are running (or waiting to run) for finishing partial
        // uploads of PBI default reports, based on the values in table 6308.
        PowerBIOngoingDeployments.Reset;
        PowerBIOngoingDeployments.SetFilter("User Security ID",UserSecurityId);
        exit(PowerBIOngoingDeployments.FindFirst and PowerBIOngoingDeployments."Is Retrying Uploads");
    end;

    procedure IsUserDeletingReports(): Boolean
    var
        PowerBIOngoingDeployments: Record "Power BI Ongoing Deployments";
    begin
        // Checks whether any background sessions are running (or waiting to run) for deleting any
        // uploaded PBI default reports, based on the values in table 6308.
        PowerBIOngoingDeployments.Reset;
        PowerBIOngoingDeployments.SetFilter("User Security ID",UserSecurityId);
        exit(PowerBIOngoingDeployments.FindFirst and PowerBIOngoingDeployments."Is Deleting Reports");
    end;

    procedure SetIsDeployingReports(IsDeploying: Boolean)
    var
        PowerBIOngoingDeployments: Record "Power BI Ongoing Deployments";
    begin
        // Sets values in table 6308 to indicate a report deployment session is currently running or
        // waiting to run. This lets us make sure we don't schedule any simulatenous sessions that would
        // accidentally deploy a report multiple times or something.
        PowerBIOngoingDeployments.Reset;
        PowerBIOngoingDeployments.SetFilter("User Security ID",UserSecurityId);

        if PowerBIOngoingDeployments.FindFirst then begin
          PowerBIOngoingDeployments."Is Deploying Reports" := IsDeploying;
          PowerBIOngoingDeployments.Modify;
        end else begin
          PowerBIOngoingDeployments.Init;
          PowerBIOngoingDeployments."User Security ID" := UserSecurityId;
          PowerBIOngoingDeployments."Is Deploying Reports" := IsDeploying;
          PowerBIOngoingDeployments.Insert;
        end;

        Commit;
    end;

    procedure SetIsRetryingUploads(IsRetrying: Boolean)
    var
        PowerBIOngoingDeployments: Record "Power BI Ongoing Deployments";
    begin
        // Sets values in table 6308 to indicate a deployment retry session is currently running or
        // waiting to run. This lets us make sure we don't schedule any simulatenous sessions that would
        // accidentally retry an upload multiple times or something.
        PowerBIOngoingDeployments.Reset;
        PowerBIOngoingDeployments.SetFilter("User Security ID",UserSecurityId);

        if PowerBIOngoingDeployments.FindFirst then begin
          PowerBIOngoingDeployments."Is Retrying Uploads" := IsRetrying;
          PowerBIOngoingDeployments.Modify;
        end else begin
          PowerBIOngoingDeployments.Init;
          PowerBIOngoingDeployments."User Security ID" := UserSecurityId;
          PowerBIOngoingDeployments."Is Retrying Uploads" := IsRetrying;
          PowerBIOngoingDeployments.Insert;
        end;

        Commit;
    end;

    procedure SetIsDeletingReports(IsDeleting: Boolean)
    var
        PowerBIOngoingDeployments: Record "Power BI Ongoing Deployments";
    begin
        // Sets values in table 6308 to indicate a report deletion session is currently running or
        // waiting to run. This lets us make sure we don't schedule any simultaneous sessions that would
        // accidentally delete a report that is already trying to delete or something.
        PowerBIOngoingDeployments.Reset;
        PowerBIOngoingDeployments.SetFilter("User Security ID",UserSecurityId);

        if PowerBIOngoingDeployments.FindFirst then begin
          PowerBIOngoingDeployments."Is Deleting Reports" := IsDeleting;
          PowerBIOngoingDeployments.Modify;
        end else begin
          PowerBIOngoingDeployments.Init;
          PowerBIOngoingDeployments."User Security ID" := UserSecurityId;
          PowerBIOngoingDeployments."Is Deleting Reports" := IsDeleting;
          PowerBIOngoingDeployments.Insert;
        end;

        Commit;
    end;

    local procedure GetServiceRetries(): Integer
    begin
        // Const - number of attempts for deployment API calls.
        exit(25);
    end;

    procedure IsPBIServiceAvailable(): Boolean
    var
        PowerBIServiceStatusSetup: Record "Power BI Service Status Setup";
    begin
        // Checks whether the Power BI service is available for deploying default reports, based on
        // whether previous deployments have failed with a retry date/time that we haven't reached yet.
        PowerBIServiceStatusSetup.Reset;
        if PowerBIServiceStatusSetup.FindFirst then
          exit(PowerBIServiceStatusSetup."Retry After" <= CurrentDateTime);

        exit(true);
    end;

    local procedure UpdatePBIServiceAvailability(RetryAfter: DateTime)
    var
        PowerBIServiceStatusSetup: Record "Power BI Service Status Setup";
    begin
        // Sets the cross-company variable that tracks when the Power BI service is available for
        // deployment calls - service failures will return the date/time which we shouldn't attempt
        // new calls before.
        PowerBIServiceStatusSetup.Reset;
        if PowerBIServiceStatusSetup.FindFirst then begin
          PowerBIServiceStatusSetup."Retry After" := RetryAfter;
          PowerBIServiceStatusSetup.Modify;
        end else begin
          PowerBIServiceStatusSetup.Init;
          PowerBIServiceStatusSetup."Retry After" := RetryAfter;
          PowerBIServiceStatusSetup.Insert;
        end;

        Commit;
    end;

    procedure LogException(var ExceptionMessage: Text;var ExceptionDetails: Text)
    var
        AzureADAppSetup: Record "Azure AD App Setup";
        ActivityLog: Record "Activity Log";
        Company: Record Company;
    begin
        if ExceptionMessage <> '' then begin
          if not AzureADAppSetup.IsEmpty then begin
            AzureADAppSetup.FindFirst;
            ActivityLog.LogActivityForUser(
              AzureADAppSetup.RecordId,ActivityLog.Status::Failed,'Power BI Non-SaaS',ExceptionMessage,ExceptionDetails,UserId);
          end else begin
            Company.Get(CompanyName); // Dummy record to attach to activity log
            ActivityLog.LogActivityForUser(
              Company.RecordId,ActivityLog.Status::Failed,'Power BI SaaS',ExceptionMessage,ExceptionDetails,UserId);
          end;
          ExceptionMessage := '';
          ExceptionDetails := '';
        end;
    end;

    [Scope('Personalization')]
    procedure CanHandleServiceCalls(): Boolean
    var
        AzureADMgtSetup: Record "Azure AD Mgt. Setup";
    begin
        // Checks if the current codeunit is allowed to handle Power BI service requests rather than a mock.
        if AzureADMgtSetup.Get then
          exit(AzureADMgtSetup."PBI Service Mgt. Codeunit ID" = CODEUNIT::"Power BI Service Mgt.");

        exit(false);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetReports(var TempPowerBIReportBuffer: Record "Power BI Report Buffer" temporary;var ExceptionMessage: Text;var ExceptionDetails: Text;Context: Text[30])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUploadReports(var ApiRequestList: DotNet ImportReportRequestList;var ApiResponseList: DotNet ImportReportResponseList)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRetryUploads(var ImportIdList: DotNet ImportedReportRequestList;var ApiResponseList: DotNet ImportedReportResponseList)
    begin
    end;
}

