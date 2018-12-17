codeunit 5487 "Graph Mgt - Dimension"
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    procedure UpdateIntegrationRecords(OnlyItemsWithoutId: Boolean)
    var
        Dimension: Record Dimension;
        DimensionValue: Record "Dimension Value";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        DimensionRecordRef: RecordRef;
        DimensionValueRecordRef: RecordRef;
    begin
        DimensionRecordRef.Open(DATABASE::Dimension);
        GraphMgtGeneralTools.UpdateIntegrationRecords(DimensionRecordRef,Dimension.FieldNo(Id),OnlyItemsWithoutId);

        DimensionValueRecordRef.Open(DATABASE::"Dimension Value");
        GraphMgtGeneralTools.UpdateIntegrationRecords(DimensionValueRecordRef,DimensionValue.FieldNo(Id),OnlyItemsWithoutId);
    end;

    [EventSubscriber(ObjectType::Codeunit, 5150, 'OnUpdateReferencedIdField', '', false, false)]
    local procedure HandleUpdateReferencedIdFieldOnDimension(var RecRef: RecordRef;NewId: Guid;var Handled: Boolean)
    var
        DummyDimension: Record Dimension;
        DummyDimensionValue: Record "Dimension Value";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        GraphMgtGeneralTools.HandleUpdateReferencedIdFieldOnItem(
          RecRef,NewId,Handled,DATABASE::Dimension,DummyDimension.FieldNo(Id));

        GraphMgtGeneralTools.HandleUpdateReferencedIdFieldOnItem(
          RecRef,NewId,Handled,DATABASE::"Dimension Value",DummyDimensionValue.FieldNo(Id));
    end;

    [EventSubscriber(ObjectType::Codeunit, 5150, 'OnGetPredefinedIdValue', '', false, false)]
    local procedure HandleGetPredefinedIdValue(var Id: Guid;var RecRef: RecordRef;var Handled: Boolean)
    var
        DummyDimension: Record Dimension;
        DummyDimensionValue: Record "Dimension Value";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        GraphMgtGeneralTools.HandleGetPredefinedIdValue(
          Id,RecRef,Handled,DATABASE::Dimension,DummyDimension.FieldNo(Id));

        GraphMgtGeneralTools.HandleGetPredefinedIdValue(
          Id,RecRef,Handled,DATABASE::"Dimension Value",DummyDimensionValue.FieldNo(Id));
    end;

    [EventSubscriber(ObjectType::Codeunit, 5465, 'ApiSetup', '', false, false)]
    local procedure HandleApiSetup()
    begin
        UpdateIntegrationRecords(false);
    end;
}

