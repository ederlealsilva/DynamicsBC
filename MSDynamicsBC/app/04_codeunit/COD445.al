codeunit 445 "Purch.-Post Prepmt.  (Yes/No)"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Do you want to post the prepayments for %1 %2?';
        Text001: Label 'Do you want to post a credit memo for the prepayments for %1 %2?';
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";

    [Scope('Personalization')]
    procedure PostPrepmtInvoiceYN(var PurchHeader2: Record "Purchase Header";Print: Boolean)
    var
        PurchHeader: Record "Purchase Header";
        PurchPostPrepmt: Codeunit "Purchase-Post Prepayments";
    begin
        PurchHeader.Copy(PurchHeader2);
        with PurchHeader do begin
          if not Confirm(Text000,false,"Document Type","No.") then
            exit;

          PurchPostPrepmt.Invoice(PurchHeader);

          if Print then
            GetReport(PurchHeader,0);

          Commit;
          PurchHeader2 := PurchHeader;
        end;
    end;

    [Scope('Personalization')]
    procedure PostPrepmtCrMemoYN(var PurchHeader2: Record "Purchase Header";Print: Boolean)
    var
        PurchHeader: Record "Purchase Header";
        PurchPostPrepmt: Codeunit "Purchase-Post Prepayments";
    begin
        PurchHeader.Copy(PurchHeader2);
        with PurchHeader do begin
          if not Confirm(Text001,false,"Document Type","No.") then
            exit;

          PurchPostPrepmt.CreditMemo(PurchHeader);

          if Print then
            GetReport(PurchHeader,1);

          Commit;
          PurchHeader2 := PurchHeader;
        end;
    end;

    local procedure GetReport(var PurchHeader: Record "Purchase Header";DocumentType: Option Invoice,"Credit Memo")
    begin
        with PurchHeader do
          case DocumentType of
            DocumentType::Invoice:
              begin
                PurchInvHeader."No." := "Last Prepayment No.";
                PurchInvHeader.SetRecFilter;
                PurchInvHeader.PrintRecords(false);
              end;
            DocumentType::"Credit Memo":
              begin
                PurchCrMemoHeader."No." := "Last Prepmt. Cr. Memo No.";
                PurchCrMemoHeader.SetRecFilter;
                PurchCrMemoHeader.PrintRecords(false);
              end;
          end;
    end;
}

