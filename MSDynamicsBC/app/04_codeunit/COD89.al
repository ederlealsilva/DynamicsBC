codeunit 89 "Sales-Post + Email"
{
    // version NAVW113.00

    TableNo = "Sales Header";

    trigger OnRun()
    begin
        SalesHeader.Copy(Rec);
        Code;
        Rec := SalesHeader;
    end;

    var
        PostAndSendInvoiceQst: Label 'Do you want to post and send the %1?';
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        FileManagement: Codeunit "File Management";
        IdentityManagement: Codeunit "Identity Management";
        HideMailDialog: Boolean;
        PostAndSaveInvoiceQst: Label 'Do you want to post and save the %1?';
        NotSupportedDocumentTypeSendingErr: Label 'The %1 is not posted because sending document of type %1 is not supported.';
        NotSupportedDocumentTypeSavingErr: Label 'The %1 is not posted because saving document of type %1 is not supported.';

    local procedure "Code"()
    var
        HideDialog: Boolean;
        IsHandled: Boolean;
    begin
        HideDialog := false;
        IsHandled := false;
        OnBeforePostAndEMail(SalesHeader,HideDialog,IsHandled);
        if IsHandled then
          exit;

        if not HideDialog then
          with SalesHeader do
            case "Document Type" of
              "Document Type"::Invoice,
              "Document Type"::"Credit Memo":
                if not ConfirmPostAndDistribute(SalesHeader) then
                  exit;
              else
                ErrorPostAndDistribute(SalesHeader);
            end;

        OnAfterConfirmPost(SalesHeader);

        CODEUNIT.Run(CODEUNIT::"Sales-Post",SalesHeader);
        Commit;
        SendDocumentReport(SalesHeader);
    end;

    local procedure SendDocumentReport(var SalesHeader: Record "Sales Header")
    var
        ShowDialog: Boolean;
    begin
        with SalesHeader do
          case "Document Type" of
            "Document Type"::Invoice:
              begin
                if "Last Posting No." = '' then
                  SalesInvHeader."No." := "No."
                else
                  SalesInvHeader."No." := "Last Posting No.";
                SalesInvHeader.Find;
                SalesInvHeader.SetRecFilter;
                ShowDialog := (not IdentityManagement.IsInvAppId) and not HideMailDialog;
                SalesInvHeader.EmailRecords(ShowDialog);
              end;
            "Document Type"::"Credit Memo":
              begin
                if "Last Posting No." = '' then
                  SalesCrMemoHeader."No." := "No."
                else
                  SalesCrMemoHeader."No." := "Last Posting No.";
                SalesCrMemoHeader.Find;
                SalesCrMemoHeader.SetRecFilter;
                SalesCrMemoHeader.EmailRecords(not HideMailDialog);
              end
          end
    end;

    [Scope('Personalization')]
    procedure InitializeFrom(NewHideMailDialog: Boolean)
    begin
        HideMailDialog := NewHideMailDialog;
    end;

    local procedure ConfirmPostAndDistribute(var SalesHeader: Record "Sales Header"): Boolean
    var
        PostAndDistributeQuestion: Text;
        ConfirmOK: Boolean;
    begin
        if IdentityManagement.IsInvAppId then
          exit(true);

        if FileManagement.IsWebClient then
          PostAndDistributeQuestion := PostAndSaveInvoiceQst
        else
          PostAndDistributeQuestion := PostAndSendInvoiceQst;

        ConfirmOK := Confirm(PostAndDistributeQuestion,false,SalesHeader."Document Type");

        exit(ConfirmOK);
    end;

    local procedure ErrorPostAndDistribute(var SalesHeader: Record "Sales Header")
    var
        NotSupportedDocumentType: Text;
    begin
        if FileManagement.IsWebClient then
          NotSupportedDocumentType := NotSupportedDocumentTypeSavingErr
        else
          NotSupportedDocumentType := NotSupportedDocumentTypeSendingErr;

        Error(NotSupportedDocumentType,SalesHeader."Document Type");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterConfirmPost(SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostAndEMail(var SalesHeader: Record "Sales Header";var HideDialog: Boolean;var IsHandled: Boolean)
    begin
    end;
}

