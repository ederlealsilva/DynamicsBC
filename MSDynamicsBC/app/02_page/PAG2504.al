page 2504 "Extension Details Part"
{
    // version NAVW110.0

    Caption = 'Extension Details Part';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = CardPart;
    PopulateAllFields = true;
    RefreshOnActivate = true;
    ShowFilter = false;
    SourceTable = "NAV App";

    layout
    {
        area(content)
        {
            group(Control8)
            {
                //The GridLayout property is only supported on controls of type Grid
                //GridLayout = Rows;
                ShowCaption = false;
                group(Control2)
                {
                    ShowCaption = false;
                    field(Logo;Logo)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Logo';
                        Editable = false;
                        ShowCaption = false;
                        ToolTip = 'Specifies the logo of the extension, such as the logo of the service provider.';
                    }
                }
            }
            group(Control4)
            {
                //The GridLayout property is only supported on controls of type Grid
                //GridLayout = Rows;
                ShowCaption = false;
                group(Control9)
                {
                    ShowCaption = false;
                    field(Name;Name)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Name';
                        MultiLine = true;
                        ToolTip = 'Specifies the name of the extension.';
                    }
                    field(Publisher;Publisher)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Publisher';
                        MultiLine = true;
                        ToolTip = 'Specifies the person or company that created the extension.';
                    }
                    field(Version;VersionDisplay)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Version';
                        ToolTip = 'Specifies the version of the extension.';
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        VersionDisplay :=
          NavExtensionInstallationMgmt.GetVersionDisplayString(
            "Version Major","Version Minor",
            "Version Build","Version Revision");
    end;

    var
        NavExtensionInstallationMgmt: Codeunit NavExtensionInstallationMgmt;
        VersionDisplay: Text;
}

