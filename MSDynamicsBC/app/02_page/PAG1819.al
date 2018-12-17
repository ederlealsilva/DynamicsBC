page 1819 "Setup and Help Resource Card"
{
    // version NAVW113.00

    Caption = 'Setup and Help Resources';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = NavigatePage;
    SourceTable = "Assisted Setup";
    SourceTableView = SORTING(Order,Visible)
                      WHERE(Visible=CONST(true));

    layout
    {
        area(content)
        {
            repeater(Resources)
            {
                Caption = 'Resources';
                Editable = false;
                field(Icon;Icon)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Icon';
                }
                field(Resource;Name)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Resource';
                }
                field(Help;HelpAvailable)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Help';
                    StyleExpr = HelpStyle;
                    Width = 3;

                    trigger OnDrillDown()
                    begin
                        NavigateHelpPage;
                        CurrPage.Update;
                    end;
                }
                field(Video;VideoAvailable)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Video';
                    StyleExpr = VideoStyle;
                    Width = 3;

                    trigger OnDrillDown()
                    begin
                        NavigateVideo;
                        CurrPage.Update;
                    end;
                }
                field("Assisted Setup";AssistedSetupAvailable)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Assisted Setup';
                    StyleExpr = AssistedSetupStyle;
                    Width = 3;

                    trigger OnDrillDown()
                    begin
                        if "Assisted Setup Page ID" = 0 then
                          exit;
                        Run;
                        Get("Page ID");
                        CurrPage.Update;
                    end;
                }
                field("Product Tour";TourAvailable)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Product Tour';
                    StyleExpr = TourStyle;
                    Width = 3;

                    trigger OnDrillDown()
                    begin
                        if "Tour Id" = 0 then
                          exit;
                        StartProductTour("Tour Id");
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Manage)
            {
                Caption = 'Manage';
                action(View)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'View';
                    Image = View;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunPageMode = View;
                    ShortCutKey = 'Return';

                    trigger OnAction()
                    var
                        LocalAssistedSetup: Record "Assisted Setup";
                    begin
                        CurrPage.SetSelectionFilter(LocalAssistedSetup);
                        if LocalAssistedSetup.FindFirst then
                          LocalAssistedSetup.Navigate;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        HelpAvailable := '';
        VideoAvailable := '';
        TourAvailable := '';
        AssistedSetupAvailable := '';
        HelpStyle := StandardStatusStyleTok;
        AssistedSetupStyle := StandardStatusStyleTok;
        TourStyle := StandardStatusStyleTok;
        VideoStyle := StandardStatusStyleTok;

        if "Help Url" <> '' then begin
          HelpAvailable := HelpLinkTxt;
          if "Help Status" then
            HelpStyle := SeenStatusStyleTok
          else
            HelpStyle := StandardStatusStyleTok;
        end;

        if "Assisted Setup Page ID" <> 0 then begin
          AssistedSetupAvailable := AssistedSetupLinkTxt;
          if Status = Status::Completed then
            AssistedSetupStyle := SeenStatusStyleTok
          else
            AssistedSetupStyle := StandardStatusStyleTok;
        end;

        if "Tour Id" <> 0 then begin
          TourAvailable := TourLinkTxt;
          if "Tour Status" then
            TourStyle := SeenStatusStyleTok
          else
            TourStyle := StandardStatusStyleTok;
        end;

        if "Video Url" <> '' then begin
          VideoAvailable := VideoLinkTxt;
          if "Video Status" then
            VideoStyle := SeenStatusStyleTok
          else
            VideoStyle := StandardStatusStyleTok;
        end;
    end;

    trigger OnOpenPage()
    begin
        SetRange(Parent,ParentID);
        SetCurrentKey(Order,Visible);
    end;

    var
        [RunOnClient]
        [WithEvents]
        UserTourObj: DotNet UserTours;
        ParentID: Integer;
        TourNotAvailableMsg: Label 'Tour is not available.';
        HelpAvailable: Text;
        VideoAvailable: Text;
        AssistedSetupAvailable: Text;
        TourAvailable: Text;
        HelpLinkTxt: Label 'Read';
        VideoLinkTxt: Label 'Watch';
        AssistedSetupLinkTxt: Label 'Start';
        TourLinkTxt: Label 'Try';
        HelpStyle: Text;
        VideoStyle: Text;
        TourStyle: Text;
        AssistedSetupStyle: Text;
        StandardStatusStyleTok: Label 'Standard', Locked=true;
        SeenStatusStyleTok: Label 'Subordinate', Locked=true;

    [Scope('Personalization')]
    procedure SetGroup(GroupID: Integer)
    begin
        ParentID := GroupID;
    end;

    local procedure StartProductTour(TourID: Integer)
    begin
        if UserTourObj.IsAvailable then begin
          UserTourObj := UserTourObj.Create;
          UserTourObj.StartUserTour(TourID);
          CurrPage.Close;
        end else
          Message(TourNotAvailableMsg);
    end;

    trigger UserTourObj::ShowTourWizard(hasTourCompleted: Boolean)
    begin
    end;

    trigger UserTourObj::IsTourInProgressResultReady(isInProgress: Boolean)
    begin
    end;
}

