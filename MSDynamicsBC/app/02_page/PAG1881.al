page 1881 "Sandbox Environment"
{
    // version NAVW113.00

    ApplicationArea = Basic,Suite;
    Caption = 'Sandbox Environment (Preview)';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = NavigatePage;
    ShowFilter = false;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            group(Control6)
            {
                Editable = false;
                ShowCaption = false;
                Visible = TopBannerVisible;
                field(MediaResourcesStandard;MediaResourcesStandard."Media Reference")
                {
                    ApplicationArea = Basic,Suite;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(Control7)
            {
                Caption = '';
                InstructionalText = 'In addition to your production environment, you can create an environment for sandbox activities, such as test, demonstration, or development.';
            }
            group(Control8)
            {
                Caption = '';
                InstructionalText = 'A new sandbox environment (preview) only contains the CRONUS demonstration company. Actions that you perform in the sandbox environment (preview) do not affect data or settings in your production environment.';
            }
            group(Control12)
            {
                Caption = '';
                InstructionalText = 'This Sandbox environment feature is provided as a free preview solely for testing, development and evaluation. You will not use the Sandbox in a live operating environment. Microsoft may, in its sole discretion, change the Sandbox environment or subject it to a fee for a final, commercial version, if any, or may elect not to release one.';
            }
            group(Control9)
            {
                Caption = '';
                InstructionalText = 'Choose Create to start a new sandbox environment (preview).';
            }
            group(Control10)
            {
                Caption = '';
                InstructionalText = 'Choose Reset to clean and restart the sandbox environment (preview).';
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Create)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Create';
                InFooterBar = true;
                ToolTip = 'Create a sandbox environment.';

                trigger OnAction()
                begin
                    HyperLink(GetFunctionUrl(CreateSandboxUrlTxt));
                end;
            }
            action(Reset)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Reset';
                InFooterBar = true;
                ToolTip = 'Reset the sandbox environment.';

                trigger OnAction()
                begin
                    HyperLink(GetFunctionUrl(ResetSandboxUrlTxt));
                end;
            }
            action(Open)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Open';
                InFooterBar = true;
                ToolTip = 'Open the sandbox environment.';

                trigger OnAction()
                begin
                    HyperLink(GetFunctionUrl(CreateSandboxUrlTxt));
                end;
            }
        }
    }

    trigger OnInit()
    begin
        LoadTopBanners;
    end;

    trigger OnOpenPage()
    var
        PermissionManager: Codeunit "Permission Manager";
    begin
        if not PermissionManager.SoftwareAsAService or PermissionManager.IsSandboxConfiguration then
          Error(EnvironmentErr);
    end;

    var
        MediaRepositoryStandard: Record "Media Repository";
        MediaRepositoryDone: Record "Media Repository";
        MediaResourcesStandard: Record "Media Resources";
        MediaResourcesDone: Record "Media Resources";
        ClientTypeManagement: Codeunit ClientTypeManagement;
        TopBannerVisible: Boolean;
        EnvironmentErr: Label 'This feature is only available in the online production version of the product.';
        CreateSandboxUrlTxt: Label '/sandbox?redirectedFromSignup=false', Locked=true;
        ResetSandboxUrlTxt: Label '/sandbox/reset?redirectedFromSignup=false', Locked=true;
        FixedClientEndpointBaseProdUrlTxt: Label 'https://businesscentral.dynamics.com/', Locked=true;
        FixedClientEndpointBaseTieUrlTxt: Label 'https://businesscentral.dynamics-tie.com/', Locked=true;
        FixedClientEndpointBaseServiceTieUrlTxt: Label 'https://businesscentral.dynamics-servicestie.com/', Locked=true;

    local procedure LoadTopBanners()
    begin
        if MediaRepositoryStandard.Get('AssistedSetup-NoText-400px.png',Format(ClientTypeManagement.GetCurrentClientType)) and
           MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png',Format(ClientTypeManagement.GetCurrentClientType))
        then
          if MediaResourcesStandard.Get(MediaRepositoryStandard."Media Resources Ref") and
             MediaResourcesDone.Get(MediaRepositoryDone."Media Resources Ref")
          then
            TopBannerVisible := MediaResourcesDone."Media Reference".HasValue;
    end;

    local procedure GetFunctionUrl(SandboxFunctionUrl: Text): Text
    var
        EnvironmentMgt: Codeunit "Environment Mgt.";
        TenantManagement: Codeunit "Tenant Management";
    begin
        if EnvironmentMgt.IsPROD then
          exit(FixedClientEndpointBaseProdUrlTxt + TenantManagement.GetAadTenantId + SandboxFunctionUrl);
        if EnvironmentMgt.IsTIE then
          exit(FixedClientEndpointBaseServiceTieUrlTxt + TenantManagement.GetAadTenantId + SandboxFunctionUrl);
        if EnvironmentMgt.IsPPE then
          exit(FixedClientEndpointBaseTieUrlTxt + TenantManagement.GetAadTenantId + SandboxFunctionUrl);
        if EnvironmentMgt.IsPartnerPROD or EnvironmentMgt.IsPartnerTIE or EnvironmentMgt.IsPartnerPPE then
          exit(LowerCase(GetUrl(CLIENTTYPE::Web)) + SandboxFunctionUrl);

        exit('');
    end;
}

