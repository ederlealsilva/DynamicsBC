codeunit 1330 "Instruction Mgt."
{
    // version NAVW113.00

    Permissions = TableData "My Notifications"=rimd;

    trigger OnRun()
    begin
    end;

    var
        WarnUnpostedDocumentsTxt: Label 'Warn about unposted documents.';
        WarnUnpostedDocumentsDescriptionTxt: Label 'Show warning when you close a document that you have not posted.';
        ConfirmAfterPostingDocumentsTxt: Label 'Confirm after posting documents.';
        ConfirmAfterPostingDocumentsDescriptionTxt: Label 'Show warning when you post a document where you can choose to view the posted document.';
        ConfirmPostingAfterCurrentFiscalYearTxt: Label 'Confirm posting after the current fiscal year.';
        ConfirmPostingAfterCurrentFiscalYearDescriptionTxt: Label 'Show warning when you post entries where the posting date is after the current fiscal year.';
        MarkBookingAsInvoicedWarningTxt: Label 'Confirm marking booking as invoiced.';
        MarkBookingAsInvoicedWarningDescriptionTxt: Label 'Show warning when you mark a Booking appointment as invoiced.';
        OfficeUpdateNotificationTxt: Label 'Notify user of Outlook add-in update.';
        OfficeUpdateNotificationDescriptionTxt: Label 'Ask user to update their Outlook add-in when an update is available.';
        AutomaticLineItemsDialogNotificationTxt: Label 'Discover line items in Outlook add-in';
        AutomaticLineItemsDialogNotificationDescriptionTxt: Label 'Scan the email body for potential line items when you create documents in the Outlook add-in.';
        ClosingUnreleasedOrdersNotificationTxt: Label 'Warn about unreleased orders.';
        ClosingUnreleasedOrdersNotificationDescriptionTxt: Label 'Show warning when you close an order that you have not released.';
        ClosingUnreleasedOrdersConfirmQst: Label 'The document has not been released.\Are you sure you want to exit?';

    [Scope('Personalization')]
    procedure ShowConfirm(ConfirmQst: Text;InstructionType: Code[50]): Boolean
    begin
        if GuiAllowed and IsEnabled(InstructionType) then
          exit(Confirm(ConfirmQst));

        exit(true);
    end;

    [Scope('Personalization')]
    procedure ShowConfirmUnreleased(): Boolean
    begin
        exit(ShowConfirm(ClosingUnreleasedOrdersConfirmQst,ClosingUnreleasedOrdersCode));
    end;

    [Scope('Personalization')]
    procedure DisableMessageForCurrentUser(InstructionType: Code[50])
    var
        UserPreference: Record "User Preference";
    begin
        UserPreference.DisableInstruction(InstructionType);
    end;

    [Scope('Personalization')]
    procedure EnableMessageForCurrentUser(InstructionType: Code[50])
    var
        UserPreference: Record "User Preference";
    begin
        UserPreference.EnableInstruction(InstructionType);
    end;

    [Scope('Personalization')]
    procedure IsEnabled(InstructionType: Code[50]): Boolean
    var
        UserPreference: Record "User Preference";
    begin
        exit(not UserPreference.Get(UserId,InstructionType));
    end;

    [Scope('Personalization')]
    procedure IsUnpostedEnabledForRecord("Record": Variant): Boolean
    var
        MyNotifications: Record "My Notifications";
    begin
        exit(MyNotifications.IsEnabledForRecord(GetClosingUnpostedDocumentNotificationId,Record));
    end;

    [Scope('Personalization')]
    procedure IsMyNotificationEnabled(NotificationID: Guid): Boolean
    var
        MyNotifications: Record "My Notifications";
    begin
        if not MyNotifications.Get(UserId,NotificationID) then
          exit(false);

        exit(MyNotifications.Enabled);
    end;

    [Scope('Personalization')]
    procedure ShowPostedConfirmationMessageCode(): Code[50]
    begin
        exit(UpperCase('ShowPostedConfirmationMessage'));
    end;

    [Scope('Personalization')]
    procedure QueryPostOnCloseCode(): Code[50]
    begin
        exit(UpperCase('QueryPostOnClose'));
    end;

    [Scope('Personalization')]
    procedure OfficeUpdateNotificationCode(): Code[50]
    begin
        exit(UpperCase('OfficeUpdateNotification'));
    end;

    [Scope('Personalization')]
    procedure PostingAfterCurrentFiscalYearNotAllowedCode(): Code[50]
    begin
        exit(UpperCase('PostingAfterCurrentFiscalYearNotAllowed'));
    end;

    [Scope('Personalization')]
    procedure ClosingUnreleasedOrdersCode(): Code[50]
    begin
        exit(UpperCase('ClosingUnreleasedOrders'));
    end;

    [Scope('Personalization')]
    procedure MarkBookingAsInvoicedWarningCode(): Code[50]
    begin
        exit(UpperCase('MarkBookingAsInvoicedWarning'));
    end;

    [Scope('Personalization')]
    procedure AutomaticLineItemsDialogCode(): Code[50]
    begin
        exit(UpperCase('AutomaticallyCreateLineItemsFromOutlook'));
    end;

    [Scope('Personalization')]
    procedure GetClosingUnpostedDocumentNotificationId(): Guid
    begin
        exit('612A2701-4BBB-4C5B-B4C0-629D96B60644');
    end;

    [Scope('Personalization')]
    procedure GetDocumentTypeInvoiceFilter(): Text
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetRange("Document Type",SalesHeader."Document Type"::Invoice);
        exit(SalesHeader.GetView(false));
    end;

    [Scope('Personalization')]
    procedure GetOpeningPostedDocumentNotificationId(): Guid
    begin
        exit('0C6ED8F1-7408-4352-8DD1-B9F17332607D');
    end;

    [Scope('Personalization')]
    procedure GetMarkBookingAsInvoicedWarningNotificationId(): Guid
    begin
        exit('413A3221-D47F-4FBF-8822-0029AB41F9A6');
    end;

    [Scope('Personalization')]
    procedure GetOfficeUpdateNotificationId(): Guid
    begin
        exit('882980DE-C2F6-4D4F-BF39-BB3A9FE3D7DA');
    end;

    [Scope('Personalization')]
    procedure GetPostingAfterCurrentFiscalYeartNotificationId(): Guid
    begin
        exit('F76D6004-5EC5-4DEA-B14D-71B2AEB53ACF');
    end;

    [Scope('Personalization')]
    procedure GetClosingUnreleasedOrdersNotificationId(): Guid
    begin
        exit('F76D6004-3FD8-2ABC-B14D-61B2AEB53ACF');
    end;

    [Scope('Personalization')]
    procedure GetAutomaticLineItemsDialogNotificationId(): Guid
    begin
        exit('7FFD2619-BCEF-48F1-B5D1-469DCE5E6631');
    end;

    [Scope('Personalization')]
    procedure InsertDefaultUnpostedDoucumentNotification()
    var
        MyNotifications: Record "My Notifications";
    begin
        MyNotifications.InsertDefaultWithTableNumAndFilter(GetClosingUnpostedDocumentNotificationId,
          WarnUnpostedDocumentsTxt,
          WarnUnpostedDocumentsDescriptionTxt,
          DATABASE::"Sales Header",
          GetDocumentTypeInvoiceFilter);
    end;

    [EventSubscriber(ObjectType::Page, 1518, 'OnInitializingNotificationWithDefaultState', '', false, false)]
    local procedure OnInitializingNotificationWithDefaultState()
    var
        MyNotifications: Record "My Notifications";
    begin
        InsertDefaultUnpostedDoucumentNotification;
        MyNotifications.InsertDefault(GetOpeningPostedDocumentNotificationId,
          ConfirmAfterPostingDocumentsTxt,
          ConfirmAfterPostingDocumentsDescriptionTxt,
          IsEnabled(ShowPostedConfirmationMessageCode));
        MyNotifications.InsertDefault(GetPostingAfterCurrentFiscalYeartNotificationId,
          ConfirmPostingAfterCurrentFiscalYearTxt,
          ConfirmPostingAfterCurrentFiscalYearDescriptionTxt,
          IsEnabled(PostingAfterCurrentFiscalYearNotAllowedCode));
        MyNotifications.InsertDefault(GetMarkBookingAsInvoicedWarningNotificationId,
          MarkBookingAsInvoicedWarningTxt,
          MarkBookingAsInvoicedWarningDescriptionTxt,
          IsEnabled(MarkBookingAsInvoicedWarningCode));
        MyNotifications.InsertDefault(GetAutomaticLineItemsDialogNotificationId,
          AutomaticLineItemsDialogNotificationTxt,
          AutomaticLineItemsDialogNotificationDescriptionTxt,
          IsEnabled(AutomaticLineItemsDialogCode));
        MyNotifications.InsertDefault(GetOfficeUpdateNotificationId,
          OfficeUpdateNotificationTxt,
          OfficeUpdateNotificationDescriptionTxt,
          IsEnabled(OfficeUpdateNotificationCode));
        MyNotifications.InsertDefault(GetClosingUnreleasedOrdersNotificationId,
          ClosingUnreleasedOrdersNotificationTxt,
          ClosingUnreleasedOrdersNotificationDescriptionTxt,
          IsEnabled(ClosingUnreleasedOrdersCode));
    end;

    [EventSubscriber(ObjectType::Table, 1518, 'OnStateChanged', '', false, false)]
    local procedure OnStateChanged(NotificationId: Guid;NewEnabledState: Boolean)
    begin
        case NotificationId of
          GetClosingUnpostedDocumentNotificationId:
            if NewEnabledState then
              EnableMessageForCurrentUser(QueryPostOnCloseCode)
            else
              DisableMessageForCurrentUser(QueryPostOnCloseCode);
          GetOpeningPostedDocumentNotificationId:
            if NewEnabledState then
              EnableMessageForCurrentUser(ShowPostedConfirmationMessageCode)
            else
              DisableMessageForCurrentUser(ShowPostedConfirmationMessageCode);
          GetAutomaticLineItemsDialogNotificationId:
            if NewEnabledState then
              EnableMessageForCurrentUser(AutomaticLineItemsDialogCode)
            else
              DisableMessageForCurrentUser(AutomaticLineItemsDialogCode);
          GetPostingAfterCurrentFiscalYeartNotificationId:
            if NewEnabledState then
              EnableMessageForCurrentUser(PostingAfterCurrentFiscalYearNotAllowedCode)
            else
              DisableMessageForCurrentUser(PostingAfterCurrentFiscalYearNotAllowedCode);
          GetClosingUnreleasedOrdersNotificationId:
            if NewEnabledState then
              EnableMessageForCurrentUser(ClosingUnreleasedOrdersCode)
            else
              DisableMessageForCurrentUser(ClosingUnreleasedOrdersCode);
        end;
    end;
}

