codeunit 5528 "Graph Mgt - Purch. Inv. Lines"
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    procedure GetUnitOfMeasureJSON(var PurchInvLineAggregate: Record "Purch. Inv. Line Aggregate"): Text
    var
        Item: Record Item;
        GraphCollectionMgtItem: Codeunit "Graph Collection Mgt - Item";
        GraphMgtComplexTypes: Codeunit "Graph Mgt - Complex Types";
        UnitOfMeasureJSON: Text;
    begin
        if PurchInvLineAggregate."No." = '' then
          exit;

        case PurchInvLineAggregate.Type of
          PurchInvLineAggregate.Type::Item:
            begin
              if not Item.Get(PurchInvLineAggregate."No.") then
                exit;

              UnitOfMeasureJSON := GraphCollectionMgtItem.ItemUnitOfMeasureToJSON(Item,PurchInvLineAggregate."Unit of Measure Code");
            end;
          else
            UnitOfMeasureJSON := GraphMgtComplexTypes.GetUnitOfMeasureJSON(PurchInvLineAggregate."Unit of Measure Code");
        end;

        exit(UnitOfMeasureJSON);
    end;

    [EventSubscriber(ObjectType::Codeunit, 5150, 'OnUpdateReferencedIdField', '', false, false)]
    local procedure HandleUpdateReferencedIdFieldOnPurchaseInvoiceHeader(var RecRef: RecordRef;NewId: Guid;var Handled: Boolean)
    begin
        if Handled then
          exit;

        if RecRef.Number <> DATABASE::"Purch. Inv. Line" then
          exit;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 5150, 'OnGetPredefinedIdValue', '', false, false)]
    local procedure HandleGetPredefinedIdValue(var Id: Guid;var RecRef: RecordRef;var Handled: Boolean)
    begin
        if Handled then
          exit;

        if RecRef.Number <> DATABASE::"Purch. Inv. Line" then
          exit;

        Handled := true;
    end;
}

