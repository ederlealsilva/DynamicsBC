page 1305 "O365 Developer Welcome"
{
    // version NAVW113.00

    Caption = 'Welcome';
    PageType = NavigatePage;
    SourceTable = "O365 Getting Started";

    layout
    {
        area(content)
        {
            group(Control4)
            {
                ShowCaption = false;
                Visible = FirstPageVisible;
                field(Image1;PageDataMediaResources."Media Reference")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Image';
                    Editable = false;
                    ShowCaption = false;
                }
                group(Page1Group)
                {
                    Caption = 'This is your sandbox environment (preview) for Dynamics 365 Business Central';
                    field(MainTextLbl;MainTextLbl)
                    {
                        ApplicationArea = Basic,Suite;
                        Editable = false;
                        MultiLine = true;
                        ShowCaption = false;
                    }
                    field(SandboxTextLbl;SandboxTextLbl)
                    {
                        ApplicationArea = Basic,Suite;
                        Editable = false;
                        MultiLine = true;
                        ShowCaption = false;
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(WelcomeTour)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Learn More';
                Image = Start;
                InFooterBar = true;

                trigger OnAction()
                begin
                    HyperLink(LearnMoreLbl);
                    CurrPage.Close;
                end;
            }
        }
    }

    trigger OnInit()
    begin
        SetRange("User ID",UserId);
    end;

    trigger OnOpenPage()
    begin
        FirstPageVisible := true;
        O365GettingStartedPageData.GetPageImage(O365GettingStartedPageData,1,PAGE::"O365 Getting Started");
        if PageDataMediaResources.Get(O365GettingStartedPageData."Media Resources Ref") then;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        MarkAsCompleted;
    end;

    var
        O365GettingStartedPageData: Record "O365 Getting Started Page Data";
        MainTextLbl: Label 'This environment is for you to try out different product features without affecting data or settings in your production environment. You can use it for different non-production activities such as test, demonstration, or development. ';
        LearnMoreLbl: Label 'https://aka.ms/d365fobesandbox', Locked=true;
        PageDataMediaResources: Record "Media Resources";
        ClientTypeManagement: Codeunit ClientTypeManagement;
        FirstPageVisible: Boolean;
        SandboxTextLbl: Label 'This Sandbox environment feature is provided as a free preview solely for testing, development and evaluation. You will not use the Sandbox in a live operating environment. Microsoft may, in its sole discretion, change the Sandbox environment or subject it to a fee for a final, commercial version, if any, or may elect not to release one.';

    local procedure MarkAsCompleted()
    begin
        "User ID" := UserId;
        "Display Target" := Format(ClientTypeManagement.GetCurrentClientType);
        "Tour in Progress" := false;
        "Tour Completed" := true;
        Insert;
    end;
}

