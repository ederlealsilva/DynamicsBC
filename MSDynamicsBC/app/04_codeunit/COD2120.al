codeunit 2120 "O365 Sales Disable BC Pages"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        IdentityManagement: Codeunit "Identity Management";
        NotAccessibleInMicrosoftInvoicingErr: Label 'This page is currently not available in Microsoft Invoicing.\For more information, see %1.', Comment='%1 = url to help page';
        NotAccessibleInMicrosoftInvoicingUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2005502', Locked=true;

    [EventSubscriber(ObjectType::Page, 9176, 'OnOpenPageEvent', '', false, false)]
    procedure RedirectMySettings()
    begin
        if not IdentityManagement.IsInvAppId then
          exit;

        PAGE.RunModal(PAGE::"BC O365 My Settings");
        Error('');
    end;

    [EventSubscriber(ObjectType::Page, 1751, 'OnOpenPageEvent', '', false, false)]
    procedure DisableDataClassificationWorksheet(var Rec: Record "Data Sensitivity")
    begin
        CheckInvoicingIdentityAndError
    end;

    [EventSubscriber(ObjectType::Page, 1518, 'OnOpenPageEvent', '', false, false)]
    procedure DisableMyNotifications(var Rec: Record "My Notifications")
    begin
        CheckInvoicingIdentityAndError
    end;

    [EventSubscriber(ObjectType::Page, 9179, 'OnOpenPageEvent', '', false, false)]
    procedure DisableApplicationArea(var Rec: Record "Application Area Buffer")
    begin
        CheckInvoicingIdentityAndError
    end;

    [EventSubscriber(ObjectType::Page, 1308, 'OnOpenPageEvent', '', false, false)]
    procedure DisableO365DeviceSetup(var Rec: Record "O365 Device Setup Instructions")
    begin
        CheckInvoicingIdentityAndError
    end;

    local procedure CheckInvoicingIdentityAndError()
    begin
        if not IdentityManagement.IsInvAppId then
          exit;

        Error(NotAccessibleInMicrosoftInvoicingErr,NotAccessibleInMicrosoftInvoicingUrlTxt);
    end;
}

