page 1875 "Business Setup"
{
    // version NAVW113.00

    AccessByPermission = TableData "Business Setup"=R;
    ApplicationArea = Basic,Suite;
    Caption = 'Business Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Business Setup";
    SourceTableTemporary = true;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name;Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the business.';
                }
                field(Description;Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the business.';
                }
                field("Area";Area)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the area of the customer or vendor, for the purpose of reporting to INTRASTAT.';
                }
                field(Keywords;Keywords)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which keywords relate to the business setup on the line.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Open Manual Setup")
            {
                ApplicationArea = All;
                Caption = 'Open Manual Setup';
                Image = Edit;
                Scope = Repeater;
                ShortCutKey = 'Return';
                ToolTip = 'View or edit the setup windows for various business functionality that you can set up manually. ';

                trigger OnAction()
                var
                    Handled: Boolean;
                begin
                    OnOpenBusinessSetupPage(Rec,Handled);
                    if (not Handled) and ("Setup Page ID" <> 0) then
                      PAGE.Run("Setup Page ID");
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        OnRegisterBusinessSetup(Rec);
    end;
}

