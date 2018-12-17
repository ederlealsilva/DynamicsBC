codeunit 5492 "Graph Mgt - Item Category"
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    procedure UpdateIntegrationRecords(OnlyItemsWithoutId: Boolean)
    var
        DummyItemCategory: Record "Item Category";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        ItemCategoryRecordRef: RecordRef;
    begin
        ItemCategoryRecordRef.Open(DATABASE::"Item Category");
        GraphMgtGeneralTools.UpdateIntegrationRecords(ItemCategoryRecordRef,DummyItemCategory.FieldNo(Id),OnlyItemsWithoutId);
    end;

    [EventSubscriber(ObjectType::Codeunit, 5150, 'OnUpdateReferencedIdField', '', false, false)]
    local procedure HandleUpdateReferencedIdFieldOnItem(var RecRef: RecordRef;NewId: Guid;var Handled: Boolean)
    var
        DummyItemCategory: Record "Item Category";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        GraphMgtGeneralTools.HandleUpdateReferencedIdFieldOnItem(RecRef,NewId,Handled,
          DATABASE::"Item Category",DummyItemCategory.FieldNo(Id));
    end;

    [EventSubscriber(ObjectType::Codeunit, 5150, 'OnGetPredefinedIdValue', '', false, false)]
    local procedure HandleGetPredefinedIdValue(var Id: Guid;var RecRef: RecordRef;var Handled: Boolean)
    var
        DummyItemCategory: Record "Item Category";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        GraphMgtGeneralTools.HandleGetPredefinedIdValue(Id,RecRef,Handled,
          DATABASE::"Item Category",DummyItemCategory.FieldNo(Id));
    end;

    [EventSubscriber(ObjectType::Codeunit, 5465, 'ApiSetup', '', false, false)]
    local procedure HandleApiSetup()
    begin
        UpdateIntegrationRecords(false);
    end;
}

