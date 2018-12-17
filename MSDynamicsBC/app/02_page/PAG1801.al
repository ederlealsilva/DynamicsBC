page 1801 "Assisted Setup"
{
    // version NAVW113.00

    AccessByPermission = TableData "Assisted Setup"=R;
    ApplicationArea = Basic,Suite;
    Caption = 'Assisted Setup';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    RefreshOnActivate = true;
    ShowFilter = false;
    SourceTable = "Aggregated Assisted Setup";
    SourceTableTemporary = true;
    SourceTableView = WHERE(Visible=FILTER(true),
                            "Assisted Setup Page ID"=FILTER(<>0));
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name;Name)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the name.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        RunAssistedSetup;
                        CurrPage.Update(false);
                    end;
                }
                field(Status;Status)
                {
                    ApplicationArea = Basic,Suite;
                    StyleExpr = StyleText;
                    ToolTip = 'Specifies if the setup is completed.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        RunAssistedSetup;
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Start Setup")
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Start Setup';
                Image = Setup;
                Scope = Repeater;
                ShortCutKey = 'Return';
                ToolTip = 'Start the assisted setup guide.';

                trigger OnAction()
                begin
                    RunAssistedSetup;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetStyle;
    end;

    trigger OnOpenPage()
    begin
        OnRegisterAssistedSetup(Rec);
        SetCurrentKey("External Assisted Setup",Order);
        Ascending(true);
    end;

    var
        StyleText: Text;

    local procedure SetStyle()
    begin
        case Status of
          Status::Completed:
            StyleText := 'Favorable';
          else
            StyleText := 'Standard';
        end;
    end;
}

