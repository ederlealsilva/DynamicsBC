page 9190 "Delete Profile Configuration"
{
    // version NAVW113.00

    ApplicationArea = Basic,Suite;
    Caption = 'Delete Profile Configuration';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Profile Metadata";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1106000000)
            {
                ShowCaption = false;
                field("Profile ID";"Profile ID")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Profile ID';
                    ToolTip = 'Specifies the profile for which the customization has been created.';
                }
                field("Page ID";"Page ID")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Page ID';
                    ToolTip = 'Specifies the number of the page object that has been configured.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Description';
                    ToolTip = 'Specifies a description of the customization.';
                }
                field(Date;Date)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Date';
                    ToolTip = 'Specifies the date of the customization.';
                }
                field(Time;Time)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Time';
                    ToolTip = 'Specifies a timestamp for the customization.';
                }
            }
        }
    }

    actions
    {
    }
}

