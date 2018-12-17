codeunit 91 "Purch.-Post (Yes/No)"
{
    // version NAVW113.00

    EventSubscriberInstance = Manual;
    TableNo = "Purchase Header";

    trigger OnRun()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        if not Find then
          Error(NothingToPostErr);

        PurchaseHeader.Copy(Rec);
        Code(PurchaseHeader);
        Rec := PurchaseHeader;
    end;

    var
        ReceiveInvoiceQst: Label '&Receive,&Invoice,Receive &and Invoice';
        PostConfirmQst: Label 'Do you want to post the %1?', Comment='%1 = Document Type';
        ShipInvoiceQst: Label '&Ship,&Invoice,Ship &and Invoice';
        NothingToPostErr: Label 'There is nothing to post.';

    local procedure "Code"(var PurchaseHeader: Record "Purchase Header")
    var
        PurchSetup: Record "Purchases & Payables Setup";
        PurchPostViaJobQueue: Codeunit "Purchase Post via Job Queue";
        HideDialog: Boolean;
        IsHandled: Boolean;
    begin
        HideDialog := false;
        IsHandled := false;
        OnBeforeConfirmPost(PurchaseHeader,HideDialog,IsHandled);
        if  IsHandled then
          exit;

        if not HideDialog then
          if not ConfirmPost(PurchaseHeader) then
            exit;

        OnAfterConfirmPost(PurchaseHeader);

        PurchSetup.Get;
        if PurchSetup."Post with Job Queue" then
          PurchPostViaJobQueue.EnqueuePurchDoc(PurchaseHeader)
        else
          CODEUNIT.Run(CODEUNIT::"Purch.-Post",PurchaseHeader);

        OnAfterPost(PurchaseHeader);
    end;

    local procedure ConfirmPost(var PurchaseHeader: Record "Purchase Header"): Boolean
    var
        Selection: Integer;
    begin
        with PurchaseHeader do begin
          case "Document Type" of
            "Document Type"::Order:
              begin
                Selection := StrMenu(ReceiveInvoiceQst,3);
                if Selection = 0 then
                  exit(false);
                Receive := Selection in [1,3];
                Invoice := Selection in [2,3];
              end;
            "Document Type"::"Return Order":
              begin
                Selection := StrMenu(ShipInvoiceQst,3);
                if Selection = 0 then
                  exit(false);
                Ship := Selection in [1,3];
                Invoice := Selection in [2,3];
              end
            else
              if not Confirm(PostConfirmQst,false,LowerCase(Format("Document Type"))) then
                exit(false);
          end;
          "Print Posted Documents" := false;
        end;
        exit(true);
    end;

    [Scope('Personalization')]
    procedure Preview(var PurchaseHeader: Record "Purchase Header")
    var
        GenJnlPostPreview: Codeunit "Gen. Jnl.-Post Preview";
        PurchPostYesNo: Codeunit "Purch.-Post (Yes/No)";
    begin
        BindSubscription(PurchPostYesNo);
        GenJnlPostPreview.Preview(PurchPostYesNo,PurchaseHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPost(var PurchaseHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterConfirmPost(PurchaseHeader: Record "Purchase Header")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 19, 'OnRunPreview', '', false, false)]
    local procedure OnRunPreview(var Result: Boolean;Subscriber: Variant;RecVar: Variant)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchPost: Codeunit "Purch.-Post";
    begin
        with PurchaseHeader do begin
          Copy(RecVar);
          Ship := "Document Type" = "Document Type"::"Return Order";
          Receive := "Document Type" = "Document Type"::Order;
          Invoice := true;
        end;
        PurchPost.SetPreviewMode(true);
        Result := PurchPost.Run(PurchaseHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeConfirmPost(var PurchaseHeader: Record "Purchase Header";var HideDialog: Boolean;var IsHandled: Boolean)
    begin
    end;
}

