page 2506 "Extension Logo Part"
{
    // version NAVW110.0

    Caption = 'Extension Logo Part';
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
            group(Control4)
            {
                ShowCaption = false;
                group(Control3)
                {
                    ShowCaption = false;
                    field(Logo;Logo)
                    {
                        ApplicationArea = Basic,Suite;
                        ToolTip = 'Specifies the logo of the extension, such as the logo of the service provider.';
                    }
                }
            }
        }
    }

    actions
    {
    }
}

