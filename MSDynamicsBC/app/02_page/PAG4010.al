page 4010 "Intelligent Cloud"
{
    // version NAVW113.00

    Caption = 'Intelligent Cloud';
    Editable = false;
    PageType = Card;
    ShowFilter = false;

    layout
    {
        area(content)
        {
            usercontrol(WebPageViewer;"Microsoft.Dynamics.Nav.Client.WebPageViewer")
            {
                ApplicationArea = Basic,Suite;
                Visible = ShowIntelligentCloud;
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        ShowIntelligentCloud := not PermissionManager.SoftwareAsAService;
    end;

    var
        PermissionManager: Codeunit "Permission Manager";
        AddInReady: Boolean;
        IntelligentCloudUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2009848&clcid=0x409', Locked=true;
        ShowIntelligentCloud: Boolean;

    local procedure NavigateToUrl()
    begin
        CurrPage.WebPageViewer.Navigate(IntelligentCloudUrlTxt);
    end;

    procedure GetIntelligentCloudInsightsUrl(): Text
    var
        BaseUrl: Text;
        ParameterUrl: Text;
        NoDomainUrl: Text;
    begin
        BaseUrl := GetUrl(CLIENTTYPE::Web);
        ParameterUrl := GetUrl(CLIENTTYPE::Web,'',OBJECTTYPE::Page,4013);
        NoDomainUrl := DelChr(ParameterUrl,'<',BaseUrl);

        exit(StrSubstNo('https://businesscentral.dynamics.com/%1',NoDomainUrl));
    end;
}

