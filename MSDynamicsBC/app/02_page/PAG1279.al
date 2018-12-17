page 1279 "Service Connections"
{
    // version NAVW113.00

    ApplicationArea = Basic,Suite;
    Caption = 'Service Connections';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "Service Connection";
    SourceTableTemporary = true;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name;Name)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the service. The description is based on the name of the setup page that opens when you choose the Setup.';
                }
                field("Host Name";"Host Name")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the name of the web service. This is typically a URL.';
                    Visible = false;
                }
                field(Status;Status)
                {
                    ApplicationArea = Basic,Suite;
                    StyleExpr = StyleExpression;
                    ToolTip = 'Specifies if the service is enabled or disabled.';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Setup)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Setup';
                Enabled = SetupActive;
                Image = Setup;
                Scope = Repeater;
                ShortCutKey = 'Return';
                ToolTip = 'Get a connection to a service up and running or manage an connection that is already working.';

                trigger OnAction()
                begin
                    CallSetup;
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        RefreshPressed: Boolean;
    begin
        RefreshPressed := CurrRecordNo = "No.";
        if RefreshPressed then
          Refresh
        else
          CurrRecordNo := "No.";
        SetupActive := "Page ID" <> 0;
        SetStyle;
    end;

    trigger OnAfterGetRecord()
    begin
        SetStyle;
    end;

    trigger OnOpenPage()
    begin
        ReloadServiceConnections;
    end;

    var
        SetupActive: Boolean;
        StyleExpression: Text;
        CurrRecordNo: Text;

    local procedure CallSetup()
    var
        AssistedSetup: Record "Assisted Setup";
        RecordRefVariant: Variant;
        RecordRef: RecordRef;
    begin
        if not SetupActive then
          exit;
        RecordRef.Get("Record ID");
        if ((Status = Status::Error) or (Status = Status::Disabled)) and
           ("Assisted Setup Page ID" > 0) and
           AssistedSetup.Get("Assisted Setup Page ID") and
           (AssistedSetup.Status = AssistedSetup.Status::"Not Completed") and
           AssistedSetup.Visible
        then
          AssistedSetup.Run
        else begin
          RecordRef.Get("Record ID");
          RecordRefVariant := RecordRef;
          PAGE.RunModal("Page ID",RecordRefVariant);
        end;
        ReloadServiceConnections;
        if Get(xRec."No.") then;
        CurrPage.Update(false);
    end;

    local procedure SetStyle()
    begin
        case Status of
          Status::Disabled:
            StyleExpression := 'Standard';
          Status::Connected,Status::Enabled:
            StyleExpression := 'Favorable';
          Status::Error:
            StyleExpression := 'Unfavorable';
        end
    end;

    local procedure Refresh()
    begin
        ReloadServiceConnections;
        CurrRecordNo := '';
        if Get(xRec."No.") then;
        CurrPage.Activate(true);
    end;

    local procedure ReloadServiceConnections()
    begin
        DeleteAll;
        OnRegisterServiceConnection(Rec);
    end;
}

