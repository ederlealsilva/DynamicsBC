codeunit 5923 "Service-Quote to Order"
{
    // version NAVW113.00

    Permissions = TableData "Loaner Entry"=m,
                  TableData "Service Order Allocation"=rimd;
    TableNo = "Service Header";

    trigger OnRun()
    var
        ServQuoteLine: Record "Service Line";
        Customer: Record Customer;
        CustCheckCreditLimit: Codeunit "Cust-Check Cr. Limit";
        ItemCheckAvail: Codeunit "Item-Check Avail.";
        DocType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
    begin
        OnBeforeRun(Rec);

        NewServHeader := Rec;

        ServMgtSetup.Get;

        NewServHeader."Document Type" := "Document Type"::Order;
        Customer.Get("Customer No.");
        Customer.CheckBlockedCustOnDocs(Customer,DocType::Quote,false,false);
        if "Customer No." <> "Bill-to Customer No." then begin
          Customer.Get("Bill-to Customer No.");
          Customer.CheckBlockedCustOnDocs(Customer,DocType::Quote,false,false);
        end;

        ValidateSalesPersonOnServiceHeader(Rec,true,false);

        CustCheckCreditLimit.ServiceHeaderCheck(NewServHeader);

        ServQuoteLine.SetRange("Document Type","Document Type");
        ServQuoteLine.SetRange("Document No.","No.");
        ServQuoteLine.SetRange(Type,ServQuoteLine.Type::Item);
        ServQuoteLine.SetFilter("No.",'<>%1','');
        if ServQuoteLine.Find('-') then
          repeat
            ServLine := ServQuoteLine;
            ServLine.Validate("Reserved Qty. (Base)",0);
            ServLine."Line No." := 0;
            if GuiAllowed then
              if ItemCheckAvail.ServiceInvLineCheck(ServLine) then
                ItemCheckAvail.RaiseUpdateInterruptedError;
          until ServQuoteLine.Next = 0;

        MakeOrder(Rec);

        Delete(true);
    end;

    var
        ServMgtSetup: Record "Service Mgt. Setup";
        RepairStatus: Record "Repair Status";
        ServItemLine: Record "Service Item Line";
        ServItemLine2: Record "Service Item Line";
        ServLine: Record "Service Line";
        ServLine2: Record "Service Line";
        ServOrderAlloc: Record "Service Order Allocation";
        NewServHeader: Record "Service Header";
        LoanerEntry: Record "Loaner Entry";
        ServCommentLine: Record "Service Comment Line";
        ServCommentLine2: Record "Service Comment Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        ServLogMgt: Codeunit ServLogManagement;
        ReserveServiceLine: Codeunit "Service Line-Reserve";

    local procedure TestNoSeries()
    begin
        ServMgtSetup.TestField("Service Order Nos.");
    end;

    local procedure GetNoSeriesCode(): Code[20]
    begin
        exit(ServMgtSetup."Service Order Nos.");
    end;

    [Scope('Personalization')]
    procedure ReturnOrderNo(): Code[20]
    begin
        exit(NewServHeader."No.");
    end;

    local procedure InsertServHeader(var ServiceHeaderOrder: Record "Service Header";ServiceHeaderQuote: Record "Service Header")
    begin
        ServiceHeaderOrder.Insert(true);
        ServiceHeaderOrder."Document Date" := ServiceHeaderQuote."Document Date";
        ServiceHeaderOrder."Location Code" := ServiceHeaderQuote."Location Code";
        ServiceHeaderOrder.Modify;

        OnAfterInsertServHeader(ServiceHeaderOrder,ServiceHeaderQuote);
    end;

    local procedure MakeOrder(ServiceHeader: Record "Service Header")
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        RecordLinkManagement: Codeunit "Record Link Management";
    begin
        with NewServHeader do begin
          "No." := '';
          "No. Printed" := 0;
          Validate(Status,Status::Pending);
          "Order Date" := WorkDate;
          "Order Time" := Time;
          "Actual Response Time (Hours)" := 0;
          "Service Time (Hours)" := 0;
          "Starting Date" := 0D;
          "Starting Time" := 0T;
          "Finishing Date" := 0D;
          "Finishing Time" := 0T;

          TestNoSeries;
          NoSeriesMgt.InitSeries(GetNoSeriesCode,'',0D,"No.","No. Series");

          "Quote No." := ServiceHeader."No.";
          RecordLinkManagement.CopyLinks(ServiceHeader,NewServHeader);
          InsertServHeader(NewServHeader,ServiceHeader);

          ServCommentLine.Reset;
          ServCommentLine.SetRange("Table Name",ServCommentLine."Table Name"::"Service Header");
          ServCommentLine.SetRange("Table Subtype",ServiceHeader."Document Type");
          ServCommentLine.SetRange("No.",ServiceHeader."No.");
          ServCommentLine.SetRange("Table Line No.",0);
          if ServCommentLine.Find('-') then
            repeat
              ServCommentLine2 := ServCommentLine;
              ServCommentLine2."Table Subtype" := "Document Type";
              ServCommentLine2."No." := "No.";
              ServCommentLine2.Insert;
            until ServCommentLine.Next = 0;

          ServOrderAlloc.Reset;
          ServOrderAlloc.SetCurrentKey("Document Type","Document No.",Status);
          ServOrderAlloc.SetRange("Document Type",ServiceHeader."Document Type");
          ServOrderAlloc.SetRange("Document No.",ServiceHeader."No.");
          ServOrderAlloc.SetRange(Status,ServOrderAlloc.Status::Active);
          while ServOrderAlloc.FindFirst do begin
            ServOrderAlloc."Document Type" := "Document Type";
            ServOrderAlloc."Document No." := "No.";
            ServOrderAlloc."Service Started" := true;
            ServOrderAlloc.Status := ServOrderAlloc.Status::"Reallocation Needed";
            ServOrderAlloc.Modify;
          end;

          ServItemLine.Reset;
          ServItemLine.SetRange("Document Type",ServiceHeader."Document Type");
          ServItemLine.SetRange("Document No.",ServiceHeader."No.");
          if ServItemLine.Find('-') then
            repeat
              ServItemLine2 := ServItemLine;
              ServItemLine2."Document Type" := "Document Type";
              ServItemLine2."Document No." := "No.";
              ServItemLine2."Starting Date" := 0D;
              ServItemLine2."Starting Time" := 0T;
              ServItemLine2."Actual Response Time (Hours)" := 0;
              ServItemLine2."Finishing Date" := 0D;
              ServItemLine2."Finishing Time" := 0T;
              RepairStatus.Reset;
              RepairStatus.SetRange(Initial,true);
              if RepairStatus.FindFirst then
                ServItemLine2."Repair Status Code" := RepairStatus.Code;
              ServItemLine2.Insert(true);
              OnAfterInsertServiceLine(ServItemLine2,ServItemLine);
            until ServItemLine.Next = 0;

          UpdateResponseDateTime;

          LoanerEntry.Reset;
          LoanerEntry.SetCurrentKey("Document Type","Document No.");
          LoanerEntry.SetRange("Document Type",ServiceHeader."Document Type" + 1);
          LoanerEntry.SetRange("Document No.",ServiceHeader."No.");
          while LoanerEntry.FindFirst do begin
            LoanerEntry."Document Type" := "Document Type" + 1;
            LoanerEntry."Document No." := "No.";
            LoanerEntry.Modify;
          end;

          ServCommentLine.Reset;
          ServCommentLine.SetRange("Table Name",ServCommentLine."Table Name"::"Service Header");
          ServCommentLine.SetRange("Table Subtype",ServiceHeader."Document Type");
          ServCommentLine.SetRange("No.",ServiceHeader."No.");
          ServCommentLine.SetFilter("Table Line No.",'>%1',0);
          if ServCommentLine.Find('-') then
            repeat
              ServCommentLine2 := ServCommentLine;
              ServCommentLine2."Table Subtype" := "Document Type";
              ServCommentLine2."No." := "No.";
              ServCommentLine2.Insert;
            until ServCommentLine.Next = 0;

          ServLine.Reset;
          ServLine.SetRange("Document Type",ServiceHeader."Document Type");
          ServLine.SetRange("Document No.",ServiceHeader."No.");
          if ServLine.Find('-') then
            repeat
              ServLine2 := ServLine;
              ServLine2."Document Type" := "Document Type";
              ServLine2."Document No." := "No.";
              ServLine2."Posting Date" := "Posting Date";
              ServLine2.Insert;
              ReserveServiceLine.TransServLineToServLine(ServLine,ServLine2,ServLine.Quantity);
            until ServLine.Next = 0;

          ServLogMgt.ServOrderQuoteChanged(NewServHeader,ServiceHeader);
          ApprovalsMgmt.CopyApprovalEntryQuoteToOrder(ServiceHeader.RecordId,"No.",RecordId);
          ApprovalsMgmt.DeleteApprovalEntries(ServiceHeader.RecordId);
          ServLine.DeleteAll(true);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRun(var ServiceHeader: Record "Service Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertServHeader(var ServiceHeaderOrder: Record "Service Header";ServiceHeaderQuote: Record "Service Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertServiceLine(var ServiceItemLine2: Record "Service Item Line";ServiceItemLine: Record "Service Item Line")
    begin
    end;
}

