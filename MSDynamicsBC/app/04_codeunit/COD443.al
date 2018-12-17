codeunit 443 "Sales-Post Prepayment (Yes/No)"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Do you want to post the prepayments for %1 %2?';
        Text001: Label 'Do you want to post a credit memo for the prepayments for %1 %2?';
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";

    procedure PostPrepmtInvoiceYN(var SalesHeader2: Record "Sales Header";Print: Boolean)
    var
        SalesHeader: Record "Sales Header";
        SalesPostPrepayments: Codeunit "Sales-Post Prepayments";
    begin
        SalesHeader.Copy(SalesHeader2);
        with SalesHeader do begin
          if not Confirm(Text000,false,"Document Type","No.") then
            exit;

          SalesPostPrepayments.Invoice(SalesHeader);

          if Print then
            GetReport(SalesHeader,0);

          Commit;
          SalesHeader2 := SalesHeader;
        end;
    end;

    procedure PostPrepmtCrMemoYN(var SalesHeader2: Record "Sales Header";Print: Boolean)
    var
        SalesHeader: Record "Sales Header";
        SalesPostPrepayments: Codeunit "Sales-Post Prepayments";
    begin
        SalesHeader.Copy(SalesHeader2);
        with SalesHeader do begin
          if not Confirm(Text001,false,"Document Type","No.") then
            exit;

          SalesPostPrepayments.CreditMemo(SalesHeader);

          if Print then
            GetReport(SalesHeader,1);

          Commit;
          SalesHeader2 := SalesHeader;
        end;
    end;

    local procedure GetReport(var SalesHeader: Record "Sales Header";DocumentType: Option Invoice,"Credit Memo")
    begin
        with SalesHeader do
          case DocumentType of
            DocumentType::Invoice:
              begin
                SalesInvHeader."No." := "Last Prepayment No.";
                SalesInvHeader.SetRecFilter;
                SalesInvHeader.PrintRecords(false);
              end;
            DocumentType::"Credit Memo":
              begin
                SalesCrMemoHeader."No." := "Last Prepmt. Cr. Memo No.";
                SalesCrMemoHeader.SetRecFilter;
                SalesCrMemoHeader.PrintRecords(false);
              end;
          end;
    end;
}

