codeunit 5481 "Graph Mgt - Tax Group"
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    procedure UpdateIntegrationRecords(OnlyItemsWithoutId: Boolean)
    var
        DummyTaxGroup: Record "Tax Group";
        DummyVATProductPostingGroup: Record "VAT Product Posting Group";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        TaxGroupRecordRef: RecordRef;
        VATProductPostingGroupRecordRef: RecordRef;
    begin
        TaxGroupRecordRef.Open(DATABASE::"Tax Group");
        GraphMgtGeneralTools.UpdateIntegrationRecords(TaxGroupRecordRef,DummyTaxGroup.FieldNo(Id),OnlyItemsWithoutId);

        VATProductPostingGroupRecordRef.Open(DATABASE::"VAT Product Posting Group");
        GraphMgtGeneralTools.UpdateIntegrationRecords(
          VATProductPostingGroupRecordRef,DummyVATProductPostingGroup.FieldNo(Id),OnlyItemsWithoutId);
    end;

    [EventSubscriber(ObjectType::Codeunit, 5150, 'OnUpdateReferencedIdField', '', false, false)]
    local procedure HandleUpdateReferencedIdFieldOnTaxGroup(var RecRef: RecordRef;NewId: Guid;var Handled: Boolean)
    var
        DummyTaxGroup: Record "Tax Group";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        if not CheckSupportedTable(RecRef) then
          exit;

        GraphMgtGeneralTools.HandleUpdateReferencedIdFieldOnItem(
          RecRef,NewId,Handled,RecRef.Number,DummyTaxGroup.FieldNo(Id));
    end;

    [EventSubscriber(ObjectType::Codeunit, 5150, 'OnGetPredefinedIdValue', '', false, false)]
    local procedure HandleGetPredefinedIdValue(var Id: Guid;var RecRef: RecordRef;var Handled: Boolean)
    var
        DummyTaxGroup: Record "Tax Group";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        if not CheckSupportedTable(RecRef) then
          exit;

        GraphMgtGeneralTools.HandleGetPredefinedIdValue(
          Id,RecRef,Handled,RecRef.Number,DummyTaxGroup.FieldNo(Id));
    end;

    [EventSubscriber(ObjectType::Codeunit, 5465, 'ApiSetup', '', false, false)]
    local procedure HandleApiSetup()
    begin
        UpdateIntegrationRecords(false);
    end;

    local procedure CheckSupportedTable(var RecRef: RecordRef): Boolean
    begin
        exit(RecRef.Number in [DATABASE::"VAT Product Posting Group",DATABASE::"Tax Group"]);
    end;
}

