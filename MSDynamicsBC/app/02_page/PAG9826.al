page 9826 "User ListPart"
{
    // version NAVW113.00

    Caption = 'User ListPart';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    RefreshOnActivate = true;
    ShowFilter = false;
    SourceTable = User;
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("User Name";"User Name")
                {
                    ApplicationArea = All;
                    TableRelation = User;
                    ToolTip = 'Specifies the name that the user must present when signing in. ';
                }
                field("Full Name";"Full Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the full name of the user.';
                }
            }
        }
    }

    actions
    {
    }

    procedure SetRec(var TempUser: Record User temporary)
    begin
        DeleteAll;

        if TempUser.FindSet then
          repeat
            TransferFields(TempUser);
            Insert;
          until TempUser.Next = 0;
    end;
}

