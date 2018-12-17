page 6401 "Flow Selector"
{
    // version NAVW113.00

    ApplicationArea = Suite;
    Caption = 'Manage Flows';
    Editable = false;
    LinksAllowed = false;
    PromotedActionCategories = 'New,Process,Report,Configuration';
    SourceTable = "Workflow Webhook Entry";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            grid(Control10)
            {
                ShowCaption = false;
                Visible = IsUserReadyForFlow AND NOT IsErrorMessageVisible;
                field(EnvironmentNameText;EnvironmentNameText)
                {
                    ApplicationArea = Basic,Suite;
                    ShowCaption = false;
                }
            }
            group(Control3)
            {
                ShowCaption = false;
                Visible = IsUserReadyForFlow AND NOT IsErrorMessageVisible;
                usercontrol(FlowAddin;"Microsoft.Dynamics.Nav.Client.FlowIntegration")
                {
                    ApplicationArea = Basic,Suite;
                }
            }
            group(Control4)
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

    actions
    {
        area(processing)
        {
            action(FlowEntries)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Flow Entries';
                Image = Flow;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'View and configure Flow entries.';
                Visible = IsSaaS;

                trigger OnAction()
                var
                    WorkflowWebhookEntry: Record "Workflow Webhook Entry";
                begin
                    WorkflowWebhookEntry.SetDefaultFilter(WorkflowWebhookEntry);
                    PAGE.Run(PAGE::"Workflow Webhook Entries",WorkflowWebhookEntry);
                end;
            }
            action(OpenMyFlows)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Open Flow';
                Image = Flow;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'View and configure Flows on the Flow website.';

                trigger OnAction()
                begin
                    HyperLink(FlowServiceManagement.GetFlowManageUrl);
                end;
            }
            action(SelectFlowUserEnvironment)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Select Environment';
                Image = CheckList;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Select your Flow environment.';

                trigger OnAction()
                var
                    FlowUserEnvironmentConfig: Record "Flow User Environment Config";
                    TempFlowUserEnvironmentBuffer: Record "Flow User Environment Buffer" temporary;
                    FlowUserEnvSelection: Page "Flow User Env. Selection";
                begin
                    TempFlowUserEnvironmentBuffer.Reset;
                    FlowServiceManagement.GetEnvironments(TempFlowUserEnvironmentBuffer);
                    FlowUserEnvSelection.SetFlowEnvironmentBuffer(TempFlowUserEnvironmentBuffer);
                    FlowUserEnvSelection.LookupMode(true);

                    if FlowUserEnvSelection.RunModal <> ACTION::LookupOK then
                      exit;

                    TempFlowUserEnvironmentBuffer.Reset;
                    TempFlowUserEnvironmentBuffer.SetRange(Enabled,true);

                    // Remove any previous selection since user did not select anything
                    if not TempFlowUserEnvironmentBuffer.FindFirst then begin
                      if FlowUserEnvironmentConfig.Get(UserSecurityId) then
                        FlowUserEnvironmentConfig.Delete;
                      exit;
                    end;

                    FlowServiceManagement.SaveFlowUserEnvironmentSelection(TempFlowUserEnvironmentBuffer);
                    LoadFlows;
                end;
            }
            action(ConnectionInfo)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Connection Information';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "Content Pack Setup Wizard";
                ToolTip = 'Show information for connecting to Power BI content packs.';
            }
        }
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

        if not FlowServiceManagement.HasUserSelectedFlowEnvironment then
          FlowServiceManagement.SetSelectedFlowEnvironmentIDToDefault;

        IsSaaS := AzureAdMgt.IsSaaS;
    end;

    var
        AzureAdMgt: Codeunit "Azure AD Mgt.";
        FlowServiceManagement: Codeunit "Flow Service Management";
        IsErrorMessageVisible: Boolean;
        ErrorMessageText: Text;
        IsUserReadyForFlow: Boolean;
        AddInReady: Boolean;
        EnvironmentNameText: Text;
        IsSaaS: Boolean;

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

    local procedure LoadFlows()
    begin
        EnvironmentNameText := FlowServiceManagement.GetSelectedFlowEnvironmentName;
        CurrPage.FlowAddin.LoadFlows(FlowServiceManagement.GetFlowEnvironmentID);
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

