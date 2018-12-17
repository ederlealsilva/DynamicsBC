page 2140 "O365 Sync with Microsoft Apps"
{
    // version NAVW113.00

    Caption = 'Sync with Microsoft Apps';

    layout
    {
        area(content)
        {
            group(Control7)
            {
                ShowCaption = false;
                field(EnableSync;EnableSync)
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Caption = 'Enable Synchronization';
                    ToolTip = 'Specifies whether Microsoft synchronization is enabled.';

                    trigger OnValidate()
                    var
                        O365SalesBackgroundSetup: Codeunit "O365 Sales Background Setup";
                    begin
                        if not EnableSync then
                          if not Confirm(ConfirmDisablingSyncQst,false) then
                            Error('');

                        O365SalesBackgroundSetup.InitializeGraphSync(EnableSync,false);

                        SetUserName;

                        // Coupons sync changes state along with graph sync
                        SyncCoupons := EnableSync;
                        StoreCouponsSync;
                    end;
                }
                field(SyncCoupons;SyncCoupons)
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Caption = 'Show coupons';
                    ToolTip = 'Specifies if you want to see coupons when you create a new invoice or estimate.';

                    trigger OnValidate()
                    begin
                        StoreCouponsSync;
                    end;
                }
                field(SyncUser;UserName)
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Caption = 'User';
                    Editable = false;
                    ToolTip = 'Specifies the user who owns the synchronization jobs.';
                    Visible = UsernameVisible;

                    trigger OnAssistEdit()
                    var
                        SelectedUser: Record User;
                        MarketingSetup: Record "Marketing Setup";
                    begin
                        if not EnableSync then
                          exit;

                        SelectedUser.SetFilter("License Type",'<> %1',SelectedUser."License Type"::"External User");
                        if not (PAGE.RunModal(PAGE::Users,SelectedUser) = ACTION::LookupOK) then
                          exit;

                        MarketingSetup.Get;
                        if MarketingSetup.TrySetWebhookSubscriptionUser(SelectedUser."User Security ID") then begin
                          MarketingSetup.Modify(true);
                          UserName := SelectedUser."User Name";
                        end
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        UsernameVisible := not ClientTypeManagement.IsPhoneClientType;
    end;

    trigger OnOpenPage()
    var
        MarketingSetup: Record "Marketing Setup";
        O365SalesInitialSetup: Record "O365 Sales Initial Setup";
    begin
        if MarketingSetup.Get then
          EnableSync := MarketingSetup."Sync with Microsoft Graph";
        SetUserName;
        if O365SalesInitialSetup.Get then
          SyncCoupons := O365SalesInitialSetup."Coupons Integration Enabled";
    end;

    var
        ClientTypeManagement: Codeunit ClientTypeManagement;
        EnableSync: Boolean;
        UserName: Text;
        UsernameVisible: Boolean;
        SyncCoupons: Boolean;
        ConfirmDisablingSyncQst: Label 'If you disable synchronization with other Microsoft apps, some of the functionality in the Invoicing app will not be available. Do you want to disable sync with Microsoft apps?';

    local procedure SetUserName()
    var
        MarketingSetup: Record "Marketing Setup";
        User: Record User;
    begin
        if EnableSync then begin
          if User.Get(MarketingSetup.GetWebhookSubscriptionUser) then
            UserName := User."User Name";
        end else
          UserName := '';
    end;

    local procedure StoreCouponsSync()
    var
        O365SalesInitialSetup: Record "O365 Sales Initial Setup";
    begin
        O365SalesInitialSetup.Get;
        O365SalesInitialSetup."Coupons Integration Enabled" := SyncCoupons;
        O365SalesInitialSetup.Modify(true);
    end;
}

