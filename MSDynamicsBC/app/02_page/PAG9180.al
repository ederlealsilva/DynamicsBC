page 9180 "System Information"
{
    // version NAVW113.00

    ApplicationArea = All;
    Caption = 'System Information';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = StandardDialog;
    ShowFilter = false;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            field(Version;GetVersion)
            {
                ApplicationArea = All;
                Caption = 'Version';
            }
            field(CreatedDateTime;GetCreatedDateTime)
            {
                ApplicationArea = All;
                Caption = 'Created';
            }
            group(ErrorGroup)
            {
                Visible = ErrorOccurred;
                group("Error Details")
                {
                    Caption = 'Error Details';
                    field(ErrorText;GetLastErrorText)
                    {
                        ApplicationArea = Advanced;
                        Caption = 'Error Text';
                    }
                    field(ErrorCode;GetLastErrorCode)
                    {
                        ApplicationArea = Advanced;
                        Caption = 'Error Code';
                    }
                    field(ErrorCallStackLabel;'')
                    {
                        ApplicationArea = Advanced;
                        Caption = 'Error Callstack';
                    }
                    field(ErrorCallStack;GetLastErrorCallstack)
                    {
                        ApplicationArea = Advanced;
                        MultiLine = true;
                        ShowCaption = false;
                    }
                    field(ErrorObjectLabel;'')
                    {
                        ApplicationArea = Advanced;
                        Caption = 'Error Object';
                    }
                    field(ErrorObject;GetErrorObject)
                    {
                        ApplicationArea = Advanced;
                        MultiLine = true;
                        ShowCaption = false;
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
        ErrorOccurred := GetLastErrorCallstack <> '';
    end;

    var
        ApplicationSystemConstants: Codeunit "Application System Constants";
        ErrorOccurred: Boolean;

    local procedure GetVersion(): Text
    begin
        exit(StrSubstNo('%1 (%2)',ApplicationSystemConstants.ApplicationVersion,ApplicationSystemConstants.ApplicationBuild));
    end;

    local procedure GetCreatedDateTime(): DateTime
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get;

        exit(CompanyInformation."Created DateTime");
    end;

    local procedure GetErrorObject(): Text
    begin
        exit(Format(GetLastErrorObject));
    end;
}

