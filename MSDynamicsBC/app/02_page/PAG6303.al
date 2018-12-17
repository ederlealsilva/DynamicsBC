page 6303 "Power BI Report Spinner Part"
{
    // version NAVW113.00

    Caption = 'Power BI Reports';
    PageType = CardPart;
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(Control11)
            {
                ShowCaption = false;
                Visible = NOT IsGettingStartedVisible AND NOT IsErrorMessageVisible AND HasReports;
                usercontrol(WebReportViewer;"Microsoft.Dynamics.Nav.Client.WebPageViewer")
                {
                    ApplicationArea = All;
                }
            }
            grid(Control15)
            {
                GridLayout = Columns;
                ShowCaption = false;
                group(Control13)
                {
                    ShowCaption = false;
                    group(Control7)
                    {
                        ShowCaption = false;
                        Visible = IsGettingStartedVisible;
                        field(GettingStarted;'Get started with Power BI')
                        {
                            ApplicationArea = All;
                            Editable = false;
                            ShowCaption = false;
                            Style = StrongAccent;
                            StyleExpr = TRUE;
                            ToolTip = 'Specifies that the Azure AD setup window opens. ';

                            trigger OnDrillDown()
                            begin
                                if not TryAzureAdMgtGetAccessToken then
                                  ShowErrorMessage(GetLastErrorText);

                                PowerBiServiceMgt.SelectDefaultReports;
                                LoadContent;
                            end;
                        }
                    }
                    group(Control10)
                    {
                        ShowCaption = false;
                        Visible = IsErrorMessageVisible;
                        field(ErrorMessageText;ErrorMessageText)
                        {
                            ApplicationArea = All;
                            Editable = false;
                            ShowCaption = false;
                            ToolTip = 'Specifies the error message from Power BI.';
                        }
                        field(ErrorUrlText;ErrorUrlText)
                        {
                            ApplicationArea = All;
                            Editable = false;
                            ExtendedDatatype = URL;
                            ShowCaption = false;
                            ToolTip = 'Specifies the link that generated the error.';
                            Visible = IsUrlFieldVisible;
                        }
                        field(GetReportsLink;'Get reports')
                        {
                            ApplicationArea = All;
                            Editable = false;
                            ShowCaption = false;
                            Style = StrongAccent;
                            StyleExpr = TRUE;
                            ToolTip = 'Specifies the reports.';
                            Visible = IsGetReportsVisible;

                            trigger OnDrillDown()
                            begin
                                SelectReports;
                            end;
                        }
                    }
                    group(Control12)
                    {
                        ShowCaption = false;
                        Visible = NOT IsGettingStartedVisible AND NOT IsErrorMessageVisible AND NOT HasReports AND NOT IsDeployingReports;
                        field(EmptyMessage;'')
                        {
                            ApplicationArea = All;
                            Caption = 'There are no enabled reports. Choose Select Report to see a list of reports that you can display.';
                            Editable = false;
                            ShowCaption = false;
                            ToolTip = 'Specifies that the user needs to select Power BI reports.';
                            Visible = NOT IsDeployingReports;
                        }
                    }
                    group(Control24)
                    {
                        ShowCaption = false;
                        Visible = NOT IsDeploymentUnavailable AND IsDeployingReports AND NOT HasReports;
                        field(InProgressMessage;'')
                        {
                            ApplicationArea = All;
                            Caption = 'Power BI report deployment is in progress.';
                            Editable = false;
                            ShowCaption = false;
                            ToolTip = 'Specifies that the page is deploying reports to Power BI.';
                        }
                    }
                    group(Control30)
                    {
                        ShowCaption = false;
                        Visible = IsDeploymentUnavailable AND NOT IsDeployingReports AND NOT HasReports;
                        field(ServiceUnavailableMessage;'')
                        {
                            ApplicationArea = All;
                            Caption = 'Power BI report deployment is currently unavailable.';
                            ToolTip = 'Specifies that the page cannot currently deploy reports to Power BI.';
                        }
                    }
                    group(Control20)
                    {
                        ShowCaption = false;
                        usercontrol(DeployTimer;"Microsoft.Dynamics.Nav.Client.PowerBIManagement")
                        {
                            ApplicationArea = All;
                        }
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Select Report")
            {
                ApplicationArea = All;
                Caption = 'Select Report';
                Enabled = NOT IsGettingStartedVisible AND NOT IsErrorMessageVisible;
                Image = SelectChart;
                ToolTip = 'Select the report.';

                trigger OnAction()
                begin
                    SelectReports;
                end;
            }
            action("Expand Report")
            {
                ApplicationArea = All;
                Caption = 'Expand Report';
                Enabled = HasReports AND NOT IsErrorMessageVisible;
                Image = View;
                ToolTip = 'View all information in the report.';

                trigger OnAction()
                var
                    PowerBiReportDialog: Page "Power BI Report Dialog";
                begin
                    PowerBiReportDialog.SetUrl(GetEmbedUrlWithNavigation,GetMessage);
                    PowerBiReportDialog.Caption(TempPowerBiReportBuffer.ReportName);
                    PowerBiReportDialog.Run;
                end;
            }
            action("Previous Report")
            {
                ApplicationArea = All;
                Caption = 'Previous Report';
                Enabled = HasReports AND NOT IsErrorMessageVisible;
                Image = PreviousSet;
                ToolTip = 'Go to the previous report.';

                trigger OnAction()
                begin
                    // need to reset filters or it would load the LastLoadedReport otherwise
                    TempPowerBiReportBuffer.Reset;
                    TempPowerBiReportBuffer.SetFilter(Enabled,'%1',true);
                    if TempPowerBiReportBuffer.Next(-1) = 0 then
                      TempPowerBiReportBuffer.FindLast;

                    if AddInReady then
                      CurrPage.WebReportViewer.Navigate(GetEmbedUrl);
                end;
            }
            action("Next Report")
            {
                ApplicationArea = All;
                Caption = 'Next Report';
                Enabled = HasReports AND NOT IsErrorMessageVisible;
                Image = NextSet;
                ToolTip = 'Go to the next report.';

                trigger OnAction()
                begin
                    // need to reset filters or it would load the LastLoadedReport otherwise
                    TempPowerBiReportBuffer.Reset;
                    TempPowerBiReportBuffer.SetFilter(Enabled,'%1',true);
                    if TempPowerBiReportBuffer.Next = 0 then
                      TempPowerBiReportBuffer.FindFirst;

                    if AddInReady then
                      CurrPage.WebReportViewer.Navigate(GetEmbedUrl);
                end;
            }
            action("Manage Report")
            {
                ApplicationArea = All;
                Caption = 'Manage Report';
                Enabled = HasReports AND NOT IsErrorMessageVisible;
                Image = PowerBI;
                ToolTip = 'Opens current selected report for edits.';
                Visible = IsSaaSUser;

                trigger OnAction()
                var
                    PowerBIManagement: Page "Power BI Management";
                begin
                    PowerBIManagement.SetTargetReport(LastOpenedReportID,GetEmbedUrl);
                    PowerBIManagement.LookupMode(true);
                    PowerBIManagement.RunModal;

                    RefreshPart;
                end;
            }
            action(Refresh)
            {
                ApplicationArea = All;
                Caption = 'Refresh Page';
                Enabled = NOT IsGettingStartedVisible;
                Image = Refresh;
                ToolTip = 'Refresh the visible content.';

                trigger OnAction()
                begin
                    RefreshPart;
                end;
            }
            action("Upload Report")
            {
                ApplicationArea = All;
                Caption = 'Upload Report';
                Image = Add;
                ToolTip = 'Uploads a report from a PBIX file.';
                Visible = IsSaaSUser;

                trigger OnAction()
                begin
                    PAGE.RunModal(PAGE::"Upload Power BI Report");
                    RefreshPart;
                end;
            }
            action("Reset All Reports")
            {
                ApplicationArea = All;
                Caption = 'Reset All Reports';
                Image = Reuse;
                ToolTip = 'Resets all reports for redeployment.';
                Visible = IsAdmin AND IsSaaSUser;

                trigger OnAction()
                var
                    PowerBIReportUploads: Record "Power BI Report Uploads";
                    PowerBIReportConfiguration: Record "Power BI Report Configuration";
                    PowerBIOngoingDeployments: Record "Power BI Ongoing Deployments";
                    PowerBIServiceStatusSetup: Record "Power BI Service Status Setup";
                    PowerBIUserConfiguration: Record "Power BI User Configuration";
                    PowerBICustomerReports: Record "Power BI Customer Reports";
                begin
                    if Confirm(ResetReportsQst,false) then begin
                      PowerBIReportUploads.Reset;
                      PowerBIReportUploads.DeleteAll;
                      PowerBIReportConfiguration.Reset;
                      PowerBIReportConfiguration.DeleteAll;
                      PowerBIOngoingDeployments.DeleteAll;
                      PowerBIServiceStatusSetup.DeleteAll;
                      PowerBICustomerReports.DeleteAll;
                      PowerBIUserConfiguration.Reset;
                      PowerBIUserConfiguration.DeleteAll;
                      Commit;
                    end;
                end;
            }
        }
    }

    trigger OnInit()
    begin
        // Variables used by PingPong timer when deploying default PBI reports.
        TimerDelay := 30000; // 30 seconds
        MaxTimerCount := (60000 / TimerDelay) * 5; // 5 minutes
    end;

    trigger OnOpenPage()
    begin
        UpdateContext;
        RefreshPart;
        IsAdmin := PermissionManager.IsSuper(UserSecurityId);
        IsSaaSUser := AzureAdMgt.IsSaaS;
    end;

    var
        NoReportsAvailableErr: Label 'There are no reports available from Power BI.';
        ResetReportsQst: Label 'This action will remove all Power BI reports in the database for all users. Reports in your Power BI workspace need to be removed manually. Continue?';
        TempPowerBiReportBuffer: Record "Power BI Report Buffer" temporary;
        PowerBIUserConfiguration: Record "Power BI User Configuration";
        SetPowerBIUserConfig: Codeunit "Set Power BI User Config";
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
        PowerBiServiceMgt: Codeunit "Power BI Service Mgt.";
        AzureAdMgt: Codeunit "Azure AD Mgt.";
        ClientTypeManagement: Codeunit ClientTypeManagement;
        PermissionManager: Codeunit "Permission Manager";
        LastOpenedReportID: Guid;
        Context: Text[30];
        NameFilter: Text;
        IsGettingStartedVisible: Boolean;
        HasReports: Boolean;
        AddInReady: Boolean;
        IsErrorMessageVisible: Boolean;
        ErrorMessageText: Text;
        IsUrlFieldVisible: Boolean;
        IsGetReportsVisible: Boolean;
        IsDeployingReports: Boolean;
        IsDeploymentUnavailable: Boolean;
        IsTimerReady: Boolean;
        IsTimerActive: Boolean;
        ErrorUrlText: Text;
        ExceptionMessage: Text;
        ExceptionDetails: Text;
        TimerDelay: Integer;
        MaxTimerCount: Integer;
        CurrentTimerCount: Integer;
        IsSaaSUser: Boolean;
        IsAdmin: Boolean;

    local procedure GetMessage(): Text
    var
        HttpUtility: DotNet HttpUtility;
    begin
        exit(
          '{"action":"loadReport","accessToken":"' +
          HttpUtility.JavaScriptStringEncode(AzureAdMgt.GetAccessToken(
              PowerBiServiceMgt.GetPowerBiResourceUrl,PowerBiServiceMgt.GetPowerBiResourceName,false)) + '"}');
    end;

    local procedure GetEmbedUrl(): Text
    begin
        if TempPowerBiReportBuffer.IsEmpty then begin
          // Clear out last opened report if there are no reports to display.
          Clear(LastOpenedReportID);
          SetLastOpenedReportID(LastOpenedReportID);
        end else begin
          // update last loaded report
          SetLastOpenedReportID(TempPowerBiReportBuffer.ReportID);
          // Hides both filters and tabs for embedding in small spaces where navigation is unnecessary.
          exit(TempPowerBiReportBuffer.EmbedUrl + '&filterPaneEnabled=false&navContentPaneEnabled=false');
        end;
    end;

    local procedure GetEmbedUrlWithNavigation(): Text
    begin
        // update last loaded report
        SetLastOpenedReportID(TempPowerBiReportBuffer.ReportID);
        // Hides filters and shows tabs for embedding in large spaces where navigation is necessary.
        exit(TempPowerBiReportBuffer.EmbedUrl + '&filterPaneEnabled=false');
    end;

    local procedure LoadContent()
    begin
        // The end to end process for loading reports onscreen, or defaulting to an error state if that fails,
        // including deploying default reports in case they haven't been loaded yet. Called when first logging
        // into Power BI or any time the part has reloaded from scratch.
        if not TryLoadPart then
          ShowErrorMessage(GetLastErrorText);

        // Always call this function after calling TryLoadPart to log exceptions to ActivityLog table
        PowerBiServiceMgt.LogException(ExceptionMessage,ExceptionDetails);
        CurrPage.Update;
        DeployDefaultReports;
    end;

    local procedure LoadPart()
    begin
        IsGettingStartedVisible := not PowerBiServiceMgt.IsUserReadyForPowerBI;

        TempPowerBiReportBuffer.Reset;
        TempPowerBiReportBuffer.DeleteAll;
        if IsGettingStartedVisible then begin
          if AzureAdMgt.IsSaaS then
            Error(PowerBiServiceMgt.GetGenericError);

          TempPowerBiReportBuffer.Insert // Hack to display Get Started link.
        end else begin
          PowerBiServiceMgt.GetReports(TempPowerBiReportBuffer,ExceptionMessage,ExceptionDetails,Context);
          if PowerBiServiceMgt.UserHasMissingReportUrls(Context) then begin
            // Call PBI service only when cached reports are invalid (niche upgrade scenario).
            if TempPowerBiReportBuffer.IsEmpty then
              Error(NoReportsAvailableErr); // No reports in PBI account - even more niche scenario.
          end else
            PowerBiServiceMgt.GetCachedReports(TempPowerBiReportBuffer,Context);

          RefreshAvailableReports;
        end;
    end;

    local procedure RefreshAvailableReports()
    begin
        // Filters the report buffer to show the user's selected report onscreen if possible, otherwise defaulting
        // to other enabled reports.
        // (The updated selection will automatically get saved on render - can't save to database here without
        // triggering errors about calling MODIFY during a TryFunction.)
        TempPowerBiReportBuffer.Reset;
        TempPowerBiReportBuffer.SetFilter(Enabled,'%1',true);
        if not IsNullGuid(LastOpenedReportID) then begin
          TempPowerBiReportBuffer.SetFilter(ReportID,'%1',LastOpenedReportID);

          if TempPowerBiReportBuffer.IsEmpty then begin
            // If last selection is invalid, clear it and default to showing the first enabled report.
            Clear(LastOpenedReportID);
            RefreshAvailableReports;
          end;
        end;

        HasReports := TempPowerBiReportBuffer.FindFirst;
    end;

    local procedure RefreshPart()
    begin
        // Refreshes content by re-rendering the whole page part - removes any current error message text, and tries to
        // reload the user's list of reports, as if the page just loaded. Used by the Refresh button or when closing the
        // Select Reports page, to make sure we have the most up to date list of reports and aren't stuck in an error state.
        IsErrorMessageVisible := false;
        IsUrlFieldVisible := false;
        IsGetReportsVisible := false;

        IsDeployingReports := PowerBiServiceMgt.IsUserDeployingReports or PowerBiServiceMgt.IsUserRetryingUploads or
          PowerBiServiceMgt.IsUserDeletingReports;
        IsDeploymentUnavailable := not PowerBiServiceMgt.IsPBIServiceAvailable;

        PowerBiServiceMgt.SelectDefaultReports;

        SetPowerBIUserConfig.CreateOrReadUserConfigEntry(PowerBIUserConfiguration,LastOpenedReportID,Context);
        LoadContent;

        if AddInReady then
          CurrPage.WebReportViewer.Navigate(GetEmbedUrl);
    end;

    [Scope('Personalization')]
    procedure SetContext(ParentContext: Text[30])
    begin
        // Sets an ID that tracks which page to show reports for - called by the parent page hosting the part,
        // if possible (see UpdateContext).
        Context := ParentContext;
    end;

    local procedure UpdateContext()
    var
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
    begin
        // Automatically sets the parent page ID based on the user's selected role center (role centers can't
        // have codebehind, so they have no other way to set the context for their reports).
        if Context = '' then
          SetContext(ConfPersonalizationMgt.GetCurrentProfileIDNoError);
    end;

    [Scope('Personalization')]
    procedure SetNameFilter(ParentFilter: Text)
    begin
        // Sets a text value that tells the selection page how to filter the reports list. This should be called
        // by the parent page hosting this page part, if possible.
        NameFilter := ParentFilter;
    end;

    local procedure ShowErrorMessage(TextToShow: Text)
    begin
        // this condition checks if we caught the authorization error that contains a link to Power BI
        // the function divide the error message into simple text and url part
        if TextToShow = PowerBiServiceMgt.GetUnauthorizedErrorText then begin
          IsUrlFieldVisible := true;
          // this message is required to have ':' at the end, but it has '.' instead due to C/AL Localizability requirement
          TextToShow := DelStr(PowerBiServiceMgt.GetUnauthorizedErrorText,StrLen(PowerBiServiceMgt.GetUnauthorizedErrorText),1) + ':';
          ErrorUrlText := PowerBiServiceMgt.GetPowerBIUrl;
        end;

        IsGetReportsVisible := (TextToShow = NoReportsAvailableErr);

        IsErrorMessageVisible := true;
        IsGettingStartedVisible := false;
        TempPowerBiReportBuffer.DeleteAll; // Required to avoid one INSERT after another (that will lead to an error)
        if TextToShow = '' then
          TextToShow := PowerBiServiceMgt.GetGenericError;
        ErrorMessageText := TextToShow;
        TempPowerBiReportBuffer.Insert; // Hack to show the field with the text
        CurrPage.Update;
    end;

    [TryFunction]
    local procedure TryLoadPart()
    begin
        // Need the try function here to catch any possible internal errors
        LoadPart;
    end;

    [TryFunction]
    local procedure TryAzureAdMgtGetAccessToken()
    begin
        AzureAdMgt.GetAccessToken(PowerBiServiceMgt.GetPowerBiResourceUrl,PowerBiServiceMgt.GetPowerBiResourceName,true);
    end;

    local procedure SetReport()
    begin
        if (ClientTypeManagement.GetCurrentClientType <> CLIENTTYPE::Phone) and
           (ClientTypeManagement.GetCurrentClientType <> CLIENTTYPE::Windows)
        then
          CurrPage.WebReportViewer.InitializeIFrame(PowerBiServiceMgt.GetReportPageSize);
        // CurrPage.WebReportViewer.InitializeFullIFrame();
        CurrPage.WebReportViewer.Navigate(GetEmbedUrl);
    end;

    procedure SetLastOpenedReportID(LastOpenedReportIDInputValue: Guid)
    begin
        LastOpenedReportID := LastOpenedReportIDInputValue;
        // filter to find the proper record
        PowerBIUserConfiguration.Reset;
        PowerBIUserConfiguration.SetFilter("Page ID",'%1',Context);
        PowerBIUserConfiguration.SetFilter("Profile ID",'%1',ConfPersonalizationMgt.GetCurrentProfileIDNoError);
        PowerBIUserConfiguration.SetFilter("User Security ID",'%1',UserSecurityId);

        // update the last loaded report field (the record at this point should already exist bacause it was created OnOpenPage)
        if not PowerBIUserConfiguration.IsEmpty then begin
          PowerBIUserConfiguration."Selected Report ID" := LastOpenedReportID;
          PowerBIUserConfiguration.Modify;
          Commit;
        end;
    end;

    local procedure SelectReports()
    var
        PowerBIReportSelection: Page "Power BI Report Selection";
    begin
        // Opens the report selection page, then updates the onscreen report depending on the user's
        // subsequent selection and enabled/disabled settings.
        PowerBIReportSelection.SetContext(Context);
        PowerBIReportSelection.SetNameFilter(NameFilter);
        PowerBIReportSelection.LookupMode(true);

        PowerBIReportSelection.RunModal;
        if PowerBIReportSelection.IsPageClosedOkay then begin
          PowerBIReportSelection.GetRecord(TempPowerBiReportBuffer);

          if TempPowerBiReportBuffer.Enabled then
            LastOpenedReportID := TempPowerBiReportBuffer.ReportID; // RefreshAvailableReports handles fallback logic on invalid selection.

          RefreshPart;
          // At this point, NAV will load the web page viewer since HasReports should be true. WebReportViewer::ControlAddInReady will then fire, calling Navigate()
        end;
    end;

    local procedure DeployDefaultReports()
    begin
        // Checks if there are any default reports the user needs to upload, select, or delete and automatically begins
        // those processes. The page will refresh when the timer control runs later.
        DeleteMarkedReports;
        FinishPartialUploads;
        if not IsGettingStartedVisible and not IsErrorMessageVisible and AzureAdMgt.IsSaaS and
           PowerBiServiceMgt.UserNeedsToDeployReports and not PowerBiServiceMgt.IsUserDeployingReports
        then begin
          IsDeployingReports := true;
          PowerBiServiceMgt.UploadDefaultReportsInBackground;
          StartDeploymentTimer;
        end;
    end;

    local procedure FinishPartialUploads()
    begin
        // Checks if there are any default reports whose uploads only partially completed, and begins a
        // background process for those reports. The page will refresh when the timer control runs later.
        if not IsGettingStartedVisible and not IsErrorMessageVisible and AzureAdMgt.IsSaaS and
           PowerBiServiceMgt.UserNeedsToRetryUploads and not PowerBiServiceMgt.IsUserRetryingUploads
        then begin
          IsDeployingReports := true;
          PowerBiServiceMgt.RetryUnfinishedReportsInBackground;
          StartDeploymentTimer;
        end;
    end;

    local procedure DeleteMarkedReports()
    begin
        // Checks if there are any default reports that have been marked to be deleted on page 6321, and begins
        // a background process for those reports. The page will refresh when the timer control runs later.
        if not IsGettingStartedVisible and not IsErrorMessageVisible and AzureAdMgt.IsSaaS and
           PowerBiServiceMgt.UserNeedsToDeleteReports and not PowerBiServiceMgt.IsUserDeletingReports
        then begin
          IsDeployingReports := true;
          PowerBiServiceMgt.DeleteDefaultReportsInBackground;
          StartDeploymentTimer;
          // TODO: Make same changes on factbox page.
        end;
    end;

    local procedure StartDeploymentTimer()
    begin
        // Resets the timer for refreshing the page during OOB report deployment, if the add-in is
        // ready to go and the timer isn't already going.
        if IsTimerReady and not IsTimerActive then begin
          CurrentTimerCount := 0;
          IsTimerActive := true;
          CurrPage.DeployTimer.Ping(TimerDelay);
        end;
    end;
}

