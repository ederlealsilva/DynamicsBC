page 1608 "Office Error Dlg"
{
    // version NAVW111.00

    Caption = 'Something went wrong';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    ShowFilter = false;

    layout
    {
        area(content)
        {
            field(Control3;'')
            {
                Editable = false;
                Enabled = false;
                HideValue = true;
                ShowCaption = false;
            }
            field(ErrorText;ErrorText)
            {
                ApplicationArea = All;
                Editable = false;
                Enabled = false;
                MultiLine = true;
                ShowCaption = false;
                ToolTip = 'Specifies the text you enter that applies to the error.';
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    var
        OfficeErrorEngine: Codeunit "Office Error Engine";
    begin
        ErrorText := OfficeErrorEngine.GetError;
    end;

    var
        ErrorText: Text;
}

