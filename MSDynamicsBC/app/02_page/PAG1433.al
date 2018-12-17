page 1433 "Net Promoter Score"
{
    // version NAVW111.00

    Caption = ' ';
    PageType = Card;

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
        NetPromoterScoreMgt: Codeunit "Net Promoter Score Mgt.";

    local procedure Navigate()
    var
        Url: Text;
    begin
        Url := NetPromoterScoreMgt.GetRenderUrl;
        if Url = '' then
          exit;
        CurrPage.WebPageViewer.SubscribeToEvent('message',Url);
        CurrPage.WebPageViewer.Navigate(Url);
    end;
}

