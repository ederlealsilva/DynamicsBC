page 2139 "O365 Language Settings"
{
    // version NAVW113.00

    Caption = 'Language';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = CardPart;

    layout
    {
        area(content)
        {
            group(Control11)
            {
                InstructionalText = 'Select your language. You must sign out and then sign in again for the change to take effect.';
                ShowCaption = false;
                field(Language;Language)
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Caption = 'Language';
                    Importance = Promoted;
                    QuickEntry = false;
                    ToolTip = 'Specifies the display language, on all devices. You must sign out and then sign in again for the change to take effect.';

                    trigger OnAssistEdit()
                    var
                        LanguageManagement: Codeunit LanguageManagement;
                    begin
                        LanguageManagement.LookupApplicationLanguage(LanguageID);
                        Language := GetLanguage;
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        UserPersonalization: Record "User Personalization";
    begin
        with UserPersonalization do begin
          Get(UserSecurityId);
          LanguageID := "Language ID";
        end;
        Language := GetLanguage;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        UserPersonalization: Record "User Personalization";
    begin
        with UserPersonalization do begin
          Get(UserSecurityId);
          if "Language ID" <> LanguageID then begin
            Validate("Language ID",LanguageID);
            Modify(true);
            Message(ReSignInMsg);
          end;
        end;
    end;

    var
        LanguageID: Integer;
        ReSignInMsg: Label 'You must sign out and then sign in again for the change to take effect.', Comment='"sign out" and "sign in" are the same terms as shown in the Business Central client.';
        Language: Text;

    local procedure GetLanguage(): Text
    begin
        exit(GetWindowsLanguageNameFromID(LanguageID));
    end;

    local procedure GetWindowsLanguageNameFromID(ID: Integer): Text
    var
        WindowsLanguage: Record "Windows Language";
    begin
        if WindowsLanguage.Get(ID) then
          exit(WindowsLanguage.Name);
    end;
}

