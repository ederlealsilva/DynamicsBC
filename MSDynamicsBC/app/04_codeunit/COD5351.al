codeunit 5351 "CRM Customer-Contact Link"
{
    // version NAVW113.00

    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationTableSynch: Codeunit "Integration Table Synch.";
        SynchActionType: Option "None",Insert,Modify,ForceModify,IgnoreUnchanged,Fail,Skip,Delete;
        Counter: Integer;
    begin
        CODEUNIT.Run(CODEUNIT::"CRM Integration Management");
        Commit;

        IntegrationTableMapping.Get("Record ID to Process");

        IntegrationTableSynch.BeginIntegrationSynchJob(
          TABLECONNECTIONTYPE::CRM,IntegrationTableMapping,IntegrationTableMapping."Table ID");

        Counter :=
          SyncPrimaryContactLinkFromCustomerPrimaryContactNo +
          SyncPrimaryContactLinkFromCRMAccountPrimaryContactId;
        if Counter <> 0 then
          IntegrationTableSynch.UpdateSynchJobCounters(SynchActionType::Modify,Counter);
        IntegrationTableSynch.EndIntegrationSynchJobWithMsg(CustomerContactLinkTxt);
    end;

    var
        CustomerContactLinkTxt: Label 'Customer-contact link.';

    local procedure SyncPrimaryContactLinkFromCustomerPrimaryContactNo() FixedLinksQty: Integer
    var
        Customer: Record Customer;
        CRMAccount: Record "CRM Account";
        NullGuid: Guid;
    begin
        Clear(NullGuid);
        CRMAccount.SetRange(PrimaryContactId,NullGuid);
        if CRMAccount.FindSet(true) then
          repeat
            if FindCustomerByAccountId(CRMAccount.AccountId,Customer) then
              if Customer."Primary Contact No." <> '' then
                if UpdateCRMAccountPrimaryContactId(CRMAccount,Customer."Primary Contact No.") then
                  FixedLinksQty += 1;
          until CRMAccount.Next = 0;
    end;

    local procedure SyncPrimaryContactLinkFromCRMAccountPrimaryContactId() FixedLinksQty: Integer
    var
        Customer: Record Customer;
        Contact: Record Contact;
        CRMAccount: Record "CRM Account";
    begin
        Customer.SetFilter("Primary Contact No.",'=%1','');
        if Customer.FindSet(true) then
          repeat
            if FindCRMAccount(Customer,CRMAccount) then
              if not IsNullGuid(CRMAccount.PrimaryContactId) then
                if FindContactByContactId(CRMAccount.PrimaryContactId,Contact) then begin
                  Customer.Validate("Primary Contact No.",Contact."No.");
                  Customer.Modify;
                  FixedLinksQty += 1;
                end;
          until Customer.Next = 0;
    end;

    local procedure FindCustomerByAccountId(AccountId: Guid;var Customer: Record Customer): Boolean
    var
        CRMIntegrationRecord: Record "CRM Integration Record";
        CustomerRecordID: RecordID;
    begin
        if CRMIntegrationRecord.FindRecordIDFromID(AccountId,DATABASE::Customer,CustomerRecordID) then
          exit(Customer.Get(CustomerRecordID));

        exit(false);
    end;

    local procedure FindContactByContactId(ContactId: Guid;var Contact: Record Contact): Boolean
    var
        CRMIntegrationRecord: Record "CRM Integration Record";
        ContactRecordID: RecordID;
    begin
        if CRMIntegrationRecord.FindRecordIDFromID(ContactId,DATABASE::Contact,ContactRecordID) then
          exit(Contact.Get(ContactRecordID));

        exit(false);
    end;

    local procedure FindCRMAccount(Customer: Record Customer;var CRMAccount: Record "CRM Account"): Boolean
    var
        CRMIntegrationRecord: Record "CRM Integration Record";
        CRMID: Guid;
    begin
        if CRMIntegrationRecord.FindIDFromRecordID(Customer.RecordId,CRMID) then
          exit(CRMAccount.Get(CRMID));

        exit(false);
    end;

    local procedure UpdateCRMAccountPrimaryContactId(var CRMAccount: Record "CRM Account";PrimaryContactNo: Code[20]): Boolean
    var
        Contact: Record Contact;
        CRMIntegrationRecord: Record "CRM Integration Record";
    begin
        Contact.Get(PrimaryContactNo);
        if CRMIntegrationRecord.FindByRecordID(Contact.RecordId) then begin
          CRMAccount.PrimaryContactId := CRMIntegrationRecord."CRM ID";
          CRMAccount.Modify(true);
          exit(true);
        end;

        exit(false);
    end;

    procedure EnqueueJobQueueEntry(CodeunitId: Integer;IntegrationTableMapping: Record "Integration Table Mapping")
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        with JobQueueEntry do begin
          "Object Type to Run" := "Object Type to Run"::Codeunit;
          "Object ID to Run" := CodeunitId;
          if IntegrationTableMapping."Parent Name" <> '' then
            IntegrationTableMapping.Get(IntegrationTableMapping."Parent Name");
          "Record ID to Process" := IntegrationTableMapping.RecordId;
          Priority := 1000;
          Description := CopyStr(CustomerContactLinkTxt,1,MaxStrLen(Description));
          "Maximum No. of Attempts to Run" := 2;
          Status := Status::Ready;
          "Rerun Delay (sec.)" := 30;
          CODEUNIT.Run(CODEUNIT::"Job Queue - Enqueue",JobQueueEntry)
        end;
    end;
}

