page 2375 "BC O365 Quickbooks Settings"
{
    // version NAVW113.00

    Caption = ' ';
    PageType = CardPart;

    layout
    {
        area(content)
        {
            field(SyncWithQb;SyncWithQbLbl)
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Editable = false;
                ShowCaption = false;
            }
            field(SyncWithQbo;SyncWithQboLbl)
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Editable = false;
                ShowCaption = false;
                Visible = QBOVisible;

                trigger OnDrillDown()
                begin
                    OnQuickBooksOnlineSyncClicked;
                end;
            }
            field(SyncWithQbd;SyncWithQbdLbl)
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Editable = false;
                ShowCaption = false;
                Visible = QBDVisible;

                trigger OnDrillDown()
                begin
                    OnQuickBooksDesktopSyncClicked;
                end;
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        SetVisibility;
    end;

    var
        SyncWithQbLbl: Label 'You can connect Invoicing with QuickBooks, so you have access to data and contacts in both places.';
        SyncWithQboLbl: Label 'For QuickBooks Online, start by importing your contacts.';
        SyncWithQbdLbl: Label 'For QuickBooks Desktop, launch the setup guide.';
        O365SalesManagement: Codeunit "O365 Sales Management";
        QBDVisible: Boolean;
        QBOVisible: Boolean;

    [IntegrationEvent(false, false)]
    procedure OnQuickBooksOnlineSyncClicked()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnQuickBooksDesktopSyncClicked()
    begin
    end;

    local procedure SetVisibility()
    begin
        O365SalesManagement.GetQboQbdVisibility(QBOVisible,QBDVisible);
    end;
}

