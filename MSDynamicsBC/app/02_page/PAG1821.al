page 1821 "Video link"
{
    // version NAVW113.00

    Caption = 'Video link';
    Editable = false;
    PageType = Card;

    layout
    {
        area(content)
        {
            group(Control5)
            {
                ShowCaption = false;
            }
            usercontrol(WebPageViewer;"Microsoft.Dynamics.Nav.Client.WebPageViewer")
            {
                ApplicationArea = Basic,Suite,Invoicing;
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

