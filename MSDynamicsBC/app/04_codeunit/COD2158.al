codeunit 2158 "O365 Document Send Mgt"
{
    // version NAVW113.00

    Permissions = TableData "O365 Document Sent History"=imd;

    trigger OnRun()
    begin
    end;

    var
        RoleCenterEmailErrorIDTxt: Label 'c3c760b9-6405-aaaa-b2a6-1affb70c38bf';
        DocumentPageEmailErrorIDTxt: Label '9c8d5ebc-8c62-45a7-bc77-e260691e6de0';
        ShowDocumentsActionLbl: Label 'Show documents';
        IgnoreTheseFailuresActionLbl: Label 'Ignore';
        EmailSetupActionLbl: Label 'Set up email';
        EditCustomerActionLbl: Label 'Edit customer';
        ResendForegroundActionLbl: Label 'Resend now';
        SomeDocumentsFailedMsg: Label 'Some documents could not be sent.';
        EmailFailedCheckSetupMsg: Label 'The last email about this document could not be sent. Check your email setup.';
        EmailFailedCheckCustomerMsg: Label 'The last email about this document could not be sent. Check the customer''s email address.';
        EmailFailedGenericMsg: Label 'The last email about this document could not be sent.';
        EmailFailedWithErrorCodeMsg: Label 'The last email about this document could not be sent due to this error: %1.', Comment='%1=the SMTP error code returned';
        InvoiceSuccesfullyResentMsg: Label 'The invoice was succesfully sent.';
        EstimateSuccesfullyResentMsg: Label 'The estimate was succesfully sent.';
        ClientTypeManagement: Codeunit ClientTypeManagement;
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        ResendDocumentFromUIMsg: Label 'To resend this document, use the action in the document page.';

    local procedure ShowSendFailedNotificationForDocument(DocumentType: Option;DocumentNo: Code[20];Posted: Boolean;DocumentRecordId: RecordID;ShowActions: Boolean)
    var
        O365DocumentSentHistory: Record "O365 Document Sent History";
        ErrorCode: Text;
    begin
        O365DocumentSentHistory.SetRange("Document Type",DocumentType);
        O365DocumentSentHistory.SetRange("Document No.",DocumentNo);
        O365DocumentSentHistory.SetRange(Posted,Posted);
        if O365DocumentSentHistory.FindLast then
          ErrorCode := GetEmailErrorCode(O365DocumentSentHistory.GetJobQueueErrorMessage)
        else
          ErrorCode := '';

        SendNotificationFromErrorCode(O365DocumentSentHistory."Source No.",ErrorCode,DocumentRecordId,ShowActions);
    end;

    procedure ShowSalesInvoiceHeaderFailedNotification(SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        DummyO365DocumentSentHistory: Record "O365 Document Sent History";
    begin
        SalesInvoiceHeader.CalcFields(Cancelled);
        if SalesInvoiceHeader.Cancelled then
          exit;

        SalesInvoiceHeader.CalcFields("Last Email Sent Time","Last Email Sent Status");
        if (SalesInvoiceHeader."Last Email Sent Time" <> 0DT) and
           (SalesInvoiceHeader."Last Email Sent Status" = SalesInvoiceHeader."Last Email Sent Status"::Error)
        then
          ShowSendFailedNotificationForDocument(
            DummyO365DocumentSentHistory."Document Type"::Invoice,SalesInvoiceHeader."No.",true,SalesInvoiceHeader.RecordId,true);
    end;

    procedure ShowSalesHeaderFailedNotification(SalesHeader: Record "Sales Header")
    begin
        SalesHeader.CalcFields("Last Email Sent Time","Last Email Sent Status");
        if (SalesHeader."Last Email Sent Time" <> 0DT) and
           (SalesHeader."Last Email Sent Status" = SalesHeader."Last Email Sent Status"::Error)
        then
          ShowSendFailedNotificationForDocument(SalesHeader."Document Type",SalesHeader."No.",false,
            SalesHeader.RecordId,SalesHeader."Document Type" = SalesHeader."Document Type"::Quote);
    end;

    local procedure GetEmailErrorCode(ErrorText: Text): Text
    var
        TextPosition: Integer;
    begin
        TextPosition := StrPos(ErrorText,'The server response was:');
        if TextPosition = 0 then
          exit('');
        ErrorText := CopyStr(ErrorText,
            TextPosition + StrLen('The server response was:')
            );
        ErrorText := DelChr(ErrorText,'<',' ');

        TextPosition := StrPos(ErrorText,' ');
        if TextPosition <> 0 then
          ErrorText := CopyStr(ErrorText,1,TextPosition - 1);

        exit(ErrorText);
    end;

    local procedure SendNotificationFromErrorCode(CustomerNo: Code[20];ErrorCode: Text;DocumentRecordId: RecordID;ShowActions: Boolean)
    var
        TargetNotification: Notification;
    begin
        TargetNotification.Id(DocumentPageEmailErrorIDTxt);
        TargetNotification.Scope(NOTIFICATIONSCOPE::LocalScope);
        TargetNotification.SetData('CustNo',Format(CustomerNo));
        TargetNotification.SetData('DocumentRecordId',Format(DocumentRecordId));
        TargetNotification.SetData('ErrCode',ErrorCode);

        case ErrorCode of
          '5.7.57':
            begin
              TargetNotification.Message(EmailFailedCheckSetupMsg);
              // Update tests in COD138958 when MethodName changed
              if ShowActions then
                TargetNotification.AddAction(
                  EmailSetupActionLbl,CODEUNIT::"O365 Document Send Mgt",'OpenSetupEmailFromNotification');
            end;
          '5.1.6':
            begin
              TargetNotification.Message(EmailFailedCheckCustomerMsg);
              // Update tests in COD138958 when MethodName changed
              if ShowActions then
                TargetNotification.AddAction(
                  EditCustomerActionLbl,CODEUNIT::"O365 Document Send Mgt",'OpenCustomerFromNotification');
            end;
          '':
            TargetNotification.Message(EmailFailedGenericMsg);
          else
            TargetNotification.Message(StrSubstNo(EmailFailedWithErrorCodeMsg,ErrorCode));
        end;

        // Update tests in COD138958 when MethodName changed
        if ShowActions then
          TargetNotification.AddAction(
            ResendForegroundActionLbl,CODEUNIT::"O365 Document Send Mgt",'ResendDocumentFromNotification');
        NotificationLifecycleMgt.SendNotification(TargetNotification,DocumentRecordId);
    end;

    procedure ResendDocumentFromNotification(EmailFailedNotification: Notification)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesHeader: Record "Sales Header";
        DocumentMailing: Codeunit "Document-Mailing";
        DocumentRecordId: RecordID;
    begin
        if not EmailFailedNotification.HasData('DocumentRecordId') then
          exit;

        if not Evaluate(DocumentRecordId,EmailFailedNotification.GetData('DocumentRecordId')) then
          exit;

        case DocumentRecordId.TableNo of
          DATABASE::"Sales Invoice Header":
            begin
              SalesInvoiceHeader.Get(DocumentRecordId);
              if DocumentMailing.SendPostedInvoiceInForeground(SalesInvoiceHeader) then
                Message(InvoiceSuccesfullyResentMsg);
            end;
          DATABASE::"Sales Header":
            begin
              SalesHeader.Get(DocumentRecordId);
              case SalesHeader."Document Type" of
                SalesHeader."Document Type"::Quote:
                  if DocumentMailing.SendQuoteInForeground(SalesHeader) then
                    Message(EstimateSuccesfullyResentMsg);
                else
                  Message(ResendDocumentFromUIMsg);
              end;
            end;
          else
            Message(ResendDocumentFromUIMsg);
        end;
    end;

    procedure OpenCustomerFromNotification(EmailFailedNotification: Notification)
    var
        Customer: Record Customer;
        CustomerNo: Code[20];
    begin
        if not EmailFailedNotification.HasData('CustNo') then
          exit;

        CustomerNo := EmailFailedNotification.GetData('CustNo');

        if Customer.Get(CustomerNo) then
          if ClientTypeManagement.IsPhoneClientType then
            PAGE.Run(PAGE::"O365 Sales Customer Card",Customer)
          else
            PAGE.Run(PAGE::"BC O365 Sales Customer Card",Customer)
    end;

    procedure OpenSetupEmailFromNotification(EmailFailedNotification: Notification)
    var
        O365SetupEmail: Codeunit "O365 Setup Email";
    begin
        O365SetupEmail.SetupEmail(true);
    end;

    procedure ShowRoleCenterEmailNotification(CountOnlyNotNotified: Boolean)
    var
        DummyO365SalesDocument: Record "O365 Sales Document";
        RoleCenterNotification: Notification;
        FailedNotNotifiedDocuments: Integer;
    begin
        FailedNotNotifiedDocuments := GetFailedNotNotifiedDocuments(CountOnlyNotNotified);

        if FailedNotNotifiedDocuments <> 0 then begin
          RoleCenterNotification.Id(RoleCenterEmailErrorIDTxt);
          RoleCenterNotification.Scope(NOTIFICATIONSCOPE::LocalScope);
          RoleCenterNotification.Message(SomeDocumentsFailedMsg);
          // Update tests in COD138958 when MethodName changed
          RoleCenterNotification.AddAction(
            ShowDocumentsActionLbl,CODEUNIT::"O365 Document Send Mgt",'ShowSendingFailedDocumentList');
          RoleCenterNotification.AddAction(
            IgnoreTheseFailuresActionLbl,CODEUNIT::"O365 Document Send Mgt",'ClearNotificationsForAllDocumentsAction');
          NotificationLifecycleMgt.SendNotification(RoleCenterNotification,DummyO365SalesDocument.RecordId);
          SetAllToNotified;
        end;
    end;

    procedure ShowSendingFailedDocumentList(RoleCenterSendingFailedNotification: Notification)
    var
        O365SalesDocument: Record "O365 Sales Document";
    begin
        O365SalesDocument.SetRange("Last Email Sent Status",O365SalesDocument."Last Email Sent Status"::Error);
        O365SalesDocument.SetRange("Last Email Notif Cleared",false);

        PAGE.Run(PAGE::"BC O365 Sent Documents List",O365SalesDocument);
    end;

    local procedure GetFailedNotNotifiedDocuments(CountOnlyNotNotified: Boolean) DocumentsFailedSending: Integer
    var
        O365DocumentSentHistory: Record "O365 Document Sent History";
    begin
        O365DocumentSentHistory.SetRange(NotificationCleared,false);
        if CountOnlyNotNotified then
          O365DocumentSentHistory.SetRange(Notified,false);

        O365DocumentSentHistory.SetRange("Job Last Status",O365DocumentSentHistory."Job Last Status"::Error);
        DocumentsFailedSending := O365DocumentSentHistory.Count;
    end;

    local procedure SetAllToNotified()
    var
        O365DocumentSentHistory: Record "O365 Document Sent History";
    begin
        O365DocumentSentHistory.SetRange(Notified,false);
        O365DocumentSentHistory.ModifyAll(Notified,true,true);
    end;

    procedure ClearNotificationsForDocument(DocNo: Code[20];Posted: Boolean;DocType: Option)
    var
        O365DocumentSentHistory: Record "O365 Document Sent History";
    begin
        O365DocumentSentHistory.SetRange(Posted,Posted);
        O365DocumentSentHistory.SetRange("Document No.",DocNo);
        O365DocumentSentHistory.SetRange("Document Type",DocType);

        if O365DocumentSentHistory.FindLast then begin
          O365DocumentSentHistory.NotificationCleared := true;
          O365DocumentSentHistory.Notified := true;
          O365DocumentSentHistory.Modify(true);
        end;
    end;

    procedure ClearNotificationsForAllDocuments()
    var
        O365DocumentSentHistory: Record "O365 Document Sent History";
    begin
        O365DocumentSentHistory.SetRange(NotificationCleared,false);
        O365DocumentSentHistory.ModifyAll(NotificationCleared,true,true);
    end;

    procedure ClearNotificationsForAllDocumentsAction(TheNotification: Notification)
    begin
        ClearNotificationsForAllDocuments;
    end;

    procedure RecallEmailFailedNotification()
    var
        LocalNotification: Notification;
    begin
        LocalNotification.Id(DocumentPageEmailErrorIDTxt);
        if LocalNotification.Recall then;
    end;
}

