page 9173 "User Personalization List"
{
    // version NAVW113.00

    ApplicationArea = Basic,Suite;
    Caption = 'User Personalizations';
    CardPageID = "User Personalization Card";
    Editable = false;
    PageType = List;
    SourceTable = "User Personalization";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("User ID";"User ID")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'User ID';
                    DrillDown = false;
                    ToolTip = 'Specifies the user ID of a user who is using Database Server Authentication to log on to Business Central.';
                }
                field("Profile ID";"Profile ID")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Profile ID';
                    Lookup = false;
                    ToolTip = 'Specifies the ID of the profile that is associated with the current user.';

                    trigger OnValidate()
                    var
                        UserPersonalizationCard: Page "User Personalization Card";
                    begin
                        UserPersonalizationCard.SetExperienceToEssential("Profile ID");
                    end;
                }
                field("Language ID";"Language ID")
                {
                    ApplicationArea = Basic,Suite;
                    BlankZero = true;
                    Caption = 'Language ID';
                    ToolTip = 'Specifies the ID of the language that Microsoft Windows is set up to run for the selected user.';
                }
                field("Locale ID";"Locale ID")
                {
                    ApplicationArea = Basic,Suite;
                    BlankZero = true;
                    Caption = 'Locale ID';
                    ToolTip = 'Specifies the ID of the locale that Microsoft Windows is set up to run for the selected user.';
                    Visible = false;
                }
                field("Time Zone";"Time Zone")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Time Zone';
                    ToolTip = 'Specifies the time zone that Microsoft Windows is set up to run for the selected user.';
                    Visible = false;
                }
                field(Company;Company)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Company';
                    Lookup = false;
                    ToolTip = 'Specifies the company that is associated with the user.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207;Links)
            {
                Visible = false;
            }
            systempart(Control1905767507;Notes)
            {
                Visible = false;
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        HideExternalUsers;
    end;

    local procedure HideExternalUsers()
    var
        PermissionManager: Codeunit "Permission Manager";
        OriginalFilterGroup: Integer;
    begin
        if not PermissionManager.SoftwareAsAService then
          exit;

        OriginalFilterGroup := FilterGroup;
        FilterGroup := 2;
        CalcFields("License Type");
        SetFilter("License Type",'<>%1',"License Type"::"External User");
        FilterGroup := OriginalFilterGroup;
    end;
}

