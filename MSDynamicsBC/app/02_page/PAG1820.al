page 1820 "Video link Part"
{
    // version NAVW113.00

    Caption = 'Video link Part';
    Editable = false;
    PageType = CardPart;

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
        URL: Text;

    [Scope('Personalization')]
    procedure SetURL(NavigateToURL: Text)
    begin
        URL := NavigateToURL;
    end;

    procedure Navigate(NavigateToUrl: Text)
    begin
        URL := NavigateToUrl;
        CurrPage.WebPageViewer.Navigate(URL);
    end;
}

