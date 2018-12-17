codeunit 5509 "Graph Mgt - Inc Doc Attachment"
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    procedure UpdateIntegrationRecords(OnlyItemsWithoutId: Boolean)
    var
        DummyIncomingDocumentAttachment: Record "Incoming Document Attachment";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        RecRef: RecordRef;
    begin
        RecRef.Open(DATABASE::"Incoming Document Attachment");
        GraphMgtGeneralTools.UpdateIntegrationRecords(RecRef,DummyIncomingDocumentAttachment.FieldNo(Id),OnlyItemsWithoutId);
    end;

    [EventSubscriber(ObjectType::Codeunit, 5150, 'OnUpdateReferencedIdField', '', false, false)]
    local procedure HandleUpdateReferencedIdFieldOnItem(var RecRef: RecordRef;NewId: Guid;var Handled: Boolean)
    var
        DummyIncomingDocumentAttachment: Record "Incoming Document Attachment";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        GraphMgtGeneralTools.HandleUpdateReferencedIdFieldOnItem(
          RecRef,NewId,Handled,DATABASE::"Incoming Document Attachment",DummyIncomingDocumentAttachment.FieldNo(Id));
    end;

    [EventSubscriber(ObjectType::Codeunit, 5150, 'OnGetPredefinedIdValue', '', false, false)]
    local procedure HandleGetPredefinedIdValue(var Id: Guid;var RecRef: RecordRef;var Handled: Boolean)
    var
        DummyIncomingDocumentAttachment: Record "Incoming Document Attachment";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        GraphMgtGeneralTools.HandleGetPredefinedIdValue(
          Id,RecRef,Handled,DATABASE::"Incoming Document Attachment",DummyIncomingDocumentAttachment.FieldNo(Id));
    end;

    [EventSubscriber(ObjectType::Codeunit, 5465, 'ApiSetup', '', false, false)]
    local procedure HandleApiSetup()
    begin
        UpdateIntegrationRecords(false);
    end;
}

