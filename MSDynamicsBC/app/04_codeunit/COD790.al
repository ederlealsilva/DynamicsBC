codeunit 790 "IC Inbox Outbox Subscribers"
{
    // version NAVW111.00

    TableNo = "IC Inbox Transaction";

    trigger OnRun()
    begin
        SetRecFilter;
        "Line Action" := "Line Action"::Accept;
        Modify;
        REPORT.Run(REPORT::"Complete IC Inbox Action",false,false,Rec);
        Reset;
    end;

    [EventSubscriber(ObjectType::Report, 513, 'OnICInboxTransactionCreated', '', false, false)]
    procedure AcceptOnAfterInsertICInboxTransaction(var Sender: Report "Move IC Trans. to Partner Comp";var ICInboxTransaction: Record "IC Inbox Transaction";PartnerCompanyName: Text)
    var
        CompanyInformation: Record "Company Information";
        ICPartner: Record "IC Partner";
    begin
        CompanyInformation.Get;
        ICPartner.ChangeCompany(PartnerCompanyName);

        if not ICPartner.Get(CompanyInformation."IC Partner Code") then
          exit;

        if ICPartner."Auto. Accept Transactions" then
          TASKSCHEDULER.CreateTask(CODEUNIT::"IC Inbox Outbox Subscribers",0,
            true,PartnerCompanyName,0DT,ICInboxTransaction.RecordId);
    end;

    [EventSubscriber(ObjectType::Codeunit, 427, 'ICOutboxTransactionCreated', '', false, false)]
    procedure AcceptOnAfterInsertICOutboxTransaction(ICOutboxTransaction: Record "IC Outbox Transaction")
    var
        CompanyInformation: Record "Company Information";
        ICOutboxExport: Codeunit "IC Outbox Export";
    begin
        CompanyInformation.Get;
        if CompanyInformation."Auto. Send Transactions" then begin
          ICOutboxTransaction."Line Action" := ICOutboxTransaction."Line Action"::"Send to IC Partner";
          ICOutboxTransaction.Modify;
          ICOutboxExport.RunOutboxTransactions(ICOutboxTransaction);
        end;
    end;
}

