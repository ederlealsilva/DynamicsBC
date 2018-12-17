page 6400 "Flow Template Selector"
{
    // version NAVW113.00

    ApplicationArea = Suite;
    Caption = 'Select an Existing Flow Template';
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            grid(Control7)
            {
                ShowCaption = false;
                group(Control8)
                {
                    ShowCaption = false;
                    group(Control11)
                    {
                        ShowCaption = false;
                        Visible = IsUserReadyForFlow AND NOT IsErrorMessageVisible;
                        field(EnvironmentNameText;EnvironmentNameText)
                        {
                            ApplicationArea = Basic,Suite;
                            Editable = false;
                            ShowCaption = false;
                        }
                    }
                    group(Control4)
                    {
                        ShowCaption = false;
                        Visible = IsUserReadyForFlow AND NOT IsErrorMessageVisible;
                        field(SearchFilter;SearchText)
                        {
                            ApplicationArea = Basic,Suite;
                            Caption = 'Search Filter';
                            ToolTip = 'Specifies a search filter on the templates.';

                            trigger OnLookup(var Text: Text): Boolean
                            begin
                                if AddInReady then
                                  CurrPage.FlowAddin.LoadTemplates(FlowServiceManagement.GetFlowEnvironmentID,SearchText,
                                    FlowServiceManagement.GetFlowTemplatePageSize,FlowServiceManagement.GetFlowTemplateDestinationNew);
                            end;
                        }
                        usercontrol(FlowAddin;"Microsoft.Dynamics.Nav.Client.FlowIntegration")
                        {
                            ApplicationArea = Basic,Suite;
                        }
                    }
                    group(Control5)
                    {
                        ShowCaption = false;
                        Visible = IsErrorMessageVisible;
                        field(ErrorMessageText;ErrorMessageText)
                        {
                            ApplicationArea = Basic,Suite;
                            Editable = false;
                            ShowCaption = false;
                        }
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        if FlowServiceManagement.IsPPE then begin
          ShowErrorMessage(FlowServiceManagement.GetFlowPPEError);
          exit;
        end;

        IsErrorMessageVisible := false;
        if not TryInitialize then
          ShowErrorMessage(GetLastErrorText);
        if not FlowServiceManagement.IsUserReadyForFlow then
          Error('');
        IsUserReadyForFlow := true;
        if SearchText = '' then
          SearchText := FlowServiceManagement.GetTemplateFilter;
        SetSearchText(SearchText);

        if not FlowServiceManagement.HasUserSelectedFlowEnvironment then
          FlowServiceManagement.SetSelectedFlowEnvironmentIDToDefault;
    end;

    var
        AzureAdMgt: Codeunit "Azure AD Mgt.";
        FlowServiceManagement: Codeunit "Flow Service Management";
        SearchText: Text;
        ErrorMessageText: Text;
        IsErrorMessageVisible: Boolean;
        IsUserReadyForFlow: Boolean;
        AddInReady: Boolean;
        EnvironmentNameText: Text;

    [Scope('Personalization')]
    procedure SetSearchText(Search: Text)
    begin
        if Search = '' then
          Search := FlowServiceManagement.GetTemplateFilter;
        SearchText := Search;
    end;

    local procedure Initialize()
    begin
        IsUserReadyForFlow := FlowServiceManagement.IsUserReadyForFlow;

        if not IsUserReadyForFlow then begin
          if AzureAdMgt.IsSaaS then
            Error(FlowServiceManagement.GetGenericError);
          if not TryAzureAdMgtGetAccessToken then
            ShowErrorMessage(GetLastErrorText);
          CurrPage.Update;
        end;
    end;

    local procedure LoadTemplates()
    begin
        EnvironmentNameText := FlowServiceManagement.GetSelectedFlowEnvironmentName;
        CurrPage.FlowAddin.LoadTemplates(FlowServiceManagement.GetFlowEnvironmentID,SearchText,
          FlowServiceManagement.GetFlowTemplatePageSize,FlowServiceManagement.GetFlowTemplateDestinationNew);
        CurrPage.Update;
    end;

    [TryFunction]
    local procedure TryInitialize()
    begin
        Initialize;
    end;

    [TryFunction]
    local procedure TryAzureAdMgtGetAccessToken()
    begin
        AzureAdMgt.GetAccessToken(FlowServiceManagement.GetFlowARMResourceUrl,FlowServiceManagement.GetFlowResourceName,true);
    end;

    local procedure ShowErrorMessage(TextToShow: Text)
    begin
        IsErrorMessageVisible := true;
        IsUserReadyForFlow := false;
        if TextToShow = '' then
          TextToShow := FlowServiceManagement.GetGenericError;
        ErrorMessageText := TextToShow;
        CurrPage.Update;
    end;
}

