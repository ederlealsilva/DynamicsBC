page 2844 "Native - QBO Sync Auth"
{
    // version NAVW111.00

    Caption = 'nativeQBOAuth', Locked=true;
    Editable = false;
    PageType = List;
    Permissions = TableData "Webhook Subscription"=rimd;
    SourceTable = "O365 Settings Menu";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(authorizationUrl;AuthorizationURL)
                {
                    ApplicationArea = All;
                    Caption = 'authorizationUrl', Locked=true;
                    ToolTip = 'Specifies QuickBooks Online Sync authorization url.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        QBOSyncProxy.GetQBOAuthURL(AuthorizationURL);
    end;

    trigger OnOpenPage()
    begin
        Insert;
    end;

    var
        QBOSyncProxy: Codeunit "QBO Sync Proxy";
        AuthorizationURL: Text;
}

