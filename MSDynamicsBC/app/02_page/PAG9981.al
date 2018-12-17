page 9981 "Buy Subscription"
{
    // version NAVW110.0

    Caption = 'Buy Subscription';
    Editable = false;

    layout
    {
        area(content)
        {
            usercontrol(WebPageViewer;"Microsoft.Dynamics.Nav.Client.WebPageViewer")
            {
                ApplicationArea = Basic,Suite;
            }
        }
    }

    actions
    {
    }

    var
        BuySubscriptionForwardLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=828659', Locked=true;
        ForwardLinkMgt: Codeunit "Forward Link Mgt.";
}

