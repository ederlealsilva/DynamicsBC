codeunit 5504 "Graph Mgt - Tax Area"
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    procedure UpdateIntegrationRecords(OnlyItemsWithoutId: Boolean)
    var
        DummyTaxArea: Record "Tax Area";
        DummyVATBusinessPostingGroup: Record "VAT Business Posting Group";
        DummyVATClause: Record "VAT Clause";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        TaxAreaRecordRef: RecordRef;
        VATBusinessPostingGroupRecordRef: RecordRef;
        VATClauseRecordRef: RecordRef;
    begin
        TaxAreaRecordRef.Open(DATABASE::"Tax Area");
        GraphMgtGeneralTools.UpdateIntegrationRecords(TaxAreaRecordRef,DummyTaxArea.FieldNo(Id),OnlyItemsWithoutId);

        VATBusinessPostingGroupRecordRef.Open(DATABASE::"VAT Business Posting Group");
        GraphMgtGeneralTools.UpdateIntegrationRecords(
          VATBusinessPostingGroupRecordRef,DummyVATBusinessPostingGroup.FieldNo(Id),OnlyItemsWithoutId);

        VATClauseRecordRef.Open(DATABASE::"VAT Clause");
        GraphMgtGeneralTools.UpdateIntegrationRecords(VATClauseRecordRef,DummyVATClause.FieldNo(Id),OnlyItemsWithoutId);
    end;

    [EventSubscriber(ObjectType::Codeunit, 5150, 'OnUpdateReferencedIdField', '', false, false)]
    local procedure HandleUpdateReferencedIdField(var RecRef: RecordRef;NewId: Guid;var Handled: Boolean)
    var
        DummyTaxArea: Record "Tax Area";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        if not CheckSupportedTable(RecRef) then
          exit;

        GraphMgtGeneralTools.HandleUpdateReferencedIdFieldOnItem(
          RecRef,NewId,Handled,RecRef.Number,DummyTaxArea.FieldNo(Id));
    end;

    [EventSubscriber(ObjectType::Codeunit, 5150, 'OnGetPredefinedIdValue', '', false, false)]
    local procedure HandleGetPredefinedIdValue(var Id: Guid;var RecRef: RecordRef;var Handled: Boolean)
    var
        DummyTaxArea: Record "Tax Area";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        if not CheckSupportedTable(RecRef) then
          exit;

        GraphMgtGeneralTools.HandleGetPredefinedIdValue(Id,RecRef,Handled,RecRef.Number,DummyTaxArea.FieldNo(Id));
    end;

    [EventSubscriber(ObjectType::Codeunit, 5465, 'ApiSetup', '', false, false)]
    local procedure HandleApiSetup()
    begin
        UpdateIntegrationRecords(false);
    end;

    local procedure CheckSupportedTable(var RecRef: RecordRef): Boolean
    begin
        exit(RecRef.Number in [DATABASE::"VAT Business Posting Group",DATABASE::"Tax Area",DATABASE::"VAT Clause"]);
    end;
}

