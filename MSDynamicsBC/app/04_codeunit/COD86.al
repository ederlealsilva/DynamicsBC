codeunit 86 "Sales-Quote to Order"
{
    // version NAVW113.00

    TableNo = "Sales Header";

    trigger OnRun()
    var
        Cust: Record Customer;
        SalesCommentLine: Record "Sales Comment Line";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        ArchiveManagement: Codeunit ArchiveManagement;
        SalesCalcDiscountByType: Codeunit "Sales - Calc Discount By Type";
        RecordLinkManagement: Codeunit "Record Link Management";
        ShouldRedistributeInvoiceAmount: Boolean;
    begin
        OnBeforeOnRun(Rec);

        TestField("Document Type","Document Type"::Quote);
        ShouldRedistributeInvoiceAmount := SalesCalcDiscountByType.ShouldRedistributeInvoiceDiscountAmount(Rec);

        OnCheckSalesPostRestrictions;

        Cust.Get("Sell-to Customer No.");
        Cust.CheckBlockedCustOnDocs(Cust,"Document Type"::Order,true,false);
        if "Sell-to Customer No." <> "Bill-to Customer No." then begin
          Cust.Get("Bill-to Customer No.");
          Cust.CheckBlockedCustOnDocs(Cust,"Document Type"::Order,true,false);
        end;
        CalcFields("Amount Including VAT","Work Description");

        ValidateSalesPersonOnSalesHeader(Rec,true,false);

        CheckInProgressOpportunities(Rec);

        CreateSalesHeader(Rec,Cust."Prepayment %");

        TransferQuoteToSalesOrderLines(SalesQuoteLine,Rec,SalesOrderLine,SalesOrderHeader,Cust);
        OnAfterInsertAllSalesOrderLines(SalesOrderLine,Rec);

        SalesSetup.Get;
        case SalesSetup."Archive Quotes" of
          SalesSetup."Archive Quotes"::Always:
            ArchiveManagement.ArchSalesDocumentNoConfirm(Rec);
          SalesSetup."Archive Quotes"::Question:
            ArchiveManagement.ArchiveSalesDocument(Rec);
        end;

        if SalesSetup."Default Posting Date" = SalesSetup."Default Posting Date"::"No Date" then begin
          SalesOrderHeader."Posting Date" := 0D;
          SalesOrderHeader.Modify;
        end;

        SalesCommentLine.CopyComments("Document Type",SalesOrderHeader."Document Type","No.",SalesOrderHeader."No.");
        RecordLinkManagement.CopyLinks(Rec,SalesOrderHeader);

        AssignItemCharges("Document Type","No.",SalesOrderHeader."Document Type",SalesOrderHeader."No.");

        MoveWonLostOpportunites(Rec,SalesOrderHeader);

        ApprovalsMgmt.CopyApprovalEntryQuoteToOrder(RecordId,SalesOrderHeader."No.",SalesOrderHeader.RecordId);
        ApprovalsMgmt.DeleteApprovalEntries(RecordId);

        OnBeforeDeleteSalesQuote(Rec,SalesOrderHeader);

        DeleteLinks;
        Delete;

        SalesQuoteLine.DeleteAll;

        if not ShouldRedistributeInvoiceAmount then
          SalesCalcDiscountByType.ResetRecalculateInvoiceDisc(SalesOrderHeader);

        OnAfterOnRun(Rec,SalesOrderHeader);
    end;

    var
        Text000: Label 'An open %1 is linked to this %2. The %1 has to be closed before the %2 can be converted to an %3. Do you want to close the %1 now and continue the conversion?', Comment='An open Opportunity is linked to this Quote. The Opportunity has to be closed before the Quote can be converted to an Order. Do you want to close the Opportunity now and continue the conversion?';
        Text001: Label 'An open %1 is still linked to this %2. The conversion to an %3 was aborted.', Comment='An open Opportunity is still linked to this Quote. The conversion to an Order was aborted.';
        SalesQuoteLine: Record "Sales Line";
        SalesOrderHeader: Record "Sales Header";
        SalesOrderLine: Record "Sales Line";
        SalesSetup: Record "Sales & Receivables Setup";

    local procedure CreateSalesHeader(SalesHeader: Record "Sales Header";PrepmtPercent: Decimal)
    begin
        with SalesHeader do begin
          SalesOrderHeader := SalesHeader;
          SalesOrderHeader."Document Type" := SalesOrderHeader."Document Type"::Order;

          SalesOrderHeader."No. Printed" := 0;
          SalesOrderHeader.Status := SalesOrderHeader.Status::Open;
          SalesOrderHeader."No." := '';
          SalesOrderHeader."Quote No." := "No.";
          SalesOrderLine.LockTable;
          SalesOrderHeader.Insert(true);

          SalesOrderHeader."Order Date" := "Order Date";
          if "Posting Date" <> 0D then
            SalesOrderHeader."Posting Date" := "Posting Date";

          SalesOrderHeader.InitFromSalesHeader(SalesHeader);
          SalesOrderHeader."Outbound Whse. Handling Time" := "Outbound Whse. Handling Time";
          SalesOrderHeader.Reserve := Reserve;

          SalesOrderHeader."Prepayment %" := PrepmtPercent;
          if SalesOrderHeader."Posting Date" = 0D then
            SalesOrderHeader."Posting Date" := WorkDate;
          OnBeforeInsertSalesOrderHeader(SalesOrderHeader,SalesHeader);
          SalesOrderHeader.Modify;
        end;
    end;

    local procedure AssignItemCharges(FromDocType: Option;FromDocNo: Code[20];ToDocType: Option;ToDocNo: Code[20])
    var
        ItemChargeAssgntSales: Record "Item Charge Assignment (Sales)";
    begin
        ItemChargeAssgntSales.Reset;
        ItemChargeAssgntSales.SetRange("Document Type",FromDocType);
        ItemChargeAssgntSales.SetRange("Document No.",FromDocNo);
        while ItemChargeAssgntSales.FindFirst do begin
          ItemChargeAssgntSales.Delete;
          ItemChargeAssgntSales."Document Type" := SalesOrderHeader."Document Type";
          ItemChargeAssgntSales."Document No." := SalesOrderHeader."No.";
          if not (ItemChargeAssgntSales."Applies-to Doc. Type" in
                  [ItemChargeAssgntSales."Applies-to Doc. Type"::Shipment,
                   ItemChargeAssgntSales."Applies-to Doc. Type"::"Return Receipt"])
          then begin
            ItemChargeAssgntSales."Applies-to Doc. Type" := ToDocType;
            ItemChargeAssgntSales."Applies-to Doc. No." := ToDocNo;
          end;
          ItemChargeAssgntSales.Insert;
        end;
    end;

    [Scope('Personalization')]
    procedure GetSalesOrderHeader(var SalesHeader2: Record "Sales Header")
    begin
        SalesHeader2 := SalesOrderHeader;
    end;

    [Scope('Personalization')]
    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        if NewHideValidationDialog then
          exit;
    end;

    local procedure CheckInProgressOpportunities(var SalesHeader: Record "Sales Header")
    var
        Opp: Record Opportunity;
        TempOpportunityEntry: Record "Opportunity Entry" temporary;
    begin
        Opp.Reset;
        Opp.SetCurrentKey("Sales Document Type","Sales Document No.");
        Opp.SetRange("Sales Document Type",Opp."Sales Document Type"::Quote);
        Opp.SetRange("Sales Document No.",SalesHeader."No.");
        Opp.SetRange(Status,Opp.Status::"In Progress");
        if Opp.FindFirst then begin
          if not Confirm(Text000,true,Opp.TableCaption,Opp."Sales Document Type"::Quote,Opp."Sales Document Type"::Order) then
            Error('');
          TempOpportunityEntry.DeleteAll;
          TempOpportunityEntry.Init;
          TempOpportunityEntry.Validate("Opportunity No.",Opp."No.");
          TempOpportunityEntry."Sales Cycle Code" := Opp."Sales Cycle Code";
          TempOpportunityEntry."Contact No." := Opp."Contact No.";
          TempOpportunityEntry."Contact Company No." := Opp."Contact Company No.";
          TempOpportunityEntry."Salesperson Code" := Opp."Salesperson Code";
          TempOpportunityEntry."Campaign No." := Opp."Campaign No.";
          TempOpportunityEntry."Action Taken" := TempOpportunityEntry."Action Taken"::Won;
          TempOpportunityEntry."Calcd. Current Value (LCY)" := TempOpportunityEntry.GetSalesDocValue(SalesHeader);
          TempOpportunityEntry."Cancel Old To Do" := true;
          TempOpportunityEntry."Wizard Step" := 1;
          TempOpportunityEntry.Insert;
          TempOpportunityEntry.SetRange("Action Taken",TempOpportunityEntry."Action Taken"::Won);
          PAGE.RunModal(PAGE::"Close Opportunity",TempOpportunityEntry);
          Opp.Reset;
          Opp.SetCurrentKey("Sales Document Type","Sales Document No.");
          Opp.SetRange("Sales Document Type",Opp."Sales Document Type"::Quote);
          Opp.SetRange("Sales Document No.",SalesHeader."No.");
          Opp.SetRange(Status,Opp.Status::"In Progress");
          if Opp.FindFirst then
            Error(Text001,Opp.TableCaption,Opp."Sales Document Type"::Quote,Opp."Sales Document Type"::Order);
          Commit;
          SalesHeader.Get(SalesHeader."Document Type",SalesHeader."No.");
        end;
    end;

    local procedure MoveWonLostOpportunites(var SalesQuoteHeader: Record "Sales Header";var SalesOrderHeader: Record "Sales Header")
    var
        Opp: Record Opportunity;
        OpportunityEntry: Record "Opportunity Entry";
    begin
        Opp.Reset;
        Opp.SetCurrentKey("Sales Document Type","Sales Document No.");
        Opp.SetRange("Sales Document Type",Opp."Sales Document Type"::Quote);
        Opp.SetRange("Sales Document No.",SalesQuoteHeader."No.");
        if Opp.FindFirst then
          if Opp.Status = Opp.Status::Won then begin
            Opp."Sales Document Type" := Opp."Sales Document Type"::Order;
            Opp."Sales Document No." := SalesOrderHeader."No.";
            Opp.Modify;
            OpportunityEntry.Reset;
            OpportunityEntry.SetCurrentKey(Active,"Opportunity No.");
            OpportunityEntry.SetRange(Active,true);
            OpportunityEntry.SetRange("Opportunity No.",Opp."No.");
            if OpportunityEntry.FindFirst then begin
              OpportunityEntry."Calcd. Current Value (LCY)" := OpportunityEntry.GetSalesDocValue(SalesOrderHeader);
              OpportunityEntry.Modify;
            end;
          end else
            if Opp.Status = Opp.Status::Lost then begin
              Opp."Sales Document Type" := Opp."Sales Document Type"::" ";
              Opp."Sales Document No." := '';
              Opp.Modify;
            end;
    end;

    local procedure TransferQuoteToSalesOrderLines(var QuoteSalesLine: Record "Sales Line";var QuoteSalesHeader: Record "Sales Header";var OrderSalesLine: Record "Sales Line";var OrderSalesHeader: Record "Sales Header";Customer: Record Customer)
    var
        ATOLink: Record "Assemble-to-Order Link";
        Resource: Record Resource;
        PrepmtMgt: Codeunit "Prepayment Mgt.";
        SalesLineReserve: Codeunit "Sales Line-Reserve";
    begin
        QuoteSalesLine.Reset;
        QuoteSalesLine.SetRange("Document Type",QuoteSalesHeader."Document Type");
        QuoteSalesLine.SetRange("Document No.",QuoteSalesHeader."No.");
        if QuoteSalesLine.FindSet then
          repeat
            if QuoteSalesLine.Type = QuoteSalesLine.Type::Resource then
              if QuoteSalesLine."No." <> '' then
                if Resource.Get(QuoteSalesLine."No.") then begin
                  Resource.CheckResourcePrivacyBlocked(false);
                  Resource.TestField(Blocked,false);
                end;
            OrderSalesLine := QuoteSalesLine;
            OrderSalesLine."Document Type" := OrderSalesHeader."Document Type";
            OrderSalesLine."Document No." := OrderSalesHeader."No.";
            OrderSalesLine."Shortcut Dimension 1 Code" := QuoteSalesLine."Shortcut Dimension 1 Code";
            OrderSalesLine."Shortcut Dimension 2 Code" := QuoteSalesLine."Shortcut Dimension 2 Code";
            OrderSalesLine."Dimension Set ID" := QuoteSalesLine."Dimension Set ID";
            if Customer."Prepayment %" <> 0 then
              OrderSalesLine."Prepayment %" := Customer."Prepayment %";
            PrepmtMgt.SetSalesPrepaymentPct(OrderSalesLine,OrderSalesHeader."Posting Date");
            OrderSalesLine.Validate("Prepayment %");
            if OrderSalesLine."No." <> '' then
              OrderSalesLine.DefaultDeferralCode;
            OnBeforeInsertSalesOrderLine(OrderSalesLine,OrderSalesHeader,QuoteSalesLine,QuoteSalesHeader);
            OrderSalesLine.Insert;
            OnAfterInsertSalesOrderLine(OrderSalesLine,OrderSalesHeader,QuoteSalesLine,QuoteSalesHeader);
            ATOLink.MakeAsmOrderLinkedToSalesOrderLine(QuoteSalesLine,OrderSalesLine);
            SalesLineReserve.TransferSaleLineToSalesLine(
              QuoteSalesLine,OrderSalesLine,QuoteSalesLine."Outstanding Qty. (Base)");
            SalesLineReserve.VerifyQuantity(OrderSalesLine,QuoteSalesLine);

            if OrderSalesLine.Reserve = OrderSalesLine.Reserve::Always then
              OrderSalesLine.AutoReserve;

          until QuoteSalesLine.Next = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeleteSalesQuote(var QuoteSalesHeader: Record "Sales Header";var OrderSalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertSalesOrderHeader(var SalesOrderHeader: Record "Sales Header";SalesQuoteHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertSalesOrderLine(var SalesOrderLine: Record "Sales Line";SalesOrderHeader: Record "Sales Header";SalesQuoteLine: Record "Sales Line";SalesQuoteHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertAllSalesOrderLines(var SalesOrderLine: Record "Sales Line";SalesQuoteHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterOnRun(var SalesHeader: Record "Sales Header";var SalesOrderHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertSalesOrderLine(var SalesOrderLine: Record "Sales Line";SalesOrderHeader: Record "Sales Header";SalesQuoteLine: Record "Sales Line";SalesQuoteHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnRun(var SalesHeader: Record "Sales Header")
    begin
    end;
}

