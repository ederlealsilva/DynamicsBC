page 1432 "Net Promoter Score Setup"
{
    // version NAVW111.00

    Caption = 'Net Promoter Score Setup';
    Editable = false;
    PageType = Card;
    SourceTable = "Net Promoter Score Setup";

    layout
    {
        area(content)
        {
            field(PUID;Puid)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'PUID';
                ToolTip = 'Specifies PUID';
            }
            field("Actual API URL";ActualApiUrl)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Actual API URL';
                ToolTip = 'Specifies the actual API URL.';
            }
            field("Cached API URL";CachedApiUrl)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Cached API URL';
                Editable = false;
                ToolTip = 'Specifies the cached API URL.';
            }
            field("Cache Expire Time";"Expire Time")
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Cache Expire Time';
                ToolTip = 'Specifies the cache expiration time.';
            }
            field("Time Between Requests";"Time Between Requests")
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Time Between Requests';
                ToolTip = 'Specifies the minimum time between requests to the NPS API URL.';
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Validate Actual URL")
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Validate Actual URL';
                Enabled = IsActualUrlNotEmpty;
                Image = ValidateEmailLoggingSetup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Validate the actual API URL.';

                trigger OnAction()
                begin
                    ValidateApiUrl(ActualApiUrl);
                end;
            }
            action("Validate Cached URL")
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Validate Cached URL';
                Enabled = IsCachedUrlNotEmpty;
                Image = ValidateEmailLoggingSetup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Validate the cached API URL.';

                trigger OnAction()
                begin
                    ValidateApiUrl(CachedApiUrl);
                end;
            }
            action("Test Actual URL")
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Test Actual URL';
                Enabled = IsActualUrlNotEmpty;
                Image = Link;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Verify the actual API URL.';

                trigger OnAction()
                var
                    NetPromoterScoreMgt: Codeunit "Net Promoter Score Mgt.";
                begin
                    TestApiUrl(NetPromoterScoreMgt.GetTestUrl(ActualApiUrl));
                end;
            }
            action("Test Cached URL")
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Test Cached URL';
                Enabled = IsCachedUrlNotEmpty;
                Image = Link;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Verify the cached API URL.';

                trigger OnAction()
                var
                    NetPromoterScoreMgt: Codeunit "Net Promoter Score Mgt.";
                begin
                    TestApiUrl(NetPromoterScoreMgt.GetTestUrl(CachedApiUrl));
                end;
            }
            action("Renew Cached URL")
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Renew Cached URL';
                Image = Apply;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Renew the cached API URL.';

                trigger OnAction()
                begin
                    GetActualApiUrl;
                    if not IsActualUrlNotEmpty then
                      if not Confirm(EmptyCachedUrlQst) then
                        exit;

                    "Expire Time" := CurrentDateTime;
                    Modify;

                    GetCachedApiUrl;
                    if IsCachedUrlNotEmpty then
                      Message(SuccessfulSynchronizationMsg)
                    else
                      Message(FailedSynchronizationMsg);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        GetCachedApiUrl;
    end;

    trigger OnOpenPage()
    var
        NetPromoterScoreMgt: Codeunit "Net Promoter Score Mgt.";
    begin
        GetActualApiUrl;
        Puid := NetPromoterScoreMgt.GetPuid;
    end;

    var
        CachedApiUrl: Text;
        TestSuccessfulMsg: Label 'The URL test was successful.\Request: %1\Response: %2.', Comment='%1 - request, %2 - response';
        TestFailedMsg: Label 'The URL test failed.\Request: %1\Error: %2.', Comment='%1 - request, %2 - error';
        ValidationMsg: Label 'The URL was validated.\URL: %1\Is URI: %2\Is HTTP: %3\Is HTTPS: %4.', Comment='%1 - URL, %2 - is URI, %3 - is HTTP, %4 - is HTTPS';
        SuccessfulSynchronizationMsg: Label 'The cached URL was successfuly synchronized with the actual URL.';
        FailedSynchronizationMsg: Label 'Cannot get the actual URL.';
        ActualApiUrl: Text;
        NpsApiUrlTxt: Label 'NpsApiUrl', Locked=true;
        Puid: Text;
        IsCachedUrlNotEmpty: Boolean;
        IsActualUrlNotEmpty: Boolean;
        EmptyCachedUrlQst: Label 'The actual API URL is empty. Do you want to empty the cached API URL as well?';

    local procedure GetActualApiUrl()
    var
        AzureKeyVaultManagement: Codeunit "Azure Key Vault Management";
    begin
        if AzureKeyVaultManagement.IsEnable then
          if not AzureKeyVaultManagement.GetAzureKeyVaultSecret(ActualApiUrl,NpsApiUrlTxt) then
            ActualApiUrl := '';
        ActualApiUrl := DelChr(ActualApiUrl,'<>',' ');
        IsActualUrlNotEmpty := ActualApiUrl <> '';
    end;

    local procedure GetCachedApiUrl()
    begin
        CachedApiUrl := DelChr(GetApiUrl,'<>',' ');
        IsCachedUrlNotEmpty := CachedApiUrl <> '';
    end;

    local procedure TestApiUrl(Url: Text)
    var
        NetPromoterScoreMgt: Codeunit "Net Promoter Score Mgt.";
        Response: Text;
        ErrorMessage: Text;
    begin
        if NetPromoterScoreMgt.TestConnection(Url,Response,ErrorMessage) then
          Message(TestSuccessfulMsg,Url,Response)
        else
          Message(TestFailedMsg,Url,ErrorMessage);
    end;

    local procedure ValidateApiUrl(Url: Text)
    var
        WebRequestHelper: Codeunit "Web Request Helper";
        IsValidUri: Boolean;
        IsHttpUrl: Boolean;
        IsSecureHttpUrl: Boolean;
    begin
        IsValidUri := WebRequestHelper.IsValidUri(Url);
        IsHttpUrl := WebRequestHelper.IsHttpUrl(Url);
        IsSecureHttpUrl := WebRequestHelper.IsSecureHttpUrl(Url);
        Message(ValidationMsg,Url,IsValidUri,IsHttpUrl,IsSecureHttpUrl);
    end;
}

