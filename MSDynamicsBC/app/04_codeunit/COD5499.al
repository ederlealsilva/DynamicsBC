codeunit 5499 "Graph Mgt - Purchase Header"
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    procedure UpdateIntegrationRecords(OnlyItemsWithoutId: Boolean)
    var
        DummyPurchaseHeader: Record "Purchase Header";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        PurchaseHeaderRecordRef: RecordRef;
    begin
        PurchaseHeaderRecordRef.Open(DATABASE::"Purchase Header");
        GraphMgtGeneralTools.UpdateIntegrationRecords(PurchaseHeaderRecordRef,DummyPurchaseHeader.FieldNo(Id),OnlyItemsWithoutId);
    end;

    [EventSubscriber(ObjectType::Codeunit, 5150, 'OnUpdateReferencedIdField', '', false, false)]
    local procedure HandleUpdateReferencedIdFieldOnItem(var RecRef: RecordRef;NewId: Guid;var Handled: Boolean)
    var
        DummyPurchaseHeader: Record "Purchase Header";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        GraphMgtGeneralTools.HandleUpdateReferencedIdFieldOnItem(RecRef,NewId,Handled,
          DATABASE::"Purchase Header",DummyPurchaseHeader.FieldNo(Id));
    end;

    [EventSubscriber(ObjectType::Codeunit, 5150, 'OnGetPredefinedIdValue', '', false, false)]
    local procedure HandleGetPredefinedIdValue(var Id: Guid;var RecRef: RecordRef;var Handled: Boolean)
    var
        DummyPurchaseHeader: Record "Purchase Header";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        GraphMgtGeneralTools.HandleGetPredefinedIdValue(Id,RecRef,Handled,
          DATABASE::"Purchase Header",DummyPurchaseHeader.FieldNo(Id));
    end;

    [EventSubscriber(ObjectType::Codeunit, 5465, 'ApiSetup', '', false, false)]
    local procedure HandleApiSetup()
    begin
        UpdateIntegrationRecords(false);
    end;
}

