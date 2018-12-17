page 9194 "Available Profiles"
{
    // version NAVW111.00

    Caption = 'Available Profiles';
    DelayedInsert = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "All Profile";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Profile ID";"Profile ID")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the profile ID types which are available to use.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies a description of the Role Center.';
                }
                field(Scope;Scope)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Scope';
                    ToolTip = 'Specifies if the profile is general for the system or applies to a tenant database.';
                }
                field("App Name";"App Name")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Extension Name';
                    ToolTip = 'Specifies the name of the extension that provided the profile.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
    begin
        ConfPersonalizationMgt.HideSandboxProfiles(Rec);
    end;
}

