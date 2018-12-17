codeunit 5482 "Graph Mgt - Journal"
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    procedure GetDefaultJournalLinesTemplateName(): Text[10]
    var
        GenJnlTemplate: Record "Gen. Journal Template";
    begin
        GenJnlTemplate.Reset;
        GenJnlTemplate.SetRange("Page ID",PAGE::"General Journal");
        GenJnlTemplate.SetRange(Recurring,false);
        GenJnlTemplate.SetRange(Type,0);
        GenJnlTemplate.FindFirst;
        exit(GenJnlTemplate.Name);
    end;

    procedure GetDefaultCustomerPaymentsTemplateName(): Text[10]
    var
        GenJnlTemplate: Record "Gen. Journal Template";
    begin
        GenJnlTemplate.Reset;
        GenJnlTemplate.SetRange("Page ID",PAGE::"Cash Receipt Journal");
        GenJnlTemplate.SetRange(Recurring,false);
        GenJnlTemplate.SetRange(Type,3);
        GenJnlTemplate.FindFirst;
        exit(GenJnlTemplate.Name);
    end;

    procedure UpdateIntegrationRecords(OnlyItemsWithoutId: Boolean)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        GenJournalBatchRecordRef: RecordRef;
    begin
        GenJournalBatchRecordRef.Open(DATABASE::"Gen. Journal Batch");
        GraphMgtGeneralTools.UpdateIntegrationRecords(GenJournalBatchRecordRef,GenJournalBatch.FieldNo(Id),OnlyItemsWithoutId);
    end;

    [EventSubscriber(ObjectType::Codeunit, 5150, 'OnUpdateReferencedIdField', '', false, false)]
    local procedure HandleUpdateReferencedIdFieldOnTaxGroup(var RecRef: RecordRef;NewId: Guid;var Handled: Boolean)
    var
        DummyGenJournalBatch: Record "Gen. Journal Batch";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        GraphMgtGeneralTools.HandleUpdateReferencedIdFieldOnItem(
          RecRef,NewId,Handled,DATABASE::"Gen. Journal Batch",DummyGenJournalBatch.FieldNo(Id));
    end;

    [EventSubscriber(ObjectType::Codeunit, 5150, 'OnGetPredefinedIdValue', '', false, false)]
    local procedure HandleGetPredefinedIdValue(var Id: Guid;var RecRef: RecordRef;var Handled: Boolean)
    var
        DummyGenJournalBatch: Record "Gen. Journal Batch";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        GraphMgtGeneralTools.HandleGetPredefinedIdValue(
          Id,RecRef,Handled,DATABASE::"Gen. Journal Batch",DummyGenJournalBatch.FieldNo(Id));
    end;

    [EventSubscriber(ObjectType::Codeunit, 5465, 'ApiSetup', '', false, false)]
    local procedure HandleApiSetup()
    begin
        UpdateIntegrationRecords(false);
    end;
}

