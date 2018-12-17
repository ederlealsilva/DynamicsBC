page 535 "Windows Languages"
{
    // version NAVW110.0

    Caption = 'Available Languages';
    Editable = false;
    PageType = List;
    SourceTable = "Windows Language";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Language ID";"Language ID")
                {
                    ApplicationArea = All;
                    Caption = 'ID';
                    ToolTip = 'Specifies the unique language ID for the Windows language.';
                    Visible = false;
                }
                field(Name;Name)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    ToolTip = 'Specifies the names of the available Windows languages.';
                }
            }
        }
    }

    actions
    {
    }
}

