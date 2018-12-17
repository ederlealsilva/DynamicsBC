codeunit 5494 "Graph Mgt - Country/Region"
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    procedure UpdateIntegrationRecords(OnlyItemsWithoutId: Boolean)
    var
        DummyCountryRegion: Record "Country/Region";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        CountryRegionRecordRef: RecordRef;
    begin
        CountryRegionRecordRef.Open(DATABASE::"Country/Region");
        GraphMgtGeneralTools.UpdateIntegrationRecords(CountryRegionRecordRef,DummyCountryRegion.FieldNo(Id),OnlyItemsWithoutId);
    end;

    [EventSubscriber(ObjectType::Codeunit, 5150, 'OnUpdateReferencedIdField', '', false, false)]
    local procedure HandleUpdateReferencedIdFieldOnItem(var RecRef: RecordRef;NewId: Guid;var Handled: Boolean)
    var
        DummyCountryRegion: Record "Country/Region";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        GraphMgtGeneralTools.HandleUpdateReferencedIdFieldOnItem(RecRef,NewId,Handled,
          DATABASE::"Country/Region",DummyCountryRegion.FieldNo(Id));
    end;

    [EventSubscriber(ObjectType::Codeunit, 5150, 'OnGetPredefinedIdValue', '', false, false)]
    local procedure HandleGetPredefinedIdValue(var Id: Guid;var RecRef: RecordRef;var Handled: Boolean)
    var
        DummyCountryRegion: Record "Country/Region";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        GraphMgtGeneralTools.HandleGetPredefinedIdValue(Id,RecRef,Handled,
          DATABASE::"Country/Region",DummyCountryRegion.FieldNo(Id));
    end;

    [EventSubscriber(ObjectType::Codeunit, 5465, 'ApiSetup', '', false, false)]
    local procedure HandleApiSetup()
    begin
        UpdateIntegrationRecords(false);
    end;
}

