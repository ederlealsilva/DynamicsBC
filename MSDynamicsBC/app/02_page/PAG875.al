page 875 "Social Listening FactBox"
{
    // version NAVW113.00

    Caption = 'Social Media Insights';
    PageType = CardPart;
    SourceTable = "Social Listening Search Topic";

    layout
    {
        area(content)
        {
            usercontrol(SocialListening;"Microsoft.Dynamics.Nav.Client.SocialListening")
            {
                ApplicationArea = Suite;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        IsDataReady := true;
        UpdateAddIn;
    end;

    var
        SocialListeningMgt: Codeunit "Social Listening Management";
        IsDataReady: Boolean;
        IsAddInReady: Boolean;

    local procedure UpdateAddIn()
    var
        SocialListeningSetup: Record "Social Listening Setup";
    begin
        if "Search Topic" = '' then
          exit;
        if not IsAddInReady then
          exit;

        if not IsDataReady then
          exit;

        if not SocialListeningSetup.Get or
           (SocialListeningSetup."Solution ID" = '')
        then
          exit;

        CurrPage.SocialListening.DetermineUserAuthentication(SocialListeningMgt.MSLAuthenticationStatusURL);
    end;
}

