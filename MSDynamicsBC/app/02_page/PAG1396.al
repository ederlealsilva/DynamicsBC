page 1396 "Video Player Page Tablet"
{
    // version NAVW113.00

    Caption = 'Video Player';
    DelayedInsert = false;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = Document;
    ShowFilter = false;

    layout
    {
        area(content)
        {
            usercontrol(VideoPlayer;"Microsoft.Dynamics.Nav.Client.VideoPlayer")
            {
            }
            group(Control3)
            {
                ShowCaption = false;
                Visible = VideoLinkVisible;
                field(OpenSourceVideoInNewWindowLbl;OpenSourceVideoInNewWindowLbl)
                {
                    ApplicationArea = Basic,Suite;
                    Editable = false;
                    ShowCaption = false;

                    trigger OnDrillDown()
                    begin
                        HyperLink(LinkSrc);
                        CurrPage.Close;
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        CurrPage.Caption(NewCaption);
        SetSourceVideoVisible;
    end;

    var
        [InDataSet]
        Height: Integer;
        [InDataSet]
        Width: Integer;
        [InDataSet]
        Src: Text;
        LinkSrc: Text;
        [InDataSet]
        NewCaption: Text;
        OpenSourceVideoInNewWindowLbl: Label 'Watch the video in a new window.';
        VideoLinkVisible: Boolean;

    [Scope('Personalization')]
    procedure SetParameters(VideoHeight: Integer;VideoWidth: Integer;VideoSrc: Text;VideoLinkSrc: Text;PageCaption: Text)
    begin
        Height := VideoHeight;
        Width := VideoWidth;
        Src := VideoSrc;
        LinkSrc := VideoLinkSrc;
        NewCaption := PageCaption;
    end;

    local procedure SetSourceVideoVisible()
    begin
        VideoLinkVisible := false;

        if LinkSrc <> '' then
          VideoLinkVisible := true;
    end;
}

