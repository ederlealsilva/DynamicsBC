codeunit 5480 "Graph Mgt - Account"
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    local procedure EnableAccountODataWebService()
    begin
        UpdateIntegrationRecords(false);
    end;

    procedure UpdateIntegrationRecords(OnlyItemsWithoutId: Boolean)
    var
        GLAccount: Record "G/L Account";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        GLAccountRecordRef: RecordRef;
    begin
        GLAccountRecordRef.Open(DATABASE::"G/L Account");
        GraphMgtGeneralTools.UpdateIntegrationRecords(GLAccountRecordRef,GLAccount.FieldNo(Id),OnlyItemsWithoutId);
    end;

    [EventSubscriber(ObjectType::Codeunit, 5150, 'OnUpdateReferencedIdField', '', false, false)]
    local procedure HandleUpdateReferencedIdFieldOnAccount(var RecRef: RecordRef;NewId: Guid;var Handled: Boolean)
    var
        DummyGLAccount: Record "G/L Account";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        GraphMgtGeneralTools.HandleUpdateReferencedIdFieldOnItem(
          RecRef,NewId,Handled,DATABASE::"G/L Account",DummyGLAccount.FieldNo(Id));
    end;

    [EventSubscriber(ObjectType::Codeunit, 5150, 'OnGetPredefinedIdValue', '', false, false)]
    local procedure HandleGetPredefinedIdValue(var Id: Guid;var RecRef: RecordRef;var Handled: Boolean)
    var
        DummyGLAccount: Record "G/L Account";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        GraphMgtGeneralTools.HandleGetPredefinedIdValue(
          Id,RecRef,Handled,DATABASE::"G/L Account",DummyGLAccount.FieldNo(Id));
    end;

    [EventSubscriber(ObjectType::Codeunit, 5465, 'ApiSetup', '', false, false)]
    local procedure HandleApiSetup()
    begin
        EnableAccountODataWebService;
    end;
}

