page 2870 "Native - Languages"
{
    // version NAVW111.00

    Caption = 'Native - Languages';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Windows Language";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(languageId;"Language ID")
                {
                    ApplicationArea = All;
                    Caption = 'languageId', Locked=true;
                }
                field(languageCode;LanguageCode)
                {
                    ApplicationArea = All;
                    Caption = 'languageCode';
                    Editable = false;
                    ToolTip = 'Specifies the language code.';
                }
                field(displayName;Name)
                {
                    ApplicationArea = All;
                    Caption = 'displayName', Locked=true;
                }
                field(default;Default)
                {
                    ApplicationArea = All;
                    Caption = 'default';
                    Editable = false;
                    ToolTip = 'Specifies if the language is the default.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    var
        UserPersonalization: Record "User Personalization";
        CultureInfo: DotNet CultureInfo;
    begin
        CultureInfo := CultureInfo.CultureInfo("Language ID");
        LanguageCode := CultureInfo.Name;
        Default := false;
        UserPersonalization.Get(UserSecurityId);
        if UserPersonalization."Language ID" = "Language ID" then
          Default := true;
    end;

    trigger OnOpenPage()
    var
        LanguageManagement: Codeunit LanguageManagement;
    begin
        LanguageManagement.GetApplicationLanguages(Rec);
    end;

    var
        LanguageCode: Text;
        Default: Boolean;
}

