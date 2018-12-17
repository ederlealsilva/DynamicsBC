page 2337 "BC O365 Language Settings"
{
    // version NAVW113.00

    Caption = ' ';
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
                InstructionalText = 'Select your preferred language. This will also apply to the documents you send. You must sign out and then sign in again for the change to take effect.';
                ShowCaption = false;
            }
            group(Control2)
            {
                ShowCaption = false;
                field(Language;LanguageName)
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Caption = 'Language';
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the language that pages are shown in. You must sign out and then sign in again for the change to take effect.';

                    trigger OnAssistEdit()
                    var
                        UserPersonalization: Record "User Personalization";
                    begin
                        LanguageManagement.LookupApplicationLanguage(LanguageID);
                        LanguageName := GetLanguage;
                        with UserPersonalization do begin
                          Get(UserSecurityId);
                          if "Language ID" <> LanguageID then begin
                            Validate("Language ID",LanguageID);
                            Modify(true);
                            Message(ReSignInMsg);
                          end;
                        end;
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
        LanguageName := GetLanguage;
    end;

    var
        LanguageManagement: Codeunit LanguageManagement;
        LanguageID: Integer;
        ReSignInMsg: Label 'You must sign out and then sign in again for the change to take effect.', Comment='"sign out" and "sign in" are the same terms as shown in the Business Central client.';
        LanguageName: Text;

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

