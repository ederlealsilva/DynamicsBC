page 2505 "Extension Installation Dialog"
{
    // version NAVW111.00

    Caption = 'Extension Installation Dialog';
    PageType = NavigatePage;
    SourceTable = "NAV App";

    layout
    {
        area(content)
        {
            group(Control7)
            {
                ShowCaption = false;
                Visible = IsVisible;
                fixed(Control3)
                {
                    //The GridLayout property is only supported on controls of type Grid
                    //GridLayout = Columns;
                    ShowCaption = false;
                    part(DetailsPart;"Extension Logo Part")
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Installing Extension';
                        ShowFilter = false;
                        SubPageLink = "Package ID"=FIELD("Package ID");
                        SubPageView = SORTING("Package ID")
                                      ORDER(Ascending);
                    }
                    group(Control4)
                    {
                        ShowCaption = false;
                        field(Control5;'')
                        {
                            ApplicationArea = Basic,Suite;
                            ShowCaption = false;
                        }
                        usercontrol(WebView;"Microsoft.Dynamics.Nav.Client.WebPageViewer")
                        {
                            ApplicationArea = Basic,Suite;
                        }
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        LanguageId := 1033; // Default to english if unset
        IsVisible := true; // Hack to get the navigation page 'button' to hide properly
    end;

    var
        NavExtensionInstallationMgmt: Codeunit NavExtensionInstallationMgmt;
        LanguageId: Integer;
        RestartActivityInstallMsg: Label 'The extension %1 was successfully installed. All active users must log out and log in again to see the navigation changes.', Comment='Indicates that users need to restart their activity to pick up new menusuite items. %1=Name of Extension';
        IsVisible: Boolean;

    local procedure InstallExtension(LangId: Integer)
    begin
        NavExtensionInstallationMgmt.InstallNavExtension("Package ID",LangId);

        // If successfully installed, message users to restart activity for menusuites
        if NavExtensionInstallationMgmt.IsInstalled("Package ID") then
          Message(StrSubstNo(RestartActivityInstallMsg,Name));

        CurrPage.Close;
    end;

    [Scope('Personalization')]
    procedure SetLanguageId(LangId: Integer)
    begin
        LanguageId := LangId
    end;
}

