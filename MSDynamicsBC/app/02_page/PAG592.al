page 592 "Change Log Setup"
{
    // version NAVW113.00

    ApplicationArea = Basic,Suite;
    Caption = 'Change Log Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    PromotedActionCategories = 'New,Process,Report,Setup';
    SourceTable = "Change Log Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Change Log Activated";"Change Log Activated")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies that the change log is active.';

                    trigger OnValidate()
                    begin
                        ConfirmActivationOfChangeLog;
                    end;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207;Links)
            {
                Visible = false;
            }
            systempart(Control1905767507;Notes)
            {
                Visible = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("&Setup")
            {
                Caption = '&Setup';
                Image = Setup;
                action(Tables)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Tables';
                    Image = "Table";
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    ToolTip = 'View what must be logged for each table.';

                    trigger OnAction()
                    var
                        ChangeLogSetupList: Page "Change Log Setup (Table) List";
                    begin
                        ChangeLogSetupList.SetSource;
                        ChangeLogSetupList.RunModal;
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
          Init;
          Insert;
        end;
    end;

    var
        ActivateChangeLogQst: Label 'Turning on the Change Log might slow things down, especially if you are monitoring entities that often change. Do you want to log changes?';

    local procedure ConfirmActivationOfChangeLog()
    var
        PermissionManager: Codeunit "Permission Manager";
    begin
        if not "Change Log Activated" then
          exit;
        if not PermissionManager.SoftwareAsAService then
          exit;
        if not Confirm(ActivateChangeLogQst,true) then
          Error('');
    end;
}

