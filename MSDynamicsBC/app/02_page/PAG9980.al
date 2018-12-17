page 9980 "Contact MS Sales"
{
    // version NAVW110.0

    Caption = 'Contact MS Sales';
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
        ContactSalesForwardLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=828707', Locked=true;
        ForwardLinkMgt: Codeunit "Forward Link Mgt.";
}

