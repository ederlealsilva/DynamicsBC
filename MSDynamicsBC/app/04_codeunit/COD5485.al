codeunit 5485 "Graph Mgt - Currency"
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    procedure UpdateIntegrationRecords(OnlyItemsWithoutId: Boolean)
    var
        DummyCurrency: Record Currency;
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        CurrencyRecordRef: RecordRef;
    begin
        CurrencyRecordRef.Open(DATABASE::Currency);
        GraphMgtGeneralTools.UpdateIntegrationRecords(CurrencyRecordRef,DummyCurrency.FieldNo(Id),OnlyItemsWithoutId);
    end;

    [EventSubscriber(ObjectType::Codeunit, 5150, 'OnUpdateReferencedIdField', '', false, false)]
    local procedure HandleUpdateReferencedIdFieldOnItem(var RecRef: RecordRef;NewId: Guid;var Handled: Boolean)
    var
        DummyCurrency: Record Currency;
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        GraphMgtGeneralTools.HandleUpdateReferencedIdFieldOnItem(RecRef,NewId,Handled,
          DATABASE::Currency,DummyCurrency.FieldNo(Id));
    end;

    [EventSubscriber(ObjectType::Codeunit, 5150, 'OnGetPredefinedIdValue', '', false, false)]
    local procedure HandleGetPredefinedIdValue(var Id: Guid;var RecRef: RecordRef;var Handled: Boolean)
    var
        DummyCurrency: Record Currency;
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        GraphMgtGeneralTools.HandleGetPredefinedIdValue(Id,RecRef,Handled,
          DATABASE::Currency,DummyCurrency.FieldNo(Id));
    end;

    [EventSubscriber(ObjectType::Codeunit, 5465, 'ApiSetup', '', false, false)]
    local procedure HandleApiSetup()
    begin
        UpdateIntegrationRecords(false);
    end;
}

