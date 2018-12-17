codeunit 5476 "Graph Mgt - Sales Inv. Lines"
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    procedure GetUnitOfMeasureJSON(var SalesInvoiceLineAggregate: Record "Sales Invoice Line Aggregate"): Text
    var
        Item: Record Item;
        GraphCollectionMgtItem: Codeunit "Graph Collection Mgt - Item";
        GraphMgtComplexTypes: Codeunit "Graph Mgt - Complex Types";
        UnitOfMeasureJSON: Text;
    begin
        if SalesInvoiceLineAggregate."No." = '' then
          exit;

        case SalesInvoiceLineAggregate.Type of
          SalesInvoiceLineAggregate.Type::Item:
            begin
              if not Item.Get(SalesInvoiceLineAggregate."No.") then
                exit;

              UnitOfMeasureJSON := GraphCollectionMgtItem.ItemUnitOfMeasureToJSON(Item,SalesInvoiceLineAggregate."Unit of Measure Code");
            end;
          else
            UnitOfMeasureJSON := GraphMgtComplexTypes.GetUnitOfMeasureJSON(SalesInvoiceLineAggregate."Unit of Measure Code");
        end;

        exit(UnitOfMeasureJSON);
    end;

    [EventSubscriber(ObjectType::Codeunit, 5150, 'OnUpdateReferencedIdField', '', false, false)]
    local procedure HandleUpdateReferencedIdFieldOnSalesInvoiceHeader(var RecRef: RecordRef;NewId: Guid;var Handled: Boolean)
    begin
        if Handled then
          exit;

        if RecRef.Number <> DATABASE::"Sales Invoice Line" then
          exit;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 5150, 'OnGetPredefinedIdValue', '', false, false)]
    local procedure HandleGetPredefinedIdValue(var Id: Guid;var RecRef: RecordRef;var Handled: Boolean)
    begin
        if Handled then
          exit;

        if RecRef.Number <> DATABASE::"Sales Invoice Line" then
          exit;

        Handled := true;
    end;
}

