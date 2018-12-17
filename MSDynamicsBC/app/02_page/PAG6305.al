page 6305 "Power BI Report Dialog"
{
    // version NAVW111.00

    Caption = 'Power BI Report Dialog';
    Editable = false;
    LinksAllowed = false;
    ShowFilter = false;

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
        EmbedUrl: Text;
        PostMessage: Text;
        FilterPostMessage: Text;
        reportfirstpage: Text;

    [Scope('Personalization')]
    procedure SetUrl(Url: Text;Message: Text)
    begin
        EmbedUrl := Url;
        PostMessage := Message;
    end;

    [Scope('Personalization')]
    procedure SetFilter(filterMessage: Text;firstpage: Text)
    begin
        FilterPostMessage := filterMessage;
        reportfirstpage := firstpage;
    end;
}

