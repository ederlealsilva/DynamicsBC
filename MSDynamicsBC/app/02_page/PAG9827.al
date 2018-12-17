page 9827 "User Buffer List"
{
    // version NAVW113.00

    Caption = 'User List';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
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
                    ToolTip = 'Specifies the name that the user must present when signing in.';
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
        area(processing)
        {
            action(AddUser)
            {
                ApplicationArea = All;
                Caption = 'Add';
                Image = Add;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    User: Record User;
                    UserLookup: Page "User Lookup";
                begin
                    UserLookup.LookupMode := true;

                    if UserLookup.RunModal = ACTION::LookupOK then begin
                      UserLookup.GetSelectionFilter(User);
                      if User.FindSet then
                        repeat
                          if not Get(User."User Security ID") then begin
                            Init;
                            "User Security ID" := User."User Security ID";
                            "User Name" := User."User Name";
                            "Full Name" := User."Full Name";
                            Insert;
                          end;
                        until User.Next = 0;
                    end;
                end;
            }
            action(DeleteUser)
            {
                ApplicationArea = All;
                Caption = 'Delete Selected';
                Image = Delete;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    User: Record User;
                begin
                    CurrPage.SetSelectionFilter(User);

                    if not User.FindSet then
                      exit;

                    repeat
                      Get(User."User Security ID");
                      Delete;
                    until User.Next = 0;
                end;
            }
        }
    }
}

