codeunit 81 "Sales-Post (Yes/No)"
{
    // version NAVW113.00

    EventSubscriberInstance = Manual;
    TableNo = "Sales Header";

    trigger OnRun()
    var
        SalesHeader: Record "Sales Header";
    begin
        if not Find then
          Error(NothingToPostErr);

        SalesHeader.Copy(Rec);
        Code(SalesHeader,false);
        Rec := SalesHeader;
    end;

    var
        ShipInvoiceQst: Label '&Ship,&Invoice,Ship &and Invoice';
        PostConfirmQst: Label 'Do you want to post the %1?', Comment='%1 = Document Type';
        ReceiveInvoiceQst: Label '&Receive,&Invoice,Receive &and Invoice';
        NothingToPostErr: Label 'There is nothing to post.';

    procedure PostAndSend(var SalesHeader: Record "Sales Header")
    var
        SalesHeaderToPost: Record "Sales Header";
    begin
        SalesHeaderToPost.Copy(SalesHeader);
        Code(SalesHeaderToPost,true);
        SalesHeader := SalesHeaderToPost;
    end;

    local procedure "Code"(var SalesHeader: Record "Sales Header";PostAndSend: Boolean)
    var
        SalesSetup: Record "Sales & Receivables Setup";
        SalesPostViaJobQueue: Codeunit "Sales Post via Job Queue";
        HideDialog: Boolean;
        IsHandled: Boolean;
    begin
        HideDialog := false;
        IsHandled := false;
        OnBeforeConfirmSalesPost(SalesHeader,HideDialog,IsHandled);
        if IsHandled then
          exit;

        if not HideDialog then
          if not ConfirmPost(SalesHeader) then
            exit;

        OnAfterConfirmPost(SalesHeader);

        SalesSetup.Get;
        if SalesSetup."Post with Job Queue" and not PostAndSend then
          SalesPostViaJobQueue.EnqueueSalesDoc(SalesHeader)
        else
          CODEUNIT.Run(CODEUNIT::"Sales-Post",SalesHeader);

        OnAfterPost(SalesHeader);
    end;

    local procedure ConfirmPost(var SalesHeader: Record "Sales Header"): Boolean
    var
        Selection: Integer;
    begin
        with SalesHeader do begin
          case "Document Type" of
            "Document Type"::Order:
              begin
                Selection := StrMenu(ShipInvoiceQst,3);
                Ship := Selection in [1,3];
                Invoice := Selection in [2,3];
                if Selection = 0 then
                  exit(false);
              end;
            "Document Type"::"Return Order":
              begin
                Selection := StrMenu(ReceiveInvoiceQst,3);
                if Selection = 0 then
                  exit(false);
                Receive := Selection in [1,3];
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

    procedure Preview(var SalesHeader: Record "Sales Header")
    var
        SalesPostYesNo: Codeunit "Sales-Post (Yes/No)";
        GenJnlPostPreview: Codeunit "Gen. Jnl.-Post Preview";
    begin
        BindSubscription(SalesPostYesNo);
        GenJnlPostPreview.Preview(SalesPostYesNo,SalesHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPost(var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterConfirmPost(SalesHeader: Record "Sales Header")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 19, 'OnRunPreview', '', false, false)]
    local procedure OnRunPreview(var Result: Boolean;Subscriber: Variant;RecVar: Variant)
    var
        SalesHeader: Record "Sales Header";
        SalesPost: Codeunit "Sales-Post";
    begin
        with SalesHeader do begin
          Copy(RecVar);
          Receive := "Document Type" = "Document Type"::"Return Order";
          Ship := "Document Type" = "Document Type"::Order;
          Invoice := true;
        end;
        SalesPost.SetPreviewMode(true);
        Result := SalesPost.Run(SalesHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeConfirmSalesPost(var SalesHeader: Record "Sales Header";var HideDialog: Boolean;var IsHandled: Boolean)
    begin
    end;
}

