codeunit 5498 "Graph Mgt - Unit Of Measure"
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    procedure UpdateIntegrationRecords(OnlyUofMWithoutId: Boolean)
    var
        DummyUnitOfMeasure: Record "Unit of Measure";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        UnitOfMeasureRecordRef: RecordRef;
    begin
        UnitOfMeasureRecordRef.Open(DATABASE::"Unit of Measure");
        GraphMgtGeneralTools.UpdateIntegrationRecords(UnitOfMeasureRecordRef,DummyUnitOfMeasure.FieldNo(Id),OnlyUofMWithoutId);
    end;

    [EventSubscriber(ObjectType::Codeunit, 5150, 'OnUpdateReferencedIdField', '', false, false)]
    local procedure HandleUpdateReferencedIdFieldOnItem(var RecRef: RecordRef;NewId: Guid;var Handled: Boolean)
    var
        DummyUnitOfMeasure: Record "Unit of Measure";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        GraphMgtGeneralTools.HandleUpdateReferencedIdFieldOnItem(
          RecRef,NewId,Handled,DATABASE::"Unit of Measure",DummyUnitOfMeasure.FieldNo(Id));
    end;

    [EventSubscriber(ObjectType::Codeunit, 5150, 'OnGetPredefinedIdValue', '', false, false)]
    local procedure HandleGetPredefinedIdValue(var Id: Guid;var RecRef: RecordRef;var Handled: Boolean)
    var
        DummyUnitOfMeasure: Record "Unit of Measure";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        GraphMgtGeneralTools.HandleGetPredefinedIdValue(Id,RecRef,Handled,DATABASE::"Unit of Measure",DummyUnitOfMeasure.FieldNo(Id));
    end;

    [EventSubscriber(ObjectType::Codeunit, 5465, 'ApiSetup', '', false, false)]
    local procedure HandleApiSetup()
    begin
        UpdateIntegrationRecords(false);
    end;
}

