page 1822 "Setup and Help Resource Visual"
{
    // version NAVW113.00

    ApplicationArea = Basic,Suite;
    Caption = 'Setup and Help Resources';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Details';
    SourceTable = "Assisted Setup";
    SourceTableView = SORTING(Order,Visible)
                      WHERE(Visible=CONST(true));
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item Type";"Item Type")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the type of resource.';
                }
                field(Name;Name)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the name.';

                    trigger OnDrillDown()
                    begin
                        Navigate;
                    end;
                }
                field(Icon;Icon)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the icon for the button that opens the resource.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Manage)
            {
                Caption = 'Manage';
                action(View)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'View';
                    Image = View;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ShortCutKey = 'Return';
                    ToolTip = 'View extension details.';

                    trigger OnAction()
                    begin
                        Navigate;
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        SetRange(Parent,0);
    end;
}

